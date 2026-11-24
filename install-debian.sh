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
set -euo pipefail

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
APT_ARCH="$(dpkg --print-architecture)"
INSTALL_DOCKER=false
if [ "$INSTALL_DEV" = true ] && ! command -v docker >/dev/null 2>&1; then
  INSTALL_DOCKER=true
fi

# ============================================
# Step 1: Add third-party apt repos (mise + Docker if dev tier)
# ============================================
info "Adding apt repositories..."
sudo apt-get update -qq
sudo apt-get install -y -qq gpg curl lsb-release

sudo install -dm 755 /etc/apt/keyrings

# mise repo
curl -fsSL https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=$APT_ARCH] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list > /dev/null

# Docker official repo (dev tier and up)
if [ "$INSTALL_DEV" = true ]; then
  . /etc/os-release
  DISTRO_ID="${ID:-debian}"  # "debian" or "ubuntu"
  CODENAME="$(lsb_release -cs)"

  # Keep an existing engine and its containers running; docker-ce conflicts
  # with Ubuntu's docker.io/containerd packages.
  if [ "$INSTALL_DOCKER" = true ]; then
    curl -fsSL "https://download.docker.com/linux/${DISTRO_ID}/gpg" | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$APT_ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DISTRO_ID} ${CODENAME} stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  fi

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
  openssh-client
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
  transmission-cli
  imagemagick
  entr
  git-lfs
  rclone
  nmap
  ipython3
  shellcheck

  # Native Ruby/Python gems and Rails image/database dependencies
  libyaml-dev
  libssl-dev
  libreadline-dev
  zlib1g-dev
  libffi-dev
  libgdbm-dev
  libncurses-dev
  liblzma-dev
  libsqlite3-dev
  libpq-dev
  libvips-dev

  # Mesh VPN (from pkgs.tailscale.com repo, added in Step 1)
  tailscale

  # Databases (parity with macOS Brewfile)
  postgresql-client
  # valkey not yet in apt — install via direct binary or skip
)

if [ "$INSTALL_DEV" = true ]; then
  if [ "$INSTALL_DOCKER" = true ]; then
    APT_DEV+=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)
  elif dpkg-query -W -f='${Status}' docker.io 2>/dev/null | grep -q 'install ok installed'; then
    APT_DEV+=(docker-compose-v2 docker-buildx)
  else
    info "Keeping the existing Docker installation"
  fi

  if ss -ltnH 'sport = :5432' 2>/dev/null | grep -q .; then
    info "PostgreSQL already listens on 5432; installing client/build libraries only"
  else
    APT_DEV+=(postgresql)
  fi
fi

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
# Configure the shell before optional runtime downloads/builds. A failed
# runtime install must not leave the account on Bash without dotfile links.
# ============================================
LOGIN_SHELL=$(getent passwd "$USER" | cut -d: -f7)
ZSH_PATH=$(command -v zsh)
if [ "$LOGIN_SHELL" != "$ZSH_PATH" ]; then
  info "Changing default shell to zsh ($LOGIN_SHELL → $ZSH_PATH)..."
  sudo chsh -s "$ZSH_PATH" "$USER"
fi

if [ "$RUN_SYMLINKS" = true ]; then
  info "Running symlink step (./install.sh)..."
  "$CONFIGS_DIR/install.sh"
fi

# ============================================
# Step 7: mise gap-filler (all tiers)
# ============================================
info "Setting up mise gap-filler config..."

MISE_DIR="$HOME/.config/mise"
mkdir -p "$MISE_DIR"

if [ -L "$MISE_DIR/config.local.toml" ]; then
  rm "$MISE_DIR/config.local.toml"
elif [ -f "$MISE_DIR/config.local.toml" ]; then
  mv "$MISE_DIR/config.local.toml" "$MISE_DIR/config.local.toml.backup.$(date +%Y%m%d_%H%M%S)"
fi
MISE_TOOLS_FILE="$CONFIGS_DIR/debian-mise-bare.toml"
[ "$INSTALL_DEV" = true ] && MISE_TOOLS_FILE="$CONFIGS_DIR/debian-mise-tools.toml"
ln -s "$MISE_TOOLS_FILE" "$MISE_DIR/config.local.toml"
info "Symlinked: $MISE_DIR/config.local.toml → $MISE_TOOLS_FILE"

# The Debian tools are already selected by the global config.local.toml link.
# Load the checkout's shared runtimes too, even when this script is launched
# from another directory before install.sh has linked the global config.
mise trust "$CONFIGS_DIR"
mise trust "$MISE_DIR"
MISE_INSTALL_FAILED=false
if [ "$INSTALL_DEV" = true ]; then
  info "Installing shared runtimes and Debian CLI tools..."
  if ! mise -C "$CONFIGS_DIR" install; then
    MISE_INSTALL_FAILED=true
  fi
else
  info "Installing shell prompt, history, and Git TUI..."
  if ! mise -C "$CONFIGS_DIR" install aqua:starship/starship aqua:atuinsh/atuin aqua:jesseduffield/lazygit; then
    MISE_INSTALL_FAILED=true
  fi
fi

# ============================================
# Step 7b: Docker post-install (enable service, add user to group)
# ============================================
if [ "$INSTALL_DEV" = true ] && command -v docker &>/dev/null; then
  info "Ensuring docker.service is enabled and running..."
  sudo systemctl enable --now docker.service
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
  info "Ensuring tailscaled.service is enabled and running..."
  sudo systemctl enable --now tailscaled.service
fi

# ============================================
# Done!
# ============================================
echo ""
info "Debian/Ubuntu package and shell setup complete!"
echo ""
echo "Tiers installed:"
$INSTALL_BARE && echo "  - bare (server-grade shell)"
$INSTALL_DEV  && echo "  - dev (mise gap-filler, runtimes)"
$INSTALL_GUI  && echo "  - gui (small apt set)"
echo ""
if [ "$RUN_SYMLINKS" = false ]; then
  echo "Skipped symlink step. Run: ./install.sh"
fi

echo ""
echo "Next: log out and back in (or: exec zsh)"
echo ""
if [ "$MISE_INSTALL_FAILED" = true ]; then
  warn "Some mise tools failed to install. Shell and symlinks are configured; retry: mise -C $CONFIGS_DIR install"
  exit 1
fi
