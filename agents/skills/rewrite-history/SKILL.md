---
name: rewrite-history
description: >
  Use when rewriting git history while keeping the same tree—squash, reword, reorder commits, narrative
  commits, or cleanup before review/force-push. Triggers on "rewrite history", "clean up commits",
  "reorganize commits", "redo the history", "narrative commits". Requires authorization for the rewrite.
argument-hint: [base-branch]
allowed-tools: Bash(git:*), Read, Glob, Grep, Edit, Write
---

## Context

A history rewrite needs the current branch (`git branch --show-current`), a clean working tree (`git status --short`), and the verified base branch from Step 1 before anything else. Only with the base resolved do the commit range (`git log --oneline origin/<base>..HEAD`) and the diff stat (`git diff origin/<base>...HEAD --stat`) mean anything; never guess the base from a fixed candidate list. Read these in one batch, reuse the results within the session, and report a failing command rather than assuming the state it would have shown.

## Task

Rewrite the current branch's commit history with clean, narrative-quality commits. The final tree must be byte-for-byte identical to the current state — only the commits change, not the code.

This rewrites the current branch. When the branch is already published, the approved rewrite includes force-pushing it.

### Steps

1. **Determine the base branch**
   - If `$ARGUMENTS` is provided, use it as the base branch.
   - Otherwise, use the Conductor target, existing PR base, or documented repository convention. Ask when these leave the base ambiguous.
   - Fetch the verified base before analyzing the commit range.

2. **Validate preconditions**
   - Ensure no uncommitted changes (`git status --porcelain` must be empty)
   - Record the current tree SHA for later verification: `git rev-parse HEAD^{tree}`
   - Record the current branch name

3. **Analyze the full diff**
   - Study all changes between the current branch and the base branch
   - Understand the final intended state as a whole — files added, modified, deleted, and how they relate
   - Read changed files to understand the purpose and structure of the work
   - Review the existing commit history to understand what was done, but don't feel bound by it — the whole point is to tell a cleaner story

4. **Plan the commit storyline**
   - Break the implementation into self-contained logical steps — typically fewer commits than the original history
   - Each commit should represent a coherent, functional stage of development. A reviewer reading the PR commit-by-commit should see a clear progression where each step builds naturally on the last.
   - Strip out any dead ends, reverts, fixups, or back-and-forth from the original history. The rewritten history should read as if the implementation went smoothly from start to finish.
   - Aim for the smallest number of commits that are each independently valid but maximally separable — each commit should compile and work on its own, but no commit should mix unrelated concerns. New infrastructure before migration, migration before removal. Never delete code that is still referenced in a later commit.
   - Consider: what would a reviewer want to see first? What context do they need before the next piece makes sense?

   **Stop here. Present the proposed commit list — ordered, each with a one-line summary of intent — and wait for explicit confirmation before moving on.** Do not create `_rewrite-temp` or run any tree-mutating command until the user has approved the storyline. This is a destructive rewrite; the gate matters more than the time it costs.

5. **Rewrite the history**
   - Create a temporary branch from the branch's original merge-base, **not** from the current tip of `<base>`: `git checkout -b _rewrite-temp $(git merge-base origin/<base> <branch>)`. The tree-match check in step 6 fails if the base has advanced since the branch was created, because files outside the branch's own diff will differ. Rebase onto the current base afterward when the task calls for it.
   - Recreate changes commit by commit following the planned storyline
   - Each commit must:
     - Introduce a single coherent idea
     - Leave the codebase in a functional state — each commit should stand on its own as a reasonable checkpoint
     - Have a clear commit message (short summary line + description body when warranted)
   - Run required checks and hooks for every commit. Adjust the storyline if an intermediate commit cannot satisfy them.

6. **Verify byte-for-byte equivalence**
   - After the final commit, compare the tree SHA against the one recorded in step 2:
     ```
     [ "$(git rev-parse HEAD^{tree})" = "<saved-tree-sha>" ] && echo "MATCH" || echo "MISMATCH"
     ```
   - If they differ, diff the two trees to find the discrepancy and fix it before proceeding.
   - Confirm all required checks pass on the complete state.

7. **Move the branch**
   - Point the original branch at the rewritten history:
     ```
     git checkout <original-branch>
     git reset --hard _rewrite-temp
     git branch -d _rewrite-temp
     ```

8. **Report**
   - Show the new commit log: `git log <base>..HEAD --oneline`
   - When the rewritten commits replace published history, push with `git push --force-with-lease`. Ask first when the push could discard work you did not author, such as remote commits missing from the rewrite or a branch other people push to.

### Rules

- Commit authorship follows GLOBAL.md: single authorial point of view, no AI attribution or `Co-Authored-By` lines
- The final tree SHA must exactly match the original.
- Do not open a pull request — that is a separate workflow
- Force-push with `--force-with-lease`, never bare `--force`
