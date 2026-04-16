#!/bin/bash
# Configs installer - sets up symlinks and local configs
set -e

CONFIGS_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_DIR="$CONFIGS_DIR/local"
EXAMPLE_DIR="$LOCAL_DIR/example"

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

copy_template "zshrc"
copy_template "vimrc"
copy_template "tmux.conf"
copy_template "gitconfig"
copy_template "ghostty.local"
copy_template "valkey.conf"

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

create_symlink "$LOCAL_DIR/zshrc" "$HOME/.zshrc"
create_symlink "$LOCAL_DIR/vimrc" "$HOME/.vimrc"
create_symlink "$LOCAL_DIR/tmux.conf" "$HOME/.tmux.conf"
create_symlink "$LOCAL_DIR/gitconfig" "$HOME/.gitconfig"

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

write_managed_file() {
  local dest=$1
  local marker=$2
  local content=$3

  if [ -L "$dest" ]; then
    info "Removing existing symlink: $dest"
    rm "$dest"
  elif [ -f "$dest" ]; then
    if grep -qF "$marker" "$dest"; then
      info "Updating managed file: $dest"
    else
      local backup="${dest}.backup.$(date +%Y%m%d_%H%M%S)"
      warn "Backing up existing file: $dest → $backup"
      mv "$dest" "$backup"
    fi
  fi

  printf '%s\n' "$content" > "$dest"
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

# Neovim config
if [ -d "$CONFIGS_DIR/nvim" ]; then
  NVIM_DEST="$HOME/.config/nvim"
  if [ -L "$NVIM_DEST" ]; then
    rm "$NVIM_DEST"
  elif [ -d "$NVIM_DEST" ]; then
    backup="${NVIM_DEST}.backup.$(date +%Y%m%d_%H%M%S)"
    warn "Backing up: $NVIM_DEST → $backup"
    mv "$NVIM_DEST" "$backup"
  fi
  mkdir -p "$HOME/.config"
  info "Creating symlink: $NVIM_DEST → $CONFIGS_DIR/nvim"
  ln -s "$CONFIGS_DIR/nvim" "$NVIM_DEST"
fi

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

# lazygit config
if [ -f "$CONFIGS_DIR/lazygit/config.yml" ]; then
  if [ "$OS" = "macos" ]; then
    LAZYGIT_DIR="$HOME/Library/Application Support/lazygit"
  else
    LAZYGIT_DIR="$HOME/.config/lazygit"
  fi
  mkdir -p "$LAZYGIT_DIR"
  create_optional_symlink "$CONFIGS_DIR/lazygit/config.yml" "$LAZYGIT_DIR/config.yml"
fi

# atuin config
if [ -f "$CONFIGS_DIR/atuin.toml" ]; then
  ATUIN_DIR="$HOME/.config/atuin"
  mkdir -p "$ATUIN_DIR"
  create_optional_symlink "$CONFIGS_DIR/atuin.toml" "$ATUIN_DIR/config.toml"
fi

# Valkey config (macOS + Homebrew only)
if [ "$OS" = "macos" ] && [ -f "$CONFIGS_DIR/valkey/overrides.conf" ]; then
  if command -v brew >/dev/null 2>&1; then
    if brew list valkey >/dev/null 2>&1; then
      BREW_PREFIX="$(brew --prefix)"
      VALKEY_MAIN_CONF="$BREW_PREFIX/etc/valkey.conf"
      VALKEY_FALLBACK_CONF="$BREW_PREFIX/etc/valkey-homebrew-default.conf"
      VALKEY_FORMULA_CONF="$BREW_PREFIX/opt/valkey/.bottle/etc/valkey.conf"
      VALKEY_LOCAL_CONF="$LOCAL_DIR/valkey.conf"
      VALKEY_MARKER="# Managed by $CONFIGS_DIR/install.sh"

      mkdir -p "$BREW_PREFIX/etc" "$BREW_PREFIX/var/run" "$BREW_PREFIX/var/db/valkey"

      if [ -f "$VALKEY_FORMULA_CONF" ]; then
        VALKEY_BASE_CONF="$VALKEY_FORMULA_CONF"
      elif [ -f "$VALKEY_FALLBACK_CONF" ]; then
        VALKEY_BASE_CONF="$VALKEY_FALLBACK_CONF"
      elif [ -f "$VALKEY_MAIN_CONF" ] && [ ! -L "$VALKEY_MAIN_CONF" ]; then
        info "Preserving existing Valkey config as fallback base: $VALKEY_FALLBACK_CONF"
        cp "$VALKEY_MAIN_CONF" "$VALKEY_FALLBACK_CONF"
        VALKEY_BASE_CONF="$VALKEY_FALLBACK_CONF"
      else
        warn "Couldn't find a Homebrew Valkey base config, skipping valkey.conf generation"
        VALKEY_BASE_CONF=""
      fi

      if [ -n "$VALKEY_BASE_CONF" ]; then
        VALKEY_CONTENT="$VALKEY_MARKER
# Layer order:
# 1. Homebrew stock config
# 2. Repo-wide overrides
# 3. Machine-specific overrides
include $VALKEY_BASE_CONF
include $CONFIGS_DIR/valkey/overrides.conf
include $VALKEY_LOCAL_CONF"

        write_managed_file "$VALKEY_MAIN_CONF" "$VALKEY_MARKER" "$VALKEY_CONTENT"
      fi
    else
      warn "Valkey is not installed yet. Run 'brew bundle install --file=$CONFIGS_DIR/Brewfile' and rerun ./install.sh to generate valkey.conf."
    fi
  else
    warn "Homebrew not found, skipping Valkey config"
  fi
fi

# opencode config
if [ -f "$CONFIGS_DIR/opencode/opencode.jsonc" ]; then
  OPENCODE_DIR="$HOME/.config/opencode"
  mkdir -p "$OPENCODE_DIR"
  create_optional_symlink "$CONFIGS_DIR/opencode/opencode.jsonc" "$OPENCODE_DIR/opencode.jsonc"
fi

# ============================================
# Step 5: Install git-hunks (non-interactive hunk staging)
# ============================================
if command -v git &> /dev/null; then
  GIT_HUNKS_REPO="https://github.com/rockorager/git-hunks.git"
  TEMP_DIR=$(mktemp -d)

  if git clone --depth 1 "$GIT_HUNKS_REPO" "$TEMP_DIR/git-hunks" 2>/dev/null; then
    info "Installing git-hunks..."
    make -C "$TEMP_DIR/git-hunks" PREFIX=~/.local install >/dev/null 2>&1
    info "git-hunks installed to ~/.local/bin"
  else
    warn "Failed to clone git-hunks, skipping"
  fi

  rm -rf "$TEMP_DIR"
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
