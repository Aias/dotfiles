---
name: refine-skills
description: >
  Review accumulated skill.feedback.md notes during requested skill maintenance and promote
  supported preferences into canonical instructions. Feedback is a review queue, not live guidance.
---

# Refine skills

Read feedback during a requested refinement or periodic maintenance task. Normal skill use reads the compiled skill only. Feedback files stay local and are excluded from deployment.

Compare each relevant note with the current source instructions and the user's intent. Repeated corrections can reveal a missing rule, but repetition alone does not make a task-specific preference universal. Keep unsupported inferences in the queue. Flag conflicts with explicit standing rules instead of silently overriding them.

Consolidate supported guidance into the smallest appropriate source: a skill, project instructions, or GLOBAL.md. Scope harness-specific guidance with the inclusion markers. Keep private details in local-only sources. Add examples only when they clarify the rule on a different, representative task.

An explicit request to apply a defined refinement authorizes that edit. For proposed changes to standing preferences that the user has not authorized, present the wording, destination, and reason for approval. Reuse authorization already given in the session.

After applying an approved promotion, remove its queue entry, run `make compile`, and deploy with `make link`. Report the changes and any conflicts or unreviewed notes that remain. Successful promotion replaces repetition with one clear instruction.
