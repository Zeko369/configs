#!/bin/sh

get_latest () {
  URL="https://api.github.com/repos/$1/releases/latest";
  echo "$(curl -s $URL)" #| grep $2 | cut -d : -f 2,3 | tr -d \" | wget -qi -
}

# get_latest "ogham/exa" "exa-linux"
get_latest "creationix/nvm"