---
name: llm-prompt-authoring
description: >
  Use when writing or editing a prompt that another model consumes—system prompts, tool/function
  descriptions, extraction or classification instructions, image-generation prompts, LLM-judge rubrics,
  or any multi-stage AI pipeline. Triggers on "the prompt", "tune the prompt", "the extractor/judge/curator
  anchors on", "prompt is too long", "cache_control", "prompt caching", "which model should this call".
  For the prose itself, pair with `/write`; for model ids, pricing, and caching mechanics, see `/claude-api`.
global_category: AI
---

# LLM Prompt Authoring

Craft for prompts that a downstream model reads, distinct from prose a human reads (`/write`). The reader is a sampler over tokens, so framing, ordering, and cost behave differently.

## Framing

<!-- @> Prompt the model toward the target, never away from a distractor: "not X" anchors it on X. Affirmative instructions; describe the wanted output, not the banned one -->
**Prefer affirmative instructions.** State what the output should be, not what it should avoid. A negative instruction injects the excluded concept into the context, and the model anchors on it: image and language models alike sample toward salient tokens and weight `not` weakly. "Render an empty room" beats "render a room with no people"; "extract only verifiable claims" beats "don't extract opinions." This is the bag-of-words skim from `/write`, sharpened. Here the reader literally conditions on every token you write, so a banned concept you name becomes a concept you summoned.

**When you must exclude, name the positive alternative.** If a constraint is unavoidable, pair it with the wanted target so the model has something to move toward: "use a neutral gray background" rather than "avoid colored backgrounds."

**Keep examples on-target.** Few-shot examples and counter-examples both teach by demonstration; a vivid counter-example can be imitated as readily as a positive one. Lead with examples of the output you want.

## Cost and Caching

**Cache only what you reuse.** Prompt caching (`cache_control`) pays a write premium to amortize a stable prefix across calls. Mark a span cacheable only when later requests reuse that exact prefix: a fixed system prompt, a shared rubric, a tool schema. Turn it off for per-call payloads that never recur, such as a one-shot image or document handed to a single extraction or judging stage, request-specific user content, or anything downstream of the cache breakpoint. Caching unrepeated content adds the write surcharge with no hit to recover it. See `/claude-api` for breakpoint placement and pricing.

**Default to the latest model when touching a pipeline.** When editing an AI pipeline, pin its calls to the current stable model rather than inheriting a stale id. Confirm the id against `/claude-api`; never carry an old version forward by default.

## Length

**Trim while editing.** Long prompts dilute attention and cost tokens every call. On any pass, cut redundancy: instructions repeated across the system prompt and the user turn, restated constraints, hedges, throat-clearing. State each instruction once, in the place the model reads it. Apply `/write` density rules: every sentence in a prompt earns its place the same way every sentence in prose does.
