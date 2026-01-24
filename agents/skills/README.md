# Agent Skills

Skills are modular packages that extend agent capabilities with specialized knowledge, workflows, and tools. This directory contains **personal skills** (hand-written) that are deployed alongside external skills to agent-specific directories.

## Personal vs External Skills

- **`agents/skills/`** (this directory) - [P] Personal skills you write and maintain
- **`.agents/skills/`** - [E] External skills installed from [skills.sh](https://skills.sh)

Both types are synced to `~/.claude/skills/` and `~/.codex/skills/` by the install script.

## Quick Start

**Create a personal skill:**

```bash
~/.claude/skills/skill-creator/scripts/init_skill.py my-new-skill
```

**Install an external skill:**

See `skills-manager/README.md` for complete workflow, or:

```bash
npx skills add <source> --skill <skill-name>
```

**Deploy all skills:**

```bash
cd ~/Code/dotfiles && make link
```

## Format Overview

Skills follow the [Agent Skills open standard](https://agentskills.io/). Each skill is a directory containing:

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
└── assets/           # Optional: templates, resources
```

### SKILL.md

```yaml
---
name: skill-name          # Lowercase, hyphens, max 64 chars
description: What the skill does and WHEN to use it.
compatibility: git, network  # Optional: requirements
---

# Skill Title

Instructions in markdown...
```

The `description` field is critical—it determines when the skill triggers. Include both what the skill does AND specific scenarios/keywords that should activate it.

## Naming Conventions

- Lowercase letters, numbers, hyphens only (`a-z`, `0-9`, `-`)
- Cannot start or end with a hyphen
- No consecutive hyphens (`--`)
- Max 64 characters
- Directory name must match the `name` field

## Resource Directories

**scripts/** — Executable code run directly without loading into context
- Python, Bash, etc.
- Example: `rotate_pdf.py`, `extract_data.sh`

**references/** — Documentation loaded into context when needed
- Keep detailed docs here instead of bloating SKILL.md
- Example: `api_docs.md`, `schema.md`

**assets/** — Files used in output, never loaded into context
- Templates, images, boilerplate
- Example: `template.pptx`, `boilerplate/`

## Compatibility Field

Only use when specific requirements exist:

```yaml
compatibility: Requires GitHub CLI (gh) and git.
```

Common patterns:
- CLI tools: `git`, `gh`, `jq`, `docker`
- Network access: `network access`, `GitHub API access`
- Agent-specific: `Designed for Claude Code`

## Deployment

Skills from both `agents/skills/` (personal) and `.agents/skills/` (external) are synced via rsync to agent-specific locations by `install.sh`:

- `~/.claude/skills/` — Claude Code
- `~/.codex/skills/` — Codex

The sync uses `rsync -a --delete` to mirror each skill folder individually. Check sync status:

```bash
make check
```

This shows all skills with [P] or [E] labels and their sync status.

## Creating Skills

Use the `skill-creator` skill for guidance:

```bash
# Initialize a new skill
~/.claude/skills/skill-creator/scripts/init_skill.py my-skill-name --path ~/Code/dotfiles/agents/skills/

# Package a skill for distribution
~/.claude/skills/skill-creator/scripts/package_skill.py ~/Code/dotfiles/agents/skills/my-skill-name
```

See `~/.claude/skills/skill-creator/SKILL.md` for comprehensive authoring guidance.

## Managing External Skills

The `skills-manager` skill (in this directory) handles external skills from skills.sh:

- Install external skills with `npx skills add`
- Track versions in `.agents/skills.json`
- Update with `make update-skills`

See `skills-manager/README.md` for full documentation.
