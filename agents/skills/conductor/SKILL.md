---
name: conductor
description: >
  Use for Conductor workspace configuration, target branches, lifecycle, and runtime setup. Applies to conductor.build and workspaces under ~/conductor/workspaces.
---

# Conductor

[Conductor](https://conductor.build) runs coding agents in isolated git worktrees. This skill covers Conductor-specific configuration and lifecycle. Standing authorization rules apply to Git operations.

## Agent-critical context

- Each workspace is a full repo checkout, typically `~/conductor/workspaces/<project>/<city>` (the `city` name is the workspace directory label; the **branch** is the primary identifier for what you're building).
- **`CONDUCTOR_ROOT_PATH`** points at the repository root inside that workspace. Use it in setup scripts (e.g. symlinking `.env` files): `ln -sf "$CONDUCTOR_ROOT_PATH/<path>/.env.local" <path>/.env.local`.
- **`.context/`** in the workspace is for inter-agent collaboration and is gitignored — don't treat it as durable repo state.

- Conductor injects a **target branch** in the workspace system instruction. Use it for **PR base selection**, **rebase targets**, and **diff range** — not merely "whatever branch is currently checked out" without confirming it matches that target.

- **`origin` is shared** with every other clone of the repo. **`git fetch`** (especially `origin` and the relevant base) before diffing or rebasing — another workspace may have advanced the base branch.

## Environment variables

Conductor exposes these in the terminal and in [scripts](https://docs.conductor.build/core/scripts) (see [official env doc](https://docs.conductor.build/tips/conductor-env)):

| Variable                   | Role                                                                                    |
| -------------------------- | --------------------------------------------------------------------------------------- |
| `CONDUCTOR_WORKSPACE_NAME` | Workspace display name                                                                  |
| `CONDUCTOR_WORKSPACE_PATH` | Path to the workspace directory                                                         |
| `CONDUCTOR_ROOT_PATH`      | Repository root inside the workspace                                                    |
| `CONDUCTOR_DEFAULT_BRANCH` | Default branch name (often `main`)                                                      |
| `CONDUCTOR_PORT`           | First of **10** consecutive ports reserved for this workspace (`CONDUCTOR_PORT` … `+9`) |

## Running the app

Dev servers bind to **`$CONDUCTOR_PORT`**, and run-script cwd is **`$CONDUCTOR_WORKSPACE_PATH`** ([Using run scripts](https://docs.conductor.build/guides/how-to-run)). Each workspace is one feature or bugfix; archived workspaces can be restored with their chat history.

## Workspaces and branches

Per [Workspaces and branches](https://docs.conductor.build/tips/workspaces-and-branches):

- New workspace → new branch; first chat often renames the branch to match the task.
- Switch work with `git checkout`, `git branch -m`, or `git checkout -b` as usual.
- **A branch can only be checked out in one workspace at a time.** If blocked, switch the other workspace to another branch or create a new branch from the desired one.

## Parallel agents

Each workspace is an isolated tree ([Parallel agents](https://docs.conductor.build/core/parallel-agents)). Subagents within one workspace share its working tree, so give editing subagents their own worktree.

## Checkpoints

[Checkpoints](https://docs.conductor.build/core/checkpoints) snapshot per-turn code changes and allow revert from the chat UI. Revert is destructive for messages and code after the chosen turn. **Use extra care if multiple chats run in the same workspace** — checkpoints are Claude Code–only and stored separately from normal branch history.

## Todos

[Todos](https://docs.conductor.build/core/todos) live in the notes tab; incomplete todos can **block merging**. Reference them in composer with **`@todos`**.

## Cursor / Grok in Conductor

Cursor IDE Agent, Claude Code, and Codex inject `AGENTS.md` and skill catalogs. Conductor's Grok / Cursor CLI path does not, even when those files sit in Cursor's documented discovery locations. Do not compensate with `[prompts.general]` — that prompt is appended to every harness.

What this Grok path *does* inject: Cursor User Rules (Customize → Rules) and Conductor action prompts (`create_pr`, `code_review`, …). There is no per-harness prompt in Conductor's settings schema. The durable fix is Conductor/Cursor loading project `AGENTS.md` and `~/.cursor/skills` for Grok the same way Claude does; until then, a short Cursor User Rule is the only auto-load channel that stays off Claude and GPT.

## Git and PRs

- **Base branch and PR prose:** `/pr-guidelines` — first step when choosing base is still **Conductor target branch** when present.

## Managed settings

`~/.conductor/settings.toml` (schema: `https://conductor.build/schemas/settings.schema.json`) holds machine-wide overrides Conductor enforces — `defaultModel`, `enterpriseDataPrivacy`, `claudeExecutablePath`. In this dotfiles setup it is symlinked from `agents/conductor.settings.toml`; edit there.

## Official documentation

Full index: [docs.conductor.build/llms.txt](https://docs.conductor.build/llms.txt). Starting points:

- [Workflow](https://docs.conductor.build/workflow)
- [Workspaces and branches](https://docs.conductor.build/tips/workspaces-and-branches)
- [Conductor environment variables](https://docs.conductor.build/tips/conductor-env)
- [From issue to PR](https://docs.conductor.build/guides/issue-to-pr)
- Core: [Parallel agents](https://docs.conductor.build/core/parallel-agents), [Diff viewer](https://docs.conductor.build/core/diff-viewer), [Checkpoints](https://docs.conductor.build/core/checkpoints), [Todos](https://docs.conductor.build/core/todos), [Scripts](https://docs.conductor.build/core/scripts), [MCP](https://docs.conductor.build/core/mcp)
