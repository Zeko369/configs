#!/bin/zsh
# ls aliases using eza

source "$CONFIGS_DIR/shell/no-git-repos.sh"

_configs_eza() {
  if _configs_path_in_no_git_repo "$PWD"; then
    command eza "$@"
  else
    command eza --git "$@"
  fi
}

# Basic listing
alias _ls="ls"
alias ls='eza --icons'
alias ll='_configs_eza -l --icons'
alias la='_configs_eza -la --icons'

# Tree view
alias lt='_configs_eza --tree --level=2 --icons -I "node_modules|.git|vendor"'
