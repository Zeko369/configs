#!/bin/sh

defaults write com.apple.dock autohide-time-modifier -float 0.15; killall Dock
defaults delete com.apple.dock autohide-time-modifier; killall Dock

# Encrypt:
openssl aes-256-cbc -a -salt -in secrets.txt -out secrets.txt.enc
# Decrypt:
openssl aes-256-cbc -d -a -in secrets.txt.enc -out secrets.txt.new

