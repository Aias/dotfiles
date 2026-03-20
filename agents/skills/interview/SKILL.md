---
name: interview
description: >
  Use when the user wants to be interviewed about a plan, spec, RFC, or feature before building—
  "interview me", "poke holes in this", "what am I missing", stress-test a design, or flesh out
  requirements via Q&A. Runs deep questioning (AskUserQuestion or equivalent), then writes findings
  into the existing plan/spec or creates one.
---

Using the available context from our conversation – this might be a formal spec in a plan document we're working on, or a less formal set of messages from the current chat – interview me in detail using the AskUserQuestionTool about literally anything: technical implementation, UI & UX, concerns, tradeoffs, etc. but make sure the questions are not obvious. If the AskUserQuestionTool isn't available, or an equivalent doesn't exist, then simply ask questions one by one. Questions can either be multiple choice, or freeform, but freeform questions should not require a response longer than a sentence or two.

Be _very in-depth_ and interview me continually until all potential questions have been resolved, then write the spec to the existing plan document or spec file, or create a new one if one doesn't exist.
