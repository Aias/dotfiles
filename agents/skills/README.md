# Agent Skills

Skills are modular packages that extend agent capabilities with specialized knowledge, workflows, and tools. This directory contains skills that are deployed to agent-specific directories via the dotfiles install script.

## Quick Start

Create a new skill:

```bash
skill-creator/scripts/init-skill.py my-new-skill
```

Deploy skills:

```bash
cd ~/Code/dotfiles && ./install.sh
```

Restart your agent to pick up new skills.

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

Skills in this directory are synced via rsync to agent-specific locations by `install.sh`:

- `~/.claude/skills/` — Claude Code
- `~/.codex/skills/` — Codex

The sync uses `rsync -a --delete` to mirror each skill folder individually, removing files deleted from source while preserving other directories in the target. After deployment, restart the agent to load new skills.

## Creating Skills

Use the `skill-creator` skill for guidance, or run the init script directly:

```bash
# Basic skill
skill-creator/scripts/init-skill.py pdf-processing

# With resource directories
skill-creator/scripts/init-skill.py data-analysis --resources scripts,references
```

See `skill-creator/SKILL.md` for comprehensive authoring guidance.

## Current Skills

| Skill | Description |
|-------|-------------|
| `changelog` | Analyze outdated dependencies and summarize changelogs |
| `deslop` | Remove AI code slop |
| `diagrams` | Generate Mermaid diagrams from code or architecture |
| `fresh-pr` | Create a PR from a fresh branch off the base branch |
| `interview` | Interview about a plan, feature, or code change |
| `merge-conflicts` | Resolve merge or rebase conflicts interactively |
| `pr-review` | Review a pull request |
| `remove-effects` | Remove React useEffect hooks |
| `skill-creator` | Create or update Agent Skills |
