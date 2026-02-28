# Refactor Pass (Heavy)

Structural cleanup focused on simplicity after recent changes.

## Workflow

1. Review the changes just made and identify simplification opportunities:
   - Dead code and dead paths.
   - Logic flows that can be straightened.
   - Excessive parameters.
   - Premature optimization.
   - [Shared principles](../SKILL.md#shared-principles) violations (slop, comment policy).
   - **Rule of Three:** Search for duplicated or near-identical functions/patterns. Three or more copies is a signal to extract a shared abstraction (only if the abstraction is clearer than the repetition).
2. Present a numbered list of proposed refactors, ordered largest-to-smallest. Each item: one-line description, affected file(s), and scope (structural / cosmetic / deletion).
3. Ask the user to approve all, select by number, or deny.
4. Apply only approved refactors.
5. Run build/tests to verify behavior.
