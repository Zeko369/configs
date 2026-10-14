# mise automatic tool updates — sourced by install.sh after linking the global config.
# Relies on OS, CONFIGS_DIR, info, and warn from install.sh.

setup_mise_tool_update() {
  [ -f "$CONFIGS_DIR/mise.toml" ] || return 0

  case "$OS" in
    macos|linux) ;;
    *) return 0 ;;
  esac

  if ! command -v mise >/dev/null 2>&1; then
    warn "mise not found, skipping automatic tool-update service. Install mise >= 2026.10.9 and rerun ./install.sh."
    return 0
  fi

  local mise_version version_year version_month version_patch
  if ! mise_version="$(mise --version 2>/dev/null)"; then
    warn "Could not read the mise version, skipping automatic tool-update service."
    return 0
  fi
  mise_version="${mise_version%% *}"
  if [[ ! "$mise_version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    warn "Unrecognized mise version '$mise_version', skipping automatic tool-update service."
    return 0
  fi
  version_year=$((10#${BASH_REMATCH[1]}))
  version_month=$((10#${BASH_REMATCH[2]}))
  version_patch=$((10#${BASH_REMATCH[3]}))
  if (( version_year < 2026 ||
        (version_year == 2026 && version_month < 10) ||
        (version_year == 2026 && version_month == 10 && version_patch < 9) )); then
    warn "mise $mise_version is too old for automatic tool updates. Upgrade to >= 2026.10.9 and rerun ./install.sh."
    return 0
  fi

  # Read the linked global config rather than project configs from the caller's directory.
  info "Setting up the mise automatic tool-update service..."
  if ! mise -C "$HOME/.config/mise" bootstrap services apply --yes; then
    warn "Could not set up the mise tool-update service. Check the user service manager and rerun ./install.sh."
  fi
}

setup_mise_tool_update
