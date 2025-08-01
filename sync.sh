#!/bin/bash

# cd to <dotfiles> first before execute this file

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
    cp -r ~/.config/helix                           ./root/home/.config/
    cp ~/.config/lf/lfrc                            ./root/home/.config/lf/
    cp ~/.cargo/config                              ./root/home/.cargo/
    cp ~/.pip/pip.conf                              ./root/home/.pip/

    ## Arch
    if [[ `uname -r` =~ "arch" ]]; then
        # home/.config
        cp ~/.config/xfce4/terminal/terminalrc          ./root/home/.config/xfce4/terminal/
        cp ~/.config/alacritty/alacritty.toml           ./root/home/.config/alacritty/
        # X11
        cp ~/.Xresources                                ./root/home-arch/
        cp ~/.xinitrc                                   ./root/home-arch/
        cp ~/.nvidia-xinitrc                            ./root/home-arch/
        cp ~/.inputrc                                   ./root/home-arch/
        cp /etc/X11/xorg.conf                           ./root/etc-arch/X11/
        cp /etc/X11/xorg.conf.d/30-touchpad.conf        ./root/etc-arch/X11/xorg.conf.d
        cp /etc/X11/nvidia-xorg.conf                    ./root/etc-arch/X11/
        cp -r /etc/X11/nvidia-xorg.conf.d               ./root/etc-arch/X11/
        # systemd
        cp /etc/systemd/logind.conf                     ./root/etc-arch/systemd/
        cp /etc/systemd/system.conf                     ./root/etc-arch/systemd/
        # pacman
        cp /etc/pacman.conf                             ./root/etc-arch/
        # modules
        cp -r /etc/modprobe.d/bbswitch.conf             ./root/etc-arch/modprobe.d
        cp -r /etc/modprobe.d/blacklist-nouveau.conf    ./root/etc-arch/modprobe.d
        cp -r /etc/modprobe.d/nvidia.conf               ./root/etc-arch/modprobe.d
        cp -r /etc/modules-load.d/bbswitch.conf         ./root/etc-arch/modules-load.d
        echo "Arch: Copy completed!"
    fi

    # Ubuntu
    if [[ `uname -v` =~ "Ubuntu" ]]; then
        # home/.config
        cp ~/.config/libinput-gestures.conf             ./root/home/.config/

        echo "Ubuntu: Copy completed!"
    fi

elif [[ `uname -o` == "Msys" || `uname -o` == "Cygwin" ]]; then

    if [ ! -d "$DOT_HOME/dotvim" ]; then
        echo "$DOT_HOME/dotvim is not existed."
        exit
    fi

    # vim & neovim
    cp -r $DOT_HOME/dotvim/autoload                         ./vim/dotvim/
    cp -r $DOT_HOME/dotvim/init                             ./vim/dotvim/
    cp -r $DOT_HOME/dotvim/share                            ./vim/dotvim/
    cp $LOCALAPPDATA/nvim/init.lua                          ./vim/nvim/
    #cp $LOCALAPPDATA/nvim/init.vim                          ./vim/nvim/

    # gw
    cp $DOT_APPS/msys64/ucrt64.ini                          ./disk/msys2/
    cp $DOT_APPS/msys64/etc/pacman.conf                     ./disk/msys2/etc/
    cp $DOT_APPS/msys64/etc/pacman.d/mirrorlist.msys        ./disk/msys2/etc/pacman.d
    cp $DOT_APPS/msys64/etc/pacman.d/mirrorlist.mingw32     ./disk/msys2/etc/pacman.d
    cp $DOT_APPS/msys64/etc/pacman.d/mirrorlist.mingw64     ./disk/msys2/etc/pacman.d
    cp $DOT_APPS/msys64/etc/pacman.d/mirrorlist.ucrt64      ./disk/msys2/etc/pacman.d
    cp ~/.minttyrc                                          ./disk/msys2/home/
    cp ~/.gitconfig                                         ./disk/msys2/home/
    cp ~/.zshrc                                             ./disk/msys2/home/
    cp ~/.tmux.conf                                         ./disk/msys2/home/
    cp ~/.tmux-status.conf                                  ./disk/msys2/home/

    # win
    cp $USERPROFILE/.cargo/config                           ./disk/home/.cargo/
    cp $USERPROFILE/pip/pip.ini                             ./disk/home/pip/
    cp $USERPROFILE/.condarc                                ./disk/home/
    cp -r $USERPROFILE/Documents/WindowsPowerShell          ./disk/home/Documents/
    cp -r $USERPROFILE/Documents/PowerShell                 ./disk/home/Documents/
    cp -r $APPDATA/helix                                    ./disk/home/AppData/Roaming/
    cp $APPDATA/lazygit/config.yml                          ./disk/home/AppData/Roaming/lazygit/

    # scoop
    cp $DOT_APPS/_packs/persist/windows-terminal/settings/settings.json     ./disk/scoop/windows-terminal/settings/
    cp $DOT_APPS/_packs/persist/sioyek/keys_user.config                     ./disk/scoop/sioyek/
    cp $DOT_APPS/_packs/persist/sioyek/prefs_user.config                    ./disk/scoop/sioyek/

    echo "Win: Copy completed!"
fi
