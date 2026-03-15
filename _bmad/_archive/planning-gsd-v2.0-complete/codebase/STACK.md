# Technology Stack

**Analysis Date:** 2026-03-07

## Languages

**Primary:**
- Lua - Neovim configuration (`nvim/.config/nvim/lua/`)
- Shell (Bash/Zsh) - Scripts, shell configuration, automation

**Secondary:**
- Rust - Development projects (custom build directory: `$HOME/.rust_build`)
- Python - MCP servers, utility scripts
- JavaScript/TypeScript - OpenCode plugins, MCP tools
- TOML - Configuration files (Cargo, Ghostty, Rio)
- YAML - Configuration (Espanso, Fusuma, systemd)

## Runtime

**Environment:**
- Linux (Fedora-based) - Primary OS
- Wayland - Display protocol (Sway compositor)
- Nix - Package manager integration

**Package Managers:**
- Bun - Node.js package management (preferred over npm)
- Cargo - Rust package manager
- uv - Python package manager (for Serena MCP)
- Nix - System packages
- pnpm - Alternative Node.js package manager

**Lockfiles:**
- `opencode/.config/opencode/bun.lock` - Present

## Frameworks

**Core:**
- LazyVim - Neovim distribution and plugin management (migrated June 2025)
- Oh My Zsh - Shell framework with plugins

**AI/Development:**
- OpenCode - Primary AI coding environment (migrated to micode framework September 2025)
- Aider - AI pair programming tool
- Serena - Code analysis via LSP

**Window Management:**
- Sway - Wayland compositor (i3-compatible)
- Yabai - macOS tiling window manager
- Waybar - Status bar for Wayland

**Terminal Emulators:**
- Ghostty - Primary terminal (config: `ghostty/.config/ghostty/config`)
- Rio - Alternative terminal
- Kitty - Available (with themes submodule)

## Key Dependencies

**Neovim Plugins:**
- `lazy.nvim` - Plugin manager
- `nvim-lspconfig` - Language server configuration
- `LuaSnip` - Snippet engine
- `blink.cmp` - Completion engine
- `avante.nvim` - AI coding assistant
- `codecompanion.nvim` - AI chat interface
- `dadbod-ui` - Database UI
- `wakatime/vim-wakatime` - Time tracking

**Shell Plugins (Oh My Zsh):**
- asdf - Version manager
- zoxide - Directory jumper
- direnv - Environment loader
- fzf - Fuzzy finder
- docker-compose - Container management
- vi-mode - Vim-style editing

**MCP Servers:**
- `@z_ai/mcp-server` - ZAI vision and web tools
- `mcp-clickhouse` - ClickHouse database client
- `mcp-neovim-server` - Neovim integration
- `serena` - Code analysis (via uvx)

**System Tools:**
- Podman - Container runtime (preferred over Docker)
- Syncthing - File synchronization
- Ollama - Local AI model hosting
- Gammastep - Blue light filter

## Configuration

**Environment:**
- Shell: Zsh with Oh My Zsh (`zsh/.zshrc`)
- Editor: Neovim (`nvim/.config/nvim/`)
- Terminal: Ghostty (`ghostty/.config/ghostty/config`)
- Window Manager: Sway (`sway/.config/sway/config`)

**Key Config Files:**
- `.luarc.json` - Lua language server configuration
- `rust/.rustfmt.toml` - Rust formatter settings
- `rust/.cargo/config.toml` - Cargo aliases and build profiles
- `tmux/.tmux.conf` - Terminal multiplexer config
- `git/.gitconfig` - Git configuration with GPG signing

**Environment Variables:**
- `CARGO_TARGET_DIR="$HOME/.rust_build"` - Custom Rust build directory
- `BUN_INSTALL="$HOME/.bun"` - Bun installation path
- `EDITOR=nvim` - Default editor

**Build:**
- Rust: Custom target directory (`~/.rust_build`)
- Profile settings in `rust/.cargo/config.toml`

## Platform Requirements

**Development:**
- Linux (Fedora-based) or macOS (via Yabai/Skhd)
- Wayland or X11 display server
- Git with GPG signing support
- SSH access to remote host `REDACTED_PROJECT` for remote testing

**Production:**
- N/A - This is a dotfiles repository for development environment configuration

## Keyboard/Input

**Advanced Remapping:**
- Kanata - Keyboard remapping (`kanata/.kanata.conf`)
- Kmonad - Alternative keyboard config (`kmonad/.config/kmonad/`)
- Keyd - Yet another keyboard remapper (`keyd/default.conf`)
- Espanso - Text expansion with packages (`espanso/.config/espanso/`)

**Touch Gestures:**
- Fusuma - Touch gesture recognition (`fusuma/.config/fusuma/config.yml`)

---

*Stack analysis: 2026-03-07*
