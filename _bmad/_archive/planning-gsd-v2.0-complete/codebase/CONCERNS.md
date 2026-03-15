# Codebase Concerns

**Analysis Date:** 2026-03-07

## Tech Debt

**Stale Configuration Directory:**
- Issue: `nvim/config.old/` contains old Neovim configuration predating LazyVim migration (June 2025)
- Files: `nvim/config.old/nvim/lua/plugins/*.lua`
- Impact: Confusion about which config is active, wasted disk space, potential for accidentally using old configs
- Fix approach: Remove `nvim/config.old/` directory entirely after verifying current LazyVim config is complete

**Backup Files in Repository:**
- Issue: Backup files committed to version control
- Files:
  - `kitty/.config/kitty/kitty.conf.bak`
  - `local_bin/.local/bin/waybar.sh.backup`
  - `local_bin/.local/bin/gesture-watchdog.sh.bak`
- Impact: Repository clutter, confusion about active config
- Fix approach: Remove backup files and add `*.bak`, `*.backup` to `.gitignore`

**Duplicate Keyboard Remapping Tools:**
- Issue: Both kmonad and kanata configured for keyboard remapping
- Files:
  - `kmonad/.config/kmonad/config.kbd`, `kmonad/.config/kmonad/apple_keyboard.kbd`
  - `kanata/.config/kanata/kanata.kbd`
- Impact: Unclear which tool is primary, maintenance burden doubled
- Fix approach: Choose one (kanata is newer, actively maintained) and remove the other

**Multiple AI Coding Tool Configs:**
- Issue: Overlapping AI assistant configurations
- Files:
  - `opencode/.config/opencode/` (primary)
  - `nvim/.config/nvim/lua/plugins/avante.lua`
  - `nvim/.config/nvim/lua/plugins/codecompanion.lua`
  - `aider/` directory
- Impact: Confusion about which tool to use, potential config conflicts
- Fix approach: Consolidate to primary tool (OpenCode) and remove redundant configs

## Known Bugs

**Gesture Recognition Script Complexity:**
- Symptoms: 258-line bash script with manual state file management
- Files: `local_bin/.local/bin/gesture_recognition.sh`
- Trigger: Touch gestures on Wayland (Sway)
- Workaround: None - script works but is fragile
- Risk: Race conditions with temp files in `/tmp/touch_*`

**Remote Test Script Host Dependency:**
- Symptoms: Hardcoded remote host "REDACTED_PROJECT"
- Files: `local_bin/.local/bin/remote_test.sh`
- Trigger: Running `remote_test.sh` without "REDACTED_PROJECT" in SSH config
- Workaround: Add "REDACTED_PROJECT" host to `~/.ssh/config`
- Fix approach: Make remote host configurable via environment variable

## Security Considerations

**Ollama Service Network Exposure:**
- Risk: Binds to all interfaces (0.0.0.0:11434), exposing API to local network
- Files: `systemd_user_files/.config/systemd/user/ollama.service`
- Current mitigation: Behind firewall, but still network-accessible
- Recommendations: Change to `OLLAMA_HOST=127.0.0.1:11434` if external access not needed

**API Key Handling:**
- Risk: API keys referenced by environment variable names (good practice)
- Files:
  - `nvim/.config/nvim/lua/plugins/codecompanion.lua:14` - `api_key = "OPENROUTER_API_KEY"`
  - `nvim/.config/nvim/lua/plugins/avante.lua:21` - `api_key_name = "OPENROUTER_API_KEY"`
- Current mitigation: Keys stored in environment, not in files
- Recommendations: Continue this pattern; never commit actual key values

**WiFi Password in Command Line:**
- Risk: Password passed via command line to nmcli (visible in process list)
- Files: `waybar/.local/bin/wifi-menu.sh:60`
- Current mitigation: Password is user-provided via prompt, not stored
- Recommendations: Acceptable for personal machine; consider using nmcli connection files for shared machines

## Performance Bottlenecks

**Gesture Recognition Polling:**
- Problem: Continuous polling and file I/O for touch state
- Files: `local_bin/.local/bin/gesture_recognition.sh`
- Cause: Uses temp files (`/tmp/touch_count`, `/tmp/touch_positions`, `/tmp/gesture_active`) for state
- Improvement path: Consider rewriting in Rust/Python with in-memory state or use libinput directly

**Sway Background Cycling:**
- Problem: Background image cycling every 10 seconds
- Files: `sway/.config/sway/config:42`
- Cause: `cycle_background.sh` called with 10-second interval
- Improvement path: Increase interval or disable if not needed

## Fragile Areas

**Gesture System (Multiple Scripts):**
- Files:
  - `local_bin/.local/bin/gesture_recognition.sh` (258 lines)
  - `local_bin/.local/bin/gesture-watchdog.sh`
  - `local_bin/.local/bin/touch-gesture-service.sh`
  - `local_bin/.local/bin/toggle-keyboard.sh`
- Why fragile: Interdependent scripts with hardcoded paths, temp file state, no error handling
- Safe modification: Test changes in isolation; verify watchdog restarts service correctly
- Test coverage: None

**Hardcoded Home Paths:**
- Files:
  - `local_bin/.local/bin/touch-gesture-service.sh:6` - `SCRIPT_DIR="/home/nikos/dotfiles/..."`
  - `local_bin/.local/bin/gesture_recognition.sh:84` - `/home/nikos/dotfiles/...`
  - `local_bin/.local/bin/gesture-watchdog.sh:5` - `SERVICE_SCRIPT="/home/nikos/dotfiles/..."`
  - `sway/.config/sway/config:42-49` - Multiple `/home/nikos/dotfiles/` references
- Why fragile: Breaks if username changes or repo moved
- Safe modification: Replace with `$HOME` or relative paths
- Test coverage: None

**Neovim Plugin Configuration:**
- Files: `nvim/.config/nvim/lua/plugins/*.lua`
- Why fragile: Multiple interdependent plugins, lazy loading, custom keymaps
- Safe modification: Test with `:checkhealth` and `:Lazy` after changes
- Test coverage: Manual testing only

## Scaling Limits

**Shell Script Maintainability:**
- Current capacity: Simple to moderate complexity scripts
- Limit: Complex state management in bash becomes unmaintainable
- Scaling path: Rewrite gesture system in compiled language (Rust) or Python

**Dotfiles Linking:**
- Current capacity: Manual symlinking per tool
- Limit: No automated setup, easy to miss new configs
- Scaling path: Consider GNU stow or similar for automated linking

## Dependencies at Risk

**Superpowers Git Submodule:**
- Risk: External repository as submodule
- Impact: Changes upstream may break local customizations
- Location: `opencode/.config/opencode/superpowers/` (submodule from `https://github.com/obra/superpowers`)
- Migration plan: Pin to specific commit or fork for stability

**TPM (Tmux Plugin Manager):**
- Risk: External git submodule
- Impact: Plugin installation depends on external repo availability
- Location: `tmux/.tmux/plugins/tpm/`
- Migration plan: Acceptable risk - TPM is stable and widely used

**Kitty Themes Submodule:**
- Risk: External theme repository
- Impact: Theme updates may change appearance
- Location: `config/.config/kitty/kitty-themes` (note: path may be stale)
- Migration plan: Verify path is correct; consider vendoring preferred themes

## Missing Critical Features

**No Automated Setup Script:**
- Problem: New machine setup requires manual symlink creation
- Blocks: Quick environment replication
- Files affected: All config directories
- Priority: Medium

**No Test Suite for Shell Scripts:**
- Problem: Custom scripts have no automated tests
- Blocks: Confident refactoring of gesture system
- Files affected: `local_bin/.local/bin/*.sh`
- Priority: Low (personal dotfiles)

## Test Coverage Gaps

**Gesture System Scripts:**
- What's not tested: Touch gesture detection, keyboard toggle, watchdog restart behavior
- Files:
  - `local_bin/.local/bin/gesture_recognition.sh`
  - `local_bin/.local/bin/gesture-watchdog.sh`
  - `local_bin/.local/bin/touch-gesture-service.sh`
- Risk: Changes may break touch functionality without detection
- Priority: Low (requires hardware to test)

**Neovim Configuration:**
- What's not tested: Plugin loading, keymap correctness, LSP configuration
- Files: `nvim/.config/nvim/lua/plugins/*.lua`
- Risk: Plugin updates may break configuration
- Priority: Low (manual testing with `:checkhealth`)

**Sway Configuration:**
- What's not tested: Keybindings, output configuration, autostart apps
- Files: `sway/.config/sway/config`
- Risk: Config errors only detected at runtime
- Priority: Low (sway validates on reload)

---

*Concerns audit: 2026-03-07*
