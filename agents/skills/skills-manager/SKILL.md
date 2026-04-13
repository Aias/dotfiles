---
name: skills-manager
description: >
  Use when adding, updating, removing, or cleaning external skills in dotfiles; `skills.sh`,
  `make update-skills`, `.agents/skills/`, `skills-lock.json`, or syncing skills into install paths.
  Manages the external-skill pipeline for this repo.
---

# Skills Manager

Manages external skills within the dotfiles setup. External skills live in `.agents/skills/` and deploy via `make link`.

**When invoked with no additional user context**, use `AskUserQuestion` to present the available actions (install/update, delete, cleanup, find) as interactive prompts rather than listing them as plain text.

## Current State

Sources:

- `agents/skills/`: !`ls ~/Code/dotfiles/agents/skills/ 2>/dev/null | tr '\n' ' '`
- `.agents/skills/`: !`ls ~/Code/dotfiles/.agents/skills/ 2>/dev/null | tr '\n' ' '`
- `agents/skills.local/`: !`ls ~/Code/dotfiles/agents/skills.local/ 2>/dev/null | tr '\n' ' ' || echo "(none)"`

Deploy targets:

- `~/.claude/skills/`: !`ls ~/.claude/skills/ 2>/dev/null | tr '\n' ' '`
- `~/.codex/skills/`: !`ls ~/.codex/skills/ 2>/dev/null | tr '\n' ' '`

Orphans (deployed but no source): !`comm -23 <(ls ~/.claude/skills/ 2>/dev/null | sort -u) <({ ls ~/Code/dotfiles/agents/skills/ 2>/dev/null; ls ~/Code/dotfiles/.agents/skills/ 2>/dev/null; ls ~/Code/dotfiles/agents/skills.local/ 2>/dev/null; } | sort -u) | tr '\n' ' '`

## Directory Structure

```
dotfiles/
├── agents/skills/           # [P] Personal skills (hand-written, tracked in git)
├── agents/skills.local/     # [L] Local skills (machine-specific, gitignored)
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

# Vercel skills (note: vercel-react-best-practices has been adopted as react-best-practices in agents/skills/)

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

Three source directories, not two: `agents/skills/`, `.agents/skills/`, **and** `agents/skills.local/` (gitignored). All three deploy to `~/.claude/skills/` and `~/.codex/skills/`.

Run this exact command to list orphans (deployed directories with no source):

```bash
comm -23 \
  <({ ls ~/.claude/skills/ 2>/dev/null; ls ~/.codex/skills/ 2>/dev/null; } | sort -u) \
  <({ ls ~/Code/dotfiles/agents/skills/ 2>/dev/null; ls ~/Code/dotfiles/.agents/skills/ 2>/dev/null; ls ~/Code/dotfiles/agents/skills.local/ 2>/dev/null; } | sort -u)
```

Do **not** substitute `Glob` — it returns files only and misses directory-only entries in `skills.local/`, which will produce false-positive orphans for valid local skills. Use `ls` (or `fd --type d --max-depth 1`).

For each orphan: check `git log` for context, then propose `rm -rf ~/.claude/skills/NAME ~/.codex/skills/NAME` and ask for confirmation.

## Finding Skills

Browse [skills.sh](https://skills.sh) or search GitHub for agent skill repositories.
