"let s:use = SvarUse()

" Editor {{{
" easy-motion {{{ 快速跳转
let g:EasyMotion_dict = 'zh-cn'         " 支持简体中文拼音
let g:EasyMotion_do_mapping = 0         " 禁止默认map
let g:EasyMotion_smartcase = 1          " 不区分大小写
nmap s <Plug>(easymotion-overwin-f)
nmap f <Plug>(easymotion-bd-fl)
nmap <leader>ms <Plug>(easymotion-overwin-f2)
nmap <leader><leader>s <Plug>(easymotion-sn)
nmap <leader>j <Plug>(easymotion-bd-jk)
nmap <leader><leader>j <Plug>(easymotion-overwin-line)
nmap <leader>mw <Plug>(easymotion-bd-w)
" }}}

" signature {{{ 书签管理
let g:SignatureMap = {
    \ 'Leader'            : "m",
    \ 'PlaceNextMark'     : "m,",
    \ 'ToggleMarkAtLine'  : "m.",
    \ 'PurgeMarksAtLine'  : "m-",
    \ 'DeleteMark'        : '', 'PurgeMarks'        : '', 'PurgeMarkers'      : '',
    \ 'GotoNextLineAlpha' : '', 'GotoPrevLineAlpha' : '', 'GotoNextLineByPos' : '', 'GotoPrevLineByPos' : '',
    \ 'GotoNextSpotAlpha' : '', 'GotoPrevSpotAlpha' : '', 'GotoNextSpotByPos' : '', 'GotoPrevSpotByPos' : '',
    \ 'GotoNextMarker'    : '', 'GotoPrevMarker'    : '', 'GotoNextMarkerAny' : '', 'GotoPrevMarkerAny' : '',
    \ 'ListBufferMarks'   : '', 'ListBufferMarkers' : '',
    \ }
nnoremap <leader>ts :SignatureToggleSigns<CR>
nnoremap <leader>ma :SignatureListBufferMarks<CR>
nnoremap <leader>mc :call signature#mark#Purge('all')<CR>
nnoremap <leader>ml :call signature#mark#Purge('line')<CR>
nnoremap <M-,>      :call signature#mark#Goto('prev', 'line', 'pos')<CR>
nnoremap <M-.>      :call signature#mark#Goto('next', 'line', 'pos')<CR>
" }}}
" }}}

" Component {{{
" startify {{{ 启动首页
let g:startify_bookmarks = [
    \ {'c': '$DotVimDir/.init.vim'},
    \ {'d': '$NVimConfigDir/init.vim'},
    \ {'o': '$DotVimCache/todo.md'} ]
let g:startify_lists = [
    \ {'type': 'bookmarks', 'header': ['   Bookmarks']},
    \ {'type': 'files',     'header': ['   Recent Files']},
    \ ]
let g:startify_files_number = 8
let g:startify_custom_header = 'startify#pad(startify#fortune#cowsay(Plug_stt_todo(), "─", "│", "┌", "┐", "┘", "└"))'
nnoremap <leader>su :Startify<CR>

function! Plug_stt_todo()
    if filereadable($DotVimCache.'/todo.md')
        let l:todo = filter(readfile($DotVimCache.'/todo.md'), 'v:val !~ "\\m^[ \t]*$"')
        return empty(l:todo) ? '' : l:todo
    else
        return ''
    endif
endfunction
" }}}
" }}}

" Coding {{{
" colorizer {{{ 颜色预览
let g:colorizer_nomap = 1
let g:colorizer_startup = 0
nnoremap <leader>tc :ColorToggle<CR>
" }}}

" auto-pairs {{{ 自动括号
let g:AutoPairsShortcutToggle = ''
let g:AutoPairsShortcutFastWrap = ''
let g:AutoPairsShortcutJump = ''
let g:AutoPairsShortcutFastBackInsert = ''
nnoremap <leader>tp :call AutoPairsToggle()<CR>
" }}}

" nerdcommenter {{{ 批量注释
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 0               " 在Comment后添加Space
nmap <leader>ci <Plug>NERDCommenterInvert
nmap <leader>cl <Plug>NERDCommenterAlignBoth
nmap <leader>cu <Plug>NERDCommenterUncomment
nmap <leader>ct <Plug>NERDCommenterAltDelims
" }}}
" }}}

" Utils {{{
" }}}
