---
name: repomix
description: Pack codebases into AI-friendly formats for LLM analysis. Use when needing to prepare code context for AI tools, analyze remote repositories, generate single-file representations of projects, or when user mentions "pack", "repomix", or preparing code for AI.
---

# Repomix

Pack entire codebases into a single AI-optimized file. Supports local and remote repositories with token counting, security scanning, and multiple output formats.

## Quick Start

```bash
# Pack current directory
repomix

# Pack specific directory
repomix path/to/directory

# Pack remote repository
repomix --remote user/repo
repomix --remote https://github.com/user/repo

# Pack with compression (reduces tokens ~70%)
repomix --compress

# Output to stdout (pipe to other tools)
repomix --stdout | llm "Explain this code"
```

## Output Formats

```bash
repomix --style xml        # Default, best for Claude
repomix --style markdown   # Human-readable
repomix --style json       # Programmatic processing
repomix --style plain      # Simple text
```

## File Selection

```bash
# Include only specific patterns
repomix --include "src/**/*.ts,**/*.md"

# Exclude patterns
repomix --ignore "**/*.test.ts,docs/**"

# Combine with stdin for precise control
fd -e ts | repomix --stdin
rg -l "TODO" **/*.ts | repomix --stdin
git ls-files "*.ts" | repomix --stdin
```

## Remote Repositories

```bash
# GitHub shorthand
repomix --remote yamadashy/repomix

# Specific branch/tag/commit
repomix --remote user/repo --remote-branch main
repomix --remote https://github.com/user/repo/tree/feature-branch
repomix --remote https://github.com/user/repo/commit/abc123
```

## Token Optimization

```bash
# Show token distribution tree
repomix --token-count-tree

# With minimum threshold
repomix --token-count-tree 1000

# Compress output (extracts signatures, removes implementation)
repomix --compress

# Split large outputs
repomix --split-output 1mb
```

## Common Options

| Option                    | Description                                    |
| ------------------------- | ---------------------------------------------- |
| `-o, --output <file>`     | Output file path (default: repomix-output.xml) |
| `--style <style>`         | xml, markdown, json, plain                     |
| `--compress`              | Extract essential code structure               |
| `--include <patterns>`    | Glob patterns to include                       |
| `-i, --ignore <patterns>` | Patterns to exclude                            |
| `--remote <url>`          | Process remote repository                      |
| `--stdout`                | Output to stdout                               |
| `--copy`                  | Copy output to clipboard                       |
| `--no-security-check`     | Skip sensitive data scanning                   |
| `--include-diffs`         | Add git diff section                           |
| `--include-logs`          | Add git commit history                         |

## Configuration

Initialize config file:

```bash
repomix --init
```

Creates `repomix.config.json`:

```json
{
  "$schema": "https://repomix.com/schemas/latest/schema.json",
  "output": {
    "filePath": "repomix-output.xml",
    "style": "xml",
    "compress": false
  },
  "include": ["**/*"],
  "ignore": {
    "useGitignore": true,
    "customPatterns": ["**/*.log"]
  }
}
```

## Ignore Patterns

Priority (highest to lowest):

1. `ignore.customPatterns` in config
2. `.repomixignore`, `.ignore`, `.gitignore`
3. Default patterns (node_modules, .git, etc.)

## Working with JSON Output

```bash
# List all file paths
cat repomix-output.json | jq -r '.files | keys[]'

# Extract specific file
cat repomix-output.json | jq -r '.files["src/index.ts"]'

# Find TypeScript files
cat repomix-output.json | jq -r '.files | keys[] | select(endswith(".ts"))'
```

## MCP Server Mode

Run as Model Context Protocol server for AI tool integration:

```bash
repomix --mcp
```

## Best Practices

1. **Start with `--token-count-tree`** to understand codebase size
2. **Use `--compress` for large codebases** to stay within context limits
3. **Use `--include` patterns** to focus on relevant code
4. **Use `--split-output`** when output exceeds AI tool limits
5. **Check security warnings** before sharing packed output
