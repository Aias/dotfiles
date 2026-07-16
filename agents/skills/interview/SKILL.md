---
name: interview
description: >
  Use when the user wants to be interviewed about a plan, spec, RFC, or feature before building—
  "interview me", "poke holes in this", "what am I missing", stress-test a design, or flesh out
  requirements via Q&A. Runs deep questioning (AskUserQuestion or equivalent), then writes findings
  into the existing plan/spec or creates one.
---

Using the available context from our conversation – a formal spec in a plan document, or a less formal set of messages from the current chat – interview me in detail about anything that matters: technical implementation, UI & UX, concerns, tradeoffs, edge cases, scope. Surface what isn't obvious; skip what is. Obvious means answerable from the spec, the codebase, or an established convention; anything resting on my intent, a tradeoff, or unstated scope is not obvious, however likely the answer feels.

Rules:

- **Work the design tree in frontier rounds.** Sketch the dependency order before the first question — which decisions gate which. The frontier is every question whose prerequisites are settled; ask the whole frontier each round, and hold back any question that depends on another still open this round. Use AskUserQuestion, up to 4 questions per call (multiple calls when the frontier is bigger); fall back to numbered prose questions in one message. After each round, recompute the frontier — answers prune branches and unblock new ones.
- **Resolve facts yourself, off the user's turn.** If a question can be answered by reading source, git history, tests, or types, do that instead of asking — only ask what the code cannot tell you. Dispatch lookups as background subagents and ask the rest of the frontier meanwhile: a running lookup is an unsettled prerequisite, so only its downstream questions wait for it.
- **Recommend an answer for every question.** State your pick and why in one line, then ask. For AskUserQuestion, put your recommendation first and append "(Recommended)" to the label. Freeform questions: lead with "I'd suggest X because Y — does that hold, or are you thinking differently?"
- **Keep freeform answers cheap.** A sentence or two max. If the answer would be longer, restructure as multiple choice.

The interview is done when the frontier is empty — nothing left silently assumed. Then write the findings into the existing plan or spec document; if none exists, create one.
