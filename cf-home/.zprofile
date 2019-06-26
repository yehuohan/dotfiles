
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
export PATH=$PATH:$HOME/my-apps
export PATH=$PATH:$HOME/my-apps/AppImage
export PATH=$PATH:$HOME/my-apps/XXNet
export PATH=$PATH:$HOME/my-apps/firefox
export PATH=$PATH:/opt/cuda/bin

export PATH=$PATH:$HOME/my-apps/android-studio/bin
export ANDROID_HOME=$HOME/my-apps/Android/SDK
export PATH=$PATH:$ANDROID_HOME
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/ndk-bundle
export PATH=$PATH:$ANDROID_HOME/emulator
