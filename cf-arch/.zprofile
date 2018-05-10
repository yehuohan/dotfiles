
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
export PATH="$PATH:$HOME/my-apps/"
export PATH="$PATH:$HOME/my-apps/XXNet"
export PATH="$PATH:$HOME/my-apps/firefox"

export PATH="$PATH:/opt/cuda/bin"
