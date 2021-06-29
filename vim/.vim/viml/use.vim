function! Sv_use()
    return s:use
endfunction

let s:use_file = $DotVimCachePath . '/.use.json'
let s:use = {
    \ 'powerfont' : v:false,
    \ 'lightline' : v:false,
    \ 'startify'  : v:false,
    \ 'ycm'       : v:false,
    \ 'snip'      : v:false,
    \ 'coc'       : v:false,
    \ 'coc_exts'  : {
        \ 'coc-snippets'      : v:false,
        \ 'coc-yank'          : v:false,
        \ 'coc-explorer'      : v:false,
        \ 'coc-json'          : v:false,
        \ 'coc-pyright'       : v:false,
        \ 'coc-java'          : v:false,
        \ 'coc-tsserver'      : v:false,
        \ 'coc-rust-analyzer' : v:false,
        \ 'coc-vimlsp'        : v:false,
        \ 'coc-lua'           : v:false,
        \ 'coc-vimtex'        : v:false,
        \ 'coc-cmake'         : v:false,
        \ 'coc-calc'          : v:false,
        \ },
    \ 'spector'   : v:false,
    \ 'leaderf'   : v:false,
    \ 'utils'     : v:false,
    \ }

" Function: s:useLoad() {{{
function! s:useLoad()
    if filereadable(s:use_file)
        call extend(s:use, json_decode(join(readfile(s:use_file))), 'force')
    else
        call s:useSave()
    endif
    if IsVim() && s:use.coc        " vim中coc容易卡，补全用ycm
        let s:use.ycm = v:true
        let s:use.coc = v:false
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
    " Set coc-extension selections
    let l:dic = map(copy(s:use), '{}')
    let l:dic.coc_exts = {
        \ 'dsr' : 'coc extensions',
        \ 'lst' : sort(keys(s:use.coc_exts)),
        \ 'dic' : map(copy(s:use.coc_exts), '{}'),
        \ 'sub' : {
            \ 'lst': [v:true, v:false],
            \ 'cmd': {sopt, sel -> extend(s:use.coc_exts, {sopt : sel})},
            \ 'get': {sopt -> s:use.coc_exts[sopt]},
            \ },
        \ 'onCR': funcref('s:useSave'),
        \ }

    call PopSelection({
        \ 'opt' : 'select use settings',
        \ 'lst' : sort(keys(s:use)),
        \ 'dic' : l:dic,
        \ 'sub' : {
            \ 'lst' : [v:true, v:false],
            \ 'cmd' : {sopt, sel -> extend(s:use, {sopt : sel})},
            \ 'get' : {sopt -> s:use[sopt]},
            \ },
        \ 'onCR': funcref('s:useSave'),
        \ })
endfunction
" }}}

command! -nargs=0 Use :call s:useInit()

call s:useLoad()
