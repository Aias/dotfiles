# Conflict Resolution Workflow

Use this workflow when resolving merge or rebase conflicts. Can be invoked standalone or as part of the [rebasing workflow](rebasing.md).

## Step 1: Identify Conflicts

1. Run `git status` to find conflicted files (under "Unmerged paths")
2. Get context on what's being merged:
   - **Merge:** `git log --oneline -1 MERGE_HEAD`
   - **Rebase:** `git rebase --show-current-patch --stat`

## Step 2: Analyze Each Conflict

For each conflicted file:

### 2a: Find conflict boundaries (both start AND end)

```bash
rg -n "^<<<<<<|^>>>>>>>" <file>   # Shows paired start/end markers
```

Note line numbers for each conflict:

- `start_line` = line with `<<<<<<<`
- `end_line` = line with `>>>>>>>`

### 2b: View the conflict block

```bash
sed -n '<start_line>,<end_line>p' <file>
```

### 2c: Identify what each side changed

- **HEAD / ours**: Your branch (merge) or target branch (rebase)
- **Base**: Common ancestor (between `|||||||` and `=======`)
- **Theirs**: Incoming branch (merge) or your commit (rebase)

### 2d: Determine resolution strategy

- Independent additions → combine both
- Competing implementations → choose one or hybrid
- Check if referenced variables/imports from either side are needed

## Step 3: Propose and Apply Resolutions

For each conflict, present to the user:

- File path and line numbers
- Summary of each side's changes
- Proposed resolution with code preview

**Wait for user confirmation (yes/no) before applying.**

### To apply resolutions

Use head/tail to reconstruct the file:

```bash
{
  head -$((start_line - 1)) <file>    # Everything before the conflict
  cat << 'RESOLVED'
<resolved code here>
RESOLVED
  tail -n +$((end_line + 1)) <file>   # Everything after the conflict
} > /tmp/fixed && mv /tmp/fixed <file>
```

### CRITICAL: Verify immediately after EACH resolution

```bash
rg "^<<<<<<" <file> && echo "CONFLICT REMAINS - FIX BEFORE PROCEEDING" || echo "OK"
```

Do not proceed to the next file until verification passes. Errors compound when batched.

## Step 4: Special Cases

### Lock files (pnpm-lock.yaml, package-lock.json, yarn.lock)

- Often show as "both modified" (UU) without text conflict markers
- Resolution: `git checkout --theirs <lockfile>` then regenerate (`rush update`, `npm install`, etc.)

### Generated files (GraphQL types, etc.)

- Prefer taking the more complete version (usually theirs/dev)
- Regenerate after merge to ensure consistency

## Step 5: Completion

1. **Verify all conflicts resolved:**

   ```bash
   git diff --check
   ```

   Should output nothing except trailing whitespace warnings.

2. **Stage resolved files** to mark conflicts as resolved:

   ```bash
   git add <resolved files>
   ```

   This updates the index so editors/IDEs recognize conflicts are resolved.

3. **Show `git status`** — files should now appear under "Changes to be committed"

4. **Do NOT commit or finalize** — inform the user the merge is ready and provide the command:
   - Merge: `git commit`
   - Rebase: `git rebase --continue`

## Guidelines

- Prefer combining changes when they're independent
- Look at imports and surrounding code—one side may add dependencies the other needs
- For rebases, "ours" and "theirs" are swapped vs merges
- If a resolution is complex, break it into smaller pieces for review
