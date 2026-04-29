#!/bin/bash
# Debian / Ubuntu package installer
# Installs CLI tools via apt + mise/cargo. Optionally a small GUI app set.
#
# Usage:
#   ./install-debian.sh             # CLI only (default)
#   ./install-debian.sh --gui       # CLI + GUI apps
#   ./install-debian.sh --gui-only  # GUI apps only
#
# Sibling: ./install-arch.sh for Arch / CachyOS
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
INSTALL_GUI=false
for arg in "$@"; do
  case "$arg" in
    --gui)      INSTALL_GUI=true ;;
    --gui-only) INSTALL_GUI=true; INSTALL_CLI=false ;;
    --cli-only) INSTALL_GUI=false ;;
    -h|--help)  sed -n '2,9p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *)          error "Unknown arg: $arg" ;;
  esac
done

# Sanity checks
[ "$(uname -s)" = "Linux" ] || error "Linux only"
command -v apt-get >/dev/null 2>&1 || error "apt-get not found - this script is for Debian/Ubuntu"
command -v sudo >/dev/null 2>&1 || error "sudo required"

CONFIGS_DIR="$(cd "$(dirname "$0")" && pwd)"

# ============================================
# Step 1: Add mise apt repository
# ============================================
if [ "$INSTALL_CLI" = true ]; then
  info "Adding mise apt repository..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq gpg curl

  sudo install -dm 755 /etc/apt/keyrings
  curl -fsSL https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg > /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list > /dev/null
fi

# ============================================
# Step 2: apt cache refresh
# ============================================
info "Updating apt cache..."
sudo apt-get update -qq

# ============================================
# Step 3: CLI packages (apt repo names)
# ============================================
APT_CLI_PACKAGES=(
  # Core tools
  git
  tmux
  zsh
  fzf
  ripgrep
  fd-find
  bat
  jq
  neovim
  vim

  # Modern CLI tools
  eza
  zoxide
  btop
  duf
  git-delta
  just
  hyperfine

  # Git tools
  tig
  gh

  # Shell
  zsh-syntax-highlighting

  # Utilities
  trash-cli
  xclip
  xsel
  curl
  wget
  unzip
  build-essential

  # mise (from mise repo)
  mise
)

# ============================================
# Step 4: GUI apps (apt-only set; many casks need separate PPAs/.debs and
# are intentionally omitted from this script — install them manually)
# ============================================
APT_GUI_PACKAGES=(
  firefox
  vlc
  obs-studio
  transmission-gtk
  fonts-firacode
)

# ============================================
# Step 5: Install
# ============================================
PACKAGES=()
[ "$INSTALL_CLI" = true ] && PACKAGES+=("${APT_CLI_PACKAGES[@]}")
[ "$INSTALL_GUI" = true ] && PACKAGES+=("${APT_GUI_PACKAGES[@]}")

info "Installing apt packages..."
sudo apt-get install -y "${PACKAGES[@]}"

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
# Step 7: mise gap-filler config (tools apt doesn't ship)
# ============================================
if [ "$INSTALL_CLI" = true ]; then
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
# Step 8: Default shell
# ============================================
if [ "$INSTALL_CLI" = true ] && [ "$SHELL" != "$(which zsh)" ]; then
  info "Changing default shell to zsh..."
  chsh -s "$(which zsh)"
fi

# ============================================
# Step 9: Claude Code
# ============================================
if [ "$INSTALL_CLI" = true ] && ! command -v claude &> /dev/null; then
  info "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

# ============================================
# Done!
# ============================================
echo ""
info "Debian/Ubuntu package installation complete!"
echo ""
echo "Next steps:"
echo "  1. Run ./install.sh to set up symlinks"
echo "  2. Log out and back in (or: exec zsh)"
echo ""
