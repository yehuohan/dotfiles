function! SvarUse()
    return s:use
endfunction

" Struct s:use {{{
let s:use_file = $DotVimCache . '/.use.json'
let s:use = {
    \ 'fastgit'   : v:false,
    \ 'lightline' : v:false,
    \ 'coc'       : v:false,
    \ 'coc_exts'  : {
        \ 'coc-snippets'      : v:false,
        \ 'coc-yank'          : v:false,
        \ 'coc-json'          : v:false,
        \ 'coc-clangd'        : v:false,
        \ 'coc-rust-analyzer' : v:false,
        \ 'coc-pyright'       : v:false,
        \ 'coc-java'          : v:false,
        \ 'coc-tsserver'      : v:false,
        \ 'coc-vimlsp'        : v:false,
        \ 'coc-lua'           : v:false,
        \ 'coc-toml'          : v:false,
        \ 'coc-vimtex'        : v:false,
        \ 'coc-cmake'         : v:false,
        \ 'coc-calc'          : v:false,
        \ 'coc-spell-checker' : v:false,
        \ },
    \ 'nlsp'      : v:false,
    \ 'treesitter': v:false,
    \ 'snip'      : v:false,
    \ 'spector'   : v:false,
    \ 'leaderf'   : v:false,
    \ 'ui'        : {
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
        if has_key(l:dic, 'coc_exts')
            call extend(s:use.coc_exts, l:dic.coc_exts)
            unlet l:dic.coc_exts
        endif
        call extend(s:use, l:dic)
    else
        call s:useSave()
    endif
    if IsVim()
        let s:use.ui.font = 'Consolas For Powerline'
        let s:use.ui.wide = 'Microsoft YaHei Mono'
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
            \ 'lst' : [v:true, v:false],
            \ 'cmd' : {sopt, sel -> extend(s:use.coc_exts, {sopt : sel})},
            \ 'get' : {sopt -> s:use.coc_exts[sopt]},
            \ },
        \ 'onCR': funcref('s:useSave'),
        \ }

    " Set ui selections
    let l:fontlst = [
        \ 'Consolas',
        \ 'Consolas Nerd Font Mono',
        \ 'agave Nerd Font Mono',
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
