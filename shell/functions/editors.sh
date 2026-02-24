# Editor and AI tool aliases

# ============================================
# VS Code / Cursor
# ============================================
alias ci='code-insiders'
alias ci.='ci .'
alias cs='cursor'
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
alias cc='claude --dangerously-skip-permissions'
alias ca='cursor-agent'
alias cx='codex'
alias oc='opencode'
