
## Setup

- Linux

```sh
cd dotconfigs/vim/setup
./setup_dotvim.sh
```

- Windows

```sh
cd dotconfigs/vim/setup
# 首先运行add_env_path.reg，添加APPS_HOME等环境变量
setup_dotvim.bat
setup_link_msys64.bat
```

## Vim && Neovim

- [vim/vim](https://github.com/vim/vim)
- [neovim/neovim](https://github.com/neovim/neovim)
  - `pacman -S xclip or xsel`
  - [nvim.appimage](https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage)
  - [nvim-win64.zip](https://github.com/neovim/neovim/releases/download/nightly/nvim-win64.zip)
  - [neovim-qt-mingw-x64.zip](https://github.com/yehuohan/neovim-qt/releases/download/lastest/neovim-qt-mingw-x64.zip)
  - [neovim-qt-msvc-x64.zip](https://github.com/yehuohan/neovim-qt/releases/download/lastest/neovim-qt-msvc-x64.zip)
- [Python](https://www.python.org/)
  - `pip install pynvim`
- [NodeJs](https://nodejs.org)
  - `HTTPS_PROXY=addr:port npm install -g neovim`
  - `cd $DotVimPath/local && HTTPS_PROXY=addr:port npm install neovim`
- [lua](https://www.lua.org/)
- Git
  - `git config --global http.proxy addr:port`
  - [Msys2](http://www.msys2.org/)
  - [Cygwin](https://cygwin.com)

---

- [LLVM](http://llvm.org/)
  - [Clangd](https://github.com/clangd/clangd)
- [Fzf](https://github.com/junegunn/fzf)
- [Ripgrep](https://github.com/BurntSushi/ripgrep)
- [Ag](https://github.com/k-takata/the_silver_searcher-win32)
- [Bat](https://github.com/sharkdp/bat)
- [Astyle](http://astyle.sourceforge.net)
- [Ctags](https://github.com/universal-ctags/ctags)
- [Lf](https://github.com/gokcehan/lf)

---

- [GvimFullscreen](./gvimfullscreen)
- [Typora](https://typora.io/)
- [MuPDF](https://www.mupdf.com)
- [SumatraPDF](https://www.sumatrapdfreader.org)
