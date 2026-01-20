---
name: skill-creator
description: Create or update Agent Skills (SKILL.md + resources). Use when building new skills, revising existing skills, or asking about skill best practices.
---

# Skill Creator

Create concise, triggerable skills with clear workflows and minimal context cost.

## Mental model

- Skills are onboarding guides: procedural, not encyclopedic.
- Progressive disclosure: metadata (always) → SKILL.md (on trigger) → resources (as needed).
- Description is the trigger: include WHAT + WHEN.

## Required structure

```
skill-name/
├── SKILL.md            # required
├── scripts/            # optional
├── references/         # optional
└── assets/             # optional
```

### SKILL.md frontmatter

```yaml
---
name: skill-name # lowercase, hyphens, <=64 chars
description: >-
  What it does. Use when <trigger phrases / contexts>.
compatibility: <optional> # only if needed
---
```

## Creation flow

1. Define use cases + trigger phrases (what user says that should trigger).
2. Choose resources:
   - repeated code → `scripts/`
   - docs/specs → `references/`
   - templates/files → `assets/`
3. Init:
   ```bash
   scripts/init-skill.py <skill-name> [--resources scripts,references,assets]
   ```
   Source of truth: `~/Code/dotfiles/agents/skills/`.
4. Implement:
   - description first (WHAT + WHEN)
   - imperative instructions; add only what an agent lacking context wouldn’t already know
   - add resources only if they reduce repetition
   - test scripts if present
5. Deploy:
   ```bash
   cd ~/Code/dotfiles && make install
   ```
   Restart agent to load new skills.

## Writing rules (tight)

- Imperative voice; examples > prose; SKILL.md <500 lines.
- Don’t duplicate “when to use” in body (belongs in description).
- Avoid README/CHANGELOG/INSTALL docs; avoid duplicated content.
- Keep references one level deep from SKILL.md.

## Portability (paths)

- Never hardcode `~/.claude/skills` or similar.
- Inline commands when possible; otherwise use relative paths:
  ```bash
  scripts/my-script.sh "args"
  ```

## Progressive disclosure pattern

```markdown
## Quick start

<minimal example>

## Advanced

- Forms: See [references/forms.md](references/forms.md)
- API: See [references/api.md](references/api.md)
```

## Spec

- Format: [references/specification.md](references/specification.md)
- Official docs: https://agentskills.io/
