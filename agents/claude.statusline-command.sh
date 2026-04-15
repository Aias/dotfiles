#!/bin/bash

# Starship-aligned statusLine for Claude Code (see starship/starship.toml).
# Mirrors: directory → Conductor → git_branch → git_state → git_status.
# Claude additions: Linear ticket + gh PR# after state; model name + context% at end.
# Not mirrored: username/hostname (SSH), cmd_duration, jobs, sudo, prompt character.

input=$(cat)

model_name=$(echo "$input" | jq -r '.model.display_name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')

# Colors — ANSI codes for the starship color names used in starship.toml.
BOLD_CYAN='\033[1;36m'    # [directory] default style
BRIGHT_BLACK='\033[90m'   # bright-black
RED='\033[31m'            # red
GREEN='\033[32m'          # green
YELLOW='\033[33m'         # yellow
CYAN='\033[36m'           # cyan
NC='\033[0m'

cd "$current_dir" 2>/dev/null || cd /

# [directory] truncate_to_repo=true, truncation_length=3, truncation_symbol="…/",
# home_symbol="~" (default), read_only=" ", style="bold cyan" (default).
if git rev-parse --git-dir >/dev/null 2>&1; then
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    dir_display="$(basename "$repo_root")${current_dir#$repo_root}"
else
    dir_display="${current_dir/#$HOME/~}"
    count=$(echo "$dir_display" | awk -F/ '{n=NF; if ($1=="") n--; print n}')
    if [ "$count" -gt 3 ]; then
        dir_display="…/$(echo "$dir_display" | awk -F/ '{print $(NF-2)"/"$(NF-1)"/"$NF}')"
    fi
fi
read_only=""
[ ! -w "$current_dir" ] && read_only=" "
dir_out="${BOLD_CYAN}${dir_display}${read_only}${NC}"

# [custom.conductor]
conductor_info=""
if [ -n "${CONDUCTOR_WORKSPACE_NAME:-}" ]; then
    conductor_info=" ${BRIGHT_BLACK}${CONDUCTOR_WORKSPACE_NAME}"
    [ -n "${CONDUCTOR_PORT:-}" ] && conductor_info="${conductor_info} ·${CONDUCTOR_PORT}"
    conductor_info="${conductor_info}${NC}"
fi

git_info=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # [git_branch] bright-black
    branch=$(git branch --show-current 2>/dev/null || echo "detached")
    git_info=" ${BRIGHT_BLACK}${branch}${NC}"

    # [git_state] literal parens, bright-black
    git_top=$(git status 2>/dev/null | head -n1)
    if [ -n "$git_top" ] && [[ ! "$git_top" =~ ^On\ branch ]] && [[ ! "$git_top" =~ ^HEAD\ detached ]]; then
        git_info="${git_info} ${BRIGHT_BLACK}(${git_top})${NC}"
    fi

    # Claude additions: Linear ticket from branch + open PR number
    if [[ "$branch" =~ (rmrk-[0-9]+) ]]; then
        git_info="${git_info} ${BRIGHT_BLACK}${BASH_REMATCH[1]}${NC}"
    fi
    pr_number=$(gh pr view --json number -q '.number' 2>/dev/null)
    [ -n "$pr_number" ] && git_info="${git_info} ${BRIGHT_BLACK}#${pr_number}${NC}"

    # [git_status] $ahead_behind in cyan
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

    # [git_status] counts in starship order: conflicted → staged → modified → untracked.
    # No literal parens (starship's (…) are optional-group markers, not output).
    status_output=$(git status --porcelain 2>/dev/null)
    conflicts=$(git diff --name-only --diff-filter=U 2>/dev/null | wc -l | xargs)
    staged=$(printf '%s\n' "$status_output" | grep -c '^[AMDRC]')
    modified=$(printf '%s\n' "$status_output" | grep -c '^.[MD]')
    untracked=$(printf '%s\n' "$status_output" | grep -c '^??')

    counts=""
    [ "$conflicts" -gt 0 ] && counts="${RED}!${conflicts}${NC}"
    [ "$staged" -gt 0 ] && counts="${counts:+${counts} }${GREEN}+${staged}${NC}"
    [ "$modified" -gt 0 ] && counts="${counts:+${counts} }${YELLOW}~${modified}${NC}"
    [ "$untracked" -gt 0 ] && counts="${counts:+${counts} }${BRIGHT_BLACK}?${untracked}${NC}"
    [ -n "$counts" ] && git_info="${git_info} ${counts}"
fi

# Claude-only: context window usage, colored by threshold.
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
context_info=""
if [ -n "$used" ] && [ "$used" != "empty" ]; then
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

output="${dir_out}${conductor_info}${git_info} ${BRIGHT_BLACK}${model_name}${NC}${context_info}"

printf "%b" "$output"
