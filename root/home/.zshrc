# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH=~/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="alanpeabody"

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
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.


# 插件
#plugins=(git web-content)
plugins=(git)


source $ZSH/oh-my-zsh.sh


#===============================================================================
# User configuration
#===============================================================================

#键绑定, 设置 [DEL]键 为向后删除
#bindkey "\e[3~" delete-char
bindkey '^P' up-line-or-search
bindkey '^N' down-line-or-search

# ctrl+z 返回vim
fancy-ctrl-z () {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line
    else
        zle push-input
        zle clear-screen
    fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# man高亮
man() {
    env \
        LESS_TERMCAP_mb=$(printf "\e[1;31m") \
        LESS_TERMCAP_md=$(printf "\e[1;31m") \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[1;32m") \
            man "$@"
}

# 历史纪录条目数量
export HISTSIZE=10000

# 注销后保存的历史纪录条目数量
export SAVEHIST=10000

# 如果连续输入的命令相同，历史纪录中只保留一个
setopt HIST_IGNORE_DUPS

# 为历史纪录中的命令添加时间戳
setopt EXTENDED_HISTORY     

# 启用 cd 命令的历史纪录，cd -[TAB]进入历史路径
setopt AUTO_PUSHD

# 相同的历史路径只保留一个
setopt PUSHD_IGNORE_DUPS

#在命令前添加空格，不将此命令添加到纪录文件中
setopt HIST_IGNORE_SPACE

#扩展路径, /v/c/p/p => /var/cache/pacman/pkg
setopt complete_in_word

# pip zsh completion
function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip
compctl -K _pip_completion pip3

# alias
alias vim=nvim
alias vi=nvim
alias qvim=nvim-qt
alias -s png=eog
alias -s jpg=eog
alias -s jpeg=eog
alias -s gif=eog
alias -s PNG=eog
alias -s JPG=eog
alias -s JPEG=eog
alias -s GIF=eog

alias gitstatus='git status'
alias gitadd='git add'
alias gitcommit='git commit'
alias gitdiff='git diff'
alias giticdiff='git icdiff'
alias gitlog='git log'
alias gitpush='git push'
alias gitpull='git pull'
alias gitfetch='git fetch'

alias nxxx='nvidia-xrun'
alias xxx='startx'

alias ndkmake='ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=Android.mk NDK_APPLICATION_MK=Application.mk'

# auto program
clear
