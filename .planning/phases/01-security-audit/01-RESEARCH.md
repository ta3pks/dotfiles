# Phase 1: Security Audit - Research

**Researched:** 2026-03-08
**Domain:** Secret detection, git security, credential management
**Confidence:** HIGH

## Summary

This phase addresses security audit for a personal dotfiles repository. The goal is to ensure no hardcoded secrets exist in version control and establish protection patterns for future development. Research covers secret scanning tools (gitleaks, trufflehog), .gitignore best practices for secret patterns, and secret handling strategies for dotfiles.

**Primary recommendation:** Use gitleaks for scanning (lighter weight, good defaults) combined with comprehensive .gitignore patterns and environment variable-based secret management.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **Secret Detection Scope:**
  - Scan for: API keys, tokens, passwords, private keys (SSH, GPG)
  - Include AI tool configs in scan (OpenCode, Aider - identified as risk vectors)
  - Include environment files (.env, .env.*)
  - Include shell history files
  - Include credential files (credentials.json, secrets.yaml, etc.)
  - Exclude: public keys, known-safe files

- **Gitignore Coverage:**
  - Standard patterns: `*_API_KEY`, `*_TOKEN`, `*_PASSWORD`, `*_SECRET`
  - AI tool patterns: `.config/opencode/` (may contain API keys), `.aider*`
  - Shell history: `.bash_history`, `.zsh_history`, `.local/share/history/`
  - Environment files: `.env`, `.env.*`, `*.env`
  - SSH keys: `.ssh/id_rsa*` (exclude private), `.ssh/*.pem`
  - Browser data: Already in repo-level gitignore

- **Secret Handling Strategy:**
  - Document in README: Use environment variables for secrets
  - Template files: Provide `.env.example` with placeholder values
  - No secrets in version control: Secrets managed externally (password manager, system env vars)
  - Audit frequency: Run on every commit (pre-commit hook or manual)

### Claude's Discretion

- Exact tool choice for secret scanning (gitleaks, trufflehog, or manual grep)
- Pre-commit hook implementation details
- Specific .gitignore pattern ordering

### Deferred Ideas (OUT OF SCOPE)

None - discussion stayed within phase scope

</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SEC-01 | No hardcoded secrets in version control | Gitleaks/trufflehog scanning + manual verification patterns |
| SEC-02 | `.gitignore` covers all secret patterns | Comprehensive pattern library from industry best practices |
| SEC-03 | Secret handling strategy documented | Environment variable patterns + .env.example template approach |
</phase_requirements>

## Standard Stack

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| gitleaks | v8.30.0+ | Secret scanning | 25.3k stars, actively maintained, pre-commit integration, fast |
| git | any | Version control hooks | Native pre-commit support |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| trufflehog | v3.56.0+ | Deep credential verification | When active API validation needed (800+ detectors) |
| pre-commit | 3.0+ | Hook management | Optional - if automated scanning desired |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| gitleaks | trufflehog | TruffleHog has active verification (calls APIs) but heavier; gitleaks is regex-based, faster, sufficient for dotfiles |
| pre-commit hook | manual scan | Manual gives control; pre-commit ensures consistency but adds friction |
| gitleaks | detect-secrets | detect-secrets is Python-based; gitleaks is Go binary, easier install |

**Installation:**
```bash
# MacOS
brew install gitleaks

# Linux (binary)
curl -sSfL https://github.com/gitleaks/gitleaks/releases/download/v8.30.0/gitleaks_8.30.0_linux_x64.tar.gz | tar -xz -C /usr/local/bin

# Optional: pre-commit integration
pip install pre-commit
```

## Architecture Patterns

### Recommended Project Structure
```
dotfiles/
├── .gitignore              # Root-level secret patterns (CRITICAL)
├── .gitleaks.toml          # Custom gitleaks config (optional)
├── .env.example            # Template for environment variables
├── README.md               # Document secret handling strategy
├── opencode/               # AI tool configs (HIGH RISK - check for API keys)
├── zsh/                    # Shell configs (check for embedded secrets)
└── [other tool dirs]/
```

### Pattern 1: Gitleaks Repository Scan
**What:** Scan entire git history for secrets
**When to use:** Initial audit, periodic verification
**Example:**
```bash
# Full repository scan
gitleaks git --verbose --report-path gitleaks-report.json

# Scan specific directory
gitleaks dir --verbose ./

# Pre-commit scan (staged files only)
gitleaks git --staged --verbose
```

### Pattern 2: .gitignore Secret Patterns
**What:** Prevent future secret commits
**When to use:** Always - defense in depth
**Example:**
```gitignore
# Secrets - NEVER commit these
*_API_KEY
*_TOKEN
*_PASSWORD
*_SECRET
*_PRIVATE_KEY

# Environment files
.env
.env.*
*.env

# AI tool configs (may contain API keys)
.config/opencode/*.json
.aider*

# Shell history (may contain secrets in commands)
.bash_history
.zsh_history
.local/share/history/

# SSH private keys
.ssh/id_rsa*
.ssh/*.pem
id_ed25519
id_ecdsa

# Credential files
credentials.json
secrets.yaml
secrets.yml
*.pem
*.key

# Browser data (already covered but explicit)
*Brave*
*Keybase*
```

### Pattern 3: Environment Variable Strategy
**What:** Externalize all secrets to environment
**When to use:** Any configuration requiring secrets
**Example:**
```bash
# .env.example (committed to repo)
OPENAI_API_KEY=your_key_here
ANTHROPIC_API_KEY=your_key_here
GITHUB_TOKEN=your_token_here

# Actual usage (in shell config)
export OPENAI_API_KEY="${OPENAI_API_KEY:-$(pass show openai/api-key)}"
```

### Anti-Patterns to Avoid
- **Hardcoding secrets in configs:** Use environment variables or external credential stores
- **Committing .env files:** Only commit .env.example templates
- **Relying solely on .gitignore:** Combine with active scanning (gitleaks)
- **Ignoring AI tool configs:** OpenCode, Aider configs are high-risk vectors for API keys

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Secret detection regex | Custom grep patterns | gitleaks | 100+ built-in patterns, entropy detection, active maintenance |
| Pre-commit hook logic | Shell script | gitleaks pre-commit hook | Handles edge cases, binary scanning, encoding detection |
| Secret validation | API call scripts | trufflehog (if needed) | 800+ detectors with active verification |
| Git history scanning | Manual git log review | gitleaks git command | Scans all commits, patches, handles binary files |

**Key insight:** Secret detection is a solved problem with mature tools. Custom solutions miss edge cases and patterns.

## Common Pitfalls

### Pitfall 1: False Sense of Security from .gitignore
**What goes wrong:** .gitignore only prevents future commits, doesn't scan existing history
**Why it happens:** Developers assume .gitignore = clean repo
**How to avoid:** Run gitleaks on full git history, not just current files
**Warning signs:** No secret scanning in CI/CD, .gitignore added after commits

### Pitfall 2: AI Tool Config Exposure
**What goes wrong:** OpenCode, Aider, Claude configs often contain API keys
**Why it happens:** AI tools store credentials for convenience
**How to avoid:** Explicitly ignore AI tool config directories, use environment variables
**Warning signs:** `opencode.json` with `apiKey` field, `.aider.conf.yml` with tokens

### Pitfall 3: Shell History Leakage
**What goes wrong:** Commands with secrets (e.g., `export API_KEY=sk-...`) saved to history
**Why it happens:** Shell saves all commands by default
**How to avoid:** Add history files to .gitignore, use `setopt HIST_IGNORE_SPACE` in zsh
**Warning signs:** `.zsh_history` or `.bash_history` in repo

### Pitfall 4: Entropy-Based False Negatives
**What goes wrong:** Low-entropy secrets (like short tokens) missed by scanners
**Why it happens:** Scanners use entropy thresholds to reduce noise
**How to avoid:** Combine automated scanning with manual review of config files
**Warning signs:** Scanner passes but config review finds suspicious values

## Code Examples

### Gitleaks Configuration (Optional)
```toml
# .gitleaks.toml - Custom rules for dotfiles
title = "Dotfiles Secret Detection"

[extend]
useDefault = true

[[rules]]
id = "dotfiles-ai-api-key"
description = "AI Tool API Key"
regex = '''(?i)(openai|anthropic|claude|gemini)_(api_?key|token)\s*[=:]\s*['"]?[a-zA-Z0-9_-]{20,}['"]?'''
tags = ["ai", "api-key"]

[[allowlists]]
description = "Allow example placeholders"
regexes = ['''your_key_here''', '''sk-xxx''', '''placeholder''']
```

### Pre-Commit Hook (Optional)
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.30.0
    hooks:
      - id: gitleaks
```

### Manual Scan Script
```bash
#!/bin/bash
# scan-secrets.sh - Run secret scan

echo "Running gitleaks scan..."
gitleaks git --verbose --report-path gitleaks-report.json

if [ $? -eq 0 ]; then
    echo "✓ No secrets detected"
    rm gitleaks-report.json
else
    echo "✗ Secrets found! Review gitleaks-report.json"
    exit 1
fi
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual grep patterns | Gitleaks/trufflehog | 2017+ | Automated detection, 100+ patterns |
| Commit then scan | Pre-commit hooks | 2018+ | Prevention over detection |
| Regex-only detection | Entropy + regex | 2019+ | Catches obfuscated/random secrets |
| Local-only scanning | CI/CD integration | 2020+ | Continuous monitoring |

**Deprecated/outdated:**
- **trufflehog v2:** Replaced by v3 with Go rewrite, active verification
- **Custom regex scripts:** Gitleaks covers more patterns, maintained

## Open Questions

1. **Should we use pre-commit hooks or manual scanning?**
   - What we know: Pre-commit ensures consistency, manual gives control
   - What's unclear: User preference for workflow friction
   - Recommendation: Start with manual scanning, add pre-commit if desired

2. **How to handle existing secrets in git history?**
   - What we know: Changelog shows "remove credentials" in 2024-12-04
   - What's unclear: Whether history was rewritten (BFG/git-filter-repo)
   - Recommendation: Scan full history, use `git filter-branch` or BFG if needed

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Shell scripts (bash) |
| Config file | None - simple exit codes |
| Quick run command | `gitleaks git --verbose` |
| Full suite command | `gitleaks git --verbose --report-path report.json` |
| Estimated runtime | ~5-10 seconds |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SEC-01 | No hardcoded secrets in version control | integration | `gitleaks git --verbose` | ❌ Wave 0 gap |
| SEC-02 | .gitignore covers secret patterns | unit | `grep -f .gitignore secret-patterns.txt` | ❌ Wave 0 gap |
| SEC-03 | Secret handling strategy documented | manual | N/A - README review | ❌ Wave 0 gap |

### Nyquist Sampling Rate
- **Minimum sample interval:** After every .gitignore or config file change → run: `gitleaks dir --verbose`
- **Full suite trigger:** Before completing Phase 1
- **Phase-complete gate:** Gitleaks scan returns exit code 0 (no secrets)
- **Estimated feedback latency per task:** ~5 seconds

### Wave 0 Gaps (must be created before implementation)
- [ ] `scripts/scan-secrets.sh` — automated gitleaks wrapper for SEC-01
- [ ] `tests/test_gitignore_patterns.sh` — verify .gitignore covers known patterns for SEC-02
- [ ] No framework install needed — uses existing gitleaks binary

*(Note: SEC-03 is documentation-only, verified by manual review)*

## Sources

### Primary (HIGH confidence)
- https://github.com/gitleaks/gitleaks - Official gitleaks repository, README, v8.30.0
- https://github.com/trufflesecurity/trufflehog - TruffleHog repository for comparison

### Secondary (MEDIUM confidence)
- .planning/phases/01-security-audit/01-CONTEXT.md - User decisions and constraints
- .planning/REQUIREMENTS.md - Phase requirements SEC-01, SEC-02, SEC-03
- CHANGELOG.md - Evidence of past credential exposure (2024-12-04)

### Tertiary (LOW confidence)
- Web search for gitignore best practices (common knowledge, not verified)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Gitleaks and trufflehog are well-documented, actively maintained
- Architecture: HIGH - Patterns are straightforward, well-established in industry
- Pitfalls: HIGH - Based on common security incidents and tool documentation

**Research date:** 2026-03-08
**Valid until:** 2026-06-08 (3 months - tools stable, patterns long-term)
