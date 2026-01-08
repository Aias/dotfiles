---
name: skill-creator
description: Create or update Agent Skills that extend agent capabilities with specialized knowledge and workflows. Use when a user wants to create a new skill, update an existing skill, or learn about skill best practices. Skills are modular packages following the agentskills.io open standard.
---

# Skill Creator

Create effective skills following the Agent Skills open standard. Skills are modular packages that give agents specialized knowledge, workflows, and tools for specific domains or tasks.

## Core Concepts

### What Skills Provide

1. **Specialized workflows** — Multi-step procedures for specific domains
2. **Tool integrations** — Instructions for working with specific file formats or APIs
3. **Domain expertise** — Company-specific knowledge, schemas, business logic
4. **Bundled resources** — Scripts, references, and assets for complex tasks

### Progressive Disclosure

Skills use three-level loading to manage context efficiently:

1. **Metadata** (~100 tokens) — `name` + `description` loaded at startup for all skills
2. **SKILL.md body** (<5k words) — Full instructions loaded when skill activates
3. **Resources** (as needed) — Scripts/references/assets loaded only when required

This means the `description` field is critical for triggering—include WHEN to use the skill, not just what it does.

## Skill Structure

```
skill-name/
├── SKILL.md          # Required: frontmatter + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation to load as needed
└── assets/           # Optional: templates, files for output
```

### SKILL.md Format

```yaml
---
name: skill-name # Required: lowercase, hyphens, max 64 chars
description: What the skill does and when to use it. Include trigger scenarios.
compatibility: Requires git, jq, network access # Optional: environment requirements
---
# Skill Title

Instructions in markdown...
```

### Resource Directories

**scripts/** — Executable code (Python/Bash) for deterministic, repeatable operations

- Example: `rotate_pdf.py`, `extract_data.sh`
- Run directly without loading into context

**references/** — Documentation loaded into context when needed

- Example: `api_docs.md`, `schema.md`, `workflows.md`
- Keep large docs here instead of bloating SKILL.md

**assets/** — Files used in output, not loaded into context

- Example: `template.pptx`, `boilerplate/`, `logo.png`
- Copied or modified in final output

## Creation Workflow

### Step 1: Understand the Use Cases

Before creating a skill, gather concrete examples:

- "What should this skill do?"
- "What would a user say that should trigger this skill?"
- "Can you give examples of how this would be used?"

A clear understanding of use cases drives good skill design.

### Step 2: Plan Resources

For each use case, identify what would help repeated execution:

- **Same code rewritten repeatedly?** → Script in `scripts/`
- **Reference material needed?** → Doc in `references/`
- **Boilerplate or templates?** → Files in `assets/`

Most skills only need a SKILL.md. Only add resources that provide clear value.

### Step 3: Initialize the Skill

Run the initialization script:

```bash
scripts/init-skill.py <skill-name> [--resources scripts,references,assets]
```

This creates the skill directory with a template SKILL.md. The skill is created in `~/Code/dotfiles/agents/skills/` which is the source directory for all skills.

### Step 4: Implement the Skill

1. **Write the description** — Include what the skill does AND when to use it
2. **Write the instructions** — Clear, imperative, step-by-step guidance
3. **Add resources** — Only what's actually needed
4. **Test scripts** — Run any scripts to verify they work

### Step 5: Deploy

Skills are deployed via the dotfiles install script which copies them to client-specific directories (`~/.claude/skills/`, `~/.cursor/skills/`, `~/.codex/skills/`).

```bash
cd ~/Code/dotfiles && ./install.sh
```

After installation, restart the agent to pick up new skills.

## Writing Guidelines

### Frontmatter

**name**: Lowercase, hyphens only, max 64 chars. Match the directory name.

- Good: `pdf-processing`, `pr-review`, `data-analysis`
- Bad: `PDF-Processing`, `-pdf`, `pdf--processing`

**description**: 1-1024 chars. Include WHAT and WHEN.

- Good: "Extract text from PDFs, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction."
- Bad: "Helps with PDFs."

**compatibility**: Only if specific requirements exist (tools, network, etc.)

### Instructions

- Use imperative/infinitive form ("Run the script", "Create the file")
- Keep SKILL.md under 500 lines—move detailed content to references
- Include concrete examples over verbose explanations
- Reference other files clearly: "See [api_docs.md](references/api_docs.md) for details"

### Portable Script References

Skills must be **agent-agnostic**—never hardcode paths like `~/.claude/skills/` or `~/.cursor/skills/`. Different agents install skills in different locations.

**For simple commands**: Inline the command directly in SKILL.md. This avoids path resolution issues entirely:

```markdown
## Usage

Run this command:
\`\`\`bash
docker exec -i my-container some-command "YOUR ARGS"
\`\`\`
```

**For complex scripts**: Use relative paths and note they're relative to the skill directory:

```markdown
## Usage

Run the script (resolve path relative to this skill's directory):
\`\`\`bash
scripts/my-script.sh "args"
\`\`\`
```

**Combining both**: For maximum compatibility, show the inline command first (works everywhere) and mention the script as an alternative:

```markdown
## Usage

Run directly:
\`\`\`bash
docker exec -i container cmd "YOUR SQL"
\`\`\`

Or use the bundled script (relative to skill directory):
\`\`\`bash
scripts/wrapper.sh "YOUR SQL"
\`\`\`
```

### What NOT to Include

- README.md, CHANGELOG.md, INSTALLATION_GUIDE.md — only SKILL.md matters
- Content in both SKILL.md and references — avoid duplication
- "When to use" sections in the body — that belongs in the description

## Progressive Disclosure Patterns

### Pattern 1: High-level guide with references

Keep SKILL.md lean, link to detailed docs:

```markdown
## Quick Start

Basic usage example here.

## Advanced Features

- **Forms**: See [forms.md](references/forms.md)
- **API reference**: See [api.md](references/api.md)
```

### Pattern 2: Domain-specific organization

For skills with multiple domains, organize by domain:

```
bigquery-skill/
├── SKILL.md (overview + navigation)
└── references/
    ├── finance.md
    ├── sales.md
    └── product.md
```

Load only what's needed for the current task.

### Pattern 3: Framework/variant selection

For skills supporting multiple frameworks:

```
deploy-skill/
├── SKILL.md (workflow + selection guidance)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```

## Specification Reference

For complete format specification, see [references/specification.md](references/specification.md).

For official documentation, visit https://agentskills.io/
