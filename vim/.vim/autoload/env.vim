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
        \ 'C:/Program Files (x86)/Google/Chrome/Application',
        \ 'D:/Mozilla Firefox',
        \ 'D:/VS2017/VC/Auxiliary/Build',
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
    return {
        \ "Lua": {
            \ "workspace": {
                \ "library": {
                    \ $VIMRUNTIME."/lua": v:true,
                    \ $VIMRUNTIME."/lua/vim": v:true,
                    \ $VIMRUNTIME."/lua/vim/lsp": v:true,
                    \ $VIMRUNTIME."/lua/vim/treesitter": v:true
                \}
            \ }
        \ },
        \ "python": {
            \ "pythonPath": $VPathPython . "/python"
        \ }
    \ }
endfunction
" }}}
