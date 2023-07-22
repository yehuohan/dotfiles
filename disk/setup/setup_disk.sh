#!/usr/bin/env bash

DIR_DISK=$(readlink -f "$(dirname "$0")/../")
echo DIR_DISK: $DIR_DISK

# Set zsh url
ZSH_URL=raw.githubusercontent.com
if [[ ! -z "$1" ]]; then
    ZSH_URL=$1
fi

# Restore disk
cp -r $DIR_DISK/msys2/etc/*         /etc/
cp -r $DIR_DISK/msys2/etc/.*        /etc/
cp -r $DIR_DISK/msys2/home/*        ~/
cp -r $DIR_DISK/msys2/home/.*       ~/
cp -r $DIR_DISK/home-win/*          $USERPROFILE/
cp -r $DIR_DISK/home-win/.*         $USERPROFILE/

pacman -Sy

# Install zsh and git
if [[ ! -x "$(command -v zsh)" ]]; then
    pacman -S zsh
fi
if [[ ! -x "$(command -v git)" ]]; then
    pacman -S git
fi

# Install on-my-zsh from https://github.com/ohmyzsh/ohmyzsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(wget -O- https://${ZSH_URL}/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install gcc
# pacman -S mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-clang mingw-w64-ucrt-x86_64-make
# cp /ucrt64/bin/mingw32-make.exe /ucrt64/bin/make.exe

echo "Disk setup was completed!"
