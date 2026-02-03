---
name: ask-opencode
description: Use when you need a second opinion on architecture decisions, code review, debugging strategies, or implementation approaches - consults opencode AI via CLI
---

# Ask Opencode

## Overview

Consult opencode AI for a second opinion using the CLI. Useful for validating approaches, catching edge cases, and getting fresh perspectives on complex decisions.

## When to Use

- Architecture decisions with multiple valid approaches
- Code review before committing complex changes
- Debugging when stuck or unsure of root cause
- Implementation plan review
- Validating assumptions about unfamiliar APIs/libraries

## CLI Usage

```bash
opencode run "Your question or prompt here"
```

**Common flags:**
- `-m provider/model`: Specify model (e.g., `-m anthropic/claude-sonnet-4-20250514`)
- `-f file`: Attach file(s) for context
- `-c`: Continue last session
- `-s session_id`: Continue specific session
- `--format json`: Output raw JSON events (for parsing)
- `--agent name`: Use specific agent

## Quick Reference

| Scenario | Example Command |
|----------|-----------------|
| Simple question | `opencode run "Review this approach for X"` |
| With file context | `opencode run -f src/module.ts "Review this code"` |
| Specific model | `opencode run -m anthropic/claude-sonnet-4-20250514 "question"` |
| Continue session | `opencode run -c "follow-up question"` |

## Best Practices

**Provide context:**
- Use `-f` flag to attach relevant files
- Include code snippets in the prompt
- State constraints and what you've already considered

**Ask specific questions:**
- "What edge cases am I missing?" vs "Is this good?"
- "What would break if X happens?" vs "Any problems?"

**Example - Architecture Decision:**

```bash
opencode run "I'm implementing WebSocket connection limiting in Cloudflare Durable Objects.

Option A: Track connections in a separate Map, sync on hibernation
Option B: Derive connections on-demand from existing connections Map

Which approach handles hibernation wake-up better? What edge cases should I consider?"
```

**Example - Code Review with File:**

```bash
opencode run -f src/ws/connection-manager.ts "Review this code for race conditions and edge cases. Focus on the eviction logic."
```

**Example - Plan Review:**

```bash
opencode run -f docs/plans/feature-plan.md "Review this implementation plan. What issues do you see? What's missing?"
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Vague questions | Be specific about what you want reviewed |
| No context | Use `-f` to attach files or include snippets |
| Asking yes/no | Ask "what issues" or "what edge cases" |
| Ignoring response | Evaluate critically, AI can be wrong too |

## Integration with Workflow

Use ask-opencode at key decision points:
1. **Before implementing:** Validate approach
2. **After implementing:** Review for issues
3. **When stuck:** Get fresh debugging perspective
4. **Before committing:** Final sanity check on complex changes
