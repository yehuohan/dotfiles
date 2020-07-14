
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Env: environment variable for vim and neovim.
" Github: https://github.com/yehuohan/dotconfigs
" Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" environment variable {{{
" Format: s:env.dev.os
let s:env = {
    \ 'hp': {}
    \ }
" }}}

" hp with windows10 {{{
let s:env.hp.win = [
    \ 'C:/apps/bin',
    \ 'C:/apps/Python',
    \ 'C:/apps/Julia/bin',
    \ 'C:/apps/msys64/usr/bin',
    \ 'C:/apps/msys64/mingw64/bin',
    \ 'C:/apps/LLVM/bin',
    \ 'C:/apps/Go/bin',
    \ 'C:/apps/lua',
    \ 'C:/apps/rust/toolchain/toolchains/nightly-x86_64-pc-windows-msvc/bin',
    \ 'C:/apps/rust/cargo/bin',
    \ 'C:/apps/cmake/bin',
    \ 'C:/Program Files (x86)/Google/Chrome/Application',
    \ 'D:/nodejs',
    \ 'D:/Java/jdk1.8.0_201/bin',
    \ 'D:/Qt/5.12.5/msvc2017_64/bin',
    \ 'D:/VS2017/MSBuild/15.0/Bin',
    \ 'D:/VS2017/VC/Auxiliary/Build',
    \ 'D:/VS2017/VC/Tools/MSVC/14.16.27023/bin/Hostx64/x64',
    \ 'D:/VS2017/VC/Tools/MSVC/14.16.27023/bin/Hostx64/x86',
    \ 'D:/Mozilla Firefox',
    \ 'D:/Typora',
    \ 'E:/texlive/bin/win32',
    \ 'E:/SumatraPDF',
    \ 'E:/MATLAB/R2015b/bin',
    \ ]
" }}}

" FUNCTION: env#env(dev, os) {{{
" @param dev: device name
" @param os: os name
function! env#env(dev, os)
    let l:e = get(get(s:env, a:dev, {}), a:os, [])
    " IsWin() is from vimrc
    if IsWin()
        if !empty(l:e)
            let $PATH .= ';' . join(l:e, ';')
        endif
        let $VPathPython = 'C:/apps/Python'
        let $VPathMingw64 = 'C:/apps/msys64/mingw64'
        let $VPathVs = 'D:/VS2017/VC/Tools/MSVC/14.16.27023'
        let $VPathLuaLsp = $HOME . '/.vscode/extensions/sumneko.lua-0.16.2'
    else
        if !empty(l:e)
            let $PATH .= ':' . join(l:e, ':')
        endif
        let $VPathPython = '/usr/bin'
        let $VPathLuaLsp = '~/.vscode/extensions/sumneko.lua-0.16.2'
    endif
endfunction
" }}}
