# Dotfiles

Cross-platform configuration files for zsh, vim, tmux, and various tools.

## Quick Start

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/configs.git ~/repos/configs

# Run the installer
cd ~/repos/configs
./install.sh
```

## How It Works

```
configs/
├── zshrc              # Base zsh config (cross-platform)
├── vim/vimrc          # Base vim config
├── tmux.conf          # Base tmux config
├── Brewfile           # macOS Homebrew packages
│
├── local/             # GITIGNORED - machine-specific configs
│   ├── .zshrc         # Sources base + your machine customizations
│   ├── .vimrc         # Sources base + your machine customizations
│   └── .tmux.conf     # Sources base + your machine customizations
│
├── local.example/     # Templates for local/ configs
│
└── shell/             # Extra utilities (optional)
    ├── aliases        # Additional aliases
    ├── functions.sh   # Package.json helpers
    └── ls.sh          # Smart ls (eza/exa/lsd fallback)
```

The `local/` directory is gitignored. Your `~/.zshrc` symlinks to `local/.zshrc`, which sources the base config and allows machine-specific customizations.

## Machine-Specific Customizations

Edit `local/.zshrc` to add things specific to your machine:

```bash
# Source the base config
source "$CONFIGS_DIR/zshrc"

# Machine-specific stuff below
export SOME_API_KEY="xxx"
alias vpn="open /Applications/SomeVPN.app"
```

## macOS: Install Packages

```bash
brew bundle install --file=~/repos/configs/Brewfile
```

## Updating

The base configs in the repo can be updated and committed. Your machine-specific customizations in `local/` stay private.

```bash
cd ~/repos/configs
git pull
source ~/.zshrc
```
