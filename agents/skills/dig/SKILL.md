---
name: dig
description: >-
  Investigate an unresolved bug or disputed explanation across code, history, and runtime evidence.
  Use for /dig, a requested root-cause investigation, or a failed initial diagnosis.
  Ordinary code explanations do not need this workflow.
---

# Dig

Deliver a supported explanation of the reported behavior, its cause, and its impact. Match the depth to the unresolved question. Temporary instrumentation in local code is fine; remove it before reporting. Leave no lasting code changes and no external-state changes during diagnosis. A request that also authorizes a fix can proceed to that fix once the cause is established.

Follow the evidence across repository and service boundaries when the cause lies there. Choose source, history, dependency code, logs, data, or a reproduction according to the claim they can settle. A checklist of systems to visit is unnecessary.

Test the strongest competing explanation before concluding. For a suspected regression, compare the relevant behavior with the baseline before attributing it to the change. Distinguish what source code implies from what the failing environment actually runs.

Temporary scripts and isolated reproductions are useful when they resolve uncertainty. Use existing authorized access. Ask for missing access or an input whose location only the user knows.

Lead with the finding and its practical impact. Cite the code, history, or runtime evidence supporting consequential claims. State what remains unknown and the evidence needed to resolve it. Stop when the requested question is answered or the remaining evidence requires user input or unavailable access.
