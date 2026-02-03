---
name: ask-kimi
description: Use when you need a second opinion on architecture decisions, code review, debugging strategies, or implementation approaches - consults Kimi AI via CLI
---

# Ask Kimi

## Overview

Consult Kimi AI for a second opinion using the CLI. Useful for validating approaches, catching edge cases, and getting fresh perspectives on complex decisions.

## When to Use

- Architecture decisions with multiple valid approaches
- Code review before committing complex changes
- Debugging when stuck or unsure of root cause
- Implementation plan review
- Validating assumptions about unfamiliar APIs/libraries

## CLI Usage

```bash
kimi --print -p "Your question or prompt here"
```

**Flags:**
- `--print` or `-P`: Output response to stdout (required for capturing output)
- `-p "prompt"`: The question or context to send

## Quick Reference

| Scenario | Example Prompt |
|----------|----------------|
| Architecture review | "Review this approach for [X]. What edge cases am I missing?" |
| Code review | "Review this code for [file]. Focus on [bugs/performance/security]." |
| Debugging | "I'm seeing [symptom]. I've tried [X]. What else should I check?" |
| Implementation plan | "Review this plan: [paste plan]. What issues do you see?" |

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
kimi --print -p "I'm implementing WebSocket connection limiting in Cloudflare Durable Objects.

Option A: Track connections in a separate Map, sync on hibernation
Option B: Derive connections on-demand from existing connections Map

Which approach handles hibernation wake-up better? What edge cases should I consider?"
```

**Example - Code Review:**

```bash
kimi --print -p "Review this eviction logic for race conditions:

\`\`\`typescript
const userSockets = this.getUserSockets(userId);
while (userSockets.length > MAX_CONNECTIONS) {
  const oldest = userSockets.shift();
  oldest.close(4001, 'Connection replaced');
}
\`\`\`

The getUserSockets() returns a copy of the array. Is there a race condition?"
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Vague questions | Be specific about what you want reviewed |
| No context | Include code, constraints, what you've tried |
| Asking yes/no | Ask "what issues" or "what edge cases" |
| Ignoring response | Evaluate critically, Kimi can be wrong too |

## Integration with Workflow

Use ask-kimi at key decision points:
1. **Before implementing:** Validate approach
2. **After implementing:** Review for issues
3. **When stuck:** Get fresh debugging perspective
4. **Before committing:** Final sanity check on complex changes
