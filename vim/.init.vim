
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" .init.vim: configuration for vim and neovim.
" Github: https://github.com/yehuohan/dotconfigs
" Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Platforms {{{
" Vim or NVim, with or without Gui {{{
function! IsVim()
    return !(has('nvim'))
endfunction
function! IsNVim()
    return (has('nvim'))
endfunction
function! IsGVim()
    return has('gui_running')
endfunction
function! IsNVimQt()
    " 只在VimEnter之后起作用
    return exists('g:GuiLoaded')
endfunction
" }}}

" Linux or Win {{{
function! IsLinux()
    return (has('unix') && !has('macunix') && !has('win32unix'))
endfunction
function! IsWin()
    return (has('win32') || has('win64'))
endfunction
function! IsGw()
    " GNU for windows
    return (has('win32unix'))
endfunction
function! IsMac()
    return (has('mac'))
endfunction
" }}}
" }}} End

" Globals {{{
let s:home = resolve(expand('<sfile>:p:h'))
let $DotVimPath=s:home . '/.vim'
set rtp+=$DotVimPath

" First {{{
set encoding=utf-8                      " 内部使用utf-8编码
if IsVim()
    set nocompatible                    " 不兼容vi
endif
let mapleader="\<Space>"
nnoremap ; :
vnoremap ; :
nnoremap : ;
set timeout                             " 打开映射超时检测
set ttimeout                            " 打开键码超时检测
set timeoutlen=1000                     " 映射超时时间为1000ms
set ttimeoutlen=70                      " 键码超时时间为70ms
if IsVim()
    " 终端Alt键映射处理：如 Alt+x，实际连续发送 <Esc>x 编码
    " 以下三种方法都可以使按下 Alt+x 后，执行 CmdTest 命令，但超时检测有区别
    "<1> set <M-x>=x  " 设置键码，这里的是一个字符，即<Esc>的编码，不是^和[放在一起
                        " 在终端的Insert模式，按Ctrl+v再按Alt+x可输入
    "    nnoremap <M-x> :CmdTest<CR>    " 按键码超时时间检测
    "<2> nnoremap <Esc>x :CmdTest<CR>   " 按映射超时时间检测
    "<3> nnoremap x  :CmdTest<CR>     " 按映射超时时间检测
    for t in split('q w e r t y u i o p a s d f g h j k l z x c v b n m', ' ')
        execute 'set <M-'. t . '>=' . t
    endfor
    set <M-,>=,
    set <M-.>=.
    set <M-;>=;
endif
" }}}

" Struct: s:gset {{{
let s:gset_file = $DotVimPath . '/.gset.json'
let s:gset = {
    \ 'set_dev'       : v:null,
    \ 'set_os'        : v:null,
    \ 'use_powerfont' : 1,
    \ 'use_lightline' : 1,
    \ 'use_startify'  : 1,
    \ 'use_fzf'       : 1,
    \ 'use_leaderf'   : 1,
    \ 'use_ycm'       : 1,
    \ 'use_snip'      : 1,
    \ 'use_coc'       : 1,
    \ 'use_spector'   : 1,
    \ 'use_utils'     : 1,
    \ }
" Function: s:gsetLoad() {{{
function! s:gsetLoad()
    if filereadable(s:gset_file)
        call extend(s:gset, json_decode(join(readfile(s:gset_file))), 'force')
    else
        call s:gsetSave()
    endif
    if IsVim() && s:gset.use_coc
        " vim中coc容易卡，补全用ycm
        let s:gset.use_ycm = '1'
        let s:gset.use_coc = '0'
    endif
    call env#env(s:gset.set_dev, s:gset.set_os)
endfunction
" }}}
" Function: s:gsetSave() {{{
function! s:gsetSave()
    call writefile([json_encode(s:gset)], s:gset_file)
    echo 's:gset save successful!'
endfunction
" }}}
" Function: s:gsetInit() {{{
function! s:gsetInit()
    function! InitSet(sopt, arg)
        let s:gset[a:sopt] = a:arg
    endfunction
    function! InitGet(sopt)
        return s:gset[a:sopt]
    endfunction
    call PopSelection({
        \ 'opt' : 'select settings',
        \ 'lst' : add(sort(keys(s:gset)), '[OK]') ,
        \ 'dic' : {
            \ 'set_dev'       : {'opt': 'set_dev'      , 'lst': ['hp']         , 'cmd': 'InitSet', 'get': 'InitGet'},
            \ 'set_os'        : {'opt': 'set_os'       , 'lst': ['win', 'arch'], 'cmd': 'InitSet', 'get': 'InitGet'},
            \ 'use_powerfont' : {'opt': 'use_powerfont', 'lst': ['0', '1']     , 'cmd': 'InitSet', 'get': 'InitGet'},
            \ 'use_lightline' : {'opt': 'use_lightline', 'lst': ['0', '1']     , 'cmd': 'InitSet', 'get': 'InitGet'},
            \ 'use_startify'  : {'opt': 'use_startify' , 'lst': ['0', '1']     , 'cmd': 'InitSet', 'get': 'InitGet'},
            \ 'use_fzf'       : {'opt': 'use_fzf'      , 'lst': ['0', '1']     , 'cmd': 'InitSet', 'get': 'InitGet'},
            \ 'use_leaderf'   : {'opt': 'use_leaderf'  , 'lst': ['0', '1']     , 'cmd': 'InitSet', 'get': 'InitGet'},
            \ 'use_ycm'       : {'opt': 'use_ycm'      , 'lst': ['0', '1']     , 'cmd': 'InitSet', 'get': 'InitGet'},
            \ 'use_snip'      : {'opt': 'use_snip'     , 'lst': ['0', '1']     , 'cmd': 'InitSet', 'get': 'InitGet'},
            \ 'use_coc'       : {'opt': 'use_coc'      , 'lst': ['0', '1']     , 'cmd': 'InitSet', 'get': 'InitGet'},
            \ 'use_spector'   : {'opt': 'use_spector'  , 'lst': ['0', '1']     , 'cmd': 'InitSet', 'get': 'InitGet'},
            \ 'use_utils'     : {'opt': 'use_utils'    , 'lst': ['0', '1']     , 'cmd': 'InitSet', 'get': 'InitGet'},
            \ },
        \ 'cmd' : {sopt, arg -> (arg ==# '[OK]') ? s:gsetSave() : v:null}
        \ })
endfunction
" }}}
command! -nargs=0 GSInit :call s:gsetInit()
call s:gsetLoad()
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
    Plug 'easymotion/vim-easymotion'
    Plug 'mg979/vim-visual-multi'
    Plug 't9md/vim-textmanip'
    Plug 'markonm/traces.vim'
    Plug 'godlygeek/tabular', {'on': 'Tabularize'}
    Plug 'junegunn/vim-easy-align'
    Plug 'terryma/vim-smooth-scroll'
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

    " ui and managers
    Plug 'morhetz/gruvbox'
    Plug 'sainnhe/vim-color-forest-night'
    Plug 'srcery-colors/srcery-vim'
    Plug 'rakr/vim-one'
if s:gset.use_lightline
    Plug 'yehuohan/lightline.vim'
endif
    Plug 'luochen1990/rainbow'
    Plug 'Yggdroot/indentLine'
    Plug 'yehuohan/popset'
    Plug 'yehuohan/popc'
    Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTree']}
    Plug 'mhinz/vim-startify'
if s:gset.use_fzf
if IsWin()
    Plug 'junegunn/fzf', {'on': ['FzfFiles', 'FzfRg', 'FzfTags']}
endif
    Plug 'junegunn/fzf.vim', {'on': ['FzfFiles', 'FzfRg', 'FzfTags']}
endif
if s:gset.use_leaderf
    Plug 'Yggdroot/LeaderF', {'do': IsWin() ? './install.bat' : './install.sh'}
endif
if IsVim()
    Plug 'yehuohan/grep'
endif
    Plug 'mhinz/vim-grepper', {'on': ['Grepper', '<plug>(GrepperOperator)']}

    " codings
if s:gset.use_ycm
    function! Plug_ycm_build(info)
        " (first installed) or (PlugInstall! or PlugUpdate!)
        if a:info.status == 'installed' || a:info.force
            if IsLinux()
                !python install.py --clangd-completer --go-completer --java-completer --build-dir ycm_build
            elseif IsWin()
                !python install.py --clangd-completer --go-completer --java-completer --ts-completer --msvc 15 --build-dir ycm_build
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
else
    Plug 'Shougo/echodoc.vim'
    Plug 'jiangmiao/auto-pairs'
endif
    Plug 'sbdchd/neoformat', {'on': 'Neoformat'}
    Plug 'tpope/vim-surround'
    Plug 'majutsushi/tagbar', {'on': 'TagbarToggle'}
    Plug 'scrooloose/nerdcommenter'
    Plug 'skywind3000/asyncrun.vim'
if s:gset.use_spector
    function! Plug_spector_build(info)
        if a:info.status == 'installed' || a:info.force
            !python install_gadget.py --enable-c --enable-python
        endif
    endfunction
    Plug 'puremourning/vimspector', {'do': function('Plug_spector_build'), 'for': ['c', 'cpp', 'python']}
endif
    Plug 't9md/vim-quickhl'
    Plug 'RRethy/vim-illuminate'
if IsNVim()
    Plug 'norcalli/nvim-colorizer.lua', {'on': 'ColorizerToggle'}
else
    Plug 'lilydjwg/colorizer', {'on': 'ColorToggle'}
endif
    Plug 'Konfekt/FastFold'
    Plug 'bfrg/vim-cpp-modern', {'for': ['c', 'cpp']}
    Plug 'JuliaEditorSupport/julia-vim', {'for': 'julia'}

    " utils
if s:gset.use_utils
    Plug 'yianwillis/vimcdoc', {'for': 'help'}
    Plug 'gabrielelana/vim-markdown', {'for': 'markdown'}
    Plug 'iamcco/markdown-preview.nvim', {'for': 'markdown', 'do': { -> mkdp#util#install()}}
    Plug 'joker1007/vim-markdown-quote-syntax'
    Plug 'Rykka/riv.vim', {'for': 'rst'}
    Plug 'Rykka/InstantRst', {'for': 'rst'}
    Plug 'lervag/vimtex', {'for': 'tex'}
    Plug 'tyru/open-browser.vim'
    Plug 'arecarn/vim-crunch'
    Plug 'arecarn/vim-selection'
endif
call plug#end()
" }}}

" Editing {{{
" easy-motion {{{ 快速跳转
    let g:EasyMotion_do_mapping = 0     " 禁止默认map
    let g:EasyMotion_smartcase = 1      " 不区分大小写
    nmap s <Plug>(easymotion-overwin-f)
    nmap <leader>ms <Plug>(easymotion-overwin-f2)
                                        " 跨分屏快速跳转到字母
    nmap <leader>j <Plug>(easymotion-j)
    nmap <leader>k <Plug>(easymotion-k)
    nmap <leader>mw <Plug>(easymotion-w)
    nmap <leader>mb <Plug>(easymotion-b)
    nmap <leader>me <Plug>(easymotion-e)
    nmap <leader>mg <Plug>(easymotion-ge)
    nmap <leader>mW <Plug>(easymotion-W)
    nmap <leader>mB <Plug>(easymotion-B)
    nmap <leader>mE <Plug>(easymotion-E)
    nmap <leader>mG <Plug>(easymotion-gE)
" }}}

" vim-visual-multi {{{ 多光标编辑
    let g:VM_mouse_mappings = 0         " 禁用鼠标
    " C-n: 进入cursor模式
    " C-Up/Down: 进入extend模式
    " Tab: 切换cursor/extend模式
    let g:VM_leader = '\'
    let g:VM_maps = {
        \ 'Find Under'         : '<C-n>',
        \ 'Find Subword Under' : '<C-n>',
        \ 'Select Cursor Down' : '<C-Down>',
        \ 'Select Cursor Up'   : '<C-Up>',
        \ 'Switch Mode'        : '<Tab>',
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
    xnoremap <silent> <M-i>
        \ :<C-U>let g:textmanip_current_mode = 'insert'<Bar>
        \ :echo 'textmanip mode: ' . g:textmanip_current_mode<CR>gv
    xnoremap <silent> <M-o>
        \ :<C-U>let g:textmanip_current_mode = 'replace'<Bar>
        \ :echo 'textmanip mode: ' . g:textmanip_current_mode<CR>gv
    " C-i 与 <Tab>等价
    xmap <silent> <C-i> <M-i>
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

" smooth-scroll {{{ 平滑滚动
    nnoremap <silent> <M-n> :call smooth_scroll#down(&scroll, 0, 2)<CR>
    nnoremap <silent> <M-m> :call smooth_scroll#up(&scroll, 0, 2)<CR>
    nnoremap <silent> <M-j> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>
    nnoremap <silent> <M-k> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
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
            \ 'cmd' : {sopt, arg -> execute('normal! ' . tolower(a:motion) . (a:motion =~# '\l' ? 'i' : 'a' ) . arg)}
            \ })
    endfunction
" }}}

" repeat {{{ 重复命令
" }}}

" signature {{{ 书签管理
    let g:SignatureMap = {
        \ 'Leader'            : "m",
        \ 'PlaceNextMark'     : "m,",
        \ 'ToggleMarkAtLine'  : "m.",
        \ 'PurgeMarksAtLine'  : "m-",
        \ 'DeleteMark'        : '',
        \ 'PurgeMarks'        : '',
        \ 'PurgeMarkers'      : '',
        \ 'GotoNextLineAlpha' : '',
        \ 'GotoPrevLineAlpha' : '',
        \ 'GotoNextSpotAlpha' : '',
        \ 'GotoPrevSpotAlpha' : '',
        \ 'GotoNextLineByPos' : '',
        \ 'GotoPrevLineByPos' : '',
        \ 'GotoNextSpotByPos' : '',
        \ 'GotoPrevSpotByPos' : '',
        \ 'GotoNextMarker'    : '',
        \ 'GotoPrevMarker'    : '',
        \ 'GotoNextMarkerAny' : '',
        \ 'GotoPrevMarkerAny' : '',
        \ 'ListBufferMarks'   : '',
        \ 'ListBufferMarkers' : '',
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
    " Unicode字符：
    "                    
    " ► ✘ ❖ ▫ ▪ ★ ☆ • ≡ ፨ ♥
    "❤️ ❌ ⭕️ 🚫 💯 ⚠️  ❗️❓ 🔴 🔺 🔻 🔸 🔶
    let g:gruvbox_contrast_dark='soft'  " 背景选项：dark, medium, soft
    let g:gruvbox_italic = 1
    let g:forest_night_use_italic = 1
    let g:srcery_italic = 1
    let g:one_allow_italics = 1
if !s:gset.use_lightline
    try
        set background=dark
        colorscheme gruvbox
    " E185: 找不到主题
    catch /^Vim\%((\a\+)\)\=:E185/
        silent! colorscheme desert
    endtry
else
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
                \ 'all_lineinfo': '0x%02B ≡%3p%%  %04l/%L  %-2v',
                \ 'lite_info'   : '%p%%≡%L',
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
        \ }
    if s:gset.use_powerfont
        let g:lightline.separator            = {'left': '', 'right': ''}
        let g:lightline.subseparator         = {'left': '', 'right': ''}
        let g:lightline.tabline_separator    = {'left': '', 'right': ''}
        let g:lightline.tabline_subseparator = {'left': '', 'right': ''}
    endif
    try
        set background=dark
        colorscheme gruvbox
    " E185: 找不到主题
    catch /^Vim\%((\a\+)\)\=:E185/
        silent! colorscheme desert
        let g:lightline.colorscheme = 'one'
    endtry
    let g:lightline.blacklist = {'tagbar':0, 'nerdtree':0, 'Popc':0, 'coc-explorer':0}
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
        " E117: 函数不存在
        catch /^Vim\%((\a\+)\)\=:E117/
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
            \ (s:ws.fw.path . '[' . s:ws.fw.filters . '(' . join(s:ws.fw.globlst,',') . ')]')
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
" }}}

" indentLine {{{ 显示缩进标识
    "let g:indentLine_char = '|'        " 设置标识符样式
    let g:indentLinet_color_term=200    " 设置标识符颜色
    nnoremap <leader>ti :IndentLinesToggle<CR>
" }}}

" popset {{{ 弹出选项
    let g:Popset_SelectionData = [
        \{
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
        \},
        \{
            \ 'opt' : ['colorscheme', 'colo'],
            \ 'lst' : ['forest-night', 'gruvbox', 'srcery', 'one'],
        \}
    \ ]
    nnoremap <leader><leader>s :PopSet<Space>
    nnoremap <leader>sp :PopSet popset<CR>
" }}}

" popc {{{ buffer管理
    let g:Popc_jsonPath = $DotVimPath
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
    let g:Popc_useLayerRoots = ['.popc', '.git', '.svn', '.hg', 'tags']
    nnoremap <leader><leader>h :PopcBuffer<CR>
    nnoremap <M-i> :PopcBufferSwitchLeft<CR>
    nnoremap <M-o> :PopcBufferSwitchRight<CR>
    nnoremap <leader><leader>b :PopcBookmark<CR>
    nnoremap <leader><leader>w :PopcWorkspace<CR>
    nnoremap <silent> <leader>ty
        \ :let g:Popc_tabline_layout = (get(g:, 'Popc_tabline_layout', 0) + 1) % 3<Bar>
        \ :call call('popc#ui#TabLineSetLayout',
        \           [['buffer', 'tab'], ['buffer', ''], ['', 'tab']][g:Popc_tabline_layout])<CR>
" }}}

" nerdtree {{{ 目录树导航
    let g:NERDTreeShowHidden = 1
    let NERDTreeDirArrowExpandable = '▸'
    let NERDTreeDirArrowCollapsible = '▾'
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

" startify {{{ Vim启动首页
if s:gset.use_startify
if IsLinux() || IsMac()
    let g:startify_bookmarks = [ {'c': '~/.init.vim'},
                                \{'d': '~/.config/nvim/init.vim'},
                                \{'o': '$DotVimPath/todo.md'},
                                \]
elseif IsWin()
    let g:startify_bookmarks = [ {'c': '$DotVimPath/../.init.vim'},
                                \{'d': '$LOCALAPPDATA/nvim/init.vim'},
                                \{'o': '$DotVimPath/todo.md'},
                                \]
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
        if filereadable($DotVimPath.'/todo.md')
            let l:lines = readfile($DotVimPath.'/todo.md')
            call filter(l:lines, 'v:val !~ "\\m^[ \t]*$"')
            return l:lines
        else
            return ''
        endif
    endfunction
endif
" }}}

" fzf {{{ 模糊查找
if s:gset.use_fzf
    " linux下直接pacman -S fzf
    " win下载fzf.exe放入bundle/fzf/bin/下
    let g:fzf_command_prefix = 'Fzf'
    nnoremap <leader><leader>f :FzfFiles<Space>
    augroup PluginFzf
        autocmd!
        autocmd Filetype fzf tnoremap <buffer> <Esc> <C-c>
    augroup END
endif
" }}}

" LeaderF {{{ 模糊查找
if s:gset.use_leaderf
    call s:plug.reg('onVimEnter', 'exec', 'autocmd! LeaderF_Mru')
    let g:Lf_CacheDirectory = $DotVimPath
    "let g:Lf_WindowPosition = 'popup'
    "let g:Lf_PreviewInPopup = 1
    let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0}
if s:gset.use_powerfont
    let g:Lf_StlSeparator = {'left': '', 'right': ''}
else
    let g:Lf_StlSeparator = {'left': '', 'right': ''}
endif
    let g:Lf_ShortcutF = ''
    let g:Lf_ShortcutB = ''
    let g:Lf_ReverseOrder = 1
    let g:Lf_ShowHidden = 1             " 搜索隐藏文件和目录
    let g:Lf_GtagsAutoGenerate = 0
    let g:Lf_Gtagslabel = 'native-pygments'
                                        " gtags需要安装 pip install Pygments
    let g:Lf_WildIgnore = {
        \ 'dir': ['.git', '.svn', '.hg'],
        \ 'file': []
        \ }
    nnoremap <leader><leader>l :LeaderfFile<Space>
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

" grep {{{ 大范围查找
    let g:grepper = {
        \ 'rg': {
            \ 'grepprg':    'rg -H --no-heading --vimgrep' . (has('win32') ? ' $*' : ''),
            \ 'grepformat': '%f:%l:%c:%m',
            \ 'escape':     '\^$.*+?()[]{}|'}
        \}
" }}}
" }}}

" Codings {{{
" YouCompleteMe {{{ 自动补全
if s:gset.use_ycm
    call s:plug.reg('onDelay', 'load', 'YouCompleteMe')
    let g:ycm_global_ycm_extra_conf = $DotVimPath.'/.ycm_extra_conf.py'
                                                                " C-family补全路径
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
    let g:ycm_filetype_blacklist = {
        \ 'tagbar': 1,
        \ 'notes': 1,
        \ 'netrw': 1,
        \ 'unite': 1,
        \ 'text': 1,
        \ 'vimwiki': 1,
        \ 'pandoc': 1,
        \ 'infolog': 1,
        \ 'mail': 1,
        \ 'markdown': 1,
        \ }                                                     " 禁用YCM的列表
    let g:ycm_filetype_whitelist = {'*': 1}                     " YCM只在白名单出现且黑名单未出现的filetype工作
    let g:ycm_language_server = [
        \ {
            \ 'name': 'julia',
            \ 'filetypes': ['julia'],
            \ 'project_root_files': ['Project.toml'],
            \ 'cmdline': ['julia', '--startup-file=no', '--history-file=no', '-e', '
            \       using LanguageServer;
            \       using Pkg;
            \       import StaticLint;
            \       import SymbolServer;
            \       env_path = dirname(Pkg.Types.Context().env.project_file);
            \       debug = false;
            \       server = LanguageServer.LanguageServerInstance(stdin, stdout, debug, env_path, "", Dict());
            \       server.runlinter = true;
            \       run(server);
            \       ']
        \ }]                                                    " LSP支持
    let g:ycm_semantic_triggers = {
        \ 'tex' : g:vimtex#re#youcompleteme
        \ }
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
    " 删除UltiSnips#map_keys#MapKeys中的xnoremap <Tab>（和textmanip的<C-i>冲突）
    let g:UltiSnipsEditSplit = "vertical"
    let g:UltiSnipsSnippetDirectories = [$DotVimPath . '/vSnippets']
    let g:UltiSnipsExpandTrigger = '<Tab>'
    let g:UltiSnipsListSnippets = '<C-o>'
    let g:UltiSnipsJumpForwardTrigger = '<C-j>'
    let g:UltiSnipsJumpBackwardTrigger = '<C-k>'
endif
" }}}

" coc {{{ 自动补全
if s:gset.use_coc
    " coc-clangd: 需要自行下载llvm
    " coc-java: 最好自行下载jdt.ls
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
    let g:coc_data_home = $DotVimPath . '/.coc'
    let g:coc_global_extensions = [
        \ 'coc-lists', 'coc-snippets', 'coc-yank', 'coc-explorer',
        \ 'coc-clangd', 'coc-python', 'coc-java', 'coc-tsserver',
        \ 'coc-vimlsp', 'coc-cmake', 'coc-json', 'coc-calc', 'coc-pairs'
        \ ]
    let g:coc_status_error_sign = '✘'
    let g:coc_status_warning_sign = '!'
    let g:coc_filetype_map = {}
    let g:coc_snippet_next = '<C-j>'
    let g:coc_snippet_prev = '<C-k>'
    "inoremap <silent><expr> <Tab>
        "\ coc#expandable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
        "\ "\<Tab>"
    "inoremap <silent><expr> <Tab>
        "\ pumvisible() ? coc#_select_confirm() :
        "\ coc#expandable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
        "\ Plug_coc_check_bs() ? "\<Tab>" :
        "\ coc#refresh()
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
    nnoremap <silent> <leader>gs :CocCommand clangd.switchSourceHeader<CR>
    nnoremap <silent> <leader>gb :CocCommand clangd.symbolInfo<CR>
    nmap <leader>oi <Plug>(coc-diagnostic-info)
    nmap <leader>oj <Plug>(coc-diagnostic-next-error)
    nmap <leader>ok <Plug>(coc-diagnostic-prev-error)
    nmap <leader>oJ <Plug>(coc-diagnostic-next)
    nmap <leader>oK <Plug>(coc-diagnostic-prev)
    nmap <leader>or <Plug>(coc-rename)
    vnoremap <silent> <leader>of :call CocAction('formatSelected', 'v')<CR>
    nnoremap <silent> <leader>of :call CocAction('format')<CR>
    nnoremap <leader>oR :CocRestart<CR>
    nnoremap <leader>oc :CocCommand<Space>
    nnoremap <leader>on :CocConfig<CR>
    nnoremap <leader>oN :CocLocalConfig<CR>
    " coc-extensions
    nnoremap <silent> <leader>oy :<C-u>CocList --normal yank<CR>
    nnoremap <silent> <leader>oe :CocCommand explorer<CR>
    nmap <leader>oa <Plug>(coc-calc-result-append)
endif
" }}}

" echodoc {{{ 参数文档显示
if !s:gset.use_coc
    let g:echodoc_enable_at_startup = 1
if IsVim()
    let g:echodoc#type = 'popup'
else
    let g:echodoc#type = 'floating'
endif
    nnoremap <leader>to :call Plug_ed_toggle()<CR>

    function! Plug_ed_toggle()
        if echodoc#is_enabled()
            call echodoc#disable()
        else
            call echodoc#enable()
        endif
        echo 'Echo doc: ' . string(echodoc#is_enabled())
    endfunction
endif
" }}}

" auto-pairs {{{ 自动括号
if !s:gset.use_coc
    let g:AutoPairsShortcutToggle=''
    let g:AutoPairsShortcutFastWrap=''
    let g:AutoPairsShortcutJump=''
    let g:AutoPairsShortcutFastBackInsert=''
    nnoremap <leader>tp :call AutoPairsToggle()<CR>
endif
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
    let g:tagbar_width=30
    let g:tagbar_map_showproto=''       " 取消tagbar对<Space>的占用
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
if IsWin()
    let g:asyncrun_encs = 'cp936'   " 即'gbk'编码
endif
    let g:asyncrun_open = 8             " 自动打开quickfix window
    let g:asyncrun_save = 1             " 自动保存当前文件
    let g:asyncrun_local = 1            " 使用setlocal的efm
    nnoremap <leader><leader>r :AsyncRun<Space>
    vnoremap <silent> <leader><leader>r
        \ :call feedkeys(':AsyncRun ' . GetSelected(), 'n')<CR>
    nnoremap <leader>rk :AsyncStop<CR>
" }}}

" vimspector {{{ C, C++, Python, Go调试
if s:gset.use_spector
    sign define vimspectorBP text=🔴 texthl=WarningMsg
    sign define vimspectorBPDisabled text=🔴 texthl=MoreMsg
    sign define vimspectorPC text=🔶 texthl=Question
    nmap <F3>   <Plug>VimspectorStop
    nmap <F4>   <Plug>VimspectorRestart
    nmap <F5>   <Plug>VimspectorContinue
    nmap <F6>   <Plug>VimspectorPause
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
            \ 'cmd' : {sopt, arg -> vimspector#LaunchWithSettings({'configuration': arg})}
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
    let g:Illuminate_ftblacklist = ['nerdtree', 'tagbar']
    highlight link illuminatedWord MatchParen
    nnoremap <leader>tg :IlluminationToggle<CR>
" }}}

" colorizer.lua {{{ 颜色预览
if IsNVim()
    nnoremap <leader>tc :ColorizerToggle<CR>
endif
" }}}

" colorizer {{{ 颜色预览
if IsVim()
    let g:colorizer_nomap = 1
    let g:colorizer_startup = 0
    nnoremap <leader>tc :ColorToggle<CR>
endif
" }}}

" FastFold {{{ 更新折叠
    nmap <leader>zu <Plug>(FastFoldUpdate)
    let g:fastfold_savehook = 0         " 只允许手动更新folds
    let g:fastfold_fold_command_suffixes =  ['x','X','a','A','o','O','c','C']
    let g:fastfold_fold_movement_commands = ['z[', 'z]', 'zj', 'zk']
                                        " 允许指定的命令更新folds
" }}}

" cpp-modern {{{ c++语法高亮
" }}}

" julia {{{ Julia支持
    let g:default_julia_version = 'devel'
    let g:latex_to_unicode_tab = 1      " 使用<Tab>输入unicode字符
    nnoremap <leader>tn :call LaTeXtoUnicode#Toggle()<CR>
" }}}
" }}}

" Utils {{{
if s:gset.use_utils
" vimcdoc {{{ 中文帮助文档
" }}}

" MarkDown {{{
    let g:markdown_include_jekyll_support = 0
    let g:markdown_enable_mappings = 0
    let g:markdown_enable_spell_checking = 0
    let g:markdown_enable_folding = 1   " 感觉MarkDown折叠引起卡顿时，关闭此项
    let g:markdown_enable_conceal = 1   " 在Vim中显示MarkDown预览
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

" vimtex {{{ Latex支持
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
    let g:openbrowser_default_search='bing'
    let g:openbrowser_search_engines = {
		\ 'google': 'https://google.com/search?q={query}',
        \ 'bing'  : 'https://bing.com/search?q={query}',
		\ 'github': 'https://github.com/search?q={query}'
        \ }
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
endif
" }}}

call s:plug.init()
" }}} End

" User Modules {{{
" Libs {{{
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
" 多个文件或目录时，返回的补全字符串使用'|'分隔，使用时需要将'|'转回空格；
" 不支含空格的文件或目录；
function! GetMultiFilesCompletion(arglead, cmdline, cursorpos)
    let l:arglead_true = ''             " 真正用于补全的arglead
    let l:arglead_head = ''             " arglead_true之前的部分
    let l:arglead_list = []             " arglead_true开头的文件和目录补全列表
    " arglead   : _true : _head
    " $$        : ''    : ''     -> strridx('|') == -1 -> empty()
    " $ $       : ''    : ''     -> strridx('|') == -1 -> count() == strchars()
    " $xx$      : xx    : ''     -> strridx('|') == -1 -> arglead[-1:] != ' '
    " $xx yy$   : yy    : xx|    -> strridx('|') == -1 -> arglead[-1:] != ' '
    " $xx $     : ''    : xx|    -> strridx('|') == -1 -> arglead[-1:] == ' '
    " $xx yy $  : ''    : xx|yy| -> strridx('|') == -1 -> arglead[-1:] == ' '
    " $xx|**$   : ''    : xx|    -> strridx('|') != -1 -> strcharpart('|') -> no '|' case
    " 转换成 no '|' case
    let l:idx = strridx(a:arglead, '|')
    if l:idx == -1
        let l:arglead = a:arglead
    else
        let l:arglead = strcharpart(a:arglead, l:idx + 1)
        let l:arglead_head = strcharpart(a:arglead, 0, l:idx + 1)
    endif
    " 获取_true和_head
    if !empty(l:arglead) && strchars(l:arglead) > count(l:arglead, ' ')
        if l:arglead[-1:] !=# ' '
            let l:arglead = split(l:arglead)
            let l:arglead_true = l:arglead[-1]
            if len(l:arglead) > 1
                let l:arglead_head .= join(l:arglead[0:-2], '|') . '|'
            endif
        else
            let l:arglead_head .= join(split(l:arglead), '|') . '|'
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
    let s:ws.execution = a:string
    if a:0 >= 1
        let s:execution_echo = a:1
    else
        let s:execution_echo = a:string
    endif
endfunction
" }}}

" Function: ExecLast() {{{ 执行上一次的execution
" @param eager: 1:立接执行, 0:用户执行
function! ExecLast(eager)
    if !empty(s:ws.execution)
        if a:eager
            silent execute s:ws.execution
            if s:execution_echo != v:null
                echo s:execution_echo
            endif
        else
            call feedkeys(s:ws.execution, 'n')
        endif
    endif
endfunction
" }}}
" }}}

" Workspace {{{
" Required: 'yehuohan/popc'

let s:ws = {
    \ 'root' : '',
    \ 'rp': {
        \ 'fn'       : '',
        \ 'file'     : '',
        \ 'filetype' : ''
        \ },
    \ 'fw': {
        \ 'path'    : '',
        \ 'filters' : '',
        \ 'globlst' : []
        \ },
    \ 'execution' : ''
    \ }

augroup UserModulesWorkspace
    autocmd!
    autocmd User PopcLayerWksSavePre call popc#layer#wks#SetSettings(s:ws)
    autocmd User PopcLayerWksLoaded call extend(s:ws, popc#layer#wks#GetSettings(), 'force') |
                                    \ let s:ws.root = popc#layer#wks#GetCurrentWks()[1] |
                                    \ if empty(s:ws.fw.path) |
                                    \   let s:ws.fw.path = s:ws.root |
                                    \ endif
augroup END
" }}}

" Project {{{
" Required: 'skywind3000/asyncrun.vim'
"           'yehuohan/popc', 'yehuohan/popset'

" Struct: s:rp {{{
" @attribute proj: project类型
" @attribute filetype: 文件类型
" @attribute cell: 用于filetype的cell类型
" @attribute efm: 用于filetype的errorformat类型
" @attribute pat: 匹配模式字符串
let s:rp = {
    \ 'proj' : {
        \ 'f' : ['FnFile'                                     ],
        \ 'j' : ['FnCell'                                     ],
        \ 'q' : ['FnQMake' , '*.pro'                          ],
        \ 'u' : ['FnCMake' , 'cmakelists.txt'                 ],
        \ 'n' : ['FnCMake' , 'cmakelists.txt'                 ],
        \ 'm' : ['FnMake'  , 'makefile'                       ],
        \ 'v' : ['FnVs'    , '*.sln'                          ],
        \ 'a' : ['FnCargo' , 'Cargo.toml'                     ],
        \ 'h' : ['FnSphinx', IsWin() ? 'make.bat' : 'makefile'],
        \ 's' : ['FnTasks' , '.vscode'                        ],
        \ 'sets' : '[qunmvahs]'
        \ },
    \ 'filetype' : {
        \ 'c'          : [IsWin() ? 'gcc %s %s -o %s.exe && %s' : 'gcc %s %s -o %s && ./%s',
                                                               \ 'args' , 'srcf' , 'outf' , 'outf' ],
        \ 'cpp'        : [IsWin() ? 'g++ -std=c++11 %s %s -o %s.exe && %s' : 'g++ -std=c++11 %s %s -o %s && ./%s',
                                                               \ 'args' , 'srcf' , 'outf' , 'outf' ],
        \ 'rust'       : [IsWin() ? 'rustc %s %s -o %s.exe && %s' : 'rustc %s %s -o %s && ./%s',
                                                               \ 'args' , 'srcf' , 'outf' , 'outf' ],
        \ 'java'       : ['javac %s && java %s %s'             , 'srcf' , 'outf' , 'args'          ],
        \ 'python'     : ['python %s %s'                       , 'srcf' , 'args'                   ],
        \ 'julia'      : ['julia %s %s'                        , 'srcf' , 'args'                   ],
        \ 'lua'        : ['lua %s %s'                          , 'srcf' , 'args'                   ],
        \ 'go'         : ['go run %s %s'                       , 'srcf' , 'args'                   ],
        \ 'javascript' : ['node %s %s'                         , 'srcf' , 'args'                   ],
        \ 'typescript' : ['node %s %s'                         , 'srcf' , 'args'                   ],
        \ 'dart'       : ['dart %s %s'                         , 'srcf' , 'args'                   ],
        \ 'tex'        : ['pdfLatex %s && SumatraPDF %s.pdf'   , 'srcf' , 'outf'                   ],
        \ 'sh'         : ['./%s %s'                            , 'srcf' , 'args'                   ],
        \ 'dosbatch'   : ['%s %s'                              , 'srcf' , 'args'                   ],
        \ 'markdown'   : ['typora %s'                          , 'srcf'                            ],
        \ 'json'       : ['python -m json.tool %s'             , 'srcf'                            ],
        \ 'matlab'     : ['matlab -nosplash -nodesktop -r %s'  , 'outf'                            ],
        \ 'html'       : ['firefox %s'                         , 'srcf'                            ],
        \ 'dot'        : ['dotty %s && dot -Tpng %s -o %s.png' , 'srcf' , 'srcf' , 'outf'          ],
        \ },
    \ 'cell' : {
        \ 'python' : ['python', '^#%%' , '^#%%' ],
        \ 'julia'  : ['julia' , '^#%%' , '^#%%' ],
        \ 'lua'    : ['lua'   , '^--%%', '^--%%'],
        \ },
    \ 'efm' : {
        \ 'python' : '%*\\sFile\ \"%f\"\\,\ line\ %l\\,\ %m',
        \ },
    \ 'pat' : {
        \ 'target'  : '\mTARGET\s*:\?=\s*\(\<[a-zA-Z0-9_][a-zA-Z0-9_\-]*\)',
        \ 'project' : '\mproject(\(\<[a-zA-Z0-9_][a-zA-Z0-9_\-]*\)',
        \ 'name'    : '\mname\s*=\s*\(\<[a-zA-Z0-9_][a-zA-Z0-9_\-]*\)'
        \ },
    \ 'mappings' : [
        \  'rf', 'rtf', 'Rf' , 'Rtf', 'rj' ,
        \  'rP',
        \  'rp',  'rq',  'ru',  'rn',  'rm',  'rv',  'ra',  'rh',  'rs',
        \  'Rp',  'Rq',  'Ru',  'Rn',  'Rm',  'Rv',  'Ra',  'Rh',  'Rs',
        \ 'rtp', 'rtq', 'rtu', 'rtn', 'rtm', 'rtv', 'rta', 'rth', 'rts',
        \ 'Rtp', 'Rtq', 'Rtu', 'Rtn', 'Rtm', 'Rtv', 'Rta', 'Rth', 'Rts',
        \ 'rbp', 'rbq', 'rbu', 'rbn', 'rbm', 'rbv', 'rba', 'rbh', 'rbs',
        \ 'Rbp', 'Rbq', 'Rbu', 'Rbn', 'Rbm', 'Rbv', 'Rba', 'Rbh', 'Rbs',
        \ 'rcp', 'rcq', 'rcu', 'rcn', 'rcm', 'rcv', 'rca', 'rch', 'rcs',
        \ 'Rcp', 'Rcq', 'Rcu', 'Rcn', 'Rcm', 'Rcv', 'Rca', 'Rch', 'Rcs',
        \ 'rop', 'roq', 'rou', 'ron', 'rom', 'rov', 'roa', 'roh', 'ros',
        \ 'Rop', 'Roq', 'Rou', 'Ron', 'Rom', 'Rov', 'Roa', 'Roh', 'Ros',
        \ ]
    \ }
" Function: s:rp.glob(pat, low) {{{
" @param pat: 文件匹配模式，如*.pro
" @param low: true:查找到存在pat的最低层目录 false:查找到存在pat的最高层目录
" @return 返回找到的文件列表
function! s:rp.glob(pat, low) dict
    let l:dir      = expand('%:p:h')
    let l:dir_last = ''

    if IsWin()
        let l:pat = a:pat               " widows文件不区分大小写
    else
        let l:pat = join(map(split(a:pat, '\zs'),
                    \ {k,c -> (c =~? '[a-z]') ? '[' . toupper(c) . tolower(c) . ']' : c}), '')
    endif

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

" Function: s:rp.run(term, wdir, cmd, [type]) dict {{{
" @param term: 在内置terminal中运行
" @param wdir: 命令运行目录
" @param cmd: 命令字符串
" @param type: 用于设置errorformat
" @return 返回运行命令
function! s:rp.run(term, wdir, cmd, ...) dict
    if a:0 >= 1 && has_key(self.efm, a:1)
        execute 'setlocal efm=' . self.efm[a:1]
    endif
    let l:exec = ':AsyncRun '
    if a:term
        let l:exec .= '-mode=term -pos=right '
    endif
    if !empty(a:wdir)
        let l:wdir = fnameescape(a:wdir)
        let l:exec .= '-cwd=' . l:wdir
        execute 'lcd ' . l:wdir
    endif

    " create exec string
    let l:exec = join([l:exec, a:cmd])
    call SetExecLast(l:exec)
    return l:exec
endfunction
" }}}
" }}}

" Function: RunProject(keys, [args]) {{{
function! RunProject(keys, ...)
    " doc
    " {{{
    " MapKeys: [rR][tbco][pP ...]
    "          [%1][%2  ][%3    ]
    " Run: %1
    "   r : build and run
    "   R : input global args
    " Command: %2
    "   t : run in terminal
    "   b : build without run
    "   c : clean project
    "   o : search project file to low directory
    " Project: %3
    "   p : run project from s:ws.rp
    "   P : set project to s:ws.rp
    "   ... : supported project from s:rp.proj
    " }}}
    " Function: s:inputArgs() closure {{{
    function! s:inputArgs() closure
        if a:keys =~# '[fj]'
            call PopSelection({
                \ 'opt' : 'select args',
                \ 'lst' : [
                        \ '-g',
                        \ '-finput-charset=utf-8 -fexec-charset=gbk',
                        \ '-static',
                        \ '-fPIC -shared'
                        \ ],
                \ 'cpl' : 'customlist,GetMultiFilesCompletion',
                \ 'cmd' : {sopt, arg -> call('RunProject', ['r' . a:keys[1:], arg])}
                \ })
        elseif a:keys =~# s:rp.proj.sets
            call PopSelection({
                \ 'opt' : 'select args',
                \ 'lst' : ['all'],
                \ 'cmd' : {sopt, arg -> call('RunProject', ['r' . a:keys[1:], arg])}
                \ })
        endif
    endfunction
    " }}}
    " Function: s:parseKeys(args) closure {{{
    function! s:parseKeys(args) closure
        " parse conf
        let l:conf = {
            \ 'key'   : a:keys[-1:-1],
            \ 'run'   : (a:keys =~# 'b' || a:keys =~# 'c') ? 0 : 1,
            \ 'term'  : (a:keys =~# 't') ? 1 : 0,
            \ 'clean' : (a:keys =~# 'c') ? 1 : 0,
            \ 'args'  : a:args
            \ }
        " parse fn and file
        if a:keys =~# '[fj]'
            " filetype, cell
            let l:conf.filetype = &filetype
            return [s:rp.proj[l:conf.key][0], expand('%:p'), l:conf]
        elseif a:keys =~? 'p'
            " project
            if a:keys =~# 'P' || empty(s:ws.rp.fn)
                let l:p = GetInput('rp.fn (f,' . join(split(s:rp.proj.sets[1:-2], '\zs'), ',') . '): ')[0:0]
                if l:p !~# 'f' && l:p !~# s:rp.proj.sets
                    return 'Invalid fn'
                endif
                let s:ws.rp.fn = s:rp.proj[l:p][0]
            endif
            if a:keys =~# 'P' || empty(s:ws.rp.file)
                let s:ws.rp.file = GetInput('rp.file: ', '', 'file')
                if empty(s:ws.rp.file)
                    return 'Invalid file'
                endif
                let s:ws.rp.file = fnamemodify(s:ws.rp.file, ':p')
                let s:ws.rp.filetype = getbufvar(fnamemodify(s:ws.rp.file, ':t'), '&filetype', &filetype)
            endif
            let l:conf.filetype = s:ws.rp.filetype
            return [s:ws.rp.fn, s:ws.rp.file, l:conf]
        elseif a:keys =~# s:rp.proj.sets
            " others
            let [l:fn, l:pat] = s:rp.proj[l:conf.key]
            let l:file = s:rp.glob(l:pat, (a:keys =~# 'o'))
            if len(l:file) == 1
                return [l:fn, l:file[0], l:conf]
            elseif len(l:file) > 1
                return [l:fn, l:file, l:conf]
            else
                return 'None of ' . l:pat . ' was found!'
            endif
        endif
    endfunction
    " }}}

    if a:keys =~# 'R'
        call s:inputArgs()
    else
        let l:ret = s:parseKeys((a:0 > 0) ? a:1 : '')
        if type(l:ret) == v:t_list
            let [l:fn, l:file, l:conf] = l:ret
            if type(l:file) == v:t_list
                call PopSelection({
                    \ 'opt' : 'select project file',
                    \ 'lst' : l:file,
                    \ 'cmd' : l:fn,
                    \ 'arg' : l:conf
                    \ })
            else
                call function(l:fn)('', l:file, l:conf)
            endif
        else
            echo l:ret
        endif
    endif
endfunction
" }}}

" Function: FnFile(sopt, sel, conf) {{{
function! FnFile(sopt, sel, conf)
    let l:type = a:conf.filetype
    if !has_key(s:rp.filetype, l:type)
        \ || ('sh' ==? l:type && !(IsLinux() || IsGw() || IsMac()))
        \ || ('dosbatch' ==? l:type && !IsWin())
        echo 's:rp.filetype doesn''t support "' . l:type . '"'
        return
    endif

    let l:dict = {
        \ 'args' : a:conf.args,
        \ 'srcf' : '"' . fnamemodify(a:sel, ':t') . '"',
        \ 'outf' : '"' . fnamemodify(a:sel, ':t:r') . '"'
        \ }
    let l:pstr = map(copy(s:rp.filetype[l:type]), {key, val -> (key == 0) ? val : get(l:dict, val, '')})

    execute s:rp.run(a:conf.term, fnamemodify(a:sel, ':h'), call('printf', l:pstr), l:type)
endfunction
" }}}

" Function: FnCell(sopt, sel, conf) {{{
function! FnCell(sopt, sel, conf)
    let l:type = a:conf.filetype
    if !has_key(s:rp.cell, l:type)
        echo 's:rp.cell doesn''t support "' . l:type . '"'
        return
    endif
    if has_key(s:rp.efm, l:type)
        execute 'setlocal efm=' . s:rp.efm[l:type]
    endif
    let [l:bin, l:pats, l:pate] = s:rp.cell[l:type]
    let l:range = GetRange(l:pats, l:pate)

    " run exec string
    let l:exec = ':' . join(l:range, ',') . 'AsyncRun '. l:bin
    execute l:exec
    echo l:exec
endfunction
" }}}

" Function: FnQMake(sopt, sel, conf) {{{
function! FnQMake(sopt, sel, conf)
    let l:srcfile = fnamemodify(a:sel, ':t')
    let l:outfile = s:rp.pstr(a:sel, s:rp.pat.target)
    let l:outfile = empty(l:outfile) ? fnamemodify(a:sel, ':r') : l:outfile
    let l:workdir = fnamemodify(a:sel, ':h')

    if IsWin()
        let l:cmd = printf('qmake -r "%s" %s && vcvars64.bat && nmake -f Makefile.Debug %s',
                    \ l:srcfile, a:conf.args, a:conf.clean ? 'distclean' : '')
    else
        let l:cmd = printf('qmake "%s" %s && make %s',
                    \ l:srcfile, a:conf.args, a:conf.clean ? 'distclean' : '')
    endif
    if a:conf.run
        let l:cmd .= ' && "./' . l:outfile .'"'
    endif
    execute s:rp.run(a:conf.term, l:workdir, l:cmd, 'cpp')
endfunction
" }}}

" Function: FnCMake(sopt, sel, conf) {{{
function! FnCMake(sopt, sel, conf)
    let l:outfile = s:rp.pstr(a:sel, s:rp.pat.project)
    let l:outfile = empty(l:outfile) ? '' : l:outfile
    let l:workdir = fnamemodify(a:sel, ':h') . '/CMakeBuildOut'

    if a:conf.clean
        " clean
        call delete(l:workdir, 'rf')
    else
        "build
        silent! call mkdir(l:workdir, 'p')
        if a:conf.key ==# 'u'
            " generate unix makefiles
            let l:cmd = printf('cmake %s -G "Unix Makefiles" .. && cmake --build .', a:conf.args)
        elseif a:conf.key ==# 'n'
            " generate nmake makefiles
            let l:cmd = printf('vcvars64.bat && cmake %s -G "NMake Makefiles" .. && cmake --build .', a:conf.args)
        endif
        "run
        if a:conf.run
            let l:cmd .= ' && "./' . l:outfile .'"'
        endif
        execute s:rp.run(a:conf.term, l:workdir, l:cmd)
    endif
endfunction
" }}}

" Function: FnMake(sopt, sel, conf) {{{
function! FnMake(sopt, sel, conf)
    let l:outfile = s:rp.pstr(a:sel, s:rp.pat.target)
    let l:outfile = empty(l:outfile) ? '' : l:outfile
    let l:workdir = fnamemodify(a:sel, ':h')

    let l:cmd = printf('make %s %s', a:conf.clean ? 'clean' : '', a:conf.args)
    if a:conf.run
        let l:cmd .= ' && "./' . l:outfile .'"'
    endif
    execute s:rp.run(a:conf.term, l:workdir, l:cmd)
endfunction
" }}}

" Function: FnVs(sopt, sel, conf) {{{
function! FnVs(sopt, sel, conf)
    let l:srcfile = fnamemodify(a:sel, ':t')
    let l:outfile = fnamemodify(a:sel, ':t:r')
    let l:workdir = fnamemodify(a:sel, ':h')

    let l:cmd = printf('vcvars64.bat && devenv "%s" /%s %s',
                    \ l:srcfile, a:conf.clean ? 'Clean' : 'Build', a:conf.args)
    if a:conf.run
        let l:cmd .= ' && "./' . l:outfile .'"'
    endif
    execute s:rp.run(a:conf.term, l:workdir, l:cmd, 'cpp')
endfunction
" }}}

" Function: FnCargo(sopt, sel, conf) {{{
function! FnCargo(sopt, sel, conf)
    let l:workdir = fnamemodify(a:sel, ':h')

    let l:cmd = 'cargo'
    if a:conf.run
        let l:cmd .= ' run'
    elseif a:conf.clean
        let l:cmd .= ' clean'
    else
        let l:cmd .= ' build'
    endif
    execute s:rp.run(a:conf.term, l:workdir, l:cmd)
endfunction
" }}}

" Function: FnSphinx(sopt, sel, conf) {{{
function! FnSphinx(sopt, sel, conf)
    let l:outfile = 'build/html/index.html'
    let l:workdir = fnamemodify(a:sel, ':h')

    let l:cmd = printf('make %s %s',
                \ a:conf.clean ? 'clean' : 'html', a:conf.args)
    if a:conf.run
        let l:cmd .= join([' && firefox', l:outfile])
    endif
    execute s:rp.run(a:conf.term, l:workdir, l:cmd)
endfunction
" }}}

" Function: FnTasks(sopt, sel, conf) {{{
function! FnTasks(sopt, sel, conf)
    execute s:rp.run(
                \ a:conf.term,
                \ fnamemodify(a:sel, ':h'),
                \ printf('echo Not implemented(%s)', a:sel . '/tasks.json'))
endfunction
" }}}
" }}}

" Find {{{
" Required: 'skywind3000/asyncrun.vim' or 'yegappan/grep' or 'mhinz/vim-grepper'
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
" @attribute rg: 预置的rg搜索命令，用于搜索指定文本
" @attribute fuzzy: 预置的模糊搜索命令，用于文件和文本等模糊搜索
" @attribute strings: 高亮搜索字符串
" @attribute mappings: 映射按键
let s:fw = {
    \ 'cmd' : '',
    \ 'opt' : '',
    \ 'pat' : '',
    \ 'loc' : '',
    \ 'engine' : {
        \ 'rg' : '', 'fuzzy' : '',
        \ 'sr' : '', 'sa' : '', 'sk' : '',
        \ 'ff' : '', 'fF' : '', 'fl' : '', 'fL' : '', 'fh' : '', 'fH' : '',
        \ 'sel': {
            \ 'opt' : 'select the engine',
            \ 'lst' : ['rg', 'fuzzy'],
            \ 'dic' : {
                \ 'rg' : {
                    \ 'opt' : 'select rg engine',
                    \ 'lst' : ['asyncrun', 'grep', 'grepper'],
                    \ 'cmd' : {sopt, arg -> s:fw.setEngine('rg', arg)},
                    \ 'get' : {sopt -> s:fw.engine.rg}
                    \ },
                \ 'fuzzy' : {
                    \ 'opt' : 'select fuzzy engine',
                    \ 'lst' : ['fzf', 'leaderf'],
                    \ 'cmd' : {sopt, arg -> s:fw.setEngine('fuzzy', arg)},
                    \ 'get' : {sopt -> s:fw.engine.fuzzy}
                    \ }
                \ },
            \ }
        \ },
    \ 'rg' : {
        \ 'asyncrun' : {
            \ 'ch' : '"#%',
            \ 'sr' : ':botright copen | :AsyncRun! rg --vimgrep -F %s -e "%s" "%s"',
            \ 'sa' : ':botright copen | :AsyncRun! -append rg --vimgrep -F %s -e "%s" "%s"',
            \ 'sk' : ':AsyncStop'
            \ },
        \ 'grep' : {
            \ 'ch' : '#% ',
            \ 'sr' : ':Rg -F %s %s "%s"',
            \ 'sa' : ':RgAdd -F %s %s "%s"',
            \ 'sk' : ':GrepStop'
            \ },
        \ 'grepper' : {
            \ 'ch' : '"',
            \ 'sr' : ':Grepper -noprompt -tool rg -query -F %s -e "%s" "%s"',
            \ 'sa' : ':Grepper -noprompt -tool rg -append -query -F %s -e "%s" "%s"',
            \ 'sk' : ':Grepper -stop'
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
            \ 'fH' : ':Leaderf tag --nowrap'
            \ }
        \ },
    \ 'strings' : [],
    \ 'mappings' : {
        \ 'rg' :[],
        \ 'fuzzy' : []
        \ }
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
    \  'ff',  'fF',  'fl',  'fL',  'fh',  'fH',
    \ 'fpf', 'fpF', 'fpl', 'fpL', 'fph', 'fpH',
    \ ]
" }}}

" Function: s:fw.init() dict {{{
function! s:fw.init() dict
    " 设置搜索结果高亮
    augroup UserModulesSearch
        autocmd!
        autocmd User Grepper call FindWowHighlight(s:fw.pat)
    augroup END
    " 设置搜索引擎
    call s:fw.setEngine('rg', 'asyncrun')
    call s:fw.setEngine('fuzzy', 'leaderf')
endfunction
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
            \ 'lst' : ['--no-fixed-strings', '--hidden', '--no-ignore'],
            \ 'cmd' : {sopt, arg -> s:fw.exec(0, arg)}
            \ })
    else
        if a:0
            let l:self.opt .= a:1
        endif
        " format: printf('cmd %s %s %s',<opt>,<pat>,<loc>)
        let l:exec = printf(self.cmd, self.opt, escape(self.pat, self.engine.ch), self.loc)
        execute l:exec
        call FindWowHighlight(self.pat)
        call SetExecLast(l:exec)
    endif
endfunction
" }}}

call s:fw.init()
" }}}

" Function: FindWow(keys, mode) {{{ 超速查找
function! FindWow(keys, mode)
    " doc
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
    " parse function
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
            let l:loc = GetInput('Location: ', '', 'customlist,GetMultiFilesCompletion', expand('%:p:h'))
            if !empty(l:loc)
                let l:loc = split(l:loc, '|')
                call map(l:loc, {key, val -> (val =~# '[/\\]$') ? strcharpart(val, 0, strchars(val) - 1) : val})
                let l:loc = join(l:loc, '" "') " for \"l:loc\"
            endif
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
                let l:opt .= '-g"*.{' . s:ws.fw.filters . '}" '
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
            let s:fw.strings = []
        endif
        return l:cmd
    endfunction
    " }}}
    " Function: s:parseVimgrep() closure {{{
    function! s:parseVimgrep() closure
        if a:keys !~# 'v'
            return 0
        endif

        " get pattern and set options
        let s:fw.pat = s:parsePattern()
        if empty(s:fw.pat) | return 0 | endif
        let l:pat = (a:keys =~? 's') ? ('\<' . s:fw.pat . '\>') : (s:fw.pat)
        let l:pat .= (a:keys =~# '[iws]') ? '\c' : '\C'

        " set loaction
        let l:loc = '%'
        if a:keys =~# 'p'
            let l:loc = GetInput('Location: ', '', 'customlist,GetMultiFilesCompletion', expand('%:p:h'))
            let l:loc = tr(l:loc, '|', ' ')
            if empty(l:loc) | return 0 | endif
        endif

        " execute vimgrep
        execute 'vimgrep /' . l:pat . '/j ' . l:loc
        echo 'Finding...'
        if empty(getqflist())
            echo 'No match: ' . l:pat
        else
            botright copen
            call FindWowHighlight(s:fw.pat)
        endif
        return 1
    endfunction
    " }}}

    " try use vimgrep first
    if s:parseVimgrep() | return | endif

    let s:fw.pat = s:parsePattern()
    if empty(s:fw.pat) | return | endif
    let s:fw.loc = s:parseLocation()
    if empty(s:fw.loc) | return | endif
    let s:fw.opt = s:parseOptions()
    let s:fw.cmd = s:parseCommand()

    call s:fw.exec(a:keys =~# 'F')
endfunction
" }}}

" Function: FindWowKill() {{{ 停止超速查找
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
        execute 'lcd ' . l:path
        execute s:fw.engine[a:keys[0] . a:keys[-1:]]
    endif
endfunction
" }}}

" Function: FindWowSetEngine(type) {{{ 设置engine
function! FindWowSetEngine(type)
    if a:type ==# 'engine'
        call PopSelection(s:fw.engine.sel)
    else
        call PopSelection(s:fw.engine.sel.dic[a:type])
    endif
endfunction
" }}}

" Function: FindWowSetArgs(type) {{{ 设置args
" @param type: p-path, f-filters, g-glob
" @return 0表示异常结束函数（path无效），1表示正常结束函数
function! FindWowSetArgs(type)
    if a:type =~# 'p'
        let l:path = GetInput('fw.path: ', '', 'dir', expand('%:p:h'))
        if empty(l:path)
            return 0
        endif
        let l:path = fnamemodify(l:path, ':p')
        if l:path =~# '[/\\]$'
            let l:path = strcharpart(l:path, 0, strchars(l:path) - 1)
        endif
        let s:ws.fw.path = l:path
    endif
    if a:type =~# 'f'
        let s:ws.fw.filters = GetInput('fw.filters: ')
    endif
    if a:type =~# 'g'
        let s:ws.fw.globlst = split(GetInput('fw.globlst: '))
    endif
    return 1
endfunction
" }}}

" Function: FindWowHighlight([string]) {{{ 高亮字符串
" @param string: 若有字符串，则先添加到s:fw.strings，再高亮
function! FindWowHighlight(...)
    if &filetype ==# 'leaderf'
        " use leaderf's highlight
    elseif &filetype ==# 'qf'
        if a:0 >= 1
            call add(s:fw.strings, a:1)
        endif
        for str in s:fw.strings
            execute 'syntax match IncSearch /\V\c' . escape(str, '\/') . '/'
        endfor
    endif
endfunction
" }}}
" }}}

" Scripts {{{
" Struct: s:rs {{{
let s:rs = {
    \ 'sel' : {
        \ 'exe' : {
            \ 'opt' : 'select scripts to run',
            \ 'lst' : [
                    \ 'retab',
                    \ '%s/\s\+$//ge',
                    \ '%s/\r//ge',
                    \ 'edit ++enc=utf-8',
                    \ 'edit ++enc=cp936',
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
                        \ 'dsr' : 'copy config file',
                        \ 'lst' : ['.ycm_extra_conf.py', 'jsconfig.json', '.vimspector.json'],
                        \ 'cmd' : {sopt, arg -> execute('edit ' . s:rs.func.copyConfig(arg))},
                        \ },
                    \ 'lineToTop'        : 'frozen current line to top',
                    \ 'clearUndo'        : 'clear undo history',
                    \ },
            \ 'cmd' : {sopt, arg -> has_key(s:rs.func, arg) ? s:rs.func[arg]() : execute(arg)},
            \ },
        \ 'async' : {
            \ 'opt' : 'select scripts to run async',
            \ 'lst' : [
                    \ 'python -m json.tool %',
                    \ 'python setup.py build',
                    \ 'objdump -D -S -C %:r > %.asm',
                    \ 'go mod init %:r',
                    \ 'cflow -T %',
                    \ 'createCtags',
                    \ ],
            \ 'cmd' : {sopt, arg -> has_key(s:rs.func, arg) ? s:rs.func[arg]() : execute(':AsyncRun ' . arg)},
            \ }
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
    set undolevels=-1
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

" Function: s:rs.func.createCtags() dict {{{ 生成tags
function! s:rs.func.createCtags() dict
    if !empty(s:ws.root)
        execute(':AsyncRun cd '. s:ws.root . ' && ctags -R')
    else
        echo 'No root in s:ws'
    endif
endfunction
" }}}
" }}}

" Function: RunScript(type) " {{{
function! RunScript(type)
    call PopSelection(s:rs.sel[a:type])
endfunction
" }}}

" Function: FuncMacro(key) {{{ 执行宏
function! FuncMacro(key)
    let l:mstr = 'normal! @' . a:key
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
                \ 'p': 'py'}[a:key[-1:]]
    let l:ntab = a:key[0] ==# 't'
    call FuncEditFile(l:suffix, l:ntab)
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
    call SetExecLast('call FuncInsertSpace(''' . a:string . ''', ''' . a:pos . ''')', v:null)
endfunction
let RunInsertSpaceH = function('ExecInput', [['Divide H: '], 'FuncInsertSpace', 'h'])
let RunInsertSpaceB = function('ExecInput', [['Divide B: '], 'FuncInsertSpace', 'b'])
let RunInsertSpaceL = function('ExecInput', [['Divide L: '], 'FuncInsertSpace', 'l'])
let RunInsertSpaceD = function('ExecInput', [['Delete D: '], 'FuncInsertSpace', 'd'])
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

" Output {{{
" Function: QuickfixBasic(kyes) {{{ 基本操作
function! QuickfixBasic(keys)
    let l:type = a:keys[0]
    let l:oprt = a:keys[1]
    if l:oprt ==# 'o'
        execute 'botright ' . l:type . 'open'
        call FindWowHighlight()
    elseif l:oprt ==# 'c'
        if &filetype==#'qf'
            wincmd p
        endif
        execute l:type . 'close'
    elseif l:oprt ==# 'j'
        execute l:type . 'next'
        silent! normal! zO
        normal! zz
    elseif l:oprt ==# 'J'
        execute l:type . 'last'
        silent! normal! zO
        normal! zz
    elseif l:oprt ==# 'k'
        execute l:type . 'previous'
        silent! normal! zO
        normal! zz
    elseif l:oprt ==# 'K'
        execute l:type . 'first'
        silent! normal! zO
        normal! zz
    endif
endfunction
" }}}

" Function: QuickfixGet() {{{ 类型与编号
function! QuickfixGet()
    " location-list : 每个窗口对应一个位置列表
    " quickfix      : 整个vim对应一个quickfix
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
    call FindWowHighlight()
endfunction
" }}}

" Function: QuickfixMakeIconv() {{{ 编码转换
function! QuickfixMakeIconv(sopt, argstr, type)
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
" }}}

" Function: QuickfixIconv() {{{ 编码转换
function! QuickfixIconv()
    let l:type = QuickfixGet()[0]
    if empty(l:type)
        return
    endif
    call PopSelection({
        \ 'opt' : 'select encoding',
        \ 'lst' : ['"cp936", "utf-8"', '"utf-8", "cp936"'],
        \ 'cmd' : 'QuickfixMakeIconv',
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
        \ 'signcolumn'   : ['no', 'auto'],
        \ },
    \ 'func' : {
        \ 'number' : 'OptFuncNumber',
        \ 'syntax' : 'OptFuncSyntax',
        \ },
    \ }
" }}}

" Function: OptionInv(opt) {{{ 切换参数值（bool取反）
function! OptionInv(opt)
    execute printf('set inv%s', a:opt)
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
    syntax enable                       " 语法高亮
    filetype plugin indent on           " 打开文件类型检测
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
    set listchars=eol:$,tab:»·,trail:~,space:.
                                        " 不可见字符显示
    set autoindent                      " 使用autoindent缩进
    set nobreakindent                   " 折行时不缩进
    set conceallevel=0                  " 显示markdown等格式中的隐藏字符
    set foldenable                      " 充许折叠
    set foldopen-=search                " 查找时不自动展开折叠
    set foldcolumn=0                    " 0~12,折叠标识列，分别用“-”和“+”而表示打开和关闭的折叠
    set foldmethod=indent               " 设置折叠，默认为缩进折叠
    set scrolloff=3                     " 光标上下保留的行数
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
    set noimdisable                     " 切换Normal模式时，自动换成英文输入法
    set visualbell                      " 使用可视响铃代替鸣声
    set noerrorbells                    " 关闭错误信息响铃
    set belloff=all                     " 关闭所有事件的响铃
    set helplang=cn,en                  " 优先查找中文帮助
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
" }}}

" Gui {{{
" Function: GuiAdjustFontSize(inc) {{{
let s:gui_fontsize = 12
function! GuiAdjustFontSize(inc)
    let s:gui_fontsize += a:inc
    if IsLinux()
        execute 'set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ ' . s:gui_fontsize
        execute 'set guifontwide=WenQuanYi\ Micro\ Hei\ Mono\ ' . s:gui_fontsize
    elseif IsWin()
        execute 'set guifont=Consolas\ For\ Powerline:h' . s:gui_fontsize
        execute 'set guifontwide=Microsoft\ YaHei\ Mono:h' . (s:gui_fontsize - 1)
    elseif IsMac()
        execute 'set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h' . s:gui_fontsize
    endif
endfunction
" }}}

" Gui-vim {{{
if IsGVim()
    set guioptions-=m                   " 隐藏菜单栏
    set guioptions-=T                   " 隐藏工具栏
    set guioptions-=L                   " 隐藏左侧滚动条
    set guioptions-=r                   " 隐藏右侧滚动条
    set guioptions-=b                   " 隐藏底部滚动条
    set guioptions-=e                   " 不使用Gui标签
    call GuiAdjustFontSize(0)
    set lines=25
    set columns=90
    set linespace=0
    if IsWin()
        nnoremap <leader>tf <Esc>:call libcallnr('gvimfullscreen.dll', 'ToggleFullScreen', 0)<CR>
    endif
    nnoremap <kPlus> :call GuiAdjustFontSize(1)<CR>
    nnoremap <kMinus> :call GuiAdjustFontSize(-1)<CR>
endif
" }}}

" Gui-neovim {{{
if IsNVim()
augroup UserSettingsGui
    autocmd!
    autocmd VimEnter * call s:NVimQt_setGui()
augroup END

" Function: s:NVimQt_setGui() {{{
function! s:NVimQt_setGui()
if IsNVimQt()
    call GuiAdjustFontSize(0)
    GuiLinespace 0
    GuiTabline 0
    GuiPopupmenu 0
    nnoremap <silent> <RightMouse> :call GuiShowContextMenu()<CR>
    inoremap <silent> <RightMouse> <Esc>:call GuiShowContextMenu()<CR>
    vnoremap <silent> <RightMouse> :call GuiShowContextMenu()<CR>gv
    nnoremap <leader>tf :call GuiWindowFullScreen(!g:GuiWindowFullScreen)<CR>
    nnoremap <leader>tm :call GuiWindowMaximized(!g:GuiWindowMaximized)<CR>
    nnoremap <kPlus> :call GuiAdjustFontSize(1)<CR>
    nnoremap <kMinus> :call GuiAdjustFontSize(-1)<CR>
    " Qt-Gui中使用<S-lt>代替<映射
    nnoremap <S-Lt> <<
endif
endfunction
" }}}
endif
" }}}
" }}}

" Autocmd {{{
augroup UserSettingsCmd
    autocmd!
    autocmd BufNewFile *                set fileformat=unix
    autocmd BufRead,BufNewFile *.tex    set filetype=tex
    autocmd BufRead,BufNewFile *.log    set filetype=log
    autocmd Filetype vim                setlocal foldmethod=marker
    autocmd Filetype c,cpp,javascript   setlocal foldmethod=syntax
    autocmd Filetype python             setlocal foldmethod=indent
    autocmd FileType go                 setlocal expandtab
    autocmd Filetype vim,help,lua       call s:onBufferMappings()
    autocmd BufReadPre *                call s:onLargeFile()
augroup END

" Function: s:onBufferMappings() {{{
function! s:onBufferMappings()
    nnoremap <buffer> <S-k> :call execute('help ' . expand('<cword>'))<CR>
    vnoremap <buffer> <S-k> :call execute('help ' . GetSelected())<CR>
endfunction
" }}}

" Function: s:onLargeFile() {{{
function! s:onLargeFile()
    let l:fsize = getfsize(expand('<afile>'))
    if l:fsize >= 5 * 1024 * 1024 || l:fsize == -2
        let b:lightline_check_flg = 0
        setlocal filetype=log
        setlocal buftype=nowrite
        setlocal undolevels=-1
        setlocal noswapfile
    endif
endfunction
" }}}
" }}}
" }}} End

" User Mappings {{{
" Basic {{{
    " 重复上次操作命令
    nnoremap <leader>. :call ExecLast(1)<CR>
    nnoremap <leader><leader>. :call ExecLast(0)<CR>
    nnoremap <M-;> @:
    vnoremap <silent> <leader><leader>;
        \ :call feedkeys(':' . GetSelected(), 'n')<CR>
    " 回退操作
    nnoremap <S-u> <C-r>
    " 大小写转换
    nnoremap <leader>u ~
    vnoremap <leader>u ~
    nnoremap <leader>gu g~
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
    " 嵌套映射匹配符(%)
if IsVim()
    packadd matchit
endif
    nmap <S-s> %
    vmap <S-s> %
    " 行首和行尾
    nnoremap <S-l> $
    nnoremap <S-h> ^
    vnoremap <S-l> $
    vnoremap <S-h> ^
    " 复制到行首行尾
    nnoremap yL y$
    nnoremap yH y^
    " j, k 移行
    nnoremap j gj
    vnoremap j gj
    nnoremap k gk
    vnoremap k gk
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
    nnoremap <C-h> 2zh
    nnoremap <C-l> 2zl
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
    " 打开/关闭quickfix
    nnoremap <leader>qo :call QuickfixBasic('co')<CR>
    nnoremap <leader>qc :call QuickfixBasic('cc')<CR>
    nnoremap <leader>qj :call QuickfixBasic('cj')<CR>
    nnoremap <leader>qJ :call QuickfixBasic('cJ')<CR>
    nnoremap <leader>qk :call QuickfixBasic('ck')<CR>
    nnoremap <leader>qK :call QuickfixBasic('cK')<CR>
    " 打开/关闭location-list
    nnoremap <leader>lo :call QuickfixBasic('lo')<CR>
    nnoremap <leader>lc :call QuickfixBasic('lc')<CR>
    nnoremap <leader>lj :call QuickfixBasic('lj')<CR>
    nnoremap <leader>lJ :call QuickfixBasic('lJ')<CR>
    nnoremap <leader>lk :call QuickfixBasic('lk')<CR>
    nnoremap <leader>lK :call QuickfixBasic('lK')<CR>
    " 预览quickfix和location-list
    nnoremap <C-Space> :call QuickfixPreview()<CR>
    " 在新tab中打开列表项
    nnoremap <leader>qt :call QuickfixTabEdit()<CR>
    " 将quickfix中的内容复制location-list
    nnoremap <leader>ql
        \ :call setloclist(0, getqflist())<Bar>
        \ :vertical botright lopen 35<CR>
    " 编码转换
    nnoremap <leader>qi :call QuickfixIconv()<CR>
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

" Terminal {{{
if IsWin()
    nnoremap <leader>tz :terminal<CR>
else
    nnoremap <leader>tz :terminal zsh<CR>
endif
    nnoremap <leader><leader>z :terminal<Space>
if IsVim()
    set termwinkey=<C-l>
    tnoremap <Esc> <C-l>N
else
    tnoremap <C-l> <C-\><C-n><C-w>
    tnoremap <Esc> <C-\><C-n>
endif
" }}}

" Project {{{
    " 常用操作
    nnoremap <silent> <leader>ei
        \ :call ExecInput(['Suffix: '], 'FuncEditFile', 0)<CR>
    nnoremap <silent> <leader>eti
        \ :call ExecInput(['Suffix: '], 'FuncEditFile', 1)<CR>
    nnoremap <leader>ec :call RunEditFile('c')<CR>
    nnoremap <leader>ea :call RunEditFile('a')<CR>
    nnoremap <leader>ep :call RunEditFile('p')<CR>
    nnoremap <leader>etc :call RunEditFile('tc')<CR>
    nnoremap <leader>eta :call RunEditFile('ta')<CR>
    nnoremap <leader>etp :call RunEditFile('tp')<CR>
    nnoremap <leader>eh :call RunInsertSpaceH()<CR>
    nnoremap <leader>eb :call RunInsertSpaceB()<CR>
    nnoremap <leader>el :call RunInsertSpaceL()<CR>
    nnoremap <leader>ed :call RunInsertSpaceD()<CR>
    nnoremap <silent> <leader>ac
        \ :call ExecInput(['Command: ', '', 'command'], {str -> append(line('.'), GetEval(str, 'command'))})<CR>
    nnoremap <silent> <leader>af
        \ :call ExecInput(['Function: ', '', 'function'], {str -> append(line('.'), GetEval(str, 'function'))})<CR>
    vnoremap <silent> <leader>ac
        \ :call append(line('.'), GetEval(GetSelected(), 'command'))<CR>
    vnoremap <silent> <leader>af
        \ :call append(line('.'), GetEval(GetSelected(), 'function'))<CR>
    nnoremap <leader>sf :call RunSwitchFile()<CR>
    nnoremap <leader>se :call RunScript('exe')<CR>
    nnoremap <leader>sa :call RunScript('async')<CR>
    " RunProject
    for key in s:rp.mappings
        execute printf('nnoremap <leader>%s :call RunProject("%s")<CR>', key, key)
    endfor
" }}}

" Find {{{
    " /?
    nnoremap <leader><Esc> :nohlsearch<CR>
    nnoremap i :nohlsearch<CR>i
    " *,#使用\< \>，而g*,g# 不使用\< \>
    nnoremap <leader>8  *
    nnoremap <leader>3  #
    nnoremap <leader>g8 g*
    nnoremap <leader>g3 g#
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
    nnoremap <leader>fee :call FindWowSetEngine('engine')<CR>
    nnoremap <leader>fes :call FindWowSetEngine('rg')<CR>
    nnoremap <leader>feu :call FindWowSetEngine('fuzzy')<CR>
    nnoremap <leader>fea :call FindWowSetArgs('pfg')<CR>
    nnoremap <leader>fer :call FindWowSetArgs('p')<CR>
    nnoremap <leader>fef :call FindWowSetArgs('f')<CR>
    nnoremap <leader>feg :call FindWowSetArgs('g')<CR>
" }}}
" }}} End
