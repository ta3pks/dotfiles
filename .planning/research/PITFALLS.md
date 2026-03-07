# Pitfalls Research

**Domain:** Dotfiles / Development Environment Configuration
**Researched:** 2026-03-08
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Secrets in Version Control

**What goes wrong:**
API keys, tokens, SSH keys, and credentials get committed to the dotfiles repository. Even private repos can leak secrets through cloning, backups, or accidental public exposure.

**Why it happens:**
- Config files often contain tokens (`.gitconfig` with GitHub tokens, `.npmrc` with auth tokens)
- AI tool configs increasingly contain API keys (OpenAI, Anthropic, etc.)
- Easy to forget that a new config file contains sensitive data
- "I'll remove it later" mentality

**How to avoid:**
1. Use `.gitignore` patterns for known secret files
2. Use templating for sensitive values (chezmoi, yadm templates)
3. Use environment variables for secrets in configs
4. Run secret scanning tools (gitleaks, trufflehog) before commits
5. Never commit files in `.ssh/`, `.aws/`, or files ending in `*_token`, `*_key`

**Warning signs:**
- Config files with `token =`, `api_key =`, `password =`
- Files that should be in `.gitignore` appearing in `git status`
- AI tool configs (OpenCode, Aider) with model API keys inline

**Phase to address:** Phase 1 (Audit & Security)

---

### Pitfall 2: Symlink Management Chaos

**What goes wrong:**
Manual symlink management becomes unmanageable. Symlinks point to wrong locations, become dangling, or conflict with new configs. Reorganizing the repository breaks all existing symlinks.

**Why it happens:**
- No consistent tooling for symlink creation
- Ad-hoc `ln -s` commands without tracking
- Moving files in repo without updating symlinks
- Different symlink strategies on different machines

**How to avoid:**
1. Use a symlink manager (GNU Stow, rcm, homeshick) consistently
2. Document the symlink strategy in README
3. Have a single script that creates all symlinks
4. Never manually create symlinks outside the bootstrap process
5. Test symlink creation on a fresh machine regularly

**Warning signs:**
- `ls -la` showing broken symlinks (`????`)
- Configs not loading despite being in the repo
- "Works on my machine" issues
- Fear of reorganizing the repository structure

**Phase to address:** Phase 1 (Structure & Tooling)

---

### Pitfall 3: No Bootstrap/Recovery Path

**What goes wrong:**
When setting up a new machine or recovering from failure, there's no documented way to restore the environment. Hours spent remembering what tools were installed and how they were configured.

**Why it happens:**
- Dotfiles grow organically over years
- "I'll document it later"
- Assumption that the current machine will always work
- Bootstrap scripts become outdated and abandoned

**How to avoid:**
1. Maintain a working `bootstrap.sh` or `install.sh` script
2. Test bootstrap on a fresh VM/container quarterly
3. Document prerequisites (what must be installed first)
4. Separate "install tools" from "configure tools" steps
5. Keep a "new machine setup" checklist

**Warning signs:**
- No `install.sh` or `bootstrap.sh` in repo root
- Bootstrap script hasn't been tested in 6+ months
- Bootstrap script fails on fresh machine
- Missing dependencies not documented

**Phase to address:** Phase 2 (Documentation & Bootstrap)

---

### Pitfall 4: Cross-Platform Assumptions

**What goes wrong:**
Configs written for Linux break on macOS, or vice versa. Paths like `/home/user` vs `/Users/user`, different package managers, different default tools.

**Why it happens:**
- Developer uses one OS primarily
- Hardcoded absolute paths
- OS-specific tool names (e.g., `sed` behavior differs)
- Shell differences (bash vs zsh default)

**How to avoid:**
1. Use `$HOME` instead of hardcoded paths
2. Detect OS in scripts: `if [[ "$OSTYPE" == "darwin"* ]]`
3. Use conditional configs or branches per OS
4. Test critical configs on all target platforms
5. Document which OS each config targets

**Warning signs:**
- Hardcoded `/home/username` paths
- Scripts assuming Linux-only tools
- macOS-specific configs mixed with Linux configs without separation
- No OS detection in bootstrap scripts

**Phase to address:** Phase 1 (Structure & Tooling)

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Skip documenting a new config | Saves 5 minutes | Future self can't remember why it exists | Never |
| Hardcode a path | Quick fix | Breaks on different machine | Never |
| Commit a secret "temporarily" | Unblocks work | Security incident risk | Never |
| Skip testing bootstrap | Saves time | Can't recover from failure | Never |
| Copy-paste configs from internet | Fast setup | Unknown dependencies, security issues | Only with review |
| Ignore git submodule updates | Avoids conflicts | Security vulnerabilities in themes/plugins | Never |

## Integration Gotchas

Common mistakes when connecting to external services.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Git credentials | Storing tokens in `.gitconfig` | Use credential helpers or SSH keys |
| SSH keys | Committing private keys | Add `.ssh/id_*` to `.gitignore`, only track `.ssh/config` |
| AI tools (OpenCode, Aider) | API keys in config files | Use environment variables or encrypted storage |
| Neovim plugins | Lazy.nvim lockfile not committed | Commit `lazy-lock.json` for reproducibility |
| Shell plugins (Oh My Zsh) | Custom plugins not in submodules | Use git submodules for third-party plugins |
| Theme submodules | Submodules not initialized | Document `git submodule update --init --recursive` |

## Performance Traps

Patterns that work at small scale but fail as configs grow.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Shell startup bloat | Shell takes >1s to start | Lazy-load plugins, defer non-critical init | 50+ plugins or functions |
| Neovim plugin explosion | NVIM takes >2s to start | Use lazy-loading, audit plugins regularly | 100+ plugins |
| Git repo in $HOME | Every git command slow | Use bare repo approach or dedicated dotfiles dir | 10K+ files in home |
| Unconditional package installs | Bootstrap takes forever | Check if already installed before installing | 50+ packages |

## Security Mistakes

Domain-specific security issues beyond general web security.

| Mistake | Risk | Prevention |
|---------|------|------------|
| API keys in dotfiles | Credential theft, unauthorized access | Use env vars, encrypted storage, or secret managers |
| SSH config with wildcards | Accidental key exposure to wrong hosts | Be explicit about hosts, use `IdentitiesOnly yes` |
| Shell history with secrets | Passwords/tokens in plaintext | Set `HISTIGNORE` for sensitive commands, use `set +o history` |
| Git config with real email | Privacy exposure, spam | Use GitHub's noreply email |
| Unencrypted backup of dotfiles | Secrets in backup storage | Encrypt backups or exclude secret files |

## UX Pitfalls

Common user experience mistakes in this domain.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| No README or setup instructions | Can't use the dotfiles | Clear 3-step setup in README |
| Configs that require manual editing | Friction on every new machine | Use templates or env vars for machine-specific values |
| Mixing personal and shareable configs | Can't share useful parts | Separate private configs from shareable ones |
| No comments explaining "why" | Can't maintain configs | Document reasoning for non-obvious settings |
| Breaking changes without notice | Sudden breakage | Use git tags or branches for stable versions |

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **Bootstrap script:** Often missing idempotency — verify running twice doesn't break things
- [ ] **Git submodules:** Often not initialized — verify `git submodule update --init --recursive` works
- [ ] **Secret handling:** Often incomplete — verify `.gitignore` catches all secret patterns
- [ ] **Shell config:** Often has syntax errors — verify `zsh -c "source ~/.zshrc"` succeeds
- [ ] **Neovim config:** Often missing LSP servers — verify `:checkhealth` passes
- [ ] **Cross-platform:** Often untested — verify bootstrap works on all target OSes
- [ ] **Documentation:** Often outdated — verify README steps match current reality

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Secrets committed | HIGH | Rotate all exposed credentials, use BFG to rewrite history, force push |
| Broken symlinks | LOW | Re-run bootstrap script, or manually recreate symlinks |
| No bootstrap | MEDIUM | Create from scratch by documenting current machine setup |
| Config drift | MEDIUM | Diff current configs against repo, reconcile differences |
| Submodule issues | LOW | `git submodule deinit -f . && git submodule update --init --recursive` |
| Shell won't start | HIGH | Boot into recovery, rename broken config, restore from backup |

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Secrets in version control | Phase 1 (Audit) | Run gitleaks scan, verify `.gitignore` coverage |
| Symlink chaos | Phase 1 (Structure) | Test symlink creation on fresh VM |
| No bootstrap | Phase 2 (Bootstrap) | Run bootstrap on fresh container, verify all tools work |
| Cross-platform issues | Phase 1 (Structure) | Test on all target OSes |
| Performance traps | Phase 3 (Optimization) | Measure shell startup time, neovim startup time |
| Documentation rot | Phase 2 (Documentation) | Follow README on fresh machine, verify accuracy |

## Sources

- [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles) - Community knowledge and tool comparisons
- [HN Discussion: What do you use to manage dotfiles?](https://news.ycombinator.com/item?id=11070797) - Real-world experiences and failures
- [chezmoi documentation](https://zread.ai/twpayne/chezmoi) - Secret handling patterns, common issues
- Project CHANGELOG.md - Evidence of past mistakes (e.g., "remove credentials" 2024-12-04)
- Personal experience with dotfiles management over multiple machines and OSes

---
*Pitfalls research for: dotfiles / development environment configuration*
*Researched: 2026-03-08*
