# Conflict Resolution

Use when resolving merge or rebase conflicts.

## Identify Conflicts

1. Run `git status` to find conflicted files (under "Unmerged paths")
2. Get context on what's being merged:
   - **Merge:** `git log --oneline -1 MERGE_HEAD`
   - **Rebase:** `git rebase --show-current-patch --stat`

## Analyze Each Conflict

For each conflicted file:

### Find conflict boundaries

```bash
rg -n "^<<<<<<|^>>>>>>>" <file>
```

Note line numbers:

- `start_line` = line with `<<<<<<<`
- `end_line` = line with `>>>>>>>`

### View the conflict block

```bash
sed -n '<start_line>,<end_line>p' <file>
```

### Identify what each side changed

- **HEAD / ours**: Your branch (merge) or target branch (rebase)
- **Base**: Common ancestor (between `|||||||` and `=======`)
- **Theirs**: Incoming branch (merge) or your commit (rebase)

### Determine resolution strategy

- Independent additions → combine both
- Competing implementations → choose one or hybrid
- Check if referenced variables/imports from either side are needed

## Propose and Apply Resolutions

For each conflict, present to the user:

- File path and line numbers
- Summary of each side's changes
- Proposed resolution with code preview

**Wait for user confirmation before applying.**

Use head/tail to reconstruct the file:

```bash
{
  head -$((start_line - 1)) <file>
  cat << 'RESOLVED'
<resolved code here>
RESOLVED
  tail -n +$((end_line + 1)) <file>
} > /tmp/fixed && mv /tmp/fixed <file>
```

**Verify immediately after each resolution:**

```bash
rg "^<<<<<<" <file> && echo "CONFLICT REMAINS" || echo "OK"
```

Do not proceed to the next file until verification passes.

## Special Cases

**Lock files (pnpm-lock.yaml, package-lock.json, yarn.lock):**

- Often show as "both modified" (UU) without text conflict markers
- Resolution: `git checkout --theirs <lockfile>` then regenerate (`rush update`, `npm install`, etc.)

**Generated files (GraphQL types, etc.):**

- Prefer taking the more complete version (usually theirs/dev)
- Regenerate after merge to ensure consistency

## Completion

1. **Verify all conflicts resolved:**

   ```bash
   git diff --check
   ```

2. **Stage resolved files:**

   ```bash
   git add <resolved files>
   ```

3. **Show `git status`** — files should appear under "Changes to be committed"

4. **Do NOT commit or finalize** — inform the user and provide the command:
   - Merge: `git commit`
   - Rebase: `git rebase --continue`

## Rebasing

### Before Starting

1. **Check context first** — Review PR comments, line-level feedback, and any discussion to understand:

   - What the branch was trying to accomplish
   - Any feedback that should be addressed during the rebase
   - Whether there are known conflicts or areas of concern

2. **Verify the target branch is up to date:**
   ```bash
   git fetch origin <target-branch>
   ```

### Start the Rebase

```bash
git rebase origin/<target-branch>
```

**Note:** Do not use interactive rebase (`-i`) in automated contexts — it requires manual editor interaction.

### Continue, Skip, or Abort

**After resolving all conflicts for a commit:**

```bash
git rebase --continue
```

**If the rebase should be abandoned:**

```bash
git rebase --abort
```

**If you need to skip a commit entirely:**

```bash
git rebase --skip
```

Use sparingly — only when a commit is entirely superseded by the target branch.

### Push the Rebased Branch

```bash
git push --force-with-lease origin <branch-name>
```

Use `--force-with-lease` instead of `--force` — it fails if someone else pushed to the branch, preventing accidental overwrites.

**Warning:** Force pushing rewrites history. Only do this on feature branches, never on shared branches like `main` or `dev`.

### Key Principles

**Default assumption:** The branch being rebased onto has better/newer patterns. Our commits should only override target branch code when that was their explicit purpose.

**Ours vs Theirs is swapped:** During a rebase:

- "Ours" = the target branch (what you're rebasing onto)
- "Theirs" = your commits being applied

This is the opposite of merge conflict terminology.

**Preserve commit intent:** When resolving conflicts, don't just pick one side. Understand what the commit was trying to do and apply that intent to the new base.

### Common Issues

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

## Guidelines

- Prefer combining changes when they're independent
- Look at imports and surrounding code — one side may add dependencies the other needs
- For rebases, "ours" and "theirs" are swapped vs merges
- If a resolution is complex, break it into smaller pieces for review
