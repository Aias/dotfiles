---
name: skills-manager
description: >
  Use when adding, updating, removing, or cleaning external skills in dotfiles; `skills.sh`,
  `make update-skills`, the dotfiles repo's `.agents/skills/`, `skills-lock.json`, or syncing
  skills into install paths. Manages the dotfiles external-skill pipeline only — not skills that
  live in a project repository's own `.agents/skills/` directory.
---

# Skills Manager

Manages external skills within the dotfiles setup. External skills live in the dotfiles repo's `.agents/skills/` and deploy via `make link`.

**Scope: the dotfiles pipeline only.** A project repository's own `.agents/skills/` directory (`<repo>/.agents/skills/<name>`) follows the same skills spec but is ordinary project source — edit it in place, commit it with the repo, and keep it out of `skills-lock.json` and the deploy targets. Nothing in this pipeline manages, installs, or syncs project-owned skills.

**When invoked with no additional user context**, run `make check` and the orphan listing, then recommend the action the current state calls for.

## Current State

Inventory and cleanup decisions need the three source directories (`agents/skills/`, `.agents/skills/`, `agents/skills.local/`) and the three deploy targets (`~/.claude/skills/`, `~/.codex/skills/`, `~/.cursor/skills/`). `make check` prints all six with sync status; list a directory directly only when acting on it. Orphans (deployed but no source) are the deploy-target names absent from every source directory:

```bash
comm -23 <({ ls ~/.claude/skills/ ~/.codex/skills/ ~/.cursor/skills/ 2>/dev/null; } | sort -u) \
        <({ ls ~/Code/dotfiles/agents/skills/ ~/Code/dotfiles/.agents/skills/ ~/Code/dotfiles/agents/skills.local/ 2>/dev/null; } | sort -u)
```

## Directory Structure

```
dotfiles/
├── agents/skills/           # [P] Personal skills (hand-written, tracked in git)
├── agents/skills.local/     # [L] Private skills (optional submodule)
├── .agents/skills/          # [E] External skills (from GitHub)
└── .claude/skills/          # Symlinks created by bunx skills (delete these)

~/.claude/skills/            # Deployed skills (via make link)
~/.codex/skills/             # Deployed skills (via make link)
~/.cursor/skills/            # Deployed skills (via make link)
```

Read [the inclusion format](../README.md#harness-inclusion) when changing target metadata. Preserve local `metadata.targets` values across upstream updates.

## Install or Update a Skill

Install and update use the same command:

```bash
cd ~/Code/dotfiles

# 1. Install skill (goes to .agents/skills/)
bunx skills add OWNER/REPO --skill SKILL-NAME -a claude-code -y

# 2. Remove the symlink it creates (we use make link instead). Note this is relative to the dotfiles repo, NOT `~/.claude/skills/`
rm .claude/skills/SKILL-NAME

# 3. Deploy to all agents
make link
```

### Examples

```bash
# Install a skill from an external source
bunx skills add <org>/<repo> --skill <skill-name> -a claude-code -y
rm .claude/skills/<skill-name>

make link
rm -rf .claude/skills # Remove the whole subfolder, it's not needed
```

If an external skill has been adopted into `agents/skills/` (vendored as a personal skill), don't reinstall it — remove its entry from `skills-lock.json` so the install pipeline skips it.

## Delete a Skill

```bash
cd ~/Code/dotfiles
rm -rf .agents/skills/SKILL-NAME    # External skill
rm -rf agents/skills/SKILL-NAME     # Personal skill
# Then clean up orphaned deployments (see below)
```

## Cleanup Orphaned Skills

`make link` removes excluded target copies when a current source skill explicitly restricts its targets. It does not prune orphaned deployments of removed or renamed source skills.

Three source directories, not two: `agents/skills/`, `.agents/skills/`, **and** `agents/skills.local/` (optional private submodule). All three compile for their selected targets under `~/.claude/skills/`, `~/.codex/skills/`, and `~/.cursor/skills/`.

Run this exact command to list orphans (deployed directories with no source):

```bash
comm -23 \
  <({ ls ~/.claude/skills/ 2>/dev/null; ls ~/.codex/skills/ 2>/dev/null; ls ~/.cursor/skills/ 2>/dev/null; } | sort -u) \
  <({ ls ~/Code/dotfiles/agents/skills/ 2>/dev/null; ls ~/Code/dotfiles/.agents/skills/ 2>/dev/null; ls ~/Code/dotfiles/agents/skills.local/ 2>/dev/null; } | sort -u)
```

Do **not** substitute `Glob` — it returns files only and misses directory-only entries in `skills.local/`, which will produce false-positive orphans for valid local skills. Use `ls` (or `fd --type d --max-depth 1`).

For each orphan: check `git log` for context — a skill mid-rename looks identical to an orphan until the log shows the new path. Remove orphans whose dotfiles source the log shows was removed or renamed (`rm -rf ~/.claude/skills/NAME ~/.codex/skills/NAME ~/.cursor/skills/NAME`). List any orphan with no dotfiles history, such as a plugin or a manual install, and ask before removing it.

## Finding Skills

Browse [skills.sh](https://skills.sh) or search GitHub for agent skill repositories.
