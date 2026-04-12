---
name: ask-another-ai
description: Iterative debate between Claude Code and another AI CLI (Codex/Gemini/OpenCode). Context-compressed, convergence-aware, memory-backed. For architecture, security, concurrency decisions — not CRUD.
user_invocable: true
arguments:
  - name: topic
    description: The question or topic to discuss. If empty, auto-detect from current session context.
    required: false
  - name: mode
    description: "Role preset: security, performance, simplicity, devil, or default"
    required: false
  - name: model
    description: "Override model for the selected CLI (e.g. o3, o4-mini, gemini-3.1-pro-preview, openrouter/minimax/minimax-m2.7). If empty, uses CLI default."
    required: false
  - name: auto_rounds
    description: "Auto-debate mode: run N rounds without asking user between rounds. 0 = ask each time (default). 'auto' = run until convergence (max_rounds cap)."
    required: false
  - name: max_rounds
    description: "Maximum rounds before forced synthesis. Default: 7. Warns at round 5."
    required: false
---

# Ask Another AI — Iterative Cross-AI Debate

## PROTOCOL COMPLIANCE — READ THIS FIRST

**This skill defines a SPECIFIC protocol. You MUST follow it exactly. Do NOT improvise "simpler" alternatives.**

### NEVER do these:
- **NEVER use `run_in_background` Bash calls to run CLIs in parallel** — use Agent Team (Task tool with team_name) for "Ask all" mode
- **NEVER skip session ID capture** — Round 1 MUST save a session ID to `${AI_DIR}/session-id.txt` (parsed from JSONL output for all CLIs)
- **NEVER send full history in Round 2+** — use session resume (preferred) or context compression (fallback)
- **NEVER present raw CLI output to user** — always use the MANDATORY structured format (Agreement/Disagreement/Concession/Risks)
- **NEVER skip the Convergence Signal** — every round MUST end with green/yellow/red
- **NEVER combine multiple AI responses into one analysis without per-AI structured breakdown**
- **NEVER run CLIs without writing prompt to file first** — Codex/Gemini use `$(cat prompt.txt)`, OpenCode uses `-f prompt.txt`
- **NEVER skip saving files** — every round's prompt, response, analysis MUST be saved to session dir
- **NEVER overwrite previous round's live-output** — use `live-output.round-{N}.txt` (immutable per round)
- **NEVER skip retry on transient failures** — rate limits, timeouts, and empty responses get up to 2 retries with backoff
- **NEVER exceed `max_rounds`** — force synthesis when cap reached (default: 7)

### ALWAYS do these:
- **ALWAYS create session directory** with `mkdir -p` before any CLI calls
- **ALWAYS write a session ID** to `session-id.txt` from Round 1 — parsed from JSONL output for all CLIs (falls back to `"auto-continue"` if unavailable)
- **ALWAYS use session resume** for Round 2+ (see "Round N" section)
- **ALWAYS use Agent Team** (TeamCreate + Task with team_name) for "Ask all" mode — NOT background bash. If team tools are unavailable, fall back to sequential single-AI runs (see "Ask all" fallback note)
- **ALWAYS present each AI's response with the MANDATORY structured format** before asking user
- **ALWAYS ask user** after each round: Continue / Enough / Change direction
- **ALWAYS save debate to `docs/debates/`** at the end
- **ALWAYS update `docs/debates/INDEX.md`** with debate metadata after saving
- **ALWAYS validate session ID** before attempting resume in Round 2+ (see Helper Functions)
- **ALWAYS check `PIPESTATUS[0]`** after piped CLI commands to detect silent failures

### Why this matters:
- Background bash loses session state — you can't resume conversations
- Without agent team, cross-pollination is impossible
- Without structured format, debates devolve into "they said this" summaries
- Without session IDs, Round 2+ requires expensive context compression
- The protocol exists because every shortcut was tried and failed

---

## Overview

Starts a controlled, multi-round debate between Claude Code and another AI CLI. Each round uses session-based continuation, Claude uses a mandatory structured response format, and convergence signals guide the user on when to stop. Final output is optionally written to memory as a decision record.

**This is not a toy.** This is a "let me think twice before making this decision" tool.

## When to Use

**Use for:**
- Architecture decisions with multiple valid approaches
- Security review — threat modeling, attack surface analysis
- Concurrency / race condition analysis
- Infrastructure trade-offs (performance vs cost vs complexity)
- PR-level deep review before merge

**Do NOT use for:**
- CRUD operations
- Naming discussions
- Simple refactors
- Anything with an obvious single answer

## Supported AI CLIs

| CLI | Provider | Default Model | Model Flag | Non-Interactive Command |
|-----|----------|---------------|------------|------------------------|
| **Codex** | OpenAI | `gpt-5.4` (xhigh reasoning) | `-m {model}` | `codex exec --full-auto -C {dir} "{prompt}" \| tee {file}` |
| **Gemini** | Google | `gemini-3.1-pro-preview` (high thinking) | `-m {model}` | `gemini -p "{prompt}" -o text --yolo > {file}` |
| **OpenCode** | Any via OpenRouter | `openrouter/minimax/minimax-m2.7` | `-m {model}` | `expect -c '...' -- opencode run -f {prompt_file} --format json -m "{model}" --dir {dir} "Answer" 2>&1 \| tee {file}` |

### "Ask all" Default Model Pool

When user selects "Ask all (parallel)", run ALL of these in parallel — each OpenCode model gets its own agent and model-slug directory:

| Participant | CLI | Model | Directory |
|-------------|-----|-------|-----------|
| Codex | `codex` (native) | gpt-5.4 | `codex/` |
| Gemini | `gemini` (native) | gemini-3.1-pro-preview | `gemini/` |
| MiniMax | `opencode` | `openrouter/minimax/minimax-m2.7` | `minimax-m2.7/` |
| Kimi | `opencode` | `openrouter/moonshotai/kimi-k2.5` | `kimi-k2.5/` |
| GLM | `opencode` | `openrouter/z-ai/glm-5v-turbo` | `glm-5/` |
| Qwen | `opencode` | `openrouter/qwen/qwen3.5-397b-a17b` | `qwen3.5-397b-a17b/` |
| MiMo | `opencode` | `openrouter/xiaomi/mimo-v2-pro` | `mimo-v2-pro/` |
**Total: 7 parallel agents** (2 native CLIs + 5 OpenCode instances with different models). Each OpenCode instance runs independently with its own session ID and directory — zero conflicts.

### CLI Notes

**Codex:**
- `codex exec` writes to stdout (NOT file) — use `tee` to capture
- `codex exec resume {SESSION_ID}` resumes a session — does NOT support `-o` flag, output goes to stdout only
- `--json` flag enables JSONL event stream: `thread.started` (has `thread_id` = session ID), `item.completed` (has response text), `turn.completed` (has token usage)
- Session ID: `jq -Rr 'fromjson? | select(.type == "thread.started") | .thread_id'` from JSONL output
- Response text: `jq -Rr 'fromjson? | select(.item.type == "agent_message") | .item.text'` from JSONL output
- Has full codebase access via `-C` working directory

**Gemini:**
- Default model: `gemini-3.1-pro-preview` with high thinking level (best quality for debates)
- Output via stdout redirect `> {file}` or `-o text` for text mode
- `-o stream-json` streams JSON events: `init` (has `session_id`), `message` (has `role` + `content`), `result` (has `stats`)
- Session ID: `jq -Rr 'fromjson? | select(.type == "init") | .session_id'` from stream-json output
- Response text: `jq -Rrj 'fromjson? | select(.role == "assistant") | .content'` from stream-json output (`-j` joins delta chunks)
- `--resume {session_id}` resumes a previous session
- `--yolo` enables auto-approve mode

**OpenCode:**
- Routes to ANY model via OpenRouter — default is `openrouter/minimax/minimax-m2.7`
- `opencode run` is non-interactive by default — no `--auto` or `--yolo` needed
- `--format json` outputs JSONL events: `step_start` (has `sessionID`), `text` (has `part.text`), `step_finish` (has cost + tokens)
- `--dir "{WORKING_DIR}"` — use the PROJECT directory so the model has full read-only codebase access. The project's `opencode.json` disables snapshots and write tools to prevent heavy git operations and file modifications
- **Read-only enforcement via `opencode.json`** — The project's `opencode.json` config denies `bash`, `write`, and `edit` permissions. This prevents the model from running shell commands, writing files, or modifying code. Combined with `"snapshot": false`, this eliminates all heavyweight operations and ensures models only use read tools (read, glob, grep)
- `-s {session_id}` resumes an explicit session (captured from `--format json` output)
- `-c` continues last session (alternative to `-s {id}` — less explicit but simpler)
- Session ID: `jq -Rr 'fromjson? | select(.type == "step_start") | .sessionID'` from JSONL output (format: `ses_*`)
- Response text: `jq -Rr 'fromjson? | select(.type == "text") | .part.text'` from JSONL output
- `-m {provider/model}` format — e.g. `-m "openrouter/minimax/minimax-m2.7"`
- **Prompt delivery:** `$(cat prompt.txt)` does NOT work for multiline prompts. Use `-f {prompt_file}` flag instead — write prompt to file, attach via `-f`, use a short message as trigger (e.g. "Analyze and respond to the attached prompt")
- `-f` flag MUST come before `--format` and other flags (position-sensitive): `opencode run -f {file} --format json ...`
- Has **read-only** codebase access via `--dir "{WORKING_DIR}"`. The model can read files, search code (grep), and match file patterns (glob) but CANNOT write, edit, or run bash — these are denied by the project's `opencode.json` permission config. The same config disables git snapshots to prevent 3GB+ snapshot overhead and parallel contention
- Available models: `opencode models {provider}` — supports openrouter, anthropic, google, deepseek, etc.
- Install: `curl -fsSL https://opencode.ai/install | bash`
- **CRITICAL PTY REQUIREMENT:** OpenCode uses the Bun runtime which buffers stdout/stderr indefinitely when not connected to a TTY. This means `opencode run ... | tee file` or `opencode run ... > file` will produce ZERO output. You MUST wrap OpenCode commands with `expect` to provide a PTY. Use this pattern:
  ```bash
  expect ~/.opencode/pty-wrapper.exp opencode run [args...] 2>&1 | tee file
  ```
- **REQUIRED: `opencode.json` in project root** — The project MUST have an `opencode.json` file with `"snapshot": false` and write/edit/bash denied. This file is already created in the Moon System project root. Without it, `--dir "{WORKING_DIR}"` will trigger heavy git snapshots on every AI step

### Session Directory (Parallel-Safe)

**CRITICAL:** Each debate session MUST create an isolated directory to prevent file conflicts when multiple debates run in parallel (e.g., "Ask all" mode or agent teams).

**Session directory structure:**

```
/tmp/ai-discussions/{session-id}/
├── context.md              # Shared session context (read-only after creation)
├── codex/                  # Codex-specific files
│   ├── prompt.txt          # Prompt sent to Codex
│   ├── live-output.round-1.txt  # Raw CLI stdout+stderr (immutable per round)
│   ├── session-id.txt      # CLI session ID for resume
│   ├── response.md         # Extracted clean text response
│   ├── round-1.md          # Round 1 response (permanent)
│   ├── round-2.md          # Round 2 response
│   └── ...
├── gemini/                 # Gemini-specific files
│   ├── prompt.txt
│   ├── response.md
│   ├── round-1.md
│   └── ...
├── {model-slug}/           # OpenCode model-specific files (e.g. minimax-m2.7/)
│   ├── prompt.txt
│   ├── response.md
│   ├── round-1.md
│   └── ...
├── claude/                 # Claude's responses (per-AI subdirs)
│   ├── codex-round-1.md
│   ├── gemini-round-1.md
│   ├── {model-slug}-round-1.md
│   └── ...
└── debate-state/           # Compressed debate states
    ├── codex-state-1.md
    ├── gemini-state-1.md
    ├── {model-slug}-state-1.md
    └── ...
```

**OpenCode model-slug convention:** Extract the last segment of the model path as the directory name. Examples:
- `openrouter/minimax/minimax-m2.7` → `minimax-m2.7`
- `openrouter/moonshotai/kimi-k2.5` → `kimi-k2.5`
- `openrouter/z-ai/glm-5v-turbo` → `glm-5`
- `openrouter/deepseek/deepseek-r1` → `deepseek-r1`

**Session ID generation:**

```bash
SESSION_ID=$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 4)
SESSION_DIR="/tmp/ai-discussions/${SESSION_ID}"
mkdir -p "${SESSION_DIR}"/{codex,gemini,claude,debate-state}
echo "Session: ${SESSION_DIR}"
```

For OpenCode, create the model-slug directory dynamically:
```bash
MODEL_SLUG=$(echo "${OPENCODE_MODEL}" | awk -F'/' '{print $NF}')
mkdir -p "${SESSION_DIR}/${MODEL_SLUG}"
```

**Variable convention** — All subsequent file references use these variables:

```bash
AI_NAME="gemini"  # or "codex" or the model-slug for OpenCode (e.g. "minimax-m2.7")
AI_DIR="${SESSION_DIR}/${AI_NAME}"
ROUND_N=1  # increment each round
PROMPT_FILE="${AI_DIR}/prompt.txt"
LIVE_OUTPUT="${AI_DIR}/live-output.round-${ROUND_N}.txt"  # immutable per round
RESPONSE_FILE="${AI_DIR}/response.md"
ROUND_FILE="${AI_DIR}/round-${ROUND_N}.md"
CLAUDE_FILE="${SESSION_DIR}/claude/${AI_NAME}-round-${ROUND_N}.md"
STATE_FILE="${SESSION_DIR}/debate-state/${AI_NAME}-state-${ROUND_N}.md"
CONTEXT_FILE="${SESSION_DIR}/context.md"
```

### Prompt Delivery

**CRITICAL:** For all CLIs, write the prompt to the AI-specific prompt file first. How the prompt is delivered differs by CLI:
- **Codex/Gemini:** Read via `$(cat "${AI_DIR}/prompt.txt")` in the CLI argument
- **OpenCode:** Use `-f "${AI_DIR}/prompt.txt"` flag — `$(cat ...)` does NOT work for multiline prompts in OpenCode

```bash
# Write prompt to AI-specific file
cat <<'PROMPT_EOF' > "${AI_DIR}/prompt.txt"
{full prompt content here}
PROMPT_EOF

# Then use in CLI command — each AI reads from its own file
# See Step 1c for the CANONICAL commands with session capture + live output
```

> **Note:** The canonical CLI commands with session ID capture, `tee`, and live monitoring are defined in **Step 1c** (Round 1) and **Step Nb** (Round 2+). The examples below are simplified — always refer to Step 1c/Nb for the actual commands to use.

### Helper Functions

These are REFERENCE implementations showing the extraction logic. The actual CLI scripts in Step 1c and team scripts INLINE this logic directly — do NOT call these as functions (they won't be defined in the bash session).

**`parse_session_id` — Unified session ID extraction (all CLIs):**

```bash
# Usage: parse_session_id <live-output-file> <cli-type>
# cli-type: codex | gemini | opencode
parse_session_id() {
  local file="$1" cli="$2" sid=""
  case "$cli" in
    codex)
      sid=$(jq -Rr 'fromjson? | select(.type == "thread.started") | .thread_id' "$file" 2>/dev/null | head -1)
      [ -z "$sid" ] && sid=$(grep -o '"thread_id":"[^"]*"' "$file" | head -1 | cut -d'"' -f4)
      ;;
    gemini)
      sid=$(jq -Rr 'fromjson? | select(.session_id) | .session_id' "$file" 2>/dev/null | head -1)
      [ -z "$sid" ] && sid=$(grep -o '"session_id": *"[^"]*"' "$file" | head -1 | cut -d'"' -f4)
      ;;
    opencode)
      sid=$(jq -Rr 'fromjson? | select(.type == "step_start") | .sessionID' "$file" 2>/dev/null | head -1)
      [ -z "$sid" ] && sid=$(grep -o '"sessionID":"[^"]*"' "$file" | head -1 | cut -d'"' -f4)
      ;;
  esac
  if [ -z "$sid" ]; then
    echo "auto-continue"
  else
    echo "$sid"
  fi
}
```

**`validate_session` — Check session ID is valid before resume:**

```bash
# Usage: validate_session <session-id-file> <cli-type>
# Returns 0 if valid, 1 if invalid (should fall back to compression)
validate_session() {
  local file="$1" cli="$2"
  [ ! -f "$file" ] && return 1
  local sid=$(cat "$file" 2>/dev/null)
  [ -z "$sid" ] && return 1
  [ "$sid" = "auto-continue" ] && return 1
  case "$cli" in
    codex)   [[ "$sid" =~ ^thread_ ]] || return 1 ;;
    gemini)  [ ${#sid} -gt 5 ] || return 1 ;;
    opencode) [[ "$sid" =~ ^ses_ ]] || return 1 ;;
  esac
  return 0
}
```

**`run_cli_with_retry` — Retry with backoff and error detection:**

```bash
# Usage: run_cli_with_retry <max_retries> <command...>
# Retries on: rate limit (429), timeout, empty output
# Exits with original exit code after max retries
run_cli_with_retry() {
  local max_retries="$1"; shift
  local attempt=0 rc=0
  local backoff_secs=(5 15 30)
  while [ $attempt -le $max_retries ]; do
    if [ $attempt -gt 0 ]; then
      local wait=${backoff_secs[$((attempt-1))]:-30}
      echo "RETRY $attempt/$max_retries — waiting ${wait}s..." >&2
      sleep $wait
    fi
    eval "$@"
    rc=${PIPESTATUS[0]:-$?}
    # Check for rate limit in output
    if grep -qi '429\|rate.limit\|too many requests\|quota.*exceeded' "${AI_DIR}/live-output.round-${ROUND_N}.txt" 2>/dev/null; then
      echo "RATE_LIMIT detected — will retry" >&2
      attempt=$((attempt + 1))
      continue
    fi
    # Check for empty output
    if [ ! -s "${AI_DIR}/live-output.round-${ROUND_N}.txt" ] && [ $rc -ne 0 ]; then
      echo "EMPTY_OUTPUT + non-zero exit — will retry" >&2
      attempt=$((attempt + 1))
      continue
    fi
    # Success or non-retryable error
    return $rc
  done
  return $rc
}
```

**`extract_response` — Unified response extraction (all CLIs):**

```bash
# Usage: extract_response <live-output-file> <response-file> <cli-type>
extract_response() {
  local live="$1" resp="$2" cli="$3"
  case "$cli" in
    codex)
      jq -Rr 'fromjson? | select(.item.type == "agent_message") | .item.text' "$live" 2>/dev/null > "$resp"
      ;;
    gemini)
      jq -Rrj 'fromjson? | select(.role == "assistant") | .content' "$live" 2>/dev/null > "$resp"
      ;;
    opencode)
      # Strip ANSI codes first, then extract with -j (join fragments)
      sed -r "s/\x1B\[[0-9;]*[mGKH]//g; s/\x1B\[?[0-9;]*[a-zA-Z]//g; s/\r//g" "$live" | jq -Rrj 'fromjson? | select(.type == "text") | .part.text' 2>/dev/null > "$resp"
      ;;
  esac
  if [ ! -s "$resp" ] || [ $(wc -c < "$resp") -lt 50 ]; then
    echo "WARNING: response.md is empty or too short — falling back to raw output" >&2
    grep -v '^{' "$live" 2>/dev/null | sed '/<think>/,/<\/think>/d' > "$resp"
    [ ! -s "$resp" ] && cp "$live" "$resp"
  fi
}
```

### Session-Based Conversation (Multi-Round)

**All CLIs support session continuation.** Instead of sending compressed debate state, Round 2+ continues the SAME conversation. The AI remembers all previous context natively.

> **Note:** The canonical commands with `tee`, live monitoring, and error handling are in **Step 1c** (Round 1) and **Step Nb** (Round 2+). This section documents the session ID mechanism per CLI.

**Session ID Capture (Round 1) — see Step 1c for full commands:**

| CLI | How session ID is captured | Stored in |
|-----|---------------------------|-----------|
| **Codex** | `jq` parse `.thread_id` from `--json` JSONL output | `session-id.txt` |
| **Gemini** | `jq` parse `.session_id` from `-o stream-json` output | `session-id.txt` |
| **OpenCode** | `jq` parse `.sessionID` from `--format json` output | `session-id.txt` |

**Session Resume (Round 2+) — see Step Nb for full commands:**

| CLI | Resume command |
|-----|---------------|
| **Codex** | `codex exec resume "${SESSION_ID}" --full-auto --json "$(cat prompt.txt)" \| tee ...` |
| **Gemini** | `gemini --resume "${SESSION_ID}" -p "$(cat prompt.txt)" -o stream-json --yolo \| tee ...` |
| **OpenCode** | `expect -c '...' -- opencode run -f prompt.txt --format json -m "{model}" --dir "{WORKING_DIR}" -s "${SESSION_ID}" "Respond" 2>&1 \| tee ...` |

**Advantages of session continuation:**
- AI remembers ALL previous rounds — no information loss from compression
- No need for Debate State summaries in Round 2+ prompts (AI already has full context)
- Round N prompts can be much shorter (just Claude's challenge, no history)
- Better argument quality — AI can reference its own earlier points without being told

**When to still use context compression (fallback):**
- If session resume fails (CLI updated, session expired, etc.)
- If debate goes 5+ rounds (some CLIs may degrade with very long contexts)
- If cross-pollination adds context from another AI (not in the original session)

### Timeout Handling

macOS does not have `timeout` by default. Do NOT use `timeout` in commands. Instead:
- Run CLI commands with Bash tool's built-in timeout parameter (set to 1200000ms / 20 minutes for all CLIs)
- The `pty-wrapper.exp` uses `set timeout -1` (no expect-level timeout) — the Bash tool timeout is the sole kill mechanism
- If a CLI hangs, the Bash tool timeout will kill it
- OpenRouter models (especially large reasoning models) can be silent for 5+ minutes during thinking — do NOT set expect timeouts

### Model Detection

Before the debate starts, detect which model will be used:

```bash
# Codex: read from config
grep '^model' ~/.codex/config.toml 2>/dev/null

# Gemini: default is gemini-3.1-pro-preview unless overridden

# OpenCode: default is openrouter/minimax/minimax-m2.7
# List available models: opencode models openrouter 2>/dev/null | head -20
```

If `{MODEL}` argument is provided, append `-m {MODEL}` to the CLI command.
If not provided, use the CLI's configured default.

**IMPORTANT:** Always report the model used in every round header:

```
## Round {N} — {AI_NAME} ({model_name})
```

And in the final synthesis metadata line.

## Language Rules

- **All user-facing output is English** — round presentations, questions, synthesis, convergence signals
- **AskUserQuestion options are English**
- **AI-to-AI communication (prompts) is English** — all CLIs perform better in English
- **Other AIs' responses may come back in any language** — Claude summarizes/presents in English

## Topic Resolution

If `{TOPIC}` argument is empty or not provided:
1. Analyze the current conversation context
2. Identify the most recent task, problem, or decision being worked on
3. Formulate a specific technical question from that context
4. Present: "Let me ask the current topic: **{auto-detected topic}**"
5. Proceed (user can redirect if wrong)

## Role Presets

The `{MODE}` argument adjusts the other AI's system prompt. If not provided, defaults to `default`.

| Mode | Role Injected into Prompt | Best For |
|------|--------------------------|----------|
| `default` | No role — general analysis | General architecture |
| `security` | "You are a senior security engineer. Focus on attack vectors, OWASP risks, threat modeling." | Security review |
| `performance` | "You are a performance engineer. Focus on latency, throughput, memory, scaling bottlenecks." | Performance tuning |
| `simplicity` | "You are a pragmatic engineer who values simplicity. Challenge over-engineering, find the simplest solution." | Complexity check |
| `devil` | "You are a devil's advocate. Find every weakness, edge case, and failure mode. Be adversarial." | Stress testing ideas |

---

## Execution Protocol

### Pre-Flight Checklist (MANDATORY before starting)

Before executing ANY step, verify:

- [ ] I will create a session directory under `/tmp/ai-discussions/`
- [ ] I will write prompts to `${AI_DIR}/prompt.txt` and read via `$(cat ...)`
- [ ] I will capture session IDs from Round 1 (parsed from JSONL output for all CLIs)
- [ ] I will use session resume for Round 2+ (NOT re-send full history)
- [ ] If "Ask all": I will use TeamCreate + Task agents (NOT background bash)
- [ ] I will present responses in MANDATORY structured format (Agreement/Disagreement/Concession/Risks)
- [ ] I will include Convergence Signal (green/yellow/red) after every round
- [ ] I will ask user after every round (Continue/Enough/Change direction)

**If I'm about to use `run_in_background: true` for CLI calls -> STOP. I'm violating protocol. Use Agent Team instead.**

---

### Step 0: Select AI & Detect Environment

**Detect available CLIs:**
```bash
which codex 2>/dev/null && echo "codex:available"
which gemini 2>/dev/null && echo "gemini:available"
which opencode 2>/dev/null && echo "opencode:available"
```

**Collect git metadata:**
```bash
git rev-parse --abbrev-ref HEAD 2>/dev/null
git rev-parse --short HEAD 2>/dev/null
```

**Ask user:**
- "Which AI should we debate with?" with options from available CLIs:
  - "Codex (OpenAI)"
  - "Gemini (Google — gemini-3.1-pro-preview)"
  - "OpenCode ({default_model})"
  - "Ask all (parallel)"

---

### Round 1: Opening

**Step 1a: Create session directory & build context file**

```bash
SESSION_ID=$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 4)
SESSION_DIR="/tmp/ai-discussions/${SESSION_ID}"
mkdir -p "${SESSION_DIR}"/{codex,gemini,claude,debate-state}
```

For OpenCode, also create the model-slug directory:
```bash
OPENCODE_MODEL="${MODEL_OVERRIDE:-openrouter/minimax/minimax-m2.7}"
MODEL_SLUG=$(echo "${OPENCODE_MODEL}" | awk -F'/' '{print $NF}')
mkdir -p "${SESSION_DIR}/${MODEL_SLUG}"
```

Write to `${SESSION_DIR}/context.md`:

```markdown
## Session Context

Working Directory: {WORKING_DIR}
Project: {project name from CLAUDE.md or Cargo.toml}
Branch: {git branch}
Commit: {git short hash}
Mode: {MODE or "default"}
Session: {SESSION_ID}

### Current Session Summary
{Brief summary of what's been discussed/worked on}

### Constraints & Decisions Already Made
{Any relevant constraints}

### Question
{TOPIC}
```

**Report session directory to user:** "Debate directory: `{SESSION_DIR}`"

**Step 1b: Build role-augmented prompt**

```
{ROLE_PROMPT if MODE != default, else ""}

You have access to the full codebase in the current directory.

Session context:
{content of ${SESSION_DIR}/context.md}

Question: {TOPIC}

Analyze thoroughly and structure your response using these REQUIRED sections:

## Analysis
Your core analysis with specific file references (file:line format).

## Recommendations
Concrete recommendations with trade-offs:
- Recommendation: {what} | Trade-off: {pros vs cons} | Confidence: {HIGH/MEDIUM/LOW}

## Risks & Edge Cases
- Risk: {description} | Severity: {HIGH/MEDIUM/LOW} | Mitigation: {how}

## Open Questions
Anything you're uncertain about or need more context for.
```

**Step 1c: Send to selected AI CLI + capture session ID**

First, write the full prompt to the AI-specific prompt file (avoids shell quoting issues and parallel conflicts).

```bash
AI_NAME="{selected_ai}"  # "codex", "gemini", or model-slug for OpenCode (e.g. "minimax-m2.7")
AI_DIR="${SESSION_DIR}/${AI_NAME}"
```

**CRITICAL:** Every Round 1 command below writes a session ID to `${AI_DIR}/session-id.txt`. For all CLIs, the session ID is parsed from JSONL output (`jq` extraction). Falls back to `"auto-continue"` if parsing fails. Do NOT skip this step. Do NOT use simpler commands that omit it.

**Live Monitoring:** Every CLI pipes output through `tee` — stdout shows the live stream (visible via TaskOutput when checking the agent), and `${AI_DIR}/live-output.round-{N}.txt` keeps an immutable per-round copy. To watch an agent's progress: use TaskOutput or Read `${AI_DIR}/live-output.round-{N}.txt`.

**Codex:** (omit `-m` entirely if no model argument provided)
```bash
ROUND_N=1
cat <<'PROMPT_EOF' > "${AI_DIR}/prompt.txt"
{full prompt}
PROMPT_EOF
# --json outputs JSONL events to stdout: thread.started, item.completed, turn.completed
codex exec --full-auto -C "{WORKING_DIR}" --json "$(cat "${AI_DIR}/prompt.txt")" 2>&1 | tee "${AI_DIR}/live-output.round-${ROUND_N}.txt"
rc=${PIPESTATUS[0]}
# Inline session ID extraction (no helper function dependency)
SID=$(jq -Rr 'fromjson? | select(.type == "thread.started") | .thread_id' "${AI_DIR}/live-output.round-${ROUND_N}.txt" 2>/dev/null | head -1)
[ -z "$SID" ] && SID=$(grep -o '"thread_id":"[^"]*"' "${AI_DIR}/live-output.round-${ROUND_N}.txt" | head -1 | cut -d'"' -f4)
[ -z "$SID" ] && SID="auto-continue"
echo "$SID" > "${AI_DIR}/session-id.txt"
# Inline response extraction — take LAST agent_message only (not thinking traces)
jq -Rr 'fromjson? | select(.item.type == "agent_message") | .item.text' "${AI_DIR}/live-output.round-${ROUND_N}.txt" 2>/dev/null | tail -n +2 > "${AI_DIR}/response.md"
# Fallback if jq produced nothing
if [ ! -s "${AI_DIR}/response.md" ] || [ $(wc -c < "${AI_DIR}/response.md") -lt 50 ]; then
  # Try all agent_messages (not just last)
  jq -Rr 'fromjson? | select(.item.type == "agent_message") | .item.text' "${AI_DIR}/live-output.round-${ROUND_N}.txt" 2>/dev/null > "${AI_DIR}/response.md"
fi
if [ ! -s "${AI_DIR}/response.md" ] || [ $(wc -c < "${AI_DIR}/response.md") -lt 50 ]; then
  grep -v '^{' "${AI_DIR}/live-output.round-${ROUND_N}.txt" 2>/dev/null | sed '/<think>/,/<\/think>/d' > "${AI_DIR}/response.md"
fi
```
Use Bash tool with `timeout: 1200000`. `--json` outputs JSONL events to stdout. Use `tee` to capture both live stream and file. Always check `PIPESTATUS[0]` for the actual CLI exit code (not `tee`'s).

**Gemini:** (default model: `gemini-3.1-pro-preview` — omit `-m` entirely if no model argument provided)
```bash
ROUND_N=1
cat <<'PROMPT_EOF' > "${AI_DIR}/prompt.txt"
{full prompt}
PROMPT_EOF
# stream-json gives real-time events (thinking, tool calls, partial response) to both stdout and file
gemini -p "$(cat "${AI_DIR}/prompt.txt")" -o stream-json --yolo -m "gemini-3.1-pro-preview" 2>&1 | tee "${AI_DIR}/live-output.round-${ROUND_N}.txt"
rc=${PIPESTATUS[0]}
# Inline session ID extraction
SID=$(jq -Rr 'fromjson? | select(.session_id) | .session_id' "${AI_DIR}/live-output.round-${ROUND_N}.txt" 2>/dev/null | head -1)
[ -z "$SID" ] && SID=$(grep -o '"session_id": *"[^"]*"' "${AI_DIR}/live-output.round-${ROUND_N}.txt" | head -1 | cut -d'"' -f4)
[ -z "$SID" ] && SID="auto-continue"
echo "$SID" > "${AI_DIR}/session-id.txt"
# Inline response extraction with null check
jq -Rrj 'fromjson? | select(.role == "assistant") | select(.content != null) | .content' "${AI_DIR}/live-output.round-${ROUND_N}.txt" 2>/dev/null > "${AI_DIR}/response.md"
if [ ! -s "${AI_DIR}/response.md" ] || [ $(wc -c < "${AI_DIR}/response.md") -lt 50 ]; then
  grep -v '^{' "${AI_DIR}/live-output.round-${ROUND_N}.txt" 2>/dev/null | sed '/<think>/,/<\/think>/d' > "${AI_DIR}/response.md"
fi
```
Use Bash tool with `timeout: 1200000`. Gemini 3.1 Pro uses high thinking level by default — best quality for debates. `-o stream-json` streams events to stdout. Always check `PIPESTATUS[0]` for actual CLI exit code.

**OpenCode:** (default model: `openrouter/minimax/minimax-m2.7` — always pass `-m` explicitly)
```bash
ROUND_N=1
cat <<'PROMPT_EOF' > "${AI_DIR}/prompt.txt"
{full prompt}
PROMPT_EOF
# --format json outputs JSONL events: step_start (sessionID), text (part.text), step_finish
# -f flag attaches prompt file ($(cat ...) does NOT work for multiline prompts in opencode)
# -f MUST come before --format and other flags (position-sensitive)
# CRITICAL: opencode (Bun runtime) requires PTY — use expect wrapper
expect ~/.opencode/pty-wrapper.exp opencode run -f "${AI_DIR}/prompt.txt" --format json -m "${OPENCODE_MODEL}" --dir "{WORKING_DIR}" "Analyze and respond to the attached prompt" 2>&1 | tee "${AI_DIR}/live-output.round-${ROUND_N}.txt"
rc=${PIPESTATUS[0]}
# Strip ANSI escape codes before JSON parsing
sed -r "s/\x1B\[[0-9;]*[mGKH]//g; s/\x1B\[?[0-9;]*[a-zA-Z]//g; s/\r//g" "${AI_DIR}/live-output.round-${ROUND_N}.txt" > "${AI_DIR}/live-clean.txt"
# Inline session ID extraction
SID=$(jq -Rr 'fromjson? | select(.type == "step_start") | .sessionID' "${AI_DIR}/live-clean.txt" 2>/dev/null | head -1)
[ -z "$SID" ] && SID=$(grep -o '"sessionID":"[^"]*"' "${AI_DIR}/live-clean.txt" | head -1 | cut -d'"' -f4)
[ -z "$SID" ] && SID="auto-continue"
echo "$SID" > "${AI_DIR}/session-id.txt"
# Inline response extraction with -j flag (join fragments)
jq -Rrj 'fromjson? | select(.type == "text") | .part.text' "${AI_DIR}/live-clean.txt" 2>/dev/null > "${AI_DIR}/response.md"
if [ ! -s "${AI_DIR}/response.md" ] || [ $(wc -c < "${AI_DIR}/response.md") -lt 50 ]; then
  grep -v '^{' "${AI_DIR}/live-output.round-${ROUND_N}.txt" 2>/dev/null | sed '/<think>/,/<\/think>/d' > "${AI_DIR}/response.md"
fi
```
Use Bash tool with `timeout: 600000` (10 minutes — OpenRouter models need extra time for reasoning). Default model is `openrouter/minimax/minimax-m2.7` — always pass it explicitly. **IMPORTANT:** Use `-f` for prompt delivery. The `-f` flag must come before `--format` in the argument list. **IMPORTANT:** Use `--dir "{WORKING_DIR}"` to give the model read-only codebase access. The project's `opencode.json` disables snapshots (`"snapshot": false`) and denies write/edit/bash permissions at config level — no CLI flag needed. Always check `PIPESTATUS[0]` for actual CLI exit code.

**Step 1d: Save round file**

```bash
cp "${AI_DIR}/response.md" "${AI_DIR}/round-1.md"
# Completeness check — verify response has actual analysis content
if [ -s "${AI_DIR}/response.md" ]; then
  RESP_BYTES=$(wc -c < "${AI_DIR}/response.md")
  HAS_HEADERS=$(grep -c '## \|### ' "${AI_DIR}/response.md" 2>/dev/null || echo 0)
  if [ "$RESP_BYTES" -lt 100 ] || [ "$HAS_HEADERS" -lt 1 ]; then
    echo "WARNING: Response appears incomplete (${RESP_BYTES} bytes, ${HAS_HEADERS} headers). May be thinking trace only." >&2
  fi
fi
```

Session ID is already captured in Step 1c above. Verify it was saved:
```bash
cat "${AI_DIR}/session-id.txt"
# Should print a non-empty session ID
```

**Step 1e: Present Round 1 with MANDATORY FORMAT**

```
## Round 1 — {AI_NAME} ({model_name})

### {AI_NAME}'s View:
{English summary/presentation of the other AI's response}

### Claude's Counter-View:

**Points of Agreement:**
- ...

**Points of Disagreement:**
- ...

**Points Conceded:**
- (none yet in Round 1)

**New Risks / Questions:**
- ...

### Convergence Signal:
New information present — debate is productive. (green)
```

Save Claude's response to `${SESSION_DIR}/claude/${AI_NAME}-round-1.md`.

**Step 1f: Ask user**

- "Continue the debate?" with options:
  - "Continue — send Claude's critique back"
  - "Enough — summarize the results"
  - "Change direction" with sub-options:
    - "From a performance angle"
    - "From a security angle"
    - "From a simplicity angle"

---

### Round N (N >= 2): Session-Based Continuation

**PRIMARY: Session Resume (preferred)**

Since all CLIs support session continuation, Round 2+ continues the SAME conversation. The AI already has full context from previous rounds — no compression needed.

**Step Na: Build challenge-only prompt**

The prompt for Round N is minimal — just Claude's challenge:

```
Claude's response to your Round {N-1} analysis:

{content of ${SESSION_DIR}/claude/${AI_NAME}-round-{N-1}.md}

Respond using this EXACT structure:

## Conceded to Claude
- Points where Claude was right and you now agree (with brief reason)

## Defended (with new evidence)
- Points you still disagree on, with NEW evidence (file paths, line numbers, concrete examples)

## New Perspective
- Any new insights neither side raised before

## Current Position Summary
- Your updated recommendation in 3-5 bullets

Do NOT repeat already-agreed points. Do NOT restate your Round {N-1} arguments without new evidence.
```

Write to `${AI_DIR}/prompt.txt`.

**Step Nb: Validate session + resume with challenge**

**FIRST: Validate session before attempting resume.** If validation fails, fall back to context compression (see fallback below).

```bash
# Determine CLI type for this AI
CLI_TYPE="codex"  # or "gemini" or "opencode"
if validate_session "${AI_DIR}/session-id.txt" "$CLI_TYPE"; then
  SESSION_AI_ID=$(cat "${AI_DIR}/session-id.txt")
  echo "Session valid: ${SESSION_AI_ID} — resuming"
else
  echo "Session invalid — falling back to context compression"
  # Jump to FALLBACK section below
fi
```

**CRITICAL: The CLI-specific resume command below MUST be inside the `if` block, NOT after it. If session is invalid, skip resume entirely and use the FALLBACK context compression approach instead.**

**Codex (resume):**
```bash
codex exec resume "${SESSION_AI_ID}" --full-auto --json "$(cat "${AI_DIR}/prompt.txt")" 2>&1 | tee "${AI_DIR}/live-output.round-${ROUND_N}.txt"
rc=${PIPESTATUS[0]}
extract_response "${AI_DIR}/live-output.round-${ROUND_N}.txt" "${AI_DIR}/response.md" "codex"
```

**Gemini (resume):**
```bash
gemini --resume "${SESSION_AI_ID}" -p "$(cat "${AI_DIR}/prompt.txt")" -o stream-json --yolo 2>&1 | tee "${AI_DIR}/live-output.round-${ROUND_N}.txt"
rc=${PIPESTATUS[0]}
extract_response "${AI_DIR}/live-output.round-${ROUND_N}.txt" "${AI_DIR}/response.md" "gemini"
```

**OpenCode (resume):**
```bash
# CRITICAL: opencode (Bun runtime) requires PTY — use expect wrapper
expect ~/.opencode/pty-wrapper.exp opencode run -f "${AI_DIR}/prompt.txt" --format json -m "${OPENCODE_MODEL}" --dir "{WORKING_DIR}" -s "${SESSION_AI_ID}" "Respond to the challenge in the attached file" 2>&1 | tee "${AI_DIR}/live-output.round-${ROUND_N}.txt"
rc=${PIPESTATUS[0]}
extract_response "${AI_DIR}/live-output.round-${ROUND_N}.txt" "${AI_DIR}/response.md" "opencode"
```

Copy response: `cp "${AI_DIR}/response.md" "${AI_DIR}/round-${ROUND_N}.md"`

**If resume CLI exits with non-zero `rc`:** Log the error, then fall back to context compression below.

**FALLBACK: Context Compression (if session resume fails)**

If session resume fails (CLI error, session expired, etc.), fall back to compressed context:

```markdown
## Debate State (end of Round {N-1})

Confirmed Facts:
- {fact 1}
- {fact 2}

Points of Agreement:
- {agreement 1}

Still Disputed Areas:
- {dispute 1}

Deliberately Rejected Approaches:
- {rejected 1} — Reason: {reason}
```

Save to `${SESSION_DIR}/debate-state/${AI_NAME}-state-{N-1}.md`.

Send as new session (Round 1 protocol) with the Debate State + Claude's last challenge as a single prompt.

**Step Nc: Present Round N with MANDATORY FORMAT**

```
## Round {N} — {AI_NAME} ({model_name})

### {AI_NAME}'s Response:
{English presentation}

### Claude's Counter-View:

**Points of Agreement:**
- ...

**Points of Disagreement:**
- ...

**Points Conceded:**
- ...

**New Risks / Questions:**
- ...

### Convergence Signal:
{One of — use these EXPLICIT criteria:}

🟢 **GREEN** — New technical argument present. Debate is productive.
  Criteria: AI introduced NEW code references, benchmarks, trade-offs, or attack vectors not seen in previous rounds.

🟡 **YELLOW** — Few new arguments. Convergence starting. One more round may suffice.
  Criteria: AI rephrased or slightly refined previous arguments. No new file references or concrete evidence. Minor positioning shifts only.

🔴 **RED** — No new information produced. Continuing risks repetition. Recommend synthesizing.
  Criteria: AI repeated Round N-1 arguments verbatim or with cosmetic changes only. No new perspectives. Positions identical to previous round.
```

Save Claude's response to `${SESSION_DIR}/claude/${AI_NAME}-round-{N}.md`.

**Step Nd: Budget check + ask user**

**Budget enforcement:**
```
MAX_ROUNDS = {max_rounds} or 7 (default)
AUTO_ROUNDS = {auto_rounds} or 0 (default, meaning ask each time)

if ROUND_N >= MAX_ROUNDS:
  → Force "Enough" — "Maximum round count reached ({MAX_ROUNDS}). Synthesizing."
elif ROUND_N >= 5:
  → Warn: "Reached round 5. Are you sure you want to continue further?"
elif AUTO_ROUNDS == "auto":
  → Auto-continue until convergence signal is RED, then auto-trigger "Enough"
elif AUTO_ROUNDS > 0 and ROUND_N < AUTO_ROUNDS:
  → Auto-continue without asking (show progress: "Round {N}/{AUTO_ROUNDS} complete — auto-continuing...")
else:
  → Ask user normally
```

**User prompt options** (when asking):
Same options: Continue / Enough / Change direction

---

### "Ask all" Mode — Agent Team

If user selected "Ask all (parallel)":

**This mode uses the Task tool's agent team infrastructure for true parallel multi-round debates with cross-pollination.**

**Fallback — if TeamCreate/SendMessage are unavailable:** Run each AI sequentially using the single-AI protocol (Round 1 -> present -> Round 1 next AI -> present -> ...). After all AIs have responded, present the comparative analysis table. Cross-pollination is not possible in sequential fallback — note this to the user. Use `Task(subagent_type="general-purpose")` without `team_name` if the Task tool is available but team features are not.

#### Architecture

```
+---------------------------------------------------+
|                  Team Lead (Claude)                 |
|  - Creates team + tasks                            |
|  - Monitors convergence matrix                     |
|  - Cross-pollinates strong arguments               |
|  - Synthesizes final output                        |
+---------+----------+------------------------------+
| Agent:  | Agent:   | Agent:                        |
| codex   | gemini   | opencode-{model-slug}         |
| +-----+ | +------+ | +--------+                    |
| |Run  | | |Run   | | |Run     |                    |
| |CLI  | | |CLI   | | |CLI     |                    |
| |Read | | |Read  | | |Read    |                    |
| |Anal.| | |Anal. | | |Anal.   |                    |
| |Report| | |Report| | |Report |                    |
| +-----+ | +------+ | +--------+                    |
+---------+----------+------------------------------+
```

#### Step H1: Create session + team

```bash
SESSION_ID=$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 4)
SESSION_DIR="/tmp/ai-discussions/${SESSION_ID}"
mkdir -p "${SESSION_DIR}"/{codex,gemini,minimax-m2.7,kimi-k2.5,glm-5,qwen3.5-397b-a17b,mimo-v2-pro,claude,debate-state}
```

**File Access:** If the debate topic involves reviewing files outside the project directory (e.g., skill files in `~/.claude/`), copy them to the project root first so all AI models can access them via `--dir`:
```bash
# Example: copy skill file for review
cp ~/.claude/skills/ask-another-ai/skill.md "${WORKING_DIR}/_review-target.md"
# Clean up after debate: rm "${WORKING_DIR}/_review-target.md"
```

Create team:
```
TeamCreate: team_name="debate-{SESSION_ID}", description="AI Debate: {TOPIC}"
```

Spawn **7 agents** in parallel (one per participant from the Default Model Pool table):
- `codex-debater` — runs Codex native CLI
- `gemini-debater` — runs Gemini native CLI
- `minimax-debater` — runs `opencode` with `-m "openrouter/minimax/minimax-m2.7"`, dir: `minimax-m2.7/`
- `kimi-debater` — runs `opencode` with `-m "openrouter/moonshotai/kimi-k2.5"`, dir: `kimi-k2.5/`
- `glm-debater` — runs `opencode` with `-m "openrouter/z-ai/glm-5v-turbo"`, dir: `glm-5/`
- `qwen-debater` — runs `opencode` with `-m "openrouter/qwen/qwen3.5-397b-a17b"`, dir: `qwen3.5-397b-a17b/`
- `mimo-debater` — runs `opencode` with `-m "openrouter/xiaomi/mimo-v2-pro"`, dir: `mimo-v2-pro/`

Write shared context to `${SESSION_DIR}/context.md` (same as single-AI mode).

#### Step H2: Create tasks + spawn agents

For EACH available AI, create a task:

```
TaskCreate: "Run {AI_NAME} debate round 1"
  description: "Run {AI_NAME} CLI with the opening prompt, read response, create structured analysis..."
```

Then spawn ONE agent per AI using the Task tool **in parallel** (all in a single message):

```
Task(subagent_type="general-purpose", team_name="debate-{SESSION_ID}", name="{ai_name}-debater")
```

**Agent prompt template** (adapted per AI):

**CRITICAL — Path substitution rule:** The team lead MUST substitute ALL `{PLACEHOLDER}` values with concrete absolute paths before sending the prompt to agents. Agents receive prompts with zero placeholders — every path is a hardcoded literal string. This prevents shell variable persistence issues between separate Bash tool calls.

**CRITICAL — Single Bash call rule:** Each agent MUST run the CLI command, session ID parsing, response extraction, and file copying in a SINGLE Bash tool call. Do NOT split these into separate Bash calls — shell variables do not persist between calls.

The team lead constructs the prompt by replacing ONLY these documented placeholders: `{SESSION_DIR}`, `{AI_DIR}`, `{AI_NAME}`, `{PROVIDER}`, `{WORKING_DIR}`, `{TOPIC}`, `{MODE}`, `{ROUND_N}`, `{COMPLETE_CLI_SCRIPT}`, and CLI-specific values like `{MODEL}`, `{SESSION_AI_ID}`. Do NOT touch shell syntax like `${PIPESTATUS[0]}`, `$SID`, `$RC` — these are real bash variables, not template placeholders (they have a `$` prefix).

```
You are a debate agent managing the {AI_NAME} ({PROVIDER}) side of an AI debate.

## Your Job
1. Run the {AI_NAME} CLI with the provided single-script command
2. Read the extracted response file
3. Send your analysis back to the team lead via SendMessage
4. Wait for further instructions (next round, cross-pollination, or shutdown)

## Session Info
- Session dir: {SESSION_DIR}
- AI dir: {AI_DIR}
- Working dir: {WORKING_DIR}
- Topic: {TOPIC}
- Mode: {MODE}

## Step 1: Run CLI + extract response (SINGLE Bash call)

CRITICAL: Run this ENTIRE script in ONE Bash tool call with timeout: 1200000 (20 minutes — models need extra time for reasoning).
The prompt file already exists at {AI_DIR}/prompt.txt — do NOT recreate it.

{COMPLETE_CLI_SCRIPT}

## Step 2: Read response and analyze

Read the file at {AI_DIR}/response.md using the Read tool.

Then send a message to "team-lead" via SendMessage with this format:

**{AI_NAME} Round {ROUND_N} Analysis:**

Convergence: {green/yellow/red — assess from the response}

**Main Arguments:**
- {bullet points from AI's analysis}

**Points I Agree With (from Claude's perspective):**
- {points that seem valid and well-supported}

**Points I Disagree With:**
- {points that seem weak or questionable}

**New Risks:**
- {new risks or edge cases the AI identified}

Also save your analysis to {SESSION_DIR}/claude/{AI_NAME}-round-{ROUND_N}.md using the Write tool.

## Important
- The ENTIRE CLI script in Step 1 MUST be a single Bash tool call — do NOT split it
- Use Bash tool with timeout: 1200000 (20min for large reasoning models)
- After sending your analysis via SendMessage, go idle and wait for instructions
```

**Per-CLI complete scripts** — team lead substitutes these into `{COMPLETE_CLI_SCRIPT}`:

**Codex script** (omit `-m {MODEL}` if no model override):
```bash
# Codex Round {ROUND_N} — all-in-one script
codex exec --full-auto -C "{WORKING_DIR}" --json "$(cat "{AI_DIR}/prompt.txt")" 2>&1 | tee "{AI_DIR}/live-output.round-{ROUND_N}.txt"
RC=${PIPESTATUS[0]}
# Parse session ID
SID=$(jq -Rr 'fromjson? | select(.type == "thread.started") | .thread_id' "{AI_DIR}/live-output.round-{ROUND_N}.txt" 2>/dev/null | head -1)
[ -z "$SID" ] && SID=$(grep -o '"thread_id":"[^"]*"' "{AI_DIR}/live-output.round-{ROUND_N}.txt" | head -1 | cut -d'"' -f4)
[ -z "$SID" ] && SID="auto-continue"
echo "$SID" > "{AI_DIR}/session-id.txt"
# Extract response
jq -Rr 'fromjson? | select(.item.type == "agent_message") | .item.text' "{AI_DIR}/live-output.round-{ROUND_N}.txt" 2>/dev/null > "{AI_DIR}/response.md"
if [ ! -s "{AI_DIR}/response.md" ]; then
  grep -v '^{' "{AI_DIR}/live-output.round-{ROUND_N}.txt" 2>/dev/null > "{AI_DIR}/response.md"
  [ ! -s "{AI_DIR}/response.md" ] && cp "{AI_DIR}/live-output.round-{ROUND_N}.txt" "{AI_DIR}/response.md"
fi
cp "{AI_DIR}/response.md" "{AI_DIR}/round-{ROUND_N}.md"
echo "=== DONE: session-id=$(cat "{AI_DIR}/session-id.txt"), response=$(wc -l < "{AI_DIR}/response.md") lines, exit=$RC ==="
```

**Gemini script** (default model `gemini-3.1-pro-preview`):
```bash
# Gemini Round {ROUND_N} — all-in-one script
gemini -p "$(cat "{AI_DIR}/prompt.txt")" -o stream-json --yolo -m "gemini-3.1-pro-preview" 2>&1 | tee "{AI_DIR}/live-output.round-{ROUND_N}.txt"
RC=${PIPESTATUS[0]}
# Parse session ID
SID=$(jq -Rr 'fromjson? | select(.session_id) | .session_id' "{AI_DIR}/live-output.round-{ROUND_N}.txt" 2>/dev/null | head -1)
[ -z "$SID" ] && SID=$(grep -o '"session_id": *"[^"]*"' "{AI_DIR}/live-output.round-{ROUND_N}.txt" | head -1 | cut -d'"' -f4)
[ -z "$SID" ] && SID="auto-continue"
echo "$SID" > "{AI_DIR}/session-id.txt"
# Extract response
jq -Rrj 'fromjson? | select(.role == "assistant") | .content' "{AI_DIR}/live-output.round-{ROUND_N}.txt" 2>/dev/null > "{AI_DIR}/response.md"
if [ ! -s "{AI_DIR}/response.md" ]; then
  grep -v '^{' "{AI_DIR}/live-output.round-{ROUND_N}.txt" 2>/dev/null > "{AI_DIR}/response.md"
  [ ! -s "{AI_DIR}/response.md" ] && cp "{AI_DIR}/live-output.round-{ROUND_N}.txt" "{AI_DIR}/response.md"
fi
cp "{AI_DIR}/response.md" "{AI_DIR}/round-{ROUND_N}.md"
echo "=== DONE: session-id=$(cat "{AI_DIR}/session-id.txt"), response=$(wc -l < "{AI_DIR}/response.md") lines, exit=$RC ==="
```

**OpenCode script** (team lead substitutes `{MODEL}` with full model path like `openrouter/minimax/minimax-m2.7`):
```bash
# OpenCode ({MODEL}) Round {ROUND_N} — all-in-one script
# -f flag MUST come before --format (position-sensitive)
# CRITICAL: opencode (Bun) needs PTY — expect wrapper prevents stdout buffering
# project opencode.json disables snapshots + denies bash/write/edit permissions
expect ~/.opencode/pty-wrapper.exp opencode run -f "{AI_DIR}/prompt.txt" --format json -m "{MODEL}" --dir "{WORKING_DIR}" "Analyze and respond to the attached prompt" 2>&1 | tee "{AI_DIR}/live-output.round-{ROUND_N}.txt"
RC=${PIPESTATUS[0]}
# Strip ANSI escape codes before JSON parsing
sed -r "s/\x1B\[[0-9;]*[mGKH]//g; s/\x1B\[?[0-9;]*[a-zA-Z]//g; s/\r//g" "{AI_DIR}/live-output.round-{ROUND_N}.txt" > "{AI_DIR}/live-clean.txt"
# Parse session ID from cleaned output
SID=$(jq -Rr 'fromjson? | select(.type == "step_start") | .sessionID' "{AI_DIR}/live-clean.txt" 2>/dev/null | head -1)
[ -z "$SID" ] && SID=$(grep -o '"sessionID":"[^"]*"' "{AI_DIR}/live-clean.txt" | head -1 | cut -d'"' -f4)
[ -z "$SID" ] && SID="auto-continue"
echo "$SID" > "{AI_DIR}/session-id.txt"
# Extract response with -j flag (join text fragments)
jq -Rrj 'fromjson? | select(.type == "text") | .part.text' "{AI_DIR}/live-clean.txt" 2>/dev/null > "{AI_DIR}/response.md"
if [ ! -s "{AI_DIR}/response.md" ] || [ $(wc -c < "{AI_DIR}/response.md") -lt 50 ]; then
  grep -v '^{' "{AI_DIR}/live-output.round-{ROUND_N}.txt" 2>/dev/null | sed '/<think>/,/<\/think>/d' > "{AI_DIR}/response.md"
  [ ! -s "{AI_DIR}/response.md" ] && cp "{AI_DIR}/live-output.round-{ROUND_N}.txt" "{AI_DIR}/response.md"
fi
cp "{AI_DIR}/response.md" "{AI_DIR}/round-{ROUND_N}.md"
echo "=== DONE: session-id=$(cat "{AI_DIR}/session-id.txt"), response=$(wc -l < "{AI_DIR}/response.md") lines, exit=$RC ==="
```

**Codex resume script** (Round 2+):
```bash
# Codex Resume Round {ROUND_N} — all-in-one script
codex exec resume "{SESSION_AI_ID}" --full-auto --json "$(cat "{AI_DIR}/prompt.txt")" 2>&1 | tee "{AI_DIR}/live-output.round-{ROUND_N}.txt"
RC=${PIPESTATUS[0]}
jq -Rr 'fromjson? | select(.item.type == "agent_message") | .item.text' "{AI_DIR}/live-output.round-{ROUND_N}.txt" 2>/dev/null > "{AI_DIR}/response.md"
if [ ! -s "{AI_DIR}/response.md" ]; then
  grep -v '^{' "{AI_DIR}/live-output.round-{ROUND_N}.txt" 2>/dev/null > "{AI_DIR}/response.md"
  [ ! -s "{AI_DIR}/response.md" ] && cp "{AI_DIR}/live-output.round-{ROUND_N}.txt" "{AI_DIR}/response.md"
fi
cp "{AI_DIR}/response.md" "{AI_DIR}/round-{ROUND_N}.md"
echo "=== DONE: response=$(wc -l < "{AI_DIR}/response.md") lines, exit=$RC ==="
```

**Gemini resume script** (Round 2+):
```bash
# Gemini Resume Round {ROUND_N} — all-in-one script
gemini --resume "{SESSION_AI_ID}" -p "$(cat "{AI_DIR}/prompt.txt")" -o stream-json --yolo 2>&1 | tee "{AI_DIR}/live-output.round-{ROUND_N}.txt"
RC=${PIPESTATUS[0]}
jq -Rrj 'fromjson? | select(.role == "assistant") | .content' "{AI_DIR}/live-output.round-{ROUND_N}.txt" 2>/dev/null > "{AI_DIR}/response.md"
if [ ! -s "{AI_DIR}/response.md" ]; then
  grep -v '^{' "{AI_DIR}/live-output.round-{ROUND_N}.txt" 2>/dev/null > "{AI_DIR}/response.md"
  [ ! -s "{AI_DIR}/response.md" ] && cp "{AI_DIR}/live-output.round-{ROUND_N}.txt" "{AI_DIR}/response.md"
fi
cp "{AI_DIR}/response.md" "{AI_DIR}/round-{ROUND_N}.md"
echo "=== DONE: response=$(wc -l < "{AI_DIR}/response.md") lines, exit=$RC ==="
```

**OpenCode resume script** (Round 2+):
```bash
# OpenCode ({MODEL}) Resume Round {ROUND_N} — all-in-one script
# CRITICAL: opencode (Bun) needs PTY — expect wrapper prevents stdout buffering
expect ~/.opencode/pty-wrapper.exp opencode run -f "{AI_DIR}/prompt.txt" --format json -m "{MODEL}" --dir "{WORKING_DIR}" -s "{SESSION_AI_ID}" "Respond to the challenge in the attached file" 2>&1 | tee "{AI_DIR}/live-output.round-{ROUND_N}.txt"
RC=${PIPESTATUS[0]}
# Strip ANSI escape codes before JSON parsing
sed -r "s/\x1B\[[0-9;]*[mGKH]//g; s/\x1B\[?[0-9;]*[a-zA-Z]//g; s/\r//g" "{AI_DIR}/live-output.round-{ROUND_N}.txt" > "{AI_DIR}/live-clean.txt"
# Extract response with -j flag (join text fragments)
jq -Rrj 'fromjson? | select(.type == "text") | .part.text' "{AI_DIR}/live-clean.txt" 2>/dev/null > "{AI_DIR}/response.md"
if [ ! -s "{AI_DIR}/response.md" ] || [ $(wc -c < "{AI_DIR}/response.md") -lt 50 ]; then
  grep -v '^{' "{AI_DIR}/live-output.round-{ROUND_N}.txt" 2>/dev/null | sed '/<think>/,/<\/think>/d' > "{AI_DIR}/response.md"
  [ ! -s "{AI_DIR}/response.md" ] && cp "{AI_DIR}/live-output.round-{ROUND_N}.txt" "{AI_DIR}/response.md"
fi
cp "{AI_DIR}/response.md" "{AI_DIR}/round-{ROUND_N}.md"
echo "=== DONE: response=$(wc -l < "{AI_DIR}/response.md") lines, exit=$RC ==="
```

#### Step H3: Collect Round 1 results

Team lead receives messages from all agents as they complete. Wait for all agents to report back.

Present comparative Round 1 analysis to user:

```
## Round 1 — Comparative Analysis

### Convergence Matrix
| AI | Convergence | Main Argument |
|----|-------------|-------------|
| Codex (OpenAI) | {signal} | {1-line summary} |
| Gemini (Google) | {signal} | {1-line summary} |
| MiniMax (minimax-m2.7) | {signal} | {1-line summary} |
| Kimi (kimi-k2.5) | {signal} | {1-line summary} |
| GLM (glm-5) | {signal} | {1-line summary} |
| Qwen (qwen3.5-397b-a17b) | {signal} | {1-line summary} |

### Where All AIs Agree:
- ...

### Key Differences:
- ...

### Strongest Argument (from whom):
- {AI_NAME}: {argument}

### Cross-Pollination Candidates:
- {AI_X}'s following argument -> should be sent to {AI_Y}: "{argument}"
```

#### Step H4: Ask user for next action

```
- "Continue — go to round 2 with all AIs"
- "Cross-pollinate — send strong arguments across, then round 2"
- "Continue with {AI_NAME} only" (switches to single-AI mode with that agent)
- "Enough — synthesize"
```

#### Step H5: Cross-Pollination Protocol

If user selects cross-pollination (or team lead detects a strong argument that others missed):

Send a message to the relevant agent via `SendMessage`:

```
SendMessage(type="message", recipient="{ai_name}-debater", content="
Round 2 instructions:

Before asking your AI the main question again, include this cross-pollination context:

Another AI ({SOURCE_AI_NAME}) raised this argument:
---
{strong argument text}
---

Ask your AI to respond to this argument specifically, in addition to the main debate continuation.

Use the compressed debate state from round 1 (same protocol as single-AI Round N).
", summary="Cross-pollination round 2 for {ai_name}")
```

The agent then:
1. Builds a Round 2 prompt including the cross-pollinated argument
2. Generates debate state from Round 1
3. Runs the CLI
4. Reports back

#### Step H6: Multi-Round Loop

Repeat Steps H3-H5 for each round. Team lead maintains a **Convergence Matrix**:

```
## Convergence Matrix — Round {N}

| AI | R1 | R2 | R3 | Trend |
|----|----|----|----| ------|
| Codex | {s} | {s} | {s} | {trend} |
| Gemini | {s} | {s} | {s} | {trend} |
| MiniMax | {s} | {s} | {s} | {trend} |
| Kimi | {s} | {s} | {s} | {trend} |
| GLM | {s} | {s} | {s} | {trend} |
| Qwen | {s} | {s} | {s} | {trend} |
| MiMo | {s} | {s} | {s} | {trend} |
```

**Auto-stop rules:**
- When ALL AIs hit red -> suggest "Enough"
- When majority of AIs hit red -> suggest focusing on the remaining productive AI(s)
- When `ROUND_N >= max_rounds` (default: 7) -> force synthesis
- When `ROUND_N >= 5` -> warn user: "Reached round 5 — recommend synthesizing"

**Circuit breaker (per AI):**

Track consecutive failures per AI agent. After 3 consecutive failures (CLI error, timeout, empty response), mark that AI as **unavailable** for the remainder of this debate:

```
AI_FAIL_COUNT[{ai_name}] += 1
if AI_FAIL_COUNT[{ai_name}] >= 3:
  → Send message to user: "{AI_NAME} failed consecutively 3 times — disabled for this debate."
  → SendMessage(type="shutdown_request", recipient="{ai_name}-debater")
  → Remove from active agents list
  → Continue debate with remaining AIs
  → If ALL AIs circuit-broken → force synthesis with whatever data collected
```

Reset failure count on any successful round.

#### Step H7: Graceful Shutdown

When synthesis begins:
1. Send `SendMessage(type="shutdown_request")` to ALL agents
2. Agents approve and exit
3. Team lead generates final synthesis (same format as single-AI mode, but multi-AI)
4. `TeamDelete` to clean up

#### "Ask all" Synthesis Template (replaces single-AI synthesis)

```
## Debate Summary: {TOPIC}

**Branch:** {branch} @ {commit}
**AIs:** Codex ({model}), Gemini ({model}), MiniMax ({model}), Kimi ({model}), GLM ({model}), Qwen ({model})
**Mode:** {MODE} | **Round Count:** {N} (per AI)
**Cross-pollination:** {count} arguments cross-sent

### Convergence Matrix (Final)
{convergence matrix table}

### Where All AIs Converge (Strong Signal)
{Points where 3+ AIs agree — these are high-confidence}

### 3-vs-2 Splits
{Points where AIs split — these need human judgment}

### Risks Only One AI Spotted
{Unique insights that only one AI raised — potentially blind spots}

### Rejected Alternatives (Majority)
{Approaches rejected by majority of AIs}

### Recommended Action
{Team lead's synthesis considering all AIs}

### Most Valuable Contribution from Each AI
- **Codex:** {unique contribution}
- **Gemini:** {unique contribution}
- **MiniMax:** {unique contribution}
- **Kimi:** {unique contribution}
- **GLM:** {unique contribution}
- **Qwen:** {unique contribution}
- **MiMo:** {unique contribution}
```

#### Performance Notes

- Agent team mode uses more tokens than simple parallel mode (each agent has its own context)
- Cross-pollination adds ~1 extra round per polinated argument
- For simple questions, prefer single-AI mode or basic parallel (no team overhead)
- Team mode shines for: architecture decisions, security audits, complex trade-offs where multiple perspectives genuinely help

---

### Final: Synthesis + Memory Write-Back

When user says "Enough":

**Step F1: Generate synthesis**

```
## Debate Summary: {TOPIC}

**Branch:** {branch} @ {commit}
**AI:** {AI_NAME} | **Model:** {model_name} | **Mode:** {MODE} | **Round Count:** {N}

### Points of Agreement
{Points both AIs agreed on}

### Unresolved Disagreements
{Where they still differ — both sides' positions}

### Rejected Alternatives
{Approaches deliberately rejected during the debate and the reasons}

### Recommended Action
{Concrete steps Claude recommends after evaluating the entire debate}

### Key Contribution from {AI_NAME}
{The most valuable point raised by the other AI that Claude would not have arrived at alone}
```

**Step F2: Save FULL debate record to docs/ (ALWAYS)**

Always save the complete debate to `docs/debates/` as a permanent project record:

```
docs/debates/YYYY-MM-DD-{topic-slug}.md
```

Create the `docs/debates/` directory if it doesn't exist.

The file MUST contain the following sections in order:

```markdown
# AI Debate: {TOPIC}

**Date:** YYYY-MM-DD
**AI:** {AI_NAME} ({provider}) | **Model:** {model_name} | **Mode:** {MODE}
**Branch:** {branch} @ {commit}
**Moderator:** Claude ({claude_model})
**Round Count:** {N}

---

## Decision Summary

{Step F1 synthesis output — agreements, disagreements, rejected alternatives, recommended action, key contribution}

---

## Debate Details

### Round 1 — {AI_NAME} ({model_name})

#### {AI_NAME}'s View:
{The other AI's FULL response — do not truncate, include original output verbatim}

#### Claude's Counter-View:

**Points of Agreement:**
{full list}

**Points of Disagreement:**
{full list}

**Points Conceded:**
{full list}

**New Risks / Questions:**
{full list}

**Convergence Signal:** {signal + explanation}

---

### Round 2 — {AI_NAME} ({model_name})

{Same format — other AI's FULL response + Claude's structured response}

---

{... all rounds ...}

---

## Final Debate State

{Contents of the last debate-state file — confirmed facts, agreements, disputes, rejected items}
```

**IMPORTANT:** Write the other AI's responses in FULL — do not truncate or summarize. This file is the only permanent record of the debate; readers must be able to see every argument.

**Step F2b: Update Debate INDEX.md**

Append an entry to `docs/debates/INDEX.md` (create file with header if it doesn't exist):

```markdown
<!-- If file doesn't exist, create with this header first: -->
# AI Debate Index

| Date | Topic | AIs | Rounds | Outcome | File |
|------|-------|-----|--------|---------|------|

<!-- Then append this row: -->
| {YYYY-MM-DD} | {topic short} | {AI names, comma-separated} | {N} | {Consensus/Partial consensus/No consensus} | [{filename}](./{filename}) |
```

This creates a permanent, browsable index of all AI debates in the project.

**Step F3: Offer memory write-back**

Ask user:
- "Save this decision to memory as well?" with options:
  - "Yes — also save to memory"
  - "No — docs/ is enough"

If yes, use the MCP `save_memory` tool directly. Derive the project name from the git repo or working directory name — do NOT hardcode it:

```
mcp__plugin_claude-mem_mcp-search__save_memory(
  title: "AI Debate: {TOPIC_SHORT}",
  text: "## Decision\n{recommended action}\n\n## Rationale\n{rationale}\n\n## Rejected Alternatives\n{rejected}\n\n## Source\nAI Debate — {AI_NAME} ({MODE}) — {N} rounds — {branch}@{commit}\nDocs: docs/debates/{filename}",
  project: "{PROJECT_NAME}"  // from `basename $(git rev-parse --show-toplevel)` or CLAUDE.md
)
```

**Step F4: Clean up**

```bash
# Remove the entire session directory
rm -rf "${SESSION_DIR}"
```

Note: Old-style flat files (`/tmp/ai-debate-*.md`, `/tmp/ai-round-*.md`, etc.) may exist from previous sessions. Clean them too if found:
```bash
rm -f /tmp/ai-debate-context.md /tmp/ai-debate-response.md /tmp/ai-debate-prompt.txt /tmp/ai-round-*.md /tmp/claude-round-*.md /tmp/debate-state-*.md
```

---

## File Management

All files live under `${SESSION_DIR}` (`/tmp/ai-discussions/{session-id}/`). Each AI has its own subdirectory — no shared mutable files between AIs.

| File | Content | Lifecycle |
|------|---------|-----------|
| `${SESSION_DIR}/context.md` | Shared session context + git metadata | Created once, read-only |
| `${AI_DIR}/prompt.txt` | Prompt sent to this AI (current round) | Overwritten each round |
| `${AI_DIR}/live-output.round-{N}.txt` | Raw CLI stdout+stderr (immutable per round for audit trail) | Per round, permanent |
| `${AI_DIR}/response.md` | Extracted clean text response (convenience pointer to current round) | Overwritten each round |
| `${AI_DIR}/session-id.txt` | CLI session ID for resume. Validated with `validate_session()` before use. Codex: `thread_*`. Gemini: any string. OpenCode: `ses_*`. Falls back to `"auto-continue"` if parse fails. | Created in Round 1, read in Round 2+ |
| `${AI_DIR}/round-{N}.md` | AI's response in round N | Per round, permanent |
| `${SESSION_DIR}/claude/${AI_NAME}-round-{N}.md` | Claude's structured response per AI per round | Per round |
| `${SESSION_DIR}/debate-state/${AI_NAME}-state-{N}.md` | Compressed debate state per AI (fallback only) | Per round, if session resume fails |

**Parallel safety:** In "Ask all" mode, Codex writes to `codex/`, Gemini to `gemini/`, OpenCode to `{model-slug}/` (e.g. `minimax-m2.7/`) — zero file conflicts.

## Error Handling

| Error | Detection | Action | Retry? |
|-------|-----------|--------|--------|
| CLI not found | `which` returns empty | "This CLI is not installed. Install: {install command}" | No |
| Auth failure | stderr contains `auth`, `login`, `unauthorized`, `401` | "You need to log in: {login command}" | No |
| Rate limit | stdout/stderr contains `429`, `rate limit`, `too many requests`, `quota exceeded` | Wait 30s, then retry. Log: "Rate limit — waiting 30s..." | Yes (max 2) |
| Timeout (>5min) | Bash tool timeout or PIPESTATUS non-zero | Show partial output from `live-output.round-{N}.txt` if exists. Retry once. | Yes (max 1) |
| Empty response | `response.md` is 0 bytes after `extract_response` | Try broader jq extraction, then grep for markdown sections. If still empty, retry with simpler prompt. | Yes (max 1) |
| Session resume fail | CLI exits non-zero on resume command | Log error. Fall back to context compression (see fallback section). Generate new session ID for fresh start. | No (fallback) |
| Partial JSON | `jq` parse fails but file is non-empty | Use `grep -v '^{'` fallback to extract readable text. Present as degraded output. | No |
| Missing `jq` | `which jq` returns empty | Install prompt: "jq required: `brew install jq`". Abort gracefully. | No |
| Disk error | Write/mkdir fails | "Disk write error — /tmp may be full. Run `df -h /tmp` to check." | No |

Install commands:
- Codex: `npm install -g @openai/codex` -> `codex login`
- Gemini: `npm install -g @google/gemini-cli` -> first run auth
- OpenCode: `curl -fsSL https://opencode.ai/install | bash` -> `opencode auth`

## Design Principles

1. **Session resume > context compression** — Round 2+ continues the same session (AI remembers all history). Compression is used only as a fallback when the session fails
2. **Format > intent** — Saying "be honest" is not enough. A mandatory structured format (Agreement/Disagreement/Concession/Risks) breaks the defensive reflex
3. **Convergence signal > infinite loop** — Claude reports debate productivity each round with green/yellow/red
4. **Memory write-back > one-shot** — Decisions are written to institutional memory so the same debate is not repeated
5. **Role presets > generic prompt** — security/performance/simplicity/devil modes double debate quality
6. **Git metadata > floating context** — branch + commit hash make the debate reproducible
7. **Cross-pollination > echo chamber** — Sending one AI's strong argument to others prevents all of them drifting the same way
8. **Convergence matrix > individual signals** — Decision is based on all AIs' matrix-wide convergence, not a single AI's red
9. **Agent isolation > shared context** — Each AI agent runs in its own context and the team lead synthesizes — no context pollution
10. **Retry with backoff > silent failure** — Transient errors (rate limit, timeout) get automatic retries; permanent errors are reported to the user
11. **Budget controls > runaway debates** — max_rounds cap (default 7) prevents infinite loops; auto_rounds mode runs N rounds without user intervention
12. **Circuit breaker > zombie agents** — An AI that fails 3 times in a row is disabled, and the debate continues with the remaining AIs
13. **Immutable round files > overwrite** — `live-output.round-{N}.txt` files are never overwritten — each round's raw output forms a permanent audit trail
14. **Debate INDEX > scattered records** — Every debate is appended to `docs/debates/INDEX.md` — a project-wide searchable history
