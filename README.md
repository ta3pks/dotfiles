# Dotfiles

Personal dotfiles repository for a Linux development environment. Manages configuration files for shell, editors, window managers, terminal emulators, and AI-powered development tools.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/ta3pks/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Link configurations as needed (example)
ln -s ~/dotfiles/nvim/.config/nvim ~/.config/nvim
ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc
```

## Key Components

| Component | Location | Description |
|-----------|----------|-------------|
| Neovim | `nvim/.config/nvim/` | LazyVim-based configuration |
| Zsh | `zsh/` | Shell with Oh My Zsh |
| Sway | `sway/.config/sway/` | Wayland compositor |
| OpenCode | `opencode/.config/opencode/` | AI coding environment |
| Kmonad | `kmonad/.config/kmonad/` | Keyboard remapping |

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

### Prerequisites

- [bun](https://bun.sh/) - Package manager (preferred over npm)
- [cargo](https://rustup.rs/) - Rust toolchain
- [gitleaks](https://github.com/gitleaks/gitleaks) - Secret scanning

### Testing

```bash
# Rust tests
cargo test

# Rust tests on remote machine
~/.local/bin/remote_test.sh
```

## License

Personal configuration files. Use at your own risk.
