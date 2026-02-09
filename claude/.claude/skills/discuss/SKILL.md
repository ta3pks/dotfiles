---
name: discuss
description: Iterative debate between Claude Code and another AI CLI (Codex/Gemini/Kimi). Context-compressed, convergence-aware, memory-backed. For architecture, security, concurrency decisions — not CRUD.
user_invocable: true
arguments:
  - name: topic
    description: The question or topic to discuss. If empty, auto-detect from current session context.
    required: false
  - name: mode
    description: "Role preset: security, performance, simplicity, devil, or default"
    required: false
  - name: model
    description: "Override model for the selected CLI (e.g. o3, o4-mini, gemini-2.5-pro, kimi-k2p5). If empty, uses CLI default."
    required: false
---

# Discuss — Iterative Cross-AI Debate

## Overview

Starts a controlled, multi-round debate between Claude Code and another AI CLI. Each round is context-compressed, Claude uses a mandatory structured response format, and convergence signals guide the user on when to stop. Final output is optionally written to memory as a decision record.

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
| **Codex** | OpenAI | `gpt-5.3-codex` (xhigh reasoning) | `-m {model}` | `codex exec --full-auto -C {dir} -o {file} "{prompt}"` |
| **Gemini** | Google | `gemini-3-pro-preview` | `-m {model}` | `gemini -p "{prompt}" -o text --yolo > {file}` |
| **Kimi** | Moonshot | `kimi-code/kimi-for-coding` (thinking + tool access) | `-m {model}` | `kimi -w {dir} --quiet -p "{prompt}" > {file}` |

### CLI Notes

**Kimi:**
- `--quiet` = `--print --output-format text --final-message-only` — clean text output, no SDK logs
- **WITHOUT `--quiet`, `--print` dumps raw Python SDK logs (TextPart, ThinkPart, ToolCall objects) — NEVER use `--print` alone**
- `-w` flag MUST come before `-p` flag (argument parsing order matters)
- Default model `kimi-code/kimi-for-coding` has codebase tool access (read files, search, shell) — it can independently verify code references
- Alternative `fireworks/kimi-k2p5` is pure reasoning without tool access — only use if user explicitly requests it
- Do NOT pass `-m` flag unless user overrides — CLI default from `~/.kimi/config.toml` is correct
- Install: `uv tool install kimi-cli` or `pip install kimi-cli`

**Codex:**
- Writes output directly to file via `-o` flag
- Has full codebase access via `-C` working directory

**Gemini:**
- Output via stdout redirect `> {file}`
- `--yolo` enables auto-approve mode

### Prompt Delivery

**CRITICAL:** For all CLIs, write the prompt to a temp file first and read it via `$(cat /tmp/ai-debate-prompt.txt)` to avoid shell quoting issues with long prompts:

```bash
# Write prompt to file first
cat <<'PROMPT_EOF' > /tmp/ai-debate-prompt.txt
{full prompt content here}
PROMPT_EOF

# Then use in CLI command
kimi -w "{dir}" --quiet -p "$(cat /tmp/ai-debate-prompt.txt)" > {file}
codex exec --full-auto -C "{dir}" -o {file} "$(cat /tmp/ai-debate-prompt.txt)"
gemini -p "$(cat /tmp/ai-debate-prompt.txt)" -o text --yolo > {file}
```

### Timeout Handling

macOS does not have `timeout` by default. Do NOT use `timeout` in commands. Instead:
- Run CLI commands with Bash tool's built-in timeout parameter (set to 300000ms)
- If a CLI hangs, the Bash tool timeout will kill it

### Model Detection

Before the debate starts, detect which model will be used:

```bash
# Codex: read from config
grep '^model' ~/.codex/config.toml 2>/dev/null

# Gemini: default is gemini-2.5-pro unless overridden
# Kimi: read from config
grep '^default_model' ~/.kimi/config.toml 2>/dev/null
```

If `{MODEL}` argument is provided, append `-m {MODEL}` to the CLI command.
If not provided, use the CLI's configured default.

**IMPORTANT:** Always report the model used in every round header:

```
## Round {N} — {AI_NAME} ({model_name})
```

And in the final synthesis metadata line.

## Language Rules

- **All output to user in English** — round presentations, questions, synthesis, convergence signals
- **AskUserQuestion options in English**
- **Inter-AI communication (prompts) in English** — all CLIs perform better in English
- **Other AI's responses may be in English** — Claude summarizes/presents in English

## Topic Resolution

If `{TOPIC}` argument is empty or not provided:
1. Analyze the current conversation context
2. Identify the most recent task, problem, or decision being worked on
3. Formulate a specific technical question from that context
4. Present: "Let me ask about the current topic: **{auto-detected topic}**"
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

### Step 0: Select AI & Detect Environment

**Detect available CLIs:**
```bash
which codex 2>/dev/null && echo "codex:available"
which gemini 2>/dev/null && echo "gemini:available"
which kimi 2>/dev/null && echo "kimi:available"
```

**Collect git metadata:**
```bash
git rev-parse --abbrev-ref HEAD 2>/dev/null
git rev-parse --short HEAD 2>/dev/null
```

**Ask user:**
- "Which AI should we debate with?" with options from available CLIs:
  - "Codex (OpenAI)"
  - "Gemini (Google)"
  - "Kimi (Moonshot)"
  - "Ask all (parallel)"

---

### Round 1: Opening

**Step 1a: Build context file**

Write to `/tmp/ai-debate-context.md`:

```markdown
## Session Context

Working Directory: {WORKING_DIR}
Project: {project name from CLAUDE.md or Cargo.toml}
Branch: {git branch}
Commit: {git short hash}
Mode: {MODE or "default"}

### Current Session Summary
{Brief summary of what's been discussed/worked on}

### Constraints & Decisions Already Made
{Any relevant constraints}

### Question
{TOPIC}
```

**Step 1b: Build role-augmented prompt**

```
{ROLE_PROMPT if MODE != default, else ""}

You have access to the full codebase in the current directory.

Session context:
{content of /tmp/ai-debate-context.md}

Question: {TOPIC}

Analyze thoroughly. Reference specific files and line numbers. Provide concrete recommendations with trade-offs.
```

**Step 1c: Send to selected AI CLI**

First, write the full prompt to `/tmp/ai-debate-prompt.txt` (avoids shell quoting issues).

**Codex:** (append `-m {MODEL}` only if model argument provided)
```bash
codex exec --full-auto -C "{WORKING_DIR}" -o /tmp/ai-debate-response.md [-m "{MODEL}"] "$(cat /tmp/ai-debate-prompt.txt)"
```
Use Bash tool with `timeout: 300000`.

**Gemini:** (append `-m {MODEL}` only if model argument provided)
```bash
gemini -p "$(cat /tmp/ai-debate-prompt.txt)" -o text --yolo [-m "{MODEL}"] > /tmp/ai-debate-response.md
```
Use Bash tool with `timeout: 300000`.

**Kimi:** (append `-m {MODEL}` only if user explicitly overrides model)
```bash
kimi -w "{WORKING_DIR}" --quiet [-m "{MODEL}"] -p "$(cat /tmp/ai-debate-prompt.txt)" > /tmp/ai-debate-response.md
```
Use Bash tool with `timeout: 300000`. Note: `-w` MUST come before `-p`. Default model `kimi-code/kimi-for-coding` has tool access and will independently browse the codebase.

**Step 1d: Read response, save as `/tmp/ai-round-1.md`**

**Step 1e: Present Round 1 with MANDATORY FORMAT**

```
## Round 1 — {AI_NAME} ({model_name})

### {AI_NAME}'s Position:
{Summary/presentation of the other AI's response}

### Claude's Counter-Position:

**Points of Agreement:**
- …

**Points of Disagreement:**
- …

**Concessions Made:**
- (None yet in Round 1)

**New Risks / Questions:**
- …

### Convergence Signal:
🟢 New information present — debate is productive.
```

Save Claude's response to `/tmp/claude-round-1.md`.

**Step 1f: Ask user**

- "Should we continue the debate?" with options:
  - "Continue — send Claude's critique back"
  - "Enough — summarize results"
  - "Change direction" with sub-options:
    - "From a performance perspective"
    - "From a security perspective"
    - "From a simplicity perspective"

---

### Round N (N >= 2): Context-Compressed Continuation

**CRITICAL: Context Compression Protocol**

Before sending Round N, Claude MUST produce a Debate State summary. This prevents prompt bloat and quality degradation.

**Step Na: Generate Debate State**

```markdown
## Debate State (End of Round {N-1})

Established Facts:
- {fact 1}
- {fact 2}

Points of Agreement:
- {agreement 1}

Still Disputed Areas:
- {dispute 1}

Consciously Rejected Approaches:
- {rejected 1} — Reason: {reason}
```

Save to `/tmp/debate-state-{N-1}.md`.

**Step Nb: Send compressed prompt to AI**

ONLY send:
1. The Debate State (NOT full history)
2. Claude's last challenge

```
This is round {N} of a technical debate.

{ROLE_PROMPT if MODE != default}

Original question: {TOPIC}

Debate state (compressed summary of all previous rounds):
{content of /tmp/debate-state-{N-1}.md}

Claude's latest challenge:
{content of /tmp/claude-round-{N-1}.md}

Respond to Claude's points. Defend where you're right, concede where Claude is right. Add new insights. Reference specific code. Do NOT repeat already-agreed points.
```

Save response to `/tmp/ai-round-{N}.md`.

**Step Nc: Present Round N with MANDATORY FORMAT**

```
## Round {N} — {AI_NAME} ({model_name})

### {AI_NAME}'s Response:
{Presentation of response}

### Claude's Counter-Position:

**Points of Agreement:**
- …

**Points of Disagreement:**
- …

**Concessions Made:**
- …

**New Risks / Questions:**
- …

### Convergence Signal:
{One of:}
🟢 New technical arguments this round — debate is productive.
🟡 Few new arguments — convergence beginning. One more round may be sufficient.
🔴 No new information generated this round. Continuing risks repetition. Recommend summarizing.
```

Save Claude's response to `/tmp/claude-round-{N}.md`.

**Step Nd: Ask user**

Same options: Continue / Enough / Change direction

---

### "Ask All" Mode

If user selected "Ask all (parallel)":

1. Run ALL available CLIs in parallel with the same prompt
2. Present comparative analysis:

```
## Comparative Analysis

### Codex (OpenAI) Says:
{summary — max 5 bullets}

### Gemini (Google) Says:
{summary — max 5 bullets}

### Kimi (Moonshot) Says:
{summary — max 5 bullets}

### Claude's Assessment:

**Where all three agree:**
- …

**Important differences:**
- …

**Strongest argument (from whom):**
- …
```

Then ask: "Would you like to continue a detailed debate with any of them?"

---

### Final: Synthesis + Memory Write-Back

When user says "Enough":

**Step F1: Generate synthesis**

```
## Debate Summary: {TOPIC}

**Branch:** {branch} @ {commit}
**AI:** {AI_NAME} | **Model:** {model_name} | **Mode:** {MODE} | **Round count:** {N}

### Points of Agreement
{Points where both AIs agreed}

### Unresolved Disagreements
{Areas where they still differ — both perspectives}

### Rejected Alternatives
{Approaches consciously rejected during debate and reasons}

### Recommended Action
{Claude's recommended concrete steps after evaluating entire debate}

### Key Contribution from {AI_NAME}
{The most valuable point raised by the other AI that Claude wouldn't have thought of alone}
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

## Debate Detail

### Round 1 — {AI_NAME} ({model_name})

#### {AI_NAME}'s Position:
{Other AI's FULL response — do not truncate, include original output verbatim}

#### Claude's Counter-Position:

**Points of Agreement:**
{full list}

**Points of Disagreement:**
{full list}

**Concessions Made:**
{full list}

**New Risks / Questions:**
{full list}

**Convergence Signal:** {🟢/🟡/🔴 + explanation}

---

### Round 2 — {AI_NAME} ({model_name})

{Same format — other AI's FULL response + Claude's structured response}

---

{... all rounds ...}

---

## Final Debate State

{Content of final debate-state file — established facts, agreements, disputed areas, rejected approaches}
```

**IMPORTANT:** Write other AI's responses in FULL, WITHOUT TRUNCATION. This file is the only permanent record of the debate — readers should be able to see all arguments.

**Step F3: Offer memory write-back**

Ask user:
- "Would you also like to save this decision to memory?" with options:
  - "Yes — also save to memory"
  - "No — docs/ is sufficient"

If yes, write to memory plugin as decision:

```bash
cat <<'EOF' > /tmp/debate-decision.json
{
  "type": "decision",
  "title": "AI Debate: {TOPIC_SHORT}",
  "content": "## Decision\n{recommended action}\n\n## Rationale\n{rationale}\n\n## Rejected Alternatives\n{rejected}\n\n## Source\nAI Debate — {AI_NAME} ({MODE}) — {N} rounds — {branch}@{commit}\nDocs: docs/debates/{filename}",
  "tags": ["debate", "{MODE}", "{AI_NAME}"]
}
EOF
cat /tmp/debate-decision.json | memory write
```

**Step F4: Clean up**

```bash
rm -f /tmp/ai-debate-context.md /tmp/ai-debate-response.md /tmp/ai-round-*.md /tmp/claude-round-*.md /tmp/debate-state-*.md
```

---

## File Management

| File | Content | Lifecycle |
|------|---------|-----------|
| `/tmp/ai-debate-context.md` | Initial session context + git metadata | Created once |
| `/tmp/ai-round-{N}.md` | Other AI's response in round N | Per round |
| `/tmp/claude-round-{N}.md` | Claude's structured response in round N | Per round |
| `/tmp/debate-state-{N}.md` | Compressed debate state after round N | Per round, replaces previous |
| `/tmp/ai-debate-response.md` | Latest raw CLI output (working file) | Overwritten each round |

## Error Handling

| Error | Action |
|-------|--------|
| CLI not found | "This CLI is not installed. Installation: {install command}" |
| Auth failure | "You need to log in: {login command}" |
| Timeout (>5min) | Show partial output if available, suggest retry |
| Empty response | Retry once with simpler prompt, then skip |

Install commands:
- Codex: `npm install -g @openai/codex` → `codex login`
- Gemini: `npm install -g @anthropic-ai/gemini-cli` → first run auth
- Kimi: `uv tool install kimi-cli` or `pip install kimi-cli` → `kimi login`

## Design Principles

1. **Context compression > full history** — Round 3+ never sends full history, only Debate State + last challenge
2. **Format > intent** — Saying "be honest" isn't enough. Mandatory structured format (Agreement/Disagreement/Concession/Risks) breaks defensive reflexes
3. **Convergence signal > infinite loop** — Claude reports debate productivity each round with 🟢/🟡/🔴
4. **Memory write-back > one-off** — Decisions are written to organizational memory, same debate won't repeat
5. **Role presets > generic prompt** — security/performance/simplicity/devil modes increase debate quality 2x
6. **Git metadata > floating context** — branch + commit hash makes debate reproducible
