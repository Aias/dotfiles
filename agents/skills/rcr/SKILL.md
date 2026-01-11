---
name: rcr
description: Use the Red Cliff Record CLI (rcr) to manage the personal knowledge base. Use when the user asks to create, search, or manage records, links, or run integrations syncs. Trigger on mentions of "rcr", "red cliff record", "knowledge base", or record/link operations.
---

# Red Cliff Record CLI

The `rcr` CLI provides direct access to Red Cliff Record, a **highly networked, manually curated personal knowledge base**. This is not a bookmark manager or metadata store—it contains interlinked, rich content that the user has specifically curated over years. Records include highlights, excerpts, notes, and semantic relationships.

## Before You Begin

**ALWAYS run `rcr --help` for the full command reference.** The help text is the authoritative documentation.

## Data Model

- **Records**: Entities (people, orgs), concepts (ideas), and artifacts (articles, books, repos)
- **Links**: Typed relationships between records (e.g., "created by", "contains", "references")
- **Sources**: Integration origins (readwise, github, raindrop, airtable, feedbin, twitter, etc.)
- **Parent/child**: Artifacts often have child records (highlights, excerpts) linked via the `containment` predicate

## Administration

- **Sync**: Pull data from external integrations (`rcr sync <integration>`, `rcr sync daily`)
- **Database**: Backup, restore, reset, seed, and status commands (`rcr db <command>`)

## Output Format

```bash
# Success (stdout)
{"data":<result>,"meta":{"count":N,"duration":M}}

# Error (stderr, exit 1)
{"error":{"code":"ERROR_CODE","message":"..."}}

# Use --raw for unwrapped output
rcr records list --source=readwise --raw | jq '.[].id'
```
