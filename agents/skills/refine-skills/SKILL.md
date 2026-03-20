---
name: refine-skills
description: |
  Use when distilling, refining, or reviewing accumulated skill feedback — "refine skills", "distill feedback", "promote feedback", "review skill feedback", "what feedback has accumulated", "compound my skills". Also when the user asks to clean up, consolidate, or review skill.feedback.md files. Reads feedback files across personal skills, identifies patterns, and promotes repeated corrections into permanent SKILL.md instructions.
---

# Refine Skills

Distill accumulated `skill.feedback.md` entries into permanent skill instructions. This turns raw session corrections into crafted rules, keeping feedback files as a staging area rather than a permanent store.

## When to Run

- User explicitly asks to refine or distill feedback
- A `skill.feedback.md` has grown to ~10+ entries
- During periodic skill maintenance

## Process

### 1. Survey feedback files

Scan `~/Code/dotfiles/agents/skills/*/skill.feedback.md` for files with content. Report which skills have accumulated feedback and how many entries each has. If none exist, say so and stop.

### 2. Read and analyze

For each skill with feedback, read both the feedback file and the skill's source SKILL.md. Look for:

- **Repeated corrections** — The same preference stated 2+ times (possibly in different words). These are the highest-signal patterns.
- **Clusters** — Related corrections that point to a missing or weak section in the skill (e.g., several tone corrections suggest a missing voice/style section).
- **One-offs** — Single corrections that may be task-specific rather than generalizable. Leave these in the feedback file for now.

### 3. Propose promotions

For each pattern identified, draft a concrete SKILL.md edit:

- Write the correction as a proper instruction in the skill's voice
- Identify where in SKILL.md it belongs (existing section, new section, or inline with related content)
- If the skill has `global_category` in frontmatter and the correction is important enough for always-in-context, draft a `<!-- @> summary -->` annotation too
- Show the user the before/after for each proposed edit

Use `AskUserQuestion` to present all proposed promotions at once and get confirmation before editing.

### 4. Apply and clean up

After confirmation:

1. Edit the source SKILL.md at `~/Code/dotfiles/agents/skills/{name}/SKILL.md` (use Bash if workspace-sandboxed)
2. Remove promoted entries from `skill.feedback.md` — leave unpromoted entries intact
3. Run `make compile` to regenerate `.build/` copies and update GLOBAL.md if annotations changed
4. Run `make link` to deploy

### 5. Report

Summarize what was promoted, what remains in feedback, and which skills were updated.

## Example

**Input** (`~/Code/dotfiles/agents/skills/write/skill.feedback.md`):
```
- 2026-03-10: Too many em dashes
- 2026-03-12: Shorter paragraphs in PR descriptions
- 2026-03-14: Stop using em dashes for asides — use commas or parentheses
- 2026-03-15: PR descriptions should open with the problem, not "This PR..."
- 2026-03-18: Again with the em dashes, seriously
- 2026-03-19: Don't start sentences with "Additionally" or "Furthermore"
```

**Analysis:**
- Em dashes: 3 entries → strong pattern, promote
- PR description opening: 1 entry → but overlaps with `/pr-guidelines`, route there instead
- Paragraph length: 1 entry → leave in feedback, not yet a pattern
- Transition words: 1 entry → leave in feedback

**Promotion to `/write` SKILL.md:**
> Avoid em dashes for parenthetical asides — use commas, parentheses, or restructure the sentence.

**After cleanup** (`skill.feedback.md`):
```
- 2026-03-12: Shorter paragraphs in PR descriptions
- 2026-03-19: Don't start sentences with "Additionally" or "Furthermore"
```

## Principles

- **Consolidate, don't accumulate.** A promoted instruction should replace multiple feedback entries, not paraphrase them individually.
- **Route correctly.** If a correction belongs in a different skill or in GLOBAL.md, route it there via `/remember-that` logic rather than forcing it into the current skill.
- **Preserve the skill's voice.** Promoted instructions should read as natural parts of the skill, not as appended afterthoughts.
- **Don't over-promote.** A single correction isn't a pattern. Leave one-offs in the feedback file — they may accumulate into a pattern later, or they may turn out to be task-specific noise.
