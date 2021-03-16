
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
export PATH=$PATH:$HOME/uapps
export PATH=$PATH:$HOME/uapps/AppImage
export PATH=$PATH:$HOME/uapps/XXNet
export PATH=$PATH:$HOME/uapps/firefox
export PATH=$PATH:/opt/cuda/bin

#export PATH=$PATH:$HOME/uapps/android-studio/bin
export ANDROID_HOME=$HOME/uapps/Android/SDK
export PATH=$PATH:$ANDROID_HOME
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/ndk-bundle
export PATH=$PATH:$ANDROID_HOME/emulator

