#!/bin/bash
# Configs installer - sets up symlinks and local configs
set -e

CONFIGS_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_DIR="$CONFIGS_DIR/local"
EXAMPLE_DIR="$CONFIGS_DIR/local.example"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS
case "$(uname -s)" in
  Darwin) OS="macos" ;;
  Linux)  OS="linux" ;;
  *)      OS="unknown" ;;
esac

info "Detected OS: $OS"
info "Configs directory: $CONFIGS_DIR"

# ============================================
# Step 1: Create local/ directory if needed
# ============================================
if [ ! -d "$LOCAL_DIR" ]; then
  info "Creating local/ directory..."
  mkdir -p "$LOCAL_DIR"
fi

# ============================================
# Step 2: Copy templates to local/ if they don't exist
# ============================================
copy_template() {
  local filename=$1
  local src="$EXAMPLE_DIR/$filename"
  local dest="$LOCAL_DIR/$filename"

  if [ ! -f "$dest" ]; then
    if [ -f "$src" ]; then
      info "Creating $dest from template..."
      cp "$src" "$dest"
    else
      warn "Template $src not found, skipping"
    fi
  else
    info "$dest already exists, skipping"
  fi
}

copy_template ".zshrc"
copy_template ".vimrc"
copy_template ".tmux.conf"
copy_template ".gitconfig"
copy_template "ghostty.local"

# ============================================
# Step 3: Create symlinks
# ============================================
create_symlink() {
  local src=$1
  local dest=$2

  # Check if source exists
  if [ ! -f "$src" ]; then
    warn "Source $src does not exist, skipping"
    return
  fi

  # If dest exists and is a symlink, remove it
  if [ -L "$dest" ]; then
    info "Removing existing symlink: $dest"
    rm "$dest"
  # If dest exists and is a regular file, back it up
  elif [ -f "$dest" ]; then
    local backup="${dest}.backup.$(date +%Y%m%d_%H%M%S)"
    warn "Backing up existing file: $dest → $backup"
    mv "$dest" "$backup"
  fi

  info "Creating symlink: $dest → $src"
  ln -s "$src" "$dest"
}

create_symlink "$LOCAL_DIR/.zshrc" "$HOME/.zshrc"
create_symlink "$LOCAL_DIR/.vimrc" "$HOME/.vimrc"
create_symlink "$LOCAL_DIR/.tmux.conf" "$HOME/.tmux.conf"
create_symlink "$LOCAL_DIR/.gitconfig" "$HOME/.gitconfig"

# ============================================
# Step 4: Optional configs (direct symlinks, no local wrapper needed)
# ============================================
create_optional_symlink() {
  local src=$1
  local dest=$2

  if [ -f "$src" ]; then
    if [ -L "$dest" ]; then
      rm "$dest"
    elif [ -f "$dest" ]; then
      local backup="${dest}.backup.$(date +%Y%m%d_%H%M%S)"
      warn "Backing up: $dest → $backup"
      mv "$dest" "$backup"
    fi
    info "Creating symlink: $dest → $src"
    ln -s "$src" "$dest"
  fi
}

# Ghostty config (macOS: ~/Library/Application Support/com.mitchellh.ghostty/config)
# Ghostty config (Linux: ~/.config/ghostty/config)
if [ -f "$CONFIGS_DIR/ghostty_config" ]; then
  if [ "$OS" = "macos" ]; then
    GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
  else
    GHOSTTY_DIR="$HOME/.config/ghostty"
  fi
  mkdir -p "$GHOSTTY_DIR"
  create_optional_symlink "$CONFIGS_DIR/ghostty_config" "$GHOSTTY_DIR/config"
fi

# ideavimrc
create_optional_symlink "$CONFIGS_DIR/vim/ideavimrc" "$HOME/.ideavimrc"

# Zed config
if [ -d "$CONFIGS_DIR/zed" ]; then
  ZED_DIR="$HOME/.config/zed"
  mkdir -p "$ZED_DIR"
  create_optional_symlink "$CONFIGS_DIR/zed/settings.json" "$ZED_DIR/settings.json"
  create_optional_symlink "$CONFIGS_DIR/zed/keymap.json" "$ZED_DIR/keymap.json"
fi

# mise config
if [ -f "$CONFIGS_DIR/mise.toml" ]; then
  MISE_DIR="$HOME/.config/mise"
  mkdir -p "$MISE_DIR"
  create_optional_symlink "$CONFIGS_DIR/mise.toml" "$MISE_DIR/config.toml"
fi

# ============================================
# Done!
# ============================================
echo ""
info "Installation complete!"
echo ""
echo "Your local config files are in: $LOCAL_DIR"
echo "Edit these files to add machine-specific customizations."
echo ""
echo "To reload your shell config:"
echo "  source ~/.zshrc"
echo ""

# Remind about Brewfile on macOS
if [ "$OS" = "macos" ]; then
  echo "To install Homebrew packages:"
  echo "  brew bundle install --file=$CONFIGS_DIR/Brewfile"
  echo ""
  echo "For Cursor/VSCode, run: ./sync cursor"
  echo ""
fi
