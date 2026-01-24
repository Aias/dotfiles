---
name: skills-manager
description: Manage skills from skills.sh - install, update, and track external skills in the dotfiles repo. Use when asked to add, update, or check external skills.
---

# Skills Manager

Manages external skills from skills.sh within the dotfiles setup. Installs to `.agents/skills/` and tracks metadata for updates.

## When to Use

- "Add [skill-name] skill from skills.sh"
- "Update my external skills"
- "Check if [skill] has updates"
- "Install vercel-react-best-practices"

## How It Works

1. **Install new skills**: Uses `npx skills add` to install to `.agents/skills/` in dotfiles
2. **Track metadata**: Maintains `.agents/skills.json` with source URLs and versions
3. **Check updates**: Compares installed skills with remote versions
4. **Update skills**: Re-installs updated skills and preserves metadata

## Metadata Format

`.agents/skills.json`:
```json
{
  "skills": {
    "skill-name": {
      "source": "owner/repo",
      "installedAt": "2026-01-24T12:00:00Z",
      "lastChecked": "2026-01-24T12:00:00Z",
      "commitHash": "abc123..."
    }
  }
}
```

## Commands

### Install a new skill

```bash
cd ~/Code/dotfiles
npx skills add <source> --skill <name>
```

This downloads the skill to `.agents/skills/<name>/` without creating symlinks.

**After install:**
1. Track metadata in `.agents/skills.json`
2. Run `make link` to deploy to all agents via rsync

### Check for updates

```bash
cd ~/Code/dotfiles
npx skills check
```

Shows which skills have updates available.

### Update skills

```bash
cd ~/Code/dotfiles
make update-skills
```

Runs `npx skills update` and redeploys all skills automatically.

## Installation Notes

The install script (`install.sh`) copies from both:
- Personal skills: `agents/skills/`
- External skills: `.agents/skills/`

The `--agent` flag is omitted from `npx skills add`. Deployment is handled via rsync in `make link`.

## Implementation Notes

- Always work within `~/Code/dotfiles` directory
- Clean up symlinks created by `npx skills add` since we use rsync
- Track git commit hashes from source repos for precise version tracking
- The `.agents/` directory should be in `.gitignore` initially, but skills can be committed once verified
