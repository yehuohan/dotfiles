
#!/bin/sh

#===============================================================================
# load xterm resources and keymaps
#===============================================================================
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ ! -n "${USER_MODMAP_LOADED+1}" ]; then
    if [ -f "$usermodmap" ]; then
        xmodmap "$usermodmap"
        export USER_MODMAP_LOADED="yes"
        readonly USER_MODMAP_LOADED
    fi
fi


#===============================================================================
# fcitx setting
#===============================================================================
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx


#===============================================================================
# user path
#===============================================================================
export PATH="$PATH:$HOME/MyApps/"

export PATH="$PATH:$HOME/MyApps/Qt591/5.9.1/gcc_64/bin"
export PATH="$PATH:$HOME/MyApps/Qt591/Tools/QtCreator/bin"

export PATH="$PATH:$HOME/MyApps/Qt570/5.7/gcc_64/bin"
export PATH="$PATH:$HOME/MyApps/Qt570/Tools/QtCreator/bin"

export PATH="$PATH:$HOME/MyApps/bochs268/bin"
export PATH="$PATH:$HOME/MyApps/nasm212/bin"
export PATH="$PATH:$HOME/MyApps/nodejs/bin"
export PATH="$PATH:$HOME/MyApps/XXNet"
