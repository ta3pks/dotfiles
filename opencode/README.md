# OpenCode

AI-powered coding environment configuration with MCP servers and multi-model support.

## Overview

[OpenCode](https://opencode.ai/) is an AI coding assistant with support for multiple model providers and MCP (Model Context Protocol) servers. This configuration includes:

- Multi-model provider setup (ZAI, Ollama, OpenRouter)
- MCP servers for vision, web access, database, and Neovim integration
- Plugin system with micode framework

## Files

| File | Purpose |
|------|---------|
| `opencode.json` | Main configuration |
| `settings.json` | Editor settings |
| `micode.json` | Micode framework config |
| `AGENTS.md` | Agent guidelines |
| `opencode-mem.jsonc` | Memory plugin config |
| `dcp.jsonc` | Docker-related operations |

## Dependencies

- **opencode** - AI coding CLI
- **bun** - For plugin management
- **ollama** (optional) - Local model inference
- **nvim** (optional) - For nvim MCP server

## MCP Servers

| Server | Purpose |
|--------|---------|
| `zai-vision` | Image analysis, OCR, UI analysis |
| `zwebsearch` | Web searching |
| `zwebreader` | Web page reading |
| `zread` | GitHub documentation |
| `clickhouse` | Database integration |
| `nvim` | Neovim server integration |
| `serena` | Code analysis and semantic operations |

## Model Providers

Configured providers:
- **ZAI Coding Plan** (GLM-4.7) - Primary model
- **Ollama** - Local models (gpt-oss variants)
- **OpenRouter** - Xiaomi mimo model

## Customization

### Adding MCP Servers

Edit `opencode.json` to add new MCP servers:

```json
"mcpServers": {
  "server-name": {
    "command": "path/to/command",
    "args": ["--arg"]
  }
}
```

### Model Selection

Change the default model in `opencode.json` under `model` key.

## Symlink

```bash
ln -s ~/dotfiles/opencode/.config/opencode ~/.config/opencode
```
