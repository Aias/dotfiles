---
name: council
description: Council is a skill that helps the user make decisions by gathering information from the codebase and spawning off task agents to dig deeper into the codebase.
---

Based on the given area of interest, please:

1. Dig around the codebase in terms of that given area of interest, gather general information such as keywords and architecture overview.
2. Spawn off n=10 (unless specified otherwise) task agents to dig deeper into the codebase in terms of that given area of interest, some of them should be out of the box for variance.
3. Once the task agents are done, use the information to do what the user wants.

If user is in plan mode, use the information to create the plan.
