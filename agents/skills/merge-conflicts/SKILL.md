---
name: merge-conflicts
description: Resolve merge or rebase conflicts interactively
compatibility: Requires git and a working repository.
---

# Resolve Merge/Rebase Conflicts

## Step 1: Identify Conflicts

1. Run `git status` to find conflicted files (under "Unmerged paths")
2. Get context on what's being merged:
   - **Merge:** `git log --oneline -1 MERGE_HEAD`
   - **Rebase:** `git rebase --show-current-patch --stat`

## Step 2: Analyze Each Conflict

For each conflicted file:

1. **View the conflict** using shell commands (see Tool Notes below):

   ```bash
   rg -n "^<<<<<<" <file>           # Find conflict line numbers
   sed -n '<start>,<end>p' <file>   # View conflict block
   ```

2. **Identify what each side changed:**

   - **HEAD / ours**: Your branch (merge) or target branch (rebase)
   - **Base**: Common ancestor (between `|||||||` and `=======`)
   - **Theirs**: Incoming branch (merge) or your commit (rebase)

3. **Determine resolution strategy:**
   - Independent additions → combine both
   - Competing implementations → choose one or hybrid
   - Check if referenced variables/imports from either side are needed

## Step 3: Propose and Apply Resolutions

For each conflict, present:

- File path and line numbers
- Summary of each side's changes
- Proposed resolution with code preview

Wait for user confirmation (**yes/no**) before applying.

**To apply resolutions**, use head/tail to reconstruct the file:

```bash
{
  head -<line_before_conflict> <file>
  cat << 'RESOLVED'
<resolved code here>
RESOLVED
  tail -n +<line_after_conflict> <file>
} > /tmp/fixed && mv /tmp/fixed <file>
```

After each resolution, verify: `rg "^<<<<<<" <file>` (should return no matches)

## Step 4: Special Cases

**Lock files** (pnpm-lock.yaml, package-lock.json, yarn.lock):

- Often show as "both modified" (UU) without text conflict markers
- Resolution: `git checkout --theirs <lockfile>` then regenerate (`rush update`, `npm install`, etc.)

**Generated files** (GraphQL types, etc.):

- Prefer taking the more complete version (usually theirs/dev)
- Regenerate after merge to ensure consistency

## Step 5: Completion

1. Verify all conflicts resolved: `git diff --check` (should output nothing)
2. Show `git status` — files should be staged or ready to stage
3. **Do NOT commit** — provide commands for user to finalize:
   - Merge: `git add <files> && git commit`
   - Rebase: `git add <files> && git rebase --continue`

## Tool Notes

The `Read` and `StrReplace` tools may have difficulty with conflict markers. During testing, `StrReplace` failed to match text containing `<<<<<<<`/`=======`/`>>>>>>>` sequences even when the exact text was confirmed present via shell commands. Use shell commands instead:

- **View conflicts:** `sed -n '<start>,<end>p' <file>` or `bat --plain -r <start>:<end> <file>`
- **Apply resolutions:** head/tail reconstruction (shown above)
- **Verify resolution:** `rg "^<<<<<<" <file>` or `git diff --check`

## Guidelines

- Prefer combining changes when they're independent
- Look at imports and surrounding code — one side may add dependencies the other needs
- For rebases, "ours" and "theirs" are swapped vs merges
- If a resolution is complex, break it into smaller pieces for review
