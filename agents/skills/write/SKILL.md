---
name: write
description: >
  Draft or revise a written deliverable such as documentation, a PR description, an issue, or agent instructions.
  Use for explicit prose editing and /write. Routine status updates use the standing writing rules.
global_category: Writing
---

# Write

Write for an intelligent reader who has not seen the investigation or conversation behind the text. Preserve the user's meaning and level of certainty. Apply these conventions to the guidance itself.

## Clarity

<!-- @> Write for a reader without the session's context: name referents, explain necessary terms, and lead with the answer or action -->
Lead with the answer or needed action. Supply the context that makes it understandable. Name code by its role before giving the identifier, such as "the retry limit (`maxAttempts`)". Expand unfamiliar acronyms and use the project's terms consistently.

Give each paragraph one main point. Use concrete subjects, active verbs, and short sentences where they help the reader. Keep details that change what the reader understands or does. Remove repetition, throat-clearing, and explanations of the writing process.

Preserve necessary qualifications. Replacing "some requests fail" with "requests fail" changes the claim. State uncertainty plainly and keep evidence separate from inference.

## Voice

<!-- @> State the point directly; omit negate-then-reframe, em dashes, semicolons, filler, promotional language, and invented compound labels -->
State the point directly. Omit negate-then-reframe constructions, em dashes, semicolons, decorative participial tails, and invented compound labels. Use a literal phrase when it expresses the meaning. Prefer familiar words over formal substitutes.

Cut praise, promotional language, inflated stakes, canned transitions, hedging stacks, and generic positive conclusions. A word used literally in the domain remains useful. "The stack trace points to the allocator" is precise.

Use sentence case in headings and straight quotation marks. Avoid decorative emoji, capitals for emphasis, and repeated bold-label bullets. Use lists and headings where they help the reader find information.

## Deliverables

### Chat explanations

Open with the result or decision. Name the affected behavior and explain why it matters. Restore skipped context when the user is confused. Keep routine updates short without turning them into shorthand the reader must decode.

### PR descriptions and commit messages

Describe the problem before the solution. Use present tense, a single authorial point of view, and the final scope. Follow the pr-guidelines skill when preparing PR prose or GitHub comments. Include validation that helps a reviewer assess the change.

### Documentation

<!-- @> Match documentation to the public surface and surrounding scope; verify claims against the implementation and keep feature concepts durable -->
Match the surrounding documentation's scope. Explain public behavior and durable concepts. Document internal details only where the surrounding material calls for them. Verify technical claims against the relevant implementation. Use examples when they clarify a decision or behavior.

Use relative file links in repository documents. Use the destination renderer's supported syntax for line links. Keep absolute machine paths in local artifacts only.

### Agent instructions

State the applicable condition and desired behavior. Keep each rule short. Add an example only when it prevents a likely misreading, using a representative case rather than the incident that prompted the rule. For model-facing instructions, apply the llm-prompt-authoring skill's scope and evaluation guidance.

Read the finished text for missing context, unsupported claims, and needless words. Stop when the requested deliverable is complete.
