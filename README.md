# Dotfiles

Cross-platform configuration files for zsh, vim, tmux, and various editors.

## Quick Start

**macOS:**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Zeko369/configs/master/bootstrap.sh)"
```

**Arch / CachyOS:**

```bash
sudo pacman -S --noconfirm git && git clone https://github.com/Zeko369/configs.git ~/repos/configs && ~/repos/configs/install-arch.sh && ~/repos/configs/install.sh
```

**Debian / Ubuntu:**

```bash
sudo apt update && sudo apt install -y git curl && git clone https://github.com/Zeko369/configs.git ~/repos/configs && ~/repos/configs/install-debian.sh && ~/repos/configs/install.sh
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
├── postgres/
│   └── overrides.conf       # Repo-wide Postgres overrides (macOS)
│
├── install.d/               # Service setup fragments sourced by install.sh
│   ├── valkey.sh            # Wires Homebrew valkey.conf (macOS)
│   └── postgres.sh          # Wires each installed postgresql@N (macOS)
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
│   ├── valkey.conf          # Machine-specific Valkey overrides
│   └── postgres.conf        # Machine-specific Postgres overrides
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
./bootstrap.sh                                       # Xcode CLT + Homebrew
brew bundle install --file=~/repos/configs/Brewfile
./install.sh
./macos-defaults.sh                                  # dock/trackpad/keyboard + postgres bootstrap
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

### Authenticating GitHub

After `brew bundle` (or the Linux equivalent) installs `gh`:

```bash
gh auth login          # pick SSH — generates an Ed25519 key and uploads it for you
git -C ~/repos/configs remote set-url origin git@github.com:Zeko369/configs.git
```

### Valkey (macOS)

`./install.sh` generates Homebrew's `etc/valkey.conf` as a wrapper that includes:

1. Homebrew's stock Valkey config
2. Repo-wide overrides from `valkey/overrides.conf`
3. Machine-specific overrides from `local/valkey.conf`

If Valkey is already running, reload it after config changes:

```bash
brew services restart valkey
```

### Postgres (macOS)

Same layering idea as Valkey, adapted to how Postgres stores config. Each
version's real `postgresql.conf` lives in its data dir and is generated by
`initdb`, so `./install.sh` doesn't replace it — it appends a managed include
block (between `configs-managed` markers) to every installed version's config:

1. The initdb base config (left untouched above the markers)
2. Repo-wide overrides from `postgres/overrides.conf` (e.g. `max_connections = 200`)
3. Machine-specific overrides from `local/postgres.conf`

PostgreSQL uses last-assignment-wins, so the includes override the defaults
above them. The block is rewritten idempotently on every `install.sh` run.

After config changes, restart any running instance to apply (some settings,
like `max_connections`, require a restart):

```bash
brew services restart postgresql@14
```

For Cursor/VSCode, manually copy:
```bash
cp vscode/*.json ~/Library/Application\ Support/Cursor/User/
```
