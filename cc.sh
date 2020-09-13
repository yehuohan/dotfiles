#!/bin/bash

# copy all the config files to <root>;
# cd to <dotconfigs> first before execute this file;
# this file must be in '~/dotconfigs/'.

if [[ `uname` == "Linux" ]]; then

    if [[ $(cd `dirname "$0"`;pwd) != ~/dotconfigs ]]; then
        echo 'Is Not in ~/dotconfigs'
        exit
    fi

    # vim
    cp ../.vim/.init.vim                            ./vim/.vim/
    cp ../.vim/.ycm_extra_conf.py                   ./vim/.vim/
    cp ../.vim/.vimspector.json                     ./vim/.vim/
    cp ../.vim/coc-settings.json                    ./vim/.vim/
    cp -r ../.vim/snips                             ./vim/.vim/
    cp -r ../.vim/autoload                          ./vim/.vim/
    cp -r ../.vim/rplugin                           ./vim/.vim/
    cp -r ../.vim/pythonx                           ./vim/.vim/
    cp ../.config/nvim/init.vim                     ./vim/nvim/
    # zsh
    cp ../.zshrc                                    ./root/home/
    cp ../.zprofile                                 ./root/home/
    cp ../.Xmodmap                                  ./root/home/
    cp ../.gitconfig                                ./root/home/
    cp ../.gdbinit                                  ./root/home/
    # .config
    cp ../.config/user-dirs.dirs                    ./root/home/.config/
    cp -r ../.config/i3                             ./root/home/.config/
    cp -r ../.config/i3status                       ./root/home/.config/
    cp -r ../.config/rofi                           ./root/home/.config/
    cp -r ../.config/fontconfig                     ./root/home/.config/
    # tmux
    cp ../.tmux.conf                                ./root/home/
    cp ../.tmux-status.conf                         ./root/home/
    # misc
    cp ../uapps/ToggleTouchPad.py                   ./misc/

    ## Arch
    if [[ `uname -r` =~ "arch" ]]; then
        # home/.config
        cp ../.config/xfce4/terminal/terminalrc     ./root/home/.config/xfce4/terminal/
        # X11
        cp ../.Xresources                           ./root/home-arch/
        cp ../.xinitrc                              ./root/home-arch/
        cp ../.nvidia-xinitrc                       ./root/home-arch/
        cp ../.inputrc                              ./root/home-arch/
        cp /etc/X11/xorg.conf                       ./root/etc-arch/X11/
        cp /etc/X11/xorg.conf.d/30-touchpad.conf    ./root/etc-arch/X11/xorg.conf.d
        cp /etc/X11/nvidia-xorg.conf                ./root/etc-arch/X11/
        cp -r /etc/X11/nvidia-xorg.conf.d           ./root/etc-arch/X11/
        # systemd
        cp /etc/systemd/logind.conf                 ./root/etc-arch/systemd/
        cp /etc/systemd/system.conf                 ./root/etc-arch/systemd/
        # pacman
        cp /etc/pacman.conf                         ./root/etc-arch/
        # modules
        cp -r /etc/modprobe.d                       ./root/etc-arch/
        cp -r /etc/modules-load.d                   ./root/etc-arch/
        echo "Arch: Copy was completed!"
    fi

    # Ubuntu
    if [[ `uname -v` =~ "Ubuntu" ]]; then
        # home/.config
        cp ../.config/libinput-gestures.conf        ./root/home/.config/

        echo "Ubuntu: Copy was completed!"
    fi

elif [[ `uname -o` == "Msys" || `uname -o` == "Cygwin" ]]; then

    # vim & neovim
    if [ ! -d "../dotvim" ]; then
        echo "../dotvim is not existed."
        exit
    fi
    cp ../dotvim/.init.vim                          ./vim/.vim/
    cp ../dotvim/.ycm_extra_conf.py                 ./vim/.vim/
    cp ../dotvim/.vimspector.json                   ./vim/.vim/
    cp ../dotvim/coc-settings.json                  ./vim/.vim/
    cp -r ../dotvim/snips                           ./vim/.vim/
    cp -r ../dotvim/autoload                        ./vim/.vim/
    cp -r ../dotvim/rplugin                         ./vim/.vim/
    cp -r ../dotvim/pythonx                         ./vim/.vim/

    # cygwin
    cp ~/.minttyrc                                  ./root/home-gw/
    cp ~/.gitconfig                                 ./root/home-gw/
    cp ~/.zshrc                                     ./root/home-gw/
    cp ~/.tmux.conf                                 ./root/home-gw/
    cp ~/.tmux-status.conf                          ./root/home-gw/

    echo "Gw: Copy was completed!"
fi

