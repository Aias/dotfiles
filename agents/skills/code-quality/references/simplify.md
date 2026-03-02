# Simplify: Code Review and Cleanup

Review all changed files for reuse, quality, and efficiency. Fix any issues found.

## Phase 1: Identify Changes

Scope the diff to only the changes introduced by the current branch:

1. If a PR exists, use `gh pr diff` (or diff against the PR's base ref).
2. If no PR exists, find the merge-base with the parent branch (`git merge-base <base> HEAD`) and diff from there.
3. If there are no branch-level changes (e.g. working on an uncommitted feature), fall back to `git diff` / `git diff HEAD`.
4. If there are no git changes at all, review the most recently modified files that the user mentioned or that you edited earlier in this conversation.

Never diff the full range between two long-lived branches (e.g. `dev...HEAD`) — this pulls in unrelated merged work and pollutes the review.

## Phase 2: Launch Three Review Agents in Parallel

Use the Agent tool to launch all three agents concurrently in a single message. Pass each agent the full diff so it has the complete context.

### Agent 1: Code Reuse Review

For each change:

1. **Search for existing utilities and helpers** that could replace newly written code. Use Grep to find similar patterns elsewhere in the codebase — common locations are utility directories, shared modules, and files adjacent to the changed ones.
2. **Flag any new function that duplicates existing functionality.** Suggest the existing function to use instead.
3. **Flag any inline logic that could use an existing utility** — hand-rolled string manipulation, manual path handling, custom environment checks, ad-hoc type guards, and similar patterns are common candidates.

### Agent 2: Code Quality Review

Review the same changes for hacky patterns:

1. **Redundant state:** state that duplicates existing state, cached values that could be derived, observers/effects that could be direct calls
2. **Parameter sprawl:** adding new parameters to a function instead of generalizing or restructuring existing ones
3. **Copy-paste with slight variation:** near-duplicate code blocks that should be unified with a shared abstraction
4. **Leaky abstractions:** exposing internal details that should be encapsulated, or breaking existing abstraction boundaries
5. **Stringly-typed code:** using raw strings where constants, enums (string unions), or branded types already exist in the codebase

### Agent 3: Efficiency Review

Review the same changes for efficiency:

1. **Unnecessary work:** redundant computations, repeated file reads, duplicate network/API calls, N+1 patterns
2. **Missed concurrency:** independent operations run sequentially when they could run in parallel
3. **Hot-path bloat:** new blocking work added to startup or per-request/per-render hot paths
4. **Unnecessary existence checks:** pre-checking file/resource existence before operating (TOCTOU anti-pattern) — operate directly and handle the error
5. **Memory:** unbounded data structures, missing cleanup, event listener leaks
6. **Overly broad operations:** reading entire files when only a portion is needed, loading all items when filtering for one

## Phase 3: Fix Issues

Wait for all three agents to complete. Aggregate their findings and fix each issue directly. If a finding is a false positive or not worth addressing, note it and move on — do not argue with the finding, just skip it.

When done, briefly summarize what was fixed (or confirm the code was already clean).
