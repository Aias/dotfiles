---
name: code-quality
description: >
  Use when cleanup, deslop, refactor, simplify, dead code, or structural passes. Triggers on "clean this
  up", "refactor pass", "tighten", "remove slop". Also .ts/.tsx types, imports, barrels—and HTML/CSS/markup:
  semantic elements, flex/grid, declaration order, a11y, tokens, CLS, "is this accessible".
global_category: Code Quality
---

# Code Quality

Cleanup and refactoring at the intensity the user requests. Type-safety and imports for `.ts`/`.tsx`, and HTML/CSS/markup conventions, all live here—no separate frontend or TypeScript skills.

## Intensity Spectrum

| Level                 | Trigger phrases                                      | Scope                                                                                                       |
| --------------------- | ---------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Light** (deslop)    | "deslop", "remove slop", "clean up the AI stuff"     | Strip AI artifacts. No structural changes. [Workflow →](references/deslop.md)                               |
| **Heavy** (refactor)  | "refactor pass", "tighten up", "dead code"           | Structural cleanup, dead path removal, build/test verification. [Workflow →](references/refactor-pass.md)   |
| **Review** (simplify) | "simplify", "review for reuse", "review for quality" | Parallel 3-agent review (reuse, quality, efficiency) on changed files. [Workflow →](references/simplify.md) |

If the user doesn't specify, infer from context: post-AI-generation → light, post-feature-complete → heavy. When uncertain, ask.

## Shared Principles

<!-- @> Primary outcome: cleanup passes should generally end with net fewer lines than before; if LOC increases, justify why complexity decreased -->

### Primary Outcome

- Prefer net line reduction: after cleanup, total LOC should usually be lower than before.
- If a cleanup increases LOC, keep it only when it clearly reduces complexity or risk, and call out that tradeoff.

<!-- @> Remove defensive checks, type casts, redundant annotations, single-use variables abnormal for codepath context -->

### What to Remove

- Extra defensive checks or try/catch blocks abnormal for that codepath (especially if called by trusted/validated callers)
- Casts to `any` or usage of `as` to get around type issues (aligns with [Type safety](#type-safety) below)
- Unnecessary or redundant type annotations
- Obvious variable declarations only used once right after declaration
- Any style inconsistent with the surrounding file

<!-- @> Do not auto-remove useCallback, useMemo, or memo. Only change with clear evidence or explicit user direction -->

### Performance Primitives

- Do not remove `useCallback`, `useMemo`, or `memo` automatically during cleanup.
- Only change memoization with clear evidence (profiling, measurable impact) or explicit user direction.

<!-- @> No shipped stubs, mocks, hardcoded fixtures, or "temporary" literals. Replace stand-ins with real sources before handoff. While a stub must exist mid-stream (debug/prototype), mark every one with `// TODO: remove` so it stays greppable -->

### No shipped stubs, mocks, or temporary values

Stubs, mocks, hardcoded fixtures, "temporary" literals, debug values, and inline test data **do not ship**. If you wired a UI, query, or branch to a stand-in during development, replace it with the real source before declaring the work done. The risk isn't sloppiness — it's that a forgotten stub silently shapes behavior, and when the feature misbehaves weeks later, the cause is invisible and the debugging trail leads in the wrong direction.

If a stub or mock must exist mid-stream (active debugging, intentional prototyping), mark every one with a `// TODO: remove` comment (or language-equivalent) so it stays greppable. Before handoff, search the touched feature for `TODO: remove`, `MOCK`, `STUB`, fixture arrays, and hardcoded values that mirror enum or option labels, and remove them. The TODO comment is a load-bearing safety net, not a substitute for cleanup.

<!-- @> List ordering: every list has an intrinsic best order — alphabetical, dependency, frequency, numeric — match the list's purpose. Place new entries in position; never just append. Encode deviations from tool defaults, not the defaults themselves -->

### List ordering

Every list has an intrinsic best order. Match the list's purpose rather than defaulting to alphabetical:

- **Alphabetical** for catalogs read like a glossary (dependency blocks, env keys, allowlists, enum members consumed by humans).
- **Dependency/logical** when earlier entries set up later ones (import groupings, CSS declaration order, pipeline stages).
- **Frequency or salience** for lookup tables where readers scan for common cases first.
- **Numeric/temporal** for sequence-bearing data (versioned migrations, dated entries).

When adding an entry, place it in the correct position rather than appending. The only reason to break the intrinsic order is a hard syntactic or logical constraint (a config schema that pins order, a list whose semantics depend on position).

For config files that combine tool defaults with project overrides, encode only the **deviations**: a short config that diverges meaningfully is more readable than a long one that mostly restates the defaults. Before adding an option, check whether it matches the default; if so, omit it.

<!-- @> Comments explain WHY not WHAT. If explaining WHAT, refactor to be self-documenting -->

### Comment Policy

Remove unacceptable comments:

- Comments that repeat what code does
- Commented-out code (delete it)
- Obvious comments ("increment counter")
- Comments that could be fixed by better naming
- Comments about updates to old code ("now supports xyz", "moved to new location")

Code should be self-documenting. If a comment explains WHAT the code does, refactor to make it clearer.

Acceptable comments:

- Comments explaining an unintuitive decision
- Comments intuitively explaining a complex algorithm
- Comments justifying an inconsistency or deviation
- Comments translating symbols/phrases otherwise unintelligible

## Types, imports & tooling (`.ts`, `.tsx`)

Applies when writing or reviewing TypeScript: typecheck failures, strictness, generics, barrels, module layout—not only during cleanup passes.

<!-- @> No any/as/!/ts-ignore — fix code, not types -->

### Type safety

**Never compromise type safety**: No `any`, no type assertions (`as Type`), no non-null assertions (`!`), no `ts-ignore`/`eslint-disable`. Avoid `unknown` unless narrowed immediately. If TypeScript resists, fix the code—don't override the types.

<!-- @> Prop intersections: specific before generic. Inline single-use variables -->

### Component & prop style

- Order prop intersections: specific props before generic (`{ specific } & RootProps`)
- Favor readability over brevity; avoid mirror variables
- Comments only for non-obvious logic, never narration
- Follow existing conventions: use `rg`, `fd`, git history before adding patterns
- Don't declare variables only used once immediately after; inline them

### Imports & dependencies

<!-- @> Import order: React → runtime → external → internal → aliased → relative → local. type keyword for type imports -->

- Import order: React → runtime → external → internal → aliased → relative → local
- Use `type` keyword for type imports: `import type { Foo } from './types'`
- Dependencies in `package.json`: alphabetical

#### Barrel files

<!-- @> No barrel files (index.ts re-exports). Import directly from source modules -->

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
- `margin` is a code smell—prefer container `padding` or `gap`; margins break encapsulation.
- Logical properties: `block`/`inline`, `start`/`end` over physical `left`/`right`/`top`/`bottom` where appropriate.
- Transform sub-properties (`translate`, `rotate`, `scale`) over a single long `transform` when the stack allows it.

<!-- @> Order CSS declarations logically (outside-in): position/display → flex/grid → sizing/spacing → overflow → typography → visual → transforms → interaction -->

### Declaration order

Order by concern, outside-in (not alphabetically): position & display → flex/grid container & child → sizing & spacing → overflow → typography → visual (color, background, border, shadow) → transform & animation → interaction (`cursor`, `pointer-events`, `user-select`). Applies to CSS-in-JS objects too.

<!-- @> Colors: tokens/custom properties, then oklch or hex (not rgb) -->

### Colors

Design tokens / CSS custom properties first; otherwise `oklch` or hex—not `rgb` for new work.

<!-- @> CSS over JS when equivalent -->

### CSS over JavaScript

Prefer CSS for visuals and motion when it matches JS behavior—less bundle work, easier `prefers-reduced-motion`, better separation.

### Accessibility

- Prefer visually hidden real text (`srOnly`) over duplicating meaning in `aria-label` alone.
- Custom click targets need keyboard support (Enter/Space). Every interactive element needs a visible `:focus-visible` style—never `outline-none` without a replacement.
- Viewport units: `dvw`/`dvh` over `vw`/`vh` where mobile chrome matters.

### Images

Explicit `width` and `height` (or constrained aspect) to limit CLS. `loading="lazy"` below the fold; prioritize above-the-fold / LCP images.

### Markup & CSS tips

- `mask-image` for gradient fades works across arbitrary backgrounds.
- Fix SVG `viewBox` at the asset, not at every call site.

## Workflow Shape

Every cleanup follows explore → propose → approve → apply:

1. **Explore.** Read the code. Identify all cleanup opportunities. Do not edit files.
2. **Propose.** Present a numbered list of changes, ordered largest-to-smallest refactor. Each item: one-line description, affected file(s), and rough scope (structural / cosmetic / deletion).
3. **Approve.** Ask the user to approve the list. They may approve all, select specific items by number, or deny. Only proceed with approved items.
4. **Apply.** Make the approved changes. Run build/tests afterward.

## Summary

Report at the end with a few sentences summarizing what changed and why.
