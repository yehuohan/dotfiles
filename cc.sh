#!/bin/bash

# copy all the <config-files> to <cf-dir>
# cd to LinuxConfigs before execute this file.
# this file must be in "~/dotconfigs/"



if [ `uname` == "Linux" ]; then

    if [[ $(cd `dirname "$0"`;pwd) != ~/dotconfigs ]]; then
        echo 'Is Not in ~/dotconfigs'
        exit
    fi

    if [[ `uname -r` =~ "lts" ]]; then
        cf_dir="cf-arch"

        # vim
        cp ../.vimrc                  ./vim/
        cp ../.vim/.ycm_extra_conf.py ./vim/
        cp ../.vim/.tern-project      ./vim/
        cp -r ../.vim/mySnippets      ./vim/
        cp -r ../.vim/autoload        ./vim/
        cp -r ../.config/nvim         ./vim/

        # zsh
        cp ../.zshrc                $cf_dir/
        cp ../.zprofile             $cf_dir/
        cp ../.Xmodmap              $cf_dir/
        cp ../.Xresources           $cf_dir/
        cp ../.gitconfig            $cf_dir/
        cp ../.xinitrc              $cf_dir/
        cp ../.nvidia-xinitrc       $cf_dir/
        cp ../.inputrc              $cf_dir/
        # .config
        cp -r ../.config/i3         $cf_dir/.config/
        cp -r ../.config/i3status   $cf_dir/.config/
        cp -r ../.config/rofi       $cf_dir/.config/
        # tmux
        cp ../.tmux.conf            $cf_dir/
        cp ../.tmux-status.conf     $cf_dir/
        # ect
        cp /etc/X11/xorg.conf                       $cf_dir/etc/X11/
        cp /etc/X11/xorg.conf.d/30-touchpad.conf    $cf_dir/etc/X11/xorg.conf.d
        cp /etc/X11/nvidia-xorg.conf                $cf_dir/etc/X11/
        cp -r /etc/X11/nvidia-xorg.conf.d           $cf_dir/etc/X11/
        cp /etc/systemd/logind.conf                 $cf_dir/etc/systemd/
        cp /etc/pacman.conf                         $cf_dir/etc/
        cp -r /etc/modprobe.d                       $cf_dir/etc/
        cp -r /etc/modules-load.d                   $cf_dir/etc/

        # misc
        cp ../my-apps/ToggleTouchPad.py ./misc/

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
        cp -r ../.config/nvim         ./vim/

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

    # vim
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
    cp ~/.minttyrc  ./cf-gw/
    cp ~/.gitconfig ./cf-gw/
    cp ~/.zshrc     ./cf-gw/

    echo "Msys: Copy was completed!"
fi

