#!/bin/bash

# cd to <dotfiles> first before execute this file;
# this file must be in '~/dotfiles/'.

if [[ `uname` == "Linux" ]]; then

    if [[ $(cd `dirname "$0"`;pwd) != ~/dotfiles ]]; then
        echo 'Is NOT in ~/dotfiles'
        exit
    fi

    # vim & neovim
    cp -r ~/dotvim/autoload                         ./vim/dotvim/
    cp -r ~/dotvim/init                             ./vim/dotvim/
    cp -r ~/dotvim/share                            ./vim/dotvim/
    cp ~/.config/nvim/init.lua                      ./vim/nvim/
    #cp ~/.config/nvim/init.vim                      ./vim/nvim/
    # zsh
    cp ~/.zshrc                                     ./root/home/
    cp ~/.zprofile                                  ./root/home/
    cp ~/.Xmodmap                                   ./root/home/
    cp ~/.tmux.conf                                 ./root/home/
    cp ~/.tmux-status.conf                          ./root/home/
    cp ~/.gitconfig                                 ./root/home/
    cp ~/.gdbinit                                   ./root/home/
    # config
    cp ~/.config/user-dirs.dirs                     ./root/home/.config/
    cp -r ~/.config/i3                              ./root/home/.config/
    cp -r ~/.config/i3status                        ./root/home/.config/
    cp -r ~/.config/rofi                            ./root/home/.config/
    cp -r ~/.config/fontconfig                      ./root/home/.config/
    cp ~/.config/lf/lfrc                            ./root/home/.config/lf/
    cp ~/.cargo/config                              ./root/home/.cargo/
    cp ~/.pip/pip.conf                              ./root/home/.pip/

    ## Arch
    if [[ `uname -r` =~ "arch" ]]; then
        # home/.config
        cp ~/.config/xfce4/terminal/terminalrc      ./root/home/.config/xfce4/terminal/
        cp ~/.config/alacritty/alacritty.toml       ./root/home/.config/alacritty/
        # X11
        cp ~/.Xresources                            ./root/home-arch/
        cp ~/.xinitrc                               ./root/home-arch/
        cp ~/.nvidia-xinitrc                        ./root/home-arch/
        cp ~/.inputrc                               ./root/home-arch/
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
        cp ~/.config/libinput-gestures.conf         ./root/home/.config/

        echo "Ubuntu: Copy was completed!"
    fi

elif [[ `uname -o` == "Msys" || `uname -o` == "Cygwin" ]]; then

    if [ ! -d "$APPS_HOME/dotvim" ]; then
        echo "$APPS_HOME/dotvim is not existed."
        exit
    fi

    # vim & neovim
    cp -r $APPS_HOME/dotvim/autoload                ./vim/dotvim/
    cp -r $APPS_HOME/dotvim/init                    ./vim/dotvim/
    cp -r $APPS_HOME/dotvim/share                   ./vim/dotvim/
    cp $LOCALAPPDATA/nvim/init.lua                  ./vim/nvim/
    #cp $LOCALAPPDATA/nvim/init.vim                  ./vim/nvim/

    # gw
    cp $APPS_HOME/msys64/ucrt64.ini                         ./disk/msys2/
    cp $APPS_HOME/msys64/etc/pacman.conf                    ./disk/msys2/etc/
    cp $APPS_HOME/msys64/etc/pacman.d/mirrorlist.msys       ./disk/msys2/etc/pacman.d
    cp $APPS_HOME/msys64/etc/pacman.d/mirrorlist.mingw32    ./disk/msys2/etc/pacman.d
    cp $APPS_HOME/msys64/etc/pacman.d/mirrorlist.mingw64    ./disk/msys2/etc/pacman.d
    cp $APPS_HOME/msys64/etc/pacman.d/mirrorlist.ucrt64     ./disk/msys2/etc/pacman.d
    cp ~/.minttyrc                                          ./disk/msys2/home/
    cp ~/.gitconfig                                         ./disk/msys2/home/
    cp ~/.zshrc                                             ./disk/msys2/home/
    cp ~/.tmux.conf                                         ./disk/msys2/home/
    cp ~/.tmux-status.conf                                  ./disk/msys2/home/

    # win
    cp $USERPROFILE/.cargo/config                   ./disk/home/.cargo/
    cp $USERPROFILE/pip/pip.ini                     ./disk/home/pip/
    cp $USERPROFILE/clink_inputrc                   ./disk/home/
    cp -r $USERPROFILE/Documents/WindowsPowerShell  ./disk/home/Documents/
    cp $LOCALAPPDATA/lf/lfrc                        ./disk/home/AppData/Local/lf/

    # scoop
    cp -r $APPS_HOME/_packs/persist/conemu          ./disk/scoop/

    echo "Gw: Copy was completed!"
fi
