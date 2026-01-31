# Rebasing Workflow

Use this workflow when rebasing a branch onto another branch (typically to update a feature branch with the latest changes from `dev` or `main`).

## Before Starting

1. **Check context first** — Review PR comments, line-level feedback, and any discussion to understand:

   - What the branch was trying to accomplish
   - Any feedback that should be addressed during the rebase
   - Whether there are known conflicts or areas of concern

2. **Verify the target branch is up to date:**
   ```bash
   git fetch origin <target-branch>
   ```

## Step 1: Start the Rebase

```bash
git rebase origin/<target-branch>
```

If you need to rebase interactively (squash commits, reorder, etc.):

```bash
git rebase -i origin/<target-branch>
```

**Note:** Do not use interactive rebase (`-i`) in automated contexts—it requires manual editor interaction.

## Step 2: Handle Conflicts

When conflicts occur, git will pause and show which files have conflicts.

1. **Understand the current commit being applied:**

   ```bash
   git rebase --show-current-patch --stat
   ```

2. **For each conflict, resolve using the [conflict-resolution workflow](conflict-resolution.md)**

3. **After resolving conflicts in a file:**

   ```bash
   git add <resolved-file>
   ```

4. **Explain each resolution to the user:**

   - What the base branch had (it's more up-to-date, prefer its logic)
   - What the commit being applied wanted to change (identify its true _intent_)
   - Why the resolution is correct (keep base structure, layer commit's intent on top)

5. **Wait for user confirmation** before continuing

## Step 3: Continue or Abort

**After resolving all conflicts for a commit:**

```bash
git rebase --continue
```

**If the rebase should be abandoned:**

```bash
git rebase --abort
```

This restores the branch to its state before the rebase started.

**If you need to skip a commit entirely:**

```bash
git rebase --skip
```

Use sparingly—only when a commit is entirely superseded by the target branch.

## Step 4: Push the Rebased Branch

After the rebase completes:

```bash
git push --force-with-lease origin <branch-name>
```

**Use `--force-with-lease` instead of `--force`:** It fails if someone else pushed to the branch, preventing accidental overwrites.

**Warning:** Force pushing rewrites history. Only do this on feature branches, never on shared branches like `main` or `dev`.

## Key Principles

**Default assumption:** The branch being rebased onto has better/newer patterns. Our commits should only override target branch code when that was their explicit purpose.

**Ours vs Theirs is swapped:** During a rebase:

- "Ours" = the target branch (what you're rebasing onto)
- "Theirs" = your commits being applied

This is the opposite of merge conflict terminology.

**Preserve commit intent:** When resolving conflicts, don't just pick one side. Understand what the commit was trying to do and apply that intent to the new base.

## Common Issues

**Repeated conflicts:** If the same conflict keeps appearing across multiple commits, consider:

- Squashing related commits before rebasing
- Using `git rerere` to record conflict resolutions

**Diverged too far:** If the branch has diverged significantly and conflicts are overwhelming:

- Consider a merge instead of rebase
- Or create a new branch and cherry-pick specific commits

**Lost changes after rebase:** Check `git reflog` to find the pre-rebase state:

```bash
git reflog
git checkout <pre-rebase-sha>
```
