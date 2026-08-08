# Work-tailnet setup — sourced by install.sh, not run standalone.
#
# Installs stable CLI links from the public work-tailnet submodule and keeps the
# machine-specific routing configuration in this repository's ignored local/.

setup_work_tailnet() {
  [ "$OS" = "macos" ] || return 0

  local repo="$CONFIGS_DIR/work-tailnet"
  local private_config="$LOCAL_DIR/work-tailnet.json"

  if [ ! -x "$repo/install.sh" ] && git -C "$CONFIGS_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    info "Initializing the work-tailnet submodule"
    git -C "$CONFIGS_DIR" submodule update --init -- work-tailnet || true
  fi

  if [ ! -x "$repo/install.sh" ]; then
    warn "work-tailnet submodule is unavailable. Run: git submodule update --init -- work-tailnet"
    return 0
  fi

  if [ ! -f "$private_config" ]; then
    info "Creating private work-tailnet config: $private_config"
    cp "$repo/config.example.json" "$private_config"
    warn "Fill in $private_config before running $repo/macos/setup.sh"
  fi
  chmod 600 "$private_config"

  "$repo/install.sh" --config-source "$private_config"
}

setup_work_tailnet
