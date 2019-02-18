# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/fran/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="candy"
ZSH_THEME="jispwoso"
# ZSH_THEME="strug"
#
# ZSH_THEME="pygmalion"
# ZSH_THEME="agnoster"
# ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

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

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# function mdc() {
#     mkdir -p "$@" && cd "$@"
# }

# alias ll='ls -l'
alias ll='exa --long --header --git'
alias la='exa --long --header --git -a'

alias fuck='sudo'
# alias idle='idle3'
alias quit='exit'

# if [[ ! $TERM =~ screen ]]; then	##dummer version of the code bellow
	    # exec tmux
# fi

# if [[ $TERM == xterm ]]; then TERM=xterm-256color; fi

# alias tmuxReboot="tmux source-file ~/.tmux.conf"

export TERM="screen-256color"
export TERM="xterm-256color"
alias tmux="tmux -2";
export PATH=$PATH:~/.vimpkg/bin

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# alias h="builtin cd"

# function cd {
#     builtin cd "$@" && ls -l
#     }

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# compctl -g '~/.itermocil/*(:t:r)' itermocil

eval "$(rbenv init -)"

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

alias code="code-insiders"

alias todo="vim todo"

alias up="python -m SimpleHTTPServer 8000"
alias upp="php -S 0.0.0.0:8080"

export PATH=$HOME/circuitmess/esp/xtensa-esp32-elf/bin:$PATH
alias get_esp32="export PATH=$HOME/circuitmess/esp/xtensa-esp32-elf/bin:$PATH"

export PATH=$PATH:~/.platformio/penv/bin

autoload bashcompinit && bashcompinit
eval "$(_PLATFORMIO_COMPLETE=source platformio)"
eval "$(_PIO_COMPLETE=source pio)"

alias iterm="open /Applications/iTerm.app"
