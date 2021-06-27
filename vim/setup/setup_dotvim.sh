#!/usr/bin/bash

if [[ $(cd `dirname "$0"`;pwd) != ~/dotconfigs/vim/setup ]]; then
    echo 'Is Not in ~/dotconfigs/vim/setup'
    exit
fi

# .vim
cp ../.vim/.init.vim            ~/.vim/
cp -r ../.vim/autoload          ~/.vim/
cp -r ../.vim/viml              ~/.vim/
cp -r ../.vim/rplugin           ~/.vim/
cp -r ../.vim/pythonx           ~/.vim/
cp -r ../.vim/snips             ~/.vim/
cp -r ../.vim/misc              ~/.vim/

# nvim
if type nvim >/dev/null 2>&1; then 
    mkdir -p ~/.config/nvim
    cp ../nvim/init.vim ~/.config/nvim/
fi

echo "Dotvim setup was completed!"
