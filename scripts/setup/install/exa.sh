#!/bin/sh

mkdir exa
cd exa
curl -s https://api.github.com/repos/ogham/exa/releases/latest | grep "/exa-linux" | cut -d : -f 2,3 | tr -d \" | wget -qi -
unzip exa*
rm exa*.zip
mv exa* /bin/exa
cd ..
rm -rf exa