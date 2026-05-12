---
name: team-orchestration
description: Manager-and-teammates workflow for parallel story execution via tmux teammates and git worktrees. Use when dispatching 2+ file-disjoint stories, running BMAD chains in parallel, or any time you want to keep manager context clean by delegating scoped work to teammates. Includes mandatory cleanup ceremony and orphan-handling guards.
version: 1.0
---

# Team Orchestration — Manager + Tmux Teammates + Worktrees

The manager pattern: you (the orchestrator) keep context light by delegating scoped, file-disjoint work to tmux-teammate processes running their own Claude sessions in their own git worktrees. Teammates do the heavy lifting (read code, write code, run tests, ceremony). You receive concise SendMessage reports back, merge, and clean up.

## When to Use

- **2+ stories that are file-disjoint** — different directories, no shared state, no order dependency. Parallel default per `~/.claude/CLAUDE.md`.
- **Long-running per-story work** (>10 min each) where keeping it in your own session would burn cache and pollute context.
- **BMAD 4-phase chains** (`create-story` → `dev-story` → `code-review` → `simplify`) — exactly the right granularity for one teammate per story.
- **You want a clean main context** — research/decisions stay with you; mechanical implementation goes to teammates.

## When NOT to Use

- Single story or single short task → run inline, don't spin a team.
- Stories that share files (real file overlap, not just same epic) → serialize, don't parallelize.
- Pure research / read-only exploration → use `Explore` subagent, not a teammate.
- Operator hasn't decided scope yet → finish planning with operator first; teammates need a frozen spec.

## Pre-Dispatch Checklist

Before calling TeamCreate, prove this is genuinely parallel work:

1. **File-conflict matrix.** List every file each story will touch. If two stories overlap on the same file → serialize them (or merge into one story). Zero overlap = parallel-safe.
2. **Dependency graph.** If story B needs story A's output (new function, schema, etc.), B is blocked until A merges. Note `addBlockedBy` on the task.
3. **Lane count cap.** More than 4-5 simultaneous lanes loses visibility — split into waves instead.
4. **Branch base.** All worktrees should base off the same clean commit (usually `origin/main` or the current `dev` HEAD). Verify with `git fetch && git log --oneline -3`.

## Worktree Setup (Manager)

Don't use `Agent({ isolation: "worktree" })` — flaky under load per operator's CLAUDE.md. Manage explicitly:

```bash
# Per lane (run sequentially or batched in one Bash call):
git worktree add .claude/worktrees/<lane> -b <branch-name> origin/main
# Verify all created cleanly:
git worktree list
```

Naming conventions:
- Lane name: short, kebab-case, story-themed (e.g., `rbac-graph`, `sidebar-fix`, `notes-delete`).
- Branch name: `<lane>-<short-desc>` or match the lane (e.g., `rbac-graph-fixes`).
- Worktree path: `.claude/worktrees/<lane>` (gitignored, under repo root).

## TeamCreate + TaskCreate

Order matters:

1. **TeamCreate** with a descriptive `team_name` (e.g., `rbac-audit-sprint`). This creates the team + task list directories.
2. **TaskCreate** one task per story. Subject = imperative ("Fix RBAC permission graph"). Description = enough detail that a teammate working blind can execute (acceptance criteria, files to touch, branch name, worktree path).
3. **Add dependencies** via `TaskUpdate addBlockedBy` for any sequential pairs.
4. **Spawn teammates** via the `Agent` tool with `team_name`, `name`, and a self-contained prompt (see template below). Use `subagent_type: claude` (full-capability) for implementation; `Explore` for read-only research lanes.

## Per-Teammate Prompt Template

The teammate has zero conversation context. The prompt must be self-contained — paste any context they need (file paths, line numbers, acceptance criteria, branch+worktree location).

```
You are <name>, working as a tmux teammate on the <team_name> team.

## Your worktree (CRITICAL)
- Worktree path: .claude/worktrees/<lane>
- Branch: <branch-name>
- cd into the worktree before ANY git operation. NEVER touch the parent worktree.
- All file paths in this prompt are relative to the worktree root.

## Your story
<story title>

<full story description: what to build, why, acceptance criteria>

## Files in scope
- path/to/file1.rs  (lines X-Y are relevant)
- path/to/file2.ts
- path/to/file3.vue

## Out of scope (DO NOT touch)
- path/to/forbidden/*.rs  (owned by lane <other-lane>)

## Mandatory 4-phase chain (NON-NEGOTIABLE)

All four phases MUST run, in order, every time. There are no carve-outs for diff size, "obviously trivial", "no architectural decisions", or "small enough to review directly". If the diff is small enough to skip ceremony, ceremony is small enough to run.

1. `/bmad-create-story` → produces story spec in implementation_artifacts
2. `/bmad-dev-story` → implement + tests
3. `/bmad-code-review` → adversarial review, iterate until clean
4. **`/simplify` → MUST RUN. Review changed code for reuse/quality/efficiency. If nothing to apply, record `simplify pass: no-op (reviewed <files>, all clean)` with the exact files reviewed. "Skipped, probably nothing" is rejected.** Going idle without a simplify pass is a process violation that will be sent back for redo.

### Why simplify is enforced even for tiny diffs

Real-world examples where simplify caught material issues despite "obviously trivial" diffs:
- A 5-line composable change had a `useState` cache check ABOVE the permission gate — only surfaced during simplify-driven review of the patch shape
- A "one-line :disabled add" trapped read-only viewers with no exit because the Cancel button got the disable too
- Three sibling composables had the same antipattern as the patched one — simplify-pass audit found them all in one sweep

The simplify pass is the canary, not the polish.

## When done — gating checklist

Before sending the final SendMessage to manager, verify EACH:

- [ ] Phase 1 `/bmad-create-story` ran; story spec file exists at the recorded path
- [ ] Phase 2 `/bmad-dev-story` ran; tests for the changes pass (`cargo test --lib <module>` for backend; `pnpm typecheck && pnpm exec eslint <changed-files>` for admin_ui; Vitest for new composables)
- [ ] Phase 3 `/bmad-code-review` ran; iterations applied OR explicitly recorded as "1 pass, clean first try"
- [ ] Phase 4 `/simplify` ran; outcome is either applied changes OR `no-op (reviewed <files>, all clean)`
- [ ] Commit on your branch with a descriptive message
- [ ] `TaskUpdate` task → `completed`

ONLY THEN send the final SendMessage to manager with:
- Branch name + final commit SHA
- One-line summary of what shipped
- **simplify outcome (verbatim — `applied: <description>` OR `no-op (reviewed <files>, all clean)`)** — manager will reject the lane if this is missing
- Any blockers / followups / known limitations

Then go idle. Do NOT initiate shutdown — manager owns lifecycle.

### Common failure modes (don't fall into these)

- "The diff is tiny, I'll skip create-story and code-review and just commit." → Rejected. Run all four phases. Tiny diffs still need durable records.
- "Simplify found nothing — I'll skip the report line." → Rejected. Record `no-op (reviewed <files>, all clean)` explicitly so the manager can see the pass happened.
- "I'll mark task completed first, then think about simplify." → Wrong order. Simplify MUST land before TaskUpdate-completed and before the final SendMessage. If simplify surfaces changes, you'll be amending a "completed" task which is messy.

## Operator preferences
- English-only prose in messages back to manager.
- Use Serena MCP tools for code-aware ops (find_symbol, replace_symbol_body) over grep/Edit.
- Use bun, not npm/pnpm — EXCEPT for admin_ui which is locked to pnpm.
- Skip any --no-verify / --no-gpg-sign flags.
```

## Communication Patterns

- **Manager → teammate**: SendMessage with task assignments or clarifications. Always address by `name`, not UUID.
- **Teammate → manager**: SendMessage on milestones (story spec ready, dev done, review iteration, final done). Plain text, not structured JSON.
- **Manager → operator**: Concise updates per the Progress Reporting Format in CLAUDE.md.

Idle teammates are normal. Don't ping just because they're idle.

## Cleanup Ceremony (Mandatory Order)

Skipping this order orphans processes that SIGKILL won't fully reclaim from the harness.

### Per-teammate teardown (after their work is merged)

```
1. SendMessage(to: <name>, message: {type: "shutdown_request", reason: "<lane> merged, cleanup"})
2. Wait for shutdown_response with approve=true (auto-delivered)
3. Verify pane closed: tmux list-panes -s -t <session> -F '#{pane_id} #{pane_current_command}'
   (claude PID for that pane should be gone)
4. git worktree remove .claude/worktrees/<lane>
5. git branch -D <branch-name>  (locally — only if merged; verify with git branch --merged)
6. git push origin --delete <branch-name>  (remote — only if pushed AND merged)
```

### Whole-team teardown (after all lanes done)

```
1. Confirm all teammates have acknowledged shutdown_request
2. Confirm no active members in ~/.claude/teams/<team>/config.json
3. TeamDelete (no args — uses current team context)
4. ls -la .claude/worktrees/  → should be empty or only contain non-team worktrees
5. tmux list-sessions  → no leftover sessions from this team
```

`TeamDelete` will FAIL if any teammate is still active. That's by design — fix the orphan first.

## Orphan Detection & Safe Kill

If a teammate didn't ack shutdown, OR `TeamDelete` complains about active members, OR you find stray `claude --teammate-mode` processes — DO NOT immediately SIGKILL. Self-recognition first.

### Step 1: Enumerate all claude processes and tmux panes

```bash
# All claude processes with elapsed time
ps -eo pid,etime,user,args | grep -E 'claude( |$)' | grep -v grep

# All tmux panes with their PIDs and current command
tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_id} #{pane_pid} #{pane_current_command}'
```

### Step 2: Self-recognition (CRITICAL — never skip)

Before killing any `claude --teammate-mode` process, prove it isn't *you*. From [CLAUDE.md operator rule, origin 2026-05-02 incident]:

```bash
# Your own pane
echo "I am pane: $TMUX_PANE  pid: $$"

# Walk your process ancestry — your claude parent is in this chain
ps -o pid,ppid,args -p $$ -p $(ps -o ppid= -p $$) -p $(ps -o ppid= -p $(ps -o ppid= -p $$))
```

**Refuse to kill** any PID whose pane matches `$TMUX_PANE` or whose process tree contains your own ancestor `claude` PID. A `claude --teammate-mode` process with low ELAPSED time looks like a stale leftover but may be your current session immediately after a resume.

### Step 3: Confirm it's truly orphaned

A teammate is genuinely orphaned only if:
- Its team config (`~/.claude/teams/<team>/config.json`) lists it but the team has been ended OR
- Its session has had zero activity for >30 minutes AND no pending tasks AND no in-flight messages OR
- The operator has explicitly identified it as orphaned

### Step 4: Graceful → forceful

```bash
# Try graceful again first (sometimes a re-ping wakes it)
# (use SendMessage with shutdown_request; if no response in 60s → escalate)

# Targeted SIGTERM (NOT SIGKILL):
kill -TERM <orphan_pid>
sleep 5
# If still alive:
kill -KILL <orphan_pid>

# Worktree cleanup of orphan lane (manager-side):
git worktree remove --force .claude/worktrees/<lane>  # only if PID confirmed gone
rm -rf /tmp/<lane>-worktree  # stubs sometimes left in /tmp
```

`tmux kill-pane -t <pane_id>` kills the pane but doesn't always reap child processes — that's the orphan source. Always reap the PID before/alongside the pane.

### Common orphan sources

- Teammate hit a model error and crashed without sending `shutdown_response`.
- Pre-commit hook held a lock; teammate timed out waiting.
- Operator restarted tmux mid-session (panes survive, claude PIDs don't get clean exits).
- Skipping the `shutdown_request → shutdown_response` ack and going straight to `TeamDelete` (the documented anti-pattern).

## Known Claude Code Teammate-Mode Gotchas

- **`pane-base-index` non-zero breaks teammate messaging** — Claude Code assumes 0-based pane indexing for routing keys to teammate panes. If your tmux config sets `pane-base-index 1` or similar, teammate panes open but receive no instructions. ([anthropics/claude-code#23527](https://github.com/anthropics/claude-code/issues/23527))
- **iTerm2 + tmux -CC integration** can produce disconnected panes where teammates launch but never join the messaging bus. ([anthropics/claude-code#24292](https://github.com/anthropics/claude-code/issues/24292), [#24771](https://github.com/anthropics/claude-code/issues/24771))
- **`Agent({isolation: "worktree"})` flakes under load** — manage worktrees explicitly via Bash instead (per CLAUDE.md operator rule).

If teammates open panes but `SendMessage` silently fails, suspect one of these first.

## Mandatory Ceremony Floor (Per Story)

Inherited from `~/.claude/CLAUDE.md` — never carve out:

1. `/bmad-create-story` → story spec file
2. `/bmad-dev-story` → implementation + tests
3. `/bmad-code-review` → adversarial review with iterations until clean
4. `/simplify` → reuse/quality pass; if nothing to do, record "no-op (reviewed X, all clean)" — "skipped, probably nothing" is rejected

No carve-outs for size, scope, UI-only, docs, or config-only stories.

### Manager enforcement on simplify specifically

Teammates MUST run `/simplify` before considering themselves done. The final SendMessage report MUST include a simplify outcome line verbatim — either `applied: <description>` or `no-op (reviewed <files>, all clean)`. If the line is missing, send the lane back with explicit instructions to run the missing phase. This rule has been earned through experience: teammates who skip simplify because "the diff is small / obviously clean" miss real issues (cache-ordering antipatterns, cancel-button traps, sibling-composable leaks) that only surface during the deliberate quality pass. Don't accept "I reviewed it informally during dev-story" as a substitute.

## Progress Reporting Cadence

Per CLAUDE.md "Progress Reporting Format" — keep under 5 lines:

```
Progress after [latest action]:
- {Sprint}: {done}/{total} {short status} - {N}% [emoji]
- Latest: {one-line description}
```

Update after: wave dispatched, story merged, retro authored, sprint closed, blocker hit, rule change, recovery action. Skip for trivial plumbing.

## Quick Reference

| Action | Tool / Command |
| ------ | -------------- |
| Create team | `TeamCreate({team_name, description})` |
| Add task | `TaskCreate({subject, description})` |
| Add dependency | `TaskUpdate({taskId, addBlockedBy: [...]})` |
| Spawn teammate | `Agent({team_name, name, subagent_type, prompt})` |
| Send to teammate | `SendMessage({to: name, message, summary})` |
| Graceful shutdown | `SendMessage({to: name, message: {type: "shutdown_request"}})` |
| Delete team | `TeamDelete()` (after all members acked shutdown) |
| List panes | `tmux list-panes -a -F '#{pane_id} #{pane_pid} #{pane_current_command}'` |
| Own pane id | `echo $TMUX_PANE` |
| Worktree add | `git worktree add .claude/worktrees/<lane> -b <branch> origin/main` |
| Worktree remove | `git worktree remove .claude/worktrees/<lane>` |

## End-of-Sprint Housekeeping

Per CLAUDE.md "Workflow Close Housekeeping" — at sprint/feature/epic close, doc cleanup is part of the close ceremony, not optional:

- Update tracking yaml (`_bmad-output/implementation-artifacts/sprint-status-{feature}.yaml`): flip retro entries from `backlog` → `done  # see {retro-file}.md`, refresh `current_state`, increment `total_retrospectives_done`, append `last_updated` comment trail.
- Verify with `git diff` that only the tracking yaml + intended doc files are in the close commit.
- Single closing chore commit: `chore({feature}): flip retro entries to done pointers + refresh sprint-status state`.

## Sources

Web research informing the orphan-handling guidance:

- [tmux list-panes / pane_pid reference (man page)](https://man7.org/linux/man-pages/man1/tmux.1.html)
- [tmux-safekill plugin — recursive safe-kill of known long-running children](https://github.com/jlipps/tmux-safekill)
- [tmux feature request: kill-pane -d for dead panes only](https://github.com/tmux/tmux/issues/4782)
- [claude-code teammate-mode pane-base-index bug (#23527)](https://github.com/anthropics/claude-code/issues/23527)
- [claude-code teammate-mode iTerm2 disconnect (#24292)](https://github.com/anthropics/claude-code/issues/24292)
- [claude-code teammate-mode tmux messaging disconnect (#24771)](https://github.com/anthropics/claude-code/issues/24771)
- [Claude Code agent teams docs (registerTeamForSessionCleanup)](https://code.claude.com/docs/en/agent-teams)
