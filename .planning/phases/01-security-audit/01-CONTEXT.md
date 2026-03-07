# Phase 1: Security Audit - Context

**Gathered:** 2026-03-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Repository is free of secrets and protected against future credential exposure. This phase audits existing content, establishes protection patterns, and documents how secrets should be handled going forward.

</domain>

<decisions>
## Implementation Decisions

### Secret Detection Scope

- Scan for: API keys, tokens, passwords, private keys (SSH, GPG)
- Include AI tool configs in scan (OpenCode, Aider - identified as risk vectors)
- Include environment files (.env, .env.*)
- Include shell history files
- Include credential files (credentials.json, secrets.yaml, etc.)
- Exclude: public keys, known-safe files

### Gitignore Coverage

- Standard patterns: `*_API_KEY`, `*_TOKEN`, `*_PASSWORD`, `*_SECRET`
- AI tool patterns: `.config/opencode/` (may contain API keys), `.aider*`
- Shell history: `.bash_history`, `.zsh_history`, `.local/share/history/`
- Environment files: `.env`, `.env.*`, `*.env`
- SSH keys: `.ssh/id_rsa*` (exclude private), `.ssh/*.pem`
- Browser data: Already in repo-level gitignore

### Secret Handling Strategy

- Document in README: Use environment variables for secrets
- Template files: Provide `.env.example` with placeholder values
- No secrets in version control: Secrets managed externally (password manager, system env vars)
- Audit frequency: Run on every commit (pre-commit hook or manual)

### Claude's Discretion

- Exact tool choice for secret scanning (gitleaks, trufflehog, or manual grep)
- Pre-commit hook implementation details
- Specific .gitignore pattern ordering

</decisions>

<specifics>
## Specific Ideas

- Research identified AI tool configs (OpenCode, Aider) as a growing risk vector for credential exposure
- Project changelog shows "remove credentials" in 2024-12-04 - evidence of past exposure
- Use `.env.example` pattern for documenting required environment variables

</specifics>

<deferred>
## Deferred Ideas

None - discussion stayed within phase scope

</deferred>

---

*Phase: 01-security-audit*
*Context gathered: 2026-03-08*
