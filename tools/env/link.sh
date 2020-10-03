#!/bin/sh

ln -s ~/repos/configs/vimrc ~/.vimrc
ln -s ~/repos/configs/tmux.conf ~/.tmux.conf

cp ~/repos/configs/zshrc.base ~/repos/configs/zshrc.base.local
ln -s ~/repos/configs/zshrc.base.local ~/.zshrc