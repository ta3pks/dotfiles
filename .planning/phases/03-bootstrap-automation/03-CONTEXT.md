# Phase 3: Bootstrap Automation - Context

**Gathered:** 2026-03-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Interactive CLI script that sets up the complete dotfiles environment via symlinks. Users select which tools to install, prerequisites are verified, and existing file conflicts are handled gracefully. The script supports dry-run preview and undo capability.

</domain>

<decisions>
## Implementation Decisions

### TUI Library
- Primary: whiptail only (no gum dependency)
- Menu style: Checklist for tool selection, radiolist for config options
- Layout: Priority-based — essential tools first, optional tools last
- Defaults: Essential tools pre-selected, optional tools unchecked

### Conflict Handling
- Strategy: Global choice at start (overwrite/backup/skip) — applies to all files
- Backup naming: Simple suffix (`filename.bak`)
- Skip behavior: Log skipped files and continue
- Overwrite behavior: Create `.bak` first, then symlink

### Script Features
- `--dry-run`: Detailed preview showing source → dest mappings and conflicts
- `--undo`: Full undo — remove symlinks, restore all `.bak` files
- Logging: Normal level — errors, warnings, key actions (file linked, backup created)
- Idempotency: Skip existing correct symlinks (safe to re-run)

### Prerequisite Flow
- Missing prerequisites: Stop immediately with error listing all missing
- Definition: Central `prerequisites.json` manifest at repo root
- Format: JSON (works with `jq`)
- Post-install: Print summary + verify each symlink points to correct target

### Claude's Discretion
- Exact tool categorization (essential vs optional)
- Whiptail dialog text and formatting
- Error message wording
- Summary output format

</decisions>

<specifics>
## Specific Ideas

- Script should feel like a standard Linux installer — familiar patterns, clear feedback
- Works in CI pipelines (exit codes, non-interactive mode via flags)
- Safe to run multiple times without side effects

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 03-bootstrap-automation*
*Context gathered: 2026-03-11*
