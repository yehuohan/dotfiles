
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
# pip zsh completion
#===============================================================================
function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip
compctl -K _pip_completion pip3



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
