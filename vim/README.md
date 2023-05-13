
## Setup

- Linux

```sh
cd dotconfigs/vim/setup
./setup_dotvim.sh
```

- Windows

```sh
cd dotconfigs/vim/setup
# 首先运行reg/add_env_path.reg，添加APPS_HOME等环境变量
setup_dotvim.bat
setup_link_msys64.bat
```

## `.vim`

> *Workspace run project:*

<div align="center">
<img alt="workspace run project" src="README/ws-rp.gif"  width=75% height=75% />
</div>

> *Workspace find:*

<div align="center">
<img alt="workspace find" src="README/ws-fw.gif"  width=75% height=75% />
</div>


## Remote

- Start server

```sh
# Run in remote machine
nvim --headless --listen localhost:6666
# Or run in local machine via ssh
ssh -L 6666:localhost:6666 <remote machine IP> <remote machine nvim path> --headless --listen localhost:6666
```

- Connect to server

```sh
# Run in local machine
neovide --remote-tcp=localhost:6666
```


---

## Links

- [vim](https://github.com/vim/vim)
  - [GvimFullscreen](./gvim/gvimfullscreen)
- [neovim](https://github.com/neovim/neovim)
  - `pacman -S xclip or xsel`
  - [nvim.appimage](https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage)
  - [nvim-win64.zip](https://github.com/neovim/neovim/releases/download/nightly/nvim-win64.zip)
  - [neovim-qt-mingw-x64.zip](https://github.com/yehuohan/neovim-qt/releases/download/lastest/neovim-qt-mingw-x64.zip)
  - [neovim-qt-msvc-x64.zip](https://github.com/yehuohan/neovim-qt/releases/download/lastest/neovim-qt-msvc-x64.zip)
- [neovide](https://github.com/neovide/neovide)
  - [neovide-windows](https://github.com/neovide/neovide/releases/latest/download/neovide-windows.zip)
- [Python](https://www.python.org/)
  - `pip install pynvim`
- [lua](https://www.lua.org/)
- [NodeJs](https://nodejs.org)
  - `HTTPS_PROXY=addr:port npm install -g neovim`
  - `cd $DotVimPath/local && HTTPS_PROXY=addr:port npm install neovim`
- [Deno](https://github.com/denoland/deno)
- Git: [Msys2](http://www.msys2.org/) or [Cygwin](https://cygwin.com)
  - `git config --global http.proxy addr:port`
- [LLVM](http://llvm.org/) or [Clangd](https://github.com/clangd/clangd)
- [Ripgrep](https://github.com/BurntSushi/ripgrep) or [Ag](https://github.com/k-takata/the_silver_searcher-win32)
- [Fzf](https://github.com/junegunn/fzf)
- [Bat](https://github.com/sharkdp/bat)
- [Ctags](https://github.com/universal-ctags/ctags)
- [Lf](https://github.com/gokcehan/lf)
