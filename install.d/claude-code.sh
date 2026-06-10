# Claude Code install — sourced by install.sh, not run standalone.
#
# Relies on these being defined by install.sh before sourcing:
#   vars:  OS
#   funcs: info
#
# macOS only. Linux installs Claude Code from its platform package script
# (install-debian.sh native installer / install-arch.sh AUR). Uses Anthropic's
# recommended native installer instead of Homebrew so Claude Code auto-updates
# in the background. https://code.claude.com/docs/en/setup
#
# Skips if `claude` already resolves on PATH. To switch a machine off the old
# Homebrew cask: `brew uninstall --cask claude-code@latest`, then rerun install.

setup_claude_code() {
  [ "$OS" = "macos" ] || return 0
  command -v claude >/dev/null 2>&1 && return 0

  info "Installing Claude Code (native installer)..."
  curl -fsSL https://claude.ai/install.sh | bash
}

setup_claude_code
