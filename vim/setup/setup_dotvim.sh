#!/usr/bin/bash

DIR_VIM=$(readlink -f "$(dirname "$0")/../")
DIR_DOT=~/dotvim
InitFile=init.lua
# InitFile=init.vim

echo DIR_VIM: $DIR_VIM
echo DIR_DOT: $DIR_DOT
echo Init file: $InitFile

# check DIR_VIM
if [[ ! -d "$DIR_VIM/dotvim" ]]; then
    echo ERROR: "$DIR_VIM/dotvim" is not existed
    exit
fi
if [[ ! -f "$DIR_VIM/nvim/$InitFile" ]]; then
    echo ERROR: "$DIR_VIM/nvim/$InitFile" is not existed
    exit
fi

# copy dotvim
cp -r $DIR_VIM/dotvim/*         $DIR_DOT/

# copy nvim
mkdir -p ~/.config/nvim
cp $DIR_VIM/nvim/$InitFile      ~/.config/nvim/

echo "Dotvim setup was completed!"
