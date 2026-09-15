---
name: debug-agent
description: >-
  Diagnose and fix a bug that needs additional runtime evidence, when source changes are authorized.
  Uses targeted instrumentation only where existing tests, logs, and observations leave the cause unresolved.
global_category: Investigation
---

# Runtime debugging

Use the reported failure and relevant source to identify the evidence that would distinguish plausible causes. Reuse an existing failing test, log, API response, or browser observation when it answers the question.

<!-- @> Add instrumentation only when existing evidence cannot distinguish causes and source changes are authorized; verify the fix against the observed failure and remove temporary instrumentation -->
Add instrumentation only to resolve a specific uncertainty. Choose the least intrusive mechanism the environment supports. The [debug-agent daemon protocol](references/daemon.md) provides a shared log sink when one is needed.

<!-- @> Keep instrumentation and experimental writes out of production; reproduce the relevant conditions in an authorized safe environment -->
Keep instrumentation and experimental writes out of production. Reproduce the relevant conditions locally or in an authorized test environment. Log only the fields needed to distinguish causes, excluding credentials and personal data.

Preserve the pre-fix evidence, make the supported fix, and compare the same failing behavior afterward. A test result, response, or browser observation can establish success without adding a separate log-based test. Ask the user to reproduce only when their participation is necessary.

When evidence rejects a hypothesis, remove changes made solely for it. If no cause is established, report the remaining uncertainty and required evidence. Additional speculative fixes do not substitute for a diagnosis.

<!-- @> Fix lifecycle and synchronization problems through their actual dependencies rather than artificial delays -->
Fix lifecycle and synchronization problems through their actual dependencies rather than artificial delays.

After verification, remove temporary instrumentation and stop services started for the investigation. Review the remaining diff for unintended changes. Report the cause, fix, and verification, including any limits of the reproduction.
