---
name: rcr
description: Use the Red Cliff Record CLI (rcr) to manage the personal knowledge base. Use when the user asks to create, search, or manage records, links, or run integrations syncs. Trigger on mentions of "rcr", "red cliff record", "knowledge base", or record/link operations.
---

# Red Cliff Record CLI

The `rcr` CLI provides direct access to Red Cliff Record, a highly networked, manually curated knowledge base.

## Source Of Truth

- Always run `rcr --help` before non-trivial usage.
- Trust live CLI help and errors over this document if they diverge.
- The command surface is implemented in `src/server/cli/rcr/`.

## Safety Defaults

- Prefer read commands first (`list`, `get`, `search`) before mutations.
- Ask for confirmation before destructive operations:
  - `rcr records delete ...`
  - `rcr records merge ...`
  - `rcr links delete ...`
  - `rcr db restore ...`
  - `rcr db reset ...`
  - `rcr db clone-prod-to-dev ...`
- Use `--dry-run` for destructive-capable `db` operations when available.
- Add `--limit` to `list`/`search` commands unless the user explicitly wants broad output.

## Global Behavior

- Default output: JSON wrapper

```json
{"data":<result>,"meta":{"count":N,"duration":M}}
```

- Error output (stderr, exit code 1):

```json
{"error":{"code":"ERROR_CODE","message":"..."}}
```

- `--raw` outputs just `data` without `{data,meta}` wrapper.
- `--format=table` prints human-readable tables.
- Global options:
  - `--format=json|table`
  - `--raw`
  - `--limit=N`
  - `--offset=N`
  - `--dev` (uses development DB connection)
  - `--debug`
  - `--help`, `-h`
  - `--version`, `-v`
- Practical note: `--limit` and `--offset` are most useful on list/search commands. Some strict subcommands reject them.
- Boolean flags support all forms:
  - `--flag`
  - `--flag=true`
  - `--flag=false`
- Command alias: `record` is accepted as `records`.

## Data Model

- Records: entities, concepts, artifacts
- Links: typed edges between records
- Media: files/URLs attached to records (image, video, text, etc.)
- Sources: integration provenance on records

## Command Reference

### `records`

- `rcr records get <id...> [--links]`
  - Single ID returns one record or NOT_FOUND error
  - Multi-ID returns array; missing records return `{ id, error: "NOT_FOUND" }`
- `rcr records list [filters]`
  - Filters:
    - `--type=entity,concept,artifact`
    - `--source=<comma-separated integration types>`
      - `ai_chat, airtable, browser_history, crawler, embeddings, feedbin, github, lightroom, manual, raindrop, readwise, twitter`
    - `--has-title[=BOOL]`
    - `--curated[=BOOL]`
    - `--private[=BOOL]`
    - `--parent[=BOOL]`
    - `--media[=BOOL]`
    - `--embedding[=BOOL]`
    - `--rating-min=N` and `--rating-max=N` (0-3)
    - `--order=field:dir,...`
      - Fields: `recordUpdatedAt, recordCreatedAt, title, contentCreatedAt, contentUpdatedAt, rating, id`
      - Direction: `asc|desc`
    - `--full` to fetch complete records instead of ID-only rows
- `rcr records create '<json>'`
- `rcr records update <id> '<json>'`
- `rcr records bulk-update <id,id,...> '<json>'`
- `rcr records delete <id...>`
- `rcr records merge <sourceId> <targetId>`
- `rcr records embed <id...>`
- `rcr records tree <id...>`
- `rcr records children <id>`
- `rcr records parent <id>`

### `media`

- `rcr media get <id...> [--with-record]`
- `rcr media list [filters]`
  - `--type=application|audio|font|image|message|model|multipart|text|video`
  - `--alt-text[=BOOL]`
  - `--record=<recordId>`
  - `--order=recordCreatedAt|recordUpdatedAt|id`
  - `--direction=asc|desc`
- `rcr media create --record <id> --file <path> [--name <filename>] [--type <mime>]`
- `rcr media create --record <id> --url <url>`
  - Exactly one of `--file` or `--url` is required
- `rcr media update <id> '{"altText":"..."}'`
- `rcr media generate-alt <id...> [--force]`

### `search`

- Hybrid (default): `rcr search <query> [--limit=N]`
- Text: `rcr search text <query> [--type=entity|concept|artifact] [--limit=N]`
- Semantic: `rcr search semantic <query> [--limit=N] [--exclude=id,id,...]`
- Similar by record: `rcr search similar <id...> [--limit=N]`

### `links`

- `rcr links list <recordId> [--predicate=<slug>] [--direction=incoming|outgoing]`
- `rcr links create '<json>'`
  - JSON shape: `{ sourceId, targetId, predicateId, notes? }`
- `rcr links delete <id...>`
- `rcr links predicates`

### `browsing`

- `rcr browsing daily <YYYY-MM-DD>`
- `rcr browsing omit`
- `rcr browsing omit-add <pattern>` (SQL `LIKE` syntax, `%` wildcard)
- `rcr browsing omit-delete <pattern...>`

### `github`

- `rcr github daily <YYYY-MM-DD>`
- `rcr github get <commitId>`

### `sync`

- `rcr sync`
  - Runs daily sync set, then enrichments:
    - Daily integrations: `browsing, raindrop, readwise, github, airtable, twitter`
    - Then: avatars, alt-text, embeddings enrichments
- `rcr sync <integration>`
  - Valid integrations:
    - `github, readwise, raindrop, airtable, adobe, feedbin, browsing, twitter, agents`
  - Single integration run is still followed by enrichments.

### `enrich`

- `rcr enrich`
  - Runs all: `avatars -> alt-text -> embeddings`
- `rcr enrich avatars`
- `rcr enrich alt-text [--limit=N]`
- `rcr enrich embeddings`
- `--limit` is only valid with `rcr enrich alt-text`.

### `db`

- `rcr db backup <prod|dev> [--data-only] [--dry-run|-n]`
- `rcr db restore <prod|dev> [--clean] [--data-only] [--file <path>|--file=<path>|-f <path>|-f=<path>] [--dry-run|-n] [--yes|-y]`
  - If `--file/-f` is omitted, restore auto-selects the newest matching backup for the target environment:
    - Data-only restore: `<target>-data-*.dump`
    - Full restore: `<target>-*.dump` excluding `<target>-data-*.dump`
  - `--dry-run` uses a placeholder dump path when no matching file exists.
- `rcr db reset [dev]` (dev only)
- `rcr db seed [dev]` (dev only)
- `rcr db status`
  - Connection determined by `--dev` flag / `NODE_ENV`. Use `--dev` for dev, omit for prod.
- `rcr db clone-prod-to-dev [--dry-run|-n] [--yes|-y]`

### `fetch`

- `rcr fetch url <url> [--content-only]`
- Uses Jina Reader (`https://r.jina.ai/`) to return parsed markdown.

## Practical Examples

```bash
# Get one record with links
rcr records get 123 --links

# Find uncurated entities/concepts
rcr records list --type=entity,concept --curated=false --limit=25

# Bulk curate
rcr records bulk-update 101,202,303 '{"isCurated":true}'

# Find media missing alt text
rcr media list --type=image --alt-text=false --limit=50

# Generate alt text for specific media items
rcr media generate-alt 123 456 789 --force

# Hybrid search (default search mode)
rcr search "recursive prompting patterns" --limit=10

# Semantic search excluding known IDs
rcr search semantic "knowledge graphs" --exclude=12,34 --limit=15

# Add an omit pattern to browsing summaries
rcr browsing omit-add "%localhost%"

# Run one integration sync + automatic enrichments
rcr sync github --debug

# Run only alt-text enrichment with a smaller batch
rcr enrich alt-text --limit=20

# Preview a prod->dev clone without changes
rcr db clone-prod-to-dev --dry-run

# Emit raw output for downstream tooling
rcr records list --source=readwise --raw | jq '.[].id'

# Fetch clean markdown from a URL
rcr fetch url https://example.com/article --content-only --raw
```
