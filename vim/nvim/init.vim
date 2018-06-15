
" Platform
silent function! IsLinux()
    return (has('unix') && !has('macunix') && !has('win32unix'))
endfunction
silent function! IsWin()
    return (has('win32') || has('win64'))
endfunction
silent function! IsMac()
    return (has('mac'))
endfunction


" Use .vimrc
if (IsLinux() || IsMac())
    set rtp^=~/.vim
    set rtp+=~/.vim/after
    let &packpath = &rtp
    source ~/.vimrc
elseif IsWin()
    set rtp^=C:/MyApps/vim/vimfiles
    set rtp+=C:/MyApps/vim/vimfiles/after
    let &packpath = &rtp
    source C:/MyApps/vim/_vimrc
endif
