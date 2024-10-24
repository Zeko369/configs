# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="candy"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(rails git ruby zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

eval "$(fnm env --use-on-cd)"
real_npx=$(which npx)
alias _npx="$real_npx"
alias npx="bunx"

# bun completions
[ -s "/Users/franzekan/.bun/_bun" ] && source "/Users/franzekan/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias ci="code-insiders"
alias ci.="ci ."
alias cs="cursor"
alias cs.="cs ."

eval "$(rbenv init - zsh)"

alias ll="eza -l --git --icons"
alias n="open"
alias ga.="git add ."

export EDITOR="vim"

bindkey "\e\eOD" beginning-of-line
bindkey "\e\eOC" end-of-line

# pnpm
export PNPM_HOME="/Users/franzekan/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
#
alias cd.='cd $(readlink -f .)' # Go to real dir (i.e. if current dir is linked)

alias be="bundle exec"
alias r="bin/rails"
alias rr="r routes"
alias rrr="r routes | fzf"
alias rc="r c"
alias rs="r s"

# TODO: Warn me before commiting if the last commit message is this
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
alias pr="gh pr view --web"
alias prcp="gh pr view --json 'url' | jq -r '.url' | pbcopy"
alias repo="gh repo view --web"
alias ocm='open "$(git remote get-url origin | sed "s/git@github.com:/https:\/\/github.com\//" | sed "s/.git$//")/commit/$(git rev-parse HEAD)"'

alias ro="railway open"
alias fwd="readlink -f"

alias gu="git reset --soft HEAD~1"
alias grs="git restore --staged"
alias grs.="grs ."
alias glo="git pull origin"
alias gcb="git checkout -b "
alias gco.="git checkout ."
alias gco-="git checkout -"
alias gpm="git pull origin $(git_main_branch)"

alias gtm="gt m"
function gtmm() { gt m -c -m "$*" }
function gcmm() {
  if git diff --cached --quiet; then
    echo "No staged files. Adding all files..."
    git add .
  else
    echo "Only using staged files"
  fi

  gc -m "$*"
}

alias gtco="gt co"
alias gtgo="gt add -A && gt continue"
alias gtss="gt ss"
alias gtup="gt up"
alias gtdn="gt down"
alias gtt="gt top"

alias yeet="gt ss"
alias yeetpr="git push && gh pr create -a @me -f"
yeetfix() {
  # Merge all arguments into a single string with spaces
  local commit_message="$*"
  # Replace spaces in the commit message with dashes for the branch name
  local branch_name=$(echo "$*" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

  # Create a new branch
  git checkout -b "$branch_name"

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

  # Open a PR on GitHub, assigning @me and using -f to fill the PR description
  local out=$(gh pr create --fill --assignee "@me")

  # Copy the PR URL to the clipboard
  echo "$out" | tail -n 1 | pbcopy

  echo "Branch '$branch_name' created, changes committed, and PR opened with message: '$commit_message' and copied to clipboard"
}

alias ocd="OVERCOMMIT_DISABLE=1"

alias aliases="alias | sed 's/=.*//'"
alias paths='echo -e ${PATH//:/\\n}'


[ -f "/Users/franzekan/.ghcup/env" ] && source "/Users/franzekan/.ghcup/env" # ghcup-env

source "$HOME/.rye/env"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

eval "$(atuin init zsh)"

function lt() {
  eza --tree --level=2 --long --icons --git --ignore-glob="node_modules|.git|vendor" $argv
}

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"

. "$HOME/.cargo/env"
