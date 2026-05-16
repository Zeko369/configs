#!/bin/bash
# macOS defaults & bootstrap — automates the parts of notes.txt that can be scripted.
# Values are captured from a working machine via `defaults read`. Idempotent — re-run anytime.

set -e

if [ "$(uname -s)" != "Darwin" ]; then
  echo "macOS only, skipping."
  exit 0
fi

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# ============================================
# Trackpad
# ============================================
info "Trackpad: tap-to-click, 3-finger swipe down → App Exposé"
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# 0=off, 1=swipe up (Mission Control), 2=swipe down (App Exposé)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2

# ============================================
# Text input — disable autocorrect & substitutions
# ============================================
info "Text: disable autocorrect, capitalization, dash/period/quote substitution"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# ============================================
# Keyboard repeat (max speed; below the System Settings minimum)
# ============================================
info "Keyboard: max repeat rate"
defaults write NSGlobalDomain InitialKeyRepeat -int 15  # 225 ms
defaults write NSGlobalDomain KeyRepeat -int 2          # 30 ms
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# ============================================
# Dock
# ============================================
info "Dock: autohide on, fast animation, hide recents"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock show-recents -bool false

# ============================================
# Hot corners
# 0=disabled (modifier reserved), 2=Mission Control, 11=Launchpad/Apps
# ============================================
info "Hot corners: TR=Mission Control, BL=Launchpad"
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 11
defaults write com.apple.dock wvous-bl-modifier -int 0

# ============================================
# Mission Control / Stage Manager
# ============================================
info "Mission Control: don't auto-rearrange Spaces by recent use"
defaults write com.apple.dock mru-spaces -bool false

info "Stage Manager: click-wallpaper-to-show-desktop only when Stage Manager is on"
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# ============================================
# Menu bar
# ============================================
info "Menu bar: clock seconds on; Sound 'when active', Now Playing hidden"
defaults write com.apple.menuextra.clock ShowSeconds -bool true
# ControlCenter visibility flags: 2=always, 8=hide, 18=when active, 24=always w/ extras
defaults -currentHost write com.apple.controlcenter Sound -int 18
defaults -currentHost write com.apple.controlcenter NowPlaying -int 8

# ============================================
# Screenshots → ~/Pictures
# ============================================
info "Screenshots: save to ~/Pictures"
mkdir -p "$HOME/Pictures"
defaults write com.apple.screencapture location -string "$HOME/Pictures"

# ============================================
# Restart UI processes so changes take effect
# ============================================
info "Reloading Dock / SystemUIServer / ControlCenter"
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
killall ControlCenter 2>/dev/null || true

# ============================================
# Croatian-US keyboard layout
# ============================================
KBD_LAYOUT_DIR="$HOME/Library/Keyboard Layouts"
if [ ! -f "$KBD_LAYOUT_DIR/Croatian-US.keylayout" ]; then
  info "Installing Croatian-US keyboard layout"
  mkdir -p "$KBD_LAYOUT_DIR"
  TMP=$(mktemp -d)
  if git clone --depth 1 https://github.com/kost/Croatian-US-mac "$TMP/croat" 2>/dev/null; then
    cp "$TMP/croat/Croatian-US.keylayout" "$TMP/croat/Croatian-US.icns" "$KBD_LAYOUT_DIR/" 2>/dev/null || true
    warn "Croatian-US installed — add it via System Settings → Keyboard → Input Sources"
  else
    warn "Failed to clone Croatian-US-mac; install manually"
  fi
  rm -rf "$TMP"
else
  info "Croatian-US keyboard already installed"
fi

# ============================================
# Postgres bootstrap (idempotent)
# ============================================
if command -v brew >/dev/null 2>&1 && brew list postgresql@14 >/dev/null 2>&1; then
  if ! brew services list 2>/dev/null | grep -q "^postgresql@14.*started"; then
    info "Starting postgresql@14"
    brew services start postgresql@14 >/dev/null
    sleep 2
  fi
  PSQL=/opt/homebrew/opt/postgresql@14/bin/psql
  if [ -x "$PSQL" ]; then
    info "Postgres: ensuring fran/dev databases and dev superuser"
    "$PSQL" -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='dev'" | grep -q 1 \
      || "$PSQL" -d postgres -c "CREATE ROLE dev WITH LOGIN SUPERUSER CREATEDB CREATEROLE PASSWORD 'foobar123'"
    "$PSQL" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='fran'" | grep -q 1 \
      || "$PSQL" -d postgres -c "CREATE DATABASE fran"
    "$PSQL" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='dev'" | grep -q 1 \
      || "$PSQL" -d postgres -c "CREATE DATABASE dev OWNER dev"
  fi
else
  warn "postgresql@14 not installed yet — run 'brew bundle install --file=$HOME/repos/configs/Brewfile' first"
fi

# ============================================
# Done
# ============================================
echo ""
info "macOS defaults applied."
cat <<'EOF'

Still manual (System Settings or external accounts):
  - xcode-select --install  (run once before brew)
  - Install Homebrew itself: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  - System Settings → General → Software Update: turn off auto OS updates, keep security only
  - System Settings → Touch ID & Password: enroll additional fingerprints
  - System Settings → Keyboard → Input Sources: add Croatian-US (file is installed)
  - System Settings → Control Center: hide Spotify / Now Playing from menu bar (per-app)
  - System Settings → Desktop & Dock → Hot Corners: confirm BR/TL stay off if you don't want them
  - Beeper: log in, configure iMessage bridge, enable CSS patch toggle, set "send" keyboard shortcut
  - Atuin: `atuin login` then `atuin sync` (key in 1Password — keep manual)
  - AirPods: pair + name + cross-device handoff
  - Spotify app: hide "Now Playing" in its own preferences
  - Apple Account / App Store: sign in (required before mas-installed apps activate)

EOF
