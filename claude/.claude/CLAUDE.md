## Git Commits

**Never include `Co-Authored-By` lines in commit messages.**

## Package Manager Preference

**Always use `bun` instead of `npm`, `npx`, or `pnpm`.**

- Use `bun install` instead of `npm install`
- Use `bun add` instead of `npm install <package>`
- Use `bun run` instead of `npm run`
- Use `bunx` instead of `npx`
- Use `bun install -g` instead of `npm install -g`

## Task Management

**Always create todos upfront before starting work.**

- Use TodoWrite/TaskCreate to create a structured task list at the beginning of any non-trivial task
- Break down complex tasks into discrete, actionable items
- Track progress by updating task status as work progresses

## Parallel Execution

**Always use parallel agents when possible.**

- When facing 2+ independent tasks, use the Task tool to dispatch parallel agents
- Maximize concurrent execution for independent operations (file reads, searches, API calls)
- Only serialize operations that have true dependencies