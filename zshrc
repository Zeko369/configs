# ============================================
# Cross-platform zsh config
# ============================================

# Detect OS
case "$(uname -s)" in
  Darwin) IS_MACOS=true ;;
  Linux)  IS_LINUX=true ;;
esac

# Configs directory
export CONFIGS_DIR="$HOME/repos/configs"

# Tool configs
export RIPGREP_CONFIG_PATH="$CONFIGS_DIR/ripgreprc"

# Fix hostname for starship (macOS hostname command returns weird value)
if [[ "$IS_MACOS" == true ]]; then
  export STARSHIP_HOST=$(scutil --get LocalHostName 2>/dev/null || hostname)
fi

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
# Completions
# ============================================
autoload -Uz compinit
# Only regenerate compinit cache once a day
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# Menu selection
zstyle ':completion:*' menu select
# Colors in completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

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
  source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
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
# zsh-defer (lazy loading for slow tools)
# ============================================
source "$CONFIGS_DIR/shell/plugins/zsh-defer.plugin.zsh"

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

# mise (runtime version manager)
eval "$(mise activate zsh)"

# zoxide (smart cd)
eval "$(zoxide init zsh)"

# ============================================
# Debug output
# ============================================
if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zprof
fi
