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
# Add wisely, as too many plugins slow down shell startup.

# 插件
plugins=(git)

source $ZSH/oh-my-zsh.sh


#===============================================================================
# User configuration
#===============================================================================
# 历史纪录条目数量
export HISTSIZE=10000

# 注销后保存的历史纪录条目数量
export SAVEHIST=10000

# 如果连续输入的命令相同，历史纪录中只保留一个
setopt HIST_IGNORE_DUPS

# Ctrl-r搜索时不显重复的命令，即使不相邻
setopt HIST_FIND_NO_DUPS

# 为历史纪录中的命令添加时间戳
setopt EXTENDED_HISTORY     

# 启用 cd 命令的历史纪录，cd -[TAB]进入历史路径
setopt AUTO_PUSHD

# 相同的历史路径只保留一个
setopt PUSHD_IGNORE_DUPS

# 在命令前添加空格，不将此命令添加到纪录文件中
setopt HIST_IGNORE_SPACE

# 扩展路径, /v/c/p/p => /var/cache/pacman/pkg
setopt complete_in_word

# 移除ls的背景色
eval "$(dircolors -p | \
    sed 's/^OTHER_WRITABLE.*$/OTHER_WRITABLE 34;49/g' | \
    dircolors /dev/stdin)"

# 移除补全列表的背景色
autoload -Uz compinit
compinit
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

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
alias gitlog='git log'
alias gitpush='git push'
alias gitpull='git pull'
alias gitfetch='git fetch'
alias gityzal='lazygit'

alias nxxx='nvidia-xrun'
alias xxx='startx ~/.xinitrc'

# auto program
clear
