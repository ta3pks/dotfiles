# 001. Manual Symlinks over GNU Stow

Date: 2026-03-11

## Context

This dotfiles repository needs a strategy for linking configuration files from the repository to their expected locations in the home directory. Common approaches include:
- GNU Stow (automatic symlink management)
- chezmoi (templated dotfiles manager)
- yadm (yet another dotfiles manager)
- Manual symlinks (explicit `ln -s` commands)

The repository already uses manual symlinks and has 30+ tool directories.

## Decision

We will use **manual symlinks** with an interactive install script, not GNU Stow or other dotfiles managers.

## Consequences

**Positive:**
- Full control over what gets linked and where
- No external dependency (stow, chezmoi, etc.)
- Explicit and transparent - easy to understand what's happening
- Works on any Unix system without additional packages
- Easy to handle edge cases (different destinations, conditional linking)

**Negative:**
- More initial setup compared to `stow */`
- Install script needs to be maintained
- No built-in templating for machine-specific configs

**Neutral:**
- XDG Base Directory compliance is maintained through consistent destination paths
