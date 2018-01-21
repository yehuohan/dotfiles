#!/bin/bash

# copy all the <config-files> to <cf-dir>
# cd to LinuxConfigs before execute this file.
# this file must be in "~/LinuxConfigs/"

if [ `uname` == "Linux" ]; then

    if [[ $(cd `dirname "$0"`;pwd) != ~/LinuxConfigs ]]; then
        echo 'Is Not in ~/LinuxConfigs'
        exit
    fi

    # cf-vim
    cp ../.vimrc                  ./cf-vim/
    cp ../.vim/.ycm_extra_conf.py ./cf-vim/
    cp ../.vim/.tern-project      ./cf-vim/
    cp ../.vim/mySnippets/*       ./cf-vim/mySnippets/
    cp ../.vim/autoload/*         ./cf-vim/autoload/

    # cf-zsh
    cp ../.zshrc      ./cf-zsh/
    cp ../.zprofile   ./cf-zsh/
    cp ../.Xmodmap    ./cf-zsh/
    cp ../.Xresources ./cf-zsh/
    cp ../.gitconfig  ./cf-zsh/
    cp ../.xinitrc    ./cf-zsh/

    # cf-i3
    cp ../.config/i3/*             ./cf-i3/i3/
    cp ../.config/i3status/config  ./cf-i3/i3status/

    # cf-tmux
    cp ../.tmux.conf        ./cf-tmux/
    cp ../.tmux-status.conf ./cf-tmux/

    # cf-misc
    cp ../MyApps/ToggleTouchPad.py ./misc/

    echo "Linux: Copy configs was completed!"

elif [ `uname -o` == "Msys" ]; then

    # cf-vim
    if [ ! -d "../Vim" ]; then
        echo "../Vim is not existed."
        exit
    fi
    cp ../Vim/_vimrc                      ./cf-vim/.vimrc
    cp ../Vim/vimfiles/.ycm_extra_conf.py ./cf-vim/
    cp ../Vim/vimfiles/.tern-project      ./cf-vim/
    cp -r ../Vim/vimfiles/mySnippets/     ./cf-vim/
    cp -r ../Vim/vimfiles/autoload/*.vim  ./cf-vim/autoload/

    # cf-msys2
    cp ~/.minttyrc  ./cf-msys2/
    cp ~/.gitconfig ./cf-msys2/
    cp ~/.zshrc     ./cf-msys2/

    echo "Msys: Copy configs was completed!"

fi

