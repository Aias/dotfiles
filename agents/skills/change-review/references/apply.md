# APPLY Mode

Make changes. Two entry paths:

1. **From a prior REVIEW.** The user has picked items by number (*"fix 2, 3, 5"*, *"do all 4"*, *"in stages, dead code first"*). Execute only the picked items.
2. **Standalone cleanup intensity.** The user named the depth: deslop, refactor pass, or targeted picks against the diff.

## Standing rules

- **Don't expand scope.** When modifying a function, you may clean obvious decay within it. Do not expand to sibling files or unrelated modules without asking. *"Don't refactor what I didn't ask about"* is a repeated correction.
- **Coherent steps.** Split substantial cleanup by concern and continue through the authorized work. Pause at a user-requested checkpoint, unresolved design choice, or reserved action.
- **Commits follow GLOBAL.md.** Commit cleanup to the working branch when the task calls for it. When the user says *"don't commit"* or asks to review first, leave the changes uncommitted.
- **Cleanup commits live on top, not folded.** *"Fix and commit as a single cleanup commit on top, we don't need to do this as part of the rebase."* Don't `git commit --amend` or `git rebase -i` to fold cleanup into prior commits unless the user asks.
- **Resolve only mechanical conflicts.** During an authorized rebase, resolve independent hunks yourself and rerun generators for generated files. Where both sides changed behavior, propose a resolution and wait for the user to confirm or deny.
- **Stub sweep before handoff.** Before declaring done, `rg` the touched feature for `stub`/`mock`-prefixed identifiers, hardcoded fixture arrays, and literals that mirror enum or option labels, and remove them.
- **PR description sync.** When cleanup changes claims in the PR body, draft the refreshed description per `/pr-guidelines`. Publish it only when PR editing is authorized.

## Workflow shape

A pick by number, or a named intensity (deslop, refactor pass), authorizes the cleanup. Identify the in-scope items, apply the clear ones, and run build/tests. Report the applied items numbered, largest-to-smallest, each with a one-line description, affected file(s), and scope tag (structural / cosmetic / deletion), so the user can revert any item by number. Bring an item to the user as a numbered decision only when it needs a product or design choice or reaches past the change-set.

## Light: deslop

**Trigger:** *"deslop"*, *"remove slop"*, *"clean up the AI stuff"*. Strips AI-generated artifacts. **No structural changes.**

See also: `/pr-guidelines` (prose in PR descriptions), `/write` (prose style).

### Workflow

1. Find the comparison commit — either the open PR's base or the commit this branch was created from.
2. Read the branch diff and staged changes.
3. Identify AI artifacts introduced since the comparison commit (see [Shared Principles](../SKILL.md#shared-principles)).
4. Remove them. **Do not** change control flow, remove parameters, or restructure logic — cosmetic only.

## Heavy: refactor pass

**Trigger:** *"refactor pass"*, *"tighten up"*, *"dead code"*. Structural cleanup after recent changes.

### Workflow

1. Review the changes just made and identify simplification opportunities:
   - Dead code and dead paths.
   - Uncovered dead code — utilities, tokens, fixtures, GraphQL fields no longer referenced after a deletion. Use `bunx knip` / `bunx deslop-cli` to surface leads and `rg` / `git grep` to confirm a symbol is truly orphaned before removing it; a tool hit is a lead, not a license to delete.
   - Logic flows that can be straightened.
   - Excessive parameters or "parameter sprawl" — adding a new parameter when generalizing/restructuring would be cleaner.
   - Premature optimization.
   - Copy-paste with slight variation — near-duplicate blocks that should be unified.
   - Stringly-typed code where enums/branded types already exist.
   - [Shared Principles](../SKILL.md#shared-principles) violations (stubs, comment policy, list ordering).
   - **Rule of Three:** three or more copies of a pattern is a signal to extract a shared abstraction — *only if* the copies share both shape and reason-for-change (they'd be edited together for the same future request). Copies that look alike today but answer different questions stay separate.
2. Apply the refactors and run build/tests to verify behavior.

## Targeted picks

**Trigger:** *"fix 2, 3, 5"*, *"do all 4"*, *"do 1 and 2 if possible"*, *"in stages, X first"*. Execute selected findings from a prior REVIEW.

### Workflow

1. Re-read the cited code for each picked item. Verify the finding is still accurate — the diff may have shifted under the review.
2. If picks span multiple phases ("dead code first, then consolidation"), execute them in the stated order, one commit per phase when committing. Pause between phases only when the user asked to review each stage.
3. For each pick, make the change. Keep the diff minimal — no opportunistic edits to surrounding code.
4. Run typecheck / build / tests after each phase (not after each pick — that's noisy).
5. Report: what was fixed, what was deferred, any picks that turned out to be false positives on closer reading.

If a pick turns out to be wrong on closer reading, **say so and skip it.** Don't fix the wrong thing because the user asked.

## When the user said "but don't commit"

The user wants to see the working-tree diff before any commit happens. After APPLY:

- Leave changes uncommitted.
- Summarize what changed in one or two sentences.
- Wait for *"commit and push"*, *"commit each as a separate commit"*, or further edits.

## After APPLY

End the session with:

- **Summary.** One or two sentences. What changed. What's still deferred.
- **Next handoff.** One of:
  - *Refreshed PR description drafted or published* — if the diff changed enough to invalidate claims in the description.
  - *Continue with phase 2* — if the user asked to review each phase.
  - *Open a follow-up PR for X* — if cleanup uncovered work that's out-of-scope for this PR.
  - *No further action* — when the cleanup is complete and the PR is current.

Don't offer to stop the session. The user will say when they're done.
