# Global Agent Guidelines

## Web Access Tools

When you need to access web resources, use the following MCPs:

### Reading Web Pages

- **Use**: `zwebreader` or `zread` or `zwebsearch` instead of websearch MCPs
- **Never use**: `websearch` or `websearch` tool

### GitHub Documentation

- **Use**: `zread` MCP for searching GitHub repositories and reading docs
- **Use**: `zread_search_doc` for finding relevant documentation
- **Use**: `zread_read_file` for reading specific files from GitHub repos

### Image Analysis

- **Use**: `zai-vision` MCP for image-related tasks
  - OCR: `zai-vision_extract_text_from_screenshot`
  - UI analysis: `zai-vision_ui_to_artifact`
  - Error diagnosis: `zai-vision_diagnose_error_screenshot`
  - Technical diagrams: `zai-vision_understand_technical_diagram`
  - Data visualization: `zai-vision_analyze_data_visualization`

### UI Testing Requirements

- **CRITICAL: When you update UI, always test with Playwright BEFORE manual testing**
  - Test everything you created - if button click is needed, click it and verify it works as expected
  - For Android: Use `adb` or Playwright for Android e2e testing
  - Take screenshots and use `zai-vision` to verify behavior is as expected visually
  - Look for small bugs that can only be found with vision: overflow issues, color problems, alignment, responsive layout issues
  - Example workflow:
    1. Start the application locally
    2. Run Playwright tests to verify functionality works
    3. Take screenshots at key states (before/after interactions)
    4. Use `zai-vision_analyze_image` to check for visual bugs
    5. If issues found, fix and re-test before manual verification

### Task and Session Progress Tracking

- **PROJECT TASK TRACKING: Check and update project task file (e.g., todo.txt) BEFORE and AFTER every task**
  - BEFORE starting: Read project task file to understand current tasks and priorities
  - AFTER completing: Update project task file to mark tasks as complete or add new tasks
  - Use appropriate format for your project (e.g., TaskPaper format: `(Priority) YYYY-MM-DD Task +project @context due:YYYY-MM-DD`)
  - Completed tasks: `x YYYY-MM-DD Task +project completed:YYYY-MM-DD`
  - Keep task entries concise - general what was done is enough (no commit hashes, file counts)
  - **CRITICAL: Always show project tasks on the main agent and update progress as you go even if you are using sub agents or background tasks or agents**

- **SESSION PROGRESS TRACKING: Always use todoread and todowrite tools for managing current session progress**
  - BEFORE starting any work: Call `todoread` to check current session tasks
  - WHEN creating tasks: Use `todowrite` to create task list for complex work (3+ steps)
  - WHILE working: Update task status to in_progress when starting work, completed when done
  - AFTER subagent completes: Update corresponding main agent task to completed
  - This tracks agents, subagents, current joblist, and plan execution status
  - DO NOT modify project task file (e.g., todo.txt) for session tracking - that's only for project-level tasks
  - **CRITICAL: Until all session tasks are complete, don't stop - keep going until you complete them all**
  - Test everything you created - if button click is needed, click it and verify it works as expected
  - For Android: Use `adb` or Playwright for Android e2e testing
  - Take screenshots and use `zai-vision` to verify behavior is as expected visually
  - Look for small bugs that can only be found with vision: overflow issues, color problems, alignment, responsive layout issues
  - Example workflow:
    1. Start the application locally
    2. Run Playwright tests to verify functionality works
    3. Take screenshots at key states (before/after interactions)
    4. Use `zai-vision_analyze_image` to check for visual bugs
    5. If issues found, fix and re-test before manual verification

## Code Operations & Searching

**ALWAYS use Serena tools for code operations when possible - they are more efficient than bash-based tools**

### Understanding Code

- **Use**: `serena_get_symbols_overview` to get high-level understanding of file structure
- **Use**: `serena_find_symbol` to find classes, functions, methods by name path pattern
- **Use**: `serena_find_referencing_symbols` to find all references to a symbol

### Searching Code

- **Use**: `serena_search_for_pattern` for code pattern searches with regex support
- **Use**: `serena_find_symbol` with substring matching for flexible symbol lookup
- **Never use**: `glob` or `grep` for code-based searches (use Serena instead)

### File Operations

- **Use**: `serena_list_dir` to list files and directories recursively
- **Use**: `serena_find_file` to find files by name pattern
- **Never use**: `bash ls` or `bash find` (use Serena instead)

### Modifying Code

- **Use**: `serena_replace_symbol_body` to replace function/method bodies
- **Use**: `serena_insert_after_symbol` / `serena_insert_before_symbol` to add code
- **Use**: `serena_rename_symbol` to rename symbols across codebase
- **Use**: `serena_replace_content` for literal or regex-based file replacements

### Thinking & Workflow

- **Use**: `serena_think_about_collected_information` after gathering information
- **Use**: `serena_think_about_task_adherence` before making code changes
- **Use**: `serena_think_about_whether_you_are_done` when about to claim completion

### Memory System

- **Use**: `serena_write_memory` to write project insights to memory
- **Use**: `serena_read_memory` to read saved memories
- **Use**: `serena_list_memories` to see available memories

## General Guidelines

### When Working on This Project

- Check `AGENTS.md` in project root for project-specific rules
- Follow project's build/test conventions (e.g., Cargo projects: `cargo build`, `cargo test`)
- Use project's existing code style and patterns

### Package Management

- **Use**: `bun` instead of `npm` for all Node.js package management operations
- **Use**: `bun install` instead of `npm install`
- **Use**: `bun run` instead of `npm run`
- **Use**: `bun add` instead of `npm install <package>`
- **Never use**: `npm` commands (use `bun` instead)

### Tool Selection

- Prefer specialized MCPs over generic tools
- Use `bash` for system operations
- **Use Serena tools for all code operations** (see Code Operations & Searching above)
- Use `read`/`edit` for file operations
