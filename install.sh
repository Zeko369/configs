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
copy_template "starship.toml"

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
  mkdir -p "$GHOSTTY_DIR/local"
  create_optional_symlink "$CONFIGS_DIR/ghostty_config" "$GHOSTTY_DIR/config"
  # ghostty resolves `config-file = ?local/ghostty.local` relative to the
  # symlink's parent dir, not the target — so mirror local/ghostty.local there.
  create_optional_symlink "$LOCAL_DIR/ghostty.local" "$GHOSTTY_DIR/local/ghostty.local"
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

# Starship config (layered: repo base + machine-local overrides).
# Starship has no include directive, so install.sh regenerates the file.
if [ -f "$CONFIGS_DIR/starship.toml" ]; then
  STARSHIP_DEST="$HOME/.config/starship.toml"
  STARSHIP_LOCAL="$LOCAL_DIR/starship.toml"
  STARSHIP_MARKER="# Managed by $CONFIGS_DIR/install.sh"
  mkdir -p "$HOME/.config"

  STARSHIP_CONTENT="$STARSHIP_MARKER
# Layer order:
# 1. Repo base: $CONFIGS_DIR/starship.toml
# 2. Machine-local overrides: $STARSHIP_LOCAL
# Edit the source files and rerun install.sh; do not edit this file directly.

$(cat "$CONFIGS_DIR/starship.toml")"

  if [ -f "$STARSHIP_LOCAL" ]; then
    STARSHIP_CONTENT="$STARSHIP_CONTENT

# --- Machine-local overrides ---
$(cat "$STARSHIP_LOCAL")"
  fi

  write_managed_file "$STARSHIP_DEST" "$STARSHIP_MARKER" "$STARSHIP_CONTENT"
fi

# Service config setup (e.g. Valkey, Postgres).
#
# Each install.d/*.sh is a fragment sourced into this shell, so it reuses the
# vars and helpers defined above (OS, CONFIGS_DIR, LOCAL_DIR, info, warn,
# copy_template, write_managed_file). Fragments self-skip when their service
# or platform doesn't apply. Drop in a new file to manage another service.
for service_script in "$CONFIGS_DIR"/install.d/*.sh; do
  [ -f "$service_script" ] || continue
  # shellcheck source=/dev/null
  source "$service_script"
done

# opencode config
if [ -f "$CONFIGS_DIR/opencode/opencode.jsonc" ]; then
  OPENCODE_DIR="$HOME/.config/opencode"
  mkdir -p "$OPENCODE_DIR"
  create_optional_symlink "$CONFIGS_DIR/opencode/opencode.jsonc" "$OPENCODE_DIR/opencode.jsonc"
fi

# Beeper custom CSS
if [ -f "$CONFIGS_DIR/beeper/custom.css" ]; then
  if [ "$OS" = "macos" ]; then
    BEEPER_DIR="$HOME/Library/Application Support/BeeperTexts"
  else
    BEEPER_DIR="$HOME/.config/BeeperTexts"
  fi
  mkdir -p "$BEEPER_DIR"
  create_optional_symlink "$CONFIGS_DIR/beeper/custom.css" "$BEEPER_DIR/custom.css"
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

# Remind about platform package installer
if [ "$OS" = "macos" ]; then
  echo "To install Homebrew packages:"
  echo "  brew bundle install --file=$CONFIGS_DIR/Brewfile"
  echo ""
  echo "To apply macOS defaults (dock/trackpad/keyboard/postgres bootstrap):"
  echo "  $CONFIGS_DIR/macos-defaults.sh"
  echo ""
  echo "For Cursor/VSCode, run: ./sync cursor"
  echo ""
elif [ "$OS" = "linux" ]; then
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "${ID_LIKE:-$ID}" in
      *arch*)         echo "To install packages:  ./install-arch.sh" ;;
      *debian*|*ubuntu*) echo "To install packages:  ./install-debian.sh" ;;
      *)              echo "Detected Linux but no installer for ID=$ID. See install-arch.sh / install-debian.sh." ;;
    esac
    echo ""
  fi
fi
