local M = {}

local defaults = {
  cmd = "gotermsql",
  args = {},
  width = 0.85,
  height = 0.85,
  border = "rounded",
  title = " gotermsql ",
  title_pos = "center",
}

local config = {}
local state = { buf = nil, win = nil, job_id = nil }

function M.setup(opts)
  config = vim.tbl_deep_extend("force", defaults, opts or {})
  vim.api.nvim_create_user_command("Gotermsql", function(cmd_opts)
    M.toggle(cmd_opts.fargs)
  end, { nargs = "*", desc = "Toggle gotermsql floating terminal" })
end

local function build_cmd(extra_args)
  local parts = { config.cmd }
  for _, a in ipairs(config.args) do
    table.insert(parts, a)
  end
  if extra_args then
    for _, a in ipairs(extra_args) do
      table.insert(parts, a)
    end
  end
  return parts
end

local function calc_win_size()
  local ew = vim.o.columns
  local eh = vim.o.lines - vim.o.cmdheight - 1
  local w = type(config.width) == "number" and config.width <= 1
      and math.ceil(ew * config.width)
      or config.width
  local h = type(config.height) == "number" and config.height <= 1
      and math.ceil(eh * config.height)
      or config.height
  local col = math.floor((ew - w) / 2)
  local row = math.floor((eh - h) / 2)
  return w, h, row, col
end

local function is_valid()
  return state.buf
      and vim.api.nvim_buf_is_valid(state.buf)
      and state.win
      and vim.api.nvim_win_is_valid(state.win)
end

function M.open(extra_args)
  if is_valid() then
    vim.api.nvim_set_current_win(state.win)
    return
  end

  local w, h, row, col = calc_win_size()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "gotermsql"

  local win_opts = {
    relative = "editor",
    width = w,
    height = h,
    row = row,
    col = col,
    style = "minimal",
    border = config.border,
    title = config.title,
    title_pos = config.title_pos,
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)
  state.buf = buf
  state.win = win

  vim.wo[win].scrolloff = 0
  vim.wo[win].sidescrolloff = 0
  vim.wo[win].signcolumn = "no"
  vim.wo[win].cursorcolumn = false
  vim.wo[win].winhighlight = "Normal:Normal,FloatBorder:Normal"

  local cmd = build_cmd(extra_args)

  vim.schedule(function()
    state.job_id = vim.fn.jobstart(cmd, {
      env = { GOTERMSQL_HEIGHT_OFFSET = "-1" },
      term = true,
      on_exit = function()
        vim.schedule(function()
          if state.win and vim.api.nvim_win_is_valid(state.win) then
            vim.api.nvim_win_close(state.win, true)
          end
          if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
            vim.api.nvim_buf_delete(state.buf, { force = true })
          end
          state.buf = nil
          state.win = nil
          state.job_id = nil
        end)
      end,
    })
  end)

  vim.cmd("startinsert")

  vim.keymap.set("n", "q", function()
    M.close()
  end, { buffer = buf, silent = true })

  -- Handle Neovim window resize
  vim.api.nvim_create_autocmd("VimResized", {
    buffer = buf,
    callback = function()
      vim.defer_fn(function()
        if not is_valid() then
          return
        end
        local new_w, new_h, new_row, new_col = calc_win_size()
        vim.api.nvim_win_set_config(state.win, {
          relative = "editor",
          width = new_w,
          height = new_h,
          row = new_row,
          col = new_col,
        })
      end, 20)
    end,
  })
end

function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_delete(state.buf, { force = true })
  end
  state.buf = nil
  state.win = nil
  state.job_id = nil
end

function M.toggle(extra_args)
  if is_valid() then
    M.close()
  else
    M.open(extra_args)
  end
end

return M
