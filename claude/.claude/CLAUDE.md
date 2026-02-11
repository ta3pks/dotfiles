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

**Always use agent teams (TeamCreate) whenever possible.**

- When facing 2+ independent tasks, create a team and spawn teammates to work concurrently
- Use TaskCreate to define work items and assign them to teammates
- Maximize concurrent execution through team coordination
- Only serialize operations that have true dependencies

## Container Runtime

**Always use `podman` instead of `docker`.**

- Use `podman` for all container operations
- Use `podman-compose` instead of `docker-compose`
- Testcontainers work with podman via `DOCKER_HOST=unix:///run/user/1000/podman/podman.sock`