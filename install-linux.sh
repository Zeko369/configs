#!/bin/bash
# Linux package installer - installs CLI tools via apt and mise/cargo
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check we're on Linux
if [ "$(uname -s)" != "Linux" ]; then
  error "This script is for Linux only"
fi

# Check for sudo
if ! command -v sudo &> /dev/null; then
  error "sudo is required"
fi

CONFIGS_DIR="$(cd "$(dirname "$0")" && pwd)"

# ============================================
# Step 1: Add apt repositories
# ============================================
info "Adding apt repositories..."
sudo apt-get update -qq
sudo apt-get install -y -qq gpg curl software-properties-common

# mise repo
sudo install -dm 755 /etc/apt/keyrings
curl -fsSL https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list > /dev/null

# lazygit PPA
info "Adding lazygit PPA..."
sudo add-apt-repository -y ppa:lazygit-team/release

# ============================================
# Step 2: Update and install apt packages
# ============================================
info "Updating apt cache..."
sudo apt-get update -qq

APT_PACKAGES=(
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
  lazygit

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

info "Installing apt packages..."
sudo apt-get install -y "${APT_PACKAGES[@]}"

# ============================================
# Step 3: Fix fd/bat binary names (Ubuntu uses different names)
# ============================================
# Ubuntu installs fd as 'fdfind' and bat as 'batcat'
if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
  info "Creating fd symlink (Ubuntu uses fdfind)..."
  sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
fi

if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
  info "Creating bat symlink (Ubuntu uses batcat)..."
  sudo ln -sf "$(which batcat)" /usr/local/bin/bat
fi

# ============================================
# Step 4: Symlink Linux mise config
# ============================================
info "Setting up Linux mise config..."

MISE_DIR="$HOME/.config/mise"
mkdir -p "$MISE_DIR"

# Symlink linux-mise-tools.toml as config.local.toml
if [ -L "$MISE_DIR/config.local.toml" ]; then
  rm "$MISE_DIR/config.local.toml"
elif [ -f "$MISE_DIR/config.local.toml" ]; then
  mv "$MISE_DIR/config.local.toml" "$MISE_DIR/config.local.toml.backup.$(date +%Y%m%d_%H%M%S)"
fi
ln -s "$CONFIGS_DIR/linux-mise-tools.toml" "$MISE_DIR/config.local.toml"
info "Symlinked: $MISE_DIR/config.local.toml → $CONFIGS_DIR/linux-mise-tools.toml"

# Trust and install
eval "$(mise activate bash)"
mise trust "$MISE_DIR"
info "Installing tools from mise configs..."
mise install

# ============================================
# Step 5: Change default shell to zsh
# ============================================
if [ "$SHELL" != "$(which zsh)" ]; then
  info "Changing default shell to zsh..."
  chsh -s "$(which zsh)"
fi

# ============================================
# Done!
# ============================================
echo ""
info "Linux package installation complete!"
echo ""
echo "Installed via apt:"
echo "  ${APT_PACKAGES[*]}" | fold -s -w 70 | sed 's/^/    /'
echo ""
echo "Installed via mise/cargo:"
echo "    lazygit, starship, atuin, procs, du-dust, tokei"
echo ""
echo "Next steps:"
echo "  1. Run ./install.sh to set up symlinks"
echo "  2. Log out and back in (or run: exec zsh)"
echo "  3. Run: mise trust ~/.config/mise/config.toml"
echo ""
