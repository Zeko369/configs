#!/bin/sh

[ -f ~/.vimrc ] && cp ~/.vimrc ~/.vimrc.bak
[ -f ~/.tmux.conf ] && cp ~/.tmux.conf ~/.tmux.conf.bak

cp ~/repos/configs/vim/basic_vimrc ~/repos/configs/vim/vimrc.local
ln -fs ~/repos/configs/vim/vimrc.local ~/.vimrc
ln -fs ~/repos/configs/tmux.conf ~/.tmux.conf

[ -f ~/repos/configs/shell/zshrc.base.local ] && cp ~/repos/configs/shell/zshrc.base.local ~/repos/configs/shell/zshrc.base.local.bak
cp ~/repos/configs/shell/zshrc.base ~/repos/configs/shell/zshrc.base.local
ln -fs ~/repos/configs/shell/zshrc.base.local ~/.zshrc
