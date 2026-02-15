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

| Level | Trigger phrases | Scope |
|-------|----------------|-------|
| **Light** (deslop) | "deslop", "remove slop", "clean up the AI stuff" | Strip AI artifacts. No structural changes. [Workflow →](workflows/deslop.md) |
| **Heavy** (refactor) | "refactor pass", "simplify", "tighten up", "dead code" | Structural cleanup, dead path removal, build/test verification. [Workflow →](workflows/refactor-pass.md) |

If the user doesn't specify, infer from context: post-AI-generation → light, post-feature-complete → heavy. When uncertain, ask.

## Shared Principles

<!-- @> Remove defensive checks, type casts, redundant annotations, single-use variables abnormal for codepath context -->
### What to Remove

- Extra defensive checks or try/catch blocks abnormal for that codepath (especially if called by trusted/validated callers)
- Casts to `any` or usage of `as` to get around type issues
- Unnecessary or redundant type annotations
- Obvious variable declarations only used once right after declaration
- Any style inconsistent with the surrounding file

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

## Summary

Report at the end with a few sentences summarizing what changed and why.
