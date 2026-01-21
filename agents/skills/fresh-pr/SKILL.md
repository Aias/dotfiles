---
name: fresh-pr
description: Create a PR from a fresh branch off the base branch
compatibility: Requires git and GitHub CLI (gh).
---

# Create a Fresh PR

Use this skill when you have uncommitted changes (or changes on a different branch) that need to be submitted as a PR from a clean branch based on the latest base branch (typically `dev` or `main`).

## Step 1: Identify the Base Branch

Determine the base branch for the PR. Common patterns:

- `dev` — most feature work
- `main` or `master` — hotfixes or repos without a dev branch
- A feature branch — for sub-features of a larger effort

If not specified, ask which base branch to use.

## Step 2: Choose Workflow

There are two approaches for creating the fresh branch:

**Worktree approach (non-disruptive):** Use when the user has dev servers running, active build processes, or mentions not wanting to disrupt their local environment. This creates a temporary separate directory.

**Checkout approach (traditional):** Use when the user's working directory is idle or they don't mind switching branches temporarily.

If unclear which to use, ask the user. Default to worktree if there are signs of active development (running processes, complex uncommitted state).

---

## Worktree Workflow

### W1: Preserve Current State

Note which files need to be changed for the PR. If changes are uncommitted, either:
- Keep track of the file paths to copy them to the worktree
- Create a patch: `git diff > /tmp/pr-changes.patch`

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

1. Run type checks if applicable
2. Stage and commit:
   ```bash
   git add <files>
   git commit -m "<commit message>"
   ```
3. Push:
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
