---
name: git-workflows
description: Git and version control workflows including creating PRs, rebasing, conflict resolution, and commit conventions. Use when working with git commands, creating PRs, resolving merge conflicts, or managing version control.
compatibility: Requires git and GitHub CLI (gh).
---

# Git Workflows

A collection of git-related workflows and guidelines. Use this skill for any git or version control task.

## When to Use

| Situation                                    | Workflow                                                |
| -------------------------------------------- | ------------------------------------------------------- |
| Creating a PR from uncommitted/local changes | [fresh-pr](workflows/fresh-pr.md)                       |
| Rebasing a branch onto another               | [rebasing](workflows/rebasing.md)                       |
| Resolving merge or rebase conflicts          | [conflict-resolution](workflows/conflict-resolution.md) |

## General Principles

**Read-only by default:** When inspecting `git status` or `git diff`, treat them as read-only context. Never revert or assume missing changes were yours. Other agents or the user may have already committed updates.

**Explicit permission required:** Do not run `git commit`, `git push`, `git reset`, or similar without explicit user permission. Prefer proposing diffs.

**Repository operations:**

- Always use SSH URLs for cloning (e.g., `git@github.com:user/repo.git`), never HTTPS
- Never use `git commit --amend` unless the user specifically requests it; prefer creating new commits over rewriting history

**Commit authorship:**

- Commit messages and PR descriptions should have a single point of view—write as the author, not as an AI assistant
- No "Generated with Claude" footers, no co-authored-by AI attribution, no "I helped implement" phrasing
- Strip non-essential information from commit/PR messages—focus on what changed, not how it was written

## Tool Notes

The `Read` and `StrReplace` tools may have difficulty with conflict markers. During testing, `StrReplace` failed to match text containing `<<<<<<<`/`=======`/`>>>>>>>` sequences even when the exact text was confirmed present via shell commands. Use shell commands instead:

- **View conflicts:** `sed -n '<start>,<end>p' <file>` or `bat --plain -r <start>:<end> <file>`
- **Apply resolutions:** head/tail reconstruction (see conflict-resolution workflow)
- **Verify resolution:** `rg "^<<<<<<" <file>` or `git diff --check`

## Guidelines

- Prefer combining changes when they're independent
- Look at imports and surrounding code—one side may add dependencies the other needs
- For rebases, "ours" and "theirs" are swapped vs merges
- If a resolution is complex, break it into smaller pieces for review
