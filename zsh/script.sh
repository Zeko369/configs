#!/bin/bash

filename="status.txt"
file="text.txt"
output=""
out="	exec tmux"
o="fi"
pero=""

pathB=$(pwd)

cd ~/.zsh

while read -r line
do
	pero="$line"
done < "$filename"

while read -r line
do
	output="$line"
done < "$file"

if [ "$pero" = 0 ]; then
	#off
	echo "alias tt="~/.zsh/script.sh"" > config.sh
	echo "1" > $filename
else
	#on
	echo $output > config.sh
	echo "     $out" >> config.sh
	echo $o >> config.sh
	echo "alias tt="~/.zsh/script.sh"" >> config.sh
	echo "1" > $filename
	echo "0" > $filename
fi

cd $pathB
