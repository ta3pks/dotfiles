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

### Tool Selection

- Prefer specialized MCPs over generic tools
- Use `bash` for system operations
- **Use Serena tools for all code operations** (see Code Operations & Searching above)
- Use `read`/`edit` for file operations
