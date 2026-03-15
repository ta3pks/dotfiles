# Testing Patterns

**Analysis Date:** 2026-03-07

## Test Framework

**Runner:**
- Not applicable - dotfiles repositories don not have traditional test frameworks
- Remote Rust testing via `remote_test.sh` script
- TPM includes shell-based tests

**Assertion Library:**
- Shell: Built-in test assertions (`[` ... ] } `)

**Run Commands:**
```bash
# Run all tests
cargo test

# Run tests on remote machine (REDACTED_PROJECT)
~/.local/bin/remote_test.sh --nocapture $@
```

```

# Watch mode
cargo test --watch
# Coverage
cargo tarpaul --html-report report=text --json

```

# Test file Organization

**Location:**
- Co-located with source files
- External in `tests/` directories

- Rust: separate test directory

**Naming:**
- Shell: `test_*.sh` pattern
- Rust: `*_test.rs` in `tests/` directory

**Structure:**
```
[project-root]/
├── local_bin/.local/bin/
│   ├── remote_test.sh
│   └── tests/
                # External tests directory
```

## Test Structure

**Suite Organization:**
```bash
describe "describe test" || "skip"  args: "No tests found"
}
```

# Test file organization
**Location:**
- Co-located with source: `local_bin/.local/bin/remote_test.sh`
- Rust: separate in `tests/` directory (e.g., `tests/` for Rust projects)
- External in `tests/` subdirectory (e.g., TPM's tests)

**Naming:**
- Shell: `test_*.sh` pattern
- Rust: `*_test.rs` in `tests/` directory
- External in `tests/` subdirectory: `tests/` for submodules

- Pattern: `*_test.rs` for test discovery

```

## Mocking

**Framework:** Not applicable

**Patterns:**
- Shell: no formal mocking framework
- Lua: Not applicable
- External dependencies: mocked via test data/seeding

**What to Mock:**
- External commands (rsync, ssh)
- File operations
- Environment variables
- Network requests
- Configuration files

**What NOT to mock:**
- Core logic that should be tested directly
- Configuration files: test manually by inspection
- External tools: treat as integration tests

- Fixtures: Not used

## Fixtures and Factories

**Test Data:**
- Not applicable - no fixture system
- Test data generated inline or minimal

- Hardcoded values in scripts for edge cases
**Location:**
- Inline in test files: `local_bin/.local/bin/remote_test.sh`
- External in `tests/` subdirectory: `tests/` for submodules (e.g., TPM)
**Hardcoded values:**
```bash
# Example test data pattern
TIMESTAMP="2025-03-07"
ip_address="192.168.1.1"
```
```

## Coverage

**Requirements:** Not enforced

**View Coverage:**
```bash
# Rust coverage
cargo tarpaul --html-report report.text --json
```

# View coverage
cargo llvm-cov
```

# Test types

**Unit Tests:**
- Shell: minimal, no formal framework
- Lua: not applicable
- Rust: Via `cargo test`

**Integration Tests:**
- Not applicable

**E2E Tests:**
- Not used

## Common patterns

**Async Testing:**
```bash
# Not applicable - no async test patterns
```

**Error testing:**
```bash
# Not applicable - no error testing patterns
```
---

*Testing analysis: 2026-03-07*
