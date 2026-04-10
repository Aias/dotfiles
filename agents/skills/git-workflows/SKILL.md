---
name: git-workflows
description: >
  Use when git operations, merge/rebase (including conflicts), branches, fetch/pull, stash, cherry-pick,
  or commit/push/reset permission questions. For PR prose, titles, bases, and `gh pr` authoring, use
  `/pr-guidelines` instead. In Conductor workspaces (paths, CONDUCTOR_*, target branch), also read `/conductor`.
  Covers workflow norms and explicit permission gates.
compatibility: Requires git and GitHub CLI (gh).
global_category: Git
---

# Git Workflows

A collection of git-related workflows and guidelines. Use this skill for any git or version control task. In **Conductor**, worktrees share `origin` with other workspaces — pair with `/conductor` for layout, env vars, and target-branch context.

## When to Use

| Situation                             | Workflow                                                 |
| ------------------------------------- | -------------------------------------------------------- |
| Creating or updating a PR             | `/pr-guidelines`                                         |
| Rebasing or resolving merge conflicts | [conflict-resolution](references/conflict-resolution.md) |

## General Principles

<!-- @> Read-only on git status/diff. Explicit permission for commit/push/reset -->

**Read-only by default:** When inspecting `git status` or `git diff`, treat them as read-only context. Never revert or assume missing changes were yours. Other agents or the user may have already committed updates.

**Explicit permission required:** Do not run `git commit`, `git push`, `git reset`, or similar without explicit user permission. Treat commit and push as separate permission gates — "commit these changes" does not imply "and push." Wait for explicit push permission.

**Never force push.** Do not run `git push --force`, `--force-with-lease`, or any force-push variant under any circumstances. If remote history needs rewriting, the user will do it manually.

**Pre-commit checks are mandatory:** Always run the project's standard lint, typecheck, format, and aggregate check scripts before any commit — not only before PRs. Fix any failures before committing.

**Commit scope awareness:** Before committing, review what's staged. Never commit temporary debugging instrumentation, one-off migration scripts, or exploratory code unless the user explicitly asks. If you added `console.log` or debug logging during investigation, clean it up before committing.

**Repository operations:**

- Always use SSH URLs for cloning (e.g., `git@github.com:user/repo.git`), never HTTPS
- Never use `git commit --amend` unless the user specifically requests it; prefer creating new commits over rewriting history

**Commit authorship:**

- Commit messages and PR descriptions should have a single point of view—write as the author, not as an AI assistant
- No "Generated with Claude" footers, no co-authored-by AI attribution, no "I helped implement" phrasing
- Strip non-essential information from commit/PR messages—focus on what changed, not how it was written

<!-- @> Always fetch and diff against origin/<base>, never local branches. Local branches go stale silently -->

**PR context:**

- Always `git fetch origin <base>` before diffing or rebasing. Diff against `origin/<base>`, never a local branch — local branches go stale silently and produce inaccurate diffs. The remote ref is the source of truth.
- Before creating a branch or PR, verify the correct base — see `/pr-guidelines` for the resolution order. Getting the base wrong is the single most common git mistake.

## Conflict markers

Conflict regions (`<<<<<<<`, `=======`, `>>>>>>>`) sometimes fail naive search-and-replace or line-based edits. Use whatever approach reliably reads and writes the exact file content. Follow [conflict-resolution](references/conflict-resolution.md) for checkpoints, user approval, and completion rules.
