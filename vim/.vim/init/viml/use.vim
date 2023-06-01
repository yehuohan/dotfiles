function! SvarUse()
    return s:use
endfunction

" Struct s:use {{{
let s:use_file = $DotVimLocal . '/.use.json'
let s:use = {
    \ 'xgit'   : v:null,
    \ 'coc'    : v:false,
    \ 'nlsp'   : v:false,
    \ 'nts'    : v:false,
    \ 'ndap'   : v:false,
    \ 'has_py' : v:false,
    \ 'ui'     : {
        \ 'patch'    : v:false,
        \ 'font'     : 'Consolas',
        \ 'fontsize' : 12,
        \ 'wide'     : 'Microsoft YaHei UI',
        \ 'widesize' : 11,
        \ }
    \ }
" }}}

" Function: s:useLoad() {{{
function! s:useLoad()
    if filereadable(s:use_file)
        let l:dic = json_decode(join(readfile(s:use_file)))
        call extend(s:use, l:dic)
    else
        call s:useSave('onCR')
    endif
endfunction
" }}}

" Function: s:useSave(...) {{{
function! s:useSave(name, ...)
    if a:name ==# 'onCR'
        call writefile([json_encode(s:use)], s:use_file)
        echo 's:use save successful!'
    endif
endfunction
" }}}

" Function: s:useInit() {{{
function! s:useInit()
    " Init with empty dict '{}' to indicate sub-selection
    let l:dic = map(copy(s:use), '{}')
    " Set xgit
    let l:dic.xgit = { 'lst': [v:null, 'https://kgithub.com'] }
    " Set ui
    let l:fontlst = [
        \ 'Consolas',
        \ 'Consolas,CaskaydiaCove Nerd Font Mono',
        \ 'Consolas Nerd Font Mono',
        \ 'CaskaydiaCove Nerd Font Mono',
        \ 'agave Nerd Font Mono',
        \ 'FantasqueSansMono Nerd Font Mono',
        \ 'UbuntuMono Nerd Font Mono',
        \ 'Microsoft YaHei UI',
        \ 'Microsoft YaHei Mono',
        \ 'WenQuanYi Micro Hei Mono',
        \ ]
    let l:fontsizelst = [9, 10, 11, 12, 13, 14, 15]
    let l:dic.ui = {
        \ 'dsr' : 'set ui',
        \ 'lst' : sort(keys(s:use.ui)),
        \ 'dic' : {
            \ 'patch'    : {'lst' : [v:true, v:false]},
            \ 'font'     : {'dsr' : 'set guifont', 'lst' : l:fontlst},
            \ 'wide'     : {'dsr' : 'set guifontwide', 'lst' : l:fontlst},
            \ 'fontsize' : {'lst' : l:fontsizelst},
            \ 'widesize' : {'lst' : l:fontsizelst},
            \ },
        \ 'sub' : {
            \ 'cmd' : {sopt, sel -> extend(s:use.ui, {sopt : sel})},
            \ 'get' : {sopt -> s:use.ui[sopt]},
            \ },
        \ }

    call PopSelection({
        \ 'opt' : 'use',
        \ 'lst' : sort(keys(s:use)),
        \ 'dic' : l:dic,
        \ 'evt': funcref('s:useSave'),
        \ 'sub' : {
            \ 'lst' : [v:true, v:false],
            \ 'cmd' : {sopt, sel -> extend(s:use, {sopt : sel})},
            \ 'get' : {sopt -> s:use[sopt]},
            \ },
        \ })
endfunction
" }}}

command! -nargs=0 Use :call s:useInit()

call s:useLoad()
