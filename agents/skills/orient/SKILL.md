---
name: orient
description: >
  Use when starting a session on an existing branch, resuming a long-running feature across sessions, or
  the user says "/orient", "get me up to speed", "catch me up", "what's going on here", "continue where
  we left off", "pick up where we left off", or "remind me where we are". Also trigger when a fresh agent
  session needs context on a non-trivial repo or branch it hasn't seen. Gathers branch state, open PR
  context, session notes, and recent activity into one structured summary so work can continue without
  replaying prior conversations.
global_category: Workflow
---

# Orient

Rebuilds agent context for the current repo and branch in a fresh session. The goal is a **short structured summary** the user can confirm before the agent continues work — not a dump of raw command output.

Pairs with `/conductor` (worktree layout, target branch, `.context/`), `/git-workflows` (fetch-before-diff, permissions), and `/pr-guidelines` (base resolution, PR prose). Defer to those skills rather than restating their mechanics here.

## Context

- Repo root: !`git rev-parse --show-toplevel 2>/dev/null`
- Branch: !`git branch --show-current 2>/dev/null`
- Short status: !`git status --short 2>/dev/null`
- Conductor env: !`env | grep '^CONDUCTOR_' 2>/dev/null || echo "not in Conductor"`
- Open PR: !`gh pr view --json number,title,state,isDraft,baseRefName,url 2>/dev/null || echo "none"`
- `.context/` present: !`[ -d .context ] && ls -1 .context 2>/dev/null | head -20 || echo "no"`

## Procedure

Read-only throughout. Run steps in order, skip ones that don't apply, and stop early if the branch is obviously a no-op (zero ahead commits, no PR, no `.context/`).

<!-- @> Resolve base via Conductor target → existing PR baseRefName → repo convention → ask. Then `git fetch origin <base>` before any diff — local refs go stale silently -->

### 1. Resolve the base and fetch

Use the resolution order from `/pr-guidelines`: `CONDUCTOR_DEFAULT_BRANCH` → existing PR's `baseRefName` → repo convention (usually `main`) → ask. Then `git fetch origin <base>` so every later diff is against the current remote, not a stale local ref.

### 2. Branch state vs base

- `git log --oneline origin/<base>..HEAD` — commits on this branch (two-dot is correct for `log`: "commits in HEAD not in base")
- `git log -1 --format='%cr — %s'` — how stale the branch is and the last thing done
- `git status --short` and `git stash list` — in-flight and shelved work

<!-- @> Diff against base uses three dots (`origin/<base>...HEAD`), not two. `..` is symmetric and includes changes the base has absorbed since the branch point, inflating the file list with work that isn't yours. `...` diffs from the merge-base and matches what GitHub shows. Prefer `gh pr view --json files` when a PR exists -->

- `git diff --stat origin/<base>...HEAD` — scope at a glance. **Three dots for `diff`, not two.** Two-dot is symmetric — it includes changes the base has absorbed since the branch point, inflating the file list with work that isn't yours. Three-dot diffs from the merge-base and matches what GitHub's PR view shows. When a PR exists, skip this and read files via `gh pr view --json files` in step 3 instead — the `gh` path can't be typo'd into the wrong form.

Note that the dot semantics **flip** between `log` and `diff`: `A..B` for `log` means "commits in B not in A" (what you want); `A...B` for `diff` means "merge-base to B" (what you want). If the `--stat` output is large, summarize by top-level directory rather than listing every file.

### 3. Open PR (if present)

When `gh pr view` returned a PR, read it in layers, cheapest first:

- **Title, body, state, base, draft flag** — from the JSON you already fetched.
- **Changed files** — `gh pr view --json files` for the authoritative list with additions/deletions per file. This uses the merge-base and is immune to the two-dot/three-dot gotcha; prefer it over `git diff --stat` when a PR exists.
- **Review comments** — `gh pr view --comments`. Unresolved threads almost always point at where the work was left.
- **Diff content** — `gh pr diff`. If the diff is long (>500 lines), read the head and summarize the rest file-by-file. The files themselves often reveal the feature's shape more clearly than the description.
- **CI** — `gh pr checks`. Failing checks are immediate context for what to do next.

### 4. Session state

<!-- @> `.context/` is gitignored inter-agent scratch; list it, read only files that look like active plans or recent notes (plan*.md, notes*.md, dated within a week). Some files are stale -->

- **`.context/`** (Conductor workspaces, gitignored): list with `ls -la .context/` rather than reading every file. Users drop plan docs, handoff notes, and inter-agent scratch here; some of it is stale. Read files that look active — `plan*.md`, `notes*.md`, anything dated within the last week — and surface the rest by filename so the user can point at specific ones.
- **Repo-level plan/spec files** on the branch: `plan.md`, `spec.md`, `TODO.md`, `.notes/` — surface them if they exist on the branch but not on the base.
- **Changed agent instructions**: if the branch modifies `AGENTS.md`, `CLAUDE.md`, or nested equivalents, read the diff. Agent-instruction changes are almost always load-bearing for what the branch is trying to do.

### 5. Repo basics (when unfamiliar)

If the agent already knows this repo, skip this step. Otherwise:

- Top-level `README.md`, `AGENTS.md`/`CLAUDE.md`, and package manifests (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`) to identify stack and entry points.
- For a genuinely unknown repo with real history, consult [references/fresh-repo-diagnostics.md](references/fresh-repo-diagnostics.md) for the churn / team / bug-cluster commands — run those before picking files to read.

## Output format

<!-- @> Synthesize into one structured summary, omit empty sections, end with a single "continue or redirect?" question. Never paste raw command output wholesale -->

Produce one summary. Omit sections that don't apply rather than showing them empty. Each line is one fact.

```
**Repo** <name> (<stack>)
**Branch** <name> — <n> ahead of origin/<base>, last touched <relative time>
**PR** #<num> "<title>" (<state>, base: <base>) — <url>
  <one-line synthesis of the PR's intent>
  <n unresolved comments> · CI: <status>
  Touches: <top-level dirs or notable files>
**In flight** <uncommitted file count>, <stashed count>
**Session notes** (`.context/`): <filenames, not contents>
**Repo docs** <AGENTS.md changed | plan.md present | etc>

**Where to pick up** <one or two sentences synthesized from PR body, recent commits, and session notes — the concrete next step, not a paraphrase of the description>
```

Finish with one question: *"Continue from here, or is there something specific you want to tackle first?"* This gives the user a chance to redirect before the agent acts on stale assumptions about which task is active.

## Principles

- **Read, don't mutate.** `git fetch` is fine; no stash manipulation, no checkout, no pull, no commits.
- **Cheap before expensive.** Branch metadata and PR JSON are instant; diffs, comments, and full file reads cost. Stop early when there's clearly nothing to orient to.
- **Synthesize, don't paste.** The value is in the short summary, not a transcript.
- **Trust cross-linked skills.** `/conductor`, `/git-workflows`, and `/pr-guidelines` already cover their domains; re-deriving their rules here just drifts out of sync.
