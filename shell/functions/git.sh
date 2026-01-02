# Git aliases and functions

# ============================================
# Basic git aliases
# ============================================
alias g='git'
alias ga='git add'
alias ga.='git add .'
alias gc='git commit --verbose'
alias gcm='git checkout $(git_main_branch)'
alias gco='git checkout'
alias gco.='git checkout .'
alias gco-='git checkout -'
alias gd='git diff'
alias gst='git status'
alias gp='git push'
alias gl='git pull'
alias glo='git pull origin'
alias gu='git reset --soft HEAD~1'
alias grs='git restore --staged'
alias grs.='grs .'
alias gs='echo "You'\''re dumb"; gst'
alias lg='lazygit'

# GitHub CLI
alias pr='gh pr view --web'
alias prcp='gh pr view --json '\''url'\'' | jq -r '\''.url'\'' | pbcopy'
alias repo='gh repo view --web'
alias acts='gh pr checks -w'
alias gcopr='gh pr checkout'

# ============================================
# Temporary commits
# ============================================
GIT_TMP_MESSAGE="THIS IS A TEMPORARY COMMIT, ROLL IT BACK"
alias gtmp='git commit -m "$GIT_TMP_MESSAGE"'
alias gtmpa='git add . && gtmp'

check_tmp() {
  last_message=$(git log -1 --format=%s)
  if [[ $last_message = $GIT_TMP_MESSAGE && $SKIP_TMP_CHECK != '1' ]]; then
    echo "Your last commit was a TMP commit, check it out or rerun with SKIP_TMP_CHECK=1, i.e. 'SKIP_TMP_CHECK=1 !!'"
    exit 1
  fi
}

# ============================================
# Graphite aliases
# ============================================
alias gtm='gt m'
alias gtco='gt co'
alias gtgo='gt add -A && gt continue'
alias gtss='gt ss'
alias gtup='gt up'
alias gtdn='gt down'
alias gtt='gt top'
alias gtc='gt c'

# ============================================
# Helper functions
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

function gpm() { git pull origin $(git_main_branch) }

function cdgr() { cd "$(git rev-parse --show-toplevel)" }

function ocm() { open "$(git remote get-url origin | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/.git$//')/commit/$(git rev-parse HEAD)" }

function cmcp() { echo "$(git remote get-url origin | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/.git$//')/commit/$(git rev-parse HEAD)" | pbcopy }

function add_unless_staged() {
  if git diff --cached --quiet; then
    echo "No staged files. Adding all files..."
    git add .
  else
    echo "Only using staged files"
  fi
}

function gtmm() {
  add_unless_staged
  gt m -c -m "$*"
}

function gcmm() {
  add_unless_staged
  gc -m "$*"
}

function gcob() {
  local branch_name=$(echo "$*" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
  git checkout -b "$branch_name"
}

# ============================================
# Yeet functions (quick commit/push/PR)
# ============================================
alias yeetm='yeet'
alias gcmmp='yeetm'
alias yeetpr='git push && gh pr create -a @me -f'

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
  if [ -z "$*" ]; then
    echo "Error: No arguments provided"
    return 1
  fi

  local commit_message=""
  local pr_body=""
  local body_flag="--body"
  local draft_flag="--draft"
  local is_draft=false

  if [[ $* == *"$draft_flag" ]]; then
    is_draft=true
    local args="${*%$draft_flag}"
    args="${args%% }"
  else
    local args="$*"
  fi

  if [[ $args == *"$body_flag"* ]]; then
    commit_message="${${args%%$body_flag*}%% }"
    pr_body="${${args#*$body_flag}## }"
  else
    commit_message="$args"
  fi

  local branch_name=$(echo "$commit_message" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

  git checkout -b "$branch_name" "origin/$(git_main_branch)"

  if git diff --cached --quiet; then
    echo "No staged files. Adding all files..."
    git add .
  else
    echo "Only using staged files"
  fi

  git commit -m "$commit_message"
  git push -u origin "$branch_name"

  local pr_args=("--assignee" "@me")

  if [ "$is_draft" = true ]; then
    pr_args+=("--draft")
  fi

  if [ -n "$pr_body" ]; then
    local out=$(gh pr create "${pr_args[@]}" --title "$commit_message" --body "$pr_body")
  else
    local out=$(gh pr create "${pr_args[@]}" --fill)
  fi

  echo "$out" | tail -n 1 | pbcopy

  echo "Branch '$branch_name' created, changes committed, and PR opened with message: '$commit_message' and copied to clipboard"
}

function yeetrepo() {
  local repo_name=""
  local private_flag="--public"

  if [[ $# -gt 0 ]]; then
    if [[ $1 == "--private" ]]; then
      private_flag="--private"
    else
      repo_name="$1"
    fi
  fi

  if [[ $private_flag == "--private" ]]; then
    if [[ $# -gt 1 ]]; then
      repo_name="$2"
    fi
  fi

  local command=("gh" "repo" "create")

  if [[ -n $repo_name ]]; then
    command+=("$repo_name")
  fi

  command+=("--push" "--source" "." "$private_flag")
  command=("${command[@]/#/}")

  "${command[@]}"
}
