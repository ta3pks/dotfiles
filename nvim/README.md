# Neovim

LazyVim-based Neovim configuration for productive development.

## Overview

This configuration uses [LazyVim](https://www.lazyvim.org/) as a base with additional plugins for AI-assisted coding, Rust development, and custom keymaps. The setup is designed for:

- Fast startup with lazy loading
- LSP support for multiple languages
- AI coding assistants integration
- Custom snippets for Rust and global use

## Files

| File | Purpose |
|------|---------|
| `init.lua` | Entry point, loads LazyVim |
| `lua/config/options.lua` | Neovim options |
| `lua/config/keymaps.lua` | Custom keymaps |
| `lua/config/autocmds.lua` | Autocommands |
| `lua/config/lazy.lua` | Lazy.nvim setup |
| `lua/plugins/main.lua` | Core plugins |
| `lua/plugins/opencode.lua` | OpenCode integration |
| `lua/plugins/avante.lua` | Avante AI assistant |
| `lua/plugins/codecompanion.lua` | CodeCompanion AI |
| `luasnip/global.lua` | Global snippets |
| `luasnip/rust.lua` | Rust-specific snippets |

## Dependencies

- **neovim** 0.9+
- **git** - For plugin management
- **LSP servers** - Install via your system package manager or Mason

## Customization

### Adding Plugins

Create a new file in `lua/plugins/` following LazyVim conventions:

```lua
return {
  {
    "author/plugin-name",
    config = function()
      -- configuration
    end,
  },
}
```

### Adding Snippets

Add to `luasnip/global.lua` for language-agnostic snippets or create a new file for language-specific ones.

### Key Bindings

Edit `lua/config/keymaps.lua` to add or modify keymaps.
