" Env: environment variable for vim and neovim.

" Environment variables {{{
let s:env = {
    \ 'local': [
        \ $DotVimPath . '/local',
        \ $DotVimPath . '/local/bin',
    \ ],
    \ 'unix': [
        \ '~/ubin',
        \ '~/uapps',
    \ ],
    \ 'win': [
        \ 'D:/apps/lua',
        \ 'D:/VS2017/VC/Auxiliary/Build',
        \ 'C:/Program Files (x86)/Google/Chrome/Application',
        \ 'D:/Mozilla Firefox',
        \ 'D:/Typora',
        \ 'E:/texlive/bin/win32',
        \ 'E:/SumatraPDF',
        \ 'E:/MATLAB/R2015b/bin',
    \ ],
\ }
" }}}

" FUNCTION: env#env() {{{
function! env#env()
    if IsWin()
        let $PATH .= ';' . join(s:env.local, ';')
        let $PATH .= ';' . join(s:env.win, ';')
        " For .ycm_extra_conf.py
        let $VPathPython = 'C:/apps/Python'
        let $VPathMingw64 = 'C:/apps/msys64/mingw64'
        let $VPathVs = 'D:/VS2017/VC/Tools/MSVC/14.16.27023'
    else
        let $PATH .= ':' . join(s:env.local, ':')
        let $PATH .= ':' . join(s:env.unix, ':')
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
