# ~/.zshrc - Interactive shell configuration
# Runs for every new interactive shell

# ─────────────────────────────────────────────────────────────
# Source .zprofile for non-login interactive shells
# ─────────────────────────────────────────────────────────────
if [[ -o interactive && ! -o login ]]; then
  [[ -r "$HOME/.zprofile" ]] && source "$HOME/.zprofile"
fi

# ─────────────────────────────────────────────────────────────
# History configuration
# ─────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # Share history across sessions (implies INC_APPEND_HISTORY)
setopt HIST_IGNORE_ALL_DUPS   # Remove duplicate entries
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks
setopt HIST_IGNORE_SPACE      # Don't save commands starting with space
setopt EXTENDED_HISTORY        # Save timestamps in history
setopt HIST_VERIFY            # Show expanded history before running (!, !!, etc.)

# ─────────────────────────────────────────────────────────────
# Shell options
# ─────────────────────────────────────────────────────────────
setopt AUTO_CD                # cd into directories by typing name
setopt GLOB_DOTS              # Include dotfiles in globbing
setopt AUTO_PUSHD             # cd pushes onto directory stack (popd / ~1 to jump back)
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT           # Don't print stack on each cd
setopt NO_BEEP                # Disable terminal beep
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive shell

# ─────────────────────────────────────────────────────────────
# Completion system (cached - only rebuilds once per day)
# ─────────────────────────────────────────────────────────────
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # Case-insensitive
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.cache/zsh"
[[ -d "$HOME/.cache/zsh" ]] || mkdir -p "$HOME/.cache/zsh"

# fzf (fuzzy finder) — Ctrl-T files, Ctrl-R history, Alt-C dirs
if [[ -x /opt/homebrew/bin/brew ]]; then
  _fzf_base="$(/opt/homebrew/bin/brew --prefix fzf 2>/dev/null)/shell"
  [[ -r "$_fzf_base/completion.zsh" ]] && source "$_fzf_base/completion.zsh"
  [[ -r "$_fzf_base/key-bindings.zsh" ]] && source "$_fzf_base/key-bindings.zsh"
  unset _fzf_base
fi

# Bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# ─────────────────────────────────────────────────────────────
# mise (dev tool version manager)
# ─────────────────────────────────────────────────────────────
# Shim PATH lives in .zshenv so all zsh shells resolve tool versions.
eval "$(mise activate zsh)"

# ─────────────────────────────────────────────────────────────
# Aliases - Navigation & Files
# ─────────────────────────────────────────────────────────────
alias ls="eza"
alias ll="eza -lah --git"
alias la="eza -a"
alias tree="eza --tree"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias mkdir="mkdir -pv"
alias grep="grep --color=auto"
alias o="cursor ."
alias odot="cd ~/Code/dotfiles && cursor ."
alias ohome="cd ~ && cursor ."
alias ocode="cd ~/Code && cursor ."
alias ocorn="cd ~/Code/acorn && cursor ."
alias onuts="cd ~/Code/chestnut && cursor ."
alias ored="cd ~/Code/red-cliff-record && cursor ."

# ─────────────────────────────────────────────────────────────
# Aliases - Tools & Utilities
# ─────────────────────────────────────────────────────────────
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias resource="source ~/.zshrc && source ~/.secrets"
alias c="claude"
alias yolo="claude --dangerously-skip-permissions"
alias ca="cursor-agent --approve-mcps --force"
alias code="cursor"
alias dotup="make -C ~/Code/dotfiles update"
alias dotcheck="make -C ~/Code/dotfiles check"
alias dotlink="make -C ~/Code/dotfiles link && resource"
function up() {
  local dim=$'\e[2m' bold=$'\e[1m' reset=$'\e[0m' blue=$'\e[34m'
  local all=false
  [[ "$1" == "--all" ]] && all=true
  local total=$($all && echo 7 || echo 6) step=0
  _up_step() { step=$((step + 1)); echo "\n${blue}${bold}[${step}/${total}]${reset} ${bold}$1${reset}\n${dim}─────────────────────────────────────${reset}"; }

  _up_step "brew update"
  brew update

  _up_step "brew upgrade"
  brew upgrade

  _up_step "npm update -g"
  npm update -g

  if $all; then
    _up_step "npm update -g (other node versions)"
    for dir in ~/.local/share/mise/installs/node/*/; do
      [[ "$(basename "$dir")" == "$(node -v | sed 's/^v//')"* ]] && continue
      echo "${dim}node $(basename "$dir")${reset}"
      "$dir/bin/npm" update -g
    done
  fi

  _up_step "claude update"
  claude update

  _up_step "bun upgrade"
  bun upgrade

  _up_step "mise upgrade"
  mise upgrade

  unfunction _up_step
}
alias mini="ssh nicktrombley@mac-mini"
alias timeout="gtimeout"

# Git repo root (monorepos / worktrees)
gr() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
  [[ -n "$root" ]] && builtin cd "$root"
}

# ─────────────────────────────────────────────────────────────
# Zoxide (smart cd) - install with: brew install zoxide
# ─────────────────────────────────────────────────────────────
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  alias cd="zd"
  zd() {
    if [ $# -eq 0 ]; then
      builtin cd ~ && return
    fi
    # Path-shaped args (absolute, dotted, tilde, or containing /) always go through
    # builtin cd. Falling back to zoxide here would silently jump to a frecency
    # match in a different worktree when the literal path doesn't resolve.
    case "$1" in
      /*|./*|../*|~*|*/*)
        builtin cd "$@"
        return
        ;;
    esac
    if [ -d "$1" ]; then
      builtin cd "$1"
    else
      z "$@" && printf "📁 " && pwd || echo "Error: Directory not found"
    fi
  }
fi

# ─────────────────────────────────────────────────────────────
# Syntax highlighting & Autosuggestions
# Install with: brew install zsh-syntax-highlighting zsh-autosuggestions
# ─────────────────────────────────────────────────────────────
if [[ -x /opt/homebrew/bin/brew ]]; then
  # Autosuggestions (load before syntax highlighting)
  [[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

  # Syntax highlighting (must be last)
  [[ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ─────────────────────────────────────────────────────────────
# Starship prompt (keep at the end)
# ─────────────────────────────────────────────────────────────
eval "$(starship init zsh)"

# ─────────────────────────────────────────────────────────────
# Force mise shims to the front of PATH (last-word override)
# ─────────────────────────────────────────────────────────────
# Conductor.app prepends its bundled bin dir to PATH when spawning terminals,
# which shadows mise-managed Node. Re-prepending here (after every other PATH
# mutation in this rc) guarantees mise resolves first in interactive shells.
if [[ -d "$HOME/.local/share/mise/shims" ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi