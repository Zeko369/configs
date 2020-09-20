#!/bin/bash

# Install basic necessities sad
sudo apt install curl git tmux zsh vim vim-gtk -y

# setup config files
mkdir repos
cd repos
git clone https://github.com/Zeko369/configs

