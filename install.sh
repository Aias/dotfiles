#!/bin/bash

# Dotfiles installation script
# Creates symlinks from dotfiles repo to home directory

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────────────────────────
# Output helpers
# ─────────────────────────────────────────────────────────────

# Colors (auto-disable if not a terminal)
if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
else
    GREEN='' RED='' YELLOW='' CYAN='' BOLD='' DIM='' RESET=''
fi

section() {
    printf "\n${BOLD}%s${RESET}\n" "$1"
}

success() {
    printf "  ${GREEN}✓${RESET} %s\n" "$1"
}

success_dim() {
    # For "exists" or "no change" cases - dimmed annotation
    printf "  ${GREEN}✓${RESET} %s ${DIM}%s${RESET}\n" "$1" "$2"
}

info() {
    printf "  ${CYAN}→${RESET} %s\n" "$1"
}

warn() {
    printf "  ${YELLOW}!${RESET} %s\n" "$1"
}

error() {
    printf "  ${RED}✗${RESET} %s\n" "$1"
}

# ─────────────────────────────────────────────────────────────
# Ensure required tools are installed (system-wide)
# ─────────────────────────────────────────────────────────────

ensure_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required to install dependencies. Install from https://brew.sh and rerun."
        exit 1
    fi
}

install_bun() {
    if ! command -v bun >/dev/null 2>&1; then
        info "Installing bun..."
        curl -fsSL https://bun.sh/install | bash
    fi
}

install_cursor_agent() {
    if ! command -v cursor-agent >/dev/null 2>&1; then
        info "Installing cursor-agent..."
        curl -fsSL https://cursor.com/install | bash
    fi
}

install_cursor_cli() {
    # Official method: Cursor > Cmd+Shift+P > "Shell Command: Install 'cursor' command in PATH"
    # This creates /usr/local/bin/cursor. As fallback, symlink to ~/.local/bin
    local cursor_bin="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
    if ! command -v cursor >/dev/null 2>&1; then
        if [[ -x "$cursor_bin" ]]; then
            info "Linking cursor CLI to ~/.local/bin/cursor"
            ln -sf "$cursor_bin" "$HOME/.local/bin/cursor"
        else
            warn "Cursor.app not found. Install from https://cursor.com"
        fi
    fi
}

install_dependencies() {
    section "Dependencies"
    ensure_homebrew
    brew bundle install --file="$DOTFILES_DIR/Brewfile" 2>&1 | grep -E "^(Using|Installing|Upgrading)" | sed 's/^/  /'
    install_bun
    install_cursor_agent
    install_cursor_cli
    success "Dependencies installed"
}

if [[ "${SKIP_DEPENDENCY_INSTALL:-0}" != "1" ]]; then
    install_dependencies
fi

# Create backup directory
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
BACKUP_CREATED=false

backup_and_link() {
    local source="$1"
    local target="$2"
    local label="$3"

    if [[ -e "$target" && ! -L "$target" ]]; then
        if [[ "$BACKUP_CREATED" == "false" ]]; then
            mkdir -p "$BACKUP_DIR"
            BACKUP_CREATED=true
        fi
        mv "$target" "$BACKUP_DIR/"
        info "Backed up existing $label"
    fi

    if [[ -L "$target" ]]; then
        rm "$target"
    fi

    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    success "$label"
}

# ─────────────────────────────────────────────────────────────
# Symlinks from links.txt
# ─────────────────────────────────────────────────────────────

install_links() {
    local current_section=""
    while IFS='|' read -r section_name source target label; do
        # Skip comments and empty lines
        [[ "$section_name" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$section_name" ]] && continue

        # Trim whitespace
        section_name="${section_name## }"; section_name="${section_name%% }"
        source="${source## }"; source="${source%% }"
        target="${target## }"; target="${target%% }"
        label="${label## }"; label="${label%% }"

        # Print section header when it changes
        if [[ "$section_name" != "$current_section" ]]; then
            section "$section_name"
            current_section="$section_name"
        fi

        backup_and_link "$DOTFILES_DIR/$source" "$HOME/$target" "$label"
    done < "$DOTFILES_DIR/links.txt"
}

install_links

# ─────────────────────────────────────────────────────────────
# Cursor global rules (copy with frontmatter, not symlink)
# ─────────────────────────────────────────────────────────────

install_cursor_global_rules() {
    local source="$DOTFILES_DIR/agents/GLOBAL.md"
    local target="$HOME/.cursor/rules/global.mdc"
    mkdir -p "$(dirname "$target")"
    {
        echo "---"
        echo "alwaysApply: true"
        echo "---"
        echo ""
        cat "$source"
    } > "$target"
    success_dim ".cursor/rules/global.mdc" "(copied)"
}
install_cursor_global_rules

# ─────────────────────────────────────────────────────────────
# Skills
# ─────────────────────────────────────────────────────────────

section "Skills"

install_skills() {
    local personal_skills="$DOTFILES_DIR/agents/skills"
    local external_skills="$DOTFILES_DIR/.agents/skills"
    local local_skills="$DOTFILES_DIR/agents/skills.local"
    local targets=(
        "$HOME/.claude/skills"
        "$HOME/.codex/skills"
    )

    # Collect skill names from all directories
    local skills=()
    local skill_names=()
    mkdir -p "$local_skills"
    for skill in "$personal_skills"/*/; do
        [[ -d "$skill" ]] && skills+=("personal:$(basename "$skill")") && skill_names+=("$(basename "$skill")")
    done
    for skill in "$external_skills"/*/; do
        [[ -d "$skill" ]] && skills+=("external:$(basename "$skill")") && skill_names+=("$(basename "$skill")")
    done
    for skill in "$local_skills"/*/; do
        [[ -d "$skill" ]] && skills+=("local:$(basename "$skill")") && skill_names+=("$(basename "$skill")")
    done

    for target_dir in "${targets[@]}"; do
        # Remove whole-directory symlink if it exists
        if [[ -L "$target_dir" ]]; then
            rm "$target_dir"
        fi
        mkdir -p "$target_dir"

        for skill_entry in "${skills[@]}"; do
            local skill_type="${skill_entry%%:*}"
            local skill_name="${skill_entry#*:}"
            local skill_source=""

            if [[ "$skill_type" == "personal" ]]; then
                skill_source="$personal_skills/$skill_name/"
            elif [[ "$skill_type" == "external" ]]; then
                skill_source="$external_skills/$skill_name/"
            else
                skill_source="$local_skills/$skill_name/"
            fi

            local skill_target="$target_dir/$skill_name"

            # Remove old symlinks
            if [[ -L "$skill_target" ]]; then
                rm "$skill_target"
            fi

            # Sync skill directory with rsync
            # -a: archive mode (preserves permissions, timestamps, etc.)
            # --delete: remove files in target that don't exist in source
            # Trailing slash on source copies contents into target
            mkdir -p "$skill_target"
            rsync -a --delete "$skill_source" "$skill_target/"
        done

        # Overwrite SKILL.md with cleaned versions (annotations stripped)
        local build_dir="$DOTFILES_DIR/agents/.build/skills"
        if [[ -d "$build_dir" ]]; then
            for cleaned_skill in "$build_dir"/*/SKILL.md; do
                [[ -f "$cleaned_skill" ]] || continue
                local skill_name
                skill_name="$(basename "$(dirname "$cleaned_skill")")"
                local target_skill="$target_dir/$skill_name/SKILL.md"
                if [[ -f "$target_skill" ]]; then
                    cp "$cleaned_skill" "$target_skill"
                fi
            done
        fi
    done

    # Print skill status table with colors
    local check="${GREEN}✓${RESET}"
    {
        printf "skill\ttype\tclaude\tcodex\n"
        for skill_entry in "${skills[@]}"; do
            local skill_type="${skill_entry%%:*}"
            local skill_name="${skill_entry#*:}"
            local type_label="${DIM}[P]${RESET}"
            [[ "$skill_type" == "external" ]] && type_label="${DIM}[E]${RESET}"
            [[ "$skill_type" == "local" ]] && type_label="${DIM}[L]${RESET}"
            printf "%s\t%b\t%b\t%b\n" "$skill_name" "$type_label" "$check" "$check"
        done
    } | column -t -s $'\t' | sed 's/^/  /'
}

install_skills

# ─────────────────────────────────────────────────────────────
# Local files (create from template if missing)
# ─────────────────────────────────────────────────────────────

section "Local"

create_from_template() {
    local target="$1"
    local template="$2"
    local label="$3"

    # Remove broken symlinks
    if [[ -L "$target" ]]; then
        rm "$target"
    fi

    if [[ ! -e "$target" ]]; then
        mkdir -p "$(dirname "$target")"
        if [[ -f "$template" ]]; then
            cat "$template" > "$target"
            success_dim "$label" "(created)"
        else
            warn "$label template not found"
            return 1
        fi
    else
        success_dim "$label" "(exists)"
    fi
}

# Secrets file (sourced by .zprofile for API keys)
create_from_template "$HOME/.secrets" "$DOTFILES_DIR/local/secrets.template" ".secrets"

# Local environment file (sourced by .zprofile)
create_from_template "$HOME/.local/bin/env" "$DOTFILES_DIR/local/env.template" ".local/bin/env"

# Ensure ~/.local/bin directory exists for local scripts
mkdir -p "$HOME/.local/bin"

# Vault (cross-session memory for agents)
if [[ ! -d "$HOME/Code/vault" ]]; then
    info "Creating vault directory at ~/Code/vault"
    mkdir -p "$HOME/Code/vault/sessions"
    cp "$DOTFILES_DIR/agents/vault-template/CLAUDE.md" "$HOME/Code/vault/"
    cp "$DOTFILES_DIR/agents/vault-template/scratch.md" "$HOME/Code/vault/"
    success "~/Code/vault"
else
    success_dim "~/Code/vault" "(exists)"
fi

# ─────────────────────────────────────────────────────────────
# Cleanup old backups (keep last 10)
# ─────────────────────────────────────────────────────────────

cleanup_old_backups() {
    local backup_root="$HOME/.dotfiles-backup"
    local keep=10
    local count=$(ls -1d "$backup_root"/*/ 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" -gt "$keep" ]]; then
        local to_delete=$((count - keep))
        ls -1d "$backup_root"/*/ | head -n "$to_delete" | xargs rm -rf
    fi
}

cleanup_old_backups

# ─────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────

echo ""
if [[ "$BACKUP_CREATED" == "true" ]]; then
    printf "${GREEN}✓ Done!${RESET} ${DIM}Backups saved to: $BACKUP_DIR${RESET}\n"
else
    printf "${GREEN}✓ Done!${RESET}\n"
fi
