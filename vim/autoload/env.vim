
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
    \ $DotVimPath . '/vBin',
    \ $DotVimPath . '/vBin/bin',
    \ 'C:/MyApps/Python37',
    \ 'C:/MyApps/Julia/bin',
    \ 'C:/MyApps/cygwin64/bin',
    \ 'C:/MyApps/LLVM/bin',
    \ 'C:/MyApps/Go/bin',
    \ 'C:/MyApps/lua',
    \ 'C:/Program Files (x86)/Google/Chrome/Application',
    \ 'D:/cmake/bin',
    \ 'D:/nodejs',
    \ 'D:/Java/jdk1.8.0_201/bin',
    \ 'D:/Qt/5.12.5/msvc2017_64/bin',
    \ 'D:/VS2017/MSBuild/15.0/Bin',
    \ 'D:/VS2017/VC/Tools/MSVC/14.13.26128/bin/Hostx64/x64',
    \ 'D:/VS2017/VC/Auxiliary/Build',
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
    if !empty(l:e)
        " IsWin() is from vimrc
        if IsWin()
            let $PATH .= ';' . join(l:e, ';')
            let $VPathPython = 'C:/MyApps/Python37'
            let $VPathCygwin = 'C:/MyApps/cygwin64'
            let $VPathQt = 'D:/Qt/5.12.5/msvc2017_64'
            let $VPathVs = 'D:/VS2017/VC/Tools/MSVC/14.13.26128'
            let $VPathLuaLsp = $HOME . '/.vscode/extensions/sumneko.lua-0.16.2'
        else
            let $PATH .= ':' . join(l:e, ':')
            let $VPathPython = '/usr/bin'
            let $VPathLuaLsp = '~/.vscode/extensions/sumneko.lua-0.16.2'
        endif
    endif
endfunction
" }}}
