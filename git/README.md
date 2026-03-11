# Git

Git configuration with aliases, merge tools, and credential helpers.

## Overview

Git configuration optimized for productivity with short aliases, Neovim as merge tool, and GitHub CLI credential integration.

## Files

| File | Purpose |
|------|---------|
| `.gitconfig` | Main git configuration |
| `.gitignore_global` | Global ignore patterns |

## Dependencies

- **git** - Version control
- **neovim** - Merge tool
- **gh** (GitHub CLI) - Credential helper
- **git-lfs** - Large file support

## Aliases

| Alias | Command |
|-------|---------|
| `c` | checkout |
| `d` | branch -d |
| `s` | status |
| `f` | fetch -p |
| `p` | push |
| `cma` | commit -am |
| `bla` | branch -la |
| `loggone` | log --oneline |
| `cb` | checkout -b |
| `main` | checkout main |
| `mm` | merge main |

## Features

### Merge Tool

Uses Neovim with `Gdiffsplit!` for conflict resolution:

```bash
git mergetool
```

### Credential Helper

GitHub credentials managed via `gh auth git-credential`:

```bash
gh auth login
```

### Commit Signing

GPG signing enabled by default. Configure your GPG key:

```bash
git config --global user.signingkey YOUR_KEY_ID
```

## Customization

### User Info

Edit the `[user]` section:

```
[user]
    name = Your Name
    email = your@email.com
```

### Additional Aliases

Add to the `[alias]` section in `.gitconfig`.

## Symlink

```bash
ln -s ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/git/.gitignore_global ~/.gitignore_global
```
