#!/bin/sh
# ls aliases using eza

# Basic listing
alias ls='eza --icons'
alias ll='eza -l --git --icons'
alias la='eza -la --git --icons'

# Tree view
alias lt='eza --tree --level=2 --icons --git -I "node_modules|.git|vendor"'

# Toggle git info for performance in large repos
function lsToggleGit() {
  if [ -n "$NO_GIT" ]; then
    unset NO_GIT
    echo "Git info enabled in ls"
  else
    export NO_GIT=true
    echo "Git info disabled in ls"
  fi
}

alias ltg="lsToggleGit"
