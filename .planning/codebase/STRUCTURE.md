# Codebase Structure

**Analysis Date:** 2026-03-07

## Directory Layout
```
[project-root]/
├── aider/                      # AI pair programming tool
├── bg_images/                  # Background images
├── claude/                    # Claude Code configuration
├── coc/                      # Coq (conquer) completion
├── espanso/                  # Text expansion
├── etc/                    # System configuration
├── flameshot/               # Screenshot configuration
├── fusuma/               # Touch gesture configuration
├── ghostty/                # Ghostty terminal
├── git/                    # Git configuration
├── gammastep/              # Blue light filter
├── hints/                 # Hints launcher
├── keyd/                  # Keyboard remapping
├── kilo/                  # Kilo AI environment
├── kitty/                 # Kitty terminal (git submodule)
├── kmonad/               # Keyboard remapping
├── kanata/               # Alternative keyboard remapping
├── local_bin/.local/bin/ # Custom scripts
├── mpv/                 # MPV media player
├── nvim/                # Neovim editor
├── opencode/              # OpenCode AI environment
├── rio/                 # Rio terminal
├── rust/                # Rust configuration
├── rustfmt.toml             # Rust formatter config
├── sketchybar/            # Sketchybar menu bar (macOS)
├── skhd/                # Skhd hotkey daemon
├── sketchybarrc           # Main config
├── sway/                # Sway compositor
├── systemd_user_files/   # Systemd user services
├── tmux/                # Tmux configuration
├── waybar/               # Waybar status bar
├── yabai/               # Yabai tiling WM (macOS)
├── zsh/                  # Zsh shell
```

## Directory Purposes
**aider:**
- Purpose: AI pair programming tool configuration
- Contains: `.aider.conf.yml`, aider environment variables
- Key files: `aider/.aider.conf.yml`
- Depends on: aider tool
- Used by: AI-assisted development workflows

**bg_images:**
- Purpose: Desktop background images
- Contains: Various wallpaper images
- Key files: Image files
- Depends on: None
- Used by: Sway config via `cycle_background.sh` script
**claude:**
- Purpose: Claude Code configuration
- Contains: Settings, skills, statusline script
- Key files: `claude/.claude/settings.json`, `claude/.claude/CLAUDE.md`, `claude/.claude/statusline.sh`
- Depends on: Claude Code CLI
- Used by: Claude Code sessions
**coc:**
- Purpose: Coq (conquer) completion
- Contains: coc extensions, ultisnips, settings.json
- Key files: `coc/.config/coc/extensions/`, `coc/.config/coc/ultisnips/`, `coc/.config/coc/settings.json`
- Depends on: coc.nvim
- Used by: Neovim completion
**espanso:**
- Purpose: Text expansion
- Contains: config files, match packages
- Key files: `espanso/.config/espanso/config/default.yml`, `espanso/.config/espanso/match/packages/`
- Depends on: espanso daemon
- Used by: Text expansion across applications
**etc:**
- Purpose: System configuration
- Contains: xorg.conf.d, udev rules, hwdb.d
- Key files: `etc/X11/xorg.conf.d/`, `etc/udev/hwdb.d/`, `etc/udev/rules.d`
- Depends on: System packages
- Used by: Hardware configuration
**flameshot:**
- Purpose: Screenshot configuration
- Contains: flameshot config
- Key files: `flameshot/.config/flameshot`
- Depends on: flameshot package
- Used by: Screenshot capture
**fusuma:**
- Purpose: Touch gesture configuration
- Contains: config.yml
- Key files: `fusuma/.config/fusuma/config.yml`
- Depends on: fusuma daemon, - Used by: Touch gesture handling in Sway
**ghostty:**
- Purpose: Ghostty terminal configuration
- Contains: config file, themes directory
- Key files: `ghostty/.config/ghostty/config`, `ghostty/.config/ghostty/themes/`
- Depends on: Ghostty application
- Used by: Terminal sessions
**git:**
- Purpose: Git configuration
- Contains: global gitignore, gitconfig
- Key files: `git/.gitignore_global`, `git/.gitconfig`
- Depends on: Git
- Used by: All version control operations
**gammastep:**
- Purpose: Blue light filter
- Contains: config.ini
- Key files: `gammastep/.config/gammastep/config.ini`
- Depends on: gammastep daemon
- Used by: Display color temperature adjustment
**hints:**
- Purpose: Hints launcher
- Contains: config.json, setup documentation
- Key files: `hints/.config/hints/config.json`, `hints/hibernate-setup.md`
- Depends on: hints daemon
- Used by: Quick application launcher
**keyd:**
- Purpose: Keyboard remapping
- Contains: configuration files
- Key files: `keyd/` (currently empty or minimal)
- Depends on: keyd daemon
 - Used by: Keyboard input remapping
**kilo:**
- Purpose: Kilo AI environment
- Contains: configuration files, agents, GSD commands
- Key files: `kilo/.config/kilo/opencode.json`, `kilo/.config/kilo/agents/`, `kilo/.config/kilo/command/`, `kilo/.config/kilo/get-shit-done/`, `kilo/.config/kilo/hooks/`
- Depends on: kilo CLI
- Used by: AI-assisted development workflows
**kitty:**
- Purpose: Kitty terminal
- Contains: kitty.conf, theme submodules
- Key files: `kitty/.config/kitty/kitty.conf`, `kitty/.config/kitty/current-theme/` (submodule)
- Depends on: kitty application
 - Used by: Terminal sessions
**kmonad:**
- Purpose: Keyboard remapping
- Contains: .kbd files, service files, udev rules
- Key files: `kmonad/.config/kmonad/config.kbd`, `kmonad/.config/kmonad/apple_keyboard.kbd`, `kmonad/.config/kmonad/kmonad.service`, `kmonad/.config/kmonad/kmonad_apple_kbd.service`, `kmonad/.config/kmonad/kmonad_mx_keys.service`, `kmonad/.config/kmonad/10-mxkeys.rules`
- Depends on: kmonad, evdev, libinput
- Used by: Advanced keyboard input processing
**kanata:**
- Purpose: Alternative keyboard remapping
- Contains: .kbd files, service file
- Key files: `kanata/.config/kanata/kanata.kbd`, `kanata/.config/kanata/kanata.service`
- Depends on: kanata daemon
 - Used by: Alternative to kmonad
**local_bin:**
- Purpose: Custom utility scripts
- Contains: Shell scripts for display tools, automation scripts
- Key files: `local_bin/.local/bin/*.sh` (various scripts)
- Depends on: Bash, system utilities
- Used by: System automation, remote testing, display management
**mpv:**
- Purpose: MPV media player
- Contains: mpv.conf
- Key files: `mpv/.config/mpv/mpv.conf`
- Depends on: mpv
 - Used by: Media playback
**nvim:**
- Purpose: Neovim editor
- Contains: Lua configuration, plugin specs, keymaps, autocmds, options
- Key files: `nvim/.config/nvim/init.lua`, `nvim/.config/nvim/lua/config/`, `nvim/.config/nvim/lua/plugins/`
- Depends on: LazyVim, lazy.nvim
- Used by: Code editing, development workflows
**opencode:**
- Purpose: OpenCode AI environment
- Contains: MCP configs, plugins, providers, agents, skills, GSD commands
- Key files: `opencode/.config/opencode/opencode.json`, `opencode/.config/opencode/AGENTS.md`, `opencode/.config/opencode/mcp/`, `opencode/.config/opencode/plugin/`, `opencode/.config/opencode/skills/`, `opencode/.config/opencode/superpowers/`, `opencode/.config/opencode/command/`, `opencode/.config/opencode/agents/`, `opencode/.config/opencode/hooks/`
- Depends on: OpenCode CLI, micode framework
 - Used by: AI-assisted development, code analysis
**rio:**
- Purpose: Rio terminal
- Contains: config.toml
- Key files: `rio/.config/rio/config.toml`
- Depends on: rio application
- Used by: Terminal sessions
**rust:**
- Purpose: Rust configuration
- Contains: .rustfmt.toml, .cargo/config.toml
- Key files: `rust/.rustfmt.toml`, `rust/.cargo/config.toml`
- Depends on: Rust toolchain
 - Used by: Rust development projects
**sketchybar:**
- Purpose: Sketchybar menu bar (macOS)
- Contains: main config, plugins
- Key files: `sketchybar/.config/sketchybar/sketchybarrc`, `sketchybar/.config/sketchybar/plugins/`
- Depends on: sketchybar application
 - Used by: macOS menu bar
**skhd:**
- Purpose: Skhd hotkey daemon
- Contains: skhdrc
- Key files: `skhd/.config/skhd/skhdrc`
- Depends on: yabai, sketchybar
- Used by: Hotkey bindings for macOS
**sway:**
- Purpose: Sway compositor
 - Contains: config file
- Key files: `sway/.config/sway/config`
- Depends on: Sway, wlroots
 - Used by: Wayland desktop environment
**systemd_user_files:**
- Purpose: Systemd user services
- Contains: service files
- Key files: `systemd_user_files/.config/systemd/user/ollama.service`, `systemd_user_files/.config/systemd/user/syncthing.service`, `systemd_user_files/.config/systemd/user/ydotoold.service`, `systemd_user_files/.config/systemd/user/remote_connect.service`
- Depends on: systemd
 - Used by: Background services
**tmux:**
- Purpose: Tmux configuration
- Contains: tmux.conf, plugins (submodules)
- Key files: `tmux/.tmux.conf`, `tmux/.tmux/plugins/tpm/`, `tmux/.tmux/plugins/tmux-copycat/` (submodules)
 - Depends on: tmux
 - Used by: Terminal multiplexing
**waybar:**
- Purpose: Waybar status bar
- Contains: config, style, scripts
- Key files: `waybar/.config/waybar/config.jsonc`, `waybar/.config/waybar/style.css`, `waybar/.config/waybar/scripts/`
- Depends on: waybar application
 - Used by: Status bar display
**yabai:**
- Purpose: Yabai tiling WM (macOS)
- Contains: (currently minimal or empty)
- Key files: `yabai/` (empty or minimal)
- Depends on: yabai
 - Used by: macOS tiling window management
**zsh:**
- Purpose: Zsh shell
- Contains: .zshrc, .bash_aliases
- Key files: `zsh/.zshrc`, `zsh/.bash_aliases`
- Depends on: Oh My Zsh
 zoxide, direnv, fzf, asdf
 - Used by: Interactive shell sessions, command execution
```

## Key File Locations
**Entry Points:**
- `zsh/.zshrc`: Shell initialization, sources bashrc.sh, sources secret_env
 starts tmux
- `nvim/.config/nvim/init.lua`: Neovim entry point
- `opencode/.config/opencode/opencode.json`: OpenCode configuration
- `sway/.config/sway/config`: Sway configuration
 - `kmonad/.config/kmonad/config.kbd`: Kmonad keyboard layout

- `kanata/.config/kanata/kanata.kbd`: Kanata keyboard layout

**sketchybar/.config/sketchybar/sketchybarrc`: Sketchybar configuration

 **tmux/.tmux.conf`: Tmux configuration
**waybar/.config/waybar/config.jsonc`: Waybar configuration

**Configuration:**
- `git/.gitignore_global`: Global gitignore
- `git/.gitconfig`: Global git config
- `rust/.rustfmt.toml`: Rust formatter config
- `rust/.cargo/config.toml`: Cargo configuration
- `.luarc.json`: Lua language server config
- `opencode/.config/opencode/opencode.json`: OpenCode main config
- `opencode/.config/opencode/AGENTS.md`: Agent guidelines
- `CLAUDE.md`: Project instructions
- `.gitmodules`: Git submodules

- `CHANGELOG.md`: Change history
- `.luarc.json`: Lua LSP config
- `nvim/.config/nvim/.neoconf.json`: Neovim options
- `nvim/.config/nvim/stylua.toml`: StyLua config
- `sway/.config/sway/config`: Sway window manager config
- `kmonad/.config/kmonad/config.kbd`: Kmonad config
- `kanata/.config/kanata/kanata.kbd`: Kanata config
 - `skhd/.config/skhd/skhdrc`: Skhd config
- `sketchybar/.config/sketchybar/sketchybarrc`: Sketchybar config
- `tmux/.tmux.conf`: Tmux config
- `waybar/.config/waybar/config.jsonc`: Waybar config
- `waybar/.config/waybar/style.css`: Waybar styles
- `waybar/.config/waybar/scripts/glm-quota.py`: GLM quota script
- `systemd_user_files/.config/systemd/user/ollama.service`: Ollama service
- `systemd_user_files/.config/systemd/user/syncthing.service`: Syncthing service
- `systemd_user_files/.config/systemd/user/ydotoold.service`: ydotool service
- `systemd_user_files/.config/systemd/user/remote_connect.service`: Remote connection service
- `local_bin/.local/bin/remote_test.sh`: Rust remote testing
- `local_bin/.local/bin/redis-cli`: Redis CLI wrapper
- `local_bin/.local/bin/cycle_background.sh`: Background cycler
- `local_bin/.local/bin/toggle_builtin_display.sh`: Display toggle
- `local_bin/.local/bin/gesture-watchdog.sh`: Gesture watchdog
- `local_bin/.local/bin/waybar.sh`: Waybar script
- `local_bin/.local/bin/askpass`: Sudo askpass

**Core Logic:**
- `nvim/.config/nvim/lua/config/options.lua`: Neovim options
- `nvim/.config/nvim/lua/config/keymaps.lua`: Neovim keymaps
- `nvim/.config/nvim/lua/config/autocmds.lua`: Neovim autocommands
- `nvim/.config/nvim/lua/config/lazy.lua`: LazyVim bootstrap
- `nvim/.config/nvim/lua/plugins/main.lua`: Main plugins
- `nvim/.config/nvim/lua/plugins/avante.lua`: Avante plugin
- `nvim/.config/nvim/lua/plugins/codecompanion.lua`: CodeCompanion plugin
- `nvim/.config/nvim/lua/plugins/opencode.lua`: OpenCode plugin
- `nvim/.config/nvim/lua/plugins/serenade.lua`: Serenade plugin
- `opencode/.config/opencode/mcp/`: MCP server configs
- `opencode/.config/opencode/skills/`: Skills directory
- `opencode/.config/opencode/command/`: GSD commands
- `opencode/.config/opencode/hooks/`: Hooks
- `opencode/.config/opencode/agents/`: Agent definitions
- `opencode/.config/opencode/superpowers/`: Superpower skills
- `opencode/.config/opencode/plugins/`: Plugin configs
- `kilo/.config/kilo/agents/`: Kilo agents
- `kilo/.config/kilo/command/`: Kilo commands
- `kilo/.config/kilo/hooks/`: Kilo hooks
- `kilo/.config/kilo/get-shit-done/`: GSD framework

 - `claude/.claude/skills/`: Claude skills

**Testing:**
- None (configuration repository)
- `local_bin/.local/bin/remote_test.sh`: Rust remote testing (shell script)
- Custom scripts in `local_bin/.local/bin/` for Sway integration

- gestures, display management, remote testing

**Utilities:**
- `local_bin/.local/bin/`: Custom scripts
- `waybar/.local/bin/`: Waybar helper scripts
- `.serena/memories/`: Serena memory storage
- `.claude/memory/`: Claude memory storage
- `.planning/`: Planning documents
```

## Naming Conventions
**Files:**
- Dotfiles: `.<filename>` (e.g., `.zshrc`, `.gitconfig`)
- Configs: `<tool-name>.config` or just `<name>` (e.g., `config`, `skhdrc`)
- Scripts: `<name>.sh` (e.g., `remote_test.sh`, `cycle_background.sh`)
- Services: `<name>.service` (e.g., `ollama.service`, `kmonad.service`)
- Keyboard layouts: `<name>.kbd` (e.g., `config.kbd`, `kanata.kbd`)
- Plugins: `<name>.lua` (e.g., `main.lua`, `avante.lua`)

- Agent configs: `<name>.json` or `AGENTS.md` (e.g., `opencode.json`, `AGENTS.md`)

- MCP configs: `<server-name>.json` or embedded in main config (e.g., in `opencode.json`)

**Directories:**
- `<tool-name>/.config/<tool-name>/` - Standard XDG path pattern
- `<tool-name>/.local/bin/` - Tool-specific binaries
- `lua/config/` - Neovim configuration
- `lua/plugins/` - Neovim plugins
- `match/packages/` - Espanso packages
- `plugins/` - Tmux plugins, - Sketchybar plugins

- `.config/<tool>/themes/` - Theme directories

 - `.local/bin/` - User-local binaries

## Where to Add New Code:**
**New Tool Configuration:**
    1. Create directory: `<tool-name>/.config/<tool-name>/`
    2. Create configuration files inside
    3. Create symlink: `ln -s ~/.config/<tool-name> ~/.config/<tool-name>`
```
- Primary code: `<tool-name>/.config/<tool-name>/`
- Tests: None (configuration repository)
- **New Component/Module:**
    - Implementation: `<tool-name>/.config/<tool-name>/`
- **Utilities:**
    - Shared helpers: `local_bin/.local/bin/`
- **New AI Tool/MCP Server:**
    1. Add to `opencode/.config/opencode/mcp/` section
    2. Add provider configuration in `opencode.json`
    3. Test with `opencode --help`
- **New Keyboard Layout:**
    1. Create `.kbd` file in `kmonad/.config/kmonad/` or `kanata/.config/kanata/`
    2. Create service file if needed: `*.service`
 in same directory
    3. Create udev rule if needed: `*.rules` in `etc/udev/hwdb.d/`
    4. Create symlink: `ln -s ~/.config/kmonad ~/.config/kmonad` (or `~/.config/kanata`)
- **New systemd Service:**
    1. Create service file in `systemd_user_files/.config/systemd/user/`
    2. Create symlink: `ln -s ~/.config/systemd/user <service-name>.service ~/.config/systemd/user/<service-name>.service`
    3. Enable with `systemctl --user enable <service-name>`
- **New Neovim Plugin:**
    1. Create file in `nvim/.config/nvim/lua/plugins/`
    2. Follow LazyVim plugin spec format
    3. Restart Neovim to load plugin
- **New Custom Script:**
    1. Create script in `local_bin/.local/bin/`
    2. Make executable: `chmod +x`
    3. Create symlink: `ln -s ~/.local/bin/<script-name> ~/.local/bin/<script-name>`
```

## Special Directories
**git/hooks/:**
- Purpose: Git hooks for automation
- Generated: No
- Committed: Yes
- Note: Create executable hooks here for custom automation
**nvim/config.old/:**
- Purpose: Old Neovim configuration backup
- Generated: No
- Committed: Yes
- Note: Reference only, not for active config
**kitty/.config/kitty/current-theme/:**
- Purpose: Kitty theme submodule
- Generated: No
- Committed: Yes
- Note: Git submodule - update with `git submodule update --init`
**tmux/.tmux/plugins/:**
- Purpose: Tmux plugins (submodules)
- Generated: No
- Committed: Yes
- Note: Git submodules - update with `git submodule update --init`
**ghostty/.config/ghostty/themes/:**
- Purpose: Ghostty terminal themes
- Generated: No
- Committed: Yes
- Note: Git submodule - themes are external repository
**espanso/.config/espanso/match/packages/:**
- Purpose: Espanso text expansion packages
- Generated: No
- Committed: Yes
- Note: Git submodules for package management
**opencode/.config/opencode/cache/:**
- Purpose: OpenCode cache directory
- Generated: Yes (- Committed: No (in .gitignore)
- Note: Cache files, not not committed
**.claude/:**
- Purpose: Claude-specific cache and memory
- Generated: Yes
- Committed: No (in .gitignore)
- Note: Not part of dotfiles repository
**.serena/:**
- Purpose: Serena analysis cache and memory
- Generated: Yes
- Committed: No (in .gitignore)
- Note: Code analysis artifacts
**.planning/:**
- Purpose: Planning documents
- Generated: Yes
- Committed: Yes
- Note: GSD planning documents stored here
**node_modules (in kilo):**
- Purpose: Kilo dependencies
- Generated: Yes
- Committed: No (in .gitignore)
- Note: Managed by kilo CLI,**.gitmodules:**
- Purpose: Git submodules (kitty themes, tmux plugins)
- Generated: Yes
- Committed: Yes
- Note: External repositories cloned as submodules
**bg_images:**
- Purpose: Background images
- Generated: No
- Committed: Yes
- Note: Static assets for background cycling
**hints/.config/hints: (directory):**
- Purpose: Hints configuration directory
- Generated: No
- Committed: Yes
- Note: Contains hints launcher config

**cv.md, cv.pdf:**
- Purpose: CV documents
- Generated: No
- Committed: Yes
- Note: Personal documents, not part of dotfiles
**kbd.zip:**
- Purpose: Keyboard layout archive
- Generated: No
- Committed: Yes
- Note: Backup of keyboard layouts
**Tomorrow Night Eighties.terminal:**
- Purpose: Terminal theme file
- Generated: No
- Committed: Yes
- Note: Terminal emulator theme file
**.env, (not tracked):**
- Purpose: Environment file
- Generated: No
- Committed: No (in .gitignore)
- Note: Secrets and environment variables (not in repository)
**.ssh/secret_env:**
- Purpose: Secret environment variables
- Generated: No
- Committed: No (in .gitignore)
- Note: Loaded by `.zshrc`, contains secrets (not in repository)

**aider/.aider.conf.yml:**
- Purpose: Aider configuration (if exists)
- Generated: No
- Committed: No (in .gitignore)
- Note: AI tool configuration, not part of main dotfiles

**.gitattributes:**
- Purpose: Git attributes
- Generated: No
- Committed: Yes
- Note: Git LFS configuration
**.gitignore:**
- Purpose: Git ignore patterns
- Generated: No
- Committed: Yes
- Note: Standard gitignore for repository

**.gitmodules:**
- Purpose: Git submodules
- Generated: No
- Committed: Yes
- Note: Submodule definitions

**.luarc.json:**
- Purpose: Lua language server config
- Generated: No
- Committed: Yes
- Note: Neovim LSP configuration
**CHANGELOG.md:**
- Purpose: Change history
- Generated: No
- Committed: Yes
- Note: Human-readable change log
**CLAUDE.md:**
- Purpose: Claude Code instructions
- Generated: No
- Committed: Yes
- Note: Project-specific instructions for Claude Code
**AGENTS.md (opencode):**
- Purpose: Agent guidelines
- Generated: No
- Committed: Yes
- Note: Tool usage guidelines for AI agents
**rust/.rustfmt.toml:**
- Purpose: Rust formatter configuration
- Generated: No
- Committed: Yes
- Note: Rust code formatting rules
**rust/.cargo/config.toml:**
- Purpose: Cargo configuration
- Generated: No
- Committed: Yes
- Note: Rust build configuration

 **bashrc.sh:**
- Purpose: Shared bash configuration
- Generated: No
- Committed: Yes
- Note: Sourced by both `.zshrc` and `.bashrc`

**zsh/.bash_aliases:**
- Purpose: Shared aliases
- Generated: No
- Committed: Yes
- Note: Sourced by `.zshrc` and `.bashrc`

---

*Structure analysis: 2026-03-07*
