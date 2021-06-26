function! Sv_gset()
    return s:gset
endfunction

let s:gset_file = $DotVimCachePath . '/.gset.json'
let s:gset = {
    \ 'use_powerfont' : 0,
    \ 'use_lightline' : 0,
    \ 'use_startify'  : 0,
    \ 'use_ycm'       : 0,
    \ 'use_snip'      : 0,
    \ 'use_coc'       : 0,
    \ 'use_spector'   : 0,
    \ 'use_leaderf'   : 0,
    \ 'use_utils'     : 0,
    \ }

" Function: s:gsLoad() {{{
function! s:gsLoad()
    if filereadable(s:gset_file)
        call extend(s:gset, json_decode(join(readfile(s:gset_file))), 'force')
    else
        call s:gsSave()
    endif
    if IsVim() && s:gset.use_coc        " vim中coc容易卡，补全用ycm
        let s:gset.use_ycm = '1'
        let s:gset.use_coc = '0'
    endif
endfunction
" }}}

" Function: s:gsSave(...) {{{
function! s:gsSave(...)
    call writefile([json_encode(s:gset)], s:gset_file)
    echo 's:gset save successful!'
endfunction
" }}}

" Function: s:gsInit() {{{
function! s:gsInit()
    call PopSelection({
        \ 'opt' : 'select settings',
        \ 'lst' : sort(keys(s:gset)),
        \ 'dic' : {
            \ 'use_powerfont' : {},
            \ 'use_lightline' : {},
            \ 'use_startify' : {},
            \ 'use_ycm' : {},
            \ 'use_snip' : {},
            \ 'use_coc' : {},
            \ 'use_spector' : {},
            \ 'use_leaderf' : {},
            \ 'use_utils' : {},
            \ },
        \ 'sub' : {
            \ 'lst': ['0', '1'],
            \ 'cmd': {sopt, sel -> extend(s:gset, {sopt : sel})},
            \ 'get': {sopt -> s:gset[sopt]},
            \ },
        \ 'onCR': function('s:gsSave'),
        \ })
endfunction
" }}}

command! -nargs=0 GSInit :call s:gsInit()

call s:gsLoad()
