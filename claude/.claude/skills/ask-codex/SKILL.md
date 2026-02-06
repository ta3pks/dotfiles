---
name: ask-codex
description: Use when you need a second opinion on architecture decisions, code review, debugging strategies, or implementation approaches - consults OpenAI Codex CLI (gpt-5.3-codex with very high reasoning)
---

# Ask Codex

## Overview

Consult OpenAI Codex (gpt-5.3-codex with very high reasoning) for a second opinion using the CLI. Useful for validating approaches, catching edge cases, and getting fresh perspectives on complex decisions.

## When to Use

- Architecture decisions with multiple valid approaches
- Code review before committing complex changes
- Debugging when stuck or unsure of root cause
- Implementation plan review
- Validating assumptions about unfamiliar APIs/libraries

## CLI Usage

```bash
codex exec -m gpt-5.3-codex "Your question or prompt here"
```

**Default Model:** `gpt-5.3-codex` (very high reasoning capability)

**Key Options:**
- `exec`: Run non-interactively (required for scripted use)
- `-m, --model <MODEL>`: Specify model (default: gpt-5.3-codex)
- `-o, --output-last-message <FILE>`: Write response to file
- `--json`: Output as JSONL for parsing

**For code review specifically:**
```bash
codex review
```

## Quick Reference

| Scenario | Example Command |
|----------|----------------|
| Architecture review | `codex exec "Review this approach for [X]. What edge cases am I missing?"` |
| Code review | `codex review` or `codex exec "Review this code: [snippet]"` |
| Debugging | `codex exec "I'm seeing [symptom]. I've tried [X]. What else should I check?"` |
| Implementation plan | `codex exec "Review this plan: [paste plan]. What issues do you see?"` |

## Best Practices

**Provide context:**
- Include relevant code snippets
- Explain what you've already considered
- State your constraints clearly

**Ask specific questions:**
- "What edge cases am I missing?" vs "Is this good?"
- "What would break if X happens?" vs "Any problems?"

**Example - Architecture Decision:**

```bash
codex exec -m gpt-5.3-codex "I'm implementing WebSocket connection limiting in Cloudflare Durable Objects.

Option A: Track connections in a separate Map, sync on hibernation
Option B: Derive connections on-demand from existing connections Map

Which approach handles hibernation wake-up better? What edge cases should I consider?"
```

**Example - Code Review:**

```bash
codex exec -m gpt-5.3-codex "Review this eviction logic for race conditions:

\`\`\`typescript
const userSockets = this.getUserSockets(userId);
while (userSockets.length > MAX_CONNECTIONS) {
  const oldest = userSockets.shift();
  oldest.close(4001, 'Connection replaced');
}
\`\`\`

The getUserSockets() returns a copy of the array. Is there a race condition?"
```

**Example - Using Built-in Code Review:**

```bash
# Review current repository changes
codex review
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Vague questions | Be specific about what you want reviewed |
| No context | Include code, constraints, what you've tried |
| Asking yes/no | Ask "what issues" or "what edge cases" |
| Ignoring response | Evaluate critically, Codex can be wrong too |

## Integration with Workflow

Use ask-codex at key decision points:
1. **Before implementing:** Validate approach
2. **After implementing:** Review for issues with `codex review`
3. **When stuck:** Get fresh debugging perspective
4. **Before committing:** Final sanity check on complex changes
