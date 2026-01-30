# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for a Linux development environment. The repository manages configuration files for shell, editors, window managers, terminal emulators, and AI-powered development tools without using GNU stow or similar tools - files are organized by tool and linked manually.

## Key Architectural Components

### OpenCode Configuration (`opencode/.config/opencode/`)

OpenCode is the primary AI coding environment, recently migrated to the **micode framework** (September 2025). Key architectural details:

- **Multi-model provider setup**:
  - ZAI Coding Plan (GLM-4.7) - primary model
  - Ollama (local models: gpt-oss:latest, gpt-oss:20b, gpt-oss:120b-cloud)
  - OpenRouter (xiaomi/mimo-v2-flash:free)

- **MCP (Model Context Protocol) servers**:
  - `zai-vision`: Image analysis (OCR, UI analysis, technical diagrams, error diagnosis)
  - `zwebsearch`, `zwebreader`: Web access tools (preferred over generic websearch)
  - `zread`: GitHub documentation searching and reading
  - `clickhouse`: Database integration
  - `nvim`: Neovim server integration (socket: `/tmp/nvim`)
  - `serena`: **Critical** - Code analysis and semantic operations (preferred for all code operations)

- **Plugin system**:
  - `micode`: Multi-agent orchestration framework
  - `opencode-mem`: Memory management
  - `opencode-wakatime`: Time tracking
  - `@mohak34/opencode-notifier`: Notifications
  - `@tarquinen/opencode-dcp`: Docker-related operations

### Development Tools

**Neovim** (`nvim/.config/nvim/`): LazyVim-based configuration
- Lua-based with lazy.nvim plugin manager
- Migrated to LazyVim June 2025
- Language server configurations in `.luarc.json`

**Rust Development**:
- Custom build directory: `$HOME/.rust_build`
- Rustfmt configured via `rust/.rustfmt.toml`
- Remote testing script: `local_bin/.local/bin/remote_test.sh`
  - Builds test binary with `cargo test --no-run --lib`
  - Uses rsync to transfer to remote host `dedecta`
  - Executes tests via SSH

**Package Management**: Use `bun` instead of `npm` for all Node.js operations

### Window Management & Desktop

- **Sway** (`sway/.config/sway/`): Wayland compositor
- **Yabai** (`yabai/.config/yabai/`): macOS-style tiling window manager
- **Skhd** (`skhd/.config/skhd/`): Hotkey daemon for Yabai
- **Sketchybar** (`sketchybar/.config/sketchybar/`): Menu bar with plugins

### Input & Keyboard

- **Kmonad** (`kmonad/.config/kmonad/`): Advanced keyboard remapping with multitap and layer switching
- **Kanata** (`kanata/.config/kanata/`): Alternative keyboard configuration
- **Espanso** (`espanso/.config/espanso/`): Text expansion with packages for contractions and misspelling correction

### Shell Environment

- **Zsh** (`zsh/`): Primary shell with Oh My Zsh
- **Bash** (`bashrc.sh`): Shared via `.bash_aliases`
- PATH includes nvim, Applications, cargo, and `$HOME/.local/bin`

### Systemd User Services

Located in `systemd_user_files/`:
- Ollama service for local AI models
- Syncthing for file synchronization

### Custom Binaries

All custom scripts in `local_bin/.local/bin/`:
- `redis-cli`: Wrapper using Podman with host network access
- `remote_test.sh`: Rust remote testing script
- Various display/gesture management scripts for Sway

## Critical Agent Guidelines (from `opencode/.config/opencode/AGENTS.md`)

### Tool Preferences

**Web Access**: Always prefer ZAI MCPs (`zwebsearch`, `zwebreader`, `zread`) over generic websearch tools

**Code Operations**: **ALWAYS use Serena tools** for code operations - they are more efficient than bash-based tools:
- Understanding: `serena_get_symbols_overview`, `serena_find_symbol`, `serena_find_referencing_symbols`
- Searching: `serena_search_for_pattern`, `serena_find_symbol` with substring matching
- Files: `serena_list_dir`, `serena_find_file`
- Modifying: `serena_replace_symbol_body`, `serena_insert_after_symbol`, `serena_rename_symbol`
- Thinking: `serena_think_about_collected_information`, `serena_think_about_task_adherence`, `serena_think_about_whether_you_are_done`
- Memory: `serena_write_memory`, `serena_read_memory`, `serena_list_memories`

**Never use**: `glob` or `grep` for code searches; `bash ls` or `bash find` for file operations

### Package Management

- Use `bun` instead of `npm` for all Node.js operations
- `bun install`, `bun run`, `bun add` - never `npm` commands

### UI Testing Requirements

**CRITICAL**: When updating UI, always test with Playwright BEFORE manual testing:
1. Start application locally
2. Run Playwright tests to verify functionality
3. Take screenshots at key states
4. Use `zai-vision` MCP to verify visual behavior (overflow, color, alignment, responsive layout)
5. Fix issues before manual verification

### Task Tracking

Two separate systems:
1. **Project tasks**: Check/update project task file (e.g., `todo.txt`) BEFORE and AFTER every task
2. **Session progress**: Use todoread/todowrite tools for current session tracking (not project task file)

## Common Development Commands

### Rust Development
```bash
# Build and run tests locally
cargo build
cargo test

# Run tests on remote machine (dedecta)
~/.local/bin/remote_test.sh

# Build specific binary with custom output directory
cargo build --target-dir $HOME/.rust_build
```

### Node.js/Bun
```bash
bun install          # Install dependencies
bun run <script>     # Run script
bun add <package>    # Add package
```

### Neovim
- Configuration is Lua-based using LazyVim framework
- Plugins managed by lazy.nvim
- Run `:Lazy` to manage plugins

### Git Submodules
```bash
# Initialize and update submodules (e.g., kitty themes, TPM)
git submodule update --init --recursive
```

## Recent Major Changes

From `CHANGELOG.md`:
- **2025-06**: Migrated to LazyVim for Neovim
- **2025-08**: Added Aider configuration, Kanata configs, systemd user services (Ollama, Syncthing)
- **2025-09**: Migrated OpenCode to micode framework, added Serena integration, added ClickHouse client alias (`dccl`)
- **2025-10**: Added Ghostty terminal configuration
- **2025-01-29**: Added redis-cli wrapper using Podman with host network access

## Project-Specific Notes

- **ClickHouse integration**: Use alias `dccl` for ClickHouse client access
- **Containerization**: Podman is preferred (see redis-cli wrapper)
- **Testing**: Remote testing support for Rust projects via dedicated script
- **AI Development**: Heavy integration with AI tools - OpenCode, Aider, Ollama local models
- **Memory system**: Uses `claude-mem` for activity tracking and context preservation across sessions
