---
name: debugging-approach
description: Systematic debugging strategies for complex issues spanning multiple components or systems. Use when debugging multi-component issues, tracking state changes, or investigating unexpected behavior in third-party code.
---

# Debugging Approach

## Complex Multi-Component Issues

When debugging issues spanning multiple components:

1. **Add comprehensive logging** at key lifecycle points (mounting, state changes, focus events)
2. **Visual categorization** - Use emojis or prefixes for scannable log categories:
   - `[ComponentName] 🚀 action`
   - `[ComponentName] 📍 checkpoint`
3. **Compact string logs** - Easier to copy-paste than objects:
   - Good: `console.log(\`active=${tag} focused=${bool}\`)`
   - Avoid: `console.log({ active, focused })`
4. **Before/after snapshots** - Include both states for changes
5. **Clean up** - Remove debug logging after resolution

## Third-Party Code Investigation

When encountering unexpected behavior in third-party libraries or framework-generated code, read the actual source code (including generated files like styled-system, build output, etc.) rather than relying on documentation alone.

The source code is the ground truth.
