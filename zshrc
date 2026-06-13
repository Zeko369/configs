# ============================================
# Cross-platform zsh config
# ============================================

# Detect OS
case "$(uname -s)" in
  Darwin) IS_MACOS=true ;;
  Linux)  IS_LINUX=true ;;
esac

# Detect system theme (light/dark)
if [[ "$IS_MACOS" == true ]]; then
  if [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == "Dark" ]]; then
    export SYSTEM_THEME="dark"
  else
    export SYSTEM_THEME="light"
  fi
else
  # Default to dark on Linux (could be extended to detect GTK/Qt theme)
  export SYSTEM_THEME="dark"
fi

# Configure git delta pager based on theme
if [[ "$SYSTEM_THEME" == "light" ]]; then
  export GIT_PAGER="delta --syntax-theme='GitHub' --light"
else
  export GIT_PAGER="delta --syntax-theme='Dracula'"
fi

# Configs directory
export CONFIGS_DIR="$HOME/repos/configs"
export PATH="$CONFIGS_DIR/bin:$PATH"

# Tool configs
export RIPGREP_CONFIG_PATH="$CONFIGS_DIR/ripgreprc"
source "$CONFIGS_DIR/shell/no-git-repos.sh"

# Fix hostname for starship (macOS hostname command returns weird value)
if [[ "$IS_MACOS" == true ]]; then
  export STARSHIP_HOST=$(scutil --get LocalHostName 2>/dev/null || hostname)
fi

# Keep prompt rendering cheap inside huge monorepos/caches.
export STARSHIP_DEFAULT_CONFIG="${STARSHIP_DEFAULT_CONFIG:-$HOME/.config/starship.toml}"
export STARSHIP_NO_GIT_CONFIG="${STARSHIP_NO_GIT_CONFIG:-$HOME/.cache/starship/no-git.toml}"

_configs_generate_starship_no_git_config() {
  local source="$STARSHIP_DEFAULT_CONFIG"
  local dest="$STARSHIP_NO_GIT_CONFIG"
  local tmp="${dest}.tmp"

  [[ -r "$source" ]] || return 1
  [[ ! -r "$dest" || "$source" -nt "$dest" ]] || return 0

  mkdir -p "${dest:h}"
  awk '
    /\$git_(branch|state|status)\\/ { next }
    /\$git_(branch|state|status)$/ { next }
    { print }
  ' "$source" > "$tmp" && mv "$tmp" "$dest"
}

_configs_update_starship_profile() {
  export STARSHIP_CONFIG="$STARSHIP_DEFAULT_CONFIG"

  if _configs_path_in_no_git_repo "$PWD"; then
    _configs_generate_starship_no_git_config
    export STARSHIP_CONFIG="$STARSHIP_NO_GIT_CONFIG"
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _configs_update_starship_profile
add-zsh-hook precmd _configs_update_starship_profile
_configs_update_starship_profile

# Add deno completions to search path
if [[ ":$FPATH:" != *":$HOME/completions:"* ]]; then export FPATH="$HOME/completions:$FPATH"; fi

# Debug mode
if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zmodload zsh/zprof
fi

# ============================================
# Shell options
# ============================================
setopt AUTO_CD              # Type directory name to cd into it

# ============================================
# History
# ============================================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY

# ============================================
# zsh-defer (lazy loading for slow tools)
# ============================================
source "$CONFIGS_DIR/shell/plugins/zsh-defer.plugin.zsh"

# ============================================
# Completions
# ============================================
# TODO: finish setting up zsh-autocomplete (fish-like real-time completions)
# if [[ "$IS_MACOS" == true ]]; then
#   source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh 2>/dev/null
# elif [[ -f /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]]; then
#   source /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# fi
# bindkey '\t' menu-complete
# bindkey -M menuselect '\t' menu-complete
# bindkey -M menuselect '\r' .accept-line

# Restore standard compinit while zsh-autocomplete is disabled
zsh-defer -c '
  autoload -Uz compinit
  if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
  else
    compinit -C
  fi
  zstyle ":completion:*" matcher-list "m:{a-z}={A-Z}"
  zstyle ":completion:*" menu select
  zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"
'

# ============================================
# Key bindings
# ============================================
bindkey -e  # emacs mode
bindkey "\e\eOD" beginning-of-line
bindkey "\e\eOC" end-of-line

# ============================================
# Ghostty shell integration (must be before prompt)
# ============================================
# Manual sourcing ensures working directory inheritance works
# even when prompt managers like starship are used
if [[ -n "${GHOSTTY_RESOURCES_DIR}" ]]; then
  ghostty_integration="${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
  if [[ ! -r "${ghostty_integration}" ]]; then
    ghostty_integration="${GHOSTTY_RESOURCES_DIR:h}/shell-integration/ghostty-integration.zsh"
  fi
  [[ -r "${ghostty_integration}" ]] && source "${ghostty_integration}"
  unset ghostty_integration
fi

# ============================================
# mise (runtime version manager) - activate early so tools are in PATH
# ============================================
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# ============================================
# Prompt (starship)
# ============================================
eval "$(starship init zsh)"

# ============================================
# Syntax highlighting
# ============================================
if [[ "$IS_MACOS" == true ]]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ============================================
# Source shell modules
# ============================================
source "$CONFIGS_DIR/shell/aliases"
source "$CONFIGS_DIR/shell/ls.sh"
source "$CONFIGS_DIR/shell/functions/git.sh"
source "$CONFIGS_DIR/shell/functions/rails.sh"
source "$CONFIGS_DIR/shell/functions/editors.sh"
source "$CONFIGS_DIR/shell/functions/worktrees.sh"
source "$CONFIGS_DIR/shell/functions/rm.sh"

# macOS specific
if [[ "$IS_MACOS" == true ]]; then
  ulimit -n 65536 2>/dev/null
  export PATH="/opt/homebrew/opt/trash/bin:$PATH"
  source "$CONFIGS_DIR/shell/macos/notif.sh"
fi

# ============================================
# Tool setup
# ============================================

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# npx -> bunx
real_npx=$(which npx)
alias _npx="$real_npx"
alias npx="bunx"

# Homebrew
export HOMEBREW_BUNDLE_FILE_GLOBAL="$CONFIGS_DIR/Brewfile"
export HOMEBREW_NO_AUTO_UPDATE=1
alias rebrew="brew update && brew bundle install --global && brew upgrade"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# atuin (shell history)
eval "$(atuin init zsh)"

# zoxide (smart cd)
eval "$(zoxide init zsh)"

# ============================================
# Debug output
# ============================================
if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zprof
fi
