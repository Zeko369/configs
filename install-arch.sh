#!/bin/bash
# Arch / CachyOS package installer
# Three install tiers: --cli-bare, --cli-dev, --gui (default = full install).
#
# Usage:
#   ./install-arch.sh             # full install (bare + dev + gui)
#   ./install-arch.sh --gui       # same as default
#   ./install-arch.sh --cli-dev   # bare + dev (no gui apps)
#   ./install-arch.sh --cli-bare  # server-grade shell only
#
# Sibling: ./install-debian.sh for Debian / Ubuntu
#
# NOTE: AUR package names are best-guess. If a package fails, comment it out
# and report — names occasionally change (e.g. cursor-bin, claude-desktop).
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Tier flags (default = everything)
INSTALL_BARE=true
INSTALL_DEV=true
INSTALL_GUI=true
RUN_SYMLINKS=true
for arg in "$@"; do
  case "$arg" in
    --cli-bare)    INSTALL_DEV=false; INSTALL_GUI=false ;;
    --cli-dev)     INSTALL_GUI=false ;;
    --gui|--all)   ;;  # default
    --no-symlinks) RUN_SYMLINKS=false ;;
    -h|--help)     sed -n '2,11p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *)             error "Unknown arg: $arg" ;;
  esac
done

# Sanity checks
[ "$(uname -s)" = "Linux" ] || error "Linux only"
command -v pacman >/dev/null 2>&1 || error "pacman not found - this script is for Arch-based distros"
command -v sudo  >/dev/null 2>&1 || error "sudo required"

CONFIGS_DIR="$(cd "$(dirname "$0")" && pwd)"

# ============================================
# Step 1: Refresh package databases
# ============================================
info "Syncing pacman databases..."
sudo pacman -Sy --noconfirm

# ============================================
# Step 2: Bootstrap an AUR helper (only if a tier needs AUR)
# ============================================
NEEDS_AUR=false
[ "$INSTALL_DEV" = true ] && NEEDS_AUR=true
[ "$INSTALL_GUI" = true ] && NEEDS_AUR=true

AUR_HELPER=""
if [ "$NEEDS_AUR" = true ]; then
  if command -v paru &>/dev/null; then
    AUR_HELPER=paru
  elif command -v yay &>/dev/null; then
    AUR_HELPER=yay
  else
    info "No AUR helper found — bootstrapping paru..."
    sudo pacman -S --needed --noconfirm base-devel git
    TMP=$(mktemp -d)
    git clone https://aur.archlinux.org/paru-bin.git "$TMP/paru-bin"
    (cd "$TMP/paru-bin" && makepkg -si --noconfirm)
    rm -rf "$TMP"
    AUR_HELPER=paru
  fi
  info "Using AUR helper: $AUR_HELPER"
fi

# ============================================
# Step 3: Tier — bare (pacman)
# Server-grade shell: prompt, history, tmux, navigation, git basics.
# ============================================
PACMAN_BARE=(
  base-devel
  git
  tmux
  zsh
  neovim
  vim
  curl
  wget
  unzip

  # Search / list / nav
  fzf
  ripgrep
  fd
  bat
  eza
  zoxide

  # Shell prompt + history + completion
  starship
  atuin
  zsh-syntax-highlighting

  # Monitoring
  btop
  duf
  dust
  procs
  fastfetch

  # Data wrangling
  jq
  yq
  tealdeer
  sd
  ouch

  # Git
  lazygit
  tig
  git-delta
  github-cli

  # Misc
  trash-cli
  mise
)

# ============================================
# Step 4: Tier — dev (pacman + AUR)
# Adds language runtimes, cloud CLIs, heavier media/image tooling.
# ============================================
PACMAN_DEV=(
  # Dev workflow
  just
  hyperfine
  tokei
  zellij
  glow
  xh
  entr

  # Display-bound clipboards (skip on bare/server)
  xclip
  xsel

  # Media / image
  yt-dlp
  ffmpeg
  imagemagick

  # Git extras
  git-lfs
  diff-so-fancy
  gitleaks
  jujutsu

  # Cloud / infra
  rclone
  nmap
  helm
  tailscale            # Mesh VPN (daemon + CLI)

  # Containers
  docker
  docker-compose
  docker-buildx
  dive                 # Docker image layer explorer
  lazydocker           # Docker TUI

  # Databases (parity with macOS Brewfile)
  postgresql
  valkey

  # Language runtimes (mise can also manage these)
  rust
  go

  # AI coding agents
  # openai-codex moved to mise.toml as "npm:@openai/codex" (cross-platform)
)

AUR_DEV=(
  jaq                   # Faster jq (Rust)
  yj                    # YAML/JSON/TOML converter
  doggo                 # Better dig
  grex                  # Regex from examples
  overmind              # Procfile manager
  # wakatime moved to mise as "pipx:wakatime" (cross-platform)
  cloudflared
  doctl
  kubeseal
  claude-code           # Claude Code CLI (also installable via curl)
  # Railway.app CLI lives in mise.toml as "npm:@railway/cli" (cross-platform)
)

# ============================================
# Step 5: Tier — GUI (pacman + AUR)
# ============================================
PACMAN_GUI=(
  ghostty
  firefox
  discord
  obs-studio
  vlc
  blender
  freecad
  kicad
  ollama
  prismlauncher
  jre-openjdk           # Explicit Java provider (prismlauncher needs java-runtime)
  transmission-gtk
  ttf-firacode-nerd
  zed
)

AUR_GUI=(
  1password
  1password-cli
  google-chrome
  visual-studio-code-bin
  cursor-bin
  jetbrains-toolbox
  spotify
  slack-desktop-wayland   # Pin specific provider to skip paru's selection prompt
  zoom
  beeper
  balena-etcher
  lm-studio
  claude-desktop-appimage   # AppImage variant: no Electron rebuild
  nordvpn-bin
  yaak-bin
  # tableplus  # disabled: AUR PKGBUILD pinned to 0.1.296 which was 404'd from upstream CDN
  qflipper
  # openai-codex-desktop  # disabled: source build (npm + native better-sqlite3/node-pty compile)
  t3code-bin            # T3 Chat code editor
  atuin-desktop-bin     # Atuin desktop GUI
)

# ============================================
# Step 6: Compose & install
# ============================================
PACMAN_LIST=()
AUR_LIST=()
[ "$INSTALL_BARE" = true ] && PACMAN_LIST+=("${PACMAN_BARE[@]}")
[ "$INSTALL_DEV"  = true ] && PACMAN_LIST+=("${PACMAN_DEV[@]}")  && AUR_LIST+=("${AUR_DEV[@]}")
[ "$INSTALL_GUI"  = true ] && PACMAN_LIST+=("${PACMAN_GUI[@]}") && AUR_LIST+=("${AUR_GUI[@]}")

info "Installing pacman packages (${#PACMAN_LIST[@]})..."
sudo pacman -S --needed --noconfirm "${PACMAN_LIST[@]}"

if [ ${#AUR_LIST[@]} -gt 0 ]; then
  info "Installing AUR packages via $AUR_HELPER (${#AUR_LIST[@]})..."
  # No --noconfirm: AUR Electron apps frequently pin conflicting nodejs-lts-*
  # versions, and paru can't auto-resolve those under --noconfirm. Provider
  # selection prompts (yj, google-chrome, etc.) default to choice 1.
  "$AUR_HELPER" -S --needed "${AUR_LIST[@]}"
fi

# ============================================
# Step 7: mise — install runtimes (dev tier and up only)
# ============================================
if [ "$INSTALL_DEV" = true ]; then
  info "Activating mise and installing runtimes from mise.toml..."
  eval "$(mise activate bash)"
  mise trust "$CONFIGS_DIR"
  mise install
fi

# ============================================
# Step 7b: Docker post-install (enable service, add user to group)
# ============================================
if [ "$INSTALL_DEV" = true ] && command -v docker &>/dev/null; then
  if ! systemctl is-enabled docker.service &>/dev/null; then
    info "Enabling docker.service..."
    sudo systemctl enable --now docker.service
  fi
  if ! id -nG "$USER" | grep -qw docker; then
    info "Adding $USER to docker group (log out + back in to take effect)..."
    sudo usermod -aG docker "$USER"
  fi
fi

# ============================================
# Step 7c: Tailscale post-install (enable daemon)
# Run `sudo tailscale up` afterwards to authenticate.
# ============================================
if [ "$INSTALL_DEV" = true ] && command -v tailscale &>/dev/null; then
  if ! systemctl is-enabled tailscaled.service &>/dev/null; then
    info "Enabling tailscaled.service..."
    sudo systemctl enable --now tailscaled.service
  fi
fi

# ============================================
# Step 8: Default shell (bare tier and up)
# Read login shell from /etc/passwd, not $SHELL — $SHELL is the current
# process's shell, which can be bash if the script is invoked via `bash ...`.
# ============================================
if [ "$INSTALL_BARE" = true ]; then
  LOGIN_SHELL=$(getent passwd "$USER" | cut -d: -f7)
  ZSH_PATH=$(command -v zsh)
  if [ "$LOGIN_SHELL" != "$ZSH_PATH" ]; then
    info "Changing default shell to zsh ($LOGIN_SHELL → $ZSH_PATH)..."
    chsh -s "$ZSH_PATH"
  fi
fi

# ============================================
# Done!
# ============================================
echo ""
info "Arch package installation complete!"
echo ""
echo "Tiers installed:"
$INSTALL_BARE && echo "  - bare (server-grade shell)"
$INSTALL_DEV  && echo "  - dev (runtimes, cloud CLIs, media)"
$INSTALL_GUI  && echo "  - gui (desktop apps)"
echo ""

# ============================================
# Step 9: Symlink configs (chain into install.sh) — unless --no-symlinks
# ============================================
if [ "$RUN_SYMLINKS" = true ] && [ -x "$CONFIGS_DIR/install.sh" ]; then
  info "Running symlink step (./install.sh)..."
  "$CONFIGS_DIR/install.sh"
else
  echo "Skipped symlink step. Run: ./install.sh"
fi

echo ""
echo "Next: log out and back in (or: exec zsh)"
echo ""
