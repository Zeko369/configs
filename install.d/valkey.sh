# Valkey config setup — sourced by install.sh, not run standalone.
#
# Relies on these being defined by install.sh before sourcing:
#   vars:  OS, CONFIGS_DIR, LOCAL_DIR
#   funcs: info, warn, copy_template, write_managed_file
#
# macOS + Homebrew only. Generates Homebrew's etc/valkey.conf as a wrapper that
# includes, in order: Homebrew stock config → repo-wide overrides → machine-local.

setup_valkey() {
  [ "$OS" = "macos" ] || return 0
  [ -f "$CONFIGS_DIR/valkey/overrides.conf" ] || return 0

  copy_template "valkey.conf"

  if ! command -v brew >/dev/null 2>&1; then
    warn "Homebrew not found, skipping Valkey config"
    return 0
  fi
  if ! brew list valkey >/dev/null 2>&1; then
    warn "Valkey is not installed yet. Run 'brew bundle install --file=$CONFIGS_DIR/Brewfile' and rerun ./install.sh to generate valkey.conf."
    return 0
  fi

  local brew_prefix main_conf fallback_conf formula_conf local_conf marker base_conf content
  brew_prefix="$(brew --prefix)"
  main_conf="$brew_prefix/etc/valkey.conf"
  fallback_conf="$brew_prefix/etc/valkey-homebrew-default.conf"
  formula_conf="$brew_prefix/opt/valkey/.bottle/etc/valkey.conf"
  local_conf="$LOCAL_DIR/valkey.conf"
  marker="# Managed by $CONFIGS_DIR/install.sh"

  mkdir -p "$brew_prefix/etc" "$brew_prefix/var/run" "$brew_prefix/var/db/valkey"

  if [ -f "$formula_conf" ]; then
    base_conf="$formula_conf"
  elif [ -f "$fallback_conf" ]; then
    base_conf="$fallback_conf"
  elif [ -f "$main_conf" ] && [ ! -L "$main_conf" ]; then
    info "Preserving existing Valkey config as fallback base: $fallback_conf"
    cp "$main_conf" "$fallback_conf"
    base_conf="$fallback_conf"
  else
    warn "Couldn't find a Homebrew Valkey base config, skipping valkey.conf generation"
    return 0
  fi

  content="$marker
# Layer order:
# 1. Homebrew stock config
# 2. Repo-wide overrides
# 3. Machine-specific overrides
include $base_conf
include $CONFIGS_DIR/valkey/overrides.conf
include $local_conf"

  write_managed_file "$main_conf" "$marker" "$content"
}

setup_valkey
