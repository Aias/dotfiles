---
name: git-workflow
description: Git and version control workflows including conflict resolution, rebasing, commit conventions, and repository operations. Use when working with git commands, resolving merge conflicts, or managing version control.
compatibility: Requires git and a working repository.
---

# Git & Version Control Workflow

## General Git Principles

**Read-only by default:** When inspecting `git status` or `git diff`, treat them as read-only context. Never revert or assume missing changes were yours. Other agents or the user may have already committed updates.

**Explicit permission required:** Do not run `git commit`, `git push`, `git reset`, or similar without explicit user permission. Prefer proposing diffs.

**Repository operations:**
- Always use SSH URLs for cloning (e.g., `git@github.com:user/repo.git`), never HTTPS
- Never use `git commit --amend` unless the user specifically requests it; prefer creating new commits over rewriting history

**Commit authorship:**
- Commit messages and PR descriptions should have a single point of view—write as the author, not as an AI assistant
- No "Generated with Claude" footers, no co-authored-by AI attribution, no "I helped implement" phrasing

## Rebasing Workflow

When rebasing branches:

1. **Check context first** - Review PR and line-level comments to understand expected changes
2. **After resolving each conflict, explain the resolution:**
   - What the base branch had (it's more up-to-date, prefer its logic)
   - What the commit being applied wanted to change (identify its true _intent_)
   - Why the resolution is correct (keep base structure, layer commit's intent on top)
3. **Wait for user confirmation** before running `git rebase --continue`
4. **Default assumption:** The branch being rebased onto has better/newer patterns; our commits should only override when that was their explicit purpose

## Conflict Resolution

### Step 1: Identify Conflicts

1. Run `git status` to find conflicted files (under "Unmerged paths")
2. Get context on what's being merged:
   - **Merge:** `git log --oneline -1 MERGE_HEAD`
   - **Rebase:** `git rebase --show-current-patch --stat`

### Step 2: Analyze Each Conflict

For each conflicted file:

1. **Find conflict boundaries** (both start AND end):

   ```bash
   rg -n "^<<<<<<|^>>>>>>>" <file>   # Shows paired start/end markers
   ```

   Note line numbers for each conflict:
   - `start_line` = line with `<<<<<<<`
   - `end_line` = line with `>>>>>>>`

2. **View the conflict block:**

   ```bash
   sed -n '<start_line>,<end_line>p' <file>
   ```

3. **Identify what each side changed:**
   - **HEAD / ours**: Your branch (merge) or target branch (rebase)
   - **Base**: Common ancestor (between `|||||||` and `=======`)
   - **Theirs**: Incoming branch (merge) or your commit (rebase)

4. **Determine resolution strategy:**
   - Independent additions → combine both
   - Competing implementations → choose one or hybrid
   - Check if referenced variables/imports from either side are needed

### Step 3: Propose and Apply Resolutions

For each conflict, present:
- File path and line numbers
- Summary of each side's changes
- Proposed resolution with code preview

Wait for user confirmation (**yes/no**) before applying.

**To apply resolutions**, use head/tail to reconstruct the file:

```bash
{
  head -$((start_line - 1)) <file>    # Everything before the conflict
  cat << 'RESOLVED'
<resolved code here>
RESOLVED
  tail -n +$((end_line + 1)) <file>   # Everything after the conflict
} > /tmp/fixed && mv /tmp/fixed <file>
```

**CRITICAL: Verify immediately after EACH resolution:**

```bash
rg "^<<<<<<" <file> && echo "CONFLICT REMAINS - FIX BEFORE PROCEEDING" || echo "OK"
```

Do not proceed to the next file until verification passes. Errors compound when batched.

### Step 4: Special Cases

**Lock files** (pnpm-lock.yaml, package-lock.json, yarn.lock):
- Often show as "both modified" (UU) without text conflict markers
- Resolution: `git checkout --theirs <lockfile>` then regenerate (`rush update`, `npm install`, etc.)

**Generated files** (GraphQL types, etc.):
- Prefer taking the more complete version (usually theirs/dev)
- Regenerate after merge to ensure consistency

### Step 5: Completion

1. Verify all conflicts resolved: `git diff --check` (should output nothing except trailing whitespace warnings)
2. **Stage resolved files** to mark conflicts as resolved:
   ```bash
   git add <resolved files>
   ```
   This updates the index so editors/IDEs recognize conflicts are resolved.
3. Show `git status` — files should now appear under "Changes to be committed"
4. **Do NOT commit or finalize** — inform the user the merge is ready and provide the command:
   - Merge: `git commit`
   - Rebase: `git rebase --continue`

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
