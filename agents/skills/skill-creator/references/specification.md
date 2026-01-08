# Agent Skills Specification

Reference for the Agent Skills open format. Full documentation at https://agentskills.io/

## Directory Structure

A skill is a directory containing at minimum a `SKILL.md` file:

```
skill-name/
├── SKILL.md          # Required
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
└── assets/           # Optional: templates, resources
```

## SKILL.md Format

### Frontmatter (Required)

```yaml
---
name: skill-name
description: What the skill does and when to use it.
---
```

### Optional Frontmatter Fields

```yaml
---
name: pdf-processing
description: Extract text from PDFs, fill forms, merge documents.
license: Apache-2.0
compatibility: Requires pdfplumber, network access
metadata:
  author: example-org
  version: "1.0"
---
```

## Field Constraints

### name (required)

- 1-64 characters
- Lowercase letters, numbers, hyphens only (`a-z`, `0-9`, `-`)
- Cannot start or end with `-`
- No consecutive hyphens (`--`)
- Must match parent directory name

Valid:

- `pdf-processing`
- `data-analysis`
- `code-review`

Invalid:

- `PDF-Processing` (uppercase)
- `-pdf` (starts with hyphen)
- `pdf--processing` (consecutive hyphens)

### description (required)

- 1-1024 characters
- Should describe WHAT and WHEN
- Include keywords for task matching

Good:

```
Extracts text and tables from PDF files, fills forms, merges PDFs.
Use when working with PDF documents or when the user mentions PDFs,
forms, or document extraction.
```

Poor:

```
Helps with PDFs.
```

### compatibility (optional)

- 1-500 characters
- Only include if specific requirements exist

Examples:

```yaml
compatibility: Requires git, docker, jq, and network access
```

```yaml
compatibility: Designed for Claude Code
```

### license (optional)

Name of license or reference to bundled license file.

### metadata (optional)

Arbitrary key-value pairs for additional properties.

## Body Content

The Markdown body after frontmatter contains instructions. No format restrictions—write what helps agents perform the task.

Recommended sections:

- Step-by-step instructions
- Examples of inputs/outputs
- Common edge cases
- References to bundled resources

## Resource Directories

### scripts/

Executable code (Python, Bash, etc.):

- Self-contained or clearly document dependencies
- Include helpful error messages
- Handle edge cases

### references/

Documentation loaded into context when needed:

- Technical references
- Form templates
- Domain-specific docs
- Keep files focused (<100 lines ideal, include TOC for longer)

### assets/

Static resources not loaded into context:

- Templates (`.pptx`, `.docx`)
- Images (`.png`, `.svg`)
- Data files (`.csv`, `.json`)
- Boilerplate directories

## Progressive Disclosure

Three-level loading for efficient context use:

1. **Metadata** (~100 tokens): `name` + `description` loaded at startup
2. **Instructions** (<5000 tokens recommended): Full SKILL.md when activated
3. **Resources** (as needed): Files loaded only when required

Guidelines:

- Keep SKILL.md under 500 lines
- Move detailed reference material to separate files
- Reference files clearly with relative paths
- Keep references one level deep from SKILL.md

## File References

Use relative paths from skill root:

```markdown
See [the reference guide](references/REFERENCE.md) for details.

Run the extraction script:
scripts/extract.py
```

## Validation

The skills-ref library (https://github.com/agentskills/agentskills/tree/main/skills-ref) validates skills:

```bash
skills-ref validate ./my-skill
```

Checks:

- Frontmatter format and required fields
- Naming conventions
- Directory structure
