# Phase 2: Documentation & Organization - Research

**Researched:** 2026-03-11
**Domain:** Documentation, repository organization, symlink management, TUI/CLI tooling
**Confidence:** HIGH

## Summary

This phase focuses on making the dotfiles repository self-documenting and well-organized so users (primarily "future you") can understand, navigate, and verify the structure. The repository currently has 30+ tool directories following XDG-compliant patterns with `.config/<tool>/` subdirectories. Research covers TUI libraries for the interactive install script, ADR formats for decision documentation, XDG specification compliance, and README best practices.

**Primary recommendation:** Use `gum` for the interactive install script (modern, well-maintained, 23k+ GitHub stars) and MADR-lite format for ADRs. Focus documentation on "future you" audience with technical, concise tone.

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions
- **README Structure:** Standard sections (Quick Start, Prerequisites, Key Components, Installation, Structure, Secrets Management, Contributing)
- **Quick Start:** One-liner only (`git clone && ./install`) — assumes user knows what they're doing
- **Per-tool READMEs:** Live in each tool's directory (e.g., `nvim/README.md`), main README links to them
- **Structure section:** Directory tree with brief one-liner per top-level directory
- **Installation Approach:** Interactive script with TUI/CLI menu to select what to link — no stow dependency
- **Script features:** Handle symlinks based on selections, prerequisites check with clear messages, per-file prompt for existing destinations (overwrite/skip/backup), `--dry-run` flag, `--undo` to restore backups
- **Doc Organization:** Per-tool READMEs in each directory, general docs in repo root
- **Per-tool template:** Overview, Files, Dependencies, Customization
- **Cross-cutting docs:** CHANGELOG.md, CLAUDE.md, ADRs, philosophy doc
- **ADR format:** Simple — `docs/decisions/NNN-title.md` — brief context, decision, consequences
- **Audience:** Future you — assume you'll forget everything, document thoroughly
- **Tone:** Technical, concise, assumes Linux familiarity, minimal hand-holding
- **Assumed knowledge:** Shell, symlinks, PATH, config files — explain tool-specific concepts only
- **Decision documentation:** Inline comments for small things, ADRs for architectural choices

### Claude's Discretion
- Exact TUI/CLI library for install script (whiptail, dialog, or custom bash)
- ADR numbering scheme
- Philosophy doc structure and content
- CHANGELOG format details

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| DOC-01 | README has clear installation instructions | Quick Start one-liner pattern, install script design with TUI |
| DOC-02 | README explains repository structure | Directory tree format, per-tool README template |
| DOC-03 | README documents prerequisites | Prerequisites section format, check script pattern |
| ORG-01 | Configs follow XDG `~/.config/<tool>/` convention | XDG spec reference, current repo structure analysis |
| ORG-02 | Per-tool directories maintained | Tool directory template, README template |
| ORG-03 | Symlink strategy documented | Symlink mapping documentation format |

</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `gum` | 0.17.0+ | TUI for install script | Modern, well-maintained, 23k+ stars, rich features (choose, confirm, input, spin) |
| `whiptail` | system | Fallback TUI | Already installed on system, no external dependency |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| MADR-lite | 4.0.0 simplified | ADR format | Architectural decisions needing context |
| Nygard ADR | 2011 format | Simple ADR | Quick decisions with minimal overhead |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `gum` | `whiptail` | whiptail is pre-installed but less feature-rich, no multi-select, older UI |
| `gum` | `dialog` | dialog not installed, requires additional dependency |
| MADR | Y-Statement | Y-Statement too terse for dotfiles context, MADR provides better structure |

**Installation:**
```bash
# gum (recommended)
brew install gum
# or
go install github.com/charmbracelet/gum@latest

# whiptail (usually pre-installed on Debian/Ubuntu)
apt install whiptail  # if needed
```

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

### Per-Tool README Template

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

### ADR Format (MADR-lite)

```markdown
# [NNN]. [Decision Title]

Date: YYYY-MM-DD

## Context
[Why this decision was needed]

## Decision
[What was decided]

## Consequences
[Impact of this decision]
```

### Symlink Mapping Documentation Pattern

```markdown
## Symlink Strategy

Configs are symlinked from `~/dotfiles/<tool>/` to XDG locations:

| Source | Destination | Notes |
|--------|-------------|-------|
| `nvim/.config/nvim/` | `~/.config/nvim/` | LazyVim config |
| `zsh/.zshrc` | `~/.zshrc` | Shell config |
| `sway/.config/sway/` | `~/.config/sway/` | Wayland compositor |

[Explain XDG compliance, why manual symlinks over stow]
```

### Pattern: Install Script with TUI

```bash
#!/usr/bin/env bash
# Source: gum examples + dotfiles best practices

set -euo pipefail

# Check gum availability, fallback to whiptail
if command -v gum &> /dev/null; then
    TOOLS=$(gum choose --no-limit --header "Select configs to install" \
        "nvim" "zsh" "sway" "git" "all")
else
    # Fallback to whiptail checklist
    TOOLS=$(whiptail --title "Dotfiles Installer" \
        --checklist "Select configs:" 20 60 10 \
        "nvim" "" ON \
        "zsh" "" ON \
        "sway" "" OFF \
        3>&1 1>&2 2>&3)
fi

# Process selections with gum spin for feedback
for tool in $TOOLS; do
    gum spin --spinner dot --title "Linking $tool..." -- link_tool "$tool"
done
```

### Anti-Patterns to Avoid
- **Over-documenting obvious things:** Don't explain what `git clone` does
- **Stale screenshots:** Avoid images that become outdated
- **Assuming reader memory:** Document WHY decisions were made, not just WHAT
- **Inconsistent formatting:** Use same structure across all per-tool READMEs

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Interactive menu | Custom bash select loop | `gum choose` or `whiptail --checklist` | Edge cases (multi-select, search, cancellation) |
| Spinner/progress | Custom animation | `gum spin` | Terminal compatibility, cleanup on exit |
| User confirmation | Custom read -p | `gum confirm` or `whiptail --yesno` | Exit codes, consistent UI |
| Backup management | Custom tar/zip | Simple timestamped copies | Easier `--undo` implementation |

**Key insight:** Shell scripting edge cases (signals, terminal resize, color support) make custom TUI components fragile. Use established tools.

## Common Pitfalls

### Pitfall 1: Symlink Destination Conflicts
**What goes wrong:** Existing configs at destination cause silent failures or data loss
**Why it happens:** Script assumes clean destination
**How to avoid:** Check destination exists, prompt per-file (overwrite/skip/backup)
**Warning signs:** `ln: failed to create symbolic link: File exists`

### Pitfall 2: Missing Prerequisite Detection
**What goes wrong:** Install succeeds but tools fail at runtime due to missing deps
**Why it happens:** Only checking for tool existence, not dependencies
**How to avoid:** Check for required packages (nvim needs git, zsh needs oh-my-zsh)
**Warning signs:** "command not found" after "successful" install

### Pitfall 3: Stale Documentation
**What goes wrong:** README describes old structure, new users get confused
**Why it happens:** Docs not updated when structure changes
**How to avoid:** Keep docs minimal, link to code (which is always current)
**Warning signs:** Documentation references non-existent files/directories

### Pitfall 4: Over-engineered Install Script
**What goes wrong:** Script becomes unmaintainable, hard to debug
**Why it happens:** Adding features without restraint
**How to avoid:** Keep script simple, focus on core use case (symlink creation)
**Warning signs:** Script exceeds 200 lines, multiple functions for same task

## Code Examples

### Gum Choose for Multi-Select

```bash
# Source: https://github.com/charmbracelet/gum
# Multi-select with limit
SELECTED=$(gum choose --no-limit --header "Select tools to install:" \
    "nvim" "zsh" "sway" "git" "kmonad" "espanso")

# Process each selection
for tool in $SELECTED; do
    echo "Installing $tool..."
done
```

### Symlink with Backup

```bash
# Source: dotfiles best practices
link_with_backup() {
    local src="$1" dest="$2"
    
    if [[ -e "$dest" ]]; then
        if gum confirm "Overwrite $dest?"; then
            backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
            mv "$dest" "$backup"
            echo "Backed up to $backup"
        else
            echo "Skipped $dest"
            return 1
        fi
    fi
    
    ln -sf "$src" "$dest"
}
```

### Prerequisite Check

```bash
# Source: dotfiles best practices
check_prerequisites() {
    local missing=()
    
    command -v git &>/dev/null || missing+=("git")
    command -v zsh &>/dev/null || missing+=("zsh")
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Missing prerequisites: ${missing[*]}"
        echo "Install with: sudo apt install ${missing[*]}"
        exit 1
    fi
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| whiptail/dialog TUI | gum (charmbracelet) | 2022+ | Better UX, modern look, more features |
| Manual symlink docs | Automated mapping generation | Ongoing | Docs stay in sync with reality |
| Full MADR template | MADR-lite for dotfiles | Context-dependent | Less overhead for personal projects |
| Static README | README + per-tool docs | Best practice | Scalability as repo grows |

**Deprecated/outdated:**
- GNU Stow: Project explicitly avoids it per REQUIREMENTS.md
- chezmoi/yadm: Migration not in scope

## Open Questions

1. **ADR numbering scheme**
   - What we know: Need `NNN-title.md` format
   - What's unclear: Sequential vs. categorical numbering
   - Recommendation: Simple sequential (001, 002, ...) — easier to maintain

2. **Philosophy doc content**
   - What we know: Should exist per decisions
   - What's unclear: Specific topics to cover
   - Recommendation: Brief doc covering: why manual symlinks, XDG preference, tool selection criteria

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | shellcheck + bats (bash testing) |
| Config file | None — see Wave 0 |
| Quick run command | `shellcheck install.sh` |
| Full suite command | `bats tests/` |
| Estimated runtime | ~5 seconds |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DOC-01 | README has installation instructions | manual | N/A | N/A |
| DOC-02 | README explains structure | manual | N/A | N/A |
| DOC-03 | README documents prerequisites | manual | N/A | N/A |
| ORG-01 | Configs follow XDG | unit | `bats tests/test_xdg.bats` | ❌ Wave 0 gap |
| ORG-02 | Per-tool directories exist | unit | `bats tests/test_structure.bats` | ❌ Wave 0 gap |
| ORG-03 | Symlink strategy documented | manual | N/A | N/A |

**Note:** Documentation requirements (DOC-*) are verified manually. Structure requirements (ORG-*) can have automated tests.

### Nyquist Sampling Rate
- **Minimum sample interval:** After each doc file created → verify with `cat` or `head`
- **Full suite trigger:** Before marking phase complete
- **Phase-complete gate:** Manual review of all README files
- **Estimated feedback latency per task:** ~2 seconds (file reads)

### Wave 0 Gaps (must be created before implementation)
- [ ] `tests/test_xdg.bats` — verifies ORG-01 (XDG compliance check)
- [ ] `tests/test_structure.bats` — verifies ORG-02 (per-tool directories)
- [ ] Framework install: `brew install shellcheck bats-core` — if not present

## Sources

### Primary (HIGH confidence)
- https://github.com/charmbracelet/gum - TUI library features, examples, installation
- https://adr.github.io/ - ADR format definitions, MADR template reference
- https://specifications.freedesktop.org/basedir-spec/latest/ - XDG Base Directory specification

### Secondary (MEDIUM confidence)
- Current repository structure analysis (30+ tool directories)
- Existing README.md content review
- whiptail availability check (confirmed installed)

### Tertiary (LOW confidence)
- None — all critical findings verified with primary sources

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - gum is well-documented, actively maintained, widely adopted
- Architecture: HIGH - README/ADR patterns are established best practices
- Pitfalls: HIGH - based on common shell scripting and dotfiles management experience

**Research date:** 2026-03-11
**Valid until:** 2026-04-11 (30 days - stable domain)
