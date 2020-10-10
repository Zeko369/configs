# Setting up a server

## Local

### Generate ssh key

```sh
ssh-keygen
```

### ssh config

```sh
Host name
  HostName IP
  User root
  Port 22
  IdentityFile ~/.ssh/key
```

## Remote

### Test

```sh
ssh name
```

### Change ssh port

`vim /etc/ssh/sshd_config`
`#Port 22`

sudo service ssh restart

## Once logged in

Essentials

```sh
sudo apt install tmux zsh git vim vim-gtk curl wget -y
```

OH MY ZSH

Create new user

```sh
adduser user
usermod -aG sudo user
usermod -aG wheel user
```

## Setup NODE

```sh
# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

# YARN
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install --no-install-recommends yarn
```

## Setup LAMP

### setup apache

```sh
sudo apt install apache2
sudo systemctl start apache2.service
sudo systemctl enable apache2.service
```

### setup php

```sh
# OMG WTF THIS WORKS
sudo apt install php php-{bcmath,bz2,intl,gd,mbstring,mysql,zip,fpm,curl,dom} -y

sudo a2enmod rewrite
sudo a2enmod php7.4
systemctl restart apache2
```

```sh
sudo apt install mysql-server
sudo mysql_secure_installation
```

### setup DB

```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '<password>';

CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON dev.* TO 'wordpress'@'localhost';
FLUSH PRIVILEGES;
```

Open `vim /etc/mysql/mysql.cnf`

```conf
[mysqld]
default-authentication-plugin=mysql_native_password
```

Setup PSQL

```sh
sudo apt install postgresql postgresql-contrib
sudo su postgres
createuser -s USER
createdb USER

psql

/password USER
# -> password
# -> password
/q
```

## GIT DEPLOY KEYS

## Additional user

sudo apt install tig
