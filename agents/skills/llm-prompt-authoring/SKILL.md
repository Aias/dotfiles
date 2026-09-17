---
name: llm-prompt-authoring
description: >
  Create or revise instructions consumed by a model, including system prompts, skill guidance,
  tool descriptions, and evaluation rubrics. Use for prompt behavior and quality, not model selection alone.
---

# LLM prompt authoring

State the desired outcome, relevant context, and decision boundaries. Preserve explicit constraints and permissions. Prefer affirmative wording when it communicates the rule fully. Keep an explicit exclusion when it defines a necessary boundary.

Scope instructions to the conditions where they apply, and reserve absolutes for invariants. Audit instructions for cases where literal compliance would misfire. Generic advice about being thorough, thinking carefully, or following a fixed itinerary rarely adds information beyond the task.

Keep descriptions short and specific to the task the skill actually serves. Put essential constraints in the entry point and substantial conditional workflows in references. Link another skill only when the task needs its guidance. Remove duplicated instructions across prompts, skills, and standing rules.

Preserve useful tool protocols, domain knowledge, output contracts, and user preferences. Give the model room to choose a method where several methods can satisfy the task. Use examples to clarify ambiguous boundaries.

Evaluate meaningful prompt changes on representative requests, including requests that should not trigger the workflow. Compare the output and behavior, not just instruction length. Usage logs can reveal misrouting, but invocation counts alone do not measure benefit. Keep conclusions scoped to the models and tasks observed.

## Provider-specific behavior

Read the provider's current documentation when changing model selection, caching, or API behavior. Keep those choices unchanged during a wording edit unless the requested outcome requires them.

Prompt-caching controls and pricing depend on the provider. Reuse stable prefixes and check the provider's actual hit, write, and retention rules before adding cache configuration. A write premium is not a universal property of prompt caching.
