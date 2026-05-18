---
name: interview
description: >
  Use when the user wants to be interviewed about a plan, spec, RFC, or feature before building—
  "interview me", "poke holes in this", "what am I missing", stress-test a design, or flesh out
  requirements via Q&A. Runs deep questioning (AskUserQuestion or equivalent), then writes findings
  into the existing plan/spec or creates one.
---

Using the available context from our conversation – a formal spec in a plan document, or a less formal set of messages from the current chat – interview me in detail about anything that matters: technical implementation, UI & UX, concerns, tradeoffs, edge cases, scope. Surface what isn't obvious; skip what is.

Rules:

- **Resolve from the codebase first.** If a question can be answered by reading source, git history, tests, or types, do that instead of asking. Only ask what the code cannot tell you.
- **Walk the design tree branch by branch.** Sequence questions so earlier answers narrow or eliminate later ones. Don't ask in parallel about decisions that depend on each other.
- **One question at a time.** Use AskUserQuestion when available; fall back to plain prose questions one per turn.
- **Recommend an answer for every question.** State your pick and why in one line, then ask. For AskUserQuestion, put your recommendation first and append "(Recommended)" to the label. Freeform questions: lead with "I'd suggest X because Y — does that hold, or are you thinking differently?"
- **Keep freeform answers cheap.** A sentence or two max. If the answer would be longer, restructure as multiple choice.

Continue until the open branches are resolved, then write the findings into the existing plan or spec document. If none exists, create one.
