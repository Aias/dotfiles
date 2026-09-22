---
name: change-review
description: >
  Review a branch, PR, or workspace change-set, or perform a requested code cleanup. Supports read-only findings and authorized edits. Ordinary implementation and prose revision do not need this workflow.
global_category: Code Quality
---

# Change Review

Review and cleanup at the scope of a change-set — what's on this branch, in this PR, in the workspace diff, or in recently modified files. Type-safety and imports for `.ts`/`.tsx`, and HTML/CSS/markup conventions, all live here.

## Modes

Two modes. **Default to REVIEW** unless the user's verb is execute-shaped or they've explicitly picked items from a prior REVIEW.

| Mode       | Trigger verbs                                                                  | Output                                                | Workflow                              |
| ---------- | ------------------------------------------------------------------------------ | ----------------------------------------------------- | ------------------------------------- |
| **REVIEW** | review, evaluate, audit, analyze, breakdown, compare, "is X dead?", "is X used?", "anything I'm missing?" | Numbered findings in chat. No edits, no commits, no GitHub comments. | [references/review.md](references/review.md) |
| **APPLY**  | clean up, delete, remove, rip out, fix N, "go ahead", "implement", "wire up", deslop, tighten, refactor pass | Edits + optional commit. | [references/apply.md](references/apply.md) |

A user who says *"review this"* and then replies *"fix 2, 3, 5"* has moved from REVIEW to APPLY. The numbered list is the bridge — REVIEW output must be cherry-pickable by number.

## Scope

A change-review is **change-scoped**, never repo-wide. Pick scope in this order:

1. **Conductor workspace** — `mcp__conductor__GetWorkspaceDiff` with `stat: true` first, then specific files, when the harness exposes it; otherwise git and `gh` against the Conductor target branch (see [`/conductor`](../conductor/SKILL.md)).
2. **Open PR** — `gh pr diff` or `gh pr view --json files,baseRefName`.
3. **Branch vs base** — `git merge-base origin/<base> HEAD`, then `git diff <merge-base> HEAD` (or three-dot `git diff origin/<base>...HEAD`). Always `git fetch origin <base>` first; local refs go stale silently.
4. **Staged / uncommitted** — `git diff --staged` and/or `git diff HEAD`.
5. **Recently modified files** — only as a last resort, and only files the user explicitly named or you edited earlier in this conversation.

Never diff the full range between two long-lived branches (`dev...main`) — that pulls in unrelated merged work and pollutes the review.

State which scope you used in the report's first line. The answer to "how many files changed?" differs by tool, and the user will ask.

Report change size as `+added / −removed` from `git diff --shortstat` or the PR's own counts (`gh pr view --json additions,deletions`), never `wc -l` of a raw diff.

## REVIEW Mode (default)

Brief — full workflow in [references/review.md](references/review.md).

- **Read-only.** No edits, no commits, no GitHub/Linear comments unless explicitly authorized. Output is chat text only. When posting is authorized, attribute each agent-authored comment per `/pr-guidelines` (open with an italic `*<model>:*` prefix).
- Delegate substantial independent review work when it can run in parallel with useful local review. Choose the relevant axes for the change: correctness, instruction compliance, dead code, complexity, or spec conformance. Small focused changes can be reviewed directly.
- Use the strongest available tier for review judgment. Validate consequential findings adversarially, with a fresh reviewer when independent scrutiny adds value.
- **Cite file path + line range** on every finding. Never restate the diff.
- **Numbered list** with stable IDs (`#1`, `#2`, ...) so the user can reply "fix 2, 3, 5". Findings are grouped into **Clear fixes** (one right solution, all get applied regardless of severity) vs **Decisions needed** (a product/design choice gates the fix — options + one recommendation each); state what breaks, for whom, and why the evidence supports it. See [references/review.md](references/review.md#phase-4-report).
- **High signal in the report, not in the finders.** Finders report everything with confidence and severity; validation filters. The [explicit false-positives list](references/review.md#explicit-false-positives) (pre-existing issues, linter-catchable, pedantic nits) is a category exclusion that binds every stage.

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

Divide substantial cleanup into coherent steps. Continue within the authorized scope. Pause when a design decision or reserved action requires the user, or when the user requested a review checkpoint.

## Shared Principles

These apply to both modes — they shape what counts as a finding (REVIEW) and what counts as a clean diff (APPLY).

### Primary outcome: net LOC reduction

After cleanup, total LOC should usually be lower than before. If cleanup increases LOC, keep it only when it clearly reduces complexity or risk, and call out that tradeoff explicitly.

Diff size is itself a finding. A version bump that produces 20k+ lines of diff, or a feature that costs 10k+ lines for a small surface, is suspect — flag it and look for the maintainer-provided codemod, an idiomatic API the project missed, or generated content that should be excluded from review.

When categorizing a large diff, split into: **generated / boilerplate / moved / new logic**. The user evaluates PR quality partly by the new-logic fraction.

### What to remove

- Extra defensive checks or try/catch blocks abnormal for that codepath (especially if called by trusted/validated callers).
- Casts to `any` or `as` to get around type issues (see [Type safety](#type-safety)).
- Unnecessary or redundant type annotations.
- Variable declarations only used once right after declaration — inline them.
- Style inconsistent with the surrounding file.

### What NOT to remove

- `useCallback`, `useMemo`, `memo`, or other performance primitives — only change with profiling evidence or explicit user direction.
- **Intentional scaffolding.** Re-export barrels, design-system primitives (`*.primitives.tsx`), and framework-required exports may look "unused" to knip but exist for a reason. Ask before pruning. (No tension with [Barrel files](#barrel-files): never *create* new barrels; don't *delete* existing ones without asking.)
- **Repetition that serves an argument.** Callbacks, deliberate restatement, or layered comments that reinforce intent are not duplication. Only flag *fully duplicated / redundant* sections.
- **Specific semantic intent.** A `<dialog>` wrapper exists for top-layer semantics; a button-styled-as-link exists for download behavior. Read the intent before flattening.

<!-- @> No shipped stubs, mocks, hardcoded fixtures, or "temporary" literals. Replace stand-ins with real sources before handoff. Mid-stream stubs stay greppable through a stub/mock-prefixed identifier, never a comment -->

### No shipped stubs, mocks, or temporary values

Stubs, mocks, hardcoded fixtures, "temporary" literals, debug values, and inline test data **do not ship**. If you wired a UI, query, or branch to a stand-in during development, replace it with the real source before declaring the work done. The risk isn't sloppiness — it's that a forgotten stub silently shapes behavior, and when the feature misbehaves weeks later, the cause is invisible and the debugging trail leads in the wrong direction.

If a stub must exist mid-stream (active debugging, intentional prototyping), make it greppable through its identifier (a `stub`/`mock`-prefixed name), never through a comment. Before handoff, search the touched feature for `STUB`, `MOCK`, fixture arrays, and hardcoded values that mirror enum or option labels, and remove them. Unmarked stubs are a first-class REVIEW finding.

<!-- @> Hard rule: a file may not cross from below 1000 lines to above. Only waiver is extremely uniform content (data table, generated code, flat enum) where any split would hurt readability. Decompose first by default -->

### The 1000-line ceiling

A file may not cross from below 1000 lines to above. This applies to REVIEW (flag the violation) and APPLY (decompose before letting a change push the file over).

The only valid waiver: the file is extremely uniform — a long data table, generated code, a flat enum, a list of route registrations — where any split would hurt readability. If the file has meaningful control flow or distinct sections, decompose first. Don't waive because the new code "logically belongs here" or because splitting "is a lot of work."

When APPLY would push a file across the line, decompose it as part of the change (subcomponents, helpers, separate modules), following the codebase's existing module patterns. Raise the split as a decision only when it creates a new boundary in shared code.

### Cleanup uncovers more cleanup

After removing a feature, branch, or component, search the codebase for sibling code that's now dead — utilities only it called, design tokens only it used, GraphQL fields only it queried, fixtures only it referenced, schema columns only it wrote. A one-shot deletion that only removes the named thing under-delivers. The user expects the cleanup to **follow the thread**.

Scope guard: stay within the change-set's natural boundary. "Sibling code that became dead because of this change" is in scope. "Sibling code that was always dead but you noticed in passing" is a follow-up, not this PR.

### List ordering

Every list has an intrinsic best order. Match the list's purpose rather than defaulting to alphabetical:

- **Alphabetical** for catalogs read like a glossary (dependency blocks, env keys, allowlists, enum members consumed by humans).
- **Dependency/logical** when earlier entries set up later ones (import groupings, CSS declaration order, pipeline stages).
- **Frequency or salience** for lookup tables where readers scan for common cases first.
- **Numeric/temporal** for sequence-bearing data (versioned migrations, dated entries).

When adding an entry, place it in the correct position rather than appending. The only reason to break the intrinsic order is a hard syntactic or logical constraint.

For config files that combine tool defaults with project overrides, encode only the **deviations**: a short config that diverges meaningfully is more readable than a long one that mostly restates the defaults. Before adding an option, check whether it matches the default; if so, omit it.

### Comment policy

Never add code comments. Following GLOBAL.md's comment policy, exceptions require very strong surrounding precedent that comments are required, or an explicit user request. Nearby comments alone do not establish that requirement. Existing comments are not findings merely because they are comments or appear in a touched file. In APPLY, do not proactively delete them unless rewriting the code they describe. In REVIEW, do not recommend removing them solely to reduce comments. When rewriting associated code, assess its comments for accuracy and usefulness. Machine-read directives are code, and lint suppressions remain governed by the lint-directives rule. Add `TODO`-style markers only when the user specifically requests them.

### Don't silence the tool; don't roll your own codemod

When a tool reports something you've already accepted as correct, run it and let downstream state settle — don't reach for `ignore` / `exclude` / `skip` config to silence it. When the upstream maintainers publish an official migration path (codemod, preset, framework-provided helper), prefer it over a handwritten substitute, even when the resulting diff is larger. A 20k-line maintainer codemod is more trustworthy than a 2k-line homegrown one. Parallel subagents > scripted refactors when no official codemod exists.

A lint rule targets a behavior, not a token. Switching to a sibling construct that produces the same flagged output — a wrapper or alternate API that emits exactly what a `no-X` rule forbids — dodges the rule without honoring it, and is still a workaround. Two honest paths: fix at the root so the rule passes on its merits, or, when the rule genuinely doesn't fit the case, write a real standard for the codebase and disable the rule deliberately. An off-the-cuff sibling swap is neither.

Inline suppression is a last resort, valid only when a rule blocks the sole viable approach and no compliant alternative exists. Exhaust the alternative first and offer the simpler-code path before suppressing: a rule against array-index list keys is satisfied by a stable id from the data, not a disable comment. Type-safety escape hatches (`any`, `as`, `!`, `ts-ignore`) are never the last resort — see [Type safety](#type-safety).

## Types, imports & tooling (`.ts`, `.tsx`)

Applies when writing or reviewing TypeScript: typecheck failures, strictness, generics, barrels, module layout — not only during cleanup passes.

### Type safety

**Never compromise type safety**: No `any`, no type assertions (`as Type`), no non-null assertions (`!`), no `ts-ignore`/`eslint-disable`/lint-disable. Avoid `unknown` unless narrowed immediately. This holds equally in backend resolvers and services — a cast in a query layer is no more acceptable than one in a component.

A cast is a symptom: the type is too wide somewhere upstream. Fix the source, not the call site.

- **Tighten the upstream type so the cast and its guard both disappear.** When a parameter is declared wider than its only callers supply — `string` where the caller already hands over the source's union or enum — narrow the parameter to the real type. The cast and the runtime guard that defended it both fall away.
- **Invert, don't widen-then-cast.** When a value doesn't fit a consumer, the fix is rarely to broaden the consumer's type and cast at the boundary. Broaden in the wrong direction and every caller inherits the looser contract. Instead, make the real type flow through from where it originates.
- **Parse at the boundary, narrow within it.** Validate untrusted input with a schema (zod or equivalent) at the edge so a typed value flows inward; narrow runtime variants with `instanceof` or a discriminant. Both replace the assertion with a check the compiler trusts.
- **Don't assert how the type system behaves.** A claim that "TS widens this" or "the inference fails here" is a verification step — confirm it with a minimal repro before designing around it, never from intuition.

### Component & prop style

- Order prop intersections: specific props before generic (`{ specific } & RootProps`).
- Favor readability over brevity; avoid mirror variables.
- Follow existing conventions: use `rg`, `fd`, git history before adding patterns.
- Don't declare variables only used once immediately after; inline them.

### Imports & dependencies

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


### Semantic HTML first

<!-- @> Prefer native semantic elements. Preserve keyboard interaction and visible focus when building or simplifying UI -->
Prefer built-in semantics over generic containers: structure (`article`, `header`, `main`, `nav`, `section`, `ul`/`li`), interactive (`button`, `form`, `label`), content (`table`, `time`). Avoid `div`/`span` unless necessary. Prefer real text + structure over ARIA-only shortcuts.


### Layout

- Flexbox/grid with `gap` for spacing between children.
- `margin` is a code smell — prefer container `padding` or `gap`; margins break encapsulation.
- Logical properties: `block`/`inline`, `start`/`end` over physical `left`/`right`/`top`/`bottom` where appropriate.
- Transform sub-properties (`translate`, `rotate`, `scale`) over a single long `transform` when the stack allows it.


### Declaration order

Order by concern, outside-in (not alphabetically): position & display → flex/grid container & child → sizing & spacing → overflow → typography → visual (color, background, border, shadow) → transform & animation → interaction (`cursor`, `pointer-events`, `user-select`). Applies to CSS-in-JS objects too.


### State styling

<!-- @> Style selected, active, and expanded states through data or appropriate ARIA attributes and CSS selectors rather than conditional class names -->
Drive selected/active/expanded state with a data attribute and an attribute selector (`[data-state="active"] {…}`, `[aria-pressed="true"]`), not a conditional className or `cx()` merge in the component. The DOM stays declarative, the styling lives with the rest of the component's CSS, and the state is inspectable in devtools without reading render logic.


### Layout stability

Avoid layout shift (CLS) by holding geometry constant across state and breakpoint:

- **Container queries, not viewport queries, when the available width is set by a sibling.** If a region's space is driven by a collapsible panel, resizable sidebar, or split pane rather than the viewport, set `container-type: inline-size` on the layout that owns the width and query it (`@container`). Viewport queries respond to the wrong axis and break when the surrounding layout changes. Audit existing `@media` width queries for this case when touching responsive layout.
- **Keep controls present and in the same order across every variant.** A control that appears in one state should occupy the same slot in the others rather than appearing, disappearing, or reordering. Consistent placement prevents both the UX surprise of a moving target and the reflow when an element pops into the flow.
- **A border that must not change box height becomes an `inset box-shadow`.** A `1px` border adds to height; toggling it between states shifts everything below by a pixel. Use `box-shadow: inset 0 0 0 1px …` instead, or keep an equal transparent border (`border: 1px solid transparent`) in every state so the box height never changes.


### Colors

Design tokens / CSS custom properties first; otherwise `oklch` or hex — not `rgb` for new work.


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

## Completion

A review request ends with supported findings and unresolved decisions. An authorized cleanup ends with the requested edits and relevant checks complete. Preserve existing authorization and ask only where scope or a reserved action remains unsettled.
