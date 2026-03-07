# Feature Landscape

**Domain:** Dotfiles / Development Environment Configuration
**Researched:** 2026-03-07
**Confidence:** HIGH (based on official docs, GitHub repos, community resources)

## Table Stakes

Features users expect. Missing = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Version control (Git) | Dotfiles are code; need history, rollback, sync | Low | Bare repo, submodule, or dedicated tool |
| Shell configuration | Core dev environment (aliases, functions, PATH) | Low | `.zshrc`, `.bashrc`, Oh My Zsh, etc. |
| Editor configuration | Developers live in editors | Med | Vim/Neovim, VS Code settings |
| Bootstrap/install script | One-command setup on new machine | Med | `curl | sh` or `make install` pattern |
| README with instructions | Users need to understand what they're installing | Low | Essential for adoption |
| Modular organization | Separate configs per tool, not one monolithic file | Low | `.d/` directories, separate files |
| Git configuration | Name, email, aliases, global ignores | Low | `.gitconfig`, `.gitignore_global` |
| Terminal configuration | Theme, font, keybindings | Low | Terminal emulator settings |

## Differentiators

Features that set product apart. Not expected, but valued.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Templating | Machine-specific configs without duplication | High | chezmoi templates, Jinja2, env vars |
| Secret management | Store API keys, tokens securely | High | Password manager integration, encryption |
| Encryption | Encrypt sensitive files in repo | High | age, GPG, git-crypt, transcrypt |
| Automated package installation | Install dependencies automatically | Med | Homebrew Bundle, apt packages, pacman |
| Idempotent setup | Run installer multiple times safely | Med | Detect existing state, skip if present |
| CI/CD testing | Verify configs work across environments | High | GitHub Actions, shellcheck, startup tests |
| Multi-machine support | Different configs for work/home/server | Med | Templates, branches, or machine detection |
| Self-documenting configs | Comments explain WHY, not just WHAT | Low | Inline documentation, separate docs |
| Quick install (curl \| sh) | Zero-friction new machine setup | Low | Single command from any shell |
| XDG compliance | Follow freedesktop.org standards | Med | `~/.config/` instead of `~/` clutter |
| Window manager configs | Tiling WM, keybindings, themes | Med | i3, Sway, Yabai, bspwm |
| Keyboard customization | Advanced remapping, layers | High | kmonad, kanata, xmodmap |
| Boot scripts | Run commands on shell/editor start | Low | `.zprofile`, init.vim |
| Diff before apply | Preview changes before applying | Low | `chezmoi diff`, `config diff` |
| Rollback capability | Undo changes if something breaks | Med | Git-based tools have this built-in |
| Update mechanism | Pull latest changes easily | Low | `chezmoi update`, git pull wrapper |
| Cross-platform support | Works on Linux, macOS, maybe Windows | High | Conditional logic per OS |
| Theme synchronization | Consistent colors across all tools | Med | Base16, pywal, themer integration |

## Anti-Features

Features to explicitly NOT build.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Hardcoded secrets | Security risk, can't share repo | Use password manager integration or encrypted files |
| Machine-specific configs without abstraction | Can't share, fork, or replicate | Use templates with variables |
| GUI-based configuration | Defeats CLI/automation purpose | Keep configs as text files |
| Over-engineering simple needs | Maintenance burden, complexity | Start simple, add complexity as needed |
| Breaking changes without migration | Users lose work, trust | Provide migration scripts, version configs |
| Auto-install without review | Users don't know what's running | Require explicit opt-in, show diff first |
| Global state modification | Breaks other tools, hard to debug | Use local configs, XDG paths |
| Dependency hell | Can't install without specific versions | Minimize dependencies, use standard tools |
| Monolithic config files | Hard to maintain, understand | Split by tool/function |
| Non-idempotent scripts | Breaks on re-run, unpredictable | Always check before modifying |

## Feature Dependencies

```
Version Control (Git)
├── Bootstrap Script (requires git to clone)
├── Update Mechanism (requires git pull)
└── Rollback (requires git history)

Templating
├── Multi-machine Support (uses templates)
└── Secret Management (can template secrets)

Encryption
├── Secret Management (encrypts secrets)
└── Password Manager Integration (decrypts at apply time)

Bootstrap Script
├── Package Installation (called by bootstrap)
├── Boot Scripts (run after files in place)
└── Idempotent Setup (required for re-runs)
```

## MVP Recommendation

**Prioritize:**
1. **Version control** - Git-based, bare repo or dedicated tool
2. **Shell configuration** - `.zshrc`/`.bashrc` with aliases, functions, PATH
3. **Editor configuration** - Neovim/Vim with plugin manager
4. **Bootstrap script** - One-command setup with idempotency
5. **Modular organization** - Separate files per tool, XDG-compliant paths
6. **README** - Clear installation and customization instructions

**Defer:**
- **Templating**: Add when managing 2+ machines with differences
- **Encryption**: Add when storing secrets (use password manager instead)
- **CI/CD testing**: Add when configs stabilize
- **Multi-machine support**: Add when actually needed

## Tool-Specific Features by Category

### Shell (zsh/bash)
| Feature | Importance | Notes |
|---------|------------|-------|
| Aliases | Table Stakes | Shortcuts for common commands |
| Functions | Table Stakes | Reusable command blocks |
| PATH management | Table Stakes | Add custom bins, tool paths |
| Prompt customization | Differentiator | Starship, pure, custom PS1 |
| Completion | Differentiator | Tab completion for tools |
| History config | Table Stakes | Size, format, deduplication |

### Editor (Neovim/Vim)
| Feature | Importance | Notes |
|---------|------------|-------|
| Plugin manager | Table Stakes | lazy.nvim, packer, vim-plug |
| LSP configuration | Table Stakes | Language servers, completion |
| Keybindings | Table Stakes | Custom mappings |
| Theme | Differentiator | Colorscheme, statusline |
| Linting/formatting | Differentiator | null-ls, conform.nvim |

### Window Management
| Feature | Importance | Notes |
|---------|------------|-------|
| Keybindings | Table Stakes | Window movement, workspace switch |
| Autostart | Table Stakes | Apps that launch with WM |
| Status bar | Differentiator | i3bar, waybar, sketchybar |
| Theming | Differentiator | Colors, fonts, gaps |

### Input/Keyboard
| Feature | Importance | Notes |
|---------|------------|-------|
| Key remapping | Differentiator | kmonad, kanata, xmodmap |
| Text expansion | Differentiator | espanso, custom scripts |
| Layers/modifiers | Differentiator | Home row mods, tap-hold |

## Sources

- [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles) - Curated list of dotfiles resources
- [chezmoi Comparison Table](https://www.chezmoi.io/comparison-table/) - Feature comparison of dotfile managers
- [Atlassian: Bare Git Repository](https://www.atlassian.com/git/tutorials/dotfiles) - Best practices for storing dotfiles
- [dotfiles.github.io](https://dotfiles.github.io/) - Unofficial guide to dotfiles on GitHub
- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) - Popular reference implementation
