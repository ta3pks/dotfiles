# Roadmap: Dotfiles Repository

## Overview

Transform a mature but undocumented dotfiles repository into a well-documented, secure, and easily reproducible development environment. The journey starts with security (ensuring no secrets are exposed), then documents the existing structure, and finally adds automation for one-command setup.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Security Audit** - Remove secrets and establish protection patterns
- [ ] **Phase 2: Documentation & Organization** - Document structure and symlink strategy
- [ ] **Phase 3: Bootstrap Automation** - Create idempotent setup script

## Phase Details

### Phase 1: Security Audit
**Goal**: Repository is free of secrets and protected against future credential exposure
**Depends on**: Nothing (first phase)
**Requirements**: SEC-01, SEC-02, SEC-03
**Success Criteria** (what must be TRUE):
  1. User can scan repository and find no hardcoded secrets in version control
  2. User can verify all common secret patterns are covered by .gitignore
  3. User can reference a documented strategy for handling sensitive values (env vars, credential files)
**Plans**: TBD

Plans:
- [ ] 01-01: Audit repository for secrets and sensitive data
- [ ] 01-02: Update .gitignore with comprehensive secret patterns
- [ ] 01-03: Document secret handling strategy

### Phase 2: Documentation & Organization
**Goal**: Users can understand, navigate, and verify the repository structure
**Depends on**: Phase 1
**Requirements**: DOC-01, DOC-02, DOC-03, ORG-01, ORG-02, ORG-03
**Success Criteria** (what must be TRUE):
  1. User can install dotfiles by following README instructions without guessing
  2. User can quickly locate any tool's configuration by reading the structure documentation
  3. User can verify prerequisites are installed before running setup
  4. User can understand the XDG-compliant symlink strategy used
**Plans**: TBD

Plans:
- [ ] 02-01: Create comprehensive README with installation instructions
- [ ] 02-02: Document repository structure and per-tool directories
- [ ] 02-03: Document symlink strategy and XDG compliance

### Phase 3: Bootstrap Automation
**Goal**: Users can set up their complete environment with a single command
**Depends on**: Phase 2
**Requirements**: AUTO-01, AUTO-02, AUTO-03
**Success Criteria** (what must be TRUE):
  1. User can run `./bootstrap.sh` and complete setup without errors
  2. User can verify all expected symlinks exist in correct locations after bootstrap
  3. User can run bootstrap script multiple times safely without duplicate or broken symlinks
**Plans**: TBD

Plans:
- [ ] 03-01: Create bootstrap script with symlink creation
- [ ] 03-02: Add idempotency and error handling
- [ ] 03-03: Test bootstrap on fresh environment

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Security Audit | 0/3 | Not started | - |
| 2. Documentation & Organization | 0/3 | Not started | - |
| 3. Bootstrap Automation | 0/3 | Not started | - |

---
*Roadmap created: 2026-03-08*
*Depth: quick (3 phases)*
*Coverage: 12/12 requirements mapped*
