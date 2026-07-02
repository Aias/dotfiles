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

## Context

- Branch: !`git branch -vv 2>/dev/null | grep '^\*' || echo "not in a git repo"`
- Status: !`git status --short 2>/dev/null`
- Recent commits: !`git log --oneline -5 2>/dev/null`

## When to Use

| Situation                             | Workflow                                                 |
| ------------------------------------- | -------------------------------------------------------- |
| Creating or updating a PR             | `/pr-guidelines`                                         |
| Rebasing or resolving merge conflicts | [conflict-resolution](references/conflict-resolution.md) |

## General Principles

<!-- @> Read-only on git status/diff. Commit/push/reset need explicit permission — commit and push are separate gates. Never force-push -->

**Read-only by default:** When inspecting `git status` or `git diff`, treat them as read-only context. Never revert or assume missing changes were yours. Other agents or the user may have already committed updates.

**Explicit permission required:** Do not run `git commit`, `git push`, `git reset`, or similar without explicit user permission. Treat commit and push as separate permission gates — "commit these changes" does not imply "and push." Wait for explicit push permission.

**Never force push.** Do not run `git push --force`, `--force-with-lease`, or any force-push variant under any circumstances. If remote history needs rewriting, the user will do it manually.

**Pre-commit checks are mandatory:** Always run the project's standard lint, typecheck, format, and aggregate check scripts before any commit — not only before PRs. Fix any failures before committing.

**Commit scope awareness:** Before committing, review what's staged. Never commit temporary debugging instrumentation, one-off migration scripts, or exploratory code unless the user explicitly asks. If you added `console.log` or debug logging during investigation, clean it up before committing.

**Repository operations:**

- Always use SSH URLs for cloning (e.g., `git@github.com:user/repo.git`), never HTTPS
- Never use `git commit --amend` unless the user specifically requests it; prefer creating new commits over rewriting history

**Commit authorship:** single authorial point of view, no AI attribution — see GLOBAL.md Permission & Risk Guardrails.

<!-- @> Never edit on a long-lived branch (dev, main) — branch first, or use a dedicated worktree for cross-repo work. Catch work that landed on the wrong branch and move it (stash/cherry-pick) before committing -->

**Work on a feature branch, never a long-lived one:** Don't make feature edits directly on a shared long-lived branch (`dev`, `main`). Branch first; for cross-repo work, each repo gets its own worktree on a ticket-named branch (see `/conductor`). If edits already landed on the wrong branch, move them to the right one before committing — stash and pop onto a fresh branch, or cherry-pick — rather than committing in place.

<!-- @> Always fetch and diff against origin/<base>, never local branches — local refs go stale silently. Diff with three dots (origin/<base>...HEAD = merge-base→HEAD, matches GitHub); two-dot inflates with changes the base absorbed. Semantics flip for log, where two-dot is correct. Change size = +added/−removed from --shortstat or the PR's own counts, never wc -l of a raw diff (context + headers ≈ 2× overstatement) -->

**PR context:**

- Always `git fetch origin <base>` before diffing or rebasing. Diff against `origin/<base>`, never a local branch — local branches go stale silently and produce inaccurate diffs. The remote ref is the source of truth.
- Diff with three dots (`git diff origin/<base>...HEAD`) — merge-base to HEAD, matching GitHub's PR view. Two-dot is symmetric and inflates the diff with changes the base has absorbed since the branch point. The semantics flip for `log`, where two-dot (`origin/<base>..HEAD`, "commits in HEAD not in base") is what you want.
- Report change size as `+added / −removed` from `git diff --shortstat` (or the PR's own `additions`/`deletions`), never `wc -l` of a raw diff — unchanged context plus `@@`/`+++` headers overstate the change, often by roughly 2×.
- Before creating a branch or PR, verify the correct base — see `/pr-guidelines` for the resolution order. Getting the base wrong is the single most common git mistake.

<!-- @> Present commits chronologically (oldest first) when summarizing for the user — `git log`'s default reverse order makes review awkward -->

**Presenting commits to the user:** When summarizing a series of commits — branch state, PR breakdown, work recap — list them in the order they were authored (oldest first), not in the reverse-chronological order `git log` shows by default. The user reviews work in the order it actually happened.

## Conflict markers

Conflict regions (`<<<<<<<`, `=======`, `>>>>>>>`) sometimes fail naive search-and-replace or line-based edits. Use whatever approach reliably reads and writes the exact file content. Follow [conflict-resolution](references/conflict-resolution.md) for checkpoints, user approval, and completion rules.
