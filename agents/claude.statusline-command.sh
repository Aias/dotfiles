#!/bin/bash

# Read JSON input from Claude Code
input=$(cat)

# Extract values from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')

# Change to the working directory
cd "$cwd" 2>/dev/null || cwd="~"

# Directory (replace home with ~)
dir="${cwd/#$HOME/~}"

# Git information
git_info=""
if git rev-parse --git-dir > /dev/null 2>&1; then
  # Get branch name
  branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

  # Get git status with --no-optional-locks to avoid lock issues
  if [ -n "$branch" ]; then
    git_info=" $branch"

    # Check for changes
    status=$(git --no-optional-locks status --porcelain 2>/dev/null)
    if [ -n "$status" ]; then
      git_info="$git_info*"
    fi
  fi
fi

# Construct the status line
printf "%s%s (%s)" "$dir" "$git_info" "$model_name"
