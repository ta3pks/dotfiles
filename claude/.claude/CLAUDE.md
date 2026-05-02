## Communication Style

**Emojis OK in conversation; skip in code, comments, commit messages, and code files.**

## Git Commits

**Never include `Co-Authored-By` lines in commit messages.**

## Package Manager

**Always use `bun` instead of `npm`/`npx`/`pnpm`.** (`bun install`, `bun add`, `bun run`, `bunx`, `bun install -g`.)

## Task Management

**Create todos upfront for non-trivial tasks via TodoWrite/TaskCreate.** Update status as work progresses.

## Parallel Execution

**Use `TeamCreate` (tmux teammates) for 2+ independent tasks; never the `parallel` or `dispatching-parallel-agents` skills.** Define work via `TaskCreate`, serialize only true dependencies.

## Subagent Model

**All subagents use Opus.** Either omit `model` (inherits Opus) or set `model: "opus"`. Never haiku/sonnet, regardless of task complexity.

## Container Runtime

**Use `podman`/`podman-compose` instead of `docker`/`docker-compose`.** Testcontainers: `DOCKER_HOST=unix:///run/user/1000/podman/podman.sock`.

## Sentry Triage Drill

When the operator asks about Sentry / production errors / "what's left", run this drill:

**1. Enumerate.** `mcp__Sentry__find_organizations` → `find_projects` → `search_issues query="is:unresolved environment:production" sort="freq"` (limit 30). Use `sort=freq` for top burners; `sort=date` for fresh-since-deploy. Cross-reference each issue's `release` tag against the current prod version (in this repo, `backend/Cargo.toml` `version`) — issues firing on the latest release post-deploy are the highest priority; older releases mean the bug may already be fixed and just hasn't aged out.

**2. Triage by category.** For each top-volume / fresh issue, fetch detail with `get_sentry_resource resourceType=issue resourceId=<KEY>`. Classify into:
- **NEW post-deploy** — release tag matches current prod, fired after last deploy. Treat as P0 unless clearly cosmetic.
- **High-volume code bug** — recurring, traces to a real defect (schema drift, type mismatch, time-window violation, etc.). Worth fixing in batch.
- **Logging noise** — business-rule violations (`limit_exceeded`, `kyc_blocked`) being logged at `error!` level. Demote to `warn!`/`info!` and add a classifier helper to keep the demotion declarative. Don't just suppress.
- **Provider response decode** — third-party API returning malformed JSON. Capture full response body in the error log before "fixing" — treat as observability fix until you can prove it's a code bug vs. provider drift.
- **Stale** — no events in 14+ days. Deprioritize; resolve when convenient.

**3. Recommend a fix order to the operator.** Present a numbered list with one-line diagnosis per issue. Ask which to do; never assume the whole list.

**4. Fix.** Standard worktree-per-issue + 4-phase BMAD chain when the operator approves a batch. File-disjoint Sentry fixes are textbook parallel work (different domains, no shared state). **Commit message MUST include `Fixes <ISSUE-KEY>`** so Sentry's GitHub integration auto-closes when the commit lands on the deployed branch.

**5. Mark resolved on Sentry — explicitly.** After the merge ships, call `mcp__Sentry__update_issue organizationSlug=<org> issueId=<KEY> status=resolved` for each fixed issue. Don't rely solely on commit-message auto-close — Sentry's GitHub integration is not always wired and silently fails when it's not. The explicit API call is the only guaranteed path. Operator should not have to remind you to mark resolved — bake it into the close ceremony for any Sentry-driven sprint.

**6. Don't auto-resolve provider-side noise.** When you skip a Sentry issue (operator decision, deferred investigation, third-party root cause), leave it unresolved. Don't `ignore` it without operator sign-off — ignoring buries signal that the operator may want to see if volume escalates.

## TDD & BMAD Story Workflow

**Always use TDD.** Write tests first, then implement.

**BMAD stories use tmux teams.** Every story dispatch runs the **full 4-phase chain**: `/bmad-create-story` → `/bmad-dev-story` → `/bmad-code-review` → `/simplify`. One teammate per story, cleanup between stories. The 4-phase chain is **non-negotiable** — see "Mandatory ceremony floor" below.

**Parallel is the default, not sequential.** When stories/tasks are mechanically independent — file-disjoint, no shared state, no order dependency, no quality regression risk — dispatch them in parallel. Don't ask, dispatch. Sequential is the exception, used only when:

- Stories share files (forces sequential per file-overlap rule)
- One story's output is the next's input (true dep)
- Pre-work surprises need one-failure-isolation visibility (rare; per-feature override available)
- Candidate count exceeds reasonable visibility (>4-5 simultaneous lanes)

Use the worktree-isolation lane pattern for parallel git-tree work. Run a file-conflict matrix + dep-graph check at every dispatch decision; dispatch all safely-parallel candidates in one message. The "ask before parallel" gate applies only when there's genuine doubt about independence — it's no longer a default-deny gate.

**Manager handles worktree lifecycle (Agent `isolation: "worktree"` is flaky under load).** Don't pass that param — manage explicitly:
1. **Setup:** `git worktree add .claude/worktrees/<lane> -b <branch> origin/main` per lane. Verify with `git worktree list`.
2. **Per-teammate prompt:** lead with `Your worktree is .claude/worktrees/<lane>, branch <branch>. cd in before any git op. Never touch the parent worktree.`
3. **Teardown after merge:** `git worktree remove`, `git branch -D`, `git push origin --delete`. Manager also cleans `/tmp/<lane>-worktree` stubs left by teammates — operator never sees artifacts.

Teammate teardown order: SendMessage `shutdown_request` → wait for `shutdown_approved` ack → only then `TeamDelete`. Skipping the ack orphans processes; SIGKILL leaks them from the harness.

**Drive to plan completion.** Inside an approved plan, execute autonomously — spawn waves, monitor, handle blockers, commit, push per the exit gate. Story-internal decisions (file paths, branch names, commit wording, code-review iteration) are manager's call. Escalate ONLY for: scope expansion, new open questions, hard quality-gate failures without obvious fix, or operator-impactful side effects (force-push main, prod data delete, secret rotation).

**Mandatory ceremony floor (non-negotiable).** Every story runs `/bmad-create-story` → `/bmad-dev-story` → `/bmad-code-review` → `/simplify`. No carve-outs for size/scope/UI-only/docs/config. If `/simplify` finds nothing, the teammate records `simplify pass: no-op (reviewed X, all clean)` in the SendMessage summary — "skipped, probably nothing" is rejected.

## Progress Reporting Format

**Report progress after every significant action** (wave dispatched, story merged, retro authored, sprint closed, blocker hit, rule change, recovery action). Skip for trivial plumbing (single teammate idle, individual file edit).

Format — keep under 5 lines, bold sprint names + percentages:

```
📊 Progress after [latest action]:
- **{Sprint}**: {done}/{total} {short status} — **{N}% {emoji}**
- **Latest:** {one-line description of the action and any blocker/decision}
```

One bullet per active sprint (closed sprints don't appear). Emojis: ✅ 100%, 🚧 in-progress, ⚠️ blocked, 🎯 active focus.

## Workflow Close Housekeeping

**At every workflow close (sprint close / feature close / epic close), doc cleanup is part of the close ceremony — not an optional follow-up.** Bake it in. The standard sweep:

- Update the project's sprint-status / tracking yaml: flip retro entries from `backlog` → `done  # see {retro-file}.md` (pointer entries), refresh any `current_state` field to reflect actual close state, increment retrospective counters, append the `last_updated` comment trail.
- Verify with `git diff` that only the tracking yaml is in the diff (or scoped doc files for the close).
- Single closing chore commit. Title shape: `chore({feature}): flip retro entries to done pointers + refresh sprint-status state`.

If running a status check (e.g. `/bmad-sprint-status`) and you see `backlog` retro entries on epics whose retros exist on disk, that's lag — flip immediately, don't wait for explicit operator request.

## Git Branch Workflow

- **`dev` is the default working branch** - Always use `dev` as the goto branch
- **Never touch main unless specifically instructed** - Main is release-only
- **Squash merge dev to main** - When merging dev to main, always use squash merge

@RTK.md
@SOUL.md
