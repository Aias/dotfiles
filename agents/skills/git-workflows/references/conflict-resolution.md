# Conflict Resolution

Use when resolving merge or rebase conflicts.

## Authority and checkpoints

Require explicit authorization for the merge or rebase before starting it. Existing approval covers routine conflict resolution and continuation within the agreed approach. Present unresolved semantic choices before applying them. Keep commit and push permissions separate, and never force-push.

Use the active harness's supported approval mechanism for a reserved action. Use clarification tools only for decisions their schema permits.

## Workflow

### 1. Situate the operation

- Confirm whether this is a **merge** or **rebase** and which branches/commits are involved.
- Inspect repository state (e.g. `git status`) to list unmerged paths and what's expected next.

Use whatever safe commands or tools fit the environment to gather that context.

### 2. Understand each conflict

For each conflicted region (or file, if the whole file is in dispute):

- Locate conflict markers or, for binary / lockfile-style conflicts, the fact that Git reports both sides modified without markers.
- Map sides to meaning: for **merge**, ours/theirs follow normal merge semantics; for **rebase**, ours is the branch you're rebasing onto and theirs is the replayed commit — the labels are reversed vs merge.
- Decide strategy: combine independent work, pick one implementation, or synthesize; ensure imports, types, and references stay coherent.

### 3. Propose, then apply

- **Name branches explicitly:** When describing each side, use the actual branch names (and short commit subjects if helpful) rather than pronouns like "ours / theirs / yours / HEAD side". Especially during rebase, where ours/theirs are reversed vs. merge, branch names remove ambiguity. If you do use a pronoun, pair it with the branch name (e.g. "HEAD (origin/dev)").
- Present path, a short description of each side, and the **proposed** resolved content (or a clear preview/summary).
- Ask before applying a resolution that changes the agreed behavior or leaves a semantic choice unresolved.
- After applying an approved resolution, confirm that conflict markers are gone and the file is internally consistent before moving to the next conflict.

How you edit (patch tool, structured replace, shell, etc.) is up to you; the requirement is correct merged content and no leftover markers.

### 4. Staging and completion

- When all conflicts in scope are resolved and verified, stage the resolved paths within the approved operation.
- After staging, verify the operation state and continue within its authorization. Commit and push require their own authorization per `/git-workflows`.
- **Do not** run `git commit`, `git rebase --continue`, or `git push` unless the user has clearly authorized that step.

<!-- @> Generated artifacts and lockfiles: never hand-merge, conflict or not — a generated file stays a build output regardless of where or when it's edited. Reset the file to one side wholesale, rerun the generator, then diff against the base to confirm only the replayed commit's changes appear -->
## Special cases

**Lock files** (`pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, etc.): Often both modified without inline markers. Typical pattern: align with one side or the other as a starting point, then **regenerate** the lockfile with the project's canonical install/update command so it matches the merged `package.json` (or monorepo equivalent).

**Generated artifacts** (codegen output, typed API clients, compiled assets): Never hand-merge one. A generated file is a generated file regardless of where or when it is being edited, and a conflict is not an exception — resolving hunks by hand is hand-editing a build output. Reset the whole file to one side (usually the base), then rerun the generator so the output derives from the merged inputs.

Per-hunk resolution is tempting because each hunk looks individually decidable, and it is wrong for a reason the markers hide: the two sides are independent generator runs, so they may order, relocate, or reformat blocks differently even where they agree on content. Choosing per hunk yields a file the generator would never emit, and the next regeneration silently reverts it.

Verify by diffing the regenerated file against the base. The delta should contain only what the replayed commit's source changes imply — anything else is schema or dependency drift that does not belong in this commit.

<!-- @> Rebase: recover missing branch context with /orient before planning. A rebased branch needs a force-push, which the agent never runs (see /git-workflows) — hand it back for the user to push, even after they approve the resolution. Regenerate codegen after the rebase lands -->
## Rebasing (workflow)

**Before starting:** Establish the branch objective and its relationship to the base. Use `/orient` when that context is missing or stale. Fetch the remote base you will rebase onto (`origin/<target>` or equivalent) so comparisons aren't stale.

**During:** Resolve conflicts within the approved approach and continue the rebase. Pause for unresolved semantic choices or a change in scope.

**Abort / skip:** If the user wants to abandon the rebase, use `git rebase --abort`. `git rebase --skip` only when a commit is truly obsolete — confirm with the user.

**Regenerate at the end:** Rebasing onto a moved base can drift generated artifacts even where no file conflicted (e.g. the base advanced a schema). After the rebase lands, rerun the project's codegen and verify a clean tree before handoff.

**Push:** A rebased branch needs a force push, and per `/git-workflows` the agent never force-pushes under any circumstances. Hand the branch back for the user to push manually — show the force-push command if helpful, but do not run it, even after the user has approved the resolution.

## Principles

- Default assumption: the branch you're rebasing onto often has newer shared conventions; preserve the **intent** of replayed commits rather than blindly keeping old text.
- Prefer combining independent changes; watch cross-file dependencies (imports, configs).
- Split the review when one resolution bundles unrelated decisions (a logic change plus formatting-only churn) — one approval per coherent decision, not per file.
- The same region conflicting across 3+ commits is a signal, not a chore: propose squashing the offending commits or `git rerere` instead of re-resolving the identical conflict each time.
- If conflict volume is unmanageable, discuss merge vs rebase or selective cherry-picks with the user before proceeding.

## Recovery

If something goes wrong after a rebase, `git reflog` can help locate the pre-rebase HEAD; involve the user before rewriting history further.
