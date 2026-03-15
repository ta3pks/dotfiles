---
phase: 06-ai-integration
plan: 02
subsystem: api
tags: [stdio, json, ndjson, shell-integration, zod, validation]

requires:
  - phase: 06-01
    provides: MemoryService for memory operations

provides:
  - Line-delimited JSON interface for shell integration
  - 6 command handlers (store, search, get, list, delete, context)
  - Zod validation for all commands
  - Integration test suite

affects: [cli-tools, aider-integration, scripting]

tech-stack:
  added: []
  patterns:
    - NDJSON protocol for stdin/stdout communication
    - Zod schema validation for request validation
    - Modular command handler architecture

key-files:
  created:
    - memory/tests/stdio/integration.test.ts
  modified:
    - memory/src/stdio/types.ts
    - memory/src/stdio/commands.ts
    - memory/src/stdio/index.ts

key-decisions:
  - "Zod schemas co-located with TypeScript types in types.ts for single source of truth"
  - "Modular architecture separates command handlers from main loop for testability"
  - "Fresh MemoryService instance per test ensures proper isolation"

patterns-established:
  - "Command handlers return StdioResponse with success boolean, optional data, and error code"
  - "Each command validated against Zod schema before processing"

requirements-completed:
  - INT-02
  - INT-04

duration: 11 min
completed: 2026-03-13
---

# Phase 6 Plan 2: Stdio Interface for Claude Code/Aider Summary

**Line-delimited JSON interface with Zod validation for shell integration and scripting**

## Performance

- **Duration:** 11 min
- **Started:** 2026-03-13T20:44:06Z
- **Completed:** 2026-03-13T20:55:16Z
- **Tasks:** 5
- **Files modified:** 4

## Accomplishments
- Fixed syntax errors in existing commands.ts (duplicate imports, missing commas, extra braces)
- Added Zod validation schemas to types.ts for all 6 commands
- Refactored index.ts to use modular commands.ts architecture
- Created comprehensive integration test suite with 15 tests
- All commands work correctly: store, search, get, list, delete, context

## Task Commits

Each task was committed atomically:

1. **Task 1: Create stdio types** - `e3f497g` (feat) - Added Zod schemas for validation
2. **Task 2: Implement command handlers** - `0939725` (fix) - Fixed syntax errors, implemented all 6 handlers
3. **Task 3: Create stdio main loop** - `c2e9712` (refactor) - Simplified to use commands module
4. **Task 5: Add stdio integration tests** - `9df6afd` (test) - 15 tests for all commands

**Plan metadata:** (pending)

## Files Created/Modified
- `memory/src/stdio/types.ts` - Added Zod schemas for all 6 commands alongside TypeScript interfaces
- `memory/src/stdio/commands.ts` - Fixed syntax errors, implemented proper handlers with validation
- `memory/src/stdio/index.ts` - Refactored to use modular commands.ts, simplified main loop
- `memory/tests/stdio/integration.test.ts` - Comprehensive test suite for all commands

## Decisions Made
- Zod schemas co-located with TypeScript types in types.ts for single source of truth
- Modular architecture separates command handlers from main loop for testability
- Fresh MemoryService instance per test ensures proper isolation
- Error codes (VALIDATION_ERROR, NOT_FOUND, UNKNOWN_COMMAND, INTERNAL_ERROR) for programmatic error handling

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed syntax errors in commands.ts**
- **Found during:** Task 2 (Implement command handlers)
- **Issue:** Existing commands.ts had multiple syntax errors: duplicate imports, missing commas in type imports, circular import, extra closing braces after each function
- **Fix:** Rewrote entire file with correct syntax, proper imports, and working implementations
- **Files modified:** memory/src/stdio/commands.ts
- **Verification:** TypeScript compilation succeeds, all tests pass
- **Committed in:** 0939725 (Task 2 commit)

**2. [Rule 3 - Blocking] Fixed test isolation issue**
- **Found during:** Task 5 (Add stdio integration tests)
- **Issue:** Shared MemoryService instance across tests caused data leakage between tests; MemoryService.init() early-return prevented re-initialization with new data path
- **Fix:** Changed to create fresh MemoryService instance in beforeEach hook instead of module-level constant
- **Files modified:** memory/tests/stdio/integration.test.ts
- **Verification:** All 15 tests pass with proper isolation
- **Committed in:** 9df6afd (Task 5 commit)

---

**Total deviations:** 2 auto-fixed (1 bug, 1 blocking)
**Impact on plan:** Both fixes essential for correctness. The syntax errors prevented the module from working; test isolation is required for reliable tests.

## Issues Encountered
None beyond the auto-fixed deviations above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Stdio interface complete and tested
- Ready for integration with shell scripts, Aider, or other tools
- Package.json already has `bun run stdio` script configured

---
*Phase: 06-ai-integration*
*Completed: 2026-03-13*
