#!/bin/sh

sudo pacman -Sy

sudo pacman -S vim git tmux zsh curl wget

curl -o- -L https://yarnpkg.com/install.sh | bash

# Psql on arch
# https://linuxhint.com/install-postgresql-10-arch-linux/
