function! SvarUse()
    return s:use
endfunction

" Struct s:use {{{
let s:use_file = $DotVimLocal . '/use.json'
let s:use = {
    \ 'has_py' : v:false,
    \ 'nlsp'   : v:false,
    \ 'ndap'   : v:false,
    \ 'nts'    : v:false,
    \ 'pkgs'   : {
        \ 'coc'       : v:false,
        \ 'im_select' : v:false,
        \ },
    \ 'ui'     : {
        \ 'icon'      : v:false,
        \ 'font'      : { 'name': '', 'size': 12 },
        \ 'font_wide' : { 'name': '', 'size': 12 },
        \ },
    \ 'xgit'   : v:null,
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
    let l:dic.pkgs = {
        \ 'dsr' : 'set pkgs',
        \ 'lst' : sort(keys(s:use.pkgs)),
        \ 'dic' : map(copy(s:use.pkgs), '{}'),
        \ 'sub' : {
            \ 'lst' : [v:true, v:false],
            \ 'cmd' : {sopt, sel -> extend(s:use.pkgs, {sopt : sel})},
            \ 'get' : {sopt -> s:use.pkgs[sopt]},
            \ },
        \ }
    let l:fontnames = [
        \ 'Consolas',
        \ 'Consolas,Cousine Nerd Font Mono',
        \ 'Consolas Nerd Font Mono',
        \ 'FantasqueSansM Nerd Font Mono',
        \ 'Maple Mono NF CN',
        \ 'Microsoft YaHei UI',
        \ 'Microsoft YaHei Mono',
        \ 'WenQuanYi Micro Hei Mono',
        \ ]
    let l:fontsizes = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
    let l:dic.ui = {
        \ 'dsr' : 'set ui',
        \ 'lst' : ['icon', 'font', 'font_wide'],
        \ 'dic' : {
            \ 'icon'      : {'lst' : [v:true, v:false]},
            \ 'font'      : {
                \ 'dsr' : 'as guifont',
                \ 'lst' : ['name', 'size'],
                \ 'dic' : {
                    \ 'name' : { 'lst': l:fontnames },
                    \ 'size' : { 'lst': l:fontsizes },
                    \ },
                    \ 'sub' : {
                        \ 'cmd' : {sopt, sel -> extend(s:use.ui.font, {sopt : sel})},
                        \ 'get' : {sopt -> s:use.ui.font[sopt]},
                    \}
                \ },
            \ 'font_wide' : {
                \ 'dsr' : 'as guifontwide',
                \ 'lst' : ['name', 'size'],
                \ 'dic' : {
                    \ 'name' : { 'lst': l:fontnames },
                    \ 'size' : { 'lst': l:fontsizes },
                    \ },
                    \ 'sub' : {
                        \ 'cmd' : {sopt, sel -> extend(s:use.ui.font_wide, {sopt : sel})},
                        \ 'get' : {sopt -> s:use.ui.font_wide[sopt]},
                    \}
                \ },
            \ },
        \ 'sub' : {
            \ 'cmd' : {sopt, sel -> extend(s:use.ui, {sopt : sel})},
            \ 'get' : {sopt -> s:use.ui[sopt]},
            \ },
        \ }
    let l:dic.xgit = { 'lst': [v:null, 'https://kkgithub.com', 'https://bgithub.xyz'] }

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
