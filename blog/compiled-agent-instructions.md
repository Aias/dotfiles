# Compiling Agent Instructions: Progressive Disclosure for AI Context

I maintain a dotfiles repo that configures my AI coding agents — Claude Code, Codex, Cursor. Over time, the agent instructions grew into a problem: an 82KB monolithic markdown file trying to be everything at once. Every rule, every guideline, every workflow, all pasted inline. Duplicated across skills and the global config. A mess to maintain, and a waste of context window.

The fix was a small build step I hadn't seen anyone else do: **compile** the instructions.

## The Problem

Agent "skills" (modular instruction packages) are great for organizing domain knowledge — git workflows, animation best practices, TypeScript conventions. But the agent needs *some* rules always in context, not just when a skill triggers. The question is which rules, and how to keep them in sync with the source.

The naive approach is to hand-write a summary section in the global config. I did this for months. It rots immediately. You update the skill, forget to update the summary. Or worse, the summary subtly diverges and now you have two sources of truth that contradict each other.

## The Idea

What if skills could **annotate** their own key rules, and a compiler could extract those annotations into a dense always-in-context index?

The requirements:

1. Annotations live in the skill files, next to the content they summarize
2. A compiler extracts them into the global config automatically
3. Deployed copies of skills don't see the annotations (they're build metadata)
4. The output format must be maximally dense — every token counts in a context window

## The Annotation Syntax

An HTML comment with a `@>` prefix, placed above the section it describes:

```markdown
<!-- @> GPU only: animate transform and opacity. Never padding/margin/height/width -->
### The Golden Rule

Only animate `transform` and `opacity`. These are the only properties
that can be hardware-accelerated...
```

The comment is invisible to markdown renderers. It's metadata for the compiler only. The text after `@>` is a compressed summary of the section below — dense enough to be useful on its own, specific enough to jog the agent's memory.

Skills opt in by adding `global_category` to their SKILL.md frontmatter:

```yaml
---
name: git-workflows
description: Git and version control workflows...
global_category: Git
---
```

No `global_category`, no compilation. Skills stay modular.

## The Compiler

A ~275-line Bun/TypeScript script (`agents/compile-global.ts`) that:

1. Scans `agents/skills/` and `.agents/skills/` for skills with `global_category` frontmatter
2. Recursively finds all `.md` files in each qualifying skill
3. Extracts `<!-- @> summary -->` annotations, recording the summary text, line number, and file path
4. Generates a pipe-delimited index sorted by category
5. Splices the index into `GLOBAL.md` between `<!-- BEGIN COMPILED -->` / `<!-- END COMPILED -->` markers
6. Writes "cleaned" copies (annotations stripped) to a `.build/` directory for deployment

The core extraction is simple — just regex and line counting:

```typescript
const ANNOTATION_RE = /^<!-- @> (.+?) -->$/;

for (const line of inputLines) {
  const m = line.match(ANNOTATION_RE);
  if (m) {
    pendingSummaries.push(m[1]);
    continue; // annotation lines are stripped from cleaned output
  }

  cleanedLines.push(line);

  if (pendingSummaries.length > 0 && line.trim() !== "") {
    const lineNum = cleanedLines.length;
    for (const text of pendingSummaries) {
      summaries.push({ text, line: lineNum, file: fileRelPath });
    }
    pendingSummaries.length = 0;
  }
}
```

Annotations accumulate until the next non-empty line, which anchors them to a line number. This means you can stack multiple annotations above a section, and they all point to the same line. The line number is calculated against the *cleaned* output (annotations removed), so references stay accurate in deployed copies.

## The Output

The compiled block in GLOBAL.md looks like this:

```
<!-- BEGIN COMPILED -->
Analysis|skills/pr-review|Explore related files — callers, callees, types, tests:L49|Prove claims in code. No speculative "likely/may":L51
Animation|skills/web-animation-design|Entering/exiting → ease-out. On-screen movement → ease-in-out:L43|GPU only: animate transform and opacity:L202
Git|skills/git-workflows|Read-only on git status/diff. Explicit permission for commit/push/reset:L23|SSH URLs. Never amend unless explicitly requested:L27
TypeScript|skills/typescript-guidelines|No any/as/!/ts-ignore — fix code, not types:L11|No barrel files. Import directly from source modules:L23
<!-- END COMPILED -->
```

Each line: `Category|skills/path|summary:Lnn|summary:Lnn|...`

No prose. No headers. No formatting. Just a flat index of the rules that matter most, with line references back to the source. The entire compiled block for 8 categories and ~25 annotations fits in about 10 lines. Compare that to the 82KB monolith it replaced.

The format is intentionally alien to natural language. Pipe-delimited, compressed, no articles or conjunctions. The agent doesn't need pretty — it needs the rule to fire at the right moment. And density means more rules fit in the always-loaded context.

## The Deployment Pipeline

The last piece: annotations shouldn't appear in the installed copies of skills. They're build metadata — useful for the compiler, noise for the agent reading the skill at runtime.

The compiler writes annotation-stripped copies to `agents/.build/skills/`. During installation (`make link`), the install script rsyncs skills to their target directories, then overlays the cleaned copies on top:

```bash
# After syncing skills, overlay cleaned versions
for build_skill in "$build_dir"/*/; do
    skill_name="$(basename "$build_skill")"
    if [[ -d "$target_dir/$skill_name" ]]; then
        rsync -a "$build_skill" "$target_dir/$skill_name/"
    fi
done
```

The `.build/` directory is gitignored and regenerated on every compile. Source files in the repo keep their annotations. Deployed files don't.

## Staleness Detection

The compiler has a `--check` mode that exits non-zero if the compiled block would change:

```bash
bun agents/compile-global.ts --check
# ✓ GLOBAL.md is up to date
# or
# ✗ GLOBAL.md is stale. Run: make compile
```

This plugs into `make check` for a quick validation that annotations haven't drifted from the compiled output.

## What Changed

The migration consolidated 7 skills, deleted 4 others, and removed the 82KB monolith entirely. The numbers:

- **Before:** 4,166 lines of duplicated, hand-maintained instruction text
- **After:** 742 lines of source + 10 lines of compiled output
- **Deleted:** `humanizer`, `council`, `ui-code-review`, `react-guidelines` (absorbed into other skills)
- **Consolidated:** `deslop` + `refactor-pass` into `code-quality`; `frontend-html-css-guidelines` + `web-design-guidelines` + `frontend-design` into `frontend-guidelines`

The key insight wasn't the tooling — it was recognizing that **the instructions had a build step missing.** Source and output were the same file, which meant every rule existed in two places or didn't exist where it was needed. Separating source (annotated skills) from output (compiled index) solved both problems at once.

## The Pattern

This is just a compiler. Source files with annotations, a build step that extracts and transforms, an output artifact, and a clean/deploy pipeline. The same pattern that builds every other piece of software.

The only novelty is applying it to agent instructions — treating the context window as a deployment target with real constraints (token budget, retrieval latency, always-loaded vs. on-demand), and using standard build tooling to optimize for those constraints.

If your agent instructions are getting unwieldy, consider: what would it look like to compile them?
