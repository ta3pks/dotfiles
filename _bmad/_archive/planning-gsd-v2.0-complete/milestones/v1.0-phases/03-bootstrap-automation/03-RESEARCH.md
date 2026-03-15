# Phase 3: Bootstrap Automation — Research

**Researcher:** gsd-phase-researcher
**Date:** 2026-03-11
**Phase Goal:** Users can set up their complete environment with a single command

---

## User Constraints

Copied verbatim from 03-CONTEXT.md `<decisions>`:

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

---

## Phase Requirements

### AUTO-01: Bootstrap script exists and runs without errors

**What this means:** A `bootstrap.sh` file at repo root that completes a full run (including tool selection, prerequisite checks, symlink creation, and summary) with exit code 0 on a properly configured system.

**Key considerations:**
- Must handle both interactive (whiptail menus) and non-interactive (CI) modes
- Non-interactive mode via flags (e.g., `--all`, `--essential`) for CI pipelines
- Exit codes: 0 success, 1 general error, 2 missing prerequisites

### AUTO-02: Bootstrap script creates all necessary symlinks

**What this means:** Every tool managed by this repo gets its config symlinked to the correct target location.

**Symlink patterns discovered (3 distinct types):**

1. **Directory-level** (`~/.config/<tool>` → `dotfiles/<tool>/.config/<tool>`):
   coc, espanso, flameshot, fusuma, gammastep, ghostty, hints, kanata, kilo, kitty, kmonad, mpv, nvim, opencode, rio, sketchybar, skhd, sway, waybar

2. **Home dotfiles** (file-level to `~/`):
   - `git/.gitconfig` → `~/.gitconfig`
   - `git/.gitignore_global` → `~/.gitignore_global`
   - `zsh/.zshrc` → `~/.zshrc`
   - `zsh/.bash_aliases` → `~/.bash_aliases`
   - `tmux/.tmux.conf` → `~/.tmux.conf`
   - `tmux/.tmux` → `~/.tmux` (directory symlink)
   - `aider/.aider.conf.yml` → `~/.aider.conf.yml`

3. **Nested targets** (file-level into existing dirs):
   - `local_bin/.local/bin/*` → `~/.local/bin/*`
   - `rust/.cargo/config.toml` → `~/.cargo/config.toml`
   - `systemd_user_files/.config/systemd/user/*` → `~/.config/systemd/user/*` (file-level, not directory — other services exist there)

**Special cases:**
- `keyd/default.conf` → `/etc/keyd/default.conf` (requires sudo — separate handling or skip)
- `etc/` directory contains system configs (`udev`, `X11`, `systemd`) — likely sudo-required, should be optional/separate
- `bg_images/`, `docs/`, `claude/` — no symlinks needed (repo-internal or special)

### AUTO-03: Bootstrap script is idempotent (safe to run multiple times)

**What this means:** Running bootstrap.sh N times produces the same result as running it once.

**Idempotency rules:**
- If symlink exists and points to correct target → skip (log as "already linked")
- If symlink exists but points to wrong target → treat as conflict
- If regular file/dir exists at target → apply conflict strategy (backup/overwrite/skip)
- If nothing exists at target → create symlink
- Parent directories created with `mkdir -p` before linking

---

## Technical Analysis

### prerequisites.json Structure

```json
{
  "tools": {
    "zsh": {
      "check": "command -v zsh",
      "description": "Z Shell"
    },
    "nvim": {
      "check": "command -v nvim",
      "description": "Neovim editor"
    },
    "jq": {
      "check": "command -v jq",
      "description": "JSON processor (required by bootstrap)"
    },
    "whiptail": {
      "check": "command -v whiptail",
      "description": "TUI dialog tool (required by bootstrap)"
    }
  }
}
```

Core prerequisites (always required): `jq`, `whiptail`
Per-tool prerequisites: only checked for selected tools

### Tool Categorization (Essential vs Optional)

**Essential** (pre-selected in checklist):
- zsh, git, nvim, tmux, local_bin (core dev environment)

**Optional** (unchecked by default):
- All window manager configs (sway, yabai, skhd, sketchybar) — platform-specific
- Keyboard remapping (kmonad, kanata, keyd) — hardware-specific
- Terminal emulators (kitty, ghostty, rio) — user preference
- AI tools (opencode, aider, claude) — specialized
- Other (espanso, fusuma, gammastep, flameshot, coc, hints, kilo, mpv, waybar)
- System services (systemd_user_files) — requires running systemd
- Rust config — only if Rust toolchain installed

### Script Architecture

```
bootstrap.sh
├── Parse flags (--dry-run, --undo, --all, --essential, --help)
├── Check core prerequisites (jq, whiptail)
├── Load prerequisites.json
├── If --undo: reverse all symlinks, restore .bak files, exit
├── Show whiptail checklist (or use flag selections)
├── Prompt conflict strategy (overwrite/backup/skip)
├── Check per-tool prerequisites for selected tools
│   └── Missing? → list all missing, exit 1
├── For each selected tool:
│   ├── Determine symlink type (directory / home file / nested)
│   ├── Check existing state at target
│   ├── Apply conflict strategy if needed
│   ├── Create parent dirs (mkdir -p)
│   └── Create symlink (ln -sf or ln -snf for dirs)
├── Print summary (linked, skipped, backed up, errors)
└── Verify all symlinks point to correct targets
```

### Undo Implementation

The `--undo` flag needs to:
1. Find all symlinks pointing into the dotfiles repo
2. Remove those symlinks
3. Find all `.bak` files at target locations and restore them (rename `.bak` → original)
4. Report what was restored vs removed

Approach: maintain a manifest of created symlinks (e.g., `.bootstrap-manifest` in repo) written during install, read during undo. Alternatively, scan for symlinks pointing to repo — simpler but slower.

**Recommendation:** Write a `.bootstrap-manifest` file during install listing every symlink created. Undo reads this manifest. This is more reliable than scanning.

### Non-Interactive Mode

For CI pipelines:
- `--all`: Select all tools
- `--essential`: Select essential tools only
- `--conflict=overwrite|backup|skip`: Set conflict strategy without prompt
- When none of these flags are set and no TTY → error with usage message

### Whiptail Dialog Flow

1. **Welcome** → msgbox with brief description
2. **Tool Selection** → checklist with essential pre-selected
3. **Conflict Strategy** → radiolist (overwrite/backup/skip) — only shown if conflicts detected during dry-run scan
4. **Confirmation** → yesno showing what will be done
5. **Execution** → progress output to terminal
6. **Summary** → msgbox with results

### Edge Cases

- Symlink target inside repo doesn't exist (deleted tool) → warn and skip
- Target parent dir doesn't exist → `mkdir -p`
- Bootstrap run from wrong directory → detect via `SCRIPT_DIR` and `cd` appropriately
- Repo path contains spaces → quote all paths
- Sudo-required links (keyd, etc/) → skip with message "run with sudo for system configs" or separate `--system` flag

---

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Overwriting user customizations | High | Global conflict choice; `.bak` before overwrite |
| Breaking existing symlinks on re-run | Medium | Idempotency check — skip correct symlinks |
| prerequisites.json out of sync with tools | Medium | Validation at script start; warn on unknown tools |
| whiptail not available (minimal system) | Low | Fall back to basic `select` menu or require whiptail |
| Undo misses some symlinks | Medium | Manifest-based tracking; verify during undo |

---

## Validation Architecture (Nyquist)

### Requirement Coverage Matrix

| Requirement | Test Type | Validation Method |
|-------------|-----------|-------------------|
| AUTO-01 | Integration | Run `bootstrap.sh --essential --conflict=overwrite` in container; assert exit 0 |
| AUTO-01 | Unit | Test prerequisite checking with mock missing tools |
| AUTO-01 | Negative | Run with missing jq/whiptail; assert exit ≠ 0 with error message |
| AUTO-02 | Integration | After bootstrap, verify every expected symlink exists and resolves correctly |
| AUTO-02 | Unit | Test each symlink type (directory, home file, nested) individually |
| AUTO-02 | Edge case | Test with pre-existing files at target locations |
| AUTO-03 | Integration | Run bootstrap twice; diff filesystem state — must be identical |
| AUTO-03 | Unit | Test skip logic for existing correct symlinks |
| AUTO-03 | Edge case | Run bootstrap, modify a symlink target, run again — should detect and handle |

### Test Strategy

**Primary approach:** Shell-based test script (`test_bootstrap.sh`) that:
1. Creates a temporary HOME directory (`mktemp -d`)
2. Runs bootstrap with `--essential --conflict=overwrite` against temp HOME
3. Verifies symlinks via `readlink` checks
4. Runs bootstrap again — verifies idempotency (no changes, same result)
5. Runs `--undo` — verifies symlinks removed, backups restored
6. Cleans up temp directory

**Why shell tests:** The bootstrap script is bash — testing in bash keeps it simple, no extra dependencies. A `test_bootstrap.sh` script can run in CI without additional tooling.

### Observability

- Bootstrap logs all actions to stdout (linked, skipped, backed up, errored)
- `--dry-run` output can be diffed against actual run output
- Exit codes enable CI pipeline integration
- `.bootstrap-manifest` provides audit trail of what was linked

---

## Implementation Approach

### Recommended Plan Breakdown

**Plan 1: Core bootstrap script + prerequisites.json**
- `bootstrap.sh` with flag parsing, prerequisite checks, whiptail menus
- `prerequisites.json` manifest
- Symlink creation for all 3 types (directory, home, nested)
- Conflict handling (backup/overwrite/skip)
- Summary + verification output
- Non-interactive mode flags

**Plan 2: Undo, dry-run, and idempotency hardening**
- `--undo` with manifest-based restoration
- `--dry-run` detailed preview
- Idempotency edge case handling
- `.bootstrap-manifest` write/read

**Plan 3: Testing and validation**
- `test_bootstrap.sh` covering AUTO-01, AUTO-02, AUTO-03
- Test in temp directory (no system modification)
- CI-compatible exit codes
- Edge case coverage (conflicts, re-runs, undo)

### Dependencies

- Phase 2 should be complete (README documents installation including bootstrap)
- `jq` must be available (already installed: jq-1.8.1)
- `whiptail` must be available (already installed: 0.52.25)

---

## RESEARCH COMPLETE

All three requirements (AUTO-01, AUTO-02, AUTO-03) are well-defined with clear implementation paths. The symlink mapping is fully documented from the live filesystem. User constraints from the discussion phase are specific and actionable. No external research needed — this is a standard shell scripting task with well-known patterns.
