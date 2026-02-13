# gotermsql.nvim

Neovim plugin for [gotermsql](https://github.com/sadopc/gotermsql) — launch a database TUI in a floating terminal window.

![gotermsql.nvim](https://github.com/sadopc/gotermsql/raw/main/gotermsql-demo.gif)

## Install

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "sadopc/gotermsql.nvim",
  keys = {
    { "<leader>db", "<cmd>Gotermsql<cr>", desc = "Toggle gotermsql" },
  },
  opts = {},
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "sadopc/gotermsql.nvim",
  config = function()
    require("gotermsql").setup()
  end,
}
```

## Usage

| Command | Description |
| --- | --- |
| `:Gotermsql` | Toggle the floating terminal |
| `:Gotermsql --adapter sqlite --file my.db` | Open with specific arguments |

Or from Lua:

```lua
require("gotermsql").toggle()
require("gotermsql").open({ "--adapter", "sqlite", "--file", "my.db" })
require("gotermsql").close()
```

## Configuration

```lua
require("gotermsql").setup({
  cmd = "gotermsql",      -- path to gotermsql binary
  args = {},              -- default arguments (e.g. {"--adapter", "sqlite", "--file", "dev.db"})
  width = 0.85,           -- float: percentage of editor width, int: fixed columns
  height = 0.85,          -- float: percentage of editor height, int: fixed rows
  border = "rounded",     -- border style: "rounded", "single", "double", "none"
  title = " gotermsql ",  -- window title
  title_pos = "center",   -- title position: "left", "center", "right"
})
```

## Suggested Keybinding

```lua
vim.keymap.set("n", "<leader>db", "<cmd>Gotermsql<cr>", { desc = "Toggle gotermsql" })
```

## Requirements

- Neovim >= 0.9
- [gotermsql](https://github.com/sadopc/gotermsql) installed and on your `PATH`

## License

MIT
