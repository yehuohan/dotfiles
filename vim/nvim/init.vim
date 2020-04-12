
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" init.vim: init.vim for neovim.
" Github: https://github.com/yehuohan/dotconfigs
" Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if (has('unix') && !has('macunix') && !has('win32unix')) || (has('mac'))
    " Path '~/config/nvim/'
    let g:python3_host_prog = '/usr/bin/python3'
    set rtp^=~/.vim
    set rtp+=~/.vim/after
    let &packpath = &rtp
    source ~/.init.vim
elseif (has('win32') || has('win64'))
    " Path 'C:\Users\<user>\AppData\Local\nvim\'
    let g:python3_host_prog = 'C:/MyApps/Python37/python.exe'
    set rtp^=C:/MyApps/VConfig/.vim
    set rtp+=C:/MyApps/VConfig/.vim/after
    let &packpath = &rtp
    source C:/MyApps/VConfig/.init.vim
endif
