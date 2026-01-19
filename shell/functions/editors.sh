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
alias nv='nvim'
alias vfz='nvim $(fzf)'

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
alias cc='claude --allow-dangerously-skip-permissions'
alias ca='cursor-agent'
alias oc='opencode'
