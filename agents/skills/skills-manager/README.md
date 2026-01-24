# Skills Manager

A skill for managing external skills from [skills.sh](https://skills.sh) within your dotfiles setup.

## Overview

This skill enables:
- Installing skills from skills.sh to `.agents/skills/` in your dotfiles repo
- Tracking skill sources and versions in `.agents/skills.json`
- Updating external skills while preserving metadata
- Clean integration with your existing dotfiles install system

## Directory Structure

```
dotfiles/
├── agents/
│   └── skills/              # [P] Personal skills (hand-written)
│       ├── council/
│       ├── skills-manager/  # ← You are here
│       └── ...
├── .agents/
│   ├── skills/              # [E] External skills (from skills.sh)
│   │   ├── vercel-react-best-practices/
│   │   └── ...
│   └── skills.json          # Metadata tracking (source, commit, date)
└── install.sh               # Copies from both directories
```

The install script (`make link`) copies **both** personal and external skills to:
- `~/.claude/skills/`
- `~/.codex/skills/`

## Quick Start

### Install a new skill

```bash
# From your dotfiles directory
cd ~/Code/dotfiles

# Install from skills.sh (only downloads to .agents/skills/, no symlinks)
npx skills add vercel-labs/agent-skills \
  --skill vercel-react-best-practices

# Track metadata
COMMIT_HASH=$(cd .agents/skills/vercel-react-best-practices && git rev-parse HEAD)
agents/skills/skills-manager/manage-skills.sh add \
  vercel-react-best-practices \
  vercel-labs/agent-skills \
  "$COMMIT_HASH"

# Deploy to all agents via rsync
make link

# Optional: commit to dotfiles
git add .agents/
git commit -m "Add vercel-react-best-practices from skills.sh"
```

The `--agent` flag is omitted. Deployment is handled via `make link` with rsync.

### Check for updates

```bash
cd ~/Code/dotfiles
npx skills check
```

### Update skills

```bash
cd ~/Code/dotfiles

# Update all skills
npx skills update

# Update metadata for changed skills
COMMIT_HASH=$(cd .agents/skills/skill-name && git rev-parse HEAD)
agents/skills/skills-manager/manage-skills.sh add \
  skill-name \
  source-repo \
  "$COMMIT_HASH"

# Deploy
make link
```

### List tracked skills

```bash
cd ~/Code/dotfiles
agents/skills/skills-manager/manage-skills.sh list
```

## Files

- **SKILL.md** - Skill definition for agents
- **manage-skills.sh** - Helper script for metadata management
- **WORKFLOW.md** - Detailed step-by-step workflows
- **README.md** - This file

## How It Works

1. **`npx skills add`** downloads external skills to `.agents/skills/` (no symlinks created)
2. **`manage-skills.sh`** tracks metadata in `.agents/skills.json`
3. **`make link`** copies from **both** `agents/skills/` and `.agents/skills/` to agent directories via rsync
4. **`make check`** verifies all skills are in sync, showing `[P]` for personal and `[E]` for external

## Integration with Dotfiles

The install script was modified to:
- Copy from both `agents/skills/` (personal) and `.agents/skills/` (external)
- Label skills as `[P]` (personal) or `[E]` (external) in output
- Clean up old symlinks before copying

The Makefile's `check` target now:
- Checks both directories for sync status
- Shows skill type alongside sync status
- Properly handles duplicate skill names (if you have both versions)

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

