#!/bin/sh

USER="dev"

# Go here and remove dict password protection 
#vim /etc/pam.d/common-password 

useradd $USER
passwd $USER
usermod -aG sudo $USER
usermod -aG wheel $USER

# Install basic
sudo apt install tmux zsh git vim curl wget tig jq -y

# On user

ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""

# NVM
sh -c "$(curl -fsSL https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh)"

echo `export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"` >> ~/.zshrc
echo `[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm` >> ~/.zshrc

source ~/.zshrc

nvm install --lts

# Yarn
curl -o- -L https://yarnpkg.com/install.sh | bash

# PSQL
sudo apt install postgresql postgresql-contrib

sudo systemctl enable postgresql
sudo systemctl start postgresql

echo """Now run
createuser -s $USER
createdb $USER

psql
\password $USER
foobar123
foobar123
\q
exit
"""

sudo su postgres

echo "Now do 'source ~/.zshrc'"
