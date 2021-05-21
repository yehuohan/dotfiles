
" Env: environment variable for vim and neovim.


" environment variable {{{
" Format: s:env.dev.os
let s:env = {
    \ 'hp': {}
    \ }
" }}}

" hp with windows10 {{{
let s:env.hp.win = [
    \ 'C:/apps/bin',
    \ 'C:/apps/bin/bin',
    \ 'C:/apps/Python',
    \ 'C:/apps/msys64/usr/bin',
    \ 'C:/apps/msys64/mingw64/bin',
    \ 'D:/apps/rust/toolchain/toolchains/nightly-x86_64-pc-windows-msvc/bin',
    \ 'D:/apps/rust/cargo/bin',
    \ 'D:/apps/LLVM/bin',
    \ 'D:/apps/lua',
    \ 'D:/apps/Julia/bin',
    \ 'D:/apps/Go/bin',
    \ 'D:/apps/cmake/bin',
    \ 'D:/nodejs',
    \ 'D:/Java/jdk1.8.0_201/bin',
    \ 'D:/Qt/5.12.5/msvc2017_64/bin',
    \ 'D:/VS2017/VC/Auxiliary/Build',
    \ 'D:/VS2017/VC/Tools/MSVC/14.16.27023/bin/Hostx64/x64',
    \ 'D:/VS2017/VC/Tools/MSVC/14.16.27023/bin/Hostx64/x86',
    \ 'C:/Program Files (x86)/Google/Chrome/Application',
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
        " For .ycm_extra_conf.py
        let $VPathMingw64 = 'C:/apps/msys64/mingw64'
        let $VPathVs = 'D:/VS2017/VC/Tools/MSVC/14.16.27023'
        let $VPathPython = 'C:/apps/Python'
    else
        if !empty(l:e)
            let $PATH .= ':' . join(l:e, ':')
        endif
        let $VPathPython = '/usr/bin'
    endif
endfunction
" }}}

" FUNCTION: env#coc_settings() {{{
function! env#coc_settings()
    let l:lualsp_cwd = (IsWin() ? $USERPROFILE : '~') . '/.vscode/extensions/sumneko.lua-0.16.2'
    let l:lualsp_cmd = l:lualsp_cwd . (IsWin() ? '/server/bin/Windows/lua-language-server.exe' : '/server/bin/Linux/lua-language-server')
    return {
        \ "python": {
            \ "pythonPath": $VPathPython . "/python"
            \ },
        \ 'languageserver': {
                \ 'lua-language-server': {
                    \ 'cwd': l:lualsp_cwd,
                    \ 'command': l:lualsp_cmd,
                    \ 'args': ['-E', '-e', 'LANG="zh-cn"', l:lualsp_cwd . '/server/main.lua'],
                    \ 'filetypes': ['lua'],
                    \ }
            \ }
        \ }
endfunction
" }}}
