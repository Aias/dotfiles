# Agent skills

Skill sources live in three directories:

- `agents/skills/`: personal skills, tracked in this repository.
- `.agents/skills/`: external skills tracked by `skills-lock.json`.
- `agents/skills.local/`: private skills in an optional submodule with its own history.

Use `make setup-private-skills` to initialize the pinned private revision and `make update-private-skills` to fast-forward it to its remote main branch. Commit and push private changes in that repository before recording its updated commit reference in dotfiles. See [private skills](../../README.md#private-skills).

Edit these sources. `make compile` generates deployment files and `make link` installs them. Installed skills and generated files are build outputs.

## Descriptions and references

Each skill has a `SKILL.md` with a YAML `name` and `description`. Describe the specific task the skill serves and the boundary that prevents likely misrouting. Keep procedures and secondary capabilities in the body.

Keep the entry point focused on the outcome, essential constraints, and relevant references. Put substantial conditional workflows in `references/`, executable helpers in `scripts/`, and output assets in `assets/`.

Use backticked skill names such as `/write` for cross-links. State the condition where the other skill is useful. Reuse guidance already loaded in the session. A cross-link alone does not require another read.

## Harness inclusion

Shared content applies to Claude, Codex, and Cursor. These names identify deployment destinations, not the model selected inside each application.

To restrict a whole skill, set a comma-separated target list in its source frontmatter:

```yaml
---
name: example-workflow
description: Perform the named workflow using its application-specific tools.
metadata:
  targets: claude,cursor
---
```

Omit `metadata.targets` for a shared skill. This controls dotfiles deployment. A harness may separately discover source skills when opened inside this repository, including `.agents/skills/`. Review local target metadata when updating external skills so an upstream replacement does not erase the intended deployment policy.

To restrict a section in GLOBAL.md or a skill's Markdown files:

```markdown
Shared guidance.

<!-- harness: codex -->
Guidance for Codex.
<!-- /harness -->

<!-- harness: claude,cursor -->
Guidance for Claude and Cursor.
<!-- /harness -->
```

Blocks cannot nest. The compiler rejects empty or unknown target lists and malformed or unclosed blocks. Keep a target-specific reference and its link under matching conditions.

## Generated instructions

`agents/GLOBAL.md` remains the source of standing instructions. The compiler writes:

| Output | Destination |
| --- | --- |
| `agents/.build/claude/GLOBAL.md` | `~/.claude/CLAUDE.md` symlink |
| `agents/.build/codex/GLOBAL.md` | `~/.codex/AGENTS.md` symlink |
| `agents/.build/cursor/GLOBAL.md` | Content of `~/.cursor/rules/global.mdc` |
| `agents/.build/shared/GLOBAL.md` | `~/AGENTS.md` symlink |
| `agents/.build/<target>/skills/` | `~/.<target>/skills/` |

The shared ancestor file contains only guidance common to every target. This prevents a harness from finding another harness's instructions through `~/AGENTS.md`.

## Compiled annotations

A skill with `global_category` contributes `<!-- @> summary -->` annotations to GLOBAL.md's compiled index:

```markdown
<!-- @> Preserve the operation's authorization boundary when retrying -->
Retry within the approved scope. Ask when a retry requires a different external action.
```

Use annotations for constraints worth carrying into every relevant session. Keep rare cases in the skill body. The compiler strips markers and calculates line references against each target's generated files. Shared ancestor summaries omit line pointers because the target files can have different line offsets. The tracked source index includes public skill summaries. Private local skills can contribute to generated target instructions without placing their summaries in tracked GLOBAL.md.

## Feedback review

`skill.feedback.md` is a local staging file for preferences that need review. It is excluded from deployment and ordinary skill reads. Public skill queues are gitignored; private skill queues can be versioned in the private submodule. The compiler adds no feedback-reading preamble.

Use `/refine-skills` during requested maintenance to compare notes with current guidance and promote supported preferences. Approved instructions belong in the source skill or GLOBAL.md, where compilation delivers them without another file read. Use `/remember-that` when the user asks to save a standing preference directly.

## Deployment and checks

```bash
make compile
make link
make check
```

Compilation filters skills and sections for each target. The installer mirrors each included skill's generated tree. It removes an excluded deployment only when a current source skill explicitly excludes that target. Unrelated installed skills, system skills, and plugins remain outside this cleanup.

Removing or renaming a source skill requires separate orphan cleanup. Check all three source directories before deleting a deployed folder. See the [skills-manager workflow](skills-manager/SKILL.md).

Use `bun agents/compile-global.ts --check` to verify generated output freshness and `make check` to inspect deployment drift. Source files remain authoritative after compilation and installation.
