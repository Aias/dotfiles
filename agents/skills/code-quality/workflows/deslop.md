# Deslop (Light Touch)

Strip AI-generated artifacts from recent changes. No structural modifications.

## Workflow

1. Use git and/or the GitHub CLI to find the most relevant comparison commit (either the target of this branch's open PR or the commit from which this branch was created).
2. Review the diff of this branch and staged changes.
3. Remove or refactor anything characteristic of AI slop introduced since the comparison commit — see [Shared Principles](../SKILL.md#shared-principles).
4. Do **not** change control flow, remove parameters, or restructure logic. This is cosmetic only.
