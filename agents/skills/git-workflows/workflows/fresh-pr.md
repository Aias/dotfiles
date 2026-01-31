# Create a Fresh PR

Use this workflow when you have uncommitted changes (or changes on a different branch) that need to be submitted as a PR from a clean branch based on the latest base branch (typically `dev` or `main`).

## Step 1: Gather Parameters

**Base branch:** Common patterns:

- `dev` — most feature work
- `main` or `master` — hotfixes or repos without a dev branch
- A feature branch — for sub-features of a larger effort

**Changes to include:** Determine if the PR should include:

- All uncommitted changes (staged + unstaged)
- Staged changes only (`git diff --cached`)
- Specific files

**Branch naming:** If the user mentions a ticket number (e.g., RMRK-1234), use it in the branch name from the start: `<handle>/rmrk-1234`. This ensures Linear auto-linking works and avoids renaming branches after PR creation.

If any of these are unclear, ask before proceeding.

## Step 2: Choose Workflow

There are two approaches for creating the fresh branch:

**Worktree approach (non-disruptive):** Use when the user has dev servers running, active build processes, or mentions not wanting to disrupt their local environment. This creates a temporary separate directory.

**Checkout approach (traditional):** Use when the user's working directory is idle or they don't mind switching branches temporarily.

If unclear which to use, ask the user. Default to worktree if there are signs of active development (running processes, complex uncommitted state).

---

## Worktree Workflow

### W1: Preserve Current State

Note which files need to be changed for the PR. Create a patch based on what should be included:

**All uncommitted changes:**

```bash
git diff > /tmp/pr-changes.patch
```

**Staged changes only:**

```bash
git diff --cached > /tmp/pr-changes.patch
```

**Specific files:**

```bash
git diff -- <file1> <file2> > /tmp/pr-changes.patch
```

### W2: Create Worktree with Fresh Branch

```bash
git fetch origin <base-branch>
git worktree add <worktree-path> origin/<base-branch> -b <new-branch-name>
```

Use a path outside the current repo, e.g., `../<repo>-pr-workspace` or `/tmp/<repo>-pr`.

Branch naming conventions:

- Use the user's handle prefix if they have one (e.g., `trombley/feature-name`)
- Include a ticket number if applicable (e.g., `trombley/RMRK-1234`)
- Keep names descriptive but concise

### W3: Apply Changes in Worktree

Choose the appropriate method:

**Copy files directly:**

```bash
cp <file> <worktree-path>/<file>
```

**Apply a patch:**

```bash
cd <worktree-path>
git apply /tmp/pr-changes.patch
```

**Re-apply from scratch:** Use the Read and Edit tools to make the changes in the worktree directory.

### W4: Verify, Commit, and Push (in worktree)

```bash
cd <worktree-path>
```

**Note:** Worktrees don't have `node_modules` installed. Skip local validation (type checks, linting) and rely on CI. Running `pnpm install` or `rush update` in a worktree is usually not worth the time for a quick PR.

1. Stage and commit:
   ```bash
   git add <files>
   git commit -m "<commit message>"
   ```
2. Push:
   ```bash
   git push -u origin <branch-name>
   ```

### W5: Create PR and Clean Up

Create the PR:

```bash
gh pr create --base <base-branch> --title "<title>" --body "$(cat <<'EOF'
<Description of what this PR does>
EOF
)"
```

Return to original directory and remove worktree:

```bash
cd <original-directory>
git worktree remove <worktree-path>
```

### W6: Handle Original Changes

The worktree approach leaves the original directory untouched. After PR creation, ask the user what to do with the local changes that were copied to the PR:

**Keep changes (continuing to iterate):** No action needed. The local changes remain staged/unstaged. This won't cause merge conflicts later—when the PR merges and you rebase, git auto-resolves identical content.

**Unstage but keep as working changes:**

```bash
git restore --staged <files>
```

**Discard (changes are now on PR branch):**

```bash
git restore --staged <files>
git restore <files>
```

If the user doesn't specify, ask: "The changes are now on the PR branch. Should I keep them locally (for continued iteration), unstage them, or discard them?"

---

## Checkout Workflow

### C1: Preserve Current State

Note the current branch name so you can return to it after completing the PR:

```bash
git branch --show-current
```

If there are uncommitted changes in the working directory:

```bash
git stash push -m "Changes for fresh PR"
```

Note which files were changed (`git status` before stashing) so they can be re-applied.

### C2: Create a Fresh Branch

```bash
git fetch origin <base-branch>
git checkout -b <new-branch-name> origin/<base-branch>
```

Branch naming conventions:

- Use the user's handle prefix if they have one (e.g., `trombley/feature-name`)
- Include a ticket number if applicable (e.g., `trombley/RMRK-1234`)
- Keep names descriptive but concise

### C3: Apply Changes

Choose the appropriate method:

**If changes were stashed:**

```bash
git stash pop
```

Note: If the stash was created from a different branch, you may need to manually re-apply changes using the Edit tool, as the stash may contain unrelated changes from the original branch.

**If cherry-picking from another branch:**

```bash
git cherry-pick <commit-sha>
```

**If re-applying from scratch:** Use the Read and Edit tools to re-apply the changes based on what was discussed in the conversation.

### C4: Verify and Commit

1. Run type checks and linting if applicable
2. Review the changes:
   ```bash
   git status
   git diff
   ```
3. Stage and commit:
   ```bash
   git add <files>
   git commit -m "<commit message>"
   ```

### C5: Push and Create PR

```bash
git push -u origin <branch-name>
```

Create the PR:

```bash
gh pr create --base <base-branch> --title "<title>" --body "$(cat <<'EOF'
<Description of what this PR does>
EOF
)"
```

### C6: Return to Original Branch

Switch back to the branch the user was on before starting this skill:

```bash
git checkout <original-branch>
```

Pop any stashes that belong to the user (ask first if uncertain):

```bash
git stash list
git stash pop  # or drop if no longer needed
```

---

## Guidelines

- Always fetch the latest base branch before creating the new branch
- Verify type checks pass before committing
- Keep PR descriptions focused on what changed — no "## Summary" wrapper
- Do NOT include AI/agent attribution in commit messages or PR descriptions
- Only add test plan sections if the user provided specific testing steps
- Always return to the original branch/directory after creating the PR
- Clean up worktrees and stashes to avoid accumulation
