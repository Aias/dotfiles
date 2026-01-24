#!/bin/bash
# Skills manager helper - manages .agents/skills.json metadata

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
METADATA_FILE="$DOTFILES_DIR/.agents/skills.json"
SKILLS_DIR="$DOTFILES_DIR/.agents/skills"

# Initialize metadata file if it doesn't exist
init_metadata() {
    if [[ ! -f "$METADATA_FILE" ]]; then
        mkdir -p "$(dirname "$METADATA_FILE")"
        echo '{"skills":{}}' > "$METADATA_FILE"
    fi
}

# Add or update skill metadata
# Usage: add_skill_metadata <skill-name> <source> [commit-hash]
add_skill_metadata() {
    local skill_name="$1"
    local source="$2"
    local commit_hash="${3:-unknown}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    init_metadata

    # Use jq to update the JSON
    jq --arg name "$skill_name" \
       --arg src "$source" \
       --arg hash "$commit_hash" \
       --arg time "$timestamp" \
       '.skills[$name] = {
           source: $src,
           commitHash: $hash,
           installedAt: $time,
           lastChecked: $time
       }' "$METADATA_FILE" > "${METADATA_FILE}.tmp"

    mv "${METADATA_FILE}.tmp" "$METADATA_FILE"
}

# Get skill metadata
# Usage: get_skill_metadata <skill-name>
get_skill_metadata() {
    local skill_name="$1"
    init_metadata
    jq -r ".skills[\"$skill_name\"]" "$METADATA_FILE"
}

# List all tracked skills
list_skills() {
    init_metadata
    jq -r '.skills | keys[]' "$METADATA_FILE"
}

# Main command dispatcher
case "${1:-help}" in
    add)
        add_skill_metadata "$2" "$3" "$4"
        echo "Added metadata for skill: $2"
        ;;
    get)
        get_skill_metadata "$2"
        ;;
    list)
        list_skills
        ;;
    help|*)
        cat <<EOF
Usage: manage-skills.sh <command> [args]

Commands:
  add <skill> <source> [hash]  Add/update skill metadata
  get <skill>                  Get skill metadata as JSON
  list                         List all tracked skills
  help                         Show this help

Examples:
  manage-skills.sh add vercel-react-best-practices vercel-labs/agent-skills abc123
  manage-skills.sh list
EOF
        ;;
esac
