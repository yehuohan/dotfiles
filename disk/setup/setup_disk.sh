#!/usr/bin/env bash

DIR_DISK=$(readlink -f "$(dirname "$0")/../")
echo DIR_DISK: $DIR_DISK

# Set zsh url
ZSH_URL=githubusercontent
if [[ ! -z "$1" ]]; then
    ZSH_URL=$1
fi

# Install zsh and git
if [[ ! -x "$(command -v zsh)" ]]; then
    pacman -S zsh
fi
if [[ ! -x "$(command -v git)" ]]; then
    pacman -S git
fi

# Install on-my-zsh from https://github.com/ohmyzsh/ohmyzsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(wget -O- https://raw.${ZSH_URL}.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

cp -r $DIR_DISK/msys2/etc/*         /etc/
cp -r $DIR_DISK/msys2/etc/.*        /etc/
cp -r $DIR_DISK/msys2/home/*        ~/
cp -r $DIR_DISK/msys2/home/.*       ~/
cp -r $DIR_DISK/home-win/*          $USERPROFILE/
cp -r $DIR_DISK/home-win/.*         $USERPROFILE/

echo "Disk setup was completed!"
