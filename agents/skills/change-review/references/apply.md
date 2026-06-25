# APPLY Mode

Make changes. Two entry paths:

1. **From a prior REVIEW.** The user has picked items by number (*"fix 2, 3, 5"*, *"do all 4"*, *"in stages, dead code first"*). Execute only the picked items.
2. **Standalone cleanup intensity.** The user named the depth: deslop, refactor pass, or targeted picks against the diff.

## Standing rules

- **Don't expand scope.** When modifying a function, you may clean obvious decay within it. Do not expand to sibling files or unrelated modules without asking. *"Don't refactor what I didn't ask about"* is a repeated correction.
- **Phased over big-bang.** When the work spans multiple concerns (dead code + consolidation + token cleanup), propose a phased plan. Execute one phase, pause for review, then continue. *"Let's do this in stages"* and *"fix duplicate exports first since that's an easy win"* are the user's defaults.
- **Don't auto-commit.** The user reviews edits before commit. Default to leaving changes staged-but-uncommitted. *"Make all changes but don't commit, I'll review first"* is the standing pattern.
- **Cleanup commits live on top, not folded.** *"Fix and commit as a single cleanup commit on top, we don't need to do this as part of the rebase."* Don't `git commit --amend` or `git rebase -i` to fold cleanup into prior commits unless the user asks.
- **Don't auto-resolve conflicts or auto-push.** *"Don't auto-resolve without checking with me first, for any conflicts propose a resolution and allow me to confirm or deny."*
- **Stub sweep before handoff.** Before declaring done, `rg` the touched feature for `TODO: remove`, `MOCK`, `STUB`, hardcoded fixture arrays, and remove them.
- **PR description sync.** When cleanup changes claims in the PR body, suggest running `/pr-guidelines` to refresh the description. Don't edit it silently.

## Workflow shape

Every APPLY follows **explore → propose → approve → apply.**

1. **Explore.** Read the picked items (or the change-set, for standalone intensity). Identify everything in scope. Do not edit yet.
2. **Propose.** Present a numbered plan, ordered largest-to-smallest refactor. Each item: one-line description, affected file(s), scope tag (structural / cosmetic / deletion).
3. **Approve.** Ask the user to approve all, select by number, or deny. Wait. Don't slide from propose to apply.
4. **Apply.** Make approved changes. Run build/tests afterward. Report what changed in one or two sentences.

The proposal step is the same shape regardless of which entry path got you here.

## Light: deslop

**Trigger:** *"deslop"*, *"remove slop"*, *"clean up the AI stuff"*. Strips AI-generated artifacts. **No structural changes.**

See also: `/pr-guidelines` (prose in PR descriptions), `/write` (prose style).

### Workflow

1. Find the comparison commit — either the open PR's base or the commit this branch was created from.
2. Read the branch diff and staged changes.
3. Identify AI artifacts introduced since the comparison commit (see [Shared Principles](../SKILL.md#shared-principles)).
4. Present a numbered list of proposed removals, largest-to-smallest. One-line description, file(s), scope.
5. Approve all / select / deny.
6. Apply approved changes only. **Do not** change control flow, remove parameters, or restructure logic — cosmetic only.

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
   - **Rule of Three:** three or more copies of a pattern is a signal to extract a shared abstraction — *only if* the abstraction is clearer than the repetition.
2. Present a numbered plan, largest-to-smallest. Each item: description, file(s), scope.
3. Approve all / select by number / deny.
4. Apply only approved refactors.
5. Run build/tests to verify behavior.

## Targeted picks

**Trigger:** *"fix 2, 3, 5"*, *"do all 4"*, *"do 1 and 2 if possible"*, *"in stages, X first"*. Execute selected findings from a prior REVIEW.

### Workflow

1. Re-read the cited code for each picked item. Verify the finding is still accurate — the diff may have shifted under the review.
2. If picks span multiple phases ("dead code first, then consolidation"), execute phase 1 only. Pause and report before phase 2.
3. For each pick, make the change. Keep the diff minimal — no opportunistic edits to surrounding code.
4. Run typecheck / build / tests after each phase (not after each pick — that's noisy).
5. Report: what was fixed, what was deferred, any picks that turned out to be false positives on closer reading.

If a pick turns out to be wrong on closer reading, **say so and skip it.** Don't fix the wrong thing because the user asked.

## When the user said "but don't commit"

Default is no-commit anyway, but this phrase is load-bearing. The user wants to see the working-tree diff before any commit happens. After APPLY:

- Leave changes uncommitted.
- Summarize what changed in one or two sentences.
- Wait for *"commit and push"*, *"commit each as a separate commit"*, or further edits.

## After APPLY

End the session with:

- **Summary.** One or two sentences. What changed. What's still deferred.
- **Next handoff.** One of:
  - *Run `/pr-guidelines` to refresh the PR description* — if the diff changed enough to invalidate claims in the description.
  - *Continue with phase 2* — if the user picked phased work.
  - *Open a follow-up PR for X* — if cleanup uncovered work that's out-of-scope for this PR.
  - *No further action* — when the cleanup is complete and the PR is current.

Don't offer to stop the session. The user will say when they're done.
