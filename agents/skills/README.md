# Agent Skills

Skills are modular packages that extend agent capabilities with specialized knowledge, workflows, and tools. This directory contains **personal skills** (hand-written) that are deployed alongside external skills to agent-specific directories.

## Personal vs External Skills

- **`agents/skills/`** (this directory) - [P] Personal skills you write and maintain
- **`.agents/skills/`** - [E] External skills installed from [skills.sh](https://skills.sh)
- **`agents/skills.local/`** - [L] Local-only skills (not committed)

All types are synced to `~/.claude/skills/` and `~/.codex/skills/` by the install script.

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
├── references/       # Optional: documentation loaded on demand
├── scripts/          # Optional: executable code
└── assets/           # Optional: templates, static resources
```

### SKILL.md

```yaml
---
name: skill-name # Lowercase, hyphens, max 64 chars
description: >
  Lead with when to invoke—situations, user phrases, keywords, file types—then a short capability line.
  Be specific enough to combat under-triggering; see `/skill-creator`.
global_category: Category # Optional: opt into GLOBAL.md compiled index
---
# Skill Title

Instructions in markdown...
```

The `description` field is the primary trigger signal. Prioritize **when** to load the skill (contexts, phrases, synonyms, adjacent intents); add a brief **what** second. Models under-trigger—err on listing concrete keywords and near-miss situations. See `.agents/skills/skill-creator/SKILL.md` (Write the SKILL.md → description).

### Cross-links

Skills reference each other with `` `/<skill-name>` `` — a leading slash plus the skill directory / YAML `name` (e.g. `` `/write` ``, `` `/git-workflows` ``), always in backticks. A cross-link signals that the agent should read that skill or apply it alongside the current one; individual skills may state stronger requirements (e.g. must invoke `/write` before submitting). Prefer this form over paraphrases like `` `foo` skill `` or relative links to another skill's SKILL.md when the intent is to name a skill for the agent.

### Compiled Annotations

Skills with `global_category` in their frontmatter contribute to a dense always-in-context index in `GLOBAL.md`. Add `<!-- @> summary text -->` annotations above relevant sections to surface key rules:

```markdown
<!-- @> GPU only: animate transform and opacity. Never padding/margin/height/width -->

### The Golden Rule

Only animate `transform` and `opacity`...
```

Annotations are extracted by `bun agents/compile-global.ts` (or `make compile`) into a pipe-delimited block in GLOBAL.md. Cleaned copies (annotations stripped) are written to `agents/.build/skills/` and overlaid onto installed skill copies during deployment.

See the [Annotation Compilation](/CLAUDE.md#annotation-compilation) section in CLAUDE.md for full details.

### Feedback Loops

Every personal skill gets a feedback preamble injected into its deployed SKILL.md (via the `.build/` overlay). The preamble tells agents to read and write a `skill.feedback.md` file in the skill's **source** directory.

```
agents/skills/write/
├── SKILL.md              # Instructions (source of truth)
├── skill.feedback.md     # Accumulated corrections (gitignored)
├── references/
```

**How it works:**
- `make compile` injects a feedback preamble after the frontmatter in each skill's `.build/` copy
- When a skill triggers, the agent reads `skill.feedback.md` from source and applies accumulated preferences
- When the user corrects output during a session, the agent appends a dated line to that file
- `install.sh` excludes `skill.feedback.md` from rsync — the preamble points agents to the source path directly

**Distillation:** Over time, repeated corrections in `skill.feedback.md` should be promoted into the actual SKILL.md as proper instructions, then cleared from the feedback file. Use `/remember-that` to trigger this, or ask the agent to "refine" or "distill" a skill's feedback.

**Opt-out:** Add `feedback: false` to a skill's SKILL.md frontmatter to skip preamble injection.

## Resource Directories

Per the [Agent Skills spec](https://agentskills.io/specification), skills use three optional directories:

**references/** — Documentation loaded into context on demand

- Workflows, library patterns, API docs, schema references
- Example: `change-review/references/apply.md`, `change-review/references/web-interface-guidelines.md`

**scripts/** — Executable code run directly without loading into context

- Python, Bash, etc.
- Example: `rotate_pdf.py`, `extract_data.sh`

**assets/** — Static resources (templates, images, data files)

- Templates, images, boilerplate
- Example: `template.pptx`, `boilerplate/`

## Naming Conventions

- Lowercase letters, numbers, hyphens only (`a-z`, `0-9`, `-`)
- Cannot start or end with a hyphen
- No consecutive hyphens (`--`)
- Max 64 characters
- Directory name must match the `name` field

## Deployment

Skills from `agents/skills/` (personal), `.agents/skills/` (external), and `agents/skills.local/` (local) are synced via rsync to agent-specific locations by `install.sh`:

- `~/.claude/skills/` — Claude Code
- `~/.codex/skills/` — Codex

The sync uses `rsync -a --delete` to mirror each skill folder individually. After syncing, cleaned skill files from `agents/.build/skills/` are overlaid to strip `@>` annotations from installed copies.

External skill install/remove lifecycle is managed by `skills-manager` (`npx skills add/remove/update`). `install.sh` only syncs skills present in source directories.

```bash
make check    # Show all skills with [P]/[E]/[L] labels and sync status
make compile  # Regenerate GLOBAL.md compiled block and .build/ cleaned files
make link     # Full install: symlinks + skills + compilation
```

## Creating Skills

Use `/skill-creator` for guidance:

```bash
# Initialize a new skill
~/.claude/skills/skill-creator/scripts/init_skill.py my-skill-name --path ~/Code/dotfiles/agents/skills/

# Package a skill for distribution
~/.claude/skills/skill-creator/scripts/package_skill.py ~/Code/dotfiles/agents/skills/my-skill-name
```

See `~/.claude/skills/skill-creator/SKILL.md` for comprehensive authoring guidance.

## Managing External Skills

`/skills-manager` (in this directory) handles external skills from skills.sh:

- Install external skills with `npx skills add`
- Track versions in `.agents/skills.json`
- Update with `make update-skills`

See `skills-manager/README.md` for full documentation.
