#!/bin/bash
# Fresh-mac bootstrap: Command Line Tools + Homebrew.
# Run this once on a brand-new machine before install.sh / macos-defaults.sh.
#
# One-liner for a fresh mac (no git yet):
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Zeko369/configs/master/bootstrap.sh)"

set -e

if [ "$(uname -s)" != "Darwin" ]; then
  echo "macOS only."; exit 1
fi

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# ============================================
# Xcode Command Line Tools
# ============================================
if xcode-select -p >/dev/null 2>&1; then
  info "Command Line Tools already installed at $(xcode-select -p)"
else
  info "Triggering Command Line Tools install (GUI dialog will appear)…"
  xcode-select --install 2>/dev/null || true
  info "Waiting for Command Line Tools to finish installing"
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
  info "Command Line Tools installed"
fi

# ============================================
# Homebrew
# ============================================
if command -v brew >/dev/null 2>&1; then
  info "Homebrew already installed at $(command -v brew)"
else
  info "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Put brew on PATH for the rest of this script (Apple Silicon vs Intel)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ============================================
# Clone configs repo if running from curl-bash (no local checkout)
# ============================================
CONFIGS_DIR="$HOME/repos/configs"
SCRIPT_PATH="${BASH_SOURCE[0]:-}"
if [ ! -d "$CONFIGS_DIR/.git" ] && { [ -z "$SCRIPT_PATH" ] || [ ! -f "$SCRIPT_PATH" ]; }; then
  info "Cloning configs into $CONFIGS_DIR"
  mkdir -p "$(dirname "$CONFIGS_DIR")"
  git clone https://github.com/Zeko369/configs.git "$CONFIGS_DIR"
fi

echo ""
info "Bootstrap complete."
cat <<EOF

Next steps:
  cd $CONFIGS_DIR
  brew bundle install --file=Brewfile   # installs everything in Brewfile
  ./install.sh                          # symlinks dotfiles
  ./macos-defaults.sh                   # dock/trackpad/keyboard + postgres bootstrap

EOF
