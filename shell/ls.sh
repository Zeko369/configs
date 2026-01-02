#!/bin/sh
# Smart ls with fallback: eza → exa → lsd → ls

function _ls() {
  if command -v eza &> /dev/null; then
    if [ -n "$NO_GIT" ]; then
      eza --long --header --icons "$@"
    else
      eza --long --header --icons --git "$@"
    fi
  elif command -v exa &> /dev/null; then
    # Fallback to exa (deprecated, but might be installed on older systems)
    if [ -n "$NO_GIT" ]; then
      exa --long --header --icons "$@"
    else
      exa --long --header --icons --git "$@"
    fi
  elif command -v lsd &> /dev/null; then
    lsd "$@"
  else
    ls "$@"
  fi
}

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

alias ll='eza -l --git --icons always'
alias la='_ls -lha'

# Tree view with eza
function lt() {
  eza --tree --level=2 --long --icons --git --ignore-glob="node_modules|.git|vendor" $argv
}
