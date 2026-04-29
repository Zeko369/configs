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

### Linux — three tiers

Both Linux installers expose the same flags:

| Flag | What you get |
|------|--------------|
| `--cli-bare` | Server-grade shell only — zsh + prompt + history + tmux + nav, git basics |
| `--cli-dev` | Bare + language runtimes, cloud CLIs, media tools, Git extras |
| `--gui` (default) | Bare + dev + desktop apps |

```bash
./install-arch.sh             # full install
./install-arch.sh --cli-bare  # for SSH'd servers

./install-debian.sh           # full install
./install-debian.sh --cli-dev # dev box, no desktop apps

./install.sh                  # symlinks (always run after the package step)
```

**Arch** uses `pacman` + `paru` (auto-bootstrapped if missing, skipped entirely on `--cli-bare`). AUR package names are best-effort; comment out anything that fails and report.

**Debian** GUI coverage is intentionally minimal — most casks need vendor PPAs / `.deb`s. On `--cli-bare`, atuin/starship/lazygit are *not* installed (they only arrive via the mise gap-filler in the dev tier), so bare Debian is a degraded shell experience compared to bare Arch.

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
