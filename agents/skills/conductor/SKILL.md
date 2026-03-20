---
name: conductor
description: >
  Use when working inside Conductor (conductor.build): parallel workspaces/worktrees, `CONDUCTOR_*` env vars,
  workspace path under ~/conductor/workspaces, target branch for PRs/rebase/diff, Diff Viewer, archiving,
  one-branch-per-workspace rules, run scripts and ports, checkpoints/todos, or "which branch is the base".
  Pair with `/git-workflows` and `/pr-guidelines` for git and PR specifics. Triggers on Conductor, worktree,
  CONDUCTOR_ROOT_PATH, workspace city name, parallel agents, ⌘⇧N workspace, merge block, @todos.
global_category: Conductor
---

# Conductor

[Conductor](https://conductor.build) runs coding agents in isolated git worktrees. Git behavior (fetch, base branch, permissions) still follows `/git-workflows` and `/pr-guidelines` — this skill is the Conductor-specific layer on top.

## Agent-critical context

<!-- @> Worktree clone at ~/conductor/workspaces/<project>/<city>; CONDUCTOR_ROOT_PATH = repo root; .context/ gitignored for inter-agent files -->

- Each workspace is a full repo checkout, typically `~/conductor/workspaces/<project>/<city>` (the `city` name is the workspace directory label; the **branch** is the primary identifier for what you're building).
- **`CONDUCTOR_ROOT_PATH`** points at the repository root inside that workspace. Use it in setup scripts (e.g. symlinking `.env` files): `ln -sf "$CONDUCTOR_ROOT_PATH/apps/admin/.env.local" apps/admin/.env.local`.
- **`.context/`** in the workspace is for inter-agent collaboration and is gitignored — don't treat it as durable repo state.

<!-- @> Conductor target branch in system instruction → PR base, rebase, diff — not the checked-out branch name alone -->

- Conductor injects a **target branch** in the workspace system instruction. Use it for **PR base selection**, **rebase targets**, and **diff range** — not merely "whatever branch is currently checked out" without confirming it matches that target.

<!-- @> Same origin across workspaces; git fetch before diff/rebase; other workspaces may push the same base -->

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

## Recommended workflow

From [Workflow](https://docs.conductor.build/workflow):

1. **One workspace per feature or bugfix** — create via **⌘⇧N** or the **⋯** menu next to "New workspace" (from PR, branch, or Linear issue).
2. **Develop** in Conductor's Claude Code UI or open the same tree in your IDE.
3. **Review** in the **Diff Viewer (⌘D)**; use Terminal or **Run** to exercise the app. For dev servers, see [Using run scripts](https://docs.conductor.build/guides/how-to-run) — bind to **`$CONDUCTOR_PORT`**; script cwd is **`$CONDUCTOR_WORKSPACE_PATH`**.
4. **Open a PR (⌘⇧P)** when ready; fix failing checks with help from Conductor, then merge when green.
5. **Archive** the workspace when done; restore later (including chat history) from **Workspaces** in the sidebar.

## Workspaces and branches

Per [Workspaces and branches](https://docs.conductor.build/tips/workspaces-and-branches):

- New workspace → new branch; first chat often renames the branch to match the task.
- Switch work with `git checkout`, `git branch -m`, or `git checkout -b` as usual.
- **A branch can only be checked out in one workspace at a time.** If blocked, switch the other workspace to another branch or create a new branch from the desired one.

## Parallel agents

**⌘N** opens another workspace; each agent works in an **isolated** tree so concurrent runs don't stomp the same working copy ([Parallel agents](https://docs.conductor.build/core/parallel-agents)).

## Checkpoints

[Checkpoints](https://docs.conductor.build/core/checkpoints) snapshot per-turn code changes and allow revert from the chat UI. Revert is destructive for messages and code after the chosen turn. **Use extra care if multiple chats run in the same workspace** — checkpoints are Claude Code–only and stored separately from normal branch history.

## Todos

[Todos](https://docs.conductor.build/core/todos) live in the notes tab; incomplete todos can **block merging**. Reference them in composer with **`@todos`**.

## Diff viewer

[Diff viewer](https://docs.conductor.build/core/diff-viewer) shows agent-made changes and aligns with steps toward merge/PR.

## Git and PRs

- **Permission and safety:** `/git-workflows` (commit/push gates, fetch-before-diff, SSH, etc.).
- **Base branch and PR prose:** `/pr-guidelines` — first step when choosing base is still **Conductor target branch** when present.

## Official documentation

Full index: [docs.conductor.build/llms.txt](https://docs.conductor.build/llms.txt). Starting points:

- [Workflow](https://docs.conductor.build/workflow)
- [Workspaces and branches](https://docs.conductor.build/tips/workspaces-and-branches)
- [Conductor environment variables](https://docs.conductor.build/tips/conductor-env)
- [From issue to PR](https://docs.conductor.build/guides/issue-to-pr)
- Core: [Parallel agents](https://docs.conductor.build/core/parallel-agents), [Diff viewer](https://docs.conductor.build/core/diff-viewer), [Checkpoints](https://docs.conductor.build/core/checkpoints), [Todos](https://docs.conductor.build/core/todos), [Scripts](https://docs.conductor.build/core/scripts), [MCP](https://docs.conductor.build/core/mcp)
