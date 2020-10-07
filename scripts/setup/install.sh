sudo apt update

# Copy / paste (try using xclip)
sudo apt install xsel

# Network thingies
sudo apt install curl wget nmap -y

# Utils
sudo apt install tmux zsh git -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Vim
sudo apt install vim vim-gtk -y

# NVM
curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh -o install_nvm.sh
bash install_nvm.sh
rm install_nvm.sh

# RBENV
sudo apt install autoconf bison build-essential libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc

# Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt update
sudo apt install yarn -y

# Others
sudo apt install xclip

# Gen ssh keys
# ssh-keygen -b 2048 -t rsa -f foo123 -q -N ""

mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cd ~
mkdir repos
cd repos
git clone git@bitbucket.org:zeko369/config_files.git
cd ~

# Google play music desktop player

# Exa/LSD
mkdir exa
cd exa
curl -s https://api.github.com/repos/ogham/exa/releases/latest | grep "/exa-linux" | cut -d : -f 2,3 | tr -d \" | wget -qi -
unzip exa*
rm exa*.zip
mv exa* /bin/exa
cd ..
rm -rf exa

# Vs code, atom, sublime
# VS code extensions

# Styling
sudo apt install breeze-cursor-theme -y
sudo apt install arc-theme -y
sudo apt install fonts-firacode -y

# Mysql, psql, mongo?

# drivers for gpu
