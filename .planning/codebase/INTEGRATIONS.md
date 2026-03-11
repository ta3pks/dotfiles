# External Integrations

**Analysis Date:** 2026-03-07

## APIs & External Services

**AI Model Providers:**
- **ZAI Coding Plan** - Primary AI model (GLM-4.7)
  - SDK/Client: Built into OpenCode
  - Auth: `{env:ZAI_API_KEY}`
- **Ollama** - Local AI model hosting
  - SDK/Client: `@ai-sdk/openai-compatible`
  - Endpoint: `http://localhost:11434/v1`
  - Models: `gpt-oss:latest`, `gpt-oss:20b`, `gpt-oss:120b-cloud`
- **OpenRouter** - AI model gateway
  - Models: `xiaomi/mimo-v2-flash:free`, `google/gemini-2.5-flash`, `qwen/qwen3-coder`
  - Auth: `{env:OPENROUTER_API_KEY}`

**AI Coding Tools:**
- **Aider** - AI pair programming
  - Config: `aider/.aider.conf.yml`
  - Model: `openrouter/qwen/qwen3-coder`
  - Weak model: `openrouter/google/gemini-2.0-flash-001`
- **Avante.nvim** - Neovim AI assistant
  - Provider: OpenCode ACP
  - Config: `nvim/.config/nvim/lua/plugins/avante.lua`
- **CodeCompanion.nvim** - Neovim AI chat
  - Adapter: OpenCode/OpenRouter
  - Config: `nvim/.config/nvim/lua/plugins/codecompanion.lua`

## MCP (Model Context Protocol) Servers

**Code Analysis:**
- **Serena** - Semantic code operations via LSP
  - Command: `uvx --from git+https://github.com/oraios/serena serena start-mcp-server`
  - Config: `.serena/project.yml`
  - Language: Lua (for this dotfiles project)

**Vision & Web:**
- **zai-vision** - Image analysis (OCR, UI analysis, error diagnosis)
  - Command: `npx -y @z_ai/mcp-server`
  - Auth: `{env:ZAI_API_KEY}`
- **zwebsearch** - Web search capabilities
  - Command: `npx -y @z_ai/mcp-server`
  - Auth: `{env:ZAI_API_KEY}`
- **zwebreader** - Web page reading
  - URL: `https://api.z.ai/api/mcp/web_reader/mcp`
  - Auth: Bearer token via `{env:ZAI_API_KEY}`
- **zread** - GitHub documentation search
  - URL: `https://api.z.ai/api/mcp/zread/mcp`
  - Auth: Bearer token via `{env:ZAI_API_KEY}`

**Development Tools:**
- **nvim** - Neovim server integration
  - Command: `npx -y mcp-neovim-server`
  - Socket: `/tmp/nvim`
  - Shell commands: Enabled
- **clickhouse** - ClickHouse database client
  - Command: `mcp-clickhouse`
  - Connection: `localhost:8123`
  - Auth: Environment variables for user/password

**Disabled/Optional:**
- `browserOS_nikos` - Remote browser control (disabled)
- `jira` - Atlassian integration (disabled)
- `context7` - Context service (disabled)
- `gh_grep` - GitHub code search (disabled)
- `pipedream` - Workflow automation (disabled)

## Data Storage

**Databases:**
- ClickHouse
  - Connection: `localhost:8123`
  - Client: `mcp-clickhouse` MCP server
  - Alias: `dccl` for CLI access

**File Storage:**
- Local filesystem only
- Syncthing for cross-device synchronization

**Caching:**
- Redis via Podman container
  - Wrapper: `local_bin/.local/bin/redis-cli`
  - Image: `docker.io/library/redis:latest`
  - Network: Host mode

## Authentication & Identity

**Auth Provider:**
- GitHub CLI (`gh`)
  - Credential helper for git operations
  - Config: `git/.gitconfig`
- GPG signing for commits
  - Enabled in git config

**SSH:**
- Remote host: `dedecta` (for remote Rust testing)
  - Script: `local_bin/.local/bin/remote_test.sh`

## Monitoring & Observability

**Error Tracking:**
- None configured

**Logs:**
- Neovim logs via LazyVim
- OpenCode logs in cache directory

**Time Tracking:**
- WakaTime
  - Neovim plugin: `wakatime/vim-wakatime`
  - OpenCode plugin: `opencode-wakatime`
  - Zsh plugin: `wakatime`

## CI/CD & Deployment

**Hosting:**
- N/A - Local development environment

**CI Pipeline:**
- None configured (dotfiles repository)

## Environment Configuration

**Required env vars:**
- `ZAI_API_KEY` - ZAI services authentication
- `OPENROUTER_API_KEY` - OpenRouter API access
- `CONTEXT7_API_KEY` - Context7 service (optional)
- `OLLAMA_HOST` - Ollama server (default: `0.0.0.0:11434`)

**Secrets location:**
- `~/.ssh/secret_env` - Shell environment secrets
- `~/.env` - Local environment variables
- Environment variables passed to MCP servers

**Git Credentials:**
- GitHub CLI (`gh`) as credential helper
- Store helper for other repositories

## Webhooks & Callbacks

**Incoming:**
- None configured

**Outgoing:**
- None configured

## Systemd User Services

**AI Services:**
- `ollama.service` - Local AI model server
  - ExecStart: `/usr/bin/ollama serve`
  - Environment: `HSA_OVERRIDE_GFX_VERSION=11.0.0` (AMD GPU support)

**Synchronization:**
- `syncthing.service` - File synchronization
  - ExecStart: `/usr/bin/syncthing -no-browser`

**Input:**
- `ydotoold.service` - Virtual input daemon
- `remote_connect.service` - Remote connection handling

## Desktop Integration

**Status Bar (Waybar):**
- Network (WiFi/Ethernet)
- CPU/Memory usage
- Audio (PulseAudio)
- Backlight
- Battery
- Language switcher
- Media player controls (playerctl)
- Power profiles (asusctl)
- Gammastep toggle

**Clipboard:**
- CopyQ - Clipboard manager

**Notifications:**
- `@mohak34/opencode-notifier` - OpenCode notifications

**Display:**
- Gammastep - Blue light filter
  - Location: Tbilisi, Georgia (41.69, 44.83)
  - Config: `gammastep/.config/gammastep/config.ini`

---

*Integration audit: 2026-03-07*
