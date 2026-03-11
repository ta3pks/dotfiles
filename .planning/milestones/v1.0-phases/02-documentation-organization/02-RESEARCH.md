# Phase 2: Documentation & Organization - Research

**Phase:** 02 - documentation-organization
**Confidence:** HIGH
**Gathered:** 2026-03-11

## Standard Stack

| Category | Choice | Version | Why |
|----------|-------|---------|-----|
| TUI Library | whiptail (primary), gum (optional) | 0.52.x (whiptail), 0.17.0+ (gum) | whiptail is Debian standard, always available. gum provides better UX but optional enhancement. |
| ADR Format | Nygard | 2011 | Simple 5-section format (Context/Decision/Status/Consequences). Proven since 2011. |
| README Structure | Standard sections | - | Quick Start, Prerequisites, Key Components, Installation, Structure, Secrets Management, Contributing. Matches user decisions from CONTEXT.md. |
| Per-tool README | Light template | - | Overview, Files, Dependencies, Customization. 4 sections, easy to maintain consistency. |

## Architecture Patterns

### Recommended README Structure
```markdown
# Dotfiles

[1-2 sentence description]

## Quick Start
git clone ... && ./install

## Prerequisites
[Bulleted list with version requirements]

## Key Components
[Table: Component | Location | Description]

## Installation
[Interactive script details, --dry-run, --undo flags]

## Structure
[Directory tree with one-liners]

## Secrets Management
[Already exists - keep current content]

## Contributing
[Brief guidelines]
```

### Per-tool README Template
```markdown
# [Tool Name]

[Brief one-liner description]

## Overview
[What this tool does, why it's configured this way]

## Files
| File | Purpose |
|------|---------|
| `.config/[tool]/...` | [description] |

## Dependencies
[Bulleted list of required packages]

## Customization
[How to modify for personal use]
```

### ADR Format (Nygard - Recommended)
```markdown
# ADR-NNN: [Short Title]

**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-xxx

## Context
[Describe forces at play - technical, political, social, project-specific. Value-neutral facts.]

## Decision
[State the decision in active voice. "We will..." - full sentences, paragraphs, not bullet fragments]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-xxx]

## Consequences
[Describe resulting context. Include positive, negative, and neutral effects.]
```

**Key principle:** Write each ADR as a conversation with a future developer. One ADR = one significant decision. Keep to 1-2 pages.

### Symlink Mapping Documentation Pattern
Source: XDG Base Directory Specification v0.8 (freedesktop.org)

**XDG Environment Variables (with defaults):**
```bash
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"    # User configs
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"   # User data
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}" # State (history, logs)
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"       # Cache
XDG_RUNTIME_DIR                                       # Runtime files (sockets, pipes)
```

**Critical:** All XDG paths must be absolute. If relative, treat as invalid.

**Example mapping table:**
```markdown
## Symlink Strategy

Configs are symlinked from `~/dotfiles/<tool>/` into XDG locations.

| Source | Destination | Notes |
|--------|-------------|-------|
| `nvim/.config/nvim/` | `$XDG_CONFIG_HOME/nvim/` | LazyVim config |
| `zsh/.zshrc` | `~/.zshrc` | Shell config |
| `sway/.config/sway/` | `$XDG_CONFIG_HOME/sway/` | Wayland compositor |
```

[Explain XDG compliance, why manual symlinks over stow]

## Common Pitfalls

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Over-documenting obvious things | Don't explain what `git clone` does | Keep it brief | Users know git |
| Stale screenshots | Avoid images that become outdated | Use text diagrams | Text is easier to update |
| Assuming reader memory | Document WHY decisions were made, not just WHAT | Context matters more | Future reader needs rationale |
| Inconsistent formatting | Different structure per README | Use template consistently | Easier to maintain |

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Interactive TUI | Custom bash menu from scratch | whiptail or gum | Standard tools, well-tested |
| ADR storage | Complex database or wiki | Simple markdown files | Easy to read, edit, version control |
| Per-tool docs | Single massive README | Per-tool README files | Documentation lives with code |

## Open Questions

1. ADR numbering - recommend sequential 3-digit (001, 002...)
2. Philosophy doc content - recommend brief: why manual symlinks, XDG preference, tool selection criteria
3. CHANGELOG format - recommend keepachangelog.com format

## Ready for Planning

Research complete. Planner can now create PLAN.md files.
