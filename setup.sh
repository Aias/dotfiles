#!/bin/bash

# Repo-local setup — run once per clone/worktree.
# Safe to re-run; idempotent.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────────────────────────
# Output helpers
# ─────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN='' BOLD='' RESET=''
fi

section() { printf "\n${BOLD}%s${RESET}\n" "$1"; }
success() { printf "  ${GREEN}✓${RESET} %s\n" "$1"; }

# ─────────────────────────────────────────────────────────────
# Git hooks
# ─────────────────────────────────────────────────────────────

install_git_hooks() {
    local hooks_src="$DOTFILES_DIR/git-hooks"
    local hooks_dst
    hooks_dst="$(git -C "$DOTFILES_DIR" rev-parse --git-dir)/hooks"

    [[ -d "$hooks_src" ]] || return 0
    mkdir -p "$hooks_dst"

    section "Git hooks"
    for hook in "$hooks_src"/*; do
        [[ -f "$hook" ]] || continue
        local name
        name="$(basename "$hook")"
        cp "$hook" "$hooks_dst/$name"
        chmod +x "$hooks_dst/$name"
        success "$name"
    done
}

install_git_hooks
