# Stack Research

**Domain:** Dotfiles / Development Environment Configuration
**Researched:** 2026-03-08
**Confidence:** HIGH

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| **Git** | 2.40+ | Version control | Universal, already in use, handles submodules well for external themes |
| **Shell scripts (Bash/Zsh)** | N/A | Symlink management | Maximum control, no external dependencies, already implemented |
| **Git submodules** | N/A | External dependencies | Standard for including third-party configs (kitty themes, TPM) |

### Dotfiles Manager Options (Choose One)

| Manager | Version | Best For | Key Features |
|---------|---------|----------|--------------|
| **chezmoi** | 2.69.4 | Multi-machine setups, secrets management | Templates, password manager integration, encryption (age/gpg), cross-platform |
| **yadm** | 3.2.2 | Git-native users, simple needs | Git wrapper, alternate files, encryption, hooks |
| **dotbot** | 1.22.0 | Structured bootstrap, symlink farms | YAML config, plugin system, self-contained Python |
| **Bare git repo** | N/A | Minimalists, maximum control | No tool dependency, pure git worktree approach |
| **Manual symlinks** | N/A | Existing repos, custom needs | Full control, no migration needed, works with any structure |

### Supporting Tools

| Tool | Purpose | When to Use |
|------|---------|-------------|
| **age** | File encryption | When storing secrets in dotfiles (chezmoi/yadm) |
| **GNU Stow** | Symlink farm manager | NOT recommended for this project (explicitly avoided) |

## Current Project Stack Analysis

This repository uses **manual symlinks + shell scripts** approach:

```
dotfiles/
├── zsh/           → ~/.zshrc, ~/.oh-my-zsh/custom/
├── nvim/          → ~/.config/nvim/
├── sway/          → ~/.config/sway/
├── yabai/         → ~/.config/yabai/
├── kmonad/        → ~/.config/kmonad/
├── espanso/       → ~/.config/espanso/
├── opencode/      → ~/.config/opencode/
└── .gitmodules    → External themes (kitty, TPM)
```

**Why this works for this project:**
1. No migration effort required
2. Full control over symlink structure
3. Easy to understand and debug
4. Works with any directory layout
5. AI tool configs (OpenCode, Aider) are complex and benefit from direct control

## Installation

### If Starting Fresh (Not This Project)

```bash
# Option 1: chezmoi (recommended for new dotfiles repos)
brew install chezmoi  # or: apt install chezmoi
chezmoi init https://github.com/username/dotfiles

# Option 2: yadm
brew install yadm
yadm clone https://github.com/username/dotfiles

# Option 3: dotbot
git clone https://github.com/username/dotfiles ~/.dotfiles
cd ~/.dotfiles && ./install

# Option 4: Bare git repo
git init --bare $HOME/.dotfiles
alias config='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
config clone https://github.com/username/dotfiles
```

### For This Project (Manual Approach)

```bash
# Clone with submodules
git clone --recursive https://github.com/nikos/dotfiles ~/dotfiles

# Symlink configs (example)
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/nvim ~/.config/nvim
# ... etc
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Manual symlinks | chezmoi | When managing 3+ machines with different configs |
| Manual symlinks | yadm | When you want git-native workflow with encryption |
| Manual symlinks | dotbot | When you need reproducible bootstrap scripts |
| chezmoi | yadm | When you don't need templates or password manager integration |
| chezmoi | dotbot | When you only need symlink management, not encryption |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| **GNU Stow** | Project explicitly avoids it; breaks existing symlink structure | Manual symlinks or chezmoi |
| **rcm** | No Windows support, less active development | chezmoi or yadm |
| **vcsh** | Complex multi-repo setup, steep learning curve | chezmoi with single repo |
| **Custom framework** | Maintenance burden, reinventing the wheel | chezmoi or manual approach |

## Stack Patterns by Variant

**If single machine, existing repo:**
- Use: Manual symlinks (current approach)
- Because: No migration cost, full control, already working

**If 2+ machines with different configs:**
- Use: chezmoi with templates
- Because: Handle OS differences (Linux vs macOS), machine-specific configs via templates

**If secrets need storage:**
- Use: chezmoi + age encryption or Bitwarden integration
- Because: Secure storage, automatic decryption on apply

**If team/organization dotfiles:**
- Use: dotbot with shared install.conf.yaml
- Because: Reproducible, declarative, easy for others to use

## Feature Comparison Matrix

| Feature | chezmoi | yadm | dotbot | Manual | Bare Git |
|---------|---------|------|--------|--------|----------|
| Templates | ✅ | ✅ (limited) | ❌ | ❌ | ❌ |
| Encryption | ✅ | ✅ | ❌ | Manual | ❌ |
| Password manager | ✅ | ❌ | ❌ | ❌ | ❌ |
| Symlinks | Files | Files | ✅ | Manual | Files |
| Bootstrap scripts | ✅ | ✅ | ✅ | Manual | Manual |
| Windows support | ✅ | ✅ | ✅ | ✅ | ✅ |
| Single binary | ✅ | ❌ | ❌ | N/A | N/A |
| Migration from existing | Medium | Easy | Medium | None | Hard |

## Version Compatibility

| Tool | Minimum Version | Notes |
|------|-----------------|-------|
| chezmoi | 2.60+ | 2.64+ recommended for latest features |
| yadm | 3.0+ | 3.2.2 is current stable |
| dotbot | 1.20+ | 1.22.0 is latest |
| Git | 2.20+ | Required for submodules, worktree |

## Sources

- https://chezmoi.io/ — Official documentation (HIGH confidence)
- https://chezmoi.io/comparison-table/ — Feature comparison (HIGH confidence)
- https://github.com/twpayne/chezmoi/releases — Version verification (HIGH confidence)
- https://yadm.io/ — Official documentation (HIGH confidence)
- https://github.com/TheLocehiliosan/yadm — Repository (HIGH confidence)
- https://github.com/anishathalye/dotbot — Repository and docs (HIGH confidence)
- https://github.com/anishathalye/dotbot/releases — v1.22.0 verified (HIGH confidence)

---
*Stack research for: dotfiles management*
*Researched: 2026-03-08*
