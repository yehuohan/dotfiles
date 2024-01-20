"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" init.vim: configuration for vim
" Github: https://github.com/yehuohan/dotfiles
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
" }}}

" Globals {{{
if !exists('$DotVimDir')
let $DotVimDir=resolve(expand('<sfile>:p:h:h:h'))
endif
let $DotVimInit=$DotVimDir . '/init'
let $DotVimVimL=$DotVimDir . '/init/viml'
let $DotVimShare=$DotVimDir . '/share'
let $DotVimLocal=$DotVimDir . '/local'
set rtp^=$DotVimDir
set encoding=utf-8                      " 内部使用utf-8编码
set nocompatible                        " 不兼容vi
let mapleader="\<Space>"                " Space leader
nnoremap ; :
vnoremap ; :
nnoremap : ;
map <CR> <CR>
map <Tab> <Tab>
" }}}

source $DotVimVimL/env.vim
source $DotVimVimL/use.vim
source $DotVimVimL/pkgs.vim
source $DotVimVimL/mods.vim
source $DotVimVimL/sets.vim
