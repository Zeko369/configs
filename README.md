# Dotfiles

Cross-platform configuration files for zsh, vim, tmux, and various editors.

## Quick Start

**macOS:**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Zeko369/configs/master/bootstrap.sh)"
```

**Arch / CachyOS:**

```bash
sudo pacman -S --noconfirm git && git clone --recurse-submodules https://github.com/Zeko369/configs.git ~/repos/configs && ~/repos/configs/install-arch.sh && ~/repos/configs/install.sh
```

**Debian / Ubuntu:**

```bash
sudo apt update && sudo apt install -y git curl && git clone --recurse-submodules https://github.com/Zeko369/configs.git ~/repos/configs && ~/repos/configs/install-debian.sh && ~/repos/configs/install.sh
```

## Structure

```
configs/
├── zshrc                    # Base zsh config (cross-platform)
├── tmux.conf                # Tmux config
├── ghostty_config           # Ghostty terminal
├── codex/
│   └── config.toml          # Codex settings → ~/.codex/config.toml
├── Brewfile                 # macOS packages
├── macos/
│   ├── file-associations.json  # Default apps by macOS content type
│   └── file-associations.swift # Native apply/check helper
├── bin/macos-file-associations # Apply or verify just the file associations
├── work-tailnet/            # Public submodule: 2nd tailnet CLI, macOS services, Raycast v2
├── valkey/
│   └── overrides.conf       # Repo-wide Valkey overrides (macOS)
├── postgres/
│   └── overrides.conf       # Repo-wide Postgres overrides (macOS)
│
├── install.d/               # Service setup fragments sourced by install.sh
│   ├── valkey.sh            # Wires Homebrew valkey.conf (macOS)
│   ├── postgres.sh          # Wires each installed postgresql@N (macOS)
│   └── mise-tool-update.sh  # Starts the mise updater (macOS/Linux, version checked)
│
├── vim/
│   ├── vimrc                # Modern vim config (no plugins needed)
│   ├── ideavimrc            # JetBrains IDE vim bindings
│   └── legacy-vimrc         # Old plugin-heavy config (reference)
│
├── vscode/                  # Cursor/VSCode settings
│   ├── settings.json
│   ├── keybindings.json
│   └── cursor-extensions.txt # Reproducible Cursor extensions
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
│   ├── postgres.conf        # Machine-specific Postgres overrides
│   └── work-tailnet.json    # Private work-tailnet routes and Raycast shortcuts
│
└── local/example/           # Safe templates copied into local/
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

The Neovim config requires **Neovim 0.11.3 or newer** (`nvim --version`). The
Debian/Ubuntu dev tier installs Neovim through mise to cover older apt packages.
For `--cli-bare`, use a newer Neovim package or install it through mise before
loading this config. Treesitter is pinned to its compatible `master` branch;
update the plugin and configuration together.

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
mise trust ~/repos/configs
mise -C ~/repos/configs install                      # runtimes + developer CLIs
./macos-defaults.sh                                  # dock/trackpad/keyboard + postgres bootstrap
```

### macOS file associations

[`macos/file-associations.json`](macos/file-associations.json) maps application
bundle IDs to macOS content types and their filename extensions. It assigns
Markdown, scripts, YAML/XML, and C/C++ source/header files to Zed (39 extensions).
`.plist`, Swift, and Objective-C are intentionally unmanaged and keep their
existing defaults.

Install Zed and the Xcode Command Line Tools, then run:

```bash
./bin/macos-file-associations --check  # inspect current defaults; also the default mode
./bin/macos-file-associations --apply  # restore the config, then verify
```

`macos-defaults.sh` also applies this config. The helper uses the native macOS
API and waits for each change to complete; no `duti` dependency is needed.
It validates the full config before applying changes, skips defaults that
already match, and verifies both content types and temporary sample files in a
fresh process. A missing app, invalid config, or failed verification exits
nonzero; the broader defaults script warns and continues.

macOS associates content types, so a mapping also covers other extensions that
resolve to the same type. The extension lists are verification samples, not an
exclusive filter. Individual files with custom “Open with” overrides may still
open in a different app.

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

If this checkout predates the work-tailnet submodule, initialize it once:

```bash
git submodule update --init -- work-tailnet
```

**Arch** uses `pacman` + `paru` (auto-bootstrapped if missing, skipped entirely on `--cli-bare`). AUR package names are best-effort; comment out anything that fails and report.

**Debian** GUI coverage is intentionally minimal — most casks need vendor PPAs / `.deb`s. On `--cli-bare`, atuin/starship/lazygit are *not* installed (they only arrive via the mise gap-filler in the dev tier), so bare Debian is a degraded shell experience compared to bare Arch.

### Automatic CLI updates

With mise **2026.10.9 or newer**, the globally symlinked `mise.toml` opts Codex,
OpenCode, and pi into update checks every 6 hours, and BTCA, agent-browser,
yt-dlp, ni, wakatime, and claude-monitor every 24 hours. `./install.sh` sets up
the declared user service automatically on macOS and Linux after linking the
global config. If mise is missing or older than 2026.10.9, the installer skips
the service with a warning; upgrade mise and rerun `./install.sh`.

On Linux, the service requires a working systemd user manager. If the user
service manager is unavailable or setup fails, installation continues. To
apply the service again after resolving the problem:

```bash
mise bootstrap services apply --yes
```

The service checks hourly and upgrades each opted-in tool when its interval is
due, including when no shell is open. This keeps downloads out of command
launches and avoids an updater dispatch failure observed with macOS symlink
shims in mise 2026.10.9. Without the service, mise falls back to checking at
shell prompts and shim/exec launches.

Updates respect the configured release-age delay and its existing agent CLI
exceptions. Project-pinned versions take precedence, and a failed update falls
back to the installed version. Run `mise doctor` to inspect update failures.
See [mise's automatic tool updates](https://mise.jdx.dev/dev-tools/#automatic-tool-updates).

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

**One server, one version.** The Brewfile pins exactly one `postgresql@N`
(currently `@18`), linked into `$(brew --prefix)/bin`, serving every project and
worktree from a single cluster on 5432 — per-project databases are cheap, extra
servers are not. `macos-defaults.sh` discovers the installed version rather than
hardcoding it, so a major upgrade is a one-line Brewfile edit plus a
dump/restore. Note that local is intentionally ahead of production (DO managed
PostgreSQL 15); CI is the gate that must match prod, not this machine.

To run a second version side by side (reproducing a version-specific bug), do
*not* `brew link` back and forth — that is global mutable state that changes
under anything already running. Give it its own port instead, or use the
project's `docker-compose.deps.yml`, and select it with `PGPORT` or a full
connection string.

After config changes, restart any running instance to apply (some settings,
like `max_connections`, require a restart):

```bash
brew services restart postgresql@18
```

### Work tailnet (macOS)

[`work-tailnet`](https://github.com/Zeko369/work-tailnet) is a public submodule containing the
second userspace Tailscale daemon, PAC tooling, CLI, and Raycast extension. Private hostnames,
routes, and site shortcuts stay in the ignored `local/work-tailnet.json` file.

`./install.sh` initializes the submodule when needed, creates the private config template, and
installs `tswork`, `tswork-pac`, and `tswork-run` into `~/.local/bin`. After filling in the JSON:

```bash
./work-tailnet/macos/setup.sh
```

To import the extension into Raycast v2 Beta, keep v2 running and run:

```bash
cd work-tailnet/raycast
npm ci
npm run dev
```

The extension reads the same private JSON and shells out to the stable CLI link, so the submodule
can move or update without breaking it.

For Cursor/VSCode, sync settings and ensure the recorded Cursor extensions are installed:
```bash
./sync cursor
```
