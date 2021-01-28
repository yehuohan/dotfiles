"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" .init.vim: configuration for vim and neovim.
" Github: https://github.com/yehuohan/dotconfigs
" Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Platforms {{{
function! IsLinux()
    return (has('unix') && !has('macunix') && !has('win32unix'))
endfunction
function! IsWin()
    return (has('win32') || has('win64'))
endfunction
function! IsGw()
    return has('win32unix')
endfunction
function! IsMac()
    return has('mac')
endfunction
function! IsVim()
    return !(has('nvim'))
endfunction
function! IsNVim()
    return has('nvim')
endfunction
function! IsGVim()
    return has('gui_running')
endfunction
function! IsNVimQt()
    return exists('g:GuiLoaded')        " 在UIEnter之后才起作用
endfunction
" }}} End

" Globals {{{
let $DotVimPath=resolve(expand('<sfile>:p:h'))
let $DotVimCachePath=$DotVimPath . '/.cache'
set rtp+=$DotVimPath

" First {{{
set encoding=utf-8                      " 内部使用utf-8编码
set nocompatible                        " 不兼容vi
set guioptions=M                        " 完全禁用Gui界面元素
let g:did_install_default_menus = 1     " 禁止加载缺省菜单
let g:did_install_syntax_menu = 1       " 禁止加载Syntax菜单
syntax enable                           " 打开语法高亮
filetype plugin indent on               " 打开文件类型检测
let mapleader="\<Space>"                " Space leader
nnoremap ; :
vnoremap ; :
nnoremap : ;
set timeout                             " 打开映射超时检测
set ttimeout                            " 打开键码超时检测
set timeoutlen=1000                     " 映射超时时间为1000ms
set ttimeoutlen=70                      " 键码超时时间为70ms
if IsVim()
    " 终端Alt键映射处理：如 Alt+x，实际连续发送 <Esc>x 的键码
    "<1> set <M-x>=x                  " 设置键码，这里的是一个字符，即<Esc>的键码（按i-C-v, i-C-[输入）
    "    nnoremap <M-x>  :CmdTest<CR>   " 按键码超时时间检测
    "<2> nnoremap <Esc>x :CmdTest<CR>   " 按映射超时时间检测
    "<3> nnoremap x    :CmdTest<CR>   " 按映射超时时间检测
    for t in split('q w e r t y u i o p a s d f g h j k l z x c v b n m ; , .', ' ')
        execute 'set <M-'. t . '>=' . t
    endfor
endif
" }}}

" Struct: s:gset {{{
let s:gset_file = $DotVimCachePath . '/.gset.json'
let s:gset = {
    \ 'set_dev'       : v:null,
    \ 'set_os'        : v:null,
    \ 'use_powerfont' : 1,
    \ 'use_lightline' : 1,
    \ 'use_startify'  : 1,
    \ 'use_ycm'       : 1,
    \ 'use_snip'      : 1,
    \ 'use_coc'       : 1,
    \ 'use_spector'   : 1,
    \ 'use_leaderf'   : 1,
    \ 'use_utils'     : 1,
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
    call env#env(s:gset.set_dev, s:gset.set_os)
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
            \ 'set_dev': {'lst': ['hp']         },
            \ 'set_os' : {'lst': ['win', 'arch']},
            \ 'use_powerfont': {}, 'use_lightline': {}, 'use_startify': {}, 'use_utils': {},
            \ 'use_ycm': {}, 'use_snip': {}, 'use_coc': {}, 'use_spector': {}, 'use_leaderf': {},
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
" }}}
" }}} End

" Plugins {{{
" Struct: s:plug {{{
let s:plug = {
    \ 'onVimEnter' : {'exec': []},
    \ 'onDelay'    : {'delay': 700, 'load': [], 'exec': []},
    \ }
" Function: s:plug.reg(event, type, name) dict {{{
function! s:plug.reg(event, type, name) dict
    call add(self[a:event][a:type], a:name)
endfunction
" }}}

" Function: s:plug.run(timer) dict {{{
function! s:plug.run(timer) dict
    call plug#load(self.onDelay.load)
    call execute(self.onDelay.exec)
endfunction
" }}}

" Function: s:plug.init() dict {{{
function! s:plug.init() dict
    if !empty(self.onVimEnter.exec)
        augroup PluginPlug
            autocmd!
            autocmd VimEnter * call execute(s:plug.onVimEnter.exec)
        augroup END
    endif
    if !empty(self.onDelay.load)
        call timer_start(self.onDelay.delay, funcref('s:plug.run', [], s:plug))
    endif
endfunction
" }}}
" }}}

" Plug {{{
call plug#begin($DotVimPath.'/bundle')  " 设置插件位置
    " editing
    Plug 'yehuohan/vim-easymotion'
    Plug 'rhysd/clever-f.vim'
    Plug 'mg979/vim-visual-multi'
    Plug 't9md/vim-textmanip'
    Plug 'markonm/traces.vim'
    Plug 'godlygeek/tabular', {'on': 'Tabularize'}
    Plug 'junegunn/vim-easy-align'
    Plug 'psliwka/vim-smoothie'
    Plug 'terryma/vim-expand-region'
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-indent'
    Plug 'kana/vim-textobj-function'
    Plug 'glts/vim-textobj-comment'
    Plug 'adriaanzon/vim-textobj-matchit'
    Plug 'lucapette/vim-textobj-underscore'
    Plug 'tpope/vim-repeat'
    Plug 'kshenoy/vim-signature'
    Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
    " managers
    Plug 'morhetz/gruvbox'
    Plug 'rakr/vim-one'
if s:gset.use_lightline
    Plug 'yehuohan/lightline.vim'
endif
    Plug 'luochen1990/rainbow'
    Plug 'Yggdroot/indentLine'
    Plug 'yehuohan/popc'
    Plug 'yehuohan/popset'
    Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTree']}
    Plug 'mhinz/vim-startify'
    Plug 'itchyny/screensaver.vim'
if IsWin()
    Plug 'junegunn/fzf', {'on': ['FzfFiles', 'FzfRg', 'FzfTags']}
endif
    Plug 'junegunn/fzf.vim', {'on': ['FzfFiles', 'FzfRg', 'FzfTags']}
if s:gset.use_leaderf
    Plug 'Yggdroot/LeaderF', {'do': IsWin() ? './install.bat' : './install.sh'}
endif
    " codings
if s:gset.use_ycm
    function! Plug_ycm_build(info)
        " (first installed) or (PlugInstall! or PlugUpdate!)
        if a:info.status == 'installed' || a:info.force
            if IsWin()
                !python install.py --clangd-completer --msvc 15 --build-dir ycm_build
            else
                !python install.py --clangd-completer --build-dir ycm_build
            endif
        endif
    endfunction
    Plug 'ycm-core/YouCompleteMe', {'do': function('Plug_ycm_build'), 'on': []}
endif
if s:gset.use_snip
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
endif
if s:gset.use_coc
    Plug 'neoclide/coc.nvim', {'branch': 'release', 'on': []}
    Plug 'neoclide/jsonc.vim'
endif
    Plug 'jiangmiao/auto-pairs'
    Plug 'sbdchd/neoformat', {'on': 'Neoformat'}
    Plug 'tpope/vim-surround'
    Plug 'majutsushi/tagbar', {'on': 'TagbarToggle'}
    Plug 'scrooloose/nerdcommenter'
    Plug 'skywind3000/asyncrun.vim'
    Plug 'skywind3000/asyncrun.extra'
    Plug 'tpope/vim-fugitive', {'on': ['G', 'Git']}
    Plug 'voldikss/vim-floaterm'
    Plug 'yehuohan/popc-floaterm'
if s:gset.use_spector
    Plug 'puremourning/vimspector'
endif
    Plug 't9md/vim-quickhl'
    Plug 'RRethy/vim-illuminate'
if IsVim()
    Plug 'lilydjwg/colorizer', {'on': 'ColorToggle'}
else
    Plug 'norcalli/nvim-colorizer.lua', {'on': 'ColorizerToggle'}
endif
    Plug 'Konfekt/FastFold'
    Plug 'JuliaEditorSupport/julia-vim', {'for': 'julia'}
    Plug 'bfrg/vim-cpp-modern', {'for': ['c', 'cpp']}
    Plug 'rust-lang/rust.vim'
    Plug 'tikhomirov/vim-glsl'
    " utils
if s:gset.use_utils
    Plug 'yianwillis/vimcdoc', {'for': 'help'}
    Plug 'gabrielelana/vim-markdown', {'for': 'markdown'}
    Plug 'iamcco/markdown-preview.nvim', {'for': 'markdown', 'do': { -> mkdp#util#install()}}
    Plug 'joker1007/vim-markdown-quote-syntax', {'for': 'markdown'}
    Plug 'Rykka/riv.vim', {'for': 'rst'}
    Plug 'Rykka/InstantRst', {'for': 'rst'}
    Plug 'lervag/vimtex', {'for': 'tex'}
    Plug 'tyru/open-browser.vim'
    Plug 'arecarn/vim-crunch'
    Plug 'arecarn/vim-selection'
    Plug 'voldikss/vim-translator'
    Plug 'brglng/vim-im-select'
endif
call plug#end()
" }}}

" Editing {{{
" easy-motion {{{ 快速跳转
    let g:EasyMotion_dict = 'zh-cn'     " 支持简体中文拼音
    let g:EasyMotion_do_mapping = 0     " 禁止默认map
    let g:EasyMotion_smartcase = 1      " 不区分大小写
    nmap s <Plug>(easymotion-overwin-f)
    nmap <leader>ms <Plug>(easymotion-overwin-f2)
    nmap <leader>j <Plug>(easymotion-j)
    nmap <leader>k <Plug>(easymotion-k)
    nmap <leader>mw <Plug>(easymotion-w)
    nmap <leader>mb <Plug>(easymotion-b)
    nmap <leader>me <Plug>(easymotion-e)
    nmap <leader>mg <Plug>(easymotion-ge)
" }}}

" clever-f {{{ 行跳转
    let g:clever_f_show_prompt = 1
" }}}

" vim-visual-multi {{{ 多光标编辑
    " Usage: https://github.com/mg979/vim-visual-multi/wiki
    " Tab: 切换cursor/extend模式
    " C-n: 添加word或selected region作为cursor
    " C-Up/Down: 移动当前position并添加cursor
    " <VM_leader>A: 查找当前word作为cursor
    " <VM_leader>/: 查找regex作为cursor（n/N用于查找下/上一个）
    " <VM_leader>\: 添加当前position作为cursor（使用/或arrows跳转位置）
    " <VM_leader>a <VM_leader>c: 添加visual区域作为cursor
    " s: 文本对象（类似于viw等）
    let g:VM_mouse_mappings = 0         " 禁用鼠标
    let g:VM_leader = '\'
    let g:VM_maps = {
        \ 'Find Under'         : '<C-n>',
        \ 'Find Subword Under' : '<C-n>',
        \ }
    let g:VM_custom_remaps = {
        \ '<C-p>': '[',
        \ '<C-s>': 'q',
        \ '<C-c>': 'Q',
        \ }
" }}}

" textmanip {{{ 块编辑
    let g:textmanip_enable_mappings = 0
    " 切换Insert/Replace Mode
    xnoremap <silent> <M-o>
        \ :<C-U>let g:textmanip_current_mode =
        \   (g:textmanip_current_mode == 'replace') ? 'insert' : 'replace'<Bar>
        \ :echo 'textmanip mode: ' . g:textmanip_current_mode<CR>gv
    xmap <silent> <C-o> <M-o>
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

" traces {{{ 预览增强
    " 支持:s, :g, :v, :sort, :range预览
" }}}

" tabular {{{ 字符对齐
    " /,/r2l0   -   第1个field使用第1个对齐符（右对齐），再插入2个空格
    "               第2个field使用第2个对齐符（左对齐），再插入0个空格
    "               第3个field又重新从第1个对齐符开始（对齐符可以有多个，循环使用）
    "               这样就相当于：需对齐的field使用第1个对齐符，分割符(,)field使用第2个对齐符
    " /,\zs     -   将分割符(,)作为对齐内容field里的字符
    nnoremap <leader><leader>a :Tabularize /
    vnoremap <leader><leader>a :Tabularize /
" }}}

" easy-align {{{ 字符对齐
    " 默认对齐内含段落（Text Object: vip）
    nmap <leader>ga <Plug>(EasyAlign)ip
    xmap <leader>ga <Plug>(EasyAlign)
    " 命令格式
    ":EasyAlign[!] [N-th]DELIMITER_KEY[OPTIONS]
    ":EasyAlign[!] [N-th]/REGEXP/[OPTIONS]
    nnoremap <silent> <leader><leader>g
        \ :call feedkeys(':' . join(GetRange('^[ \t]*$', '^[ \t]*$'), ',') . 'EasyAlign', 'n')<CR>
    vnoremap <leader><leader>g :EasyAlign
" }}}

" smoothie {{{ 平滑滚动
    let g:smoothie_no_default_mappings = v:true
    let g:smoothie_update_interval = 30
    let g:smoothie_base_speed = 20
    nmap <silent> <M-n> <Plug>(SmoothieDownwards)
    nmap <silent> <M-m> <Plug>(SmoothieUpwards)
    nmap <silent> <M-j> <Plug>(SmoothieForwards)
    nmap <silent> <M-k> <Plug>(SmoothieBackwards)
" }}}

" expand-region {{{ 快速块选择
    nmap <C-p> <Plug>(expand_region_expand)
    vmap <C-p> <Plug>(expand_region_expand)
    nmap <C-u> <Plug>(expand_region_shrink)
    vmap <C-u> <Plug>(expand_region_shrink)
" }}}

" textobj-user {{{ 文本对象
    " vdc-ia-wWsp(b[<t{B"'`
    " vdc-ia-ifcmu
    let g:textobj_indent_no_default_key_mappings = 1
    omap aI <Plug>(textobj-indent-a)
    omap iI <Plug>(textobj-indent-i)
    omap ai <Plug>(textobj-indent-same-a)
    omap ii <Plug>(textobj-indent-same-i)
    vmap aI <Plug>(textobj-indent-a)
    vmap iI <Plug>(textobj-indent-i)
    vmap ai <Plug>(textobj-indent-same-a)
    vmap ii <Plug>(textobj-indent-same-i)
    omap au <Plug>(textobj-underscore-a)
    omap iu <Plug>(textobj-underscore-i)
    vmap au <Plug>(textobj-underscore-a)
    vmap iu <Plug>(textobj-underscore-i)
    nnoremap <leader>tv :call Plug_to_motion('v')<CR>
    nnoremap <leader>tV :call Plug_to_motion('V')<CR>
    nnoremap <leader>td :call Plug_to_motion('d')<CR>
    nnoremap <leader>tD :call Plug_to_motion('D')<CR>

    function! Plug_to_motion(motion)
        call PopSelection({
            \ 'opt' : 'select text object motion',
            \ 'lst' : split('w W s p ( b [ < t { B " '' ` i f c m u', ' '),
            \ 'cmd' : {sopt, sel -> execute('normal! ' . tolower(a:motion) . (a:motion =~# '\l' ? 'i' : 'a' ) . sel)}
            \ })
    endfunction
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

" undotree {{{ 撤消历史
    nnoremap <leader>tu :UndotreeToggle<CR>
" }}}
" }}}

" Manager {{{
" theme {{{ Vim主题(ColorScheme, StatusLine, TabLine)
    let g:gruvbox_contrast_dark='soft'  " 背景选项：dark, medium, soft
    let g:gruvbox_italic = 1
    let g:one_allow_italics = 1
    try
        set background=dark
        colorscheme gruvbox
    catch /^Vim\%((\a\+)\)\=:E185/      " E185: 找不到主题
        silent! colorscheme default
    endtry
if s:gset.use_lightline
    let g:lightline = {
        \ 'enable' : {'statusline': 1, 'tabline': 0},
        \ 'colorscheme' : 'gruvbox',
        \ 'active': {
                \ 'left' : [['mode'],
                \           ['all_filesign'],
                \           ['msg_left']],
                \ 'right': [['chk_trailing', 'chk_indent', 'all_lineinfo'],
                \           ['all_format'],
                \           ['msg_right']],
                \ },
        \ 'inactive': {
                \ 'left' : [['msg_left']],
                \ 'right': [['lite_info'],
                \           ['msg_right']],
                \ },
        \ 'tabline' : {
                \ 'left' : [['tabs']],
                \ 'right': [['close']],
                \ },
        \ 'component': {
                \ 'all_filesign': '%{winnr()},%-n%{&ro?",":""}%M',
                \ 'all_format'  : '%{&ft!=#""?&ft."":""}%{&fenc!=#""?&fenc:&enc}%{&ff}',
                \ 'all_lineinfo': 'U%B %p%% %l/%L %v',
                \ 'lite_info'   : '%l/%L %v',
                \ },
        \ 'component_function': {
                \ 'mode'        : 'Plug_ll_mode',
                \ 'msg_left'    : 'Plug_ll_msgLeft',
                \ 'msg_right'   : 'Plug_ll_msgRight',
                \ },
        \ 'component_expand': {
                \ 'chk_indent'  : 'Plug_ll_checkMixedIndent',
                \ 'chk_trailing': 'Plug_ll_checkTrailing',
                \ },
        \ 'component_type': {
                \ 'chk_indent'  : 'error',
                \ 'chk_trailing': 'error',
                \ },
        \ 'fallback' : {'tagbar': 0, 'nerdtree': 0, 'Popc': 0, 'coc-explorer': '%{getcwd()}'},
        \ }
    if s:gset.use_powerfont
        let g:lightline.separator            = {'left': '', 'right': ''}
        let g:lightline.subseparator         = {'left': '', 'right': ''}
        let g:lightline.tabline_separator    = {'left': '', 'right': ''}
        let g:lightline.tabline_subseparator = {'left': '', 'right': ''}
    endif
    nnoremap <leader>tl :call lightline#toggle()<CR>
    nnoremap <leader>tk :call Plug_ll_toggleCheck()<CR>

    " Augroup: PluginLightline {{{
    augroup PluginLightline
        autocmd!
        autocmd ColorScheme * call Plug_ll_colorScheme()
        autocmd CursorHold,BufWritePost * call Plug_ll_checkRefresh()
    augroup END

    function! Plug_ll_colorScheme()
        if !exists('g:loaded_lightline')
            return
        endif
        try
            let g:lightline.colorscheme = g:colors_name
            call lightline#init()
            call lightline#colorscheme()
            call lightline#update()
        catch /^Vim\%((\a\+)\)\=:E117/  " E117: 函数不存在
        endtry
    endfunction

    function! Plug_ll_checkRefresh()
        if get(b:, 'lightline_changedtick', 0) == b:changedtick
            return
        endif
        unlet! b:lightline_changedtick
        call lightline#update()
        let b:lightline_changedtick = b:changedtick
    endfunction
    " }}}

    " Function: Plug_ll_toggleCheck() {{{
    function! Plug_ll_toggleCheck()
        let b:lightline_check_flg = !get(b:, 'lightline_check_flg', 1)
        call lightline#update()
        echo 'b:lightline_check_flg = ' . b:lightline_check_flg
    endfunction
    " }}}

    " Function: lightline components {{{
    function! Plug_ll_mode()
        return &ft ==# 'tagbar' ? 'Tagbar' :
            \ &ft ==# 'nerdtree' ? 'NERDTree' :
            \ &ft ==# 'qf' ? (QuickfixGet()[0] ==# 'c' ? 'Quickfix' : 'Location') :
            \ &ft ==# 'help' ? 'Help' :
            \ &ft ==# 'Popc' ? 'Popc' :
            \ &ft ==# 'startify' ? 'Startify' :
            \ winwidth(0) > 60 ? lightline#mode() : ''
    endfunction

    function! Plug_ll_msgLeft()
        if &ft ==# 'qf'
            return 'cwd = ' . getcwd()
        else
            let l:fp = expand('%:p')
            return empty(s:ws.fw.path) ? l:fp :
                \ substitute(l:fp, escape(s:ws.fw.path, '\'), '', '')
        endif
    endfunction

    function! Plug_ll_msgRight()
        return empty(s:ws.fw.path) ? '' :
            \ printf('%s[%s(%s)]', s:ws.fw.path, join(s:ws.fw.filters, ','), join(s:ws.fw.globlst, ','))
    endfunction

    function! Plug_ll_checkMixedIndent()
        if !get(b:, 'lightline_check_flg', 1)
            return ''
        endif
        let l:ret = search('\m\(\t \| \t\)', 'nw')
        return (l:ret == 0) ? '' : 'M:'.string(l:ret)
    endfunction

    function! Plug_ll_checkTrailing()
        if !get(b:, 'lightline_check_flg', 1)
            return ''
        endif
        let ret = search('\m\s\+$', 'nw')
        return (l:ret == 0) ? '' : 'T:'.string(l:ret)
    endfunction
    " }}}
endif
" }}}

" rainbow {{{ 彩色括号
    let g:rainbow_active = 1
    nnoremap <leader>tr :RainbowToggle<CR>
    augroup PluginRainbow
        autocmd!
        autocmd Filetype cmake RainbowToggleOff
    augroup END
" }}}

" indentLine {{{ 显示缩进标识
    "let g:indentLine_char = '|'        " 设置标识符样式
    let g:indentLinet_color_term = 200  " 设置标识符颜色
    nnoremap <leader>ti :IndentLinesToggle<CR>
" }}}

" popset {{{ 弹出选项
    let g:Popset_SelectionData = [{
            \ 'opt' : ['filetype', 'ft'],
            \ 'dsr' : 'When this option is set, the FileType autocommand event is triggered.',
            \ 'lst' : ['vim', 'make', 'markdown', 'conf',  'json', 'help'],
            \ 'dic' : {
                    \ 'vim'      : 'Vim script file',
                    \ 'make'     : 'Makefile of .mak file',
                    \ 'markdown' : 'MarkDown file',
                    \ 'conf'     : 'Config file',
                    \ 'json'     : 'Json file',
                    \ 'help'     : 'Vim help doc',
                    \},
            \ 'cmd' : 'popset#data#SetEqual',
            \ 'get' : 'popset#data#GetOptValue'
        \}, {
            \ 'opt' : ['colorscheme', 'colo'],
            \ 'lst' : ['gruvbox', 'one'],
        \}
    \ ]
    nnoremap <leader><leader>p :PopSet<Space>
    nnoremap <leader>sp :PopSet popset<CR>
" }}}

" popc {{{ buffer管理
    let g:Popc_jsonPath = $DotVimCachePath
    let g:Popc_useFloatingWin = 1
    let g:Popc_highlight = {
        \ 'text'     : 'Pmenu',
        \ 'selected' : 'CursorLineNr',
        \ }
    let g:Popc_useTabline = 1
    let g:Popc_useStatusline = 1
    let g:Popc_usePowerFont = s:gset.use_powerfont
    let g:Popc_separator = {'left' : '', 'right': ''}
    let g:Popc_subSeparator = {'left' : '', 'right': ''}
    let g:Popc_useLayerPath = 0
    let g:Popc_useLayerRoots = ['.popc', '.git', '.svn', '.hg', 'tags', '.LfGtags']
    let g:Popc_enableLog = 1
    nnoremap <leader><leader>h :PopcBuffer<CR>
    nnoremap <M-i> :PopcBufferSwitchLeft<CR>
    nnoremap <M-o> :PopcBufferSwitchRight<CR>
    nnoremap <C-i> :PopcBufferJumpPrev<CR>
    nnoremap <C-o> :PopcBufferJumpNext<CR>
    nnoremap <C-h> <C-o>
    nnoremap <C-l> <C-i>
    nnoremap <leader>wq :PopcBufferClose!<CR>
    nnoremap <leader><leader>b :PopcBookmark<CR>
    nnoremap <leader><leader>w :PopcWorkspace<CR>
    nnoremap <silent> <leader>ty
        \ :let g:Popc_tabline_layout = (get(g:, 'Popc_tabline_layout', 0) + 1) % 3<Bar>
        \ :call call('popc#stl#TabLineSetLayout',
        \           [['buffer', 'tab'], ['buffer', ''], ['', 'tab']][g:Popc_tabline_layout])<CR>
" }}}

" nerdtree {{{ 目录树导航
    let g:NERDTreeShowHidden = 1
    let g:NERDTreeDirArrowExpandable = '▸'
    let g:NERDTreeDirArrowCollapsible = '▾'
    let g:NERDTreeMapActivateNode = 'o'
    let g:NERDTreeMapOpenRecursively = 'O'
    let g:NERDTreeMapPreview = 'go'
    let g:NERDTreeMapCloseDir = 'x'
    let g:NERDTreeMapOpenInTab = 't'
    let g:NERDTreeMapOpenInTabSilent = 'gt'
    let g:NERDTreeMapOpenSplit = 's'
    let g:NERDTreeMapPreviewSplit = 'gs'
    let g:NERDTreeMapOpenVSplit = 'i'
    let g:NERDTreeMapPreviewVSplit = 'gi'
    let g:NERDTreeMapJumpLastChild = 'J'
    let g:NERDTreeMapJumpFirstChild = 'K'
    let g:NERDTreeMapJumpNextSibling = '<C-n>'
    let g:NERDTreeMapJumpPrevSibling = '<C-p>'
    let g:NERDTreeMapJumpParent = 'p'
    let g:NERDTreeMapChangeRoot = 'cd'
    let g:NERDTreeMapChdir = ''
    let g:NERDTreeMapCWD = ''
    let g:NERDTreeMapUpdir = 'u'
    let g:NERDTreeMapUpdirKeepOpen = 'U'
    let g:NERDTreeMapRefresh = 'r'
    let g:NERDTreeMapRefreshRoot = 'R'
    let g:NERDTreeMapToggleHidden = '.'
    let g:NERDTreeMapToggleZoom = 'Z'
    let g:NERDTreeMapQuit = 'q'
    let g:NERDTreeMapToggleFiles = 'F'
    let g:NERDTreeMapMenu = 'M'
    nnoremap <leader>te :NERDTreeToggle<CR>
    nnoremap <leader>tE :execute ':NERDTree ' . expand('%:p:h')<CR>
" }}}

" startify {{{ 启动首页
if s:gset.use_startify
if IsWin()
    let g:startify_bookmarks = [ {'c': '$DotVimPath/.init.vim'},
                                \{'d': '$LOCALAPPDATA/nvim/init.vim'},
                                \{'o': '$DotVimCachePath/todo.md'} ]
else
    let g:startify_bookmarks = [ {'c': '~/.vim/.init.vim'},
                                \{'d': '~/.config/nvim/init.vim'},
                                \{'o': '$DotVimCachePath/todo.md'} ]
endif
    let g:startify_lists = [
            \ {'type': 'bookmarks', 'header': ['   Bookmarks']},
            \ {'type': 'files',     'header': ['   Recent Files']},
            \ ]
    let g:startify_files_number = 8
    let g:startify_custom_header = 'startify#pad(startify#fortune#cowsay(Plug_stt_todo(), "─", "│", "┌", "┐", "┘", "└"))'
    nnoremap <leader>su :Startify<CR>
    augroup PluginStartify
        autocmd!
        autocmd User StartifyReady setlocal conceallevel=0
    augroup END

    function! Plug_stt_todo()
        if filereadable($DotVimCachePath.'/todo.md')
            return filter(readfile($DotVimCachePath.'/todo.md'), 'v:val !~ "\\m^[ \t]*$"')
        else
            return ''
        endif
    endfunction
endif
" }}}

" screensaver {{{ 屏保
    nnoremap <silent> <leader>ss :ScreenSaver<CR>
" }}}

" fzf {{{ 模糊查找
    let g:fzf_command_prefix = 'Fzf'
    nnoremap <leader><leader>f :Fzf
    augroup PluginFzf
        autocmd!
        autocmd Filetype fzf tnoremap <buffer> <Esc> <C-c>
    augroup END
" }}}

" LeaderF {{{ 模糊查找
if s:gset.use_leaderf
    "call s:plug.reg('onVimEnter', 'exec', 'autocmd! LeaderF_Mru')
    let g:Lf_CacheDirectory = $DotVimCachePath
    "let g:Lf_WindowPosition = 'popup'
    "let g:Lf_PreviewInPopup = 1
    let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0}
    let g:Lf_StlSeparator = s:gset.use_powerfont ? {'left': '', 'right': ''} : {'left': '', 'right': ''}
    let g:Lf_ShowDevIcons = 0
    let g:Lf_ShortcutF = ''
    let g:Lf_ShortcutB = ''
    let g:Lf_ReverseOrder = 1
    let g:Lf_ShowHidden = 1             " 搜索隐藏文件和目录
    let g:Lf_GtagsAutoGenerate = 0      " 禁止自动生成gtags
    let g:Lf_Gtagslabel = 'native-pygments'
                                        " gtags: pip install Pygments
    let g:Lf_GtagsStoreInRootMarker = 1
    let g:Lf_WildIgnore = {
        \ 'dir': ['.git', '.svn', '.hg'],
        \ 'file': []
        \ }
    nnoremap <leader><leader>l :Leaderf
    nnoremap <leader>lf :LeaderfFile<CR>
    nnoremap <leader>lu :LeaderfFunction<CR>
    nnoremap <leader>lU :LeaderfFunctionAll<CR>
    nnoremap <leader>lt :LeaderfBufTag<CR>
    nnoremap <leader>lT :LeaderfBufTagAll<CR>
    nnoremap <leader>ll :LeaderfLine<CR>
    nnoremap <leader>lL :LeaderfLineAll<CR>
    nnoremap <leader>lb :LeaderfBuffer<CR>
    nnoremap <leader>lB :LeaderfBufferAll<CR>
    nnoremap <leader>lr :LeaderfRgInteractive<CR>
    nnoremap <leader>lm :LeaderfMru<CR>
    nnoremap <leader>lM :LeaderfMruCwd<CR>
    nnoremap <leader>ls :LeaderfSelf<CR>
    nnoremap <leader>lh :LeaderfHistorySearch<CR>
    nnoremap <leader>le :LeaderfHistoryCmd<CR>
endif
" }}}
" }}}

" Codings {{{
" YouCompleteMe {{{ 自动补全
if s:gset.use_ycm
    call s:plug.reg('onDelay', 'load', 'YouCompleteMe')
    let g:ycm_global_ycm_extra_conf = $DotVimPath . '/.ycm_extra_conf.py'
    let g:ycm_enable_diagnostic_signs = 1                       " 开启语法检测
    let g:ycm_max_diagnostics_to_display = 30
    let g:ycm_warning_symbol = '►'                              " Warning符号
    let g:ycm_error_symbol = '✘'                                " Error符号
    let g:ycm_auto_start_csharp_server = 0                      " 禁止C#补全
    let g:ycm_cache_omnifunc = 0                                " 禁止缓存匹配项，每次都重新生成匹配项
    let g:ycm_complete_in_strings = 1                           " 开启对字符串补全
    let g:ycm_complete_in_comments = 1                          " 开启对注释补全
    let g:ycm_collect_identifiers_from_comments_and_strings = 0 " 收集注释和字符串补全
    let g:ycm_collect_identifiers_from_tags_files = 1           " 收集标签补全
    let g:ycm_seed_identifiers_with_syntax = 1                  " 收集语法关键字补全
    let g:ycm_use_ultisnips_completer = 1                       " 收集UltiSnips补全
    let g:ycm_autoclose_preview_window_after_insertion = 1      " 自动关闭预览窗口
    let g:ycm_filetype_whitelist = {'*': 1}                     " YCM只在whitelist出现且blacklist未出现的filetype工作
    let g:ycm_language_server = []                              " LSP支持
    let g:ycm_semantic_triggers = {'tex' : g:vimtex#re#youcompleteme}
    let g:ycm_key_detailed_diagnostics = ''                     " 直接使用:YcmShowDetailedDiagnostic命令
    let g:ycm_key_list_select_completion = ['<C-j>', '<M-j>', '<C-n>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<C-k>', '<M-k>', '<C-p>', '<Up>']
    let g:ycm_key_list_stop_completion = ['<C-y>']              " 关闭补全menu
    let g:ycm_key_invoke_completion = '<C-l>'                   " 显示补全内容，YCM使用completefunc（C-X C-U）
                                                                " YCM不支持的补全，通过omnifunc(C-X C-O)集成到YCM上
    imap <M-l> <C-l>
    imap <M-y> <C-y>
    nnoremap <leader>gg :YcmCompleter<CR>
    nnoremap <leader>gt :YcmCompleter GoTo<CR>
    nnoremap <leader>gI :YcmCompleter GoToInclude<CR>
    nnoremap <leader>gd :YcmCompleter GoToDefinition<CR>
    nnoremap <leader>gD :YcmCompleter GoToDeclaration<CR>
    nnoremap <leader>gi :YcmCompleter GoToImplementation<CR>
    nnoremap <leader>gr :YcmCompleter GoToReferences<CR>
    nnoremap <leader>gp :YcmCompleter GetParent<CR>
    nnoremap <leader>gk :YcmCompleter GetDoc<CR>
    nnoremap <leader>gy :YcmCompleter GetType<CR>
    nnoremap <leader>gf :YcmCompleter FixIt<CR>
    nnoremap <leader>gc :YcmCompleter ClearCompilationFlagCache<CR>
    nnoremap <leader>gs :YcmCompleter RestartServer<CR>
    nnoremap <leader>yr :YcmRestartServer<CR>
    nnoremap <leader>yd :YcmDiags<CR>
    nnoremap <leader>yD :YcmDebugInfo<CR>
endif
" }}}

" ultisnips {{{ 代码片段
if s:gset.use_snip
    let g:UltiSnipsEditSplit = "vertical"
    let g:UltiSnipsSnippetDirectories = [$DotVimPath . '/snips', "UltiSnips"]
    let g:UltiSnipsExpandTrigger = '<Tab>'
    let g:UltiSnipsListSnippets = '<C-o>'
    let g:UltiSnipsJumpForwardTrigger = '<C-j>'
    let g:UltiSnipsJumpBackwardTrigger = '<C-k>'
endif
" }}}

" coc {{{ 自动补全
if s:gset.use_coc
    call s:plug.reg('onDelay', 'load', 'coc.nvim')
    call s:plug.reg('onDelay', 'exec', 'call s:Plug_coc_settings()')
    function! s:Plug_coc_settings()
        call coc#config("python", {
            \ "pythonPath": $VPathPython . "/python"
            \ })
        call coc#config('languageserver', {
            \ 'lua-language-server': {
                \ 'cwd': $VPathLuaLsp,
                \ 'command': $VPathLuaLsp . (IsWin() ? '/server/bin/Windows/lua-language-server.exe' : '/server/bin/Linux/lua-language-server'),
                \ 'args': ['-E', '-e', 'LANG="zh-cn"', $VPathLuaLsp . '/server/main.lua'],
                \ 'filetypes': ['lua'],
                \ }
            \ })
    endfunction
    let g:coc_config_home = $DotVimPath
    let g:coc_data_home = $DotVimCachePath . '/.coc'
    let g:coc_global_extensions = [
        \ 'coc-snippets', 'coc-yank', 'coc-explorer',
        \ 'coc-pyright', 'coc-java', 'coc-tsserver', 'coc-rust-analyzer',
        \ 'coc-vimlsp', 'coc-vimtex', 'coc-cmake', 'coc-json', 'coc-calc',
        \ ]
    let g:coc_status_error_sign = '✘'
    let g:coc_status_warning_sign = '!'
    let g:coc_filetype_map = {}
    let g:coc_snippet_next = '<C-j>'
    let g:coc_snippet_prev = '<C-k>'
    "inoremap <silent><expr> <Tab>
    "    \ pumvisible() ? coc#_select_confirm() :
    "    \ coc#expandable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
    "    \ Plug_coc_check_bs() ? "\<Tab>" :
    "    \ coc#refresh()
    "function! Plug_coc_check_bs() abort
    "    let col = col('.') - 1
    "    return !col || getline('.')[col - 1]  =~# '\s'
    "endfunction
    inoremap <expr> <M-j> pumvisible() ? "\<C-n>" : "\<C-j>"
    inoremap <expr> <M-k> pumvisible() ? "\<C-p>" : "\<C-k>"
    imap <C-j> <M-j>
    imap <C-k> <M-k>
    inoremap <silent><expr> <C-l>
        \ pumvisible() ? "\<C-g>u" : coc#refresh()
    imap <M-l> <C-l>
    nmap <leader>gd <Plug>(coc-definition)
    nmap <leader>gD <Plug>(coc-declaration)
    nmap <leader>gi <Plug>(coc-implementation)
    nmap <leader>gr <Plug>(coc-references)
    nmap <leader>gy <Plug>(coc-type-definition)
    nmap <leader>gf <Plug>(coc-fix-current)
    nmap <leader>oi <Plug>(coc-diagnostic-info)
    nmap <leader>oj <Plug>(coc-diagnostic-next-error)
    nmap <leader>ok <Plug>(coc-diagnostic-prev-error)
    nmap <leader>oJ <Plug>(coc-diagnostic-next)
    nmap <leader>oK <Plug>(coc-diagnostic-prev)
    nnoremap <silent> <leader>od
        \ :call coc#config('diagnostic.enable', !coc#util#get_config('diagnostic').enable)<Bar>
        \ :echo 'diagnostic.enable: ' . coc#util#get_config('diagnostic').enable<CR>
    nmap <leader>or <Plug>(coc-rename)
    vnoremap <silent> <leader>of :call CocAction('formatSelected', 'v')<CR>
    nnoremap <silent> <leader>of :call CocAction('format')<CR>
    nnoremap <leader>oR :CocRestart<CR>
    nnoremap <leader>on :CocConfig<CR>
    nnoremap <leader>oN :CocLocalConfig<CR>
    " coc-extensions
    nnoremap <silent> <leader>oy :<C-u>CocList --normal yank<CR>
    nnoremap <silent> <leader>oe :CocCommand explorer<CR>
    nmap <leader>oc <Plug>(coc-calc-result-append)
endif
" }}}

" auto-pairs {{{ 自动括号
    let g:AutoPairsShortcutToggle = ''
    let g:AutoPairsShortcutFastWrap = '<M-p>'
    let g:AutoPairsShortcutJump = ''
    let g:AutoPairsShortcutFastBackInsert = ''
    nnoremap <leader>tp :call AutoPairsToggle()<CR>
" }}}

" neoformat {{{ 代码格式化
    let g:neoformat_basic_format_align = 1
    let g:neoformat_basic_format_retab = 1
    let g:neoformat_basic_format_trim = 1
    let g:neoformat_c_astyle = {
        \ 'exe' : 'astyle',
        \ 'args' : ['--style=attach', '--pad-oper'],
        \ 'stdin' : 1,
        \ }
    let g:neoformat_cpp_astyle = g:neoformat_c_astyle
    let g:neoformat_java_astyle = {
        \ 'exe' : 'astyle',
        \ 'args' : ['--mode=java --style=google', '--pad-oper'],
        \ 'stdin' : 1,
        \ }
    let g:neoformat_python_autopep8 = {
        \ 'exe': 'autopep8',
        \ 'args': ['-s 4', '-E'],
        \ 'replace': 1,
        \ 'stdin': 1,
        \ 'env': ['DEBUG=1'],
        \ 'valid_exit_codes': [0, 23],
        \ 'no_append': 1,
        \ }
    let g:neoformat_enabled_c = ['astyle']
    let g:neoformat_enabled_cpp = ['astyle']
    let g:neoformat_enabled_java = ['astyle']
    let g:neoformat_enabled_python = ['autopep8']
    nnoremap <leader>fc :Neoformat<CR>
    vnoremap <leader>fc :Neoformat<CR>
" }}}

" surround {{{ 添加包围符
    let g:surround_no_mappings = 1      " 取消默认映射
    " 修改和删除Surround
    nmap <leader>sd <Plug>Dsurround
    nmap <leader>sc <Plug>Csurround
    nmap <leader>sC <Plug>CSurround
    " 给Text Object添加Surround
    nmap ys <Plug>Ysurround
    nmap yS <Plug>YSurround
    nmap <leader>sw ysiw
    nmap <leader>si ysw
    nmap <leader>sW ySiw
    nmap <leader>sI ySw
    " 给行添加Surround
    nmap <leader>sl <Plug>Yssurround
    nmap <leader>sL <Plug>YSsurround
    xmap <leader>sw <Plug>VSurround
    xmap <leader>sW <Plug>VgSurround
" }}}

" tagbar {{{ 代码结构查看
    let g:tagbar_width = 30
    let g:tagbar_map_showproto = ''     " 取消tagbar对<Space>的占用
    nnoremap <leader>tt :TagbarToggle<CR>
" }}}

" nerdcommenter {{{ 批量注释
    let g:NERDCreateDefaultMappings = 0
    let g:NERDSpaceDelims = 0           " 在Comment后添加Space
    nmap <leader>cc <Plug>NERDCommenterComment
    nmap <leader>cm <Plug>NERDCommenterMinimal
    nmap <leader>cs <Plug>NERDCommenterSexy
    nmap <leader>cb <Plug>NERDCommenterAlignBoth
    nmap <leader>cl <Plug>NERDCommenterAlignLeft
    nmap <leader>ci <Plug>NERDCommenterInvert
    nmap <leader>cy <Plug>NERDCommenterYank
    nmap <leader>ce <Plug>NERDCommenterToEOL
    nmap <leader>ca <Plug>NERDCommenterAppend
    nmap <leader>ct <Plug>NERDCommenterAltDelims
    nmap <leader>cu <Plug>NERDCommenterUncomment
" }}}

" asyncrun {{{ 导步运行程序
    let g:asyncrun_open = 8             " 自动打开quickfix window
    let g:asyncrun_save = 1             " 自动保存当前文件
    let g:asyncrun_local = 1            " 使用setlocal的efm
    nnoremap <leader><leader>r :AsyncRun<Space>
    vnoremap <silent> <leader><leader>r
        \ :call feedkeys(':AsyncRun ' . GetSelected(), 'n')<CR>
    nnoremap <leader>rk :AsyncStop<CR>
" }}}

" floaterm {{{ 终端浮窗
if IsVim()
    set termwinkey=<C-l>
    tnoremap <Esc> <C-l>N
else
    tnoremap <C-l> <C-\><C-n><C-w>
    tnoremap <Esc> <C-\><C-n>
endif
    nnoremap <leader>tZ :terminal<CR>
    nnoremap <leader>tz :FloatermToggle<CR>
    nnoremap <leader><leader>m :Popc Floaterm<CR>
    nnoremap <leader><leader>z :FloatermNew<Space>
    tnoremap <A-u> <C-\><C-n>:FloatermFirst<CR>
    tnoremap <A-i> <C-\><C-n>:FloatermPrev<CR>
    tnoremap <A-o> <C-\><C-n>:FloatermNext<CR>
    tnoremap <A-p> <C-\><C-n>:FloatermLast<CR>
    tnoremap <A-q> <C-\><C-n>:FloatermKill<CR>
    tnoremap <A-h> <C-\><C-n>:FloatermHide<CR>
    nnoremap <leader>mf :FloatermNew lf<CR>
    highlight default link FloatermBorder Normal
" }}}

" vimspector {{{ 调试
if s:gset.use_spector
    let g:vimspector_install_gadgets = ['debugpy', 'vscode-cpptools', 'CodeLLDB']
    nmap <F3>   <Plug>VimspectorStop
    nmap <F4>   <Plug>VimspectorRestart
    nmap <F5>   <Plug>VimspectorContinue
    nmap <F6>   <Plug>VimspectorPause
    nmap <F7>   <Plug>VimspectorToggleConditionalBreakpoint
    nmap <F8>   <Plug>VimspectorAddFunctionBreakpoint
    nmap <F9>   <Plug>VimspectorToggleBreakpoint
    nmap <F10>  <Plug>VimspectorStepOver
    nmap <F11>  <Plug>VimspectorStepInto
    nmap <F12>  <Plug>VimspectorStepOut
    nnoremap <leader>dr :VimspectorReset<CR>
    nnoremap <leader>de :VimspectorEval<Space>
    nnoremap <leader>dw :VimspectorWatch<Space>
    nnoremap <leader>dh :VimspectorShowOutput<Space>
    nnoremap <silent><leader>db
        \ :call PopSelection({
            \ 'opt' : 'select debug configuration',
            \ 'lst' : keys(json_decode(join(readfile('.vimspector.json'))).configurations),
            \ 'cmd' : {sopt, sel -> vimspector#LaunchWithSettings({'configuration': sel})}
            \})<CR>
endif
" }}}

" quickhl {{{ 单词高亮
    nmap <leader>hw <Plug>(quickhl-manual-this)
    xmap <leader>hw <Plug>(quickhl-manual-this)
    nmap <leader>hs <Plug>(quickhl-manual-this-whole-word)
    xmap <leader>hs <Plug>(quickhl-manual-this-whole-word)
    nmap <leader>hc <Plug>(quickhl-manual-clear)
    xmap <leader>hc <Plug>(quickhl-manual-clear)
    nmap <leader>hr <Plug>(quickhl-manual-reset)
    nmap <leader>th <Plug>(quickhl-manual-toggle)
" }}}

" illuminate {{{ 自动高亮
    let g:Illuminate_delay = 250
    let g:Illuminate_ftblacklist = ['nerdtree', 'tagbar', 'coc-explorer']
    highlight link illuminatedWord MatchParen
    nnoremap <leader>tg :IlluminationToggle<CR>
" }}}

" colorizer {{{ 颜色预览
if IsVim()
    let g:colorizer_nomap = 1
    let g:colorizer_startup = 0
    nnoremap <leader>tc :ColorToggle<CR>
else
    nnoremap <leader>tc :ColorizerToggle<CR>
endif
" }}}

" FastFold {{{ 更新折叠
    nmap <leader>zu <Plug>(FastFoldUpdate)
    let g:fastfold_savehook = 0         " 只允许手动更新folds
    let g:fastfold_fold_command_suffixes = ['x','X','a','A','o','O','c','C']
    let g:fastfold_fold_movement_commands = ['z[', 'z]', 'zj', 'zk']
                                        " 允许指定的命令更新folds
" }}}

" julia {{{ Julia支持
    let g:default_julia_version = 'devel'
    let g:latex_to_unicode_tab = 1      " 使用<Tab>输入unicode字符
    nnoremap <leader>tn :call LaTeXtoUnicode#Toggle()<CR>
" }}}
" }}}

" Utils {{{
if s:gset.use_utils
" MarkDown {{{
    let g:markdown_include_jekyll_support = 0
    let g:markdown_enable_mappings = 0
    let g:markdown_enable_spell_checking = 0
    let g:markdown_enable_folding = 0   " 感觉MarkDown折叠引起卡顿时，关闭此项
    let g:markdown_enable_conceal = 0   " 在Vim中显示MarkDown预览
    let g:mkdp_auto_start = 0
    let g:mkdp_auto_close = 1
    let g:mkdp_refresh_slow = 0         " 即时预览MarkDown
    let g:mkdp_command_for_global = 0   " 只有markdown文件可以预览
    let g:mkdp_browser = 'firefox'
    nnoremap <silent> <leader>vm
        \ :echo get(b:, 'MarkdownPreviewToggleBool') ? 'Close markdown preview' : 'Open markdown preview'<Bar>
        \ :call mkdp#util#toggle_preview()<CR>
    nnoremap <silent> <leader>tb
        \ :let g:mkdp_browser = (g:mkdp_browser ==# 'firefox') ? 'chrome' : 'firefox'<Bar>
        \ :echo 'Browser: ' . g:mkdp_browser<CR>
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
    nnoremap <silent> <leader>vr
        \ :execute ':AsyncRun restview ' . expand('%:p:t')<Bar>
        \ :cclose<CR>
else
    " 需要安装 https://github.com/Rykka/instant-rst.py
    nnoremap <silent> <leader>vr
        \ :echo g:_instant_rst_daemon_started ? 'CLose rst' : 'Open rst'<Bar>
        \ :execute g:_instant_rst_daemon_started ? 'StopInstantRst' : 'InstantRst'<CR>
endif
" }}}

" vimtex {{{ Latex
    let g:vimtex_cache_root = $DotVimCachePath . '/.vimtex'
    let g:vimtex_view_general_viewer = 'SumatraPDF'
    let g:vimtex_complete_enabled = 1   " 使用vimtex#complete#omnifunc补全
    let g:vimtex_complete_close_braces = 1
    let g:vimtex_compiler_method = 'latexmk'
                                        " TexLive中包含了latexmk
    nmap <leader>at <Plug>(vimtex-toc-toggle)
    nmap <leader>al <Plug>(vimtex-compile)
    nmap <leader>aL <Plug>(vimtex-compile-ss)
    nmap <leader>ac <Plug>(vimtex-clean)
    nmap <leader>as <Plug>(vimtex-stop)
    nmap <leader>av <Plug>(vimtex-view)
    nmap <leader>am <Plug>(vimtex-toggle-main)
" }}}

" open-browser {{{ 在线搜索
    let g:openbrowser_default_search = 'bing'
    let g:openbrowser_search_engines = {'bing' : 'https://bing.com/search?q={query}'}
    nmap <leader>bs <Plug>(openbrowser-smart-search)
    vmap <leader>bs <Plug>(openbrowser-smart-search)
    nnoremap <leader>big :OpenBrowserSearch -google<Space>
    nnoremap <leader>bib :OpenBrowserSearch -bing<Space>
    nnoremap <leader>bih :OpenBrowserSearch -github<Space>
    nnoremap <silent> <leader>bb  :call openbrowser#search(expand('<cword>'), 'bing')<CR>
    nnoremap <silent> <leader>bg  :call openbrowser#search(expand('<cword>'), 'google')<CR>
    nnoremap <silent> <leader>bh  :call openbrowser#search(expand('<cword>'), 'github')<CR>
    vnoremap <silent> <leader>bb  :call openbrowser#search(GetSelected(), 'bing')<CR>
    vnoremap <silent> <leader>bg  :call openbrowser#search(GetSelected(), 'google')<CR>
    vnoremap <silent> <leader>bh  :call openbrowser#search(GetSelected(), 'github')<CR>
" }}}

" crunch {{{ 计算器
    let g:crunch_user_variables = {
        \ 'e': '2.718281828459045',
        \ 'pi': '3.141592653589793'
        \ }
    nnoremap <silent> <leader>ev
        \ :<C-U>execute '.,+' . string(v:count1-1) . 'Crunch'<CR>
    vnoremap <silent> <leader>ev :Crunch<CR>
" }}}

" translator {{{ 翻译
    nmap <leader>tw <Plug>TranslateW
    vmap <leader>tw <Plug>TranslateWV
    nnoremap <leader><leader>t :TranslateW<Space>
    vnoremap <silent> <leader><leader>t
        \ :call feedkeys(':TranslateW ' . GetSelected(), 'n')<CR>
    nnoremap <leader>tj :call translator#ui#try_jump_into()<CR>
" }}}

" im-select {{{ 输入法
if IsWin() || IsGw()
    let g:im_select_get_im_cmd = 'im-select'
    let g:im_select_default = '1033'    " 输入法代码：切换到期望的默认输入法，运行im-select
endif
    let g:ImSelectSetImCmd = {key -> ['im-select', key]}
" }}}
endif
" }}}

call s:plug.init()
" }}} End

" User Modules {{{
" Libs {{{
" Function: GetStruct(var) {{{ 获取脚本变量，用于调试
function! GetStruct(var)
    return get(s:, a:var)
endfunction
" }}}

" Function: GetSelected() {{{ 获取选区内容
function! GetSelected()
    let l:reg_var = getreg('0', 1)
    let l:reg_mode = getregtype('0')
    normal! gv"0y
    let l:word = getreg('0')
    call setreg('0', l:reg_var, l:reg_mode)
    return l:word
endfunction
" }}}

" Function: GetMultiFilesCompletion(arglead, cmdline, cursorpos) {{{ 多文件自动补全
" 多个文件或目录时，返回的补全字符串使用'|'分隔
function! GetMultiFilesCompletion(arglead, cmdline, cursorpos)
    let l:arglead_true = ''             " 真正用于补全的arglead
    let l:arglead_head = ''             " arglead_true之前的部分
    let l:arglead_list = []             " arglead_true开头的文件和目录补全列表
    "arglead        : _true : _head
    "$xx$           : 'xx'  : text before '|'
    "$xx $ or $xx|$ : ''    : 'xx|'
    if a:arglead[-1:-1] ==# ' ' || a:arglead[-1:-1] ==# '|'
        let l:arglead_true = ''
        let l:arglead_head = a:arglead[0:-2] . '|'
    else
        let l:idx = strridx(a:arglead, '|')
        if l:idx == -1
            let l:arglead_true = a:arglead
            let l:arglead_head = ''
        else
            let l:arglead_true = a:arglead[l:idx+1 : -1]
            let l:arglead_head = a:arglead[0 : l:idx]
        endif
    endif
    " 获取_list，包括<.*>隐藏文件，忽略大小写
    let l:wicSave = &wildignorecase
    set wildignorecase
    set wildignore+=.,..
    let l:arglead_list = split(glob(l:arglead_true . "*") . "\n" . glob(l:arglead_true . "\.[^.]*"), "\n")
    let &wildignorecase = l:wicSave
    set wildignore-=.,..
    "  返回补全列表
    if !empty(l:arglead_head)
        call map(l:arglead_list, 'l:arglead_head . v:val')
    endif
    return l:arglead_list
endfunction
" }}}

" Function: GetRange(pats, pate) {{{ 获取特定的内容的范围
" @param pats: 起始行匹配模式，start为pats所在行
" @param pate: 结束行匹配模式，end为pate所在行
" @return 返回列表[start, end]
function! GetRange(pats, pate)
    let l:start = search(a:pats, 'bcnW')
    let l:end = search(a:pate, 'cnW')
    if l:start == 0
        let l:start = 1
    endif
    if l:end == 0
        let l:end = line('$')
    endif
    return [l:start, l:end]
endfunction
" }}}

" Function: GetEval(str, type) {{{ 获取计算结果
function! GetEval(str, type)
    if a:type ==# 'command'
        let l:result = execute(a:str)
    elseif a:type ==# 'function'
        let l:result = eval(a:str)
    elseif a:type ==# 'registers'
        let l:result = eval('@' . a:str)
    endif
    if type(l:result) != v:t_string
        let l:result = string(l:result)
    endif
    return split(l:result, "\n")
endfunction
" }}}

" Function: GetArgs(str) {{{ 解析字符串参数到列表中
" @param str: 参数字符串，如 '"Test", 10, g:a'
" @return 返回参数列表，如 ["Test", 10, g:a]
function! GetArgs(str)
    let l:args = []
    function! s:parseArgs(...) closure
        let l:args = a:000
    endfunction
    execute 'call s:parseArgs(' . a:str . ')'
    return l:args
endfunction
" }}}

" Function: GetInput(prompt, [text, completion, workdir]) {{{ 输入字符串
" @param workdir: 设置工作目录，用于文件和目录补全
function! GetInput(prompt, ...)
    if a:0 == 0
        return input(a:prompt)
    elseif a:0 == 1
        return input(a:prompt, a:1)
    elseif a:0 == 2
        return input(a:prompt, a:1, a:2)
    elseif a:0 == 3
        execute 'lcd ' . a:3
        return input(a:prompt, a:1, a:2)
    endif
endfunction
" }}}

" Function: ExecInput(iargs, fn, [fargs...]) range {{{
" @param iargs: 用于GetInput的参数列表
" @param fn: 要运行的函数，第一个参数必须为GetInput的输入
" @param fargs: fn的附加参数
function! ExecInput(iargs, fn, ...) range
    let l:inpt = call('GetInput', a:iargs)
    if empty(l:inpt)
        return
    endif
    let l:fargs = [l:inpt]
    if a:0 > 0
        call extend(l:fargs, a:000)
    endif
    let l:range = (a:firstline == a:lastline) ? '' : (string(a:firstline) . ',' . string(a:lastline))
    let Fn = function(a:fn, l:fargs)
    execute l:range . 'call Fn()'
endfunction
" }}}

" Function: SetExecLast(string, [execution_echo]) {{{ 设置execution
function! SetExecLast(string, ...)
    let s:execution = a:string
    let s:execution_echo = (a:0 >= 1) ? a:1 : a:string
    silent! call repeat#set("\<Plug>ExecLast")
endfunction
" }}}

" Function: ExecLast() {{{ 执行上一次的execution
" @param exe: 1:运行, 0:显示
function! ExecLast(exe)
    if exists('s:execution') && !empty(s:execution)
        if a:exe
            silent execute s:execution
            if exists('s:execution_echo') && s:execution_echo != v:null
                echo s:execution_echo
            endif
        else
            call feedkeys(s:execution, 'n')
        endif
    endif
endfunction
" }}}
" }}}

" Workspace {{{
let s:ws = {
    \ 'root': '',
    \ 'rp': {},
    \ 'fw': {'path': '', 'filters': [], 'globlst': []},
    \ }
let s:dp = {
    \ 'rp': {'hl': 'WarningMsg', 'str': ['/\V\c|| "\=[RP]Warning: \.\*\$/hs=s+3']},
    \ 'fw': {'hl': 'IncSearch', 'str': []},
    \ }
augroup UserModulesWorkspace
    autocmd!
    autocmd User PopcLayerWksSavePre call popc#layer#wks#SetSettings(s:ws)
    autocmd User PopcLayerWksLoaded call extend(s:ws, popc#layer#wks#GetSettings(), 'force') |
                                    \ let s:ws.root = popc#layer#wks#GetCurrentWks('root') |
                                    \ if empty(s:ws.fw.path) |
                                    \   let s:ws.fw.path = s:ws.root |
                                    \ endif
    autocmd User AsyncRunStop call DisplaySetting()
    autocmd Filetype qf call DisplaySetting()
augroup END

" Function: DisplaySetting() {{{ 设置结果显示窗口
function! DisplaySetting()
    if &filetype ==# 'qf'
        let l:mod = getline('.') =~# '\V\^|| [rg' ? 'fw' : 'rp'
        if l:mod ==# 'fw'
            setlocal modifiable
            setlocal foldmethod=marker
            setlocal foldmarker=[rg,[Finished
            silent! normal! zO
        endif
        for str in s:dp[l:mod].str
            execute printf('syntax match %s %s', s:dp[l:mod].hl, str)
        endfor
    endif
endfunction
" }}}
" }}}

" Project {{{
" Required: 'skywind3000/asyncrun.vim', 'voldikss/floaterm'
"           'yehuohan/popc', 'yehuohan/popset'

" Struct: s:rp {{{
" @attribute proj: project类型
" @attribute type: filetype类型
let s:rp = {
    \ 'proj' : {
        \ 'f' : ['FnFile'  , v:null                           ],
        \ 'j' : ['FnCell'  , v:null                           ],
        \ 'q' : ['FnGMake' , '*.pro'                          ],
        \ 'u' : ['FnGMake' , 'cmakelists.txt'                 ],
        \ 'n' : ['FnGMake' , 'cmakelists.txt'                 ],
        \ 'm' : ['FnMake'  , 'makefile'                       ],
        \ 'a' : ['FnCargo' , 'Cargo.toml'                     ],
        \ 'h' : ['FnSphinx', IsWin() ? 'make.bat' : 'makefile'],
        \ 'v' : ['FnTasks' , '.vscode'                        ],
        \ },
    \ 'type' : {
        \ 'c'          : [IsWin() ? 'gcc -g %s %s -o %s.exe && %s %s' : 'gcc -g %s %s -o %s && ./%s %s',
                                                    \ 'abld', 'srcf', 'outf', 'outf', 'arun'],
        \ 'cpp'        : [IsWin() ? 'g++ -g -std=c++17 %s %s -o %s.exe && %s %s' : 'g++ -g -std=c++17 %s %s -o %s && ./%s %s',
                                                    \ 'abld', 'srcf', 'outf', 'outf', 'arun'],
        \ 'rust'       : [IsWin() ? 'rustc %s %s -o %s.exe && %s %s' : 'rustc %s %s -o %s && ./%s %s',
                                                    \ 'abld', 'srcf', 'outf', 'outf', 'arun'],
        \ 'java'       : ['javac %s && java %s %s'  , 'srcf', 'outf', 'arun'],
        \ 'python'     : ['python %s %s'            , 'srcf', 'arun'        ],
        \ 'julia'      : ['julia %s %s'             , 'srcf', 'arun'        ],
        \ 'lua'        : ['lua %s %s'               , 'srcf', 'arun'        ],
        \ 'go'         : ['go run %s %s'            , 'srcf', 'arun'        ],
        \ 'javascript' : ['node %s %s'              , 'srcf', 'arun'        ],
        \ 'typescript' : ['node %s %s'              , 'srcf', 'arun'        ],
        \ 'dart'       : ['dart %s %s'              , 'srcf', 'arun'        ],
        \ 'make'       : ['make -f %s %s'           , 'srcf', 'arun'        ],
        \ 'sh'         : ['bash ./%s %s'            , 'srcf', 'arun'        ],
        \ 'dosbatch'   : ['%s %s'                   , 'srcf', 'arun'        ],
        \ 'glsl'       : ['glslangValidator %s %s'  , 'abld', 'srcf'        ],
        \ 'tex'        : ['xelatex -file-line-error %s && SumatraPDF %s.pdf', 'srcf', 'outf'],
        \ 'matlab'     : ['matlab -nosplash -nodesktop -r %s', 'outf'],
        \ 'json'       : ['python -m json.tool %s'  , 'srcf'],
        \ 'markdown'   : ['typora %s'               , 'srcf'],
        \ 'html'       : ['firefox %s'              , 'srcf'],
        \ },
    \ 'cell' : {
        \ 'python' : ['python', '^#%%' , '^#%%' ],
        \ 'julia'  : ['julia' , '^#%%' , '^#%%' ],
        \ 'lua'    : ['lua'   , '^--%%', '^--%%'],
        \ },
    \ 'enc' : {
        \ 'c'    : 'utf-8',
        \ 'cpp'  : 'utf-8',
        \ 'rust' : 'utf-8',
        \ 'make' : 'utf-8',
        \ 'sh'   : 'utf-8',
        \ },
    \ 'efm' : {
        \ 'python' : '%*\\sFile\ \"%f\"\\,\ line\ %l\\,\ %m',
        \ 'rust'   : '\ %#-->\ %f:%l:%c,\%m\ %f:%l:%c',
        \ 'lua'    : 'lua:\ %f:%l:\ %m',
        \ 'tex'    : '%f:%l:\ %m',
        \ 'cmake'  : '%ECMake\ Error\ at\ %f:%l\ %#%m:',
        \ },
    \ 'pat' : {
        \ 'target'  : '\mTARGET\s*:\?=\s*\(\<[a-zA-Z0-9_][a-zA-Z0-9_\-]*\)',
        \ 'project' : '\mproject(\(\<[a-zA-Z0-9_][a-zA-Z0-9_\-]*\)',
        \ 'name'    : '\mname\s*=\s*\(\<[a-zA-Z0-9_][a-zA-Z0-9_\-]*\)',
        \ },
    \ 'mappings' : [
        \  'Rp',  'Rq',  'Ru',  'Rn',  'Rm',  'Ra',  'Rh',  'Rv',  'Rf',
        \  'rp',  'rq',  'ru',  'rn',  'rm',  'ra',  'rh',  'rv',  'rf', 'rj',
        \ 'rcp', 'rcq', 'rcu', 'rcn', 'rcm', 'rca', 'rch', 'rcv',
        \ 'rbp', 'rbq', 'rbu', 'rbn', 'rbm', 'rba', 'rbh', 'rbv',
        \ 'rlp', 'rlq', 'rlu', 'rln', 'rlm', 'rla', 'rlh', 'rlv', 'rlf',
        \ 'rtp', 'rtq', 'rtu', 'rtn', 'rtm', 'rta', 'rth', 'rtv', 'rtf',
        \ 'rop', 'roq', 'rou', 'ron', 'rom', 'roa', 'roh', 'rov',
        \ ]
    \ }
" Function: s:rp.glob(pat, low) {{{
" @param pat: 文件匹配模式，如*.pro
" @param low: true:查找到存在pat的最低层目录 false:查找到存在pat的最高层目录
" @return 返回找到的文件列表
function! s:rp.glob(pat, low) dict
    let l:dir      = expand('%:p:h')
    let l:dir_last = ''

    " widows文件不区分大小写，其它需要通过正则式实现
    let l:pat = IsWin() ? a:pat :
        \ join(map(split(a:pat, '\zs'),
        \       {k,c -> (c =~? '[a-z]') ? '[' . toupper(c) . tolower(c) . ']' : c}), '')

    let l:res = ''
    while l:dir !=# l:dir_last
        let l:files = glob(l:dir . '/' . l:pat)
        if !empty(l:files)
            let l:res = l:files
            if a:low
                break
            endif
        endif
        let l:dir_last = l:dir
        let l:dir = fnamemodify(l:dir, ':p:h:h')
    endwhile
    return split(l:res, "\n")
endfunction
" }}}

" Function: s:rp.pstr(file, pat) {{{
" @param pat: 匹配模式，必须使用 \(\) 来提取字符串
" @return 返回匹配的字符串结果
function! s:rp.pstr(file, pat)
    for l:line in readfile(a:file)
        let l:res = matchlist(l:line, a:pat)
        if !empty(l:res)
            return l:res[1]
        endif
    endfor
    return ''
endfunction
" }}}

" Function: s:rp.run(cfg) dict {{{
" @param cfg = {
"   key: proj的类型
"   term: 运行的终端类型
"   type: 用于设置encoding, errorformat ...
" }
function! s:rp.run(cfg) dict
    " get file and wdir
    let [l:Fn, l:pat] = self.proj[a:cfg.key]
    if !has_key(a:cfg, 'file')
        if l:pat == v:null
            let a:cfg.file = expand('%:p')
        else
            let a:cfg.file = self.glob(l:pat, a:cfg.lowest)
            if empty(a:cfg.file)
                throw 'None of ' . l:pat . ' was found!'
            endif
            let a:cfg.file = a:cfg.file[0]
        endif
    endif
    let a:cfg.wdir = fnamemodify(a:cfg.file, ':h')

    " set efm and enc
    let l:type = get(a:cfg, 'type', '')
    if has_key(self.efm, l:type)
        execute 'setlocal efm=' . self.efm[l:type]
    endif
    let g:asyncrun_encs = get(self.enc, l:type, (IsWin() || IsGw()) ? 'gbk' : 'utf-8')

    " execute
    let l:dir = fnameescape(a:cfg.wdir)
    let l:exec = printf(':AsyncRun -cwd=%s ', l:dir)
    if !empty(a:cfg.term)
        let l:exec .= printf('-mode=term -pos=%s ', a:cfg.term)
    endif
    let l:exec .= function(l:Fn)(a:cfg)
    execute 'lcd ' . l:dir
    call SetExecLast(l:exec)
    execute l:exec
endfunction
" }}}
" }}}

" Function: RunProject(keys, [cfg]) {{{
function! RunProject(keys, ...)
    " {{{
    " MapKeys: [rR][cblto][p...]
    "          [%1][%2   ][%3  ]
    " Run: %1
    "   r : build and run
    "   R : insert or append global args(can use with %2 together)
    " Command: %2
    "   c : clean project
    "   b : build without run
    "   l : run project in floaterm
    "   t : run project in terminal
    "   o : use project with the lowest directory
    " Project: %3
    "   p : run project from s:ws.rp
    "   ... : supported project from s:rp.proj
    " }}}
    if a:keys =~# 'R'
        let s:cfg = {
            \ 'term': '', 'agen': '', 'abld': '', 'arun': '',
            \ 'deploy': 'run',
            \ 'lowest': 0,
            \ }
        let l:sel = {
            \ 'opt' : 'change configs',
            \ 'lst' : ['term', 'agen', 'abld', 'arun', 'deploy', 'lowest'],
            \ 'dic' : {
                \ 'term': {'lst': ['right', 'bottom', 'floaterm']},
                \ 'agen': {'lst': ['-DTEST=']},
                \ 'abld': {'lst': ['-static', 'tags', '--target tags']},
                \ 'arun': {'lst': ['--nocapture']},
                \ 'deploy': {'lst': ['build', 'run', 'clean', 'test']},
                \ 'lowest': {},
                \ },
            \ 'sub' : {
                \ 'cmd': {sopt, sel -> extend(s:cfg, {sopt : sel})},
                \ 'get': {sopt -> s:cfg[sopt]},
                \ },
            \ 'onCR': {sopt -> call('RunProject', [tolower(a:keys), s:cfg])}
            \ }
        if a:keys =~# 'p'
            call extend(s:cfg, {'key': '', 'file': '', 'type': ''})
            call extend(s:cfg, s:ws.rp)
            let l:sel.lst = ['key', 'file', 'type'] + l:sel.lst
            let l:sel.dic['key'] = {'lst': keys(s:rp.proj)}
            let l:sel.dic['file'] = {'cpl': 'file'}
            let l:sel.dic['type'] = {'cpl': 'filetype'}
        endif
        call PopSelection(l:sel)
    elseif a:keys =~# 'p'
        if a:0 > 0
            let s:ws.rp = a:1
            let s:ws.rp.file = fnamemodify(s:ws.rp.file, ':p')
            if empty(s:ws.rp.type)
                let s:ws.rp.type = getbufvar(fnamemodify(s:ws.rp.file, ':t'), '&filetype', &filetype)
            endif
        endif
        call RunProject(has_key(s:ws.rp, 'key') ? a:keys[0:-2] : ('R' . a:keys[1:-1]), s:ws.rp)
    else
        try
            let l:cfg = {
                \ 'key'   : a:keys[-1:-1],
                \ 'term'  : (a:keys =~# 'l') ? 'floaterm' : ((a:keys =~# 't') ? 'right' : ''),
                \ 'deploy': (a:keys =~# 'b') ? 'build' : ((a:keys =~# 'c') ? 'clean' : 'run'),
                \ 'lowest': (a:keys =~# 'o') ? 1 : 0,
                \ 'agen': '', 'abld': '', 'arun': '',
                \ }
            if a:0 > 0
                call extend(l:cfg, a:1)
            endif
            call s:rp.run(l:cfg)
        catch
            echo v:exception
        endtry
    endif
endfunction
" }}}

" Function: FnFile(cfg) {{{
function! FnFile(cfg)
    let l:type = get(a:cfg, 'type', &filetype)
    if !has_key(s:rp.type, l:type) || ('dosbatch' ==? l:type && !IsWin())
        throw 's:rp.type doesn''t support "' . l:type . '"'
    else
        let a:cfg.type = l:type
        let a:cfg.srcf = '"' . fnamemodify(a:cfg.file, ':t') . '"'
        let a:cfg.outf = '"' . fnamemodify(a:cfg.file, ':t:r') . '"'
        let l:pstr = map(copy(s:rp.type[l:type]), {key, val -> (key == 0) ? val : get(a:cfg, val, '')})
        return call('printf', l:pstr)
    endif
endfunction
" }}}

" Function: FnCell(cfg) {{{
function! FnCell(cfg)
    let l:type = &filetype
    if !has_key(s:rp.cell, l:type)
        throw 's:rp.cell doesn''t support "' . l:type . '"'
    else
        let [l:bin, l:pats, l:pate] = s:rp.cell[l:type]
        let l:exec = ':' . join(GetRange(l:pats, l:pate), ',') . 'AsyncRun '. l:bin
        execute l:exec
        throw l:exec
    endif
endfunction
" }}}

" Function: FnMake(cfg) {{{
function! FnMake(cfg)
    if a:cfg.deploy ==# 'clean'
        let l:cmd = 'make clean'
    else
        let l:cmd = 'make ' . a:cfg.abld
        if a:cfg.deploy ==# 'run'
            let l:outfile = s:rp.pstr(a:cfg.file, s:rp.pat.target)
            if empty(l:outfile)
                let l:cmd .= ' && echo "[RP]Warning: No executable file, try add TARGET"'
            else
                let l:cmd .= printf(' && "./__VBuildOut/%s" %s', l:outfile, a:cfg.arun)
            endif
        endif
    endif
    return l:cmd
endfunction
" }}}

" Function: FnGMake(cfg) {{{
" generate make from cmake, qmake ...
function! FnGMake(cfg)
    let l:outdir = a:cfg.wdir . '/__VBuildOut'
    if a:cfg.deploy ==# 'clean'
        call delete(l:outdir, 'rf')
        throw '__VBuildOut was removed'
    else
        silent! call mkdir(l:outdir, 'p')
        if a:cfg.key ==# 'u'
            let l:cmd = printf('cmake %s -G "Unix Makefiles" .. && cmake --build . %s', a:cfg.agen, a:cfg.abld)
        elseif a:cfg.key ==# 'n'
            let l:cmd = printf('vcvars64.bat && cmake %s -G "NMake Makefiles" .. && cmake --build . %s',  a:cfg.agen, a:cfg.abld)
        elseif a:cfg.key ==# 'q'
            let l:srcfile = fnamemodify(a:cfg.file, ':t')
            if IsWin()
                let l:cmd = printf('vcvars64.bat && qmake %s ../"%s" && nmake %s', a:cfg.agen, l:srcfile, a:cfg.abld)
            else
                let l:cmd = printf('qmake %s ../"%s" && make %s', a:cfg.agen, l:srcfile, a:cfg.abld)
            endif
        endif
        let l:cmd = printf('cd __VBuildOut && %s && cd ..', l:cmd)

        if a:cfg.deploy ==# 'run'
            let l:outfile = s:rp.pstr(a:cfg.file, a:cfg.key ==# 'q' ? s:rp.pat.target : s:rp.pat.project)
            if empty(l:outfile)
                let l:cmd .= ' && echo "[RP]Warning: No executable file, try add TARGET"'
                let l:cmd .= ' && echo "[RP]Warning: No executable file, try add project() or TARGET"'
            else
                let l:cmd .= printf(' && "./__VBuildOut/%s" %s', l:outfile, a:cfg.arun)
            endif
        endif
        return l:cmd
    endif
endfunction
" }}}

" Function: FnCargo(cfg) {{{
function! FnCargo(cfg)
    let l:cmd = printf('cargo %s %s', a:cfg.deploy, a:cfg.abld)
    if a:cfg.deploy ==# 'run' || a:cfg.deploy ==# 'test'
        let l:cmd .= ' -- ' . a:cfg.arun
    endif
    let a:cfg.type = 'rust'
    return l:cmd
endfunction
" }}}

" Function: FnSphinx(cfg) {{{
function! FnSphinx(cfg)
    if a:cfg.deploy ==# 'clean'
        let l:cmd = 'make clean'
    else
        let l:cmd = 'make html ' . a:cfg.abld
        if a:cfg.deploy ==# 'run'
            let l:cmd .= ' && firefox build/html/index.html'
        endif
    endif
    return l:cmd
endfunction
" }}}

" Function: FnTasks(cfg) {{{
function! FnTasks(cfg)
    throw printf('echo "[RP]Warning: Not implemented(%s/tasks.json)"', a:cfg.file)
endfunction
" }}}
" }}}

" Find {{{
" Required: 'skywind3000/asyncrun.vim'
"           'Yggdroot/LeaderF', 'junegunn/fzf.vim'
"           'yehuohan/popc', 'yehuohan/popset'

" Struct: s:fw {{{
" @attribute engine: 搜索程序
"            sr : search
"            sa : search append
"            sk : search kill
"            ff : fuzzy files
"            fl : fuzzy line text with <cword>
"            fL : fuzzy line text
"            fh : fuzzy ctags with <cword>
"            fH : fuzzy ctags
"            fd : fuzzy gtags definitions with <cword>
"            fg : fuzzy gtags references with <cword>
" @attribute rg: 预置的rg搜索命令，用于搜索指定文本
" @attribute fuzzy: 预置的模糊搜索命令，用于文件和文本等模糊搜索
" @attribute mappings: 映射按键
let s:fw = {
    \ 'cmd' : '',
    \ 'opt' : '',
    \ 'pat' : '',
    \ 'loc' : '',
    \ 'engine' : {
        \ 'rg' : '', 'fuzzy' : '',
        \ 'sr' : '', 'sa' : '', 'sk' : '',
        \ 'ff' : '', 'fF' : '', 'fl' : '', 'fL' : '', 'fh' : '', 'fH' : '', 'fd' : '', 'fD' : '',
        \ 'sel': {
            \ 'opt' : 'select the engine',
            \ 'lst' : ['rg', 'fuzzy'],
            \ 'dic' : {
                \ 'rg' : {},
                \ 'fuzzy' : {
                    \ 'opt' : 'select fuzzy engine',
                    \ 'lst' : ['fzf', 'leaderf'],
                    \ 'cmd' : {sopt, arg -> s:fw.setEngine('fuzzy', arg)},
                    \ 'get' : {sopt -> s:fw.engine.fuzzy}
                    \ }
                \ }
            \ }
        \ },
    \ 'rg' : {
        \ 'asyncrun' : {
            \ 'chars' : '"#%',
            \ 'sr' : ':botright copen | :let g:asyncrun_encs="utf-8" | :AsyncRun! rg --vimgrep -F %s -e "%s" "%s"',
            \ 'sa' : ':botright copen | :let g:asyncrun_encs="utf-8" | :AsyncRun! -append rg --vimgrep -F %s -e "%s" "%s"',
            \ 'sk' : ':AsyncStop'
            \ }
        \ },
    \ 'fuzzy' : {
        \ 'fzf' : {
            \ 'ff' : ':FzfFiles',
            \ 'fF' : ':FzfFiles',
            \ 'fl' : ':execute "FzfRg " . expand("<cword>")',
            \ 'fL' : ':FzfRg',
            \ 'fh' : ':execute "FzfTags " . expand("<cword>")',
            \ 'fH' : ':FzfTags'
            \ },
        \ 'leaderf' : {
            \ 'ff' : ':Leaderf file',
            \ 'fF' : ':Leaderf file --cword',
            \ 'fl' : ':Leaderf rg --nowrap --cword',
            \ 'fL' : ':Leaderf rg --nowrap',
            \ 'fh' : ':Leaderf tag --nowrap --cword',
            \ 'fH' : ':Leaderf tag --nowrap',
            \ 'fd' : ':execute "Leaderf gtags --auto-jump -d " .expand("<cword>")',
            \ 'fg' : ':execute "Leaderf gtags -r " .expand("<cword>")',
            \ }
        \ },
    \ 'mappings' : {'rg' :[], 'fuzzy' : []}
    \ }
" s:fw.mappings {{{
let s:fw.mappings.rg = [
    \  'fi',  'fbi',  'fti',  'foi',  'fpi',  'fri',  'fI',  'fbI',  'ftI',  'foI',  'fpI',  'frI',
    \  'fw',  'fbw',  'ftw',  'fow',  'fpw',  'frw',  'fW',  'fbW',  'ftW',  'foW',  'fpW',  'frW',
    \  'fs',  'fbs',  'fts',  'fos',  'fps',  'frs',  'fS',  'fbS',  'ftS',  'foS',  'fpS',  'frS',
    \  'f=',  'fb=',  'ft=',  'fo=',  'fp=',  'fr=',  'f=',  'fb=',  'ft=',  'fo=',  'fp=',  'fr=',
    \  'Fi',  'Fbi',  'Fti',  'Foi',  'Fpi',  'Fri',  'FI',  'FbI',  'FtI',  'FoI',  'FpI',  'FrI',
    \  'Fw',  'Fbw',  'Ftw',  'Fow',  'Fpw',  'Frw',  'FW',  'FbW',  'FtW',  'FoW',  'FpW',  'FrW',
    \  'Fs',  'Fbs',  'Fts',  'Fos',  'Fps',  'Frs',  'FS',  'FbS',  'FtS',  'FoS',  'FpS',  'FrS',
    \  'F=',  'Fb=',  'Ft=',  'Fo=',  'Fp=',  'Fr=',  'F=',  'Fb=',  'Ft=',  'Fo=',  'Fp=',  'Fr=',
    \ 'fai', 'fabi', 'fati', 'faoi', 'fapi', 'fari', 'faI', 'fabI', 'fatI', 'faoI', 'fapI', 'farI',
    \ 'faw', 'fabw', 'fatw', 'faow', 'fapw', 'farw', 'faW', 'fabW', 'fatW', 'faoW', 'fapW', 'farW',
    \ 'fas', 'fabs', 'fats', 'faos', 'faps', 'fars', 'faS', 'fabS', 'fatS', 'faoS', 'fapS', 'farS',
    \ 'fa=', 'fab=', 'fat=', 'fao=', 'fap=', 'far=', 'fa=', 'fab=', 'fat=', 'fao=', 'fap=', 'far=',
    \ 'Fai', 'Fabi', 'Fati', 'Faoi', 'Fapi', 'Fari', 'FaI', 'FabI', 'FatI', 'FaoI', 'FapI', 'FarI',
    \ 'Faw', 'Fabw', 'Fatw', 'Faow', 'Fapw', 'Farw', 'FaW', 'FabW', 'FatW', 'FaoW', 'FapW', 'FarW',
    \ 'Fas', 'Fabs', 'Fats', 'Faos', 'Faps', 'Fars', 'FaS', 'FabS', 'FatS', 'FaoS', 'FapS', 'FarS',
    \ 'Fa=', 'Fab=', 'Fat=', 'Fao=', 'Fap=', 'Far=', 'Fa=', 'Fab=', 'Fat=', 'Fao=', 'Fap=', 'Far=',
    \ 'fvi', 'fvpi', 'fvI',  'fvpI',
    \ 'fvw', 'fvpw', 'fvW',  'fvpW',
    \ 'fvs', 'fvps', 'fvS',  'fvpS',
    \ 'fv=', 'fvp=', 'fv=',  'fvp=',
    \ ]
let s:fw.mappings.fuzzy = [
    \  'ff',  'fF',  'fl',  'fL',  'fh',  'fH',  'fd',  'fg',
    \ 'fpf', 'fpF', 'fpl', 'fpL', 'fph', 'fpH', 'fpd', 'fpg',
    \ ]
" }}}

" Function: s:fw.setEngine(type, engine) dict {{{
function! s:fw.setEngine(type, engine) dict
    let self.engine[a:type] = a:engine
    call extend(self.engine, self[a:type][a:engine], 'force')
endfunction
" }}}

" Function: s:fw.exec(input, ['opt']) dict {{{
function! s:fw.exec(input, ...) dict
    if a:input
        call PopSelection({
            \ 'opt' : 'select options',
            \ 'lst' : ['--no-fixed-strings', '--word-regexp', '--hidden', '--no-ignore', '--encoding gbk'],
            \ 'cmd' : {sopt, sel -> s:fw.exec(0, sel)}
            \ })
    else
        if a:0
            let l:self.opt .= a:1
        endif
        " format: printf('cmd %s %s %s',<opt>,<pat>,<loc>)
        let l:exec = printf(self.cmd, self.opt, self.pat, self.loc)
        call SetExecLast(l:exec)
        execute l:exec
    endif
endfunction
" }}}

call s:fw.setEngine('rg', 'asyncrun')
call s:fw.setEngine('fuzzy', 'leaderf')
" }}}

" Function: FindWow(keys, mode) {{{ 查找
function! FindWow(keys, mode)
    " {{{
    " MapKeys: [fF][av][btopr][IiWwSs=]
    "          [%1][%2][%3   ][4%     ]
    " Find: %1
    "   f : find working
    "   F : find working with inputing args
    " Command: %2
    "   '': find with rg by default
    "   a : find with rg append
    "   v : find with vimgrep
    " Location: %3
    "   b : find in current buffer(%)
    "   t : find in buffers of tab via popc
    "   o : find in buffers of all tabs via popc
    "   p : find with inputing path
    "   r : find with inputing working path and filter
    "  '' : find with s:ws.fw
    " Pattern: %4
    "   = : find text from clipboard
    "   Normal Mode: mode='n'
    "   i : find input
    "   w : find word
    "   s : find word with boundaries
    "   Visual Mode: mode='v'
    "   i : find input    with selected
    "   w : find visual   with selected
    "   s : find selected with boundaries
    "   LowerCase: [iws] find in ignorecase
    "   UpperCase: [IWS] find in case match
    " }}}
    " Function: s:getLocations() {{{
    function! s:getLocations()
        let l:loc = GetInput('Location: ', '', 'customlist,GetMultiFilesCompletion', expand('%:p:h'))
        return empty(l:loc) ? [] :
            \ map(split(l:loc, '|'), {key, val -> (val =~# '[/\\]$') ? val[0:-2] : val})
    endfunction
    " }}}
    " Function: s:parsePattern() closure {{{
    function! s:parsePattern() closure
        let l:pat = ''
        if a:mode ==# 'n'
            if a:keys =~? 'i'
                let l:pat = GetInput('Pattern: ')
            elseif a:keys =~? '[ws]'
                let l:pat = expand('<cword>')
            endif
        elseif a:mode ==# 'v'
            let l:selected = GetSelected()
            if a:keys =~? 'i'
                let l:pat = GetInput('Pattern: ', l:selected)
            elseif a:keys =~? '[ws]'
                let l:pat = l:selected
            endif
        endif
        if a:keys =~ '='
            let l:pat = getreg('+')
        endif
        return l:pat
    endfunction
    " }}}
    " Function: s:parseLocation() closure {{{
    function! s:parseLocation() closure
        let l:loc = ''
        if a:keys =~# 'b'
            let l:loc = expand('%:p')
        elseif a:keys =~# 't'
            let l:loc = join(popc#layer#buf#GetFiles('sigtab'), '" "')
        elseif a:keys =~# 'o'
            let l:loc = join(popc#layer#buf#GetFiles('alltab'), '" "')
        elseif a:keys =~# 'p'
            let l:loc = join(s:getLocations(), '" "')
        elseif a:keys =~# 'r'
            let l:loc = FindWowSetArgs('pf') ? s:ws.fw.path : ''
        else
            if empty(s:ws.fw.path)
                let s:ws.fw.path = popc#utils#FindRoot()
            endif
            if empty(s:ws.fw.path)
                call FindWowSetArgs('p')
            endif
            let l:loc = s:ws.fw.path
        endif
        return l:loc
    endfunction
    " }}}
    " Function: s:parseOptions() closure {{{
    function! s:parseOptions() closure
        let l:opt = ''
        if a:keys =~? 's'     | let l:opt .= '-w ' | endif
        if a:keys =~# '[iws]' | let l:opt .= '-i ' | elseif a:keys =~# '[IWS]' | let l:opt .= '-s ' | endif
        if a:keys !~# '[btop]'
            if !empty(s:ws.fw.filters)
                let l:opt .= '-g"*.{' . join(s:ws.fw.filters, ',') . '}" '
            endif
            if !empty(s:ws.fw.globlst)
                let l:opt .= '-g' . join(s:ws.fw.globlst, ' -g')
            endif
        endif
        return l:opt
    endfunction
    " }}}
    " Function: s:parseCommand() closure {{{
    function! s:parseCommand() closure
        if a:keys =~# 'a'
            let l:cmd = s:fw.engine.sa
        else
            let l:cmd = s:fw.engine.sr
            let s:dp.fw.str = []
        endif
        return l:cmd
    endfunction
    " }}}
    " Function: s:parseVimgrep() closure {{{
    function! s:parseVimgrep() closure
        " get options in which %s is the pattern
        let l:opt = (a:keys =~? 's') ? '\<%s\>' : '%s'
        let l:opt .= (a:keys =~# '[iws]') ? '\c' : '\C'
        let s:fw.opt = ''

        " get loaction
        let l:loc = '%'
        if a:keys =~# 'p'
            let l:loc = join(s:getLocations())
            if empty(l:loc) | return v:false | endif
        endif
        let s:fw.loc = l:loc

        " get command
        let s:dp.fw.str = []
        cgetexpr '[rg by vimgrep]'
        let s:fw.cmd = printf(':vimgrepadd %%s /%s/j %%s | :botright copen | caddexpr "[Finished]"', l:opt)
        return v:true
    endfunction
    " }}}

    let l:pat = s:parsePattern()
    if empty(l:pat) | return | endif
    if a:keys =~# 'v'
        if !s:parseVimgrep() | return | endif
        let s:fw.pat = l:pat
    else
        let s:fw.loc = s:parseLocation()
        if empty(s:fw.loc) | return | endif
        let s:fw.opt = s:parseOptions()
        let s:fw.cmd = s:parseCommand()
        let s:fw.pat = escape(l:pat, s:fw.engine.chars)
    endif
    call add(s:dp.fw.str, printf('/\V\c%s/', escape(l:pat, '\/')))
    call s:fw.exec(a:keys =~# 'F')
endfunction
" }}}

" Function: FindWowKill() {{{ 停止查找
function! FindWowKill()
    execute s:fw.engine.sk
endfunction
" }}}

" Function: FindWowFuzzy(keys) {{{ 模糊搜索
function! FindWowFuzzy(keys)
    let l:p = (a:keys[1] ==# 'p') ? 1 : 0
    let l:path = s:ws.fw.path
    if !l:p && empty(l:path)
        " 使用fw.path
        let s:ws.fw.path = popc#utils#FindRoot()
        if empty(s:ws.fw.path) && !FindWowSetArgs('p')
            return
        endif
        let l:path = s:ws.fw.path
    endif
    if l:p || empty(l:path)
        " 使用临时目录
        let l:path = GetInput('Location: ', '', 'dir', expand('%:p:h'))
    endif
    if !empty(l:path)
        let l:exec = printf(":lcd %s | %s", l:path, s:fw.engine[a:keys[0] . a:keys[-1:]])
        call SetExecLast(l:exec)
        execute l:exec
    endif
endfunction
" }}}

" Function: FindWowSetEngine(type) {{{ 设置engine
function! FindWowSetEngine(type)
    call PopSelection(a:type ==# 'engine' ? s:fw.engine.sel : s:fw.engine.sel.dic[a:type])
endfunction
" }}}

" Function: FindWowSetArgs(type) {{{ 设置args
" @param type p-path, f-filters, g-glob，其中f-filters, g-glob均用空格分隔
" @return v:false 表示异常结束函数（path无效），v:true表示正常结束函数
function! FindWowSetArgs(type)
    if a:type =~# 'p'
        let l:path = GetInput('fw.path: ', '', 'dir', expand('%:p:h'))
        if empty(l:path)
            return v:false
        endif
        let l:path = fnamemodify(l:path, ':p')
        if l:path =~# '[/\\]$'
            let l:path = strcharpart(l:path, 0, strchars(l:path) - 1)
        endif
        let s:ws.fw.path = l:path
    endif
    if a:type =~# 'f'
        let s:ws.fw.filters = split(GetInput('fw.filters: '))
    endif
    if a:type =~# 'g'
        let s:ws.fw.globlst = split(GetInput('fw.globlst: '))
    endif
    return v:true
endfunction
" }}}
" }}}

" Scripts {{{
" Struct: s:rs {{{
let s:rs = {
    \ 'sel' : {
        \ 'opt' : 'select scripts to run',
        \ 'lst' : [
                \ 'retab',
                \ '%s/\s\+$//ge',
                \ '%s/\r//ge',
                \ 'edit ++enc=utf-8',
                \ 'edit ++enc=cp936',
                \ 'syntax match QC /\v^[^|]*\|[^|]*\| / conceal',
                \ 'call mkdir(fnamemodify(tempname(), ":h"), "p")',
                \ 'Leaderf gtags --update',
                \ '!rustc --emit asm=%.asm %',
                \ '!rustc --emit asm=%.asm -C "llvm-args=-x86-asm-syntax=intel" %',
                \ '!gcc -S -masm=att %',
                \ '!gcc -S -masm=intel %',
                \ 'copyConfig',
                \ 'lineToTop',
                \ 'clearUndo',
                \ ],
        \ 'dic' : {
                \ 'retab'            : 'retab with expandtab',
                \ '%s/\s\+$//ge'     : 'remove trailing space',
                \ '%s/\r//ge'        : 'remove ^M',
                \ 'edit ++enc=utf-8' : 'reload as utf-8',
                \ 'edit ++enc=cp936' : 'reload as cp936',
                \ 'copyConfig'       : {
                    \ 'opt' : 'select config',
                    \ 'lst' : ['.ycm_extra_conf.py', '.vimspector.json'],
                    \ 'cmd' : {sopt, arg -> execute('edit ' . s:rs.func.copyConfig(arg))},
                    \ },
                \ },
        \ 'cmd' : {sopt, arg -> has_key(s:rs.func, arg) ? s:rs.func[arg]() : execute(arg)},
        \ },
    \ 'func' : {}
    \ }
" Function: s:rs.func.lineToTop() dict {{{ 冻结顶行
function! s:rs.func.lineToTop() dict
    let l:line = line('.')
    split %
    resize 1
    call cursor(l:line, 1)
    wincmd p
endfunction
" }}}

" Function: s:rs.func.clearUndo() dict {{{ 清除undo数据
function! s:rs.func.clearUndo() dict
    let l:ulbak = &undolevels
    setlocal undolevels=-1
    execute "normal! a\<Bar>\<BS>\<Esc>"
    let &undolevels = l:ulbak
endfunction
" }}}

" Function: s:rs.func.copyConfig(filename) dict {{{ 复制配置文件到当前目录
function! s:rs.func.copyConfig(filename) dict
    let l:srcfile = $DotVimPath . '/' . a:filename
    let l:dstfile = expand('%:p:h') . '/' . a:filename
    if !filereadable(l:dstfile)
        call writefile(readfile(l:srcfile), l:dstfile)
    endif
    return l:dstfile
endfunction
" }}}
" }}}

" Function: RunScript() " {{{
function! RunScript()
    call PopSelection(s:rs.sel)
endfunction
" }}}

" Function: FuncMacro(key) {{{ 执行宏
function! FuncMacro(key)
    let l:mstr = ':normal! @' . a:key
    execute l:mstr
    call SetExecLast(l:mstr)
endfunction
" }}}

" Function: FuncEditFile(suffix, ntab) {{{ 编辑临时文件
" @param suffix: 临时文件附加后缀
" @param ntab: 在新tab中打开
function! FuncEditFile(suffix, ntab)
    execute printf('%s %s.%s',
                \ a:ntab ? 'tabedit' : 'edit',
                \ fnamemodify(tempname(), ':r'),
                \ empty(a:suffix) ? 'tmp' : a:suffix)
endfunction
function! RunEditFile(key)
    let l:suffix = {
                \ 'c': 'c',
                \ 'a': 'cpp',
                \ 'r': 'rs',
                \ 'p': 'py'}[a:key[-1:]]
    call FuncEditFile(l:suffix, a:key[0] ==# 't')
endfunction
" }}}

" Function: FuncInsertSpace(string, pos) range {{{ 插入分隔符
" @param string: 分割字符，以空格分隔
" @param pos: 分割的位置
function! FuncInsertSpace(string, pos) range
    let l:chars = split(a:string)

    for k in range(a:firstline, a:lastline)
        let l:line = getline(k)
        let l:fie = ' '
        for ch in l:chars
            let l:pch = '\m\s*\M' . escape(ch, '\') . '\m\s*\C'
            if a:pos == 'h'
                let l:sch = l:fie . escape(ch, '&\')
            elseif a:pos == 'b'
                let l:sch = l:fie . escape(ch, '&\') . l:fie
            elseif a:pos == 'l'
                let l:sch = escape(ch, '&\') . l:fie
            elseif a:pos == 'd'
                let l:sch = escape(ch, '&\')
            endif
            let l:line = substitute(l:line, l:pch, l:sch, 'g')
        endfor
        call setline(k, l:line)
    endfor
    call SetExecLast(':call FuncInsertSpace(''' . a:string . ''', ''' . a:pos . ''')', v:null)
endfunction
" }}}

" Function: FuncSwitchFile(sf) {{{ 切换文件
function! FuncSwitchFile(sf)
    let l:ext = expand('%:e')
    let l:file = expand('%:p:r')
    let l:try = []
    if index(a:sf.lhs, l:ext, 0, 1) >= 0
        let l:try = a:sf.rhs
    elseif index(a:sf.rhs, l:ext, 0, 1) >= 0
        let l:try = a:sf.lhs
    endif
    for e in l:try
        if filereadable(l:file . '.' . e)
            execute 'edit ' . l:file . '.' . e
            break
        endif
        if filereadable(l:file . '.' . toupper(e))
            execute 'edit ' . l:file . '.' . e
            break
        endif
    endfor
endfunction
let RunSwitchFile = function('FuncSwitchFile', [
            \ {'lhs': ['c', 'cc', 'cpp', 'cxx'],
            \  'rhs': ['h', 'hh', 'hpp', 'hxx']}])
" }}}
" }}}

" Quickfix {{{
" Function: QuickfixBasic(kyes) {{{ 基本操作
function! QuickfixBasic(keys)
    let l:type = a:keys[0]
    let l:oprt = a:keys[1]
    if l:oprt ==# 'o'
        execute 'botright ' . l:type . 'open'
    elseif l:oprt ==# 'c'
        if &filetype ==#'qf'
            wincmd p
        endif
        execute l:type . 'close'
    else
        let l:tbl = {
            \ 'l': {'j': 'lnext', 'J': 'llast', 'k': 'lprevious', 'K': 'lfirst'},
            \ 'c': {'j': 'cnext', 'J': 'clast', 'k': 'cprevious', 'K': 'cfirst'}}
        execute l:tbl[l:type][l:oprt]
        silent! normal! zO
        normal! zz
    endif
endfunction
" }}}

" Function: QuickfixGet() {{{ 类型与编号
function! QuickfixGet()
    let l:type = ''
    let l:line = 0
    if &filetype ==# 'qf'
        let l:dict = getwininfo(win_getid())
        if l:dict[0].quickfix && !l:dict[0].loclist
            let l:type = 'c'
        elseif l:dict[0].quickfix && l:dict[0].loclist
            let l:type = 'l'
        endif
        let l:line = line('.')
    endif
    return [l:type, l:line]
endfunction
" }}}

" Function: QuickfixPreview() {{{ 预览
function! QuickfixPreview()
    let [l:type, l:line] = QuickfixGet()
    if empty(l:type)
        return
    endif

    let l:last_winnr = winnr()
    execute l:type . 'rewind ' . l:line
    silent! normal! zO
    silent! normal! zz
    execute l:last_winnr . 'wincmd w'
endfunction
" }}}

" Function: QuickfixTabEdit() {{{ 新建Tab打开窗口
function! QuickfixTabEdit()
    let [l:type, l:line] = QuickfixGet()
    if empty(l:type)
        return
    endif

    tabedit
    execute l:type . 'rewind ' . l:line
    silent! normal! zO
    silent! normal! zz
    execute 'botright ' . l:type . 'open'
endfunction
" }}}

" Function: QuickfixDoIconv() {{{ 编码转换
function! QuickfixDoIconv(sopt, argstr, type)
    let [l:from, l:to] = GetArgs(a:argstr)
    if a:type[0] ==# 'c'
        let l:list = getqflist()
        for t in l:list
            let t.text = iconv(t.text, l:from, l:to)
        endfor
        call setqflist(l:list)
    elseif a:type[0] ==# 'l'
        let l:list = getloclist(0)
        for t in l:list
            let t.text = iconv(t.text, l:from, l:to)
        endfor
        call setloclist(0, l:list)
    endif
endfunction
function! QuickfixIconv()
    let l:type = QuickfixGet()[0]
    if empty(l:type)
        return
    endif
    call PopSelection({
        \ 'opt' : 'select encoding',
        \ 'lst' : ['"cp936", "utf-8"', '"utf-8", "cp936"'],
        \ 'cmd' : 'QuickfixDoIconv',
        \ 'arg' : [l:type,]
        \ })
endfunction
" }}}
" }}}

" Option {{{
" Struct: s:opt {{{
let s:opt = {
    \ 'lst' : {
        \ 'conceallevel' : [2, 0],
        \ 'virtualedit'  : ['all', ''],
        \ 'signcolumn'   : ['no', 'yes', 'auto'],
        \ },
    \ 'func' : {
        \ 'number' : 'OptFuncNumber',
        \ 'syntax' : 'OptFuncSyntax',
        \ },
    \ }
" }}}

" Function: OptionInv(opt) {{{ 切换参数值（bool取反）
function! OptionInv(opt)
    execute printf('setlocal inv%s', a:opt)
    execute printf('echo "%s = " . &%s', a:opt, a:opt)
endfunction
" }}}

" Function: OptionLst(opt) {{{ 切换参数值（列表循环取值）
function! OptionLst(opt)
    let l:lst = s:opt.lst[a:opt]
    let l:idx = index(l:lst, eval('&' . a:opt))
    let l:idx = (l:idx + 1) % len(l:lst)
    execute printf('set %s=%s', a:opt, l:lst[l:idx])
    execute printf('echo "%s = " . &%s', a:opt, a:opt)
endfunction
" }}}

" Function: OptionFunc(opt) {{{ 切换参数值（函数取值）
function! OptionFunc(opt)
    let Fn = function(s:opt.func[a:opt])
    call Fn()
endfunction
" }}}

" Function: OptFuncNumber() {{{ 切换显示行号
function! OptFuncNumber()
    if (&number) && (&relativenumber)
        set nonumber
        set norelativenumber
    elseif !(&number) && !(&relativenumber)
        set number
        set norelativenumber
    elseif (&number) && !(&relativenumber)
        set number
        set relativenumber
    endif
endfunction
" }}}

" Function: OptFuncSyntax() {{{ 切换高亮
function! OptFuncSyntax()
    if exists('g:syntax_on')
        syntax off
        echo 'syntax off'
    else
        syntax on
        echo 'syntax on'
    endif
endfunction
" }}}
" }}}
" }}} End

" User Settings {{{
" Basic {{{
    set synmaxcol=512                   " 最大高亮列数
    set number                          " 显示行号
    set relativenumber                  " 显示相对行号
    set cursorline                      " 高亮当前行
    set cursorcolumn                    " 高亮当前列
    set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
        \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
        \,sm:block-blinkwait175-blinkoff150-blinkon175
    set hlsearch                        " 设置高亮显示查找到的文本
    set incsearch                       " 预览当前的搜索内容
    set termguicolors                   " 在终端中使用24位彩色
    set expandtab                       " 将Tab用Space代替，方便显示缩进标识indentLine
    set tabstop=4                       " 设置Tab键宽4个空格
    set softtabstop=4                   " 设置按<Tab>或<BS>移动的空格数
    set shiftwidth=4                    " 设置>和<命令移动宽度为4
    set nowrap                          " 默认关闭折行
    set textwidth=0                     " 关闭自动换行
    set listchars=tab:⤜⤚→,eol:↲,space:·,nbsp:␣,extends:…,precedes:<,extends:>,trail:~
                                        " 不可见字符显示
    set autoindent                      " 使用autoindent缩进
    set nobreakindent                   " 折行时不缩进
    set conceallevel=0                  " 显示高样样式中的隐藏字符
    set foldenable                      " 充许折叠
    set foldopen-=search                " 查找时不自动展开折叠
    set foldcolumn=0                    " 0~12,折叠标识列，分别用“-”和“+”而表示打开和关闭的折叠
    set foldmethod=indent               " 设置折叠，默认为缩进折叠
    set scrolloff=3                     " 光标上下保留的行数
    set nostartofline                   " 执行滚屏等命令时，不改变光标列位置
    set laststatus=2                    " 一直显示状态栏
    set noshowmode                      " 命令行栏不显示VISUAL等字样
    set completeopt=menuone,preview     " 补全显示设置
    set wildmenu                        " 使能命令补全
    set backspace=indent,eol,start      " Insert模式下使用BackSpace删除
    set title                           " 允许设置titlestring
    set hidden                          " 允许在未保存文件时切换buffer
    set bufhidden=                      " 跟随hidden设置
    set nobackup                        " 不生成备份文件
    set nowritebackup                   " 覆盖文件前，不生成备份文件
    set autochdir                       " 自动切换当前目录为当前文件所在的目录
    set noautowrite                     " 禁止自动保存文件
    set noautowriteall                  " 禁止自动保存文件
    set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
                                        " 解码尝试序列
    set fileformat=unix                 " 以unix格式保存文本文件，即CR作为换行符
    set magic                           " 默认使用magic匹配
    set ignorecase                      " 不区别大小写搜索
    set smartcase                       " 有大写字母时才区别大小写搜索
    set notildeop                       " 使切换大小写的~，类似于c,y,d等操作符
    set nrformats=bin,octal,hex,alpha   " CTRL-A-X支持数字和字母
    set mouse=a                         " 使能鼠标
    set noimdisable                     " 不禁用输入法
    set visualbell                      " 使用可视响铃代替鸣声
    set noerrorbells                    " 关闭错误信息响铃
    set belloff=all                     " 关闭所有事件的响铃
    set helplang=en,cn                  " help-doc顺序
if IsVim()
    set renderoptions=                  " 设置正常显示unicode字符
    if &term == 'xterm' || &term == 'xterm-256color'
        set t_vb=                       " 关闭终端可视闪铃，即normal模式时按esc会有响铃
        " 5,6: 竖线，  3,4: 横线，  1,2: 方块
        let &t_SI = "\<Esc>[6 q"        " 进入Insert模式
        let &t_SR = "\<Esc>[3 q"        " 进入Replace模式
        let &t_EI = "\<Esc>[2 q"        " 退出Insert模式
    endif
endif

" Function: s:onLargeFile() {{{
function! s:onLargeFile()
    let l:fsize = getfsize(expand('<afile>'))
    if l:fsize >= 5 * 1024 * 1024 || l:fsize == -2
        let b:lightline_check_flg = 0
        setlocal filetype=log
        setlocal undolevels=-1
        setlocal noswapfile
    endif
endfunction
" }}}

augroup UserSettingsCmd
    autocmd!
    autocmd BufNewFile *                set fileformat=unix
    autocmd BufRead,BufNewFile *.tex    set filetype=tex
    autocmd BufRead,BufNewFile *.log    set filetype=log
    autocmd Filetype vim,tex            setlocal foldmethod=marker
    autocmd Filetype c,cpp,javascript   setlocal foldmethod=syntax
    autocmd Filetype python             setlocal foldmethod=indent
    autocmd FileType txt,log            setlocal foldmethod=manual
    autocmd BufReadPre *                call s:onLargeFile()
augroup END
" }}}

" Gui {{{
" Function: GuiAdjustFontSize(inc) {{{
function! GuiAdjustFontSize(inc)
    let s:gui_fontsize = exists('s:gui_fontsize') ? s:gui_fontsize + a:inc : 12
    if IsWin()
        execute 'set guifont=Consolas\ For\ Powerline:h' . s:gui_fontsize
        execute 'set guifontwide=Microsoft\ YaHei\ Mono:h' . (s:gui_fontsize - 1)
    else
        execute 'set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h' . s:gui_fontsize
        execute 'set guifontwide=WenQuanYi\ Micro\ Hei\ Mono:h' . s:gui_fontsize
    endif
endfunction
" }}}

" Gui-vim {{{
if IsGVim()
    call GuiAdjustFontSize(0)
    set lines=25
    set columns=90
    set linespace=0
    if IsWin()
        nnoremap <leader>tf :call libcallnr('gvimfullscreen.dll', 'ToggleFullScreen', 0)<CR>
    endif
    nnoremap <kPlus> :call GuiAdjustFontSize(1)<CR>
    nnoremap <kMinus> :call GuiAdjustFontSize(-1)<CR>
endif
" }}}

" Gui-neovim {{{
if IsNVim()
augroup UserSettingsGui
    autocmd!
    autocmd UIEnter * call s:NVimQt_setGui()
augroup END

" Function: s:NVimQt_setGui() {{{
function! s:NVimQt_setGui()
if IsNVimQt()
    call GuiAdjustFontSize(0)
    GuiLinespace 0
    GuiTabline 0
    GuiPopupmenu 0
    nnoremap <RightMouse> :call GuiShowContextMenu()<CR>
    inoremap <RightMouse> <Esc>:call GuiShowContextMenu()<CR>
    vnoremap <RightMouse> :call GuiShowContextMenu()<CR>gv
    nnoremap <leader>tf :call GuiWindowFullScreen(!g:GuiWindowFullScreen)<CR>
    nnoremap <leader>tm :call GuiWindowMaximized(!g:GuiWindowMaximized)<CR>
    nnoremap <kPlus> :call GuiAdjustFontSize(1)<CR>
    nnoremap <kMinus> :call GuiAdjustFontSize(-1)<CR>
endif
endfunction
" }}}
endif
" }}}
" }}}
" }}} End

" User Mappings {{{
" Basic {{{
    " 重复命令
    nnoremap <Plug>ExecLast :call ExecLast(1)<CR>
    nnoremap <leader>. :call ExecLast(1)<CR>
    nnoremap <leader><leader>. :call ExecLast(0)<CR>
    nnoremap <M-;> @:
    vnoremap <silent> <leader><leader>;
        \ :call feedkeys(':' . GetSelected(), 'n')<CR>
    " 排序
    nnoremap <silent> <leader><leader>s :call feedkeys(':sort nr /', 'n')<CR>
    nnoremap <silent> <leader><leader>S :call feedkeys(':sort! nr /', 'n')<CR>
    vnoremap <silent> <leader><leader>s
        \ :call feedkeys(printf(':sort nr /\%%>%dc.*\%%<%dc/', getpos("'<")[2]-1, getpos("'>")[2]+1), 'n')<CR>
    vnoremap <silent> <leader><leader>S
        \ :call feedkeys(printf(':sort! nr /\%%>%dc.*\%%<%dc/', getpos("'<")[2]-1, getpos("'>")[2]+1), 'n')<CR>
    " 回退操作
    nnoremap <S-u> <C-r>
    " 大小写转换
    nnoremap <leader>u ~
    vnoremap <leader>u ~
    " 行移动
    nnoremap > >>
    nnoremap < <<
    " 加减序号
    nnoremap <leader>aj <C-x>
    nnoremap <leader>ak <C-a>
    vnoremap <leader>aj <C-x>
    vnoremap <leader>ak <C-a>
    vnoremap <leader>agj g<C-x>
    vnoremap <leader>agk g<C-a>
    " 匹配符跳转
if IsVim()
    packadd matchit
endif
    nmap <S-s> %
    vmap <S-s> %
    " 行移动
    nnoremap j gj
    vnoremap j gj
    nnoremap k gk
    vnoremap k gk
    nnoremap <S-l> $
    nnoremap <S-h> ^
    vnoremap <S-l> $
    vnoremap <S-h> ^
    " 行复制
    nnoremap yL y$
    nnoremap yH y^
    " 折叠
    nnoremap <leader>za zA
    nnoremap <leader>zc zC
    nnoremap <leader>zo zO
    nnoremap <leader>zm zM
    nnoremap <leader>zn zN
    nnoremap <leader>zr zR
    nnoremap <leader>zx zX
    nnoremap <leader>zf zF
    nnoremap <leader>zd zD
    nnoremap z[ [z
    nnoremap z] ]z
    " 滚屏
    nnoremap <C-j> <C-e>
    nnoremap <C-k> <C-y>
    nnoremap zh zt
    nnoremap zl zb
    nnoremap <M-h> 16zh
    nnoremap <M-l> 16zl
    " 命令行
    cnoremap <C-j> <Down>
    cnoremap <C-k> <Up>
    cnoremap <C-v> <C-r>+
    cnoremap <C-p> <C-r>0
    cnoremap <M-h> <Left>
    cnoremap <M-l> <Right>
    cnoremap <M-k> <C-Right>
    cnoremap <M-j> <C-Left>
    cnoremap <M-i> <C-b>
    cnoremap <M-o> <C-e>
    " HEX编辑
    nnoremap <leader>xx :%!xxd<CR>
    nnoremap <leader>xr :%!xxd -r<CR>
    " 参数设置
    nnoremap <leader>iw :call OptionInv('wrap')<CR>
    nnoremap <leader>il :call OptionInv('list')<CR>
    nnoremap <leader>ii :call OptionInv('ignorecase')<CR>
    nnoremap <leader>ie :call OptionInv('expandtab')<CR>
    nnoremap <leader>ib :call OptionInv('scrollbind')<CR>
    nnoremap <leader>iv :call OptionLst('virtualedit')<CR>
    nnoremap <leader>ic :call OptionLst('conceallevel')<CR>
    nnoremap <leader>is :call OptionLst('signcolumn')<CR>
    nnoremap <leader>in :call OptionFunc('number')<CR>
    nnoremap <leader>ih :call OptionFunc('syntax')<CR>
" }}}

" Copy & Paste {{{
    " yank & put
    vnoremap <leader>y ygv
    nnoremap <silent> ya
        \ :<C-U>execute 'let @0 .= join(getline(line("."), line(".") + v:count), "\n") . "\n"'<Bar>
        \ :echo v:count1 . ' lines append'<CR>
    nnoremap <silent> yd
        \ dd<Bar>:execute 'let @0 .= @"'<Bar>
        \ :echo 'deleted lines append'<CR>
    nnoremap <leader>p "0p
    nnoremap <leader>P "0P
    " ctrl-c & ctrl-v
    vnoremap <leader>c "+y
    nnoremap <leader>cp "+p
    nnoremap <leader>cP "+P
    vnoremap <C-c> "+y
    nnoremap <C-v> "+p
    inoremap <C-v> <Esc>"+pi
    " 使用i-C-a代替i-C-v
    inoremap <C-a> <C-v>
    " 矩形选择
    nnoremap vv <C-v>
    vnoremap vv <C-v>

    for t in split('q w e r t y u i o p a s d f g h j k l z x c v b n m', ' ')
        " 寄存器快速复制与粘贴
        execute printf('vnoremap <leader>''%s "%sy', t, t)
        execute printf('nnoremap <leader>''%s "%sp', t, t)
        execute printf('nnoremap <leader>''%s "%sP', toupper(t), t)
        " 快速执行宏
        execute printf('nnoremap <leader>2%s :call FuncMacro("%s")<CR>', t, t)
    endfor
" }}}

" Tab, Buffer, Quickfix, Window {{{
    " tab切换
    nnoremap <M-u> gT
    nnoremap <M-p> gt
    " buffer切换
    nnoremap <leader>bn :bnext<CR>
    nnoremap <leader>bp :bprevious<CR>
    nnoremap <leader>bl <C-^>
    " quickfix, location-list操作
    nnoremap <leader>qo :call QuickfixBasic('co')<CR>
    nnoremap <leader>qc :call QuickfixBasic('cc')<CR>
    nnoremap <leader>qj :call QuickfixBasic('cj')<CR>
    nnoremap <leader>qJ :call QuickfixBasic('cJ')<CR>
    nnoremap <leader>qk :call QuickfixBasic('ck')<CR>
    nnoremap <leader>qK :call QuickfixBasic('cK')<CR>
    nnoremap <leader>lo :call QuickfixBasic('lo')<CR>
    nnoremap <leader>lc :call QuickfixBasic('lc')<CR>
    nnoremap <leader>lj :call QuickfixBasic('lj')<CR>
    nnoremap <leader>lJ :call QuickfixBasic('lJ')<CR>
    nnoremap <leader>lk :call QuickfixBasic('lk')<CR>
    nnoremap <leader>lK :call QuickfixBasic('lK')<CR>
    nnoremap <C-Space> :call QuickfixPreview()<CR>
    nnoremap <leader>qt :call QuickfixTabEdit()<CR>
    nnoremap <leader>qi :call QuickfixIconv()<CR>
    " 将quickfix中的内容复制location-list
    nnoremap <leader>ql
        \ :call setloclist(0, getqflist())<Bar>
        \ :vertical botright lopen 35<CR>
    " 分割窗口
    nnoremap <leader>ws <C-w>s
    nnoremap <leader>wv <C-W>v
    nnoremap <leader>wc <C-w>c
    " 移动焦点
    nnoremap <leader>wh <C-w>h
    nnoremap <leader>wj <C-w>j
    nnoremap <leader>wk <C-w>k
    nnoremap <leader>wl <C-w>l
    nnoremap <leader>wp <C-w>p
    nnoremap <leader>wP <C-w>P
    nnoremap <leader>ww <C-w>w
    " 移动窗口
    nnoremap <leader>wH <C-w>H
    nnoremap <leader>wJ <C-w>J
    nnoremap <leader>wK <C-w>K
    nnoremap <leader>wL <C-w>L
    nnoremap <leader>wT <C-w>T
    " 改变窗口大小
    nnoremap <leader>w= <C-w>=
    nnoremap <M-e> :resize+5<CR>
    nnoremap <M-d> :resize-5<CR>
    nnoremap <M-s> :vertical resize-5<CR>
    nnoremap <M-f> :vertical resize+5<CR>
    nnoremap <M-Up> :resize+1<CR>
    nnoremap <M-Down> :resize-1<CR>
    nnoremap <M-Left> :vertical resize-1<CR>
    nnoremap <M-Right> :vertical resize+1<CR>
" }}}

" Diff {{{
    nnoremap <silent> <leader>ds
        \ :call ExecInput(['File: ', '', 'file', expand('%:p:h')], {filename -> execute('diffsplit ' . filename)})<CR>
    nnoremap <silent> <leader>dv
        \ :call ExecInput(['File: ', '', 'file', expand('%:p:h')], {filename -> execute('vertical diffsplit ' . filename)})<CR>
    " 比较当前文件（已经分屏）
    nnoremap <leader>dt :diffthis<CR>
    nnoremap <leader>do :diffoff<CR>
    nnoremap <leader>du :diffupdate<CR>
    nnoremap <leader>dp
        \ :<C-U>execute '.,+' . string(v:count1-1) . 'diffput'<CR>
    nnoremap <leader>dg
        \ :<C-U>execute '.,+' . string(v:count1-1) . 'diffget'<CR>
    nnoremap <leader>dj ]c
    nnoremap <leader>dk [c
" }}}

" Project {{{
    nnoremap <silent> <leader>ei
        \ :call ExecInput(['Suffix: '], 'FuncEditFile', 0)<CR>
    nnoremap <silent> <leader>eti
        \ :call ExecInput(['Suffix: '], 'FuncEditFile', 1)<CR>
    nnoremap <leader>ec :call RunEditFile('c')<CR>
    nnoremap <leader>ea :call RunEditFile('a')<CR>
    nnoremap <leader>er :call RunEditFile('r')<CR>
    nnoremap <leader>ep :call RunEditFile('p')<CR>
    nnoremap <leader>etc :call RunEditFile('tc')<CR>
    nnoremap <leader>eta :call RunEditFile('ta')<CR>
    nnoremap <leader>etr :call RunEditFile('tr')<CR>
    nnoremap <leader>etp :call RunEditFile('tp')<CR>
    nnoremap <silent> <leader>eh :call ExecInput(['Divide H: '], 'FuncInsertSpace', 'h')<CR>
    nnoremap <silent> <leader>eb :call ExecInput(['Divide B: '], 'FuncInsertSpace', 'b')<CR>
    nnoremap <silent> <leader>el :call ExecInput(['Divide L: '], 'FuncInsertSpace', 'l')<CR>
    nnoremap <silent> <leader>ed :call ExecInput(['Divide D: '], 'FuncInsertSpace', 'd')<CR>
    nnoremap <silent> <leader>ae
        \ :call ExecInput(['Command: ', '', 'command'], {str -> append(line('.'), GetEval(str, 'command'))})<CR>
    nnoremap <silent> <leader>af
        \ :call ExecInput(['Function: ', '', 'function'], {str -> append(line('.'), GetEval(str, 'function'))})<CR>
    vnoremap <silent> <leader>ae :call append(line('.'), GetEval(GetSelected(), 'command'))<CR>
    vnoremap <silent> <leader>af :call append(line('.'), GetEval(GetSelected(), 'function'))<CR>
    nnoremap <leader>sf :call RunSwitchFile()<CR>
    nnoremap <leader>se :call RunScript()<CR>
    " RunProject
    for key in s:rp.mappings
        execute printf('nnoremap <leader>%s :call RunProject("%s")<CR>', key, key)
    endfor
" }}}

" Find {{{
    nnoremap <leader><Esc> :nohlsearch<CR>
    nnoremap i :nohlsearch<CR>i
    nnoremap <leader>8  *
    vnoremap <silent> <leader>8
        \ "9y<Bar>:execute '/\V\c\<' . escape(@9, '\/') . '\>'<CR>
    nnoremap <leader>3  #
    vnoremap <silent> <leader>3
        \ "9y<Bar>:execute '?\V\c\<' . escape(@9, '\/') . '\>'<CR>
    nnoremap <silent> <leader>/
        \ :execute '/\V\c' . escape(expand('<cword>'), '\/')<CR>
    vnoremap <silent> <leader>/
        \ "9y<Bar>:execute '/\V\c' . escape(@9, '\/')<CR>
    vnoremap <silent> <leader><leader>/
        \ :call feedkeys('/' . GetSelected(), 'n')<CR>
    " FindWow
    for key in s:fw.mappings.rg
        execute printf('nnoremap <leader>%s :call FindWow("%s", "n")<CR>', key, key)
        execute printf('vnoremap <leader>%s :call FindWow("%s", "v")<CR>', key, key)
    endfor
    for key in s:fw.mappings.fuzzy
        execute printf('nnoremap <leader>%s :call FindWowFuzzy("%s")<CR>', key, key)
    endfor
    nnoremap <leader>fk :call FindWowKill()<CR>
    nnoremap <leader>feu :call FindWowSetEngine('fuzzy')<CR>
    nnoremap <leader>fea :call FindWowSetArgs('pfg')<CR>
    nnoremap <leader>fer :call FindWowSetArgs('p')<CR>
    nnoremap <leader>fef :call FindWowSetArgs('f')<CR>
    nnoremap <leader>feg :call FindWowSetArgs('g')<CR>
" }}}
" }}} End
