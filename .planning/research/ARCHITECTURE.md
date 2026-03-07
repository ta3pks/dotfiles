# Architecture Research

**Domain:** Dotfiles Management System
**Researched:** 2026-03-08
**Confidence:** HIGH

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DOTFILES REPOSITORY                             │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐           │
│  │  nvim/  │ │  zsh/   │ │  git/   │ │  sway/  │ │  ...    │           │
│  │(editor) │ │ (shell) │ │  (vcs)  │ │  (wm)   │ │(tools)  │           │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘           │
│       │           │           │           │           │                 │
│       └───────────┴───────────┴───────────┴───────────┘                 │
│                               │                                         │
├───────────────────────────────┼─────────────────────────────────────────┤
│                        GNU STOW LAYER                                   │
│                               │                                         │
│         (Creates symlinks from repo packages to target directory)       │
│                               │                                         │
├───────────────────────────────┼─────────────────────────────────────────┤
│                               ▼                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    TARGET DIRECTORY ($HOME)                      │   │
│  │  ~/.config/nvim/  ~/.zshrc  ~/.gitconfig  ~/.config/sway/  ...  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| **Config Packages** | Store tool-specific configurations | Directory per tool with XDG-compatible structure |
| **GNU Stow** | Create/manage symlinks from repo to $HOME | Perl script, symlink farm manager |
| **Bootstrap Script** | Automate initial setup and stow operations | Shell script or Makefile |
| **Custom Binaries** | Store personal utility scripts | `~/.local/bin/` added to PATH |
| **Systemd Services** | User-level service definitions | `~/.config/systemd/user/` |
| **Documentation** | README, CHANGELOG, usage guides | Markdown files in repo root |
| **Git Submodules** | External themes, plugins, frameworks | `.gitmodules` configuration |

## Recommended Project Structure

```
dotfiles/
├── nvim/                      # Neovim configuration
│   └── .config/nvim/          # XDG path structure
│       ├── init.lua
│       ├── lua/config/
│       └── lua/plugins/
├── zsh/                       # Zsh shell configuration
│   ├── .zshrc                 # Main zsh config
│   └── .bash_aliases          # Shared aliases (sourced by bash too)
├── git/                       # Git configuration
│   └── .gitconfig
├── sway/                      # Sway window manager
│   └── .config/sway/
├── yabai/                     # Yabai tiling WM (macOS)
│   └── .config/yabai/
├── skhd/                      # Hotkey daemon
│   └── .config/skhd/
├── sketchybar/                # macOS menu bar
│   └── .config/sketchybar/
├── kmonad/                    # Keyboard remapping
│   └── .config/kmonad/
├── kanata/                    # Alternative keyboard config
│   └── .config/kanata/
├── espanso/                   # Text expansion
│   └── .config/espanso/
├── opencode/                  # AI coding environment
│   └── .config/opencode/
├── aider/                     # AI pair programming
│   └── .config/aider/
├── ghostty/                   # Ghostty terminal
│   └── .config/ghostty/
├── kitty/                     # Kitty terminal
│   └── .config/kitty/
├── tmux/                      # Terminal multiplexer
│   └── .config/tmux/
├── waybar/                    # Wayland bar
│   └── .config/waybar/
├── local_bin/                 # Custom scripts
│   └── .local/bin/
│       ├── remote_test.sh     # Rust remote testing
│       ├── redis-cli          # Podman wrapper
│       └── *.sh               # Various utilities
├── systemd_user_files/        # User systemd services
│   └── .config/systemd/user/
│       ├── ollama.service
│       └── syncthing.service
├── rust/                      # Rust toolchain config
│   └── .rustfmt.toml
├── CLAUDE.md                  # Claude Code instructions
├── CHANGELOG.md               # Version history
├── bashrc.sh                  # Shared bash config
└── .gitmodules                # Submodule definitions
```

### Structure Rationale

- **Per-tool directories**: Each tool gets its own top-level directory, making it easy to `stow <tool>` individually
- **XDG-compliant paths**: Follow `~/.config/<tool>/` convention inside packages for cleaner $HOME
- **Mirror target structure**: Package internal structure mirrors where files land in $HOME (e.g., `nvim/.config/nvim/` → `~/.config/nvim/`)
- **Shared resources**: Shell configs (`.bash_aliases`) sourced by multiple shells

## Architectural Patterns

### Pattern 1: GNU Stow Package Structure

**What:** Each tool's config lives in its own directory that mirrors the target filesystem hierarchy. Stow creates symlinks from package directories to the target (usually $HOME).

**When to use:** Always - this is the core pattern for stow-based dotfiles.

**Trade-offs:**
- ✅ Clean separation between tools
- ✅ Easy to add/remove individual tool configs
- ✅ No external state/database (idempotent)
- ⚠️ Requires understanding of XDG paths
- ⚠️ Symlink conflicts need manual resolution

**Example:**
```
# Repository structure
nvim/.config/nvim/init.lua

# After `stow nvim` from repo root:
~/.config/nvim/init.lua → ~/dotfiles/nvim/.config/nvim/init.lua
```

### Pattern 2: Bootstrap/Install Script

**What:** A script or Makefile that automates the stow process and any additional setup (installing dependencies, setting permissions).

**When to use:** For reproducible setup on new machines.

**Trade-offs:**
- ✅ One-command setup
- ✅ Documented dependency chain
- ⚠️ Needs maintenance as tools change
- ⚠️ Platform-specific variants may be needed

**Example:**
```bash
# Simple bootstrap.sh
#!/bin/bash
cd "$(dirname "$0")"
stow nvim zsh git sway
```

### Pattern 3: Custom Bin Directory

**What:** Store personal utility scripts in `~/.local/bin/` which is added to PATH.

**When to use:** For wrapper scripts, utilities, and tools not available via package managers.

**Trade-offs:**
- ✅ Scripts version-controlled with dotfiles
- ✅ Available everywhere in shell
- ⚠️ Needs PATH configuration in shell rc

**Example:**
```bash
# In .zshrc or .bashrc
export PATH="$HOME/.local/bin:$PATH"
```

### Pattern 4: Systemd User Services

**What:** User-level systemd service definitions for daemons that should start with the session.

**When to use:** For background services (Ollama, Syncthing, custom daemons).

**Trade-offs:**
- ✅ Auto-start with user session
- ✅ Proper service management (restart, logs)
- ⚠️ Linux-specific (not portable to macOS)

## Data Flow

### Installation Flow

```
[New Machine]
     ↓
[Clone Repository] → git clone ~/dotfiles
     ↓
[Install GNU Stow] → package manager
     ↓
[Run Stow] → stow nvim zsh git sway ...
     ↓
[Symlinks Created] → ~/.config/nvim → ~/dotfiles/nvim/.config/nvim
     ↓
[Source Shell RC] → source ~/.zshrc
     ↓
[Environment Ready]
```

### Configuration Update Flow

```
[Edit Config] → Edit file in repo (e.g., ~/dotfiles/nvim/.config/nvim/init.lua)
     ↓
[Change Reflected] → Symlink points to updated file
     ↓
[Tool Picks Up Change] → Neovim reads config on next start
     ↓
[Commit Change] → git commit -am "Update nvim config"
```

### Key Data Flows

1. **Symlink Resolution:** All config reads go through symlinks → actual files in repo
2. **Shell Initialization:** `.zshrc` sources `.bash_aliases` for shared configuration
3. **Service Activation:** systemd reads `~/.config/systemd/user/*.service` → starts daemons
4. **Script Execution:** PATH includes `~/.local/bin` → custom scripts available globally

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| Single machine | Simple stow commands, minimal documentation |
| Multiple machines | Consider chezmoi or yadm for machine-specific templating |
| Team sharing | Extract common configs to separate repos, use submodules |

### Scaling Priorities

1. **First bottleneck:** Machine-specific configs (different paths, hostnames)
   - **Fix:** Use templating (chezmoi) or conditional sourcing in shell rc
2. **Second bottleneck:** Secret management (API keys, tokens)
   - **Fix:** Use `.gitignore` for sensitive files, or encryption (chezmoi/gpg)

## Anti-Patterns

### Anti-Pattern 1: Flat File Structure

**What people do:** Put all dotfiles at repo root with dot prefix (`.zshrc`, `.gitconfig`)

**Why it's wrong:** 
- Can't use stow effectively
- Hard to organize and find related configs
- Clutters repo root

**Do this instead:** Use per-tool directories with internal XDG structure

### Anti-Pattern 2: Absolute Paths in Configs

**What people do:** Hardcode paths like `/home/username/...` in config files

**Why it's wrong:**
- Breaks on different machines with different usernames
- Not portable

**Do this instead:** Use `$HOME`, `~`, or environment variables

### Anti-Pattern 3: Committing Secrets

**What people do:** Include API keys, tokens, passwords in dotfiles repo

**Why it's wrong:**
- Security risk if repo is public
- Credentials leak in git history

**Do this instead:** 
- Use `.gitignore` for sensitive files
- Source external file: `[ -f ~/.secrets ] && source ~/.secrets`
- Use password manager integration (chezmoi supports this)

### Anti-Pattern 4: Manual Symlink Management

**What people do:** Create symlinks manually with `ln -s`

**Why it's wrong:**
- Error-prone
- Hard to track what's linked
- No easy way to remove all links

**Do this instead:** Use stow, rcm, or a dedicated dotfile manager

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| Git submodules | `.gitmodules` for external themes/plugins | TPM, kitty themes |
| Homebrew | Brewfile for macOS packages | Optional, platform-specific |
| Package managers | Bootstrap script installs dependencies | apt, dnf, pacman |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Shell ↔ Tools | Environment variables, PATH | Shell exports vars tools read |
| Stow ↔ $HOME | Symlinks | One-way: repo → home |
| Systemd ↔ Daemons | Service definitions | User-session services |

## Build Order for New Setup

Based on dependencies between components:

```
Phase 1: Core Shell
├── zsh/ (provides shell environment)
└── git/ (provides VCS config)

Phase 2: Editor
└── nvim/ (requires git for plugin management)

Phase 3: Window Management
├── sway/ (or yabai on macOS)
├── skhd/ (hotkeys)
└── waybar/ (status bar)

Phase 4: Development Tools
├── opencode/ (AI coding)
├── aider/ (AI pair programming)
├── rust/ (Rust toolchain)
└── local_bin/ (custom scripts)

Phase 5: System Services
└── systemd_user_files/ (background services)

Phase 6: Additional Tools
├── kmonad/ or kanata/ (keyboard)
├── espanso/ (text expansion)
├── ghostty/ or kitty/ (terminal)
└── tmux/ (multiplexer)
```

## Sources

- GNU Stow Manual: https://www.gnu.org/software/stow/manual/
- dotfiles.github.io: https://dotfiles.github.io/
- Awesome Dotfiles: https://github.com/webpro/awesome-dotfiles
- webpro/dotfiles (Stow + Makefile pattern): https://github.com/webpro/dotfiles
- thoughtbot/dotfiles (rcm pattern): https://github.com/thoughtbot/dotfiles
- chezmoi documentation: https://www.chezmoi.io/

---
*Architecture research for: Dotfiles Management System*
*Researched: 2026-03-08*
