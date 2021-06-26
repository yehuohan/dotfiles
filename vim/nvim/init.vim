"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" init.vim: init.vim for neovim.
" Github: https://github.com/yehuohan/dotconfigs
" Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if (has('unix') && !has('macunix') && !has('win32unix')) || (has('mac'))
    " Path '~/config/nvim/'
    let g:python3_host_prog = '/usr/bin/python3'
    if filereadable('~/.vim/local/node_modules/.bin/neovim-node-host')
        let g:node_host_prog = '~/.vim/local/node_modules/.bin/neovim-node-host'
    else
        let g:node_host_prog = '/usr/bin/neovim-node-host'
    endif
    set rtp^=~/.vim
    set rtp+=~/.vim/after
    let &packpath = &rtp
    source ~/.vim/.init.vim
elseif (has('win32') || has('win64'))
    " Path 'C:\Users\<user>\AppData\Local\nvim\'
    let g:python3_host_prog = $APPS_HOME . '/Python/python.exe'
    if filereadable($APPS_HOME . '/dotvim/local/node_modules/.bin/neovim-node-host.cmd')
        let g:node_host_prog = $APPS_HOME . '/dotvim/local/node_modules/.bin/neovim-node-host.cmd'
    else
        let g:node_host_prog = $APPS_HOME . '/nodejs/node_modules/neovim-node-host.cmd'
    endif
    set rtp^=$APPS_HOME/dotvim
    set rtp+=$APPS_HOME/dotvim/after
    let &packpath = &rtp
    source $APPS_HOME/dotvim/.init.vim
endif
