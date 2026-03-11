# Coding Conventions

**Analysis Date:** 2026-03-07

## Languages

**Primary:**
- Shell (Bash/Zsh) - Configuration scripts, service management
- Lua - Neovim configuration

**Secondary:**
- Kanata KDL - Keyboard configuration
- YAML - Various tool configurations
- TOML - Rust and tool configurations

## Naming Patterns

**Files:**
- Shell scripts: `*.sh` - lowercase with underscores
- Lua modules: `*.lua` - lowercase
- Config files: Tool-specific (e.g., `config`, `yabairc`, `kanata.kbd`)
- Service files: `*.service` - systemd unit files

**Functions (Shell):**
- lowercase with underscores: `start_monitor`, `stop_monitor`, `status_monitor`
- Private/internal functions: prefixed with double underscore: `__DEVICE`, `__EVENTS`

**Variables (Shell):**
- Uppercase for underscores: `SCRIPT_DIR`, `PID_FILE`, `LOCK_FILE`
- Local variables: lowercase: `local pid=$!`

**Variables (Lua):**
- Module imports: local short names (`ls`, `s`, `sn`, `t`, `i`, `f`, `c`, `d`, `r`)
- Full module path for require for

## Code Style

**Formatting:**
- StyLua for Lua formatting (config: `nvim/.config/nvim/stylua.toml`)
  - 2-space indentation
  - 120 column width
- Rustfmt for Rust code (config: `rust/.rustfmt.toml`)
  - Unstable features enabled
  - Horizontal/vertical imports layout
  - Visual indent style
  - Crate-level imports granularity

**Indentation:**
- Shell: Tabs (common in scripts)
- Lua: 2 spaces (StyLua config)
- YAML: 2 spaces
- TOML: Standard indentation

**Line Length:**
- No strict limit enforced
- Lua: 120 chars soft limit (StyLua)
- Shell: Generally under 100 lines

## Linting

**Shell:**
- No formal linter detected
- Relies on shellcheck via `set -n` in some scripts

**Lua:**
- Lua language server via Neovim LSP
- StyLua for formatting

**YAML:**
- No formal linter detected
- Standard YAML syntax followed

## Import Organization

**Shell Scripts:**
1. Shebang line
2. Variable declarations (uppercase)
3. Function definitions
4. Main logic
5. Helper functions

**Lua Modules:**
1. Local shorthand imports (first)
2. External requires (second)
3. Module configuration/setup
4. Main logic

**Path Aliases:**
- Not used in this dotfiles repository
- All paths are relative to tool directories

## Error Handling

**Patterns:**
- Exit codes: `exit 0` for success, `exit 1` for errors
- Lock files: Used for process management (`/tmp/*.lock`, `/tmp/*.pid`)
- Logging: Redirected to log files (`>> /tmp/*.log 2>&1 &`)
- Graceful degradation: Scripts continue even if operations fail

**Shell Example:**
```bash
# From touch-gesture-service.sh
start_monitor() {
    if [ -f "$LOCK_FILE" ]; then
        echo "Touch gesture monitor is already running"
        return 0
    fi
    # ...
}

case "$1" in
    start)
        start_monitor
        ;;
    # ...
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
```

**Lua Example:**
```lua
-- From lazy.lua
if vim.v.shell_error ~= 0 then
  vim.api.nvim_echo({
    { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
    { out, "WarningMsg" },
    { "\nPress any key to exit..." },
  }, true, {})
  vim.fn.getchar()
  os.exit(1)
end
```

## Logging

**Framework:** Console output with echo

**Patterns:**
- Status messages: `echo "Starting..."`, `echo "Done"`
- Debug info: Redirected to log files in service scripts
- Error messages: Written to stderr (`echo "Error: ..." >&2`)
- Timestamps: Not typically used in simple scripts

**Shell Example:**
```bash
echo "Starting touch gesture monitor..."
"$TOUCH_MONITOR" >> /tmp/touch-gesture.log 2>&1 &
echo "Touch gesture monitor started (PID: $pid)"
```

## Comments

**When to Comment:**
- File headers explaining purpose
- Complex logic explanations
- Configuration sections with multiple options
- Workarounds and hacks

**Shell Headers:**
```bash
#!/bin/bash
# Description of what the script does
# Author/date (optional)
```

**Lua Comments:**
```lua
-- Single line comments with --
--[[
Multiline comments
]]
```

**Configuration Comments:**
- Kanata uses extensive header comments with ASCII art
- Sway/config uses inline comments for sections
- Systemd service files include Description and documentation

**JSDoc/TSDoc:**
- Lua: Minimal docstrings, mostly inline comments
- Shell: No formal documentation format

## Function Design

**Size:** Generally small, focused functions

**Parameters:** 
- Shell: Positional parameters (`$1`, `$2`, etc.)
- Lua: Named parameters preferred

**Return Values:**
- Shell: Exit codes (0 for success, 1 for error)
- Lua: Return values or nil for error states

## Module Design

**Exports:** 
- Shell: Scripts are standalone, not imported
- Lua: Module pattern with `require()` and exports

**Barrel Files:** Not used

---

*Convention analysis: 2026-03-07*
