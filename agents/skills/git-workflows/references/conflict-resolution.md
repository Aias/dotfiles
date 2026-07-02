# Conflict Resolution

Use when resolving merge or rebase conflicts.

## Authority and checkpoints

- **No surprise finalization:** Do not complete `git merge` (commit), `git rebase --continue`, or any push without the user's **explicit** go-ahead. Treat each of those as a separate permission.
- **Review before apply:** After analyzing a conflict (or a coherent batch of conflicts in one file), present the proposed resolution — file(s), what each side was doing, and the merged outcome (or options if ambiguous). **Stop.** Only apply after the user approves (or selects among options).
- **Interactive prompts:** Use `AskUserQuestion` (or an equivalent) at checkpoints: e.g. approve this resolution, choose strategy A/B, proceed to staging, proceed to continue rebase, proceed to push. If that tool is unavailable, ask in plain messages and wait for a clear yes/no or choice.

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
- **Checkpoint:** user approval required before editing the file.
- After applying an approved resolution, confirm that conflict markers are gone and the file is internally consistent before moving to the next conflict.

How you edit (patch tool, structured replace, shell, etc.) is up to you; the requirement is correct merged content and no leftover markers.

### 4. Staging and completion

- When all conflicts in scope are resolved and verified, **checkpoint:** ask whether to stage the resolved paths.
- After staging, show clean status for those paths and **checkpoint:** remind the user that merge commit, `git rebase --continue`, and push still require explicit permission per `/git-workflows`.
- **Do not** run `git commit`, `git rebase --continue`, or `git push` unless the user has clearly authorized that step.

## Special cases

**Lock files** (`pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, etc.): Often both modified without inline markers. Typical pattern: align with one side or the other as a starting point, then **regenerate** the lockfile with the project's canonical install/update command so it matches the merged `package.json` (or monorepo equivalent).

**Generated artifacts** (GraphQL types, codegen output, etc.): Prefer consistency with the chosen source side, then regenerate if the repo has a standard codegen step.

<!-- @> Rebase: run /orient first to map the change-set vs the base. A rebased branch needs a force-push, which the agent never runs (see /git-workflows) — hand it back for the user to push, even after they approve the resolution. Regenerate codegen after the rebase lands -->
## Rebasing (workflow)

**Before starting:** Run `/orient` first to map the change-set and how far the base has moved — what the branch is doing and its relationship to the base. Fetch the remote base you will rebase onto (`origin/<target>` or equivalent) so comparisons aren't stale.

**During:** Resolve conflicts using the same propose → approve → apply loop. After conflicts for the current stopped commit are fixed and staged, **checkpoint** before `git rebase --continue` — the user must explicitly agree to continue the rebase.

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
