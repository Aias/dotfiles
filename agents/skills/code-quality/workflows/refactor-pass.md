# Refactor Pass (Heavy)

Structural cleanup focused on simplicity after recent changes.

## Workflow

1. Review the changes just made and identify simplification opportunities.
2. Apply refactors:
   - Remove dead code and dead paths.
   - Straighten logic flows.
   - Remove excessive parameters.
   - Remove premature optimization.
   - Apply [shared principles](../SKILL.md#shared-principles) (slop removal, comment policy).
3. **Rule of Three:** Search for duplicated or near-identical functions/patterns. One or two copies is fine — three or more is a signal to extract a shared abstraction. Only extract if the abstraction is clearer than the repetition.
4. Run build/tests to verify behavior.
5. Identify optional abstractions or reusable patterns; only suggest them if they clearly improve clarity and keep suggestions brief.
