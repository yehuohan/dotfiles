"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" .init.vim: configuration for vim and neovim.
" Github: https://github.com/yehuohan/dotconfigs
" Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Globals {{{
let $DotVimPath=resolve(expand('<sfile>:p:h'))
let $DotVimVimLPath=$DotVimPath . '/viml'
let $DotVimMiscPath=$DotVimPath . '/misc'
let $DotVimCachePath=$DotVimPath . '/.cache'
set rtp+=$DotVimPath

set encoding=utf-8                      " 内部使用utf-8编码
set nocompatible                        " 不兼容vi
let mapleader="\<Space>"                " Space leader
nnoremap ; :
vnoremap ; :
nnoremap : ;
" }}}

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

source $DotVimVimLPath/env.vim
source $DotVimVimLPath/use.vim
source $DotVimVimLPath/plugins.vim
source $DotVimVimLPath/modules.vim
source $DotVimVimLPath/settings.vim
