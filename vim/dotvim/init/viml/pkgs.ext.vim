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

" traces {{{ 预览增强
" 支持:s, :g, :v, :sort, :range预览
let g:traces_num_range_preview = 1      " 支持范围:N,M预览
" }}}

" textobj-user {{{ 文本对象
" v-ai-wWsp(b[<t{B"'`
" v-ai-ifcmu
let g:textobj_indent_no_default_key_mappings = 1
omap ai <Plug>(textobj-indent-a)
omap ii <Plug>(textobj-indent-i)
xmap ai <Plug>(textobj-indent-a)
xmap ii <Plug>(textobj-indent-i)
omap au <Plug>(textobj-underscore-a)
omap iu <Plug>(textobj-underscore-i)
xmap au <Plug>(textobj-underscore-a)
xmap iu <Plug>(textobj-underscore-i)
" }}}

" FastFold {{{ 更新折叠
let g:fastfold_savehook = 0             " 只允许手动更新folds
let g:fastfold_fold_command_suffixes = ['x','X','a','A','o','O','c','C']
let g:fastfold_fold_movement_commands = ['z[', 'z]', 'zj', 'zk']
                                        " 允许指定的命令更新folds
nmap <leader>zu <Plug>(FastFoldUpdate)
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
if s:use.ui.icon
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
    \ {'c': '$DotVimVimL/init.vim'},
    \ {'o': '$DotVimLocal/todo.md'} ]
let g:startify_lists = [
    \ {'type': 'bookmarks', 'header': ['   Bookmarks']},
    \ {'type': 'files',     'header': ['   Recent Files']},
    \ ]
let g:startify_files_number = 8
let g:startify_custom_header = 'startify#pad(startify#fortune#cowsay(PkgTodo(), "─", "│", "┌", "┐", "┘", "└"))'
nnoremap <leader>su :Startify<CR>

function! PkgTodo()
    if filereadable($DotVimLocal.'/todo.md')
        let l:todo = filter(readfile($DotVimLocal.'/todo.md'), 'v:val !~ "\\m^[ \t]*$"')
        return empty(l:todo) ? '' : l:todo
    else
        return ''
    endif
endfunction
" }}}

" rainbow {{{ 彩色括号
let g:rainbow_active = 1
nnoremap <leader>tr :RainbowToggle<CR>
" }}}

" indentLine {{{ 显示缩进标识
let g:indentLine_char = '⁞'             " 设置标识符样式
let g:indentLinet_color_term = 200      " 设置标识符颜色
let g:indentLine_concealcursor = 'nvic'
let g:indentLine_fileTypeExclude = ['startify', 'alpha']
nnoremap <leader>ti :IndentLinesToggle<CR>
" }}}
" }}}

" Coding {{{
" coc {{{ 自动补全
if s:use.coc
function! PkgSetupCoc(timer)
    call plug#load('coc.nvim')
    for [sec, val] in items(Env_coc_settings())
        call coc#config(sec, val)
    endfor
endfunction
call timer_start(700, 'PkgSetupCoc')
endif
" }}}

" Vista {{{ 代码Tags
let g:vista_echo_cursor = 0
let g:vista_stay_on_open = 0
let g:vista_disable_statusline = 1
nnoremap <leader>tv :Vista!!<CR>
" }}}

" asyncrun {{{ 导步运行程序
let g:asyncrun_open = 8                 " 自动打开quickfix window
let g:asyncrun_save = 1                 " 自动保存当前文件
let g:asyncrun_local = 1                " 使用setlocal的efm
nnoremap <leader><leader>r :AsyncRun<Space>
vnoremap <leader><leader>r <Cmd>call feedkeys(':AsyncRun ' . GetSelected(''), 'n')<CR>
nnoremap <leader>rk :AsyncStop<CR>
nnoremap <leader>rK :AsyncReset<CR>
" }}}

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

" ReStructruedText {{{
let g:riv_auto_format_table = 0
let g:riv_i_tab_pum_next = 0
let g:riv_ignored_imaps = '<Tab>,<S-Tab>,<CR>'
let g:riv_ignored_nmaps = '<Tab>,<S-Tab>,<CR>'
let g:riv_ignored_vmaps = '<Tab>,<S-Tab>,<CR>'
let g:instant_rst_browser = 'firefox'
if IsWin()
" 需要安装 https://github.com/mgedmin/restview
nnoremap <leader>vr
    \ <Cmd>
    \ execute ':AsyncRun restview ' . Expand('%', ':p:t') <Bar>
    \ cclose<CR>
else
" 需要安装 https://github.com/Rykka/instant-rst.py
nnoremap <leader>vr
    \ <Cmd>
    \ call Notify(g:_instant_rst_daemon_started ? 'Close rst' : 'Open rst') <Bar>
    \ execute g:_instant_rst_daemon_started ? 'StopInstantRst' : 'InstantRst'<CR>
endif
" }}}

" open-browser {{{ 在线搜索
let g:openbrowser_default_search = 'bing'
let g:openbrowser_search_engines = {'bing' : 'https://cn.bing.com/search?q={query}'}
map <leader>bs <Plug>(openbrowser-smart-search)
nnoremap <leader>big :OpenBrowserSearch -google<Space>
nnoremap <leader>bib :OpenBrowserSearch -bing<Space>
nnoremap <leader>bih :OpenBrowserSearch -github<Space>
nnoremap <leader>bb  <Cmd>call openbrowser#search(Expand('<cword>'), 'bing')<CR>
nnoremap <leader>bg  <Cmd>call openbrowser#search(Expand('<cword>'), 'google')<CR>
nnoremap <leader>bh  <Cmd>call openbrowser#search(Expand('<cword>'), 'github')<CR>
vnoremap <leader>bb  <Cmd>call openbrowser#search(GetSelected(' '), 'bing')<CR>
vnoremap <leader>bg  <Cmd>call openbrowser#search(GetSelected(' '), 'google')<CR>
vnoremap <leader>bh  <Cmd>call openbrowser#search(GetSelected(' '), 'github')<CR>
" }}}

" translator {{{ 翻译
let g:translator_default_engines = ['haici', 'bing', 'youdao']
nmap <Leader>tw <Plug>TranslateW
vmap <Leader>tw <Plug>TranslateWV
nnoremap <leader><leader>t :TranslateW<Space>
vnoremap <leader><leader>t <Cmd>call feedkeys(':TranslateW ' . GetSelected(' '), 'n')<CR>
highlight! default link TranslatorBorder Constant
" }}}

" im-select {{{ 输入法
if IsWin() || IsGw()
let g:im_select_get_im_cmd = 'im-select'
let g:im_select_default = '1033'        " 输入法代码：切换到期望的默认输入法，运行im-select
endif
let g:ImSelectSetImCmd = {key -> ['im-select', key]}
" }}}
" }}}

" Plug {{{
if !empty(s:use.xgit)
    let g:plug_url_format = s:use.xgit . '/%s.git'
endif
call plug#begin($DotVimDir.'/bundle')  " 设置插件位置，且自动设置了syntax enable和filetype plugin indent on
    " editor
    Plug 'andymass/vim-matchup'
    Plug 'yehuohan/vim-easymotion'
    Plug 'kshenoy/vim-signature'
    Plug 'RRethy/vim-illuminate'
    Plug 't9md/vim-textmanip'
    Plug 'psliwka/vim-smoothie'
    Plug 'tpope/vim-repeat'
    Plug 'mg979/vim-visual-multi'
    Plug 'markonm/traces.vim'
    Plug 'junegunn/vim-easy-align'
    Plug 'terryma/vim-expand-region'
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-indent'
    Plug 'glts/vim-textobj-comment'
    Plug 'adriaanzon/vim-textobj-matchit'
    Plug 'lucapette/vim-textobj-underscore'
    Plug 'Konfekt/FastFold'
    " component
    Plug 'yehuohan/lightline.vim'
    Plug 'mhinz/vim-startify'
if s:use.ui.icon
    Plug 'ryanoasis/vim-devicons'
endif
    Plug 'morhetz/gruvbox'
    Plug 'rakr/vim-one'
    Plug 'tanvirtin/monokai.nvim'
    Plug 'luochen1990/rainbow'
    Plug 'Yggdroot/indentLine'
    Plug 'yehuohan/popc'
    Plug 'yehuohan/popset'
    Plug 'yehuohan/popc-floaterm'
    Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTree']}
    Plug 'itchyny/screensaver.vim'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
if s:use.has_py
    Plug 'Yggdroot/LeaderF', {'do': IsWin() ? './install.bat' : './install.sh'}
endif
    " coding
    Plug 'lilydjwg/colorizer', {'on': 'ColorToggle'}
    Plug 'jiangmiao/auto-pairs'
    Plug 'scrooloose/nerdcommenter'
    Plug 'tpope/vim-surround'
if s:use.coc
    Plug 'neoclide/coc.nvim', {'branch': 'release', 'on': []}
    Plug 'neoclide/jsonc.vim'
endif
if s:use.has_py
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
endif
if s:use.ndap
    Plug 'puremourning/vimspector'
endif
    Plug 'liuchengxu/vista.vim', {'on': 'Vista'}
    Plug 't9md/vim-quickhl'
    Plug 'skywind3000/asyncrun.vim'
    Plug 'voldikss/vim-floaterm'
    Plug 'bfrg/vim-cpp-modern', {'for': ['c', 'cpp']}
    Plug 'rust-lang/rust.vim'
    Plug 'tikhomirov/vim-glsl'
    Plug 'beyondmarc/hlsl.vim', {'for': 'hlsl'}
    " utils
    Plug 'gabrielelana/vim-markdown', {'for': 'markdown'}
    Plug 'joker1007/vim-markdown-quote-syntax', {'for': 'markdown'}
    Plug 'iamcco/markdown-preview.nvim', {'for': 'markdown', 'do': { -> mkdp#util#install()}}
    Plug 'Rykka/riv.vim', {'for': 'rst'}
    Plug 'Rykka/InstantRst', {'for': 'rst'}
    Plug 'lervag/vimtex', {'for': 'tex'}
    Plug 'tyru/open-browser.vim'
    Plug 'voldikss/vim-translator'
    Plug 'brglng/vim-im-select'
call plug#end()
" }}}

try
    set background=dark
    colorscheme gruvbox
catch /^Vim\%((\a\+)\)\=:E185/
    silent! colorscheme default
endtry
