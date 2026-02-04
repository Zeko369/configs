# Rails and Ruby aliases/functions

# ============================================
# Rails
# ============================================
function _rails_command() {
  if [ -e "bin/stubs/rails" ]; then
    bin/stubs/rails "$@"
  elif [ -e "bin/rails" ]; then
    bin/rails "$@"
  elif [ -e "script/rails" ]; then
    ruby script/rails "$@"
  elif [ -e "script/server" ]; then
    ruby script/"$@"
  else
    command rails "$@"
  fi
}
alias rails='_rails_command'

function _rake_command() {
  if [ -e "bin/stubs/rake" ]; then
    bin/stubs/rake "$@"
  elif [ -e "bin/rake" ]; then
    bin/rake "$@"
  elif type bundle &> /dev/null && [[ -e "Gemfile" || -e "gems.rb" ]]; then
    bundle exec rake "$@"
  else
    command rake "$@"
  fi
}
alias rake='_rake_command'

alias r='bin/rails'
alias rs='rails s'
alias rc='rails c'
alias rr='r routes'
alias rrr='r routes | fzf'

# Bundle
alias be='bundle exec'
alias br='bundle exec'  # typo helper

# RSpec with fzf
function speczf() {
  local spec=$(find spec -name "*_spec.rb" 2>/dev/null | fzf --height 40% --reverse)
  if [[ -n "$spec" ]]; then
    be rspec "$spec"
  fi
}

# Linting
alias lint='be rubocop'

# ============================================
# Kamal (with local bin override)
# ============================================
function kamal() {
  if [[ -x "./bin/kamal" ]]; then
    "./bin/kamal" "$@"
  else
    command kamal "$@"
  fi
}
