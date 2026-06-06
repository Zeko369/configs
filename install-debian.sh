#!/bin/bash
# Debian / Ubuntu package installer
# Three install tiers: --cli-bare, --cli-dev, --gui (default = full install).
#
# Usage:
#   ./install-debian.sh             # full install (bare + dev + gui)
#   ./install-debian.sh --gui       # same as default
#   ./install-debian.sh --cli-dev   # bare + dev (no gui apps)
#   ./install-debian.sh --cli-bare  # server-grade shell only
#
# Sibling: ./install-arch.sh for Arch / CachyOS
#
# NOTE: apt's coverage of modern Rust/Go CLI tools is poor — many tools that
# are first-class on Arch arrive here via mise (see debian-mise-tools.toml).
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
command -v apt-get >/dev/null 2>&1 || error "apt-get not found - this script is for Debian/Ubuntu"
command -v sudo  >/dev/null 2>&1 || error "sudo required"

CONFIGS_DIR="$(cd "$(dirname "$0")" && pwd)"

# ============================================
# Step 1: Add third-party apt repos (mise + Docker if dev tier)
# ============================================
info "Adding apt repositories..."
sudo apt-get update -qq
sudo apt-get install -y -qq gpg curl lsb-release

sudo install -dm 755 /etc/apt/keyrings

# mise repo
curl -fsSL https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list > /dev/null

# Docker official repo (dev tier and up)
if [ "$INSTALL_DEV" = true ]; then
  . /etc/os-release
  DISTRO_ID="${ID:-debian}"  # "debian" or "ubuntu"
  CODENAME="$(lsb_release -cs)"

  curl -fsSL "https://download.docker.com/linux/${DISTRO_ID}/gpg" | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DISTRO_ID} ${CODENAME} stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Tailscale official repo
  curl -fsSL "https://pkgs.tailscale.com/stable/${DISTRO_ID}/${CODENAME}.noarmor.gpg" | \
    sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
  curl -fsSL "https://pkgs.tailscale.com/stable/${DISTRO_ID}/${CODENAME}.tailscale-keyring.list" | \
    sudo tee /etc/apt/sources.list.d/tailscale.list > /dev/null
fi

info "Updating apt cache..."
sudo apt-get update -qq

# ============================================
# Step 2: Tier — bare (apt)
# ============================================
APT_BARE=(
  # Core
  git
  tmux
  zsh
  neovim
  vim
  curl
  wget
  unzip
  build-essential

  # Search / list / nav
  fzf
  ripgrep
  fd-find
  bat
  eza
  zoxide

  # Shell
  zsh-syntax-highlighting

  # Monitoring
  btop
  duf
  jq

  # Git
  tig
  gh

  # Misc
  trash-cli
  mise
)

# ============================================
# Step 3: Tier — dev (apt)
# Most modern CLI tools land via the mise gap-filler, not apt.
# ============================================
APT_DEV=(
  just
  hyperfine
  git-delta
  xclip
  xsel
  ffmpeg
  imagemagick
  entr

  # Docker (from docker.com apt repo, added in Step 1)
  docker-ce
  docker-ce-cli
  containerd.io
  docker-buildx-plugin
  docker-compose-plugin

  # Mesh VPN (from pkgs.tailscale.com repo, added in Step 1)
  tailscale

  # Databases (parity with macOS Brewfile)
  postgresql
  # valkey not yet in apt — install via direct binary or skip
)

# ============================================
# Step 4: Tier — GUI (apt)
# Intentionally minimal — most casks need vendor PPAs/.debs and aren't
# scripted here.
# ============================================
APT_GUI=(
  firefox
  vlc
  obs-studio
  transmission-gtk
  fonts-firacode
)

# ============================================
# Step 5: Compose & install
# ============================================
APT_LIST=()
[ "$INSTALL_BARE" = true ] && APT_LIST+=("${APT_BARE[@]}")
[ "$INSTALL_DEV"  = true ] && APT_LIST+=("${APT_DEV[@]}")
[ "$INSTALL_GUI"  = true ] && APT_LIST+=("${APT_GUI[@]}")

info "Installing apt packages (${#APT_LIST[@]})..."
sudo apt-get install -y "${APT_LIST[@]}"

# ============================================
# Step 6: Fix fd/bat binary names (Ubuntu uses different names)
# ============================================
if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
  info "Creating fd symlink (Ubuntu uses fdfind)..."
  sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
fi

if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
  info "Creating bat symlink (Ubuntu uses batcat)..."
  sudo ln -sf "$(which batcat)" /usr/local/bin/bat
fi

# ============================================
# Step 7: mise gap-filler (dev tier and up only)
# Atuin/starship/lazygit are bare-tier UX but only available via mise on
# Debian, so a true --cli-bare install is a degraded shell experience.
# ============================================
if [ "$INSTALL_DEV" = true ]; then
  info "Setting up mise gap-filler config..."

  MISE_DIR="$HOME/.config/mise"
  mkdir -p "$MISE_DIR"

  if [ -L "$MISE_DIR/config.local.toml" ]; then
    rm "$MISE_DIR/config.local.toml"
  elif [ -f "$MISE_DIR/config.local.toml" ]; then
    mv "$MISE_DIR/config.local.toml" "$MISE_DIR/config.local.toml.backup.$(date +%Y%m%d_%H%M%S)"
  fi
  ln -s "$CONFIGS_DIR/debian-mise-tools.toml" "$MISE_DIR/config.local.toml"
  info "Symlinked: $MISE_DIR/config.local.toml → $CONFIGS_DIR/debian-mise-tools.toml"

  eval "$(mise activate bash)"
  mise trust "$MISE_DIR"
  info "Installing and activating tools globally..."
  mise install
  mise use --global --file "$CONFIGS_DIR/debian-mise-tools.toml"
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
# Step 9: Claude Code (dev tier and up)
# ============================================
if [ "$INSTALL_DEV" = true ] && ! command -v claude &> /dev/null; then
  info "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

# ============================================
# Done!
# ============================================
echo ""
info "Debian/Ubuntu package installation complete!"
echo ""
echo "Tiers installed:"
$INSTALL_BARE && echo "  - bare (server-grade shell)"
$INSTALL_DEV  && echo "  - dev (mise gap-filler, runtimes)"
$INSTALL_GUI  && echo "  - gui (small apt set)"
echo ""
# Chain into install.sh for symlinks unless --no-symlinks
if [ "$RUN_SYMLINKS" = true ] && [ -x "$CONFIGS_DIR/install.sh" ]; then
  info "Running symlink step (./install.sh)..."
  "$CONFIGS_DIR/install.sh"
else
  echo "Skipped symlink step. Run: ./install.sh"
fi

echo ""
echo "Next: log out and back in (or: exec zsh)"
echo ""
