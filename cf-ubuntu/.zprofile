
#!/bin/sh

#===============================================================================
# load xterm resources and keymaps
#===============================================================================
usermodmap=$HOME/.Xmodmap

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
export PATH="$PATH:$HOME/my-apps"
export PATH="$PATH:$HOME/my-apps/XXNet"
