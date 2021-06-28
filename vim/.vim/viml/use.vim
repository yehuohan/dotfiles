function! Sv_use()
    return s:use
endfunction

let s:use_file = $DotVimCachePath . '/.use.json'
let s:use = {
    \ 'powerfont' : 0,
    \ 'lightline' : 0,
    \ 'startify'  : 0,
    \ 'ycm'       : 0,
    \ 'snip'      : 0,
    \ 'coc'       : 0,
    \ 'spector'   : 0,
    \ 'leaderf'   : 0,
    \ 'utils'     : 0,
    \ }

" Function: s:useLoad() {{{
function! s:useLoad()
    if filereadable(s:use_file)
        call extend(s:use, json_decode(join(readfile(s:use_file))), 'force')
    else
        call s:useSave()
    endif
    if IsVim() && s:use.coc        " vim中coc容易卡，补全用ycm
        let s:use.ycm = '1'
        let s:use.coc = '0'
    endif
endfunction
" }}}

" Function: s:useSave(...) {{{
function! s:useSave(...)
    call writefile([json_encode(s:use)], s:use_file)
    echo 's:use save successful!'
endfunction
" }}}

" Function: s:useInit() {{{
function! s:useInit()
    call PopSelection({
        \ 'opt' : 'select use settings',
        \ 'lst' : sort(keys(s:use)),
        \ 'dic' : map(copy(s:use), '{}'),
        \ 'sub' : {
            \ 'lst': ['0', '1'],
            \ 'cmd': {sopt, sel -> extend(s:use, {sopt : sel})},
            \ 'get': {sopt -> s:use[sopt]},
            \ },
        \ 'onCR': function('s:useSave'),
        \ })
endfunction
" }}}

command! -nargs=0 Use :call s:useInit()

call s:useLoad()
