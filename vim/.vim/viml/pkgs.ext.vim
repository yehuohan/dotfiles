let s:use = SvarUse()

" Editor {{{
" easy-motion {{{ 快速跳转
let g:EasyMotion_dict = 'zh-cn'         " 支持简体中文拼音
let g:EasyMotion_do_mapping = 0         " 禁止默认map
let g:EasyMotion_smartcase = 1          " 不区分大小写
nmap s <Plug>(easymotion-overwin-f)
nmap f <Plug>(easymotion-bd-fl)
nmap <leader>ms <Plug>(easymotion-sn)
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

" illuminate {{{ 自动高亮
let g:Illuminate_useDeprecated = 1
let g:Illuminate_delay = 200
let g:Illuminate_ftblacklist = ['nerdtree', 'NvimTree']
nnoremap <leader>tg :IlluminationToggle<CR>
highlight link illuminatedWord MatchParen
" }}}

" textmanip {{{ 块编辑
let g:textmanip_enable_mappings = 0
" 切换Insert/Replace Mode
xnoremap <M-o>
    \ <Cmd>
    \ let g:textmanip_current_mode = (g:textmanip_current_mode == 'replace') ? 'insert' : 'replace' <Bar>
    \ call Notify('textmanip mode: ' . g:textmanip_current_mode)<CR>
xmap <C-o> <M-o>
" 更据Mode使用Move-Insert或Move-Replace
xmap <C-j> <Plug>(textmanip-move-down)
xmap <C-k> <Plug>(textmanip-move-up)
xmap <C-h> <Plug>(textmanip-move-left)
xmap <C-l> <Plug>(textmanip-move-right)
" 更据Mode使用Duplicate-Insert或Duplicate-Replace
xmap <M-j> <Plug>(textmanip-duplicate-down)
xmap <M-k> <Plug>(textmanip-duplicate-up)
xmap <M-h> <Plug>(textmanip-duplicate-left)
xmap <M-l> <Plug>(textmanip-duplicate-right)
" }}}

" smoothie {{{ 平滑滚动
let g:smoothie_no_default_mappings = v:true
let g:smoothie_update_interval = 30
let g:smoothie_base_speed = 20
nmap <M-n> <Plug>(SmoothieDownwards)
nmap <M-m> <Plug>(SmoothieUpwards)
nmap <M-j> <Plug>(SmoothieForwards)
nmap <M-k> <Plug>(SmoothieBackwards)
" }}}
" }}}

" Component {{{
" lightline {{{ StatusLine
let g:lightline = {
    \ 'enable' : {'statusline': 1, 'tabline': 0},
    \ 'colorscheme' : 'gruvbox',
    \ 'active': {
            \ 'left' : [['mode'], [],
            \           ['msg_left']],
            \ 'right': [['chk_trailing', 'chk_indent', 'all_info'],
            \           ['all_format'],
            \           ['msg_right']],
            \ },
    \ 'inactive': {
            \ 'left' : [['absolutepath']],
            \ 'right': [['lite_info']],
            \ },
    \ 'tabline' : {
            \ 'left' : [['tabs']],
            \ 'right': [['close']],
            \ },
    \ 'component': {
            \ 'all_format': '%{&ft!=#""?&ft."/":""}%{&fenc!=#""?&fenc:&enc}/%{&ff}',
            \ 'all_info'  : 'U%-2B %p%% %l/%L $%v %{winnr()}.%n%{&mod?"+":""}',
            \ 'lite_info' : '%l/%L $%v %{winnr()}.%n%{&mod?"+":""}',
            \ },
    \ 'component_function': {
            \ 'mode'      : 'PkgMode',
            \ 'msg_left'  : 'PkgMsgLeft',
            \ 'msg_right' : 'PkgMsgRight',
            \ },
    \ 'component_expand': {
            \ 'chk_indent'  : 'PkgCheckMixedIndent',
            \ 'chk_trailing': 'PkgCheckTrailing',
            \ },
    \ 'component_type': {
            \ 'chk_indent'  : 'error',
            \ 'chk_trailing': 'error',
            \ },
    \ 'fallback' : {'Popc': 0, 'vista': 'Vista', 'nerdtree': 'NerdTree', 'NvimTree': 'NvimTree'},
    \ }
if s:use.ui.patch
let g:lightline.separator            = {'left': '', 'right': ''}
let g:lightline.subseparator         = {'left': '', 'right': ''}
let g:lightline.tabline_separator    = {'left': '', 'right': ''}
let g:lightline.tabline_subseparator = {'left': '', 'right': ''}
let g:lightline.component = {
        \ 'all_format': '%{&ft!=#""?&ft."":""}%{&fenc!=#""?&fenc:&enc}%{&ff}',
        \ 'all_info'  : 'U%-2B %p%% %l/%L %v %{winnr()}.%n%{&mod?"+":""}',
        \ 'lite_info' : '%l/%L %v %{winnr()}.%n%{&mod?"+":""}',
        \ }
endif

nnoremap <leader>tl :call lightline#toggle()<CR>
nnoremap <leader>tk
    \ <Cmd>
    \ let b:statusline_check_enabled = !get(b:, 'statusline_check_enabled', v:true) <Bar>
    \ call lightline#update() <Bar>
    \ call Notify('b:statusline_check_enabled = ' . b:statusline_check_enabled)<CR>

" Augroup: Lightline {{{
augroup PkgLightline
    autocmd!
    autocmd ColorScheme * call PkgOnColorScheme()
    autocmd CursorHold,BufWritePost * call PkgCheckRefresh()
augroup END

function! PkgOnColorScheme()
    if !exists('g:loaded_lightline')
        return
    endif
    try
        let g:lightline.colorscheme = g:colors_name
        call lightline#init()
        call lightline#colorscheme()
        call lightline#update()
    catch /^Vim\%((\a\+)\)\=:E117/      " E117: 函数不存在
    endtry
endfunction

function! PkgCheckRefresh()
    if !exists('g:loaded_lightline') || get(b:, 'lightline_changedtick', 0) == b:changedtick
        return
    endif
    unlet! b:lightline_changedtick
    call lightline#update()
    let b:lightline_changedtick = b:changedtick
endfunction
" }}}

" Function: lightline components {{{
function! PkgMode()
    return &ft ==# 'Popc' ? 'Popc' :
        \ &ft ==# 'alpha' ? 'Alpha' :
        \ &ft ==# 'startify' ? 'Startify' :
        \ &ft ==# 'qf' ? (QuickfixType() ==# 'c' ? 'Quickfix' : 'Location') :
        \ &ft ==# 'help' ? 'Help' :
        \ lightline#mode()
endfunction

function! PkgMsgLeft()
    return substitute(Expand('%', ':p'), '^' . escape(Expand(SvarWs().fw.path), '\'), '', '')
endfunction

function! PkgMsgRight()
    return SvarWs().fw.path
endfunction

function! PkgCheckMixedIndent()
    if !get(b:, 'statusline_check_enabled', v:true)
        return ''
    endif
    let l:ret = search('\m\(\t \| \t\)', 'nw')
    return (l:ret == 0) ? '' : 'M:'.string(l:ret)
endfunction

function! PkgCheckTrailing()
    if !get(b:, 'statusline_check_enabled', v:true)
        return ''
    endif
    let ret = search('\m\s\+$', 'nw')
    return (l:ret == 0) ? '' : 'T:'.string(l:ret)
endfunction
" }}}
" }}}

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
let g:startify_custom_header = 'startify#pad(startify#fortune#cowsay(PkgTodo(), "─", "│", "┌", "┐", "┘", "└"))'
nnoremap <leader>su :Startify<CR>

function! PkgTodo()
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

" surround {{{ 添加包围符
let g:surround_no_mappings = 1
xmap vs  <Plug>VSurround
xmap vS  <Plug>VgSurround
nmap ys  <Plug>Ysurround
nmap yS  <Plug>YSurround
nmap <leader>sw ysiw
nmap <leader>sW ySiw
nmap ysl <Plug>Yssurround
nmap ysL <Plug>YSsurround
nmap ds  <Plug>Dsurround
nmap cs  <Plug>Csurround
" }}}
" }}}

" Utils {{{
" MarkDown {{{
let g:markdown_include_jekyll_support = 0
let g:markdown_enable_mappings = 0
let g:markdown_enable_spell_checking = 0
let g:markdown_enable_folding = 0       " 感觉MarkDown折叠引起卡顿时，关闭此项
let g:markdown_enable_conceal = 0       " 在Vim中显示MarkDown预览
let g:markdown_enable_input_abbreviations = 0
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 1
let g:mkdp_refresh_slow = 0             " 即时预览MarkDown
let g:mkdp_command_for_global = 0       " 只有markdown文件可以预览
let g:mkdp_browser = 'firefox'
nnoremap <leader>vm
    \ <Cmd>
    \ call Notify(get(b:, 'MarkdownPreviewToggleBool') ? 'Close markdown preview' : 'Open markdown preview') <Bar>
    \ call mkdp#util#toggle_preview()<CR>
nnoremap <leader>tb
    \ <Cmd>
    \ let g:mkdp_browser = (g:mkdp_browser ==# 'firefox') ? 'chrome' : 'firefox' <Bar>
    \ call Notify('Browser: ' . g:mkdp_browser)<CR>
" }}}
" }}}
