#!/bin/sh
# ls aliases using eza

# Basic listing
alias _ls="ls"
alias ls='eza --icons'
alias ll='eza -l --git --icons'
alias la='eza -la --git --icons'

# Tree view
alias lt='eza --tree --level=2 --icons --git -I "node_modules|.git|vendor"'

