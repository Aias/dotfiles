---
name: skills-manager
description: Manage external skills in the dotfiles repo. Use when asked to add, update, or clean up skills.
---

# Skills Manager

Manages external skills within the dotfiles setup. External skills live in `.agents/skills/` and deploy via `make link`.

## Directory Structure

```
dotfiles/
├── agents/skills/           # [P] Personal skills (hand-written)
├── .agents/skills/          # [E] External skills (from GitHub)
└── .claude/skills/          # Symlinks created by npx skills (delete these)

~/.claude/skills/            # Deployed skills (via make link)
~/.codex/skills/             # Deployed skills (via make link)
```

## Install or Update a Skill

Install and update use the same command:

```bash
cd ~/Code/dotfiles

# 1. Install skill (goes to .agents/skills/)
npx skills add OWNER/REPO --skill SKILL-NAME -a claude-code -y

# 2. Remove the symlink it creates (we use make link instead). Note this is relative to the dotfiles repo, NOT `~/.claude/skills/`
rm .claude/skills/SKILL-NAME

# 3. Deploy to all agents
make link
```

### Examples

```bash
# Anthropic skills
npx skills add anthropics/skills --skill frontend-design -a claude-code -y
rm .claude/skills/frontend-design

# Vercel skills
npx skills add vercel-labs/agent-skills --skill vercel-react-best-practices -a claude-code -y
rm .claude/skills/vercel-react-best-practices

make link
rm -rf .claude/skills # Remove the whole subfolder, it's not needed
```

## Delete a Skill

```bash
cd ~/Code/dotfiles
rm -rf .agents/skills/SKILL-NAME    # External skill
rm -rf agents/skills/SKILL-NAME     # Personal skill
git add -A && git commit -m "Remove SKILL-NAME skill"
# Then clean up orphaned deployments (see below)
```

## Cleanup Orphaned Skills

`make link` only adds/updates—it doesn't delete from target directories.

After deleting or renaming skills, ask:

> "Analyze my skills and propose cleanup for any orphaned directories"

The agent should:

1. Compare `agents/skills/` and `.agents/skills/` with `~/.claude/skills/` and `~/.codex/skills/`
2. Identify skills in targets that don't exist in sources
3. Check git history for context on why they're orphaned
4. Propose deletions and ask for confirmation

## Finding Skills

Browse [skills.sh](https://skills.sh) or search GitHub for agent skill repositories.
