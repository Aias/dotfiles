# Deslop (Light Touch)

Strip AI-generated artifacts from recent changes. No structural modifications.

**See also:** [PR Guidelines](../../pr-guidelines/SKILL.md) (prose in PR descriptions), [Writing](../../write/SKILL.md) (prose style)

## Workflow

1. Use git and/or the GitHub CLI to find the most relevant comparison commit (either the target of this branch's open PR or the commit from which this branch was created).
2. Review the diff of this branch and staged changes.
3. Identify everything characteristic of AI slop introduced since the comparison commit — see [Shared Principles](../SKILL.md#shared-principles).
4. Present a numbered list of proposed removals/fixes, ordered largest-to-smallest. Each item: one-line description, affected file(s), scope.
5. Ask the user to approve all, select by number, or deny.
6. Apply only approved changes. Do **not** change control flow, remove parameters, or restructure logic — cosmetic only.
