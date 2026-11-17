# Editor and AI tool aliases

# ============================================
# VS Code / Cursor
# ============================================
unalias ci 2>/dev/null
ci() {
  if command -v code-insiders >/dev/null 2>&1; then
    command code-insiders "$@"
  elif command -v code >/dev/null 2>&1; then
    command code "$@"
  elif command -v cursor >/dev/null 2>&1; then
    command cursor --classic "$@"
  else
    printf 'ci: code-insiders, code, or cursor is required\n' >&2
    return 127
  fi
}
alias ci.='ci .'
alias cs='cursor --classic'
alias cs.='cs .'

# ============================================
# Vim / Neovim
# ============================================
export EDITOR='nvim'
alias vfz='nvim $(fzf)'

vim() {
  if [[ "$1" =~ ^(.+):([0-9]+)$ ]]; then
    command vim +"${match[2]}" "${match[1]}"
  else
    command vim "$@"
  fi
}

nvim() {
  if [[ "$1" =~ ^(.+):([0-9]+)$ ]]; then
    command nvim +"${match[2]}" "${match[1]}"
  else
    command nvim "$@"
  fi
}

# ============================================
# Zed
# ============================================
alias zed.='zed .'

# ============================================
# Zoxide + editor shortcuts
# ============================================
zv() {
  local dir=$(zoxide query -i "$@")
  [[ -n "$dir" ]] && nvim "$dir"
}

zz() {
  local dir=$(zoxide query -i "$@")
  [[ -n "$dir" ]] && zed "$dir"
}

zc() {
  local dir=$(zoxide query -i "$@")
  [[ -n "$dir" ]] && cursor "$dir"
}

# ============================================
# AI tools
# ============================================
# CPA shortcuts: cc pools accounts, ccw is Work-only, ccp is Personal-only.
# Plain codex/claude keep their native subscription authentication.
alias cc='claude-cliproxy --dangerously-skip-permissions'
alias ccw='claude-work --dangerously-skip-permissions'
alias ccwd='claude-work-direct --dangerously-skip-permissions'
alias ca='cursor-agent'
alias cx='codex-cliproxy --dangerously-bypass-approvals-and-sandbox'
alias cxd='codex-direct --dangerously-bypass-approvals-and-sandbox'
alias oc='opencode'
alias ccp='claude-personal --dangerously-skip-permissions'
