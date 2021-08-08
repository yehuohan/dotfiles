#!/usr/bin/bash

if [[ $(cd `dirname "$0"`;pwd) != ~/dotconfigs/vim/setup ]]; then
    echo 'Is NOT in ~/dotconfigs/vim/setup'
    exit
fi

# .vim
cp    ~/dotconfigs/vim/.vim/.init.vim   ~/.vim/
cp -r ~/dotconfigs/vim/.vim/*           ~/.vim/

# nvim
if type nvim >/dev/null 2>&1; then 
    mkdir -p ~/.config/nvim
    cp ~/dotconfigs/vim/nvim/init.vim   ~/.config/nvim/
    #cp ~/dotconfigs/vim/nvim/init.lua   ~/.config/nvim/
fi

echo "Dotvim setup was completed!"
