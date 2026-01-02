# ============================================
# Cross-platform zsh config (no oh-my-zsh!)
# ============================================

# Detect OS
case "$(uname -s)" in
  Darwin) IS_MACOS=true ;;
  Linux)  IS_LINUX=true ;;
esac

# Configs directory
export CONFIGS_DIR="$HOME/repos/configs"

# Tool configs
export RIPGREP_CONFIG_PATH="$CONFIGS_DIR/ripgreprc"

# Fix hostname for starship (macOS hostname command returns weird value)
if [[ "$IS_MACOS" == true ]]; then
  export STARSHIP_HOST=$(scutil --get LocalHostName 2>/dev/null || hostname)
fi

# Kiro CLI - disabled (slows down new tabs significantly)
# if [[ "$IS_MACOS" == true ]] && [[ -x ~/.local/bin/kiro-cli ]]; then
#   eval "$(~/.local/bin/kiro-cli init zsh pre --rcfile zshrc)"
# fi

# Add deno completions to search path
if [[ ":$FPATH:" != *":$HOME/completions:"* ]]; then export FPATH="$HOME/completions:$FPATH"; fi

# Debug mode
if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zmodload zsh/zprof
fi

# ============================================
# Shell options
# ============================================
setopt AUTO_CD              # Type directory name to cd into it (implicit cd)

# ============================================
# History
# ============================================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY

# ============================================
# Completions
# ============================================
autoload -Uz compinit
# Only regenerate compinit cache once a day
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# Menu selection
zstyle ':completion:*' menu select
# Colors in completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ============================================
# Key bindings
# ============================================
bindkey -e  # emacs mode
bindkey "\e\eOD" beginning-of-line
bindkey "\e\eOC" end-of-line

# ============================================
# Git helpers (replaces oh-my-zsh git plugin)
# ============================================
function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return

  # Try to get the default branch from remote's HEAD
  local remote_head=$(command git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null)
  if [[ -n "$remote_head" ]]; then
    echo ${remote_head##*/}
    return 0
  fi

  # Fallback: check common branch names
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,dev,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done
  echo master
}

# Directory navigation - AUTO_CD handles typing paths directly
# These aliases handle the common shorthand without trailing slash
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias -- -='cd -'

# Git aliases (the ones you actually use)
alias g='git'
alias ga='git add'
alias gc='git commit --verbose'
alias gcm='git checkout $(git_main_branch)'
alias gco='git checkout'
alias gd='git diff'
alias gst='git status'
alias gp='git push'
alias gl='git pull'

# ============================================
# Rails helpers (replaces oh-my-zsh rails plugin)
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

# ============================================
# Prompt (starship)
# ============================================
eval "$(starship init zsh)"

# ============================================
# Syntax highlighting (via brew - path hardcoded for speed)
# ============================================
if [[ "$IS_MACOS" == true ]]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ============================================
# Your custom config starts here
# ============================================

real_npx=$(which npx)
alias _npx="$real_npx"
alias npx="bunx"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias ci="code-insiders"
alias ci.="ci ."
alias cs="cursor"
alias cs.="cs ."

alias ll="eza -l --git --icons always"
alias n="open"
alias ga.="git add ."
alias lg="lazygit"

export EDITOR="vim"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

alias cd.='cd $(readlink -f .)' # Go to real dir (i.e. if current dir is linked)

alias be="bundle exec"
alias br="bundle exec" # not because of bundle run, but because I'm an idiot who can't type
alias r="bin/rails"
alias rr="r routes"
alias rrr="r routes | fzf"
alias rc="r c"
alias rs="r s"
alias lint="be rubocop"

# TODO: Warn me before committing if the last commit message is this
GIT_TMP_MESSAGE="THIS IS A TEMPORARY COMMIT, ROLL IT BACK"
alias gtmp="git commit -m '$GIT_TMP_MESSAGE'"
alias gtmpa="git add . && gtmp"
alias gs="echo \"You're dumb\"; gst"

check_tmp() {
  last_message=$(git log -1 --format=%s)

  if [[ $last_message = $GIT_TMP_MESSAGE && $SKIP_TMP_CHECK != '1' ]]; then
    echo "Your last commit was a TMP commit, check it out or rerun with SKIP_TMP_CHECK=1, i.e. 'SKIP_TMP_CHECK=1 !!'"
    exit 1
  fi
}

alias dc="docker compose"
alias dcup="docker compose up"
alias pr="gh pr view --web"
alias prcp="gh pr view --json 'url' | jq -r '.url' | pbcopy"
alias repo="gh repo view --web"
alias acts="gh pr checks -w"
function ocm() { open '$(git remote get-url origin | sed "s/git@github.com:/https:\/\/github.com\//" | sed "s/.git$//")/commit/$(git rev-parse HEAD)' }
function cmcp() { echo "$(git remote get-url origin | sed "s/git@github.com:/https:\/\/github.com\//" | sed "s/.git$//")/commit/$(git rev-parse HEAD)" | pbcopy }

alias ro="railway open"
alias fwd="readlink -f"

alias gu="git reset --soft HEAD~1"
alias grs="git restore --staged"
alias grs.="grs ."
alias glo="git pull origin"
alias gco.="git checkout ."
alias gco-="git checkout -"
function gpm() { git pull origin $(git_main_branch) }

function add_unless_staged() {
  if git diff --cached --quiet; then
    echo "No staged files. Adding all files..."
    git add .
  else
    echo "Only using staged files"
  fi
}

alias gtm="gt m"
function gtmm() {
  add_unless_staged
  gt m -c -m "$*"
}
function gcmm() {
  add_unless_staged
  gc -m "$*"
}
function gcob() {
  # Replace spaces in the commit message with dashes for the branch name
  local branch_name=$(echo "$*" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

  # Create a new branch
  git checkout -b "$branch_name"
}

alias yeetm="yeet" # yeet now supports message
alias gcmmp="yeetm"

alias gtco="gt co"
alias gtgo="gt add -A && gt continue"
alias gtss="gt ss"
alias gtup="gt up"
alias gtdn="gt down"
alias gtt="gt top"
alias gtc="gt c"

alias yeetpr="git push && gh pr create -a @me -f"
function yeet() {
  # if there is any git config with graphite then use graphite
  if [ -n "$(git config --list | grep graphite)" ]; then
    gt ss
  else
    add_unless_staged

    message="yolo"
    if [ -n "$*" ]; then
      message="$*"
    fi

    git commit -m "$message"

    git push
  fi
}
function yeetfix() {
  # if not args print error and exit
  if [ -z "$*" ]; then
    echo "Error: No arguments provided"
    return 1
  fi

  local commit_message=""
  local pr_body=""
  local body_flag="--body"
  local draft_flag="--draft"
  local is_draft=false

  # Check if ends with --draft flag
  if [[ $* == *"$draft_flag" ]]; then
    is_draft=true
    # Remove --draft from args
    local args="${*%$draft_flag}"
    args="${args%% }"
  else
    local args="$*"
  fi

  # Split the input at --body
  if [[ $args == *"$body_flag"* ]]; then
    # Get everything before --body for commit message
    commit_message="${${args%%$body_flag*}%% }"
    # Get everything after --body for PR body
    pr_body="${${args#*$body_flag}## }"
  else
    commit_message="$args"
  fi

  # Replace spaces in the commit message with dashes for the branch name
  local branch_name=$(echo "$commit_message" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

  # Create a new branch
  git checkout -b "$branch_name" "origin/$(git_main_branch)"

  # Add all changes and commit with the provided message
  # Check for staged files
  if git diff --cached --quiet; then
    # No staged files
    echo "No staged files. Adding all files..."
    git add .
  else
    # There are staged files
    echo "Only using staged files"
  fi

  git commit -m "$commit_message"

  # Push the branch to origin
  git push -u origin "$branch_name"

  # Open a PR on GitHub, using either --fill or the provided body
  local pr_args=("--assignee" "@me")

  if [ "$is_draft" = true ]; then
    pr_args+=("--draft")
  fi

  if [ -n "$pr_body" ]; then
    # Use provided body
    local out=$(gh pr create "${pr_args[@]}" --title "$commit_message" --body "$pr_body")
  else
    # Use --fill if no body provided
    local out=$(gh pr create "${pr_args[@]}" --fill)
  fi

  # Copy the PR URL to the clipboard
  echo "$out" | tail -n 1 | pbcopy

  echo "Branch '$branch_name' created, changes committed, and PR opened with message: '$commit_message' and copied to clipboard"
}

yeetrepo() {
  local repo_name=""
  local private_flag="--public"

  # Check for the first argument
  if [[ $# -gt 0 ]]; then
    if [[ $1 == "--private" ]]; then
      private_flag="--private"
    else
      repo_name="$1"
    fi
  fi

  # If --private was passed, shift arguments to check for additional repo name
  if [[ $private_flag == "--private" ]]; then
    if [[ $# -gt 1 ]]; then
      repo_name="$2"
    fi
  fi

  # Build the gh repo create command
  local command=("gh" "repo" "create")

  if [[ -n $repo_name ]]; then
    command+=("$repo_name")
  fi

  command+=("--push" "--source" "." "$private_flag")

  # Remove empty params from command array
  command=("${command[@]/#/}")

  # Execute the command
  "${command[@]}"
}

alias ocd="OVERCOMMIT_DISABLE=1"

alias aliases="alias | sed 's/=.*//'"
alias paths='echo -e ${PATH//:/\\n}'

function cdgr() { cd "$(git rev-parse --show-toplevel)" } # https://x.com/anthonysheww/status/1923346656205926722

# Git worktree helpers
# gwc: Create a new worktree in worktree-<repo>/<branch-name>
# Usage: gwc <branch-name> [--no-cd]
function gwc() {
  local branch_name=""
  local no_cd=false

  # Parse arguments
  for arg in "$@"; do
    if [[ "$arg" == "--no-cd" ]]; then
      no_cd=true
    elif [[ -z "$branch_name" ]]; then
      branch_name="$arg"
    fi
  done

  # Check if branch name provided
  if [[ -z "$branch_name" ]]; then
    echo "Usage: gwc <branch-name> [--no-cd]"
    echo "  Creates a new git worktree in worktree-<repo>/<branch-name>"
    echo "  --no-cd: Don't change to the new worktree directory"
    return 1
  fi

  # Get the git root directory
  local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$git_root" ]]; then
    echo "Error: Not in a git repository"
    return 1
  fi

  local repo_name=$(basename "$git_root")
  local worktree_base=""

  # Check if we're already inside a worktree-<repo> directory
  local current_dir=$(pwd)
  local parent_dir=$(dirname "$current_dir")
  local grandparent_dir=$(dirname "$parent_dir")

  if [[ "$(basename "$parent_dir")" == worktree-* ]]; then
    # We're in worktree-<repo>/<some-branch>, use parent as base
    worktree_base="$parent_dir"
  elif [[ "$(basename "$grandparent_dir")" == worktree-* ]]; then
    # We're deeper in a worktree, use grandparent
    worktree_base="$grandparent_dir"
  else
    # We're in the main repo, create worktree-<repo> next to it
    worktree_base="$(dirname "$git_root")/worktree-$repo_name"
  fi

  local worktree_path="$worktree_base/$branch_name"

  # Create worktree base directory if it doesn't exist
  if [[ ! -d "$worktree_base" ]]; then
    echo "Creating worktree directory: $worktree_base"
    mkdir -p "$worktree_base"
  fi

  # Check if worktree already exists
  if [[ -d "$worktree_path" ]]; then
    echo "Error: Worktree already exists at $worktree_path"
    return 1
  fi

  # Create the worktree with a new branch
  echo "Creating worktree at $worktree_path with branch $branch_name..."
  git worktree add -b "$branch_name" "$worktree_path"

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create worktree"
    return 1
  fi

  # Run mise trust in the new worktree
  echo "Running mise trust..."
  (cd "$worktree_path" && mise trust 2>/dev/null)

  # CD into the new worktree unless --no-cd was passed
  if [[ "$no_cd" == false ]]; then
    echo "Changing to $worktree_path"
    cd "$worktree_path"
  else
    echo "Worktree created at: $worktree_path"
  fi
}

# gwd: Delete the current worktree (must be run from within a worktree)
# Usage: gwd [-f|--force]
function gwd() {
  local force=false
  if [[ "$1" == "-f" || "$1" == "--force" ]]; then
    force=true
  fi

  local current_dir=$(pwd)
  local dir_name=$(basename "$current_dir")
  local parent_dir=$(dirname "$current_dir")
  local parent_name=$(basename "$parent_dir")

  # Check if we're in a worktree-<repo>/<branch> structure
  if [[ "$parent_name" != worktree-* ]]; then
    echo "Error: Not in a worktree directory"
    echo "Expected to be in worktree-<repo>/<branch-name>"
    return 1
  fi

  # Verify this is actually a git worktree
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "Error: Not in a git repository"
    return 1
  fi

  local branch_name=$(git rev-parse --abbrev-ref HEAD)

  # Confirm deletion
  if [[ "$force" == false ]]; then
    echo "This will remove:"
    echo "  - Worktree: $current_dir"
    echo "  - Branch: $branch_name"
    echo ""
    read -q "REPLY?Are you sure? (y/N) "
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Aborted."
      return 0
    fi
  fi

  # Move to parent directory first
  cd "$parent_dir"

  # Remove the worktree
  echo "Removing worktree..."
  git worktree remove "$current_dir" --force

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to remove worktree"
    return 1
  fi

  # Delete the branch
  echo "Deleting branch $branch_name..."
  git branch -D "$branch_name" 2>/dev/null

  echo "Done! Worktree and branch removed."
}

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env

eval "$(atuin init zsh)"

alias reload="source ~/.zshrc"
alias reload!="cp ~/repos/configs/zshrc ~/.zshrc && reload"

local real_rm=$(which rm)
alias _rm="$real_rm"

# Safe rm function that uses trash instead of permanent deletion
function rm() {
  # Get the real rm command path
  local real_rm=$(which rm)

  # Check if trash command exists
  if ! command -v trash &> /dev/null; then
    echo "Warning: 'trash' command not found. Install it with 'brew install trash' or use 'realrm' for permanent deletion."
    return 1
  fi

  # Check if -f flag is present (force, ignore non-existent files)
  local force_flag=false
  local files=()

  for arg in "$@"; do
    # Check if this is a flag (starting with -)
    if [[ "$arg" =~ ^- ]]; then
      # Check if -f is in the flags (could be -f, -rf, -fr, -Rf, etc.)
      if [[ "$arg" =~ f ]]; then
        force_flag=true
      fi
      # Skip all flags (we're just using them to determine behavior)
    else
      # This is a file/directory argument
      files+=("$arg")
    fi
  done

  # If no files were provided after filtering, show usage
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No files or directories specified"
    return 1
  fi

  # If -f flag is present, filter out non-existent files
  if [[ "$force_flag" == true ]]; then
    local existing_files=()
    for file in "${files[@]}"; do
      if [[ -e "$file" ]]; then
        existing_files+=("$file")
      fi
    done
    files=("${existing_files[@]}")

    # If no files exist after filtering, silently succeed (like rm -f does)
    if [[ ${#files[@]} -eq 0 ]]; then
      return 0
    fi
  fi

  # Use trash for the filtered file arguments
  trash "${files[@]}"
}

# Alias for the real rm command when you need permanent deletion
alias realrm="$(which rm)"

export HOMEBREW_BUNDLE_FILE_GLOBAL="~/repos/configs/Brewfile"
alias rebrew="brew bundle install --global"

alias ca="cursor-agent"
alias vfz='vim $(fzf)'

# Restored aliases
alias fmns='foreman start'
alias rfind='find . -name "*.rb" | xargs grep -n'
alias rserver='ruby -run -e httpd . -p 8080'
alias sstat='thin --stats "/thin/stats" start'
alias cc='claude --allow-dangerously-skip-permissions'
alias ff='fastfetch'
alias oc='opencode'
alias zed.='zed .'

alias rs="rails s"
alias rc="rails c"

notif() {
    # Save the command as a string
    local cmd="$*"

    # Run the command passed to the function
    "$@"  # This runs the command you provide as an argument

    # Check the exit status of the command
    if [ $? -eq 0 ]; then
        osascript -e "display notification \"Task completed successfully: $cmd\" with title \"Notification\""
    else
        osascript -e "display notification \"Task failed: $cmd\" with title \"Notification\""
    fi
}

# kamal override for local in repo + make it work with fig autocomplete
kamal() {
    if [[ -x "./bin/kamal" ]]; then
        "./bin/kamal" "$@"
    else
        command kamal "$@"
    fi
}

export OP_ACCOUNT=unidygmbh.1password.com

function lt() {
  eza --tree --level=2 --long --icons --git --ignore-glob="node_modules|.git|vendor" $argv
}

. "$HOME/.cargo/env"

if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zprof
fi

eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Kiro CLI post - disabled (slows down new tabs significantly)
# if [[ "$IS_MACOS" == true ]] && [[ -x ~/.local/bin/kiro-cli ]]; then
#   eval "$(~/.local/bin/kiro-cli init zsh post --rcfile zshrc)"
# fi
