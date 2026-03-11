# Zsh

Oh My Zsh configuration with productivity-focused plugins and aliases.

## Overview

Shell configuration using [Oh My Zsh](https://ohmyz.sh/) with plugins for development workflow, directory navigation, and git integration. Includes shared aliases via `.bash_aliases` for bash/zsh compatibility.

## Files

| File | Purpose |
|------|---------|
| `.zshrc` | Main zsh configuration |
| `.bash_aliases` | Shared aliases (sourced by both bash and zsh) |

## Dependencies

- **zsh** - Shell
- **Oh My Zsh** - Framework (`~/.oh-my-zsh`)
- **tmux** - Terminal multiplexer (auto-starts)
- **fzf** - Fuzzy finder
- **zoxide** - Smart directory jumping
- **direnv** - Environment variable management
- **asdf** - Version manager
- Optional: docker-compose, jq, rust, procs, thefuck

## Plugins

Key plugins enabled:

| Plugin | Purpose |
|--------|---------|
| `tmux` | Tmux integration |
| `git` | Git aliases |
| `asdf` | Version manager |
| `zoxide` | Smart `cd` |
| `direnv` | Auto env loading |
| `fzf` | Fuzzy completion |
| `vi-mode` | Vim-style editing |
| `docker-compose` | Docker completions |

## Customization

### Aliases

Add personal aliases to `.bash_aliases` (shared with bash) or directly in `.zshrc`.

### PATH

The PATH is configured in `.zshrc` to include:
- `~/.local/bin` - Custom scripts
- `~/.asdf/shims` - ASDF shims
- `~/.bun/bin` - Bun runtime
- `~/.local/share/pnpm` - PNPM global

### Tmux Auto-start

Tmux starts automatically if no attached sessions exist. To disable, comment out the tmux block in `.zshrc`.
