
#!/bin/sh

setterm -blength 0

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
export DOT_HOME=$HOME
export DOT_APPS=$HOME/uapps
export PATH=$PATH:$DOT_APPS
export PATH=$PATH:$DOT_APPS/firefox

export ANDROID_HOME=$HOME/uapps/Android/SDK
export PATH=$PATH:$ANDROID_HOME
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/ndk-bundle
export PATH=$PATH:$ANDROID_HOME/emulator

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
