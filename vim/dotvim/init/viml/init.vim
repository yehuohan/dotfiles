"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" init.vim: configuration for vim and neovim.
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
if !exists('$DotVimDir')
let $DotVimDir=resolve(expand('<sfile>:p:h:h:h'))
endif
let $DotVimInit=$DotVimDir . '/init'
let $DotVimVimL=$DotVimDir . '/init/viml'
let $DotVimWork=$DotVimDir . '/work'
let $DotVimLocal=$DotVimDir . '/local'
set rtp^=$DotVimDir

if IsNVim()
    let $NVimConfigDir=stdpath('config')
if IsWin()
    let g:python3_host_prog = $APPS_HOME . '/_packs/apps/python/current/python.exe'
    let g:node_host_prog = $DotVimLocal . '/node_modules/neovim/bin/cli.js'
else
    let g:python3_host_prog = '/usr/bin/python3'
    let g:node_host_prog = $DotVimLocal . '/node_modules/neovim/bin/cli.js'
endif
    let &packpath = &rtp
endif

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
source $DotVimVimL/pkgs.ext.vim
source $DotVimVimL/mods.vim
source $DotVimVimL/sets.vim
