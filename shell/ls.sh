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
alias ls='eza --icons=auto'
alias ll='_configs_eza -l --icons=auto'
alias la='_configs_eza -la --icons=auto'

# Tree view
alias lt='_configs_eza --tree --level=2 --icons=auto -I "node_modules|.git|vendor"'
