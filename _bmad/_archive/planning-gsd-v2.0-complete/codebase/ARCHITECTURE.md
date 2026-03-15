# Architecture

**Analysis Date:** 2026-03-07

## Pattern Overview

**Overall:** Tool-Based Configuration Repository

**Key Characteristics:**
- Configuration organized by tool (not GNU stow)
- Manual symlinking to $HOME` directory structure
- XDG base directory path convention (`tool/.config/tool/`)
- Multi-tool integration via shared shell environment
- MCP (Model Context Protocol) server integration for AI tools

- Plugin-based extensibility for OpenCode and Neovim

## Layers

**Shell Environment Layer:**
- Purpose: Core shell configuration and aliases
- Location: `zsh/`, `bashrc.sh`
- Contains: `.zshrc`, `.bash_aliases`, PATH configuration, Oh My Zsh plugins
- Depends on: Oh My Zsh framework, Nix (optional)
 SSH environment
- Used by: All interactive sessions, terminal emulators

**Editor Layer:**
- Purpose: Primary development editor configuration
- Location: `nvim/.config/nvim/`
- Contains: Lua configuration files, plugin specs, keymaps, autocmds
 options
- Depends on: LazyVim framework, lazy.nvim plugin manager
- Used by: Development workflows, code editing

**Window Management Layer:**
- Purpose: Tiling window management and desktop environment
- Location: `sway/.config/sway/`, `yabai/`, `skhd/.config/skhd/`, `sketchybar/.config/sketchybar/`
- Contains: Sway config, Yabai config, skhd hotkey daemon config, Sketchybar menu bar config
- Depends on: Sway (Wayland), Yabai (macOS tiling), skhd (hotkey daemon)
- Used by: Desktop environment interaction

**Input Layer:**
- Purpose: Keyboard remapping and text expansion
- Location: `kmonad/.config/kmonad/`, `kanata/.config/kanata/`, `espanso/.config/espanso/`
- Contains: Kmonad keyboard definitions, Kanata config, Espanso match packages
- Depends on: Kmonad/Kanata daemons, Espanso daemon
- Used by: All text input scenarios

**AI Development Layer:**
- Purpose: AI-powered coding assistance and automation
- Location: `opencode/.config/opencode/`, `claude/.claude/`, `kilo/.config/kilo/`, `aider/`
- Contains: OpenCode config (micode framework), Claude Code config, Kilo config, Aider config
- Depends on: OpenCode CLI, Claude Code CLI, Ollama (local models)
- Used by: AI-assisted development workflows

**System Services Layer:**
- Purpose: Background services and daemons
- Location: `systemd_user_files/.config/systemd/user/`
- Contains: Ollama service, Syncthing service, ydotoold service, remote_connect service
- Depends on: systemd --user
- Used by: System startup, background processes

**Custom Scripts Layer:**
- Purpose: Utility scripts for display management, gestures, testing
- Location: `local_bin/.local/bin/`
- Contains: Shell scripts for gesture management, display cycling, remote testing, redis-cli wrapper
- Depends on: Bash, Podman (for redis-cli), rsync/SSH (for remote_test.sh)
- Used by: Sway config, manual invocation, automated workflows

**Terminal Emulator Layer:**
- Purpose: Terminal configuration and themes
- Location: `ghostty/.config/ghostty/`, `kitty/.config/kitty/`, `tmux/`, `rio/.config/rio/`
- Contains: Ghostty config, Kitty config, Tmux config, Rio config
- Depends on: Respective terminal binaries
- Used by: Terminal sessions

**Version Control Layer:**
- Purpose: Git configuration
- Location: `git/`
- Contains: `.gitignore_global`, `.gitconfig`
- Depends on: Git
- Used by: Version control operations

## Data Flow

**Configuration Deployment Flow:**

1. Edit configuration file in dotfiles repository
2. Create symlink to `$HOME/ preserving XDG path structure
3. Configuration becomes active on next shell/editor/tool restart

4. Tool reads configuration from `$HOME/.config/tool/` path

**Shell Initialization Flow:**

1. `.zshrc` sources Oh My Zsh and shared aliases
2. PATH is set with tool-specific paths (cargo, bun, asdf, nvim, etc.)
3. Shell plugins loaded (tmux, git, asdf, zoxide, direnv, fzf, etc.)
4. Tmux auto-starts if no attached session exists
5. Aliases and custom functions become available

**AI Development Flow:**

1. OpenCode/Kilo/Claude reads configuration from `~/.config/opencode/` or `~/.config/kilo/`
2. MCP servers initialized (serena, zai-vision, zwebsearch, zwebreader, nvim, clickhouse)
3. Agent uses tools to interact with codebase and external services
4. Memory system persists context across sessions

**State Management:**
- Shell: Environment variables in `.zshrc`, aliases in `.bash_aliases`
- Neovim: Plugin state managed by lazy.nvim, editor state in vim globals
- AI Tools: Session state, memory, task tracking via respective tooling
- Window Management: Workspace state, window layouts managed by Sway/Yabai

## Key Abstractions

**Configuration File:**
- Purpose: Single tool's configuration
- Examples: `sway/.config/sway/config`, `nvim/.config/nvim/init.lua`, `opencode/.config/opencode/opencode.json`
- Pattern: One primary config file per tool, often with includes/imports

**MCP Server:**
- Purpose: External tool integration via Model Context Protocol
- Examples: `opencode/.config/opencode/opencode.json` (mcp section)
- Pattern: Local command execution or remote URL connection

**Plugin System:**
- Purpose: Extensible functionality via plugins
- Examples: `nvim/.config/nvim/lua/plugins/*.lua`, `opencode/.config/opencode/opencode.json` (plugin array)
- Pattern: Plugin specs define dependencies and configuration, framework handles loading

**Service Unit:**
- Purpose: Systemd user service definition
- Examples: `systemd_user_files/.config/systemd/user/*.service`
- Pattern: Standard systemd unit file format with [Service], [Install], [Unit] sections

**Shell Script:**
- Purpose: Automation and utility functions
- Examples: `local_bin/.local/bin/*.sh`
- Pattern: Bash scripts with shebang, often using other tools (rsync, ssh, podman)

## Entry Points

**Shell Entry:**
- Location: `zsh/.zshrc`
- Triggers: Shell startup (interactive/login)
- Responsibilities: Load Oh My Zsh, set PATH, source aliases, start tmux

**Neovim Entry:**
- Location: `nvim/.config/nvim/init.lua`
- Triggers: nvim command execution
- Responsibilities: Bootstrap lazy.nvim, load LazyVim, initialize plugins

**Sway Entry:**
- Location: `sway/.config/sway/config`
- Triggers: Sway startup (login/display connection)
- Responsibilities: Set variables, configure inputs, define keybindings, start services

**OpenCode Entry:**
- Location: `opencode/.config/opencode/opencode.json`
- Triggers: opencode command execution
- Responsibilities: Load providers, initialize MCP servers, configure plugins

**Systemd Services Entry:**
- Location: `systemd_user_files/.config/systemd/user/*.service`
- Triggers: systemctl --user start or system boot
- Responsibilities: Start background services (Ollama, Syncthing, etc.)

## Error Handling

**Strategy:** Fail-fast with logging

**Patterns:**
- Shell: Errors logged to stderr, non-zero exit codes
- Neovim: Lua error handling via pcall, notification system
- Sway: swaynag for notifications, error logging to systemd journal
- AI Tools: Error messages in UI, logging to file/memory

## Cross-Cutting Concerns

**Logging:** Console/stderr for most tools; systemd journal for services; file-based for AI tools

**Validation:** Configuration validation at startup for most tools; syntax checking for configs

**Authentication:** Environment variables for API keys (`.env` pattern); SSH keys for remote operations

---

*Architecture analysis: 2026-03-07*
