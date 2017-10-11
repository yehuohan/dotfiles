#!/bin/bash

# copy all the <config-files> to <cf-dir>
# cd to LinuxConfigs before execute this file.
# this file must be in "LinuxConfigs/"

if [ `uname -o` != "Msys" ]; then
    echo "Is Not in Msys."
    exit
fi

# cf-vim
if [ ! -d "../Vim" ]; then
    echo "No Vim."
    exit
fi
cp ../Vim/_vimrc ./cf-vim/.vimrc
cp ../Vim/vimfiles/.ycm_extra_conf.py ./cf-vim/
cp -r ../Vim/vimfiles/mySnippets/ ./cf-vim/
cp -r ../Vim/vimfiles/autoload/*.vim ./cf-vim/autoload/

# cf-msys2
cp ~/.minttyrc ./cf-msys2/
cp ~/.gitconfig ./cf-msys2/
cp ~/.zshrc ./cf-msys2/
