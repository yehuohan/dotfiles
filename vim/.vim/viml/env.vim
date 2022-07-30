const s:env = {
    \ 'local': [
        \ $DotVimDir . '/local',
        \ $DotVimDir . '/local/bin',
    \ ],
    \ 'unix': [
        \ '~/ubin',
        \ '~/uapps',
    \ ],
\ }

" FUNCTION: s:envInit() {{{
function! s:envInit()
    if IsWin()
        let l:sep = ';'
        " For .ycm_extra_conf.py
        let $VPathPython = $APPS_HOME . '/Python'
        let $VPathMingw64 = $APPS_HOME . '/msys64/mingw64'
    else
        let l:sep = ':'
        let $PATH .= l:sep . join(s:env.unix, l:sep)
        let $VPathPython = '/usr/bin'
    endif

    " Local path has first priority to vim
    let $PATH = join(s:env.local, l:sep) . l:sep . $PATH

    " Append {'path':[], 'vars':{}} from .env.json
    let l:ex_file = $DotVimCache . '/.env.json'
    if filereadable(l:ex_file)
        let l:ex = json_decode(join(readfile(l:ex_file)))
        let $PATH .= l:sep . join(l:ex.path, l:sep)
        for [name, val] in items(l:ex.vars)
            call execute(printf("let $%s='%s'", name, val))
        endfor
    endif
endfunction
" }}}

" FUNCTION: Env_coc_settings() {{{
function! Env_coc_settings()
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

call s:envInit()
