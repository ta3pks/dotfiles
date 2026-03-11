# Dotfiles

Personal dotfiles repository for a Linux development environment. Manages configuration files for shell, editors, window managers, terminal emulators, and AI-powered development tools.

## Quick Start

```bash
git clone https://github.com/ta3pks/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./install
```

## Prerequisites

### Required
- **Shell**: [zsh](https://www.zsh.org/), [Oh My Zsh](https://ohmyz.sh/)
- **Editor**: [neovim](https://neovim.io/) 0.9+, [git](https://git-scm.com/)

### Optional
- **TUI**: [gum](https://github.com/charmbracelet/gum) - Enhanced install script experience
- **Security**: [gitleaks](https://github.com/gitleaks/gitleaks) - Secret scanning
- **Runtime**: [bun](https://bun.sh/) - Package manager (preferred over npm)
- **Runtime**: [cargo](https://rustup.rs/) - Rust toolchain

## Key Components

| Component | Location | Description |
|-----------|----------|-------------|
| Neovim | `nvim/.config/nvim/` | LazyVim-based configuration |
| Zsh | `zsh/` | Shell with Oh My Zsh |
| Sway | `sway/.config/sway/` | Wayland compositor |
| OpenCode | `opencode/.config/opencode/` | AI coding environment |
| Kmonad | `kmonad/.config/kmonad/` | Keyboard remapping |
| Git | `git/` | Git configuration |
| Espanso | `espanso/.config/espanso/` | Text expansion |
| Ghostty | `ghostty/.config/ghostty/` | Terminal emulator |

## Installation

This repository uses an interactive install script (Phase 3) for symlink management:

```bash
./install           # Interactive TUI - select what to link
./install --dry-run # Preview changes without applying
./install --undo    # Restore from backups
```

The script uses manual symlinks (no GNU Stow dependency). See [docs/decisions/001-manual-symlinks.md](docs/decisions/001-manual-symlinks.md) for the rationale.

## Structure

```
~/dotfiles/
├── nvim/          # Neovim (LazyVim)
├── zsh/           # Shell configuration
├── sway/          # Wayland compositor
├── opencode/      # AI coding environment
├── kmonad/        # Keyboard remapping
├── git/           # Git configuration
├── espanso/       # Text expansion
├── ghostty/       # Terminal emulator
├── docs/          # Cross-cutting documentation
│   └── decisions/ # Architecture Decision Records
└── local_bin/     # Custom scripts
```

See per-tool READMEs for details (e.g., [nvim/README.md](nvim/README.md)).

## Symlink Strategy

### XDG Base Directory Compliance

This repository follows the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/):

| XDG Path | Purpose | Example |
|----------|---------|---------|
| `~/.config/` | Configuration files | `~/.config/nvim/` |
| `~/.local/share/` | Data files | `~/.local/share/nvim/` |
| `~/.cache/` | Cache files | `~/.cache/nvim/` |

**Repository structure mirrors XDG:**
- `nvim/.config/nvim/` → `~/.config/nvim/`
- `sway/.config/sway/` → `~/.config/sway/`

### Manual Symlinks

No GNU Stow or dotfile manager. Explicit `ln -s` commands via the install script provide:
- Full control over what gets linked
- No external dependencies
- Easy handling of edge cases

See [ADR-001: Manual Symlinks over GNU Stow](docs/decisions/001-manual-symlinks.md) for the full decision.

## Secrets Management

**Never commit secrets to this repository.**

### Guidelines

1. **Use a password manager** - Store API keys, tokens, and passwords in a secure password manager (1Password, Bitwarden, etc.)

2. **Environment variables** - Copy `.env.example` to `.env` and fill in real values. The `.env` file is gitignored.

3. **Pre-commit scanning** - This repo uses [gitleaks](https://github.com/gitleaks/gitleaks) to detect secrets before commits. If a scan fails, remove the secret from your changes.

4. **AI tool configs** - Configuration directories for AI tools (`.anthropic/`, `.cursor/`, `.opencode/`) are gitignored because they may contain API keys.

### If a Secret Was Accidentally Committed

1. **Rotate the secret immediately** - Generate a new API key/token
2. **Remove from git history** - Use `git filter-branch` or [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
3. **Force push** - Only if necessary and coordinate with any collaborators

## Custom Scripts

Custom utilities are in `local_bin/.local/bin/`:

- `remote_test.sh` - Rust remote testing script
- `redis-cli` - Redis CLI wrapper using Podman

## Development

### Testing

```bash
# Rust tests
cargo test

# Rust tests on remote machine
~/.local/bin/remote_test.sh
```

## Contributing

Personal dotfiles, but feel free to borrow ideas. For architectural decisions, see [docs/decisions/](docs/decisions/).

## License

Personal configuration files. Use at your own risk.
