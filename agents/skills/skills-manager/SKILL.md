---
name: skills-manager
description: Manage skills from skills.sh - install, update, and track external skills in the dotfiles repo. Use when asked to add, update, or check external skills.
---

# Skills Manager

Manages external skills from [skills.sh](https://skills.sh) within the dotfiles setup. Installs to `.agents/skills/` and tracks metadata for updates.

## When to Use

- "Add [skill-name] skill from skills.sh"
- "Update my external skills"
- "Check if [skill] has updates"
- "Install vercel-react-best-practices"
- "Analyze my skills and propose cleanup for orphaned directories"

## Directory Structure

```
dotfiles/
├── agents/
│   └── skills/              # [P] Personal skills (hand-written)
│       ├── council/
│       ├── skills-manager/
│       └── ...
├── .agents/
│   ├── skills/              # [E] External skills (from skills.sh)
│   │   ├── vercel-react-best-practices/
│   │   └── ...
│   └── skills.json          # Metadata tracking (source, commit, date)
└── install.sh               # Copies from both directories

~/.claude/
└── skills/
    ├── council/              # Deployed from repo
    ├── vercel-react-best-practices/  # Deployed from repo
    ├── my-local-skill/       # User-created, not in repo
    └── old-renamed-skill/    # Orphaned after rename (cleanup via agent)

~/.codex/
└── skills/
    ├── council/              # Deployed from repo
    ├── vercel-react-best-practices/  # Deployed from repo
    └── my-local-skill/       # User-created, not in repo
```

Target directories can contain:
- **Repo-managed skills** - deployed via `make link`
- **Local-only skills** - created directly in target, preserved by install script
- **Orphaned skills** - remain after deletions/renames, cleaned up via agent workflow

## How It Works

1. **`npx skills add`** downloads external skills to `.agents/skills/` (no symlinks created)
2. **`manage-skills.sh`** tracks metadata in `.agents/skills.json`
3. **`make link`** copies from **both** `agents/skills/` and `.agents/skills/` to agent directories via rsync (adds/updates only)
4. **`make check`** verifies all skills are in sync, showing `[P]` for personal and `[E]` for external
5. **Agent workflow** analyzes and proposes cleanup for orphaned skills when needed

## Install a New Skill

```bash
cd ~/Code/dotfiles

# 1. Install using npx skills (downloads to .agents/skills/)
npx skills add vercel-labs/agent-skills \
  --skill vercel-react-best-practices

# 2. Get the commit hash from the cloned repo (optional but recommended)
COMMIT_HASH=$(git -C .agents/skills/vercel-react-best-practices rev-parse HEAD 2>/dev/null || echo "unknown")

# 3. Record metadata
agents/skills/skills-manager/manage-skills.sh add \
  vercel-react-best-practices \
  vercel-labs/agent-skills \
  "$COMMIT_HASH"

# 4. Deploy to all agents via rsync
make link

# 5. Commit to dotfiles (optional)
git add .agents/skills/vercel-react-best-practices
git add .agents/skills.json
git commit -m "Add vercel-react-best-practices skill from skills.sh"
```

Without `--agent`, npx skills only downloads to `.agents/skills/` without creating symlinks. `make link` handles deployment via rsync.

## Check for Updates

```bash
cd ~/Code/dotfiles
npx skills check
```

## Update a Skill

```bash
cd ~/Code/dotfiles

# 1. Update using npx skills
npx skills update

# 2. Get new commit hash
COMMIT_HASH=$(git -C .agents/skills/skill-name rev-parse HEAD 2>/dev/null || echo "unknown")

# 3. Update metadata
agents/skills/skills-manager/manage-skills.sh add \
  skill-name \
  source-repo \
  "$COMMIT_HASH"

# 4. Deploy
make link

# 5. Commit changes
git add .agents/skills/skill-name
git add .agents/skills.json
git commit -m "Update skill-name to $COMMIT_HASH"
```

## List Tracked Skills

```bash
cd ~/Code/dotfiles
agents/skills/skills-manager/manage-skills.sh list
```

## Delete a Skill

To remove a skill from your dotfiles:

```bash
cd ~/Code/dotfiles

# 1. Delete the skill directory
rm -rf agents/skills/skill-name          # Personal skill
# OR
rm -rf .agents/skills/skill-name         # External skill

# 2. Remove from metadata (external skills only)
# Edit .agents/skills.json to remove the skill entry

# 3. Commit the deletion
git add -A
git commit -m "Remove skill-name skill"

# 4. Clean up orphaned deployments (see Agent Cleanup Workflow below)
```

**Note:** `make link` only adds/updates skills, it does not automatically delete orphaned skills from target directories. Use the agent cleanup workflow to identify and remove orphaned skills.

## Rename a Skill

To rename a skill:

```bash
cd ~/Code/dotfiles

# 1. Rename the directory
mv agents/skills/old-name agents/skills/new-name

# 2. Update metadata if it's an external skill
# Edit .agents/skills.json: change the key from old-name to new-name

# 3. Deploy the renamed skill
make link

# 4. Commit the rename
git add -A
git commit -m "Rename skill: old-name → new-name"

# 5. Clean up the old skill name (see Agent Cleanup Workflow below)
```

**Note:** The old skill name will remain in target directories until manually removed.

## Agent Cleanup Workflow

When you delete, rename, or pull changes that affect skills, orphaned directories may remain in:
- `~/.claude/skills/`
- `~/.codex/skills/`

To reconcile, ask an agent to analyze and propose cleanup:

**User prompt:**
> "Analyze my skills and propose cleanup for any orphaned directories"

**Agent should:**

1. **List skills in source directories:**
   ```bash
   ls ~/Code/dotfiles/agents/skills/
   ls ~/Code/dotfiles/.agents/skills/
   ```

2. **List skills in target directories:**
   ```bash
   ls ~/.claude/skills/
   ls ~/.codex/skills/
   ```

3. **Check git history for context** (deleted/renamed skills):
   ```bash
   cd ~/Code/dotfiles
   git log --oneline --follow --all -- 'agents/skills/*' | head -20
   git log --oneline --follow --all -- '.agents/skills/*' | head -20
   ```

4. **Identify orphans** - skills in targets that don't exist in sources

5. **Propose specific deletions** with context:
   - "Found `old-skill-name` in ~/.claude/skills/"
   - "This skill was renamed to `new-skill-name` in commit abc123"
   - "Propose: `rm -rf ~/.claude/skills/old-skill-name`"

6. **Ask for confirmation** before executing deletions

**Key considerations for agent:**
- Don't propose deleting skills that exist in source directories
- Present git history context to explain why skills are orphaned
- Allow user to review each deletion before executing
- Preserve any skills the user explicitly wants to keep as local-only

This workflow allows:
- Manual creation of local-only skills in target directories
- Safe reconciliation after git pull
- Contextual cleanup based on git history
- User control over what gets deleted

## Cleanup and Reconciliation

`make link` only adds/updates skills - it does not automatically delete orphaned skills from target directories.

After deleting, renaming, or pulling changes:

```bash
cd ~/Code/dotfiles
git pull
make link  # Deploy/update skills from repo
```

**To clean up orphaned skills**, use the agent-driven workflow above.

This approach:
- Preserves user-created local-only skills in target directories
- Provides git context for why skills are orphaned
- Gives user control over deletions
- Works safely after git pull from other machines

## Metadata Format

`.agents/skills.json`:
```json
{
  "skills": {
    "vercel-react-best-practices": {
      "source": "vercel-labs/agent-skills",
      "commitHash": "2f19db57b2db26276bf3c9eb3d0e4bba231337f2",
      "installedAt": "2026-01-24T18:47:31Z",
      "lastChecked": "2026-01-24T18:47:31Z"
    }
  }
}
```

## Integration with Dotfiles

The install script:
- Copies from both `agents/skills/` (personal) and `.agents/skills/` (external)
- Labels skills as `[P]` (personal) or `[E]` (external) in output
- Only adds/updates skills - does not automatically delete orphans
- Preserves user-created local-only skills in target directories

The Makefile:
- `make link`: Deploy/update skills from repo to targets
- `make check`: Verify sync status with type labels
- `make update-skills`: Update all external skills via `npx skills update`

## Implementation Notes

- Always work within `~/Code/dotfiles` directory
- Track git commit hashes from source repos for precise version tracking
- The `.agents/` directory can be committed to version control external skills
- `make link` is idempotent - safe to run multiple times
