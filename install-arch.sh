#!/bin/bash
# Arch / CachyOS package installer
# Installs CLI tools via pacman, AUR packages via paru, and optionally GUI apps.
#
# Usage:
#   ./install-arch.sh             # CLI + GUI apps (default)
#   ./install-arch.sh --cli-only  # CLI tools only
#   ./install-arch.sh --gui-only  # GUI apps only
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

# Parse args
INSTALL_CLI=true
INSTALL_GUI=true
for arg in "$@"; do
  case "$arg" in
    --cli-only) INSTALL_GUI=false ;;
    --gui-only) INSTALL_CLI=false ;;
    -h|--help)  sed -n '2,9p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *)          error "Unknown arg: $arg" ;;
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
# Step 2: Bootstrap an AUR helper (paru preferred; yay accepted)
# ============================================
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

# ============================================
# Step 3: CLI packages — official repos (pacman)
# ============================================
PACMAN_CLI_PACKAGES=(
  # Core
  base-devel
  git
  tmux
  zsh
  fzf
  ripgrep
  fd
  bat
  jq
  neovim
  vim
  curl
  wget
  unzip

  # Modern CLI tools
  eza
  zoxide
  btop
  duf
  dust
  procs
  tokei
  hyperfine
  just
  starship
  atuin
  zellij
  glow
  tldr
  sd
  xh
  ouch
  fastfetch
  yt-dlp
  ffmpeg

  # Git
  lazygit
  tig
  git-delta
  git-lfs
  diff-so-fancy
  github-cli
  gitleaks
  jujutsu

  # Shell
  zsh-syntax-highlighting

  # Utils
  trash-cli
  xclip
  xsel
  yq
  rclone
  nmap
  helm

  # Runtimes (mise can also manage these; pacman copies are fine for global use)
  rust
  go

  # mise
  mise
)

# ============================================
# Step 4: CLI packages — AUR-only
# ============================================
AUR_CLI_PACKAGES=(
  jaq                   # Faster jq (Rust)
  yj                    # YAML/JSON/TOML converter
  doggo                 # Better dig
  grex                  # Regex from examples
  overmind              # Procfile manager
  wakatime-cli
  cloudflared
  doctl
  kubeseal
  claude-code           # Claude Code CLI (also installable via curl)
)

# ============================================
# Step 5: GUI apps — official repos
# ============================================
PACMAN_GUI_PACKAGES=(
  ghostty
  firefox
  discord
  obs-studio
  vlc
  tailscale
  blender
  freecad
  kicad
  ollama
  prismlauncher
  transmission-gtk
  ttf-firacode-nerd
  zed
)

# ============================================
# Step 6: GUI apps — AUR-only
# ============================================
AUR_GUI_PACKAGES=(
  1password
  1password-cli
  google-chrome
  visual-studio-code-bin
  cursor-bin
  jetbrains-toolbox
  spotify
  slack-desktop
  zoom
  beeper
  balena-etcher
  lm-studio
  claude-desktop
  nordvpn-bin
)

# ============================================
# Step 7: Install
# ============================================
PACMAN_LIST=()
AUR_LIST=()
[ "$INSTALL_CLI" = true ] && PACMAN_LIST+=("${PACMAN_CLI_PACKAGES[@]}") && AUR_LIST+=("${AUR_CLI_PACKAGES[@]}")
[ "$INSTALL_GUI" = true ] && PACMAN_LIST+=("${PACMAN_GUI_PACKAGES[@]}") && AUR_LIST+=("${AUR_GUI_PACKAGES[@]}")

info "Installing pacman packages (${#PACMAN_LIST[@]})..."
sudo pacman -S --needed --noconfirm "${PACMAN_LIST[@]}"

info "Installing AUR packages via $AUR_HELPER (${#AUR_LIST[@]})..."
"$AUR_HELPER" -S --needed --noconfirm "${AUR_LIST[@]}"

# ============================================
# Step 8: mise — install runtimes from mise.toml
# ============================================
if [ "$INSTALL_CLI" = true ]; then
  info "Activating mise and installing runtimes from mise.toml..."
  eval "$(mise activate bash)"
  mise trust "$CONFIGS_DIR"
  mise install
fi

# ============================================
# Step 9: Default shell
# ============================================
if [ "$INSTALL_CLI" = true ] && [ "$SHELL" != "$(which zsh)" ]; then
  info "Changing default shell to zsh..."
  chsh -s "$(which zsh)"
fi

# ============================================
# Done!
# ============================================
echo ""
info "Arch package installation complete!"
echo ""
echo "Next steps:"
echo "  1. Run ./install.sh to set up symlinks"
echo "  2. Log out and back in (or: exec zsh)"
echo ""
