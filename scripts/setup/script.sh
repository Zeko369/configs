#!/bin/bash

install="";

read -p "Update vim, tmux, htop, zsh [y,n] " doit
case $doit in
	y|Y) install="$install vim vim-gtk tmux htop zsh" ;;
	n|N) echo no ;;
	*) install="$install vim vim-gtk tmux htop zsh";;
esac
read -p "Install git, curl, wget [y,n] " doit
case $doit in
	y|Y) install="$install curl wget git" ;;
	n|N) echo no ;;
	*) install="$install curl wget git";;
esac
read -p "Install nmap [y,n] " doit
case $doit in
	y|Y) install="$install nmap" ;;
	n|N) echo no ;;
	*) install="$install nmap";;
esac
read -p "Install ranger [y,n] " doit
case $doit in
	y|Y) install="$install ranger" ;;
	n|N) echo no ;;
	*) install="$install ranger";;
esac

if [ "$install" = "" ]; then
	echo install nothing new
else
	sudo apt update
	sudo apt install $install -y
fi

read -p "Clone config_files repo [y,n] " doit
case $doit in
	y|Y) git clone https://zeko369@bitbucket.org/zeko369/config_files.git;;
	n|N) echo no ;;
	*) git clone https://zeko369@bitbucket.org/zeko369/config_files.git;;
esac

read -p "Install OH-MY-ZSH [y,n] " doit
case $doit in
	y|Y) sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" ;;
	n|N) echo no ;;
	*) sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" ;;
esac
read -p "Vundle ? [y,n] " doit
case $doit in
	y|Y) git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim ;;
	n|N) echo no ;;
	*) git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim ;;
esac
read -p "Pathogen ? [y,n] " doit
case $doit in
	y|Y) mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim ;;
	n|N) echo no ;;
	*) mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim ;;
esac

echo "---------"
echo "   DONE  "
echo "---------"
