---
name: change-review
description: >
  Use when reviewing or cleaning up a change-set — a branch, PR, workspace diff, staged changes, or recent commits.
  Triggers on "review the changes", "review this PR", "review my branch", "anything I'm missing", "is this dead?",
  "clean up", "deslop", "tighten", "simplify", "dedup", "reduce LOC", "refactor pass", "knip", "find dead code".
  Also covers TypeScript types/imports/barrels and HTML/CSS/markup conventions (semantic elements, flex/grid,
  declaration order, a11y, tokens, CLS). Two modes: REVIEW (read-only, numbered findings) and APPLY (make changes).
global_category: Code Quality
---

# Change Review

Review and cleanup at the scope of a change-set — what's on this branch, in this PR, in the workspace diff, or in recently modified files. Type-safety and imports for `.ts`/`.tsx`, and HTML/CSS/markup conventions, all live here.

<!-- @> Two modes: REVIEW (read-only, numbered findings, cite file:line, never restate the diff) and APPLY (execute picks from prior review, or run cleanup intensity). Default to REVIEW unless the verb is execute-shaped -->

## Modes

Two modes. **Default to REVIEW** unless the user's verb is execute-shaped or they've explicitly picked items from a prior REVIEW.

| Mode       | Trigger verbs                                                                  | Output                                                | Workflow                              |
| ---------- | ------------------------------------------------------------------------------ | ----------------------------------------------------- | ------------------------------------- |
| **REVIEW** | review, evaluate, audit, analyze, breakdown, compare, "is X dead?", "is X used?", "anything I'm missing?" | Numbered findings in chat. No edits, no commits, no GitHub comments. | [references/review.md](references/review.md) |
| **APPLY**  | clean up, delete, remove, rip out, fix N, "go ahead", "implement", "wire up", deslop, tighten, refactor pass | Edits + optional commit. | [references/apply.md](references/apply.md) |

A user who says *"review this"* and then replies *"fix 2, 3, 5"* has moved from REVIEW to APPLY. The numbered list is the bridge — REVIEW output must be cherry-pickable by number.

## Scope

A change-review is **change-scoped**, never repo-wide. Pick scope in this order:

1. **Conductor workspace** — `mcp__conductor__GetWorkspaceDiff` with `stat: true` first, then specific files (see [`/conductor`](../conductor/SKILL.md)).
2. **Open PR** — `gh pr diff` or `gh pr view --json files,baseRefName`.
3. **Branch vs base** — `git merge-base origin/<base> HEAD`, then `git diff <merge-base> HEAD` (or three-dot `git diff origin/<base>...HEAD`). Always `git fetch origin <base>` first; local refs go stale silently.
4. **Staged / uncommitted** — `git diff --staged` and/or `git diff HEAD`.
5. **Recently modified files** — only as a last resort, and only files the user explicitly named or you edited earlier in this conversation.

<!-- @> Never diff the full range between two long-lived branches (e.g. dev...main) — pulls in unrelated merged work and pollutes the review -->

Never diff the full range between two long-lived branches (`dev...main`) — that pulls in unrelated merged work and pollutes the review.

State which scope you used in the report's first line. The answer to "how many files changed?" differs by tool, and the user will ask.

## REVIEW Mode (default)

Brief — full workflow in [references/review.md](references/review.md).

<!-- @> REVIEW defaults to read-only: no edits, no commits, no GitHub comments unless explicitly authorized. Output is chat text only. Codified in user's standing Conductor `Review request.md` preference -->

- **Read-only.** No edits, no commits, no GitHub/Linear comments unless explicitly authorized. Output is chat text only.
- **Fan out across parallel subagents** for any non-trivial diff. The dominant correction across hundreds of past sessions is "there's no way you reviewed all that code" — single-pass skim is not acceptable. Standard axes: bug scan, AGENTS.md/CLAUDE.md compliance, dead code & duplication, LOC & complexity.
- **Validate each finding** with a second-pass subagent before reporting. False positives erode trust faster than missed issues.
- **Cite file path + line range** on every finding. Never restate the diff.
- **Numbered list** with stable IDs (`#1`, `#2`, ...) so the user can reply "fix 2, 3, 5".
- **High signal only.** See [references/review.md](references/review.md#explicit-false-positives) for the explicit false-positives list (pre-existing issues, linter-catchable, pedantic nits, etc.).
- **End with a handoff suggestion:** APPLY a subset, run `/pr-guidelines` to refresh the description, defer to a follow-up PR, or stop.

## APPLY Mode

Brief — full workflow in [references/apply.md](references/apply.md).

Two entry paths:

1. **From a prior REVIEW:** user picks items by number (*"fix 2, 3, 5"*, *"do all 4"*, *"in stages, dead code first"*). Execute only the picked items.
2. **Standalone cleanup intensity:** the user names the depth.

| Intensity            | Trigger phrases                                  | Scope                                                                                                       |
| -------------------- | ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------- |
| **Light** (deslop)   | "deslop", "remove slop", "clean up the AI stuff" | Strip AI artifacts. No structural changes. [Workflow →](references/apply.md#light-deslop)                   |
| **Heavy** (refactor) | "refactor pass", "tighten up", "dead code"       | Structural cleanup, dead path removal, build/test verification. [Workflow →](references/apply.md#heavy-refactor-pass) |
| **Targeted**         | "fix 2, 3, 5", "do all 4", "in stages"           | Execute picked items from a prior REVIEW. [Workflow →](references/apply.md#targeted-picks) |

Phased over big-bang. The user repeatedly steers toward "in stages, dead code first, then consolidation". Default to proposing a phased plan; execute one phase, pause, then continue.

## Shared Principles

These apply to both modes — they shape what counts as a finding (REVIEW) and what counts as a clean diff (APPLY).

<!-- @> Primary outcome: cleanup passes should generally end with net fewer lines than before; if LOC increases, justify why complexity decreased. "10k+ lines is unacceptable from a reviewer perspective" — diff size itself is a finding -->

### Primary outcome: net LOC reduction

After cleanup, total LOC should usually be lower than before. If cleanup increases LOC, keep it only when it clearly reduces complexity or risk, and call out that tradeoff explicitly.

Diff size is itself a finding. A version bump that produces 20k+ lines of diff, or a feature that costs 10k+ lines for a small surface, is suspect — flag it and look for the maintainer-provided codemod, an idiomatic API the project missed, or generated content that should be excluded from review.

When categorizing a large diff, split into: **generated / boilerplate / moved / new logic**. The user evaluates PR quality partly by the new-logic fraction.

<!-- @> Remove defensive checks, type casts, redundant annotations, single-use variables abnormal for codepath context. Don't auto-remove useCallback/useMemo/memo — only with profiling evidence or explicit user direction -->

### What to remove

- Extra defensive checks or try/catch blocks abnormal for that codepath (especially if called by trusted/validated callers).
- Casts to `any` or `as` to get around type issues (see [Type safety](#type-safety)).
- Unnecessary or redundant type annotations.
- Variable declarations only used once right after declaration — inline them.
- Style inconsistent with the surrounding file.

### What NOT to remove

- `useCallback`, `useMemo`, `memo`, or other performance primitives — only change with profiling evidence or explicit user direction.
- **Intentional scaffolding.** Re-export barrels, design-system primitives (`*.primitives.tsx`), and framework-required exports may look "unused" to knip but exist for a reason. Ask before pruning.
- **Repetition that serves an argument.** Callbacks, deliberate restatement, or layered comments that reinforce intent are not duplication. Only flag *fully duplicated / redundant* sections.
- **Specific semantic intent.** A `<dialog>` wrapper exists for top-layer semantics; a button-styled-as-link exists for download behavior. Read the intent before flattening.

<!-- @> No shipped stubs, mocks, hardcoded fixtures, or "temporary" literals. Replace stand-ins with real sources before handoff. Mid-stream stubs must carry `// TODO: remove` to stay greppable -->

### No shipped stubs, mocks, or temporary values

Stubs, mocks, hardcoded fixtures, "temporary" literals, debug values, and inline test data **do not ship**. If you wired a UI, query, or branch to a stand-in during development, replace it with the real source before declaring the work done. The risk isn't sloppiness — it's that a forgotten stub silently shapes behavior, and when the feature misbehaves weeks later, the cause is invisible and the debugging trail leads in the wrong direction.

If a stub must exist mid-stream (active debugging, intentional prototyping), mark every one with a `// TODO: remove` comment (or language-equivalent) so it stays greppable. Before handoff, search the touched feature for `TODO: remove`, `MOCK`, `STUB`, fixture arrays, and hardcoded values that mirror enum or option labels, and remove them. The TODO comment is a safety net, not a substitute for cleanup. Unmarked stubs are a first-class REVIEW finding.

<!-- @> Hard rule: a file may not cross from below 1000 lines to above. Only waiver is extremely uniform content (data table, generated code, flat enum) where any split would hurt readability. Decompose first by default -->

### The 1000-line ceiling

A file may not cross from below 1000 lines to above. This applies to REVIEW (flag the violation) and APPLY (decompose before letting a change push the file over).

The only valid waiver: the file is extremely uniform — a long data table, generated code, a flat enum, a list of route registrations — where any split would hurt readability. If the file has meaningful control flow or distinct sections, decompose first. Don't waive because the new code "logically belongs here" or because splitting "is a lot of work."

When APPLY is about to push a file across the line, stop and propose the decomposition (subcomponents, helpers, separate modules) before continuing.

<!-- @> Cleanup uncovers more cleanup — follow the thread. After removing a feature, search for sibling dead code (utilities, tokens, fixtures, resolver fields) that's now unused -->

### Cleanup uncovers more cleanup

After removing a feature, branch, or component, search the codebase for sibling code that's now dead — utilities only it called, design tokens only it used, GraphQL fields only it queried, fixtures only it referenced, schema columns only it wrote. A one-shot deletion that only removes the named thing under-delivers. The user expects the cleanup to **follow the thread**.

Scope guard: stay within the change-set's natural boundary. "Sibling code that became dead because of this change" is in scope. "Sibling code that was always dead but you noticed in passing" is a follow-up, not this PR.

<!-- @> List ordering: every list has an intrinsic best order — alphabetical, dependency, frequency, numeric — match the list's purpose. Place new entries in position; never just append. Encode deviations from tool defaults, not the defaults themselves -->

### List ordering

Every list has an intrinsic best order. Match the list's purpose rather than defaulting to alphabetical:

- **Alphabetical** for catalogs read like a glossary (dependency blocks, env keys, allowlists, enum members consumed by humans).
- **Dependency/logical** when earlier entries set up later ones (import groupings, CSS declaration order, pipeline stages).
- **Frequency or salience** for lookup tables where readers scan for common cases first.
- **Numeric/temporal** for sequence-bearing data (versioned migrations, dated entries).

When adding an entry, place it in the correct position rather than appending. The only reason to break the intrinsic order is a hard syntactic or logical constraint.

For config files that combine tool defaults with project overrides, encode only the **deviations**: a short config that diverges meaningfully is more readable than a long one that mostly restates the defaults. Before adding an option, check whether it matches the default; if so, omit it.

<!-- @> Comments explain WHY not WHAT. If explaining WHAT, refactor to be self-documenting -->

### Comment policy

Remove unacceptable comments:

- Comments that repeat what code does.
- Commented-out code (delete it).
- Obvious comments ("increment counter").
- Comments that could be fixed by better naming.
- Comments about updates to old code ("now supports xyz", "moved to new location").

Code should be self-documenting. If a comment explains WHAT the code does, refactor to make it clearer.

Acceptable comments:

- Explaining an unintuitive decision.
- Intuitively explaining a complex algorithm.
- Justifying an inconsistency or deviation.
- Translating symbols/phrases otherwise unintelligible.

<!-- @> Don't reach for ignore/exclude/skip config to silence tool output you've accepted as correct. Don't write a throwaway codemod — prefer the maintainer's official path even if the diff is larger -->

### Don't silence the tool; don't roll your own codemod

When a tool reports something you've already accepted as correct, run it and let downstream state settle — don't reach for `ignore` / `exclude` / `skip` config to silence it. When the upstream maintainers publish an official migration path (codemod, preset, framework-provided helper), prefer it over a handwritten substitute, even when the resulting diff is larger. A 20k-line maintainer codemod is more trustworthy than a 2k-line homegrown one. Parallel subagents > scripted refactors when no official codemod exists.

## Types, imports & tooling (`.ts`, `.tsx`)

Applies when writing or reviewing TypeScript: typecheck failures, strictness, generics, barrels, module layout — not only during cleanup passes.

<!-- @> No any/as/!/ts-ignore — fix code, not types -->

### Type safety

**Never compromise type safety**: No `any`, no type assertions (`as Type`), no non-null assertions (`!`), no `ts-ignore`/`eslint-disable`. Avoid `unknown` unless narrowed immediately. If TypeScript resists, fix the code — don't override the types.

<!-- @> Prop intersections: specific before generic. Inline single-use variables -->

### Component & prop style

- Order prop intersections: specific props before generic (`{ specific } & RootProps`).
- Favor readability over brevity; avoid mirror variables.
- Comments only for non-obvious logic, never narration.
- Follow existing conventions: use `rg`, `fd`, git history before adding patterns.
- Don't declare variables only used once immediately after; inline them.

### Imports & dependencies

<!-- @> Import order: React → runtime → external → internal → aliased → relative → local. type keyword for type imports -->

- Import order: React → runtime → external → internal → aliased → relative → local.
- Use `type` keyword for type imports: `import type { Foo } from './types'`.
- Dependencies in `package.json`: alphabetical.

<!-- @> No barrel files (index.ts re-exports). Import directly from source modules -->

#### Barrel files

- No barrel files — don't create `index.ts` re-export files. Import directly from source modules.

### Checks

Run type/lint checks yourself when relevant; don't ask the user to run them.

## HTML, CSS & templates

Markup and styles for `.html`, `.css`, and templated/JSX UI. Deep dive: [Web Interface Guidelines](references/web-interface-guidelines.md).

<!-- @> Semantic elements over div/span; built-in elements over generic containers -->

### Semantic HTML first

Prefer built-in semantics over generic containers: structure (`article`, `header`, `main`, `nav`, `section`, `ul`/`li`), interactive (`button`, `form`, `label`), content (`table`, `time`). Avoid `div`/`span` unless necessary. Prefer real text + structure over ARIA-only shortcuts.

<!-- @> Flexbox/grid + gap; margin is code smell. Logical properties (block/inline, start/end). Transform sub-properties -->

### Layout

- Flexbox/grid with `gap` for spacing between children.
- `margin` is a code smell — prefer container `padding` or `gap`; margins break encapsulation.
- Logical properties: `block`/`inline`, `start`/`end` over physical `left`/`right`/`top`/`bottom` where appropriate.
- Transform sub-properties (`translate`, `rotate`, `scale`) over a single long `transform` when the stack allows it.

<!-- @> Order CSS declarations logically (outside-in): position/display → flex/grid → sizing/spacing → overflow → typography → visual → transforms → interaction -->

### Declaration order

Order by concern, outside-in (not alphabetically): position & display → flex/grid container & child → sizing & spacing → overflow → typography → visual (color, background, border, shadow) → transform & animation → interaction (`cursor`, `pointer-events`, `user-select`). Applies to CSS-in-JS objects too.

<!-- @> Colors: tokens/custom properties, then oklch or hex (not rgb) -->

### Colors

Design tokens / CSS custom properties first; otherwise `oklch` or hex — not `rgb` for new work.

<!-- @> CSS over JS when equivalent -->

### CSS over JavaScript

Prefer CSS for visuals and motion when it matches JS behavior — less bundle work, easier `prefers-reduced-motion`, better separation.

### Accessibility

- Prefer visually hidden real text (`srOnly`) over duplicating meaning in `aria-label` alone.
- Custom click targets need keyboard support (Enter/Space). Every interactive element needs a visible `:focus-visible` style — never `outline-none` without a replacement.
- Viewport units: `dvw`/`dvh` over `vw`/`vh` where mobile chrome matters.

### Images

Explicit `width` and `height` (or constrained aspect) to limit CLS. `loading="lazy"` below the fold; prioritize above-the-fold / LCP images.

### Markup & CSS tips

- `mask-image` for gradient fades works across arbitrary backgrounds.
- Fix SVG `viewBox` at the asset, not at every call site.

## Workflow Shape (when in doubt)

Both modes share the same skeleton: **explore → propose → approve → apply.** The difference is what each phase produces.

| Phase    | REVIEW                                                    | APPLY                                                          |
| -------- | --------------------------------------------------------- | -------------------------------------------------------------- |
| Explore  | Establish scope, fan out across axes, gather findings.    | Read the picked items (or the change-set).                     |
| Propose  | Numbered findings, file:line cited, validated.            | Numbered plan of edits, largest-to-smallest, with scope tag.   |
| Approve  | User picks items by number or replies with refinements.   | User approves all, picks by number, or denies.                 |
| Apply    | Hand off to APPLY mode (or stop, or refresh PR prose).    | Make approved changes. Run build/tests. Don't auto-commit.     |

End every session with a short summary: what changed, what's deferred, and the next handoff (e.g. *"run `/pr-guidelines` to refresh the description"* or *"the dead-code thread continues into the unused GraphQL fields"*).
