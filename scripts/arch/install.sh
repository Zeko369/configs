#!/bin/sh

sudo pacman -Sy

sudo pacman -S vim git tmux zsh curl wget jq

curl -o- -L https://yarnpkg.com/install.sh | bash

# Psql on arch
# https://linuxhint.com/install-postgresql-10-arch-linux/

sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable mysqld
sudo systemctl start mysqld

