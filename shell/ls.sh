#!/bin/sh

function _ls() {
  if command -v exa &> /dev/null; then
    if [ -n "$NO_GIT" ]; then
      exa --long --header "$@"
    else
      exa --long --header --git "$@"
    fi
  elif command -v lsd &> /dev/null; then
    lsd "$@"
  else
    ls "$@"
  fi
}

function exaToggleGit() {
  if [ -n "$NO_GIT" ]; then
    unset NO_GIT
    echo "Git enabled in exa"
  else
    export NO_GIT=true
    echo "Git disabled in exa"
  fi
}

alias etg="exaToggleGit"

alias ll='_ls -lh'
alias la='_ls -lha'
