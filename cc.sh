#!/bin/bash

# copy all the <config-files> to <cf-dir>
# cd to LinuxConfigs before execute this file.
# this file must be in "~/dotconfigs/"



if [ `uname` == "Linux" ]; then

    if [[ $(cd `dirname "$0"`;pwd) != ~/dotconfigs ]]; then
        echo 'Is Not in ~/dotconfigs'
        exit
    fi

    if [[ `uname -r` =~ "ARCH" ]]; then
        cf_dir="cf-arch"

        # vim
        cp ../.vimrc                  ./vim/
        cp ../.vim/.ycm_extra_conf.py ./vim/
        cp ../.vim/.tern-project      ./vim/
        cp -r ../.vim/mySnippets      ./vim/
        cp -r ../.vim/autoload        ./vim/

        # arch config
        # zsh
        cp ../.zshrc                $cf_dir/
        cp ../.zprofile             $cf_dir/
        cp ../.Xmodmap              $cf_dir/
        cp ../.Xresources           $cf_dir/
        cp ../.gitconfig            $cf_dir/
        cp ../.xinitrc              $cf_dir/
        # .config
        cp -r ../.config/i3         $cf_dir/.config/
        cp -r ../.config/i3status   $cf_dir/.config/
        cp -r ../.config/rofi       $cf_dir/.config/
        cp -r ../.config/libinput-gestures.conf     $cf_dir/.config/
        # tmux
        cp ../.tmux.conf            $cf_dir/
        cp ../.tmux-status.conf     $cf_dir/
        # ect
        cp /etc/X11/xorg.conf       $cf_dir/etc/X11/

        # misc
        cp ../my-apps/ToggleTouchPad.py ./misc/
        #cp /etc/sddm.conf               ./misc/sddm/

        echo "Arch: Copy was completed!"
    fi

    if [[ `uname -v` =~ "Ubuntu" ]]; then
        cf_dir="cf-ubuntu"

        # vim
        cp ../.vimrc                  ./vim/
        cp ../.vim/.ycm_extra_conf.py ./vim/
        cp ../.vim/.tern-project      ./vim/
        cp -r ../.vim/mySnippets      ./vim/
        cp -r ../.vim/autoload        ./vim/

        # arch config
        # zsh
        cp ../.zshrc                $cf_dir/
        cp ../.zprofile             $cf_dir/
        cp ../.Xmodmap              $cf_dir/
        cp ../.gitconfig            $cf_dir/
        # .config
        cp -r ../.config/i3         $cf_dir/.config/
        cp -r ../.config/i3status   $cf_dir/.config/
        cp -r ../.config/rofi       $cf_dir/.config/
        cp ../.config/libinput-gestures.conf    $cf_dir/.config/
        cp ../.config/user-dirs.dirs            $cf_dir/.config/
        # tmux
        #cp ../.tmux.conf            $cf_dir/
        #cp ../.tmux-status.conf     $cf_dir/

        # misc
        cp ../my-apps/ToggleTouchPad.py ./misc/

        echo "Ubuntu: Copy was completed!"
    fi

elif [ `uname -o` == "Msys" ]; then

    # cf-vim
    if [ ! -d "../Vim" ]; then
        echo "../Vim is not existed."
        exit
    fi
    cp ../Vim/_vimrc                      ./vim/.vimrc
    cp ../Vim/vimfiles/.ycm_extra_conf.py ./vim/
    cp ../Vim/vimfiles/.tern-project      ./vim/
    cp -r ../Vim/vimfiles/mySnippets      ./vim/
    cp -r ../Vim/vimfiles/autoload        ./vim/

    # cf-msys2
    cp ~/.minttyrc  ./cf-msys2/
    cp ~/.gitconfig ./cf-msys2/
    cp ~/.zshrc     ./cf-msys2/

    echo "Msys: Copy was completed!"
fi

