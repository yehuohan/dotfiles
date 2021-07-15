"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" .init.vim: configuration for vim and neovim.
" Github: https://github.com/yehuohan/dotconfigs
" Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Platforms {{{
function! IsLinux()
    return (has('unix') && !has('macunix') && !has('win32unix'))
endfunction
function! IsWin()
    return (has('win32') || has('win64'))
endfunction
function! IsGw()
    return has('win32unix')
endfunction
function! IsMac()
    return has('mac')
endfunction
function! IsVim()
    return !(has('nvim'))
endfunction
function! IsNVim()
    return has('nvim')
endfunction
" }}}

" Globals {{{
let $DotVimPath=resolve(expand('<sfile>:p:h'))
let $DotVimVimLPath=$DotVimPath . '/viml'
let $DotVimMiscPath=$DotVimPath . '/misc'
let $DotVimCachePath=$DotVimPath . '/.cache'
set rtp^=$DotVimPath

if IsNVim()
if IsWin()
    let g:python3_host_prog = $APPS_HOME . '/Python/python.exe'
    let g:node_host_prog = $DotVimPath . '/local/node_modules/.bin/neovim-node-host.cmd'
    if !filereadable(g:node_host_prog)
        let g:node_host_prog = $APPS_HOME . '/nodejs/node_modules/neovim-node-host.cmd'
    endif
else
    let g:python3_host_prog = '/usr/bin/python3'
    let g:node_host_prog = $DotVimPath . '/local/node_modules/.bin/neovim-node-host'
    if !filereadable(g:node_host_prog)
        let g:node_host_prog = '/usr/bin/neovim-node-host'
    endif
endif
    let &packpath = &rtp
endif

set encoding=utf-8                      " 内部使用utf-8编码
set nocompatible                        " 不兼容vi
let mapleader="\<Space>"                " Space leader
nnoremap ; :
vnoremap ; :
nnoremap : ;
" }}}

source $DotVimVimLPath/env.vim
source $DotVimVimLPath/use.vim
source $DotVimVimLPath/plugins.vim
source $DotVimVimLPath/modules.vim
source $DotVimVimLPath/settings.vim
