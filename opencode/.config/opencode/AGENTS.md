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

## General Guidelines

### When Working on This Project

- Check `AGENTS.md` in project root for project-specific rules
- Follow project's build/test conventions (e.g., Cargo projects: `cargo build`, `cargo test`)
- Use project's existing code style and patterns

### Tool Selection

- Prefer specialized MCPs over generic tools
- Use `bash` for system operations
- Use `glob`/`grep` for code searches
- Use `read`/`edit` for file operations
