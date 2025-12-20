---
name: deslop
description: Remove AI code slop
---

# Remove AI code slop

Use git and/or the Github CLI to find the most relevant comparison commit (either the target of this branch's open PR or the commit from which this branch was created). Then, check the diff of this branch as well as staged changes, and remove all AI generated slop that's been introduced since the comparison commit.

This includes:

- Extra comments that a human wouldn't add or is inconsistent with the rest of the file
- Extra defensive checks or try/catch blocks that are abnormal for that area of the codebase (especially if called by trusted / validated codepaths)
- Casts to `any` or usage of `as` to get around type issues
- Any other style that is inconsistent with the file

Report at the end with only a 1-3 sentence summary of what you changed
