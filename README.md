# Dotfiles

Cross-platform configuration files for zsh, vim, tmux, and various editors.

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/configs.git ~/repos/configs
cd ~/repos/configs && ./install.sh
```

## Structure

```
configs/
├── zshrc                    # Base zsh config (cross-platform)
├── tmux.conf                # Tmux config
├── ghostty_config           # Ghostty terminal
├── Brewfile                 # macOS packages
├── valkey/
│   └── overrides.conf       # Repo-wide Valkey overrides (macOS)
│
├── vim/
│   ├── vimrc                # Modern vim config (no plugins needed)
│   ├── ideavimrc            # JetBrains IDE vim bindings
│   └── legacy-vimrc         # Old plugin-heavy config (reference)
│
├── vscode/                  # Cursor/VSCode settings
│   ├── settings.json
│   └── keybindings.json
│
├── zed/                     # Zed editor settings
│   ├── settings.json
│   └── keymap.json
│
├── shell/                   # Extra shell utilities
│   ├── aliases              # Additional aliases
│   ├── functions.sh         # Package.json helpers
│   └── ls.sh                # Smart ls fallback
│
├── local/                   # GITIGNORED - machine-specific
│   ├── .zshrc               # → ~/.zshrc
│   ├── .vimrc               # → ~/.vimrc
│   ├── .tmux.conf           # → ~/.tmux.conf
│   ├── ghostty.local        # Loaded by ghostty_config
│   └── valkey.conf          # Machine-specific Valkey overrides
│
└── local.example/           # Templates for local/
```

## Key Bindings (consistent across editors)

| Binding | Action |
|---------|--------|
| `jk` | Escape to normal mode |
| `B` / `E` | Start / End of line |
| `Cmd+T` | File finder |
| `Cmd+P` | Symbol search |
| `Space` | Leader key |

## Customization

Edit files in `local/` for machine-specific settings:

```bash
# local/.zshrc
source "$CONFIGS_DIR/zshrc"
export SOME_API_KEY="xxx"
```

```vim
" local/.vimrc
source $HOME/repos/configs/vim/vimrc
colorscheme retrobox
```

## Setup

There are two stages:

1. A platform-specific package installer (`Brewfile` on macOS, `install-debian.sh` on Debian/Ubuntu, `install-arch.sh` on Arch/CachyOS).
2. `./install.sh` to wire up symlinks. This is cross-platform and idempotent.

### macOS

```bash
brew bundle install --file=~/repos/configs/Brewfile
./install.sh
```

### Linux — Arch / CachyOS

```bash
./install-arch.sh             # CLI + GUI apps (default)
./install-arch.sh --cli-only  # skip GUI apps
./install.sh                  # symlinks
```

Uses `pacman` for repo packages and `paru` (auto-bootstrapped if missing) for AUR. AUR package names are best-effort; comment out anything that fails and report.

### Linux — Debian / Ubuntu

```bash
./install-debian.sh           # CLI only
./install-debian.sh --gui     # CLI + a small GUI set
./install.sh                  # symlinks
```

GUI app coverage on Debian is intentionally minimal — most casks need separate vendor PPAs / `.deb`s and aren't scripted here.

### Valkey (macOS)

`./install.sh` generates Homebrew's `etc/valkey.conf` as a wrapper that includes:

1. Homebrew's stock Valkey config
2. Repo-wide overrides from `valkey/overrides.conf`
3. Machine-specific overrides from `local/valkey.conf`

If Valkey is already running, reload it after config changes:

```bash
brew services restart valkey
```

For Cursor/VSCode, manually copy:
```bash
cp vscode/*.json ~/Library/Application\ Support/Cursor/User/
```
