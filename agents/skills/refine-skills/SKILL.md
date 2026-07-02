---
name: refine-skills
description: >
  Use when distilling, refining, or reviewing accumulated skill feedback — "refine skills",
  "distill feedback", "promote feedback", "compound my skills". Reads skill.feedback.md files,
  identifies patterns, and promotes repeated corrections into permanent SKILL.md instructions.
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

- **Repeated corrections** — The same preference stated 2+ times (possibly in different words). These are the highest-signal patterns. Recognize sameness by the underlying preference, not surface phrasing — "too verbose", "cut the throat-clearing", and "get to the point faster" are one pattern, not three one-offs.
- **Clusters** — Related corrections that point to a missing or weak section in the skill (e.g., several tone corrections suggest a missing voice/style section).
- **One-offs** — Single corrections that may be task-specific rather than generalizable. Leave these in the feedback file for now.

### 3. Propose promotions

For each pattern identified, draft a concrete SKILL.md edit:

- Write the correction as a proper instruction in the skill's voice — distill the principle behind the feedback, never lift the user's correction phrasing verbatim (it reads as a complaint and won't generalize past the case that prompted it)
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

**Input** (`~/Code/dotfiles/agents/skills/foo/skill.feedback.md`):
```
- (week 1, mon): Procedural steps should be ordered (numbered) lists, not bullets
- (week 1, wed): Add a blank line between top-level sections
- (week 2, tue): Procedure as bullets again — these are sequential, use a numbered list
- (week 2, thu): Cross-link `/bar` when the topic touches bar's domain
- (week 3, mon): Still seeing bulleted steps where order matters
- (week 3, fri): Mention `/bar` for any task that crosses repo boundaries
```

**Analysis:**
- Ordered lists for sequential steps: 3 entries → strong pattern, promote
- `/bar` cross-links: 2 entries → consistent pattern, promote (route check first: does this belong in `/bar` or in `/foo`? if it's about *when /foo should defer to /bar*, it lives in /foo)
- Section spacing: 1 entry → leave in feedback, not yet a pattern

**Promotion to `/foo` SKILL.md:**
> Use ordered (numbered) lists for sequential procedures. Bullets are for sets where order doesn't matter.
>
> When a task touches `/bar`'s domain (placeholder for cross-cutting concerns), cross-link to `/bar` and defer to it on the overlapping mechanics.

**After cleanup** (`skill.feedback.md`):
```
- (week 1, wed): Add a blank line between top-level sections
```

## Principles

- **Consolidate, don't accumulate.** A promoted instruction should replace multiple feedback entries, not paraphrase them individually.
- **Keep promotions proportionate.** Match the weight of the rule to its home: a simple preference is one or two sentences inline in the existing section, never a fresh `references/*.md` file. Reserve a new reference file for a genuinely large, self-contained body of guidance — a source text, a lookup table, or a procedure long enough that inlining would double SKILL.md. When in doubt, the smaller home wins.
- **Condense, don't only grow.** Every refinement pass is also a trim pass. Before adding, audit the skill for redundancy, stale guidance, and examples that can do more work, then reorganize toward the skill's current best shape. Leave the file shorter and tighter than you found it; if it grew, the new material must earn more than it costs.
- **Route correctly.** If a correction belongs in a different skill or in GLOBAL.md, route it there via `/remember-that` logic rather than forcing it into the current skill.
- **Preserve the skill's voice.** Promoted instructions should read as natural parts of the skill, not as appended afterthoughts.
- **Don't over-promote.** A single correction isn't a pattern. Leave one-offs in the feedback file — they may accumulate into a pattern later, or they may turn out to be task-specific noise.
