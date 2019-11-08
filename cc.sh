#!/bin/bash

# copy all the <config-files> to <cf-home>
# cd to LinuxConfigs before execute this file.
# this file must be in "~/dotconfigs/"



if [ `uname` == "Linux" ]; then

    if [[ $(cd `dirname "$0"`;pwd) != ~/dotconfigs ]]; then
        echo 'Is Not in ~/dotconfigs'
        exit
    fi

    # vim
    cp ../.vimrc                    ./vim/
    cp ../.vim/.ycm_extra_conf.py   ./vim/
    cp ../.vim/jsconfig.json        ./vim/
    cp -r ../.vim/vSnippets         ./vim/
    cp -r ../.vim/autoload          ./vim/
    cp -r ../.config/nvim           ./vim/
    # zsh
    cp ../.zshrc                    ./root/home/
    cp ../.zprofile                 ./root/home/
    cp ../.Xmodmap                  ./root/home/
    cp ../.gitconfig                ./root/home/
    # .config
    cp -r ../.config/i3             ./root/home/.config/
    cp -r ../.config/i3status       ./root/home/.config/
    cp -r ../.config/rofi           ./root/home/.config/
    # tmux
    cp ../.tmux.conf                ./root/home/
    cp ../.tmux-status.conf         ./root/home/
    # misc
    cp ../my-apps/ToggleTouchPad.py ./misc/

    # Arch
    if [[ `uname -r` =~ "lts" ]]; then
        # X11
        cp ../.Xresources           ./root/home-arch/
        cp ../.xinitrc              ./root/home-arch/
        cp ../.nvidia-xinitrc       ./root/home-arch/
        cp ../.inputrc              ./root/home-arch/
        cp /etc/X11/xorg.conf                       ./root/etc-arch/X11/
        cp /etc/X11/xorg.conf.d/30-touchpad.conf    ./root/etc-arch/X11/xorg.conf.d
        cp /etc/X11/nvidia-xorg.conf                ./root/etc-arch/X11/
        cp -r /etc/X11/nvidia-xorg.conf.d           ./root/etc-arch/X11/
        # systemd
        cp /etc/systemd/logind.conf ./root/etc-arch/systemd/
        # pacman
        cp /etc/pacman.conf         ./root/etc-arch/
        # modules
        cp -r /etc/modprobe.d       ./root/etc-arch/
        cp -r /etc/modules-load.d   ./root/etc-arch/

        echo "Arch: Copy was completed!"
    fi

    # Ubuntu
    if [[ `uname -v` =~ "Ubuntu" ]]; then
        # home/.config
        cp ../.config/libinput-gestures.conf    ./root/home-ubuntu/.config/
        cp ../.config/user-dirs.dirs            ./root/home-ubuntu/.config/

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
    cp ../Vim/vimfiles/jsconfig.json      ./vim/
    cp -r ../Vim/vimfiles/vSnippets       ./vim/
    cp -r ../Vim/vimfiles/vBin            ./vim/
    cp -r ../Vim/vimfiles/autoload        ./vim/

    # cf-msys2
    cp ~/.minttyrc      ./root/home-gw/
    cp ~/.gitconfig     ./root/home-gw/
    cp ~/.zshrc         ./root/home-gw/
    cp /msys2_shell.cmd ./root/home-gw/

    echo "Msys: Copy was completed!"
fi

