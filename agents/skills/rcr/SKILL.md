---
name: rcr
description: Use the Red Cliff Record CLI (rcr) to manage the personal knowledge base. Use when the user asks to create, search, or manage records, links, or run integrations syncs. Trigger on mentions of "rcr", "red cliff record", "knowledge base", or record/link operations.
---

# Red Cliff Record CLI

The `rcr` CLI provides direct access to Red Cliff Record, a **highly networked, manually curated personal knowledge base**. This is not a bookmark manager or metadata store—it contains interlinked, rich content that the user has specifically curated over years. Records include highlights, excerpts, notes, and semantic relationships. Content in this database can be reliably assumed to be important or valuable to the user.

The CLI outputs compact JSON by default for easy parsing and piping. Use `| jq` for formatted output when needed.

**Important**: When answering follow-up questions about records or search results, default to using further `rcr` commands (e.g., `rcr links list`, `rcr search similar`, `rcr records get`) rather than external web searches. The curated content in this database is often more valuable than re-fetching raw sources. Only look outside the database when the user explicitly asks for external information or the query clearly requires it.

## Exploration Pattern

When researching a topic, follow this sequence to extract full value from the database before going external:

1. **Search** → Get initial results with summaries
2. **Get record trees** → Use `rcr records tree <id>` to find child records (highlights, excerpts, notes)
3. **Read child content** → Use `rcr records get <child-ids>` to read the actual captured knowledge
4. **Check links** → Use `rcr records get <id> --links` to find related records worth exploring
5. **Only then fetch source URLs** → If the database content is insufficient, use `WebFetch` on the record's `url` field

Child records (often with `title: null`) typically contain highlights and excerpts from the parent source. These are the curated insights—often more valuable than re-reading the full source.

```bash
# Example exploration workflow
rcr search "topic"                           # Find relevant records
rcr records tree 12345                       # See record hierarchy
rcr records get 12345 --links | jq '.data.incomingLinks'  # Find children
rcr records get 67890 67891 | jq '.data[].content'        # Read child content
```

## Output Format

All commands return compact JSON:

```bash
# Success
{"success":true,"data":<result>,"meta":{"count":N,"duration":M}}

# Error
{"success":false,"error":{"code":"ERROR_CODE","message":"..."}}

# Extract data with jq
rcr records get 123 | jq '.data.title'
rcr search "query" | jq '.data[].title'
```

## Records

### Get record(s)
```bash
rcr records get <id>
rcr records get <id1> <id2> <id3>   # Multiple IDs (parallel)
rcr records get <id> --links        # Include all incoming/outgoing links
```

### List records with filters
```bash
rcr records list [options]

# Options:
#   --type=entity|concept|artifact   Filter by record type
#   --source=github|readwise|...     Filter by integration source
#   --title=<string>                 Filter by title (fuzzy match)
#   --text=<string>                  Filter by text content
#   --url=<string>                   Filter by URL
#   --curated                        Only curated records
#   --private                        Only private records
#   --rating-min=N                   Minimum rating (0-3)
#   --rating-max=N                   Maximum rating (0-3)
#   --embedding                      Only records with embeddings
#   --media                          Only records with media
#   --parent                         Only records with a parent
#   --limit=N                        Limit results (default: 50)
#   --offset=N                       Pagination offset
```

### Create a record
```bash
rcr records create '{"title": "...", "type": "entity", ...}'

# Or via stdin:
echo '{"title": "...", "type": "entity"}' | rcr records create
```

Required: `title`. Optional: `type` (entity|concept|artifact, defaults to artifact)

### Update a record
```bash
rcr records update <id> '{"title": "New Title", ...}'
```

### Delete records
```bash
rcr records delete <id>
rcr records delete <id1> <id2> <id3>   # Multiple IDs
```

### Merge records
```bash
rcr records merge <source-id> <target-id>
```
Merges source record into target, transferring links and metadata.

### Generate embedding(s)
```bash
rcr records embed <id>
rcr records embed <id1> <id2> <id3>   # Multiple IDs (parallel)
```
Creates or updates the vector embedding for semantic search.

### Get record tree(s)
```bash
rcr records tree <id>
rcr records tree <id1> <id2> <id3>   # Multiple IDs (parallel)
```
Returns hierarchical family tree (ancestors and descendants).

## Search

### Semantic search (default)
```bash
rcr search "your query"
rcr search semantic "your query"

# Options:
#   --limit=N                        Limit results (default: 20)
#   --exclude=id1,id2                Exclude specific record IDs
```

### Full-text search
```bash
rcr search text "your query"

# Options:
#   --type=entity|concept|artifact   Filter by record type
#   --limit=N                        Limit results (default: 20)
```

### Find similar records
```bash
rcr search similar <id>
rcr search similar <id1> <id2> <id3>   # Multiple IDs (parallel)

# Options:
#   --limit=N                        Limit results (default: 20)
```

## Links

### List links for record(s)
```bash
rcr links list <record-id>
rcr links list <id1> <id2> <id3>   # Multiple IDs (uses efficient batch query)
```

### Create a link
```bash
rcr links create '{"sourceId": 1, "targetId": 2, "predicateId": 3}'

# Optional: "notes" field for additional context
```

### Delete links
```bash
rcr links delete <id>
rcr links delete <id1> <id2>   # Multiple IDs
```

### List predicate types
```bash
rcr links predicates
```
Returns available relationship types for linking records.

## Sync Integrations

### Run a single sync
```bash
rcr sync <integration>

# Available integrations:
#   github      - GitHub starred repos and activity
#   readwise    - Readwise highlights and books
#   raindrop    - Raindrop.io bookmarks
#   airtable    - Airtable records
#   adobe       - Adobe Lightroom photos
#   feedbin     - Feedbin RSS starred articles
#   browsing    - Browser history (Arc, Dia)
#   twitter     - Twitter/X bookmarks and likes
#   agents      - Claude/Cursor/Codex conversation history
```

### Run all daily syncs
```bash
rcr sync daily
```
Runs: browsing, feedbin, raindrop, readwise, github, airtable

## Global Options

```bash
--format=json|table   # Output format (default: json)
--debug               # Enable debug output
--help, -h            # Show help
```

## Examples

```bash
# Find records about machine learning
rcr search "machine learning"

# List all curated entities
rcr records list --type=entity --curated --limit=20

# Get a specific record with all its links
rcr records get 123 --links

# Get multiple records in parallel
rcr records get 123 456 789

# Create a new concept
rcr records create '{"title": "Reinforcement Learning", "type": "concept", "notes": "A type of ML..."}'

# Find records similar to an existing one
rcr search similar 456 --limit=10

# Sync GitHub stars
rcr sync github
```
