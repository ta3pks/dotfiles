# Dotfiles Repository

## What This Is

A personal Linux development environment configuration repository. Manages shell, editor, window manager, terminal emulator, and AI-powered development tools without using GNU stow. Files are organized by tool and linked manually to The repository is includes configuration files for shell, editors, window managers, terminal emulators, and AI-powered development tools.

## Core Value

Users (including my future self and can quickly understand, maintain, and replicate my setup without breaking stow symlinks.

## Requirements

### Validated

- ✓ Shell environment (zsh with Oh My Zsh, bashrc.sh) — existing
- ✓ Editor (Neovim - LazyVim-based configuration — existing
- ✓ Window management (Sway, Yabai, — existing
- ✓ Input & keyboard (kmonad, kanata, espanso) — existing
- ✓ Text expansion (espanso) — existing
- ✓ System services (systemd_user_files/) — existing

### Active

- [ ] Document existing tools and configs systematically
- [ ] Create reference docs for how things work
- [ ] Maintain stow-compatible folder structure

### Out of Scope

- Mobile app — web-first, mobile later
- GNU stow or alternative — stow is the strict requirement, must be preserved

## Context

Existing codebase with 47 directories, 47 entries. Uses git submodules for external themes (kitty themes, TPM). Heavy integration with AI tools (OpenCode, Aider, Ollama local models. Key technologies: Lua (Neovim),  Rust, Shell (zsh/bash), Python scripts.

## Constraints

- **Structure**: Must maintain stow-compatible hierarchy — Changing folder locations breaks stow symlinks
- **Compatibility**: Keep existing configs working — don't break user workflows
- **Documentation**: Keep docs accurate and current tool versions change

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| LazyVim for Neovim | June 2025 migration | ✓ Good |
| Micode framework for OpenCode | September 2025 | — Pending |

---
*Last updated: 2026-03-07 after initialization*
