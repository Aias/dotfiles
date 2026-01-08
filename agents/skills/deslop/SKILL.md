---
name: deslop
description: Remove AI code slop
---

# Remove AI code slop

Use git and/or the Github CLI to find the most relevant comparison commit (either the target of this branch's open PR or the commit from which this branch was created). Then, check the diff of this branch as well as staged changes, and remove all or refactor any code that is characteristic of "AI slop" that's been introduced since the comparison commit.

This includes:

- Extra defensive checks or try/catch blocks that are abnormal for that area of the codebase (especially if called by trusted / validated codepaths)
- Casts to `any` or usage of `as` to get around type issues
- Unnecessary or redundant type annotations
- Obvious variable declarations that are only used once right after declaration
- Any other style that is inconsistent with the file

## Comment Policy

Remove unacceptable comments:

- Comments that repeat what code does
- Commented-out code (delete it)
- Obvious comments ("increment counter")
- Comments that could be fixed by better naming
- Comments about updates to old code (e.g. "now supports xyz", "moved to new location")

Code should be self-documenting. If a comment explains WHAT the code does, consider refactoring to make it clearer instead.

Acceptable comments:

- Comments that explain an unintuitive decision
- Comments that intuitively explain a complex calculation, logic, or algorithm
- Comments that justify an inconsistency or deviation from standard practices
- Comments that translate a phrase or set of symbols that would otherwise be unintelligible to an English-speaking human

## Summary

Report at the end with only a few sentences summarizing what you changed and why.
