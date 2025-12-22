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

## Step 2: Preserve Current Changes

If there are uncommitted changes in the working directory:

```bash
git stash push -m "Changes for fresh PR"
```

Note which files were changed (`git status` before stashing) so they can be re-applied.

## Step 3: Create a Fresh Branch

```bash
git fetch origin <base-branch>
git checkout -b <new-branch-name> origin/<base-branch>
```

Branch naming conventions:

- Use the user's handle prefix if they have one (e.g., `trombley/feature-name`)
- Include a ticket number if applicable (e.g., `trombley/RMRK-1234`)
- Keep names descriptive but concise

## Step 4: Apply Changes

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

**If re-applying from scratch:**

Use the Read and Edit tools to re-apply the changes based on what was discussed in the conversation.

## Step 5: Verify and Commit

1. Run type checks and linting if applicable:

   ```bash
   pnpm tsc --noEmit  # or equivalent
   ```

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

   Write a clear commit message:

   - First line: concise summary (imperative mood)
   - Blank line
   - Body: explain what and why (not how)

## Step 6: Push and Create PR

```bash
git push -u origin <branch-name>
```

Create the PR:

```bash
gh pr create --base <base-branch> --title "<title>" --body "$(cat <<'EOF'
<Description of what this PR does - no "Summary" header needed>

<Additional context, bullet points, or explanation as appropriate>
EOF
)"
```

**PR description guidelines:**

- Do NOT include AI/agent co-authorship attribution
- Do NOT wrap the main content in a `## Summary` section — just write the description directly
- Only include a `## Test plan` section if the user explicitly provided testing steps
- Keep the description focused and concise

## Step 7: Cleanup

Drop any stashes that are no longer needed:

```bash
git stash list
git stash drop stash@{n}
```

Optionally switch back to the original branch if the user wants to continue other work.

## Guidelines

- Always fetch the latest base branch before creating the new branch
- Verify type checks pass before committing
- Keep PR descriptions focused on what changed — no wrapper sections like "## Summary"
- Do NOT include AI/agent attribution in commit messages or PR descriptions
- Only add test plan sections if the user provided specific testing steps
- Clean up stashes to avoid accumulation
