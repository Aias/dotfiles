#!/bin/bash

# Starship-inspired statusLine for Claude Code
# Based on ~/.config/starship.toml configuration

# Read JSON input from stdin
input=$(cat)

# Extract information from JSON
model_name=$(echo "$input" | jq -r '.model.display_name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')

# Colors (bright-black = dim gray, matches Starship style)
BRIGHT_BLACK='\033[90m'
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
CYAN='\033[96m'
NC='\033[0m'

# Change to the current directory
cd "$current_dir" 2>/dev/null || cd /

# Directory (truncate to 3 segments like Starship)
dir_display="$current_dir"
if git rev-parse --git-dir >/dev/null 2>&1; then
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$repo_root" ]; then
        dir_display="${current_dir#$repo_root}"
        [ -z "$dir_display" ] && dir_display="$(basename "$repo_root")" || dir_display="$(basename "$repo_root")$dir_display"
    fi
else
    # Truncate to last 3 segments if not in repo
    dir_display=$(echo "$current_dir" | awk -F/ '{print $(NF-2)"/"$(NF-1)"/"$(NF)}' | sed 's|^/||')
    [ "$dir_display" = "//" ] && dir_display=$(basename "$current_dir")
fi

# Git branch and status
git_info=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || echo "detached")
    git_info=" ${BRIGHT_BLACK}${branch}${NC}"

    # Extract Linear ticket from branch name (e.g., rmrk-1234)
    if [[ "$branch" =~ (rmrk-[0-9]+) ]]; then
        ticket="${BASH_REMATCH[1]}"
        git_info="${git_info} ${BRIGHT_BLACK}${ticket}${NC}"
    fi

    # Check for open PR (skip CI status)
    pr_number=$(gh pr view --json number -q '.number' 2>/dev/null)
    if [ -n "$pr_number" ]; then
        git_info="${git_info} ${BRIGHT_BLACK}#${pr_number}${NC}"
    fi

    # Git dirty indicator
    is_dirty=false
    if ! git diff-index --quiet HEAD -- 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
        is_dirty=true
        git_info="${git_info} ${BRIGHT_BLACK}*${NC}"
    fi

    # Ahead/behind origin
    ahead_behind=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
    if [ -n "$ahead_behind" ]; then
        ahead=$(echo "$ahead_behind" | awk '{print $1}')
        behind=$(echo "$ahead_behind" | awk '{print $2}')

        if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
            git_info="${git_info} ${CYAN}↑${ahead} ↓${behind}${NC}"
        elif [ "$ahead" -gt 0 ]; then
            git_info="${git_info} ${CYAN}↑${ahead}${NC}"
        elif [ "$behind" -gt 0 ]; then
            git_info="${git_info} ${CYAN}↓${behind}${NC}"
        fi
    fi

    # Uncommitted file counts (staged, modified, untracked)
    if [ "$is_dirty" = true ]; then
        status_output=$(git status --porcelain 2>/dev/null)
        staged=$(echo "$status_output" | grep -c '^[AMDRC]' 2>/dev/null || echo "0")
        modified=$(echo "$status_output" | grep -c '^.[MD]' 2>/dev/null || echo "0")
        untracked=$(echo "$status_output" | grep -c '^??' 2>/dev/null || echo "0")

        file_counts=""
        [ "$staged" -gt 0 ] && file_counts="${GREEN}+${staged}${NC}"
        [ "$modified" -gt 0 ] && file_counts="${file_counts:+${file_counts} }${YELLOW}~${modified}${NC}"
        [ "$untracked" -gt 0 ] && file_counts="${file_counts:+${file_counts} }${BRIGHT_BLACK}?${untracked}${NC}"

        [ -n "$file_counts" ] && git_info="${git_info} ${file_counts}"
    fi

    # Merge conflicts
    conflicts=$(git diff --name-only --diff-filter=U 2>/dev/null | wc -l | xargs)
    if [ "$conflicts" -gt 0 ]; then
        git_info="${git_info} ${RED}!${conflicts}${NC}"
    fi
fi

# Context window usage (count UP to 100%)
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
context_info=""
if [ -n "$used" ] && [ "$used" != "empty" ]; then
    # Color code based on used percentage
    used_int=${used%.*}
    if [ "$used_int" -gt 80 ]; then
        context_color="$RED"
    elif [ "$used_int" -gt 50 ]; then
        context_color="$YELLOW"
    else
        context_color="$BRIGHT_BLACK"
    fi
    context_info=" ${context_color}${used}%${NC}"
fi

# Build output
# Order: dir branch ticket pr dirty ahead/behind files conflicts model context tools
output="${dir_display}${git_info}"

# Add model name in dimmed style
output="${output} ${BRIGHT_BLACK}${model_name}${NC}"

# Add context info if available
output="${output}${context_info}"

# Output without trailing newline
printf "%b" "$output"