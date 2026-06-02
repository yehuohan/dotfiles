
$dir_this = $PSScriptRoot
$dot_home = Get-ItemPropertyValue -Path HKCU:\Environment -Name DOT_HOME -ErrorAction SilentlyContinue
$dot_apps = Get-ItemPropertyValue -Path HKCU:\Environment -Name DOT_APPS -ErrorAction SilentlyContinue
if (!(Test-Path $dot_home/dotvim -PathType Container)) {
    echo "$dot_home/dotvim is not existed."
    exit
}

# vim & neovim
New-Item -Path $dir_this/dotvim -ItemType Directory -Force
Copy-Item -Path $dot_home/dotvim/init               -Destination $dir_this/vim/dotvim/ -Recurse -Force
Copy-Item -Path $dot_home/dotvim/share              -Destination $dir_this/vim/dotvim/ -Recurse -Force
Copy-Item -Path $env:LOCALAPPDATA/nvim/init.lua     -Destination $dir_this/vim/nvim/ -Force
# Copy-Item -Path $env:LOCALAPPDATA/nvim/init.vim     -Destination $dir_this/vim/nvim/ -Force

# gw
Copy-Item -Path $dot_apps/msys64/ucrt64.ini                             -Destination $dir_this/disk/msys2/ -Force
Copy-Item -Path $dot_apps/msys64/etc/pacman.conf                        -Destination $dir_this/disk/msys2/etc/ -Force
Copy-Item -Path $dot_apps/msys64/etc/pacman.d/mirrorlist.msys           -Destination $dir_this/disk/msys2/etc/pacman.d -Force
Copy-Item -Path $dot_apps/msys64/etc/pacman.d/mirrorlist.mingw32        -Destination $dir_this/disk/msys2/etc/pacman.d -Force
Copy-Item -Path $dot_apps/msys64/etc/pacman.d/mirrorlist.mingw64        -Destination $dir_this/disk/msys2/etc/pacman.d -Force
Copy-Item -Path $dot_apps/msys64/etc/pacman.d/mirrorlist.ucrt64         -Destination $dir_this/disk/msys2/etc/pacman.d -Force
Copy-Item -Path $dot_apps/msys64/home/$env:USERNAME/.minttyrc           -Destination $dir_this/disk/msys2/home/ -Force
Copy-Item -Path $dot_apps/msys64/home/$env:USERNAME/.gitconfig          -Destination $dir_this/disk/msys2/home/ -Force
Copy-Item -Path $dot_apps/msys64/home/$env:USERNAME/.zshrc              -Destination $dir_this/disk/msys2/home/ -Force
Copy-Item -Path $dot_apps/msys64/home/$env:USERNAME/.tmux.conf          -Destination $dir_this/disk/msys2/home/ -Force
Copy-Item -Path $dot_apps/msys64/home/$env:USERNAME/.tmux-status.conf   -Destination $dir_this/disk/msys2/home/ -Force

# win
Copy-Item -Path $env:USERPROFILE/.cargo/config                  -Destination $dir_this/disk/home/.cargo/ -Force
Copy-Item -Path $env:USERPROFILE/pip/pip.ini                    -Destination $dir_this/disk/home/pip/ -Force
Copy-Item -Path $env:USERPROFILE/.condarc                       -Destination $dir_this/disk/home/ -Force
Copy-Item -Path $env:USERPROFILE/Documents/WindowsPowerShell    -Destination $dir_this/disk/home/Documents/ -Recurse -Force
Copy-Item -Path $env:USERPROFILE/Documents/PowerShell           -Destination $dir_this/disk/home/Documents/ -Recurse -Force
Copy-Item -Path $env:APPDATA/helix                              -Destination $dir_this/disk/home/AppData/Roaming/ -Recurse -Force
Copy-Item -Path $env:APPDATA/lazygit/config.yml                 -Destination $dir_this/disk/home/AppData/Roaming/lazygit/ -Force

# scoop
Copy-Item -Path $dot_apps/_packs/persist/windows-terminal/settings/settings.json    -Destination $dir_this/disk/scoop/windows-terminal/settings/ -Force
Copy-Item -Path $dot_apps/_packs/persist/sioyek/keys_user.config                    -Destination $dir_this/disk/scoop/sioyek/ -Force
Copy-Item -Path $dot_apps/_packs/persist/sioyek/prefs_user.config                   -Destination $dir_this/disk/scoop/sioyek/ -Force

echo "Copy completed!"
