---
name: git-workflows
description: Git and version control workflows including creating PRs, updating or writing PRs, rebasing, conflict resolution, and commit conventions. Use when working with git commands, pull requests, resolving merge conflicts, or managing version control.
compatibility: Requires git and GitHub CLI (gh).
global_category: Git
---

# Git Workflows

A collection of git-related workflows and guidelines. Use this skill for any git or version control task.

## When to Use

| Situation                             | Workflow                                                |
| ------------------------------------- | ------------------------------------------------------- |
| Creating or updating a PR             | `pr-guidelines` skill                                   |
| Rebasing or resolving merge conflicts | [conflict-resolution](references/conflict-resolution.md) |

## General Principles

<!-- @> Read-only on git status/diff. Explicit permission for commit/push/reset -->

**Read-only by default:** When inspecting `git status` or `git diff`, treat them as read-only context. Never revert or assume missing changes were yours. Other agents or the user may have already committed updates.

**Explicit permission required:** Do not run `git commit`, `git push`, `git reset`, or similar without explicit user permission. Treat commit and push as separate permission gates — "commit these changes" does not imply "and push." Wait for explicit push permission.

**Pre-commit checks are mandatory:** Always run available lint, typecheck, and format commands before any commit — not just PR submissions. If a project has `bun check`, `rush lint`, `pnpm typecheck`, or similar, run them. Fix any issues before committing.

**Commit scope awareness:** Before committing, review what's staged. Never commit temporary debugging instrumentation, one-off migration scripts, or exploratory code unless the user explicitly asks. If you added `console.log` or debug logging during investigation, clean it up before committing.

<!-- @> SSH URLs. Never amend unless explicitly requested; prefer new commits -->

**Repository operations:**

- Always use SSH URLs for cloning (e.g., `git@github.com:user/repo.git`), never HTTPS
- Never use `git commit --amend` unless the user specifically requests it; prefer creating new commits over rewriting history

<!-- @> Single POV as author. No AI attribution or co-authorship -->

**Commit authorship:**

- Commit messages and PR descriptions should have a single point of view—write as the author, not as an AI assistant
- No "Generated with Claude" footers, no co-authored-by AI attribution, no "I helped implement" phrasing
- Strip non-essential information from commit/PR messages—focus on what changed, not how it was written

<!-- @> Always fetch and diff against origin/<base>, never local branches. Local branches go stale silently -->

**PR context:**

- Always `git fetch origin <base>` before diffing or rebasing. Diff against `origin/<base>`, never a local branch — local branches go stale silently and produce inaccurate diffs. The remote ref is the source of truth.
- Before creating a branch or PR, verify the correct base — see the `pr-guidelines` skill for the resolution order. Getting the base wrong is the single most common git mistake.

## Tool Notes

The `Read` and `StrReplace` tools may have difficulty with conflict markers. During testing, `StrReplace` failed to match text containing `<<<<<<<`/`=======`/`>>>>>>>` sequences even when the exact text was confirmed present via shell commands. Use shell commands instead:

- **View conflicts:** `sed -n '<start>,<end>p' <file>` or `bat --plain -r <start>:<end> <file>`
- **Apply resolutions:** head/tail reconstruction (see conflict-resolution workflow)
- **Verify resolution:** `rg "^<<<<<<" <file>` or `git diff --check`
