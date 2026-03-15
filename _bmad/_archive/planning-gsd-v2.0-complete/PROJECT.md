# Dotfiles Repository

## What This Is

A personal Linux development environment configuration repository with automated bootstrap, comprehensive documentation, security hardening, and AI memory management. Manages shell, editor, window manager, terminal emulator, and AI-powered development tools using manual symlinks (no GNU stow).

## Core Value

Users can quickly understand, maintain, and replicate the setup without breaking symlinks.

## Current Milestone: v2.0 Memory System

**Goal:** Build a CLI-independent persistent memory system for AI coding assistants using vector database storage.

**Target features:**
- Vector database for semantic memory storage
- Local Ollama embeddings for privacy
- Works with any AI tool (OpenCode, Claude Code, Aider, Cursor)
- Remembers code patterns, decisions, conversation context, cross-project knowledge

## Requirements

### Validated

- ✓ SEC-01: No hardcoded secrets in version control — v1.0
- ✓ SEC-02: .gitignore covers all secret patterns — v1.0
- ✓ SEC-03: Secret handling strategy documented — v1.0
- ✓ DOC-01: README has clear installation instructions — v1.0
- ✓ DOC-02: README explains repository structure — v1.0
- ✓ DOC-03: README documents prerequisites — v1.0
- ✓ AUTO-01: Bootstrap script runs without errors — v1.0
- ✓ AUTO-02: Bootstrap script creates all symlinks — v1.0
- ✓ AUTO-03: Bootstrap script is idempotent — v1.0
- ✓ ORG-01: Configs follow XDG convention — v1.0
- ✓ ORG-02: Per-tool directories maintained — v1.0
- ✓ ORG-03: Symlink strategy documented — v1.0

### Active

(To be defined for v2.0)

### Out of Scope

| Feature | Reason |
|---------|--------|
| GNU Stow | Project explicitly avoids it |
| chezmoi/yadm migration | Manual symlink approach is optimal |
| GUI configuration | Defeats CLI/automation purpose |
| Mobile app | Web-first, mobile later |
| Cloud-only storage | Privacy requires local-first approach |

## Context

**Shipped v1.0** with 109,761 LOC (shell, markdown, json, lua, rust).

**Tech stack:**
- Shell: bootstrap.sh, zsh, bash
- Editor: Neovim (LazyVim)
- AI: OpenCode (micode framework), Aider, Ollama
- Window: Sway (Wayland), Yabai (macOS)
- Input: kmonad, kanata, espanso

**Key artifacts:**
- `bootstrap.sh` — Interactive setup with --dry-run, --undo
- `prerequisites.json` — 27 tools with symlink mappings
- `test_bootstrap.sh` — 13 automated test cases

## Constraints

- **Structure**: Manual symlinks — Changing folder locations breaks links
- **Compatibility**: Keep existing configs working
- **Documentation**: Keep docs accurate as tools evolve
- **Privacy**: Local-first, no cloud API calls for sensitive data

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Manual symlinks over GNU stow | Explicit control, no magic | ✓ Good |
| LazyVim for Neovim | June 2025 migration | ✓ Good |
| Micode framework for OpenCode | September 2025 | ✓ Good |
| Manifest-driven bootstrap | Track all symlinks for undo | ✓ Good |
| ANSI-C quoting for colors | Fix escape sequence handling | ✓ Good |
| XDG ~/.config convention | Standard Linux location | ✓ Good |

---
*Last updated: 2026-03-12 after starting v2.0 milestone*
