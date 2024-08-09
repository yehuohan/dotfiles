" FUNCTION: s:envInit() {{{
function! s:envInit()
    " Append {'path':[]} from .env.json
    let l:sep = IsWin() ? ';' : ':'
    let l:ex_file = $DotVimLocal . '/.env.json'
    if filereadable(l:ex_file)
        let l:ex = json_decode(join(readfile(l:ex_file)))
        let $PATH .= l:sep . join(l:ex.path, l:sep)
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
    \ }
endfunction
" }}}

call s:envInit()
