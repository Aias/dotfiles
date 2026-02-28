---
name: code-quality
description: >
  Code cleanup at any intensity — from light-touch AI slop removal to full
  structural refactoring. Use when the user asks to "deslop", "clean up",
  "refactor", "simplify", remove dead code, or do a cleanup pass. Triggers on:
  "deslop", "remove slop", "clean this up", "refactor pass", "simplify",
  "dead code", "cleanup pass", "tighten this up".
global_category: Code Quality
---

# Code Quality

Cleanup and refactoring at the intensity the user requests.

## Intensity Spectrum

| Level                | Trigger phrases                                        | Scope                                                                                                    |
| -------------------- | ------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| **Light** (deslop)    | "deslop", "remove slop", "clean up the AI stuff"    | Strip AI artifacts. No structural changes. [Workflow →](references/deslop.md)                             |
| **Heavy** (refactor)  | "refactor pass", "tighten up", "dead code"           | Structural cleanup, dead path removal, build/test verification. [Workflow →](references/refactor-pass.md) |
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
- Casts to `any` or usage of `as` to get around type issues
- Unnecessary or redundant type annotations
- Obvious variable declarations only used once right after declaration
- Any style inconsistent with the surrounding file

<!-- @> Do not auto-remove useCallback, useMemo, or memo. Only change with clear evidence or explicit user direction -->

### Performance Primitives

- Do not remove `useCallback`, `useMemo`, or `memo` automatically during cleanup.
- Only change memoization with clear evidence (profiling, measurable impact) or explicit user direction.

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

## Workflow Shape

Every cleanup follows explore → propose → approve → apply:

1. **Explore.** Read the code. Identify all cleanup opportunities. Do not edit files.
2. **Propose.** Present a numbered list of changes, ordered largest-to-smallest refactor. Each item: one-line description, affected file(s), and rough scope (structural / cosmetic / deletion).
3. **Approve.** Ask the user to approve the list. They may approve all, select specific items by number, or deny. Only proceed with approved items.
4. **Apply.** Make the approved changes. Run build/tests afterward.

## Summary

Report at the end with a few sentences summarizing what changed and why.
