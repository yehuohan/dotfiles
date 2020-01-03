
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Vimrc: configuration for vim and neovim.
"        set 'Global settings' before using this vimrc.
" Github: https://github.com/yehuohan/dotconfigs
" Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" README {{{
" Help {{{
    " help/h        : 查看Vim帮助
    " <S-k>         : 快速查看光标所在cword或选择内容的vim帮助
    " h *@en        : 指定查看英文(en，cn即为中文)帮助
    " h index       : 帮助列表
    " h script      :  VimL脚本语法
    " h range       : Command范围
    " h pattern     : 匹配模式
    " h magic       : Magic匹配模式
    " h Visual      : Visual模式
    " h map-listing : 映射命令
    " h registers   : 寄存器列表
    " h v:count     : 普通模式命令计数
" }}}

" Map {{{
    " - Normal模式下使用<leader>代替<C-?>,<S-?>,<A-?>，
    " - Insert模式下map带ctrl,alt的快捷键
    " - 尽量不改变vim原有键位的功能定义
    " - 尽量一只手不同时按两个键，且连续按键相隔尽量近
    " - 尽量不映射偏远的按键（F1~F12，数字键等），且集中于'j,k,i,o'键位附近
    " - 调换Esc和CapsLock键
" }}}
" }}} End

" Platform {{{
" vim or nvim, with or without gui {{{
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

" linux or win {{{
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

" Global Settings {{{
let s:home = resolve(expand('<sfile>:p:h'))
if (IsLinux() || IsMac() || IsGw())
    let $DotVimPath=s:home . '/.vim'
elseif IsWin()
    let $DotVimPath=s:home . '\vimfiles'
endif
set rtp+=$DotVimPath

" first {{{
set encoding=utf-8                      " 内部使用utf-8编码
if IsVim()
    set nocompatible                    " 不兼容vi
endif
let mapleader="\<Space>"
nnoremap ; :
nnoremap : ;
vnoremap ; :
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
    set <M-Space>=<Space>
    set <M-,>=,
    set <M-.>=.
    set <M-;>=;
endif
" }}}

" s:gset {{{
let s:gset_file = $DotVimPath . '/.gset.json'
let s:gset = {
    \ 'set_dev' : v:null,
    \ 'set_os' : v:null,
    \ 'use_powerfont' : 1,
    \ 'use_lightline': 1,
    \ 'use_startify' : 1,
    \ 'use_fzf' : 1,
    \ 'use_leaderf' : 1,
    \ 'use_ycm' : 1,
    \ 'use_ultisnips' : 1,
    \ 'use_utils' : 1,
    \ }
" FUNCTION: s:gsetLoad() {{{
function! s:gsetLoad()
    if filereadable(s:gset_file)
        call extend(s:gset, json_decode(join(readfile(s:gset_file))), 'force')
    else
        call s:gsetSave()
    endif
    call env#env(s:gset.set_dev, s:gset.set_os)
endfunction
" }}}
" FUNCTION: s:gsetSave() {{{
function! s:gsetSave()
    call writefile([json_encode(s:gset)], s:gset_file)
    echo 's:gset save successful!'
endfunction
" }}}
" FUNCTION: s:gsetInit() {{{
function! s:gsetInit()
    for [key, val] in sort(items(s:gset))
        let s:gset[key] = input('let s:gset.'. key . ' = ', val)
    endfor
    redraw
    call s:gsetSave()
endfunction
" }}}
" FUNCTION: s:gsetShow() {{{
function! s:gsetShow()
    let l:str = 'Gset:'
    for [key, val] in sort(items(s:gset))
        let l:str .= "\n    " . key . ' = ' . val
    endfor
    echo l:str
endfunction
" }}}
command! -nargs=0 GSLoad :call s:gsetLoad()
command! -nargs=0 GSInit :call s:gsetInit()
command! -nargs=0 GSShow :call s:gsetShow()
call s:gsetLoad()
" }}}
" }}} End

" Plug Settings {{{
" s:plug {{{
let s:plug = {
    \ 'timer' : 0,
    \ 'delay' : 700,
    \ 'list'  : []
    \ }
" FUNCTION: s:plug.append(name) dict {{{
function! s:plug.append(name) dict
    call add(self.list, a:name)
endfunction
" }}}

" FUNCTION: s:plug.init() dict {{{
function! s:plug.init() dict
    if !empty(self.list)
        let s:plug.timer = timer_start(s:plug.delay, {timer -> call('plug#load', self.list)})
    endif
endfunction
" }}}
" }}}

call plug#begin($DotVimPath.'/bundle')  " 可以指定插件安装位置

" 基本编辑 {{{
" easy-motion {{{ 快速跳转
    Plug 'easymotion/vim-easymotion'
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
    Plug 'mg979/vim-visual-multi'
    let g:VM_mouse_mappings = 0         " 禁用鼠标
    " C-n: 进入cursor模式
    " C-Up/Down: 进入extend模式
    " Tab: 切换cursor/extend模式
    let g:VM_leader = ','
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
    Plug 't9md/vim-textmanip'
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
"}}}

" traces {{{ 预览增强
    Plug 'markonm/traces.vim'
    " 支持:s, :g, :v, :sort, :range预览
" }}}

" fzf {{{ 模糊查找
if s:gset.use_fzf
    " linux下直接pacman -S fzf
    " win下载fzf.exe放入bundle/fzf/bin/下
    if IsWin()
        Plug 'junegunn/fzf', {'on': ['FzfFiles', 'FzfRg', 'FzfTags']}
    endif
    Plug 'junegunn/fzf.vim', {'on': ['FzfFiles', 'FzfRg', 'FzfTags']}
    let g:fzf_command_prefix = 'Fzf'
    nnoremap <silent> <leader><leader>f :call feedkeys(':FzfFiles ', 'n')<CR>
endif
" }}}

" LeaderF {{{ 模糊查找
if s:gset.use_leaderf
if IsLinux()
    Plug 'Yggdroot/LeaderF', {'do': './install.sh'}
    augroup PluginLeaderF
        autocmd!
        autocmd VimEnter * call s:Plug_lf_removeMru()
    augroup END
    function! s:Plug_lf_removeMru()
        try
            autocmd! LeaderF_Mru
        " E216:事件组不存在
        catch /^Vim\%((\a\+)\)\=:E216/
        endtry
    endfunction
elseif IsWin()
    Plug 'Yggdroot/LeaderF', {'do': './install.bat'}
else
    Plug 'Yggdroot/LeaderF'
endif
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
    nnoremap <silent> <leader><leader>l :call feedkeys(':LeaderfFile ', 'n')<CR>
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
    nnoremap <leader>lh :LeaderfHelp<CR>
endif
" }}}

" grep {{{ 大范围查找
if IsVim()
    Plug 'yehuohan/grep'                " 不支持neovim
endif
    Plug 'mhinz/vim-grepper', {'on': ['Grepper', '<plug>(GrepperOperator)']}
    let g:grepper = {
        \ 'rg': {
            \ 'grepprg':    'rg -H --no-heading --vimgrep' . (has('win32') ? ' $*' : ''),
            \ 'grepformat': '%f:%l:%c:%m',
            \ 'escape':     '\^$.*+?()[]{}|'}
        \}
" }}}

" far {{{ 查找与替换
    Plug 'brooth/far.vim', {'on': 'Farp'}
    let g:far#file_mask_favorites = ['%', '*.txt']
    nnoremap <leader>sr :Farp<CR>
    nnoremap <leader>fd :Fardo<CR>
    nnoremap <leader>fu :Farundo<CR>
" }}}

" tabular {{{ 字符对齐
    Plug 'godlygeek/tabular', {'on': 'Tabularize'}
    " /,/r2l0   -   第1个field使用第1个对齐符（右对齐），再插入2个空格
    "               第2个field使用第2个对齐符（左对齐），再插入0个空格
    "               第3个field又重新从第1个对齐符开始（对齐符可以有多个，循环使用）
    "               这样就相当于：需对齐的field使用第1个对齐符，分割符(,)field使用第2个对齐符
    " /,\zs     -   将分割符(,)作为对齐内容field里的字符
    nnoremap <silent> <leader><leader>a :call feedkeys(':Tabularize /', 'n')<CR>
    vnoremap <leader><leader>a :Tabularize /
" }}}

" easy-align {{{ 字符对齐
    Plug 'junegunn/vim-easy-align'
    " 默认对齐内含段落（Text Object: vip）
    nmap <leader>ga <Plug>(EasyAlign)ip
    xmap <leader>ga <Plug>(EasyAlign)
    " 命令格式
    ":EasyAlign[!] [N-th]DELIMITER_KEY[OPTIONS]
    ":EasyAlign[!] [N-th]/REGEXP/[OPTIONS]
    nnoremap <silent> <leader><leader>g
        \ :call feedkeys(':' . join(GetContentRange('^[ \t]*$', '^[ \t]*$'), ',') . 'EasyAlign', 'n')<CR>
    vnoremap <leader><leader>g :EasyAlign
" }}}

" smooth-scroll {{{ 平滑滚动
    Plug 'terryma/vim-smooth-scroll'
    nnoremap <silent> <M-n> :call smooth_scroll#down(&scroll, 0, 2)<CR>
    nnoremap <silent> <M-m> :call smooth_scroll#up(&scroll, 0, 2)<CR>
    nnoremap <silent> <M-j> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>
    nnoremap <silent> <M-k> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
" }}}

" expand-region {{{ 快速块选择
    Plug 'terryma/vim-expand-region'
    nmap <C-p> <Plug>(expand_region_expand)
    vmap <C-p> <Plug>(expand_region_expand)
    nmap <C-u> <Plug>(expand_region_shrink)
    vmap <C-u> <Plug>(expand_region_shrink)
" }}}

" textobj-user {{{ 文本对象
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-indent'
    let g:textobj_indent_no_default_key_mappings=1
    omap aI <Plug>(textobj-indent-a)
    omap iI <Plug>(textobj-indent-i)
    omap ai <Plug>(textobj-indent-same-a)
    omap ii <Plug>(textobj-indent-same-i)
    vmap aI <Plug>(textobj-indent-a)
    vmap iI <Plug>(textobj-indent-i)
    vmap ai <Plug>(textobj-indent-same-a)
    vmap ii <Plug>(textobj-indent-same-i)
    Plug 'kana/vim-textobj-function'
    Plug 'glts/vim-textobj-comment'
    Plug 'adriaanzon/vim-textobj-matchit'
    Plug 'lucapette/vim-textobj-underscore'
    omap au <Plug>(textobj-underscore-a)
    omap iu <Plug>(textobj-underscore-i)
    vmap au <Plug>(textobj-underscore-a)
    vmap iu <Plug>(textobj-underscore-i)
" }}}

" repeat {{{ 重复命令
    Plug 'tpope/vim-repeat'
" }}}
" }}}

" 界面管理 {{{
" theme {{{ Vim主题(ColorScheme, StatusLine, TabLine)
    Plug 'morhetz/gruvbox'
    set rtp+=$DotVimPath/bundle/gruvbox
    let g:gruvbox_contrast_dark='soft'  " 背景选项：dark, medium, soft
    Plug 'junegunn/seoul256.vim'
    set rtp+=$DotVimPath/bundle/seoul256.vim
    let g:seoul256_background=236       " 233(暗) ~ 239(亮)
    let g:seoul256_light_background=256 " 252(暗) ~ 256(亮)
    Plug 'altercation/vim-colors-solarized'
    set rtp+=$DotVimPath/bundle/vim-colors-solarized
    Plug 'sainnhe/vim-color-forest-night'
    set rtp+=$DotVimPath/bundle/vim-color-forest-night
    Plug 'srcery-colors/srcery-vim'
    set rtp+=$DotVimPath/bundle/srcery-vim
if !s:gset.use_lightline
    try
        set background=dark
        colorscheme gruvbox
    " E185: 找不到主题
    catch /^Vim\%((\a\+)\)\=:E185/
        silent! colorscheme desert
    endtry
else
    Plug 'yehuohan/lightline.vim'
    "                    
    " ► ✘ ❖ ⌘ ▫ ▪ ★ ☆ • ≡ ፨ ♥
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
        let g:lightline.colorscheme = 'solarized'
    endtry
    let g:lightline.blacklist = {'tagbar':0, 'nerdtree':0, 'Popc':0}
    nnoremap <leader>tl :call lightline#toggle()<CR>
    nnoremap <leader>tk :call Plug_ll_toggleCheck()<CR>

    " Augroup: PluginLightline {{{
    augroup PluginLightline
        autocmd!
        autocmd ColorScheme * call s:Plug_ll_colorScheme()
        autocmd CursorHold,BufWritePost * call s:Plug_ll_checkRefresh()
    augroup END

    function! s:Plug_ll_colorScheme()
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

    function! s:Plug_ll_checkRefresh()
        if get(b:, 'lightline_changedtick', 0) == b:changedtick
            return
        endif
        unlet! b:lightline_changedtick
        call lightline#update()
        let b:lightline_changedtick = b:changedtick
    endfunction
    " }}}

    " FUNCTION: Plug_ll_toggleCheck() {{{
    function! Plug_ll_toggleCheck()
        let b:lightline_check_flg = !get(b:, 'lightline_check_flg', 1)
        call lightline#update()
        echo 'b:lightline_check_flg = ' . b:lightline_check_flg
    endfunction
    " }}}

    " FUNCTION: lightline components {{{
    function! Plug_ll_mode()
        return &ft ==# 'tagbar' ? 'Tagbar' :
            \ &ft ==# 'nerdtree' ? 'NERDTree' :
            \ &ft ==# 'qf' ? (QuickfixGet()[0] ==# 'c' ? 'Quickfix' : 'Location') :
            \ &ft ==# 'help' ? 'Help' :
            \ &ft ==# 'Popc' ? popc#ui#GetStatusLineSegments('l')[0] :
            \ &ft ==# 'startify' ? 'Startify' :
            \ winwidth(0) > 60 ? lightline#mode() : ''
    endfunction

    function! Plug_ll_msgLeft()
        if &ft ==# 'qf'
            return 'cwd = ' . getcwd()
        else
            let l:fw = FindWowGetArgs()
            let l:fp = expand('%:p')
            return empty(l:fw) ? l:fp : substitute(l:fp, escape(l:fw[0], '\'), '', '')
        endif
    endfunction

    function! Plug_ll_msgRight()
        let l:fw = FindWowGetArgs()
        return empty(l:fw) ? '' : (l:fw[0] . '[' . l:fw[1] . '(' . join(l:fw[2],',') . ')]')
    endfunction

    function! Plug_ll_checkMixedIndent()
        if !get(b:, 'lightline_check_flg', 1)
            return ''
        endif
        let l:ret = search('\t', 'nw')
        return (l:ret == 0) ? '' : 'I:'.string(l:ret)
    endfunction

    function! Plug_ll_checkTrailing()
        if !get(b:, 'lightline_check_flg', 1)
            return ''
        endif
        let ret = search('\s\+$', 'nw')
        return (l:ret == 0) ? '' : 'T:'.string(l:ret)
    endfunction
    " }}}
endif
" }}}

" rainbow {{{ 彩色括号
    Plug 'luochen1990/rainbow'
    let g:rainbow_active = 1
    nnoremap <leader>tr :RainbowToggle<CR>
" }}}

" indentLine {{{ 显示缩进标识
    Plug 'Yggdroot/indentLine'
    "let g:indentLine_char = '|'        " 设置标识符样式
    let g:indentLinet_color_term=200    " 设置标识符颜色
    nnoremap <leader>ti :IndentLinesToggle<CR>
" }}}

" popset {{{ 弹出选项
    Plug 'yehuohan/popset'
    let g:Popset_SelectionData = [
        \{
            \ 'opt' : ['filetype', 'ft'],
            \ 'dsr' : 'When this option is set, the FileType autocommand event is triggered.',
            \ 'lst' : ['cpp', 'c', 'python', 'julia', 'vim', 'go', 'markdown', 'help', 'text',
                     \ 'sh', 'conf', 'make', 'cmake', 'javascript', 'json', 'html'],
            \ 'dic' : {
                    \ 'cpp'        : 'Cpp file',
                    \ 'c'          : 'C file',
                    \ 'python'     : 'Python script file',
                    \ 'julia'      : 'Julia script file',
                    \ 'vim'        : 'Vim script file',
                    \ 'go'         : 'Go Language',
                    \ 'markdown'   : 'MarkDown file',
                    \ 'help'       : 'Vim help doc',
                    \ 'text'       : 'Simple text',
                    \ 'sh'         : 'Linux shell script',
                    \ 'conf'       : 'Config file',
                    \ 'make'       : 'Makefile of .mak file',
                    \ 'cmake'      : 'CMakeLists.txt file',
                    \ 'javascript' : 'JavaScript file',
                    \ 'json'       : 'Json file',
                    \ 'html'       : 'Html file',
                    \},
            \ 'cmd' : 'popset#data#SetEqual',
            \ 'get' : 'popset#data#GetOptValue'
        \},
        \{
            \ 'opt' : ['colorscheme', 'colo'],
            \ 'lst' : ['forest-night', 'gruvbox', 'seoul256', 'seoul256-light', 'solarized', 'srcery'],
            \ 'cmd' : ''
        \}
    \ ]
    " set option with PopSet
    nnoremap <silent> <leader><leader>s :call feedkeys(':PopSet ', 'n')<CR>
    nnoremap <leader>sp :PopSet popset<CR>
" }}}

" popc {{{ buffer管理
    Plug 'yehuohan/popc'
    set hidden
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
    nnoremap <leader><leader>h :PopcBuffer<CR>
    nnoremap <M-i> :PopcBufferSwitchLeft<CR>
    nnoremap <M-o> :PopcBufferSwitchRight<CR>
    nnoremap <leader><leader>b :PopcBookmark<CR>
    nnoremap <leader><leader>w :PopcWorkspace<CR>
    nnoremap <silent> <leader>wf
        \ :let g:popc_wks_root = popc#layer#wks#GetCurrentWks()[1]<Bar>
        \ :execute empty(g:popc_wks_root) ? '' : ':LeaderfFile ' . g:popc_wks_root<CR>
    nnoremap <silent> <leader>wt
        \ :let g:popc_wks_root = popc#layer#wks#GetCurrentWks()[1]<Bar>
        \ :execute empty(g:popc_wks_root) ? '' : ':Leaderf rg -e "" ' . g:popc_wks_root<CR>
    nnoremap <silent> <leader>ty
        \ :let g:popc_tabline_layout = (get(g:, 'popc_tabline_layout', 0) + 1) % 3<Bar>
        \ :call call('popc#ui#TabLineSetLayout',
        \           [['buffer', 'tab'], ['buffer', ''], ['', 'tab']][g:popc_tabline_layout])<CR>
" }}}

" nerdtree {{{ 目录树导航
    Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTree']}
    let g:NERDTreeShowHidden = 1
    let g:NERDTreeMapPreview = 'go'
    let g:NERDTreeMapOpenInTabSilent = 'gt'
    let g:NERDTreeMapOpenSplit = 's'
    let g:NERDTreeMapPreviewSplit = 'gs'
    let g:NERDTreeMapOpenVSplit = 'i'
    let g:NERDTreeMapPreviewVSplit = 'gi'
    let g:NERDTreeMapJumpNextSibling = '<C-n>'
    let g:NERDTreeMapJumpPrevSibling = '<C-p>'
    let g:NERDTreeMapChangeRoot = 'cd'  " 更改根目录
    let g:NERDTreeMapChdir = 'CW'       " 更改CWD
    let g:NERDTreeMapCWD = 'CD'         " 更改根目录为CWD
    nnoremap <leader>te :NERDTreeToggle<CR>
    nnoremap <leader>tE :execute ':NERDTree ' . expand('%:p:h')<CR>
" }}}

" startify {{{ vim会话界面
if s:gset.use_startify
    Plug 'mhinz/vim-startify'
    if IsLinux()
        let g:startify_bookmarks = [ {'c': '~/.vimrc'},
                                    \ '~/.zshrc',
                                    \ '~/.config/nvim/init.vim',
                                    \ '~/.config/i3/config'
                                    \]
    elseif IsWin()
        let g:startify_bookmarks = [ {'c': '$DotVimPath/../_vimrc'},
                                    \ '$DotVimPath/.ycm_extra_conf.py',
                                    \ '$LOCALAPPDATA/nvim/init.vim'
                                    \]
    elseif IsMac()
        let g:startify_bookmarks = [ {'c': '~/.vimrc'}, '~/.zshrc']
    endif
    let g:startify_lists = [
            \ {'type': 'bookmarks', 'header': ['   Bookmarks']},
            \ {'type': 'files',     'header': ['   Recent Files']},
            \ ]
    let g:startify_files_number = 7
    nnoremap <leader>su :Startify<CR>
endif
" }}}

" signature {{{ 书签管理
    Plug 'kshenoy/vim-signature'
    let g:SignatureMap = {
        \ 'Leader'             :  "m",
        \ 'PlaceNextMark'      :  "m,",
        \ 'ToggleMarkAtLine'   :  "m.",
        \ 'PurgeMarksAtLine'   :  "m-",
        \ 'DeleteMark'         :  "dm",
        \ 'PurgeMarks'         :  "m<Space>",
        \ 'PurgeMarkers'       :  "m<BS>",
        \ 'GotoNextLineAlpha'  :  "']",
        \ 'GotoPrevLineAlpha'  :  "'[",
        \ 'GotoNextSpotAlpha'  :  "`]",
        \ 'GotoPrevSpotAlpha'  :  "`[",
        \ 'GotoNextLineByPos'  :  "]'",
        \ 'GotoPrevLineByPos'  :  "['",
        \ 'GotoNextSpotByPos'  :  "]`",
        \ 'GotoPrevSpotByPos'  :  "[`",
        \ 'GotoNextMarker'     :  "]-",
        \ 'GotoPrevMarker'     :  "[-",
        \ 'GotoNextMarkerAny'  :  "]=",
        \ 'GotoPrevMarkerAny'  :  "[=",
        \ 'ListBufferMarks'    :  "m/",
        \ 'ListBufferMarkers'  :  "m?"
    \ }
    nnoremap <leader>ts :SignatureToggleSigns<CR>
    nnoremap <leader>ma :SignatureListBufferMarks<CR>
    nnoremap <leader>mc :<C-U>call signature#mark#Purge('all')<CR>
    nnoremap <leader>mx :<C-U>call signature#marker#Purge()<CR>
    nnoremap <M-,> :<C-U>call signature#mark#Goto('prev', 'line', 'pos')<CR>
    nnoremap <M-.> :<C-U>call signature#mark#Goto('next', 'line', 'pos')<CR>
" }}}

" undotree {{{ 撤消历史
    Plug 'mbbill/undotree'
    nnoremap <leader>tu :UndotreeToggle<CR>
" }}}
" }}}

" 代码编写 {{{
" YouCompleteMe {{{ 自动补全
if s:gset.use_ycm
    " FUNCTION: Plug_ycm_build(info) {{{
    " Linux: 需要python-dev, python3-dev, cmake, llvm, clang
    " Windows: 需要python, cmake, VS, 7-zip
    " Params: install.py安装参数
    "   --clang-completer  : C-famlily，基于libclang补全
    "   --clangd-completer : C-famlily，基于clangd补全
    "   --go-completer     : Go补全，需要安装Go
    "   --ts-completer     : Javascript和TypeScript，基于TSServer补全，需要安装node和npm
    "   --java-completer   : Java补全，需要安装JDK8
    function! Plug_ycm_build(info)
        " info is a dictionary with 3 fields
        " - name:   name of the plugin
        " - status: 'installed', 'updated', or 'unchanged'
        " - force:  set on PlugInstall! or PlugUpdate!
        if a:info.status == 'installed' || a:info.force
            if IsLinux()
                !python install.py --clangd-completer --go-completer --java-completer --build-dir ycm_build
            elseif IsWin()
                !python install.py --clangd-completer --go-completer --java-completer --ts-completer --msvc 15 --build-dir ycm_build
            endif
        endif
    endfunction
    " }}}
    Plug 'ycm-core/YouCompleteMe', {'do': function('Plug_ycm_build'), 'on': []}
    call s:plug.append('YouCompleteMe')
    let g:ycm_global_ycm_extra_conf=$DotVimPath.'/.ycm_extra_conf.py'
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
    let g:ycm_key_detailed_diagnostics = ''                     " 直接使用:YcmShowDetailedDiagnostic命令
    let g:ycm_key_list_select_completion = ['<C-j>', '<C-n>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<C-k>', '<C-p>', '<Up>']
    let g:ycm_key_list_stop_completion = ['<C-y>']              " 关闭补全menu
    let g:ycm_key_invoke_completion = '<C-l>'                   " 显示补全内容，YCM使用completefunc（C-X C-U）
                                                                " YCM不支持的补全，通过omnifunc(C-X C-O)集成到YCM上
    imap <C-Space> <C-l>
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
    nnoremap <leader>yc :call Plug_ycm_createConf('.ycm_extra_conf.py')<CR>
    nnoremap <leader>yj :call Plug_ycm_createConf('jsconfig.json')<CR>

    function! Plug_ycm_createConf(filename)
        " 在当前目录下创建配置文件
        if !filereadable(a:filename)
            let l:file = readfile($DotVimPath . '/' . a:filename)
            call writefile(l:file, a:filename)
        endif
        execute 'edit ' . a:filename
    endfunction
endif
" }}}

" echodoc {{{ 参数文档显示
    Plug 'Shougo/echodoc.vim'
    let g:echodoc_enable_at_startup = 1
if IsVim()
    let g:echodoc#type = 'popup'
else
    let g:echodoc#type = 'floating'
endif
    nnoremap <leader>td :call Plug_ed_toggle()<CR>

    function! Plug_ed_toggle()
        if echodoc#is_enabled()
            call echodoc#disable()
        else
            call echodoc#enable()
        endif
        echo 'Echo doc: ' . string(echodoc#is_enabled())
    endfunction
" }}}

" ultisnips {{{ 代码片段
if s:gset.use_ultisnips
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'           " snippet合集
    " 删除UltiSnips#map_keys#MapKeys中的xnoremap <Tab>，和textmanip <C-i>冲突
    " 使用:UltiSnipsEdit编辑g:UltiSnipsSnippetsDir中的snippet文件
    let g:UltiSnipsEditSplit="vertical"
    let g:UltiSnipsSnippetDirectories=[$DotVimPath . '/vSnippets']
    let g:UltiSnipsExpandTrigger='<Tab>'
    let g:UltiSnipsListSnippets='<C-o>'
    let g:UltiSnipsJumpForwardTrigger='<C-j>'
    let g:UltiSnipsJumpBackwardTrigger='<C-k>'
endif
" }}}

" ale {{{ 语法检测
    Plug 'dense-analysis/ale', {'on': 'ALEToggle'}
    let g:ale_completion_enabled = 0    " 使能ale补全(只支持TypeScript)
    let g:ale_linters = {'java' : []}   " 禁用Java检测（与YCM冲突）
    let g:ale_sign_error = '✘'
    let g:ale_sign_warning = '►'
    let g:ale_set_loclist = 1
    let g:ale_set_quickfix = 0
    let g:ale_echo_delay = 10           " 显示语文错误的延时时间
    let g:ale_lint_delay = 300          " 文本更改后的延时检测时间
    let g:ale_enabled = 0               " 默认关闭ALE检测
    nnoremap <silent> <leader>ta
        \ :execute ':ALEToggle'<Bar>
        \ :echo 'AleToggle: ' . g:ale_enabled<CR>
" }}}

" neoformat {{{ 代码格式化
    Plug 'sbdchd/neoformat', {'on': 'Neoformat'}
    let g:neoformat_basic_format_align = 1
    let g:neoformat_basic_format_retab = 1
    let g:neoformat_basic_format_trim = 1
    let g:neoformat_c_astyle = {
        \ 'exe' : 'astyle',
        \ 'args' : ['--style=allman', '--pad-oper'],
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
    nnoremap <leader>cf :Neoformat<CR>
    vnoremap <leader>cf :Neoformat<CR>
" }}}

" surround {{{ 添加包围符
    Plug 'tpope/vim-surround'
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

" auto-pairs {{{ 自动括号
    Plug 'jiangmiao/auto-pairs'
    let g:AutoPairsShortcutToggle=''
    let g:AutoPairsShortcutFastWrap=''
    let g:AutoPairsShortcutJump=''
    let g:AutoPairsShortcutFastBackInsert=''
    nnoremap <leader>tp :call AutoPairsToggle()<CR>
"}}}

" tagbar {{{ 代码结构查看
    Plug 'majutsushi/tagbar', {'on': 'TagbarToggle'}
    let g:tagbar_width=30
    let g:tagbar_map_showproto=''       " 取消tagbar对<Space>的占用
    nnoremap <leader>tt :TagbarToggle<CR>
                                        " 可以 ctags -R 命令自行生成tags
" }}}

" nerdcommenter {{{ 批量注释
    Plug 'scrooloose/nerdcommenter'
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
    Plug 'skywind3000/asyncrun.vim'
    if IsWin()
        let g:asyncrun_encs = 'cp936'   " 即'gbk'编码
    endif
    let g:asyncrun_open = 8             " 自动打开quickfix window
    let g:asyncrun_save = 1             " 自动保存当前文件
    let g:asyncrun_local = 1            " 使用setlocal的efm
    nnoremap <silent> <leader><leader>r :call feedkeys(':AsyncRun ', 'n')<CR>
    vnoremap <leader><leader>r :AsyncRun
    nnoremap <silent> <leader>rr :call feedkeys(':AsyncRun ', 'n')<CR>
    vnoremap <leader>rr :AsyncRun
    nnoremap <leader>rk :AsyncStop<CR>
" }}}

" easydebugger {{{ NodeJS, Go, Python调试器(Vim only)
if IsVim()
    Plug 'jayli/vim-easydebugger', {'for': ['python', 'go']}
    " 启动关闭NodeJS/Python/Go调试
    nmap <F5>   <Plug>EasyDebuggerInspect
    nmap <S-F5> <Plug>EasyDebuggerExit
    " 暂停继续
    nmap <F6>   <Plug>EasyDebuggerContinue
    tmap <F6>   <Plug>EasyDebuggerContinue
    nmap <S-F6> <Plug>EasyDebuggerPause
    tmap <S-F6> <Plug>EasyDebuggerPause
    " 设置断点
    nmap <F9>   <Plug>EasyDebuggerSetBreakPoint
    " 单步：Step over, into, out
    nmap <F10>  <Plug>EasyDebuggerNext
    tmap <F10>  <Plug>EasyDebuggerNext
    nmap <F11>  <Plug>EasyDebuggerStepIn
    tmap <F11>  <Plug>EasyDebuggerStepIn
    nmap <S-F11>    <Plug>EasyDebuggerStepOut
    tmap <S-F11>    <Plug>EasyDebuggerStepOut
endif
" }}}

" quickhl {{{ 单词高亮
    Plug 't9md/vim-quickhl'
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
    Plug 'RRethy/vim-illuminate'
    let g:Illuminate_delay = 250
    let g:Illuminate_ftblacklist = ['nerdtree', 'tagbar']
    highlight link illuminatedWord MatchParen
    nnoremap <leader>tg :IlluminationToggle<CR>
" }}}

" colorizer {{{ 颜色预览
    Plug 'lilydjwg/colorizer', {'on': 'ColorToggle'}
    let g:colorizer_nomap = 1
    let g:colorizer_startup = 0
    nnoremap <leader>tc :ColorToggle<CR>
" }}}

" FastFold {{{ 更新折叠
    Plug 'Konfekt/FastFold'
    nmap <leader>zu <Plug>(FastFoldUpdate)
    let g:fastfold_savehook = 0         " 只允许手动更新folds
    "let g:fastfold_fold_command_suffixes =  ['x','X','a','A','o','O','c','C']
    "let g:fastfold_fold_movement_commands = [']z', '[z', 'zj', 'zk']
                                        " 允许指定的命令更新folds
" }}}

" cpp-enhanced-highlight {{{ c++语法高亮
    Plug 'octol/vim-cpp-enhanced-highlight', {'for': 'cpp'}
" }}}

" julia {{{ Julia支持
    Plug 'JuliaEditorSupport/julia-vim', {'for': 'julia'}
    let g:default_julia_version = 'devel'
    let g:latex_to_unicode_tab = 1      " 使用<Tab>输入unicode字符
    nnoremap <leader>tn :call LaTeXtoUnicode#Toggle()<CR>
" }}}
" }}}

" 软件工具 {{{
if s:gset.use_utils
" vimcdoc {{{ 中文帮助文档
    Plug 'yianwillis/vimcdoc', {'for': 'help'}
" }}}

" MarkDown {{{
    Plug 'gabrielelana/vim-markdown', {'for': 'markdown'}
    let g:markdown_include_jekyll_support = 0
    let g:markdown_enable_mappings = 0
    let g:markdown_enable_spell_checking = 0
    let g:markdown_enable_folding = 1   " 感觉MarkDown折叠引起卡顿时，关闭此项
    let g:markdown_enable_conceal = 1   " 在Vim中显示MarkDown预览

    Plug 'iamcco/markdown-preview.nvim', {'for': 'markdown', 'do': { -> mkdp#util#install()}}
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

" reStructruedText {{{
    Plug 'Rykka/riv.vim', {'for': 'rst'}
    Plug 'Rykka/InstantRst', {'for': 'rst'}
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
    Plug 'lervag/vimtex', {'for': 'tex'}
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
    " 添加YCM集成
    augroup PluginVimtex
        autocmd!
        autocmd VimEnter * call s:Plug_vt_setYcmTrigger()
    augroup END
    function! s:Plug_vt_setYcmTrigger()
        try
            let g:ycm_semantic_triggers.tex=g:vimtex#re#youcompleteme
        " E121:变量不存在
        catch /^Vim\%((\a\+)\)\=:E121/
        endtry
    endfunction
" }}}

" open-browser.vim {{{ 在线搜索
    Plug 'tyru/open-browser.vim'
    let g:openbrowser_default_search='baidu'
    nmap <leader>bs <Plug>(openbrowser-smart-search)
    vmap <leader>bs <Plug>(openbrowser-smart-search)
    nnoremap <silent> <leader>big :call feedkeys(':OpenBrowserSearch -google ', 'n')<CR>
    nnoremap <silent> <leader>bib :call feedkeys(':OpenBrowserSearch -baidu ', 'n')<CR>
    nnoremap <silent> <leader>bih :call feedkeys(':OpenBrowserSearch -github ', 'n')<CR>
    nnoremap <leader>bg  :call Plug_brw_search('google', 'n')<CR>
    vnoremap <leader>bg  :call Plug_brw_search('google', 'v')<CR>
    nnoremap <leader>bb  :call Plug_brw_search('baidu', 'n')<CR>
    vnoremap <leader>bb  :call Plug_brw_search('baidu', 'v')<CR>
    nnoremap <leader>bh  :call Plug_brw_search('github', 'n')<CR>
    vnoremap <leader>bh  :call Plug_brw_search('github', 'v')<CR>

    " 搜索引擎- google, baidu, github
    function! Plug_brw_search(engine, mode)
        if a:mode ==# 'n'
            call openbrowser#search(expand('<cword>'), a:engine)
        elseif a:mode ==# 'v'
            call openbrowser#search(GetSelected(), a:engine)
        endif
    endfunction
"}}}
endif
" }}}

call plug#end()
call s:plug.init()
" }}} End

" User Functions {{{
" libs {{{
" FUNCTION: GetSelected() {{{ 获取选区内容
function! GetSelected()
    let l:reg_var = getreg('0', 1)
    let l:reg_mode = getregtype('0')
    normal! gv"0y
    let l:word = getreg('0')
    call setreg('0', l:reg_var, l:reg_mode)
    return l:word
endfunction
" }}}

" FUNCTION: GetMultiFilesCompletion(arglead, cmdline, cursorpos) {{{ 多文件自动补全
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

" FUNCTION: GetFileList(pat, [sdir]) {{{ 获取文件列表
" @param pat: 文件匹配模式，如*.pro
" @param sdir: 查找起始目录，默认从当前文件所在目录向上查找到根目录
" @return 返回找到的文件列表
function! GetFileList(pat, ...)
    let l:dir      = a:0 >= 1 ? a:1 : expand('%:p:h')
    let l:dir_last = ''
    let l:pfile    = ''

    while l:dir !=# l:dir_last
        let l:wicSave = &wildignorecase
        set wildignorecase
        let l:pfile = glob(l:dir . '/' . a:pat)
        let &wildignorecase = l:wicSave

        if !empty(l:pfile)
            break
        endif

        let l:dir_last = l:dir
        let l:dir = fnamemodify(l:dir, ':p:h:h')
    endwhile

    return split(l:pfile, "\n")
endfunction
" }}}

" FUNCTION: GetFileContent(fp, pat, flg) {{{ 获取文件中特定的内容
" @param fp: 目录文件
" @param pat: 匹配模式，必须使用 \(\) 来提取字符串
" @param flg: 匹配所有还是第一个
" @return 返回匹配的内容列表
function! GetFileContent(fp, pat, flg)
    let l:content = []
    for l:line in readfile(a:fp)
        let l:result = matchlist(l:line, a:pat)
        if !empty(l:result)
            if a:flg ==# 'all'
                if !empty(l:result[1])
                    call add(l:content, l:result[1])
                endif
            elseif a:flg ==# 'first'
                return empty(l:result[1]) ? [] : [l:result[1]]
            endif
        endif
    endfor
    return l:content
endfunction
" }}}

" FUNCTION: GetContentRange(pats, pate) {{{ 获取特定的内容的范围
" @param pats: 起始行匹配模式，start为pats所在行
" @param pate: 结束行匹配模式，end为pate所在行
" @return 返回列表[start, end]
function! GetContentRange(pats, pate)
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

" FUNCTION: GetArgs(str) {{{ 解析字符串参数到列表中
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

" FUNCTION: GetInput(prompt, [text, completion, workdir]) {{{ 输入字符串
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

" FUNCTION: ExecInput(iargs, fn, [fargs...]) range {{{
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

" FUNCTION: SetExecLast(string) {{{ 设置execution
function! SetExecLast(string)
    let s:execution = a:string
endfunction
" }}}

" FUNCTION: ExecLast() {{{ 执行上一次的execution
function! ExecLast()
    if exists('s:execution') && !empty(s:execution)
        execute s:execution
        echo s:execution
    endif
endfunction
" }}}

" FUNCTION: ExecMacro(key) {{{ 执行宏
function! ExecMacro(key)
    let l:mstr = 'normal! @' . a:key
    execute l:mstr
    call SetExecLast(l:mstr)
endfunction
" }}}
" }}}

" project {{{
" Required: 'skywind3000/asyncrun.vim'
"           'yehuohan/popset'

" s:rp {{{
" @attribute type: 文件类型
" @attribute wdir, args, srcf, outf: 用于type的参数
" @attribute cell: 用于type的cell类型
" @attribute efm: 用于type的errorformat类型
" @attribute pro: 项目类型
" @attribute pat: 匹配模式字符串
" @attribute sel: 预置RunFile参数输入
let s:rp = {
    \ 'wdir' : '',
    \ 'args' : '',
    \ 'srcf' : '',
    \ 'outf' : '',
    \ 'type' : {
        \ 'c'          : [IsWin() ? 'gcc %s -o %s %s && %s' : 'gcc %s -o %s %s && ./%s',
                                                               \ 'args' , 'outf' , 'srcf' , 'outf' ],
        \ 'cpp'        : [IsWin() ? 'g++ -std=c++11 %s -o %s %s && %s' : 'g++ -std=c++11 %s -o %s %s && ./%s',
                                                               \ 'args' , 'outf' , 'srcf' , 'outf' ],
        \ 'java'       : ['javac %s && java %s %s'             , 'srcf' , 'outf' , 'args'          ],
        \ 'python'     : ['python %s %s'                       , 'srcf' , 'args'                   ],
        \ 'julia'      : ['julia %s %s'                        , 'srcf' , 'args'                   ],
        \ 'lua'        : ['lua %s %s'                          , 'srcf' , 'args'                   ],
        \ 'go'         : ['go run %s %s'                       , 'srcf' , 'args'                   ],
        \ 'javascript' : ['node %s %s'                         , 'srcf' , 'args'                   ],
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
        \ 'python' : ['python', '^#%%', '^#%%'],
        \ 'julia'  : ['julia', '^#%%', '^#%%'],
        \ 'lua'    : ['lua', '^--%%', '^--%%'],
        \ },
    \ 'efm' : {
        \ 'python' : '%*\\sFile\ \"%f\"\\,\ line\ %l\\,\ %m',
        \ },
    \ 'pro' : {
        \ 'qmake'  : ['*.pro', 'FnQMake'],
        \ 'cmake'  : ['cmakelists.txt', 'FnCMake'],
        \ 'make'   : ['makefile', 'FnMake'],
        \ 'vs'     : ['*.sln', 'FnVs'],
        \ 'sphinx' : [IsWin() ? 'make.bat' : 'makefile', 'FnSphinx'],
        \ },
    \ 'pat' : {
        \ 'target'  : '\mTARGET\s*:\?=\s*\(\<[a-zA-Z0-9_][a-zA-Z0-9_\-]*\)',
        \ 'project' : '\mproject(\(\<[a-zA-Z0-9_][a-zA-Z0-9_\-]*\)',
        \ },
    \ 'sel' : {
        \ 'opt' : 'select args to RunFile',
        \ 'lst' : [
                \ '-g',
                \ '-finput-charset=utf-8 -fexec-charset=gbk',
                \ '-static',
                \ '-fPIC -shared'
                \ ],
        \ 'cpl' : 'customlist,GetMultiFilesCompletion',
        \ 'cmd' : {sopt, arg -> call('RunFile', [substitute(arg, '|', ' ', 'ge')])},
        \ }
    \ }
" FUNCTION: s:rp.printf(type, args, srcf, outf) dict {{{
" 生成文件编译或执行命令字符串。
" @param type: 编译类型，需要包含于s:rp.type中
" @param wdir: 命令运行目录
" @param args: 参数
" @param srcf: 源文件
" @param outf: 目标文件
" @return 返回编译或执行命令
function! s:rp.printf(type, wdir, args, srcf, outf) dict
    if !has_key(s:rp.type, a:type)
        \ || ('sh' ==? a:type && !(IsLinux() || IsGw() || IsMac()))
        \ || ('dosbatch' ==? a:type && !IsWin())
        throw 's:rp.type doesn''t support "' . a:type . '"'
    endif
    let self.wdir = a:wdir
    let self.args = a:args
    let self.srcf = '"' . a:srcf . '"'
    let self.outf = '"' . a:outf . '"'
    let l:pstr = copy(self.type[a:type])
    call map(l:pstr, {key, val -> (key == 0) ? val : get(self, val, '')})
    " create exec string
    return self.run(a:type, self.wdir, call('printf', l:pstr))
endfunction
" }}}

" FUNCTION: s:rp.run(type, wdir, cmd) dict {{{
" 生成运行命令字符串。
" @param wdir: 命令运行目录
" @param type: errorformat类型，在s:rp.efm中
" @param cmd: 命令字符串
" @return 返回运行命令
function! s:rp.run(type, wdir, cmd) dict
    if has_key(s:rp.efm, a:type)
        execute 'setlocal efm=' . s:rp.efm[a:type]
    endif
    let l:exec = ':AsyncRun '
    if !empty(a:wdir)
        let l:wdir = fnameescape(a:wdir)
        let l:exec .= '-cwd=' . l:wdir
        execute 'lcd ' . l:wdir
    endif
    return join([l:exec, a:cmd])
endfunction
" }}}

" FUNCTION: s:rp.runcell(type) dict {{{
" @param type: cell类型，同时也是efm类型
function! s:rp.runcell(type) dict
    if !has_key(s:rp.cell, a:type)
        throw 's:rp.cell doesn''t support "' . a:type . '"'
    endif
    if has_key(s:rp.efm, a:type)
        execute 'setlocal efm=' . s:rp.efm[a:type]
    endif
    let [l:bin, l:pats, l:pate] = s:rp.cell[a:type]
    let l:range = GetContentRange(l:pats, l:pate)
    " create exec string
    return ':' . join(l:range, ',') . 'AsyncRun '. l:bin
endfunction
" }}}
" }}}

" FUNCTION: RunFile(...) {{{
function! RunFile(...)
    let l:type    = &filetype           " 文件类型
    let l:srcfile = expand('%:t')       " 文件名，不带路径，带扩展名
    let l:outfile = expand('%:t:r')     " 文件名，不带路径，不带扩展名
    let l:workdir = expand('%:p:h')     " 当前文件目录
    let l:argstr  = a:0 > 0 ? a:1 : ''
    try
        let l:exec = s:rp.printf(l:type, l:workdir, l:argstr, l:srcfile, l:outfile)
        execute l:exec
        call SetExecLast(l:exec)
    catch
        echo v:exception
    endtry
endfunction
" }}}

" FUNCTION: RunCell(argstr) {{{
function! RunCell()
    try
        let l:exec = s:rp.runcell(&filetype)
        execute l:exec
        echo l:exec
        call SetExecLast(l:exec)
    catch
        echo v:exception
    endtry
endfunction
" }}}

" FUNCTION: RunProject(type, args) {{{
" 当找到多个Project文件时，会弹出选项以供选择。
" @param type: 工程类型，用于获取工程运行回调函数
"   项目回调函数需要3个参数(可能用于popset插件)：
"   - sopt: 自定义参数信息
"   - sel: Project文件路径
"   - args: Project的附加参数列表
" @param args: 编译工程文件函数的附加参数，需要采用popset插件
function! RunProject(type, args)
    let [l:pat, l:fn] = s:rp.pro[a:type]
    let l:prj = GetFileList(l:pat)
    if len(l:prj) == 1
        let Fn = function(l:fn)
        call Fn('', l:prj[0], a:args)
    elseif len(l:prj) > 1
        call PopSelection({
            \ 'opt' : 'Please select the project file',
            \ 'lst' : l:prj,
            \ 'cmd' : a:fn,
            \ 'arg' : a:args
            \})
    else
        echo 'None of ' . l:pat . ' was found!'
    endif
endfunction
" }}}

" FUNCTION: FnQMake(sopt, sel, args) {{{
function! FnQMake(sopt, sel, args)
    let l:srcfile = fnamemodify(a:sel, ':p:t')
    let l:outfile = GetFileContent(a:sel, s:rp.pat.target, 'first')
    let l:outfile = empty(l:outfile) ? fnamemodify(a:sel, ':t:r') : l:outfile[0]
    let l:workdir = fnamemodify(a:sel, ':p:h')

    if IsWin()
        let l:cmd = printf('cd "%s" && qmake -r "%s" && vcvars64.bat && nmake -f Makefile.Debug %s',
                    \ l:workdir, l:srcfile, join(a:args[1]))
    else
        let l:cmd = printf('cd "%s" && qmake "%s" && make %s'
                    \ l:workdir, l:srcfile, join(a:args[1]))
    endif
    if a:args[0]
        let l:cmd .= ' && "./' . l:outfile .'"'
    endif
    execute s:rp.run('cpp', l:workdir, l:cmd)
endfunction
" }}}

" FUNCTION: FnCMake(sopt, sel, args) {{{
function! FnCMake(sopt, sel, args)
    let l:outfile = GetFileContent(a:sel, s:rp.pat.project, 'first')
    let l:outfile = empty(l:outfile) ? '' : l:outfile[0]
    let l:workdir = fnamemodify(a:sel, ':p:h')

    if a:args[0] == 0
        " clean
        call delete(l:workdir . '/CMakeBuildOut', 'rf')
    elseif a:args[0] >= 1
        "build
        silent! call mkdir('CMakeBuildOut')
        let l:cmd = printf('cd "%s" && cd CMakeBuildOut && cmake -G "Unix Makefiles" .. && make', l:workdir)
        if a:args[0] >= 2
            "run
            let l:cmd .= ' && "./' . l:outfile .'"'
        endif
        execute s:rp.run('', l:workdir, l:cmd)
    endif
endfunction
" }}}

" FUNCTION: FnMake(sopt, sel, args) {{{
function! FnMake(sopt, sel, args)
    let l:outfile = GetFileContent(a:sel, s:rp.pat.target, 'first')
    let l:outfile = empty(l:outfile) ? '' : l:outfile[0]
    let l:workdir = fnamemodify(a:sel, ':p:h')

    let l:cmd = printf('cd "%s" && make %s', l:workdir, join(a:args[1]))
    if a:args[0]
        let l:cmd .= ' && "./' . l:outfile .'"'
    endif
    execute s:rp.run('', l:workdir, l:cmd)
endfunction
"}}}

" FUNCTION: FnVs(sopt, sel, args) {{{
function! FnVs(sopt, sel, args)
    let l:srcfile = fnamemodify(a:sel, ':p:t')
    let l:outfile = fnamemodify(a:sel, ':p:t:r')
    let l:workdir = fnamemodify(a:sel, ':p:h')

    let l:cmd = printf('cd "%s" && vcvars64.bat && devenv "%s" /%s',
                    \ l:workdir, l:srcfile, join(a:args[1]))
    if a:args[0]
        let l:cmd .= ' && "./' . l:outfile .'"'
    endif
    execute s:rp.run('cpp', l:workdir, l:cmd)
endfunction
" }}}

" FUNCTION: FnSphinx(sopt, sel, args) {{{
" @param args[0]: 是否直接打开sphinx文档
function! FnSphinx(sopt, sel, args)
    let l:outfile = 'build/html/index.html'
    let l:workdir = fnamemodify(a:sel, ':p:h')

    let l:cmd = printf('cd "%s" && make %s', l:workdir, a:args[1])
    if a:args[0]
        let l:cmd .= join([' && firefox', l:outfile])
    endif
    execute s:rp.run('', l:workdir, l:cmd)
endfunction
"}}}

let RpArg         = function('popset#set#PopSelection', [s:rp.sel])
let RpQMake       = function('RunProject', ['qmake', [0, []]])
let RpQMakeRun    = function('RunProject', ['qmake', [1, []]])
let RpQMakeClean  = function('RunProject', ['qmake', [0, ['distclean']]])
let RpCMake       = function('RunProject', ['cmake', [1]])
let RpCMakeRun    = function('RunProject', ['cmake', [2]])
let RpCMakeClean  = function('RunProject', ['cmake', [0]])
let RpMake        = function('RunProject', ['make', [0, []]])
let RpMakeRun     = function('RunProject', ['make', [1, []]])
let RpMakeClean   = function('RunProject', ['make', [0, ['clean']]])
let RpVs          = function('RunProject', ['vs', [0, ['Build']]])
let RpVsRun       = function('RunProject', ['vs', [1, ['Build']]])
let RpVsClean     = function('RunProject', ['vs', [0, ['Clean']]])
let RpSphinx      = function('RunProject', ['sphinx', [0, 'html']])
let RpSphinxRun   = function('RunProject', ['sphinx', [1, 'html']])
let RpSphinxClean = function('RunProject', ['sphinx', [0, 'clean']])
" }}}

" find&search {{{
" Required: 'skywind3000/asyncrun.vim' or 'yegappan/grep' or 'mhinz/vim-grepper'
"           'Yggdroot/LeaderF', 'junegunn/fzf.vim'
"           'yehuohan/popc'
"           'yehuohan/popset'

" s:fw {{{
" @attribute engine: 搜索程序，命令格式为：printf('cmd %s %s %s',<pat>,<loc>,<opt>)
"            sr : search
"            sa : search append
"            sk : search kill
"            sl : search lines with fuzzy
"            ff : fuzzy files
"            fh : fuzzy huge lines-text
"            fg : fuzzy ctags
"            fc : fuzzy ctags with <cword>
" @attribute args: 搜索参数
" @attribute rg: 预置的rg搜索命令，用于搜索指定文本
" @attribute fuzzy: 预置的模糊搜索命令，用于文件和文本等模糊搜索
" @attribute misc: 搜索高亮等参数
" @attribute mappings: 映射按键
let s:fw = {
    \ 'cmd' : '',
    \ 'pat' : '',
    \ 'loc' : '',
    \ 'opt' : '',
    \ 'engine' : {
        \ 'rg'    : '',
        \ 'fuzzy' : '',
        \ 'sr'    : '',
        \ 'sa'    : '',
        \ 'sk'    : '',
        \ 'sl'    : ':Leaderf rg --nowrap -e "%s" "%s" %s',
        \ 'ff'    : '',
        \ 'fh'    : '',
        \ 'fg'    : '',
        \ 'fc'    : '',
        \ },
    \ 'args' : {
        \ 'root'    : '',
        \ 'filters' : '',
        \ 'globlst' : []
        \ },
    \ 'param' : {
        \ 'sel' : '',
        \ 'F' : {
            \ 'opt' : 'select search options',
            \ 'lst' : ['-F', '--hidden', '--no-ignore'],
            \ 'cmd' : {sopt, arg -> s:fw.setParam('opt', arg)}
            \ }
        \ },
    \ 'rg' : {
        \ 'asyncrun' : {
            \ 'sr' : ':botright copen | :AsyncRun! rg --vimgrep "%s" "%s" %s',
            \ 'sa' : ':botright copen | :AsyncRun! -append rg --vimgrep "%s" "%s" %s',
            \ 'sk' : ':AsyncStop'
            \ },
        \ 'grep' : {
            \ 'sr' : ':execute '':Rg '' . escape(''%s'', " ") . '' "%s" %s''',
            \ 'sa' : ':execute '':RgAdd '' . escape(''%s'', " ") . '' "%s" %s''',
            \ 'sk' : ':GrepStop'
            \ },
        \ 'grepper' : {
            \ 'sr' : ':Grepper -noprompt -tool rg -query "%s" "%s" %s',
            \ 'sa' : ':Grepper -noprompt -tool rg -append -query "%s" "%s" %s',
            \ 'sk' : ':Grepper -stop'
            \ },
        \ 'sel' : {
            \ 'opt' : 'select rg engine',
            \ 'lst' : ['asyncrun', 'grep', 'grepper'],
            \ 'cmd' : {sopt, arg -> s:fw.setEngine('rg', arg)},
            \ 'get' : {sopt -> s:fw.engine.rg}
            \ }
        \ },
    \ 'fuzzy' : {
        \ 'fzf' : {
            \ 'ff' : ':FzfFiles',
            \ 'fh' : ':FzfRg',
            \ 'fg' : ':FzfTags',
            \ 'fc' : ':execute "FzfTags " . expand("<cword>")'
            \ },
        \ 'leaderf' : {
            \ 'ff' : ':LeaderfFile',
            \ 'fh' : ':Leaderf rg --nowrap',
            \ 'fg' : ':Leaderf tag',
            \ 'fc' : ':Leaderf tag --cword'
            \ },
        \ 'sel' : {
            \ 'opt' : 'select fuzzy engine',
            \ 'lst' : ['fzf', 'leaderf'],
            \ 'cmd' : {sopt, arg -> s:fw.setEngine('fuzzy', arg)},
            \ 'get' : {sopt -> s:fw.engine.fuzzy}
        \ }
    \ },
    \ 'misc' : {
        \ 'markers' : ['.root', '.popc', '.git', '.svn'],
        \ 'strings' : [],
        \ },
    \ 'mappings' : []
    \ }
" s:fw.mappings {{{
let s:fw.mappings = [
                \  'fi',  'fbi',  'fti',  'foi',  'fpi',  'fri',  'fI',  'fbI',  'ftI',  'foI',  'fpI',  'frI',
                \  'fw',  'fbw',  'ftw',  'fow',  'fpw',  'frw',  'fW',  'fbW',  'ftW',  'foW',  'fpW',  'frW',
                \  'fs',  'fbs',  'fts',  'fos',  'fps',  'frs',  'fS',  'fbS',  'ftS',  'foS',  'fpS',  'frS',
                \  'f=',  'fb=',  'ft=',  'fo=',  'fp=',  'fr=',  'f=',  'fb=',  'ft=',  'fo=',  'fp=',  'fr=',
                \  'Fi',  'Fbi',  'Fti',  'Foi',  'Fpi',  'Fri',  'FI',  'FbI',  'FtI',  'FoI',  'FpI',  'FrI',
                \  'Fw',  'Fbw',  'Ftw',  'Fow',  'Fpw',  'Frw',  'FW',  'FbW',  'FtW',  'FoW',  'FpW',  'FrW',
                \  'Fs',  'Fbs',  'Fts',  'Fos',  'Fps',  'Frs',  'FS',  'FbS',  'FtS',  'FoS',  'FpS',  'FrS',
                \  'F=',  'Fb=',  'Ft=',  'Fo=',  'Fp=',  'Fr=',  'F=',  'Fb=',  'Ft=',  'Fo=',  'Fp=',  'Fr=',
                \ 'fli', 'flbi', 'flti', 'floi', 'flpi', 'flri', 'flI', 'flbI', 'fltI', 'floI', 'flpI', 'flrI',
                \ 'flw', 'flbw', 'fltw', 'flow', 'flpw', 'flrw', 'flW', 'flbW', 'fltW', 'floW', 'flpW', 'flrW',
                \ 'fls', 'flbs', 'flts', 'flos', 'flps', 'flrs', 'flS', 'flbS', 'fltS', 'floS', 'flpS', 'flrS',
                \ 'fl=', 'flb=', 'flt=', 'flo=', 'flp=', 'flr=', 'fl=', 'flb=', 'flt=', 'flo=', 'flp=', 'flr=',
                \ 'Fli', 'Flbi', 'Flti', 'Floi', 'Flpi', 'Flri', 'FlI', 'FlbI', 'FltI', 'FloI', 'FlpI', 'FlrI',
                \ 'Flw', 'Flbw', 'Fltw', 'Flow', 'Flpw', 'Flrw', 'FlW', 'FlbW', 'FltW', 'FloW', 'FlpW', 'FlrW',
                \ 'Fls', 'Flbs', 'Flts', 'Flos', 'Flps', 'Flrs', 'FlS', 'FlbS', 'FltS', 'FloS', 'FlpS', 'FlrS',
                \ 'Fl=', 'Flb=', 'Flt=', 'Flo=', 'Flp=', 'Flr=', 'Fl=', 'Flb=', 'Flt=', 'Flo=', 'Flp=', 'Flr=',
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
" }}}

" FUNCTION: s:fw.init() dict {{{
function! s:fw.init() dict
    " 设置搜索结果高亮
    augroup UserFunctionSearch
        autocmd!
        autocmd User Grepper call FindWowHighlight(s:fw.pat)
    augroup END
    " 设置搜索引擎
    call s:fw.setEngine('rg', IsVim() ? 'grep' : 'grepper')
    call s:fw.setEngine('fuzzy', 'leaderf')
endfunction
" }}}

" FUNCTION: s:fw.setEngine(type, engine) dict {{{
function! s:fw.setEngine(type, engine) dict
    let self.engine[a:type] = a:engine
    call extend(self.engine, self[a:type][a:engine], 'force')
endfunction
" }}}

" FUNCTION: s:fw.setParam(key, val) dict {{{
function! s:fw.setParam(key, val) dict
    if a:key == 'F'
        let l:self[a:key] .= a:val
    endif
    call self.exec()
endfunction
" }}}

" FUNCTION: s:fw.exec() dict {{{
function! s:fw.exec() dict
    if empty(self.param.sel)
        let l:exec = printf(self.cmd, escape(self.pat, '"-#%\'), self.loc, self.opt)
        execute l:exec
        call FindWowHighlight(self.pat)
        call SetExecLast(l:exec)
    else
        let l:sel = self.param.sel[0]
        let self.param.sel = self.param.sel[1:-1]
        call PopSelection(self.param[l:sel])
    endif
endfunction
" }}}

call s:fw.init()
" }}}

" FUNCTION: FindWow(keys, mode) {{{ 超速查找
function! FindWow(keys, mode)
    " doc
    " {{{
    " MapKeys: [fF][lav][btopr][IiWwSs=]
    "          [%1][%2 ][%3   ][4%     ]
    " Find: %1
    "   f : find working
    "   F : find working with inputing args
    " Command: %2
    "   '': find with rg by default
    "   l : find with rg in working root-filter and pass result to Leaderf
    "   a : find with rg append
    "   v : find with vimgrep
    " Location: %3
    "   b : find in current buffer(%)
    "   t : find in buffers of tab via popc
    "   o : find in buffers of all tabs via popc
    "   p : find with inputing path
    "   r : find with inputing working root and filter
    "  '' : find with s:fw.args
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
    " FUNCTION: s:parsePattern() closure {{{
    function! s:parsePattern() closure
        let l:pat = ''
        if a:mode ==# 'n'
            if a:keys =~? 'i'
                let l:pat = GetInput('What to find: ')
            elseif a:keys =~? '[ws]'
                let l:pat = expand('<cword>')
            endif
        elseif a:mode ==# 'v'
            let l:selected = GetSelected()
            if a:keys =~? 'i'
                let l:pat = GetInput('What to find: ', l:selected)
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
    " FUNCTION: s:parseLocation() closure {{{
    function! s:parseLocation() closure
        let l:loc = ''
        if a:keys =~# 'b'
            let l:loc = expand('%:p')
        elseif a:keys =~# 't'
            let l:loc = join(popc#layer#buf#GetFiles('sigtab'), '" "')
        elseif a:keys =~# 'o'
            let l:loc = join(popc#layer#buf#GetFiles('alltab'), '" "')
        elseif a:keys =~# 'p'
            let l:loc = GetInput('Where to find: ', '', 'customlist,GetMultiFilesCompletion', expand('%:p:h'))
            if !empty(l:loc)
                let l:loc = split(l:loc, '|')
                call map(l:loc, {key, val -> (val =~# '[/\\]$') ? strcharpart(val, 0, strchars(val) - 1) : val})
                let l:loc = join(l:loc, '" "') " for \"l:loc\"
            endif
        elseif a:keys =~# 'r'
            let l:loc = FindWowSetArgs('rf') ? s:fw.args.root : ''
        else
            if empty(s:fw.args.root)
                call FindWowRoot()
            endif
            if empty(s:fw.args.root)
                call FindWowSetArgs('r')
            endif
            let l:loc = s:fw.args.root
        endif
        return l:loc
    endfunction
    " }}}
    " FUNCTION: s:parseOptions() closure {{{
    function! s:parseOptions() closure
        let l:opt = ''
        if a:keys =~? 's'     | let l:opt .= '-w ' | endif
        if a:keys =~# '[iws]' | let l:opt .= '-i ' | elseif a:keys =~# '[IWS]' | let l:opt .= '-s ' | endif
        if a:keys !~# '[btop]'
            if !empty(s:fw.args.filters)
                let l:opt .= '-g "*.{' . s:fw.args.filters . '}" '
            endif
            if !empty(s:fw.args.globlst)
                let l:opt .= '-g ' . join(s:fw.args.globlst, ' -g ')
            endif
        endif
        if a:keys =~# 'F'
            let s:fw.param.sel .= 'F'
        endif
        return l:opt
    endfunction
    " }}}
    " FUNCTION: s:parseCommand() closure {{{
    function! s:parseCommand() closure
        if a:keys =~# 'l'
            let l:cmd = s:fw.engine.sl
        elseif a:keys =~# 'a'
            let l:cmd = s:fw.engine.sa
        else
            let l:cmd = s:fw.engine.sr
            let s:fw.misc.strings = []
        endif
        return l:cmd
    endfunction
    " }}}
    " FUNCTION: s:parseVimgrep() closure {{{
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
            let l:loc = GetInput('Where to find: ', '', 'customlist,GetMultiFilesCompletion', expand('%:p:h'))
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

    call s:fw.exec()
endfunction
" }}}

" FUNCTION: FindWowKill() {{{ 停止超速查找
function! FindWowKill()
    execute s:fw.engine.sk
endfunction
" }}}

" FUNCTION: FindWowFuzzy(keys, r) {{{ 模糊搜索
" @param r: 是否设置搜索目录s:fw.args.root
function! FindWowFuzzy(keys, r)
    if !a:r && empty(s:fw.args.root)
        call FindWowRoot()
    endif
    if a:r || empty(s:fw.args.root)
        call FindWowSetArgs('r')
    endif
    if !empty(s:fw.args.root)
        execute 'lcd ' . s:fw.args.root
        execute s:fw.engine[a:keys]
    endif
endfunction
" }}}

" FUNCTION: FindWowSetEngine(type) {{{ 设置engine
function! FindWowSetEngine(type)
    if a:type ==# 'engine'
        call PopSelection({
            \ 'opt' : 'select the engine',
            \ 'lst' : ['rg', 'fuzzy'],
            \ 'sub' : {
                \ 'rg'    : s:fw.rg.sel,
                \ 'fuzzy' : s:fw.fuzzy.sel},
            \ 'cmd' : 'popset#set#SubPopSelection'
            \ })
    else
        call PopSelection(s:fw[a:type]['sel'])
    endif
endfunction
" }}}

" FUNCTION: FindWowRoot() {{{ 查找root路径
function! FindWowRoot()
    if empty(s:fw.misc.markers)
        return
    endif

    let l:dir = expand('%:p:h')
    let l:dir_last = ''
    while l:dir !=# l:dir_last
        let l:dir_last = l:dir
        for m in s:fw.misc.markers
            let l:root = l:dir . '/' . m
            if filereadable(l:root) || isdirectory(l:root)
                let s:fw.args.root = fnameescape(l:dir)
                return
            endif
        endfor
        let l:dir = fnamemodify(l:dir, ':p:h:h')
    endwhile
endfunction
" }}}

" FUNCTION: FindWowSetArgs() {{{ 设置args
" @param type: r-root, f-filters, g-glob
" @return 0表示异常结束函数（root无效），1表示正常结束函数
function! FindWowSetArgs(type)
    if a:type =~# 'r'
        let l:root = GetInput('Root: ', '', 'dir', expand('%:p:h'))
        if empty(l:root)
            return 0
        endif
        let l:root = fnamemodify(l:root, ':p')
        if l:root =~# '[/\\]$'
            let l:root = strcharpart(l:root, 0, strchars(l:root) - 1)
        endif
        let s:fw.args.root = l:root
    endif
    if a:type =~# 'f'
        let s:fw.args.filters = GetInput('Filter: ')
    endif
    if a:type =~# 'g'
        let s:fw.args.globlst = split(GetInput('Glob: '))
    endif
    return 1
endfunction
" }}}

" FUNCTION: FindWowGetArgs() {{{ 获取args
function! FindWowGetArgs()
    if empty(s:fw.args.root)
        return []
    endif
    return [s:fw.args.root, s:fw.args.filters, s:fw.args.globlst]
endfunction
" }}}

" FUNCTION: FindWowHighlight([string]) {{{ 高亮字符串
" @param string: 若有字符串，则先添加到s:fw.misc.strings，再高亮
function! FindWowHighlight(...)
    if &filetype ==# 'leaderf'
        " use leaderf's highlight
    elseif &filetype ==# 'qf'
        if a:0 >= 1
            call add(s:fw.misc.strings, escape(a:1, '/*'))
        endif
        for str in s:fw.misc.strings
            execute 'syntax match IncSearch /' . str . '/'
        endfor
    endif
endfunction
" }}}
" }}}

" scripts {{{
" s:rs {{{
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
                    \ 'lineToTop',
                    \ 'clearUndo',
                    \ ],
            \ 'dic' : {
                    \ 'retab'                  : 'retab with expandtab',
                    \ '%s/\s\+$//ge'           : 'remove trailing space',
                    \ '%s/\r//ge'              : 'remove ^M',
                    \ 'edit ++enc=utf-8'       : 'reload as utf-8',
                    \ 'edit ++enc=cp936'       : 'reload as cp936',
                    \ 'lineToTop'              : 'frozen current line to top',
                    \ 'clearUndo'              : 'clear undo history',
                    \ },
            \ 'cmd' : {sopt, arg -> has_key(s:rs.funcs, arg) ? s:rs.funcs[arg]() : execute(arg)},
        \ },
        \ 'async' : {
            \ 'opt' : 'select execution to run',
            \ 'lst' : [
                    \ 'python -m json.tool %',
                    \ 'python setup.py build',
                    \ 'go mod init %:r',
                    \ 'cflow -T %',
                    \ 'createCtags',
                    \ ],
            \ 'cmd' : {sopt, arg -> has_key(s:rs.funcs, arg) ? s:rs.funcs[arg]() : execute(':AsyncRun ' . arg)},
            \ },
        \ },
    \ 'funcs' : {}
    \ }
" FUNCTION: s:rs.funcs.clearUndo() dict {{{ 清除undo数据
function! s:rs.funcs.clearUndo() dict
    let l:ulbak = &undolevels
    set undolevels=-1
    execute "normal! a\<Bar>\<BS>\<Esc>"
    let &undolevels = l:ulbak
endfunction
" }}}

" FUNCTION: s:rs.funcs.lineToTop() dict {{{ 冻结顶行
function! s:rs.funcs.lineToTop() dict
    let l:line = line('.')
    split %
    resize 1
    call cursor(l:line, 1)
    wincmd p
endfunction
" }}}

" FUNCTION: s:rs.funcs.createCtags() dict {{{ 生成tags
function! s:rs.funcs.createCtags() dict
    let l:fw = FindWowGetArgs()
    if !empty(l:fw)
        execute(':AsyncRun cd '. l:fw[0] . ' && ctags -R')
    else
        echo 'No root in s:fw'
    endif
endfunction
" }}}
" }}}

function! RunScript(type)
    call PopSelection(s:rs.sel[a:type])
endfunction
" }}}

" output {{{
" FUNCTION: QuickfixBasic(kyes) {{{ 基本操作
function! QuickfixBasic(keys)
    let l:type = a:keys[0]
    let l:oprt = a:keys[1]
    if l:oprt == 'o'
        execute 'botright ' . l:type . 'open'
        call FindWowHighlight()
    elseif l:oprt == 'c'
        if &filetype==#'qf'
            wincmd p
        endif
        execute l:type . 'close'
    elseif l:oprt == 'j'
        execute l:type . 'next'
        silent! normal! zO
        normal! zz
    elseif l:oprt == 'k'
        execute l:type . 'previous'
        silent! normal! zO
        normal! zz
    endif
endfunction
" }}}

" FUNCTION: QuickfixGet() {{{ 类型与编号
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

" FUNCTION: QuickfixPreview() {{{ 预览
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

" FUNCTION: QuickfixTabEdit() {{{ 新建Tab打开窗口
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

" FUNCTION: QuickfixMakeIconv() {{{ 编码转换
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

" FUNCTION: QuickfixIconv() {{{ 编码转换
function! QuickfixIconv()
    let l:type = QuickfixGet()[0]
    if empty(l:type)
        return
    endif
    call PopSelection({
        \ 'opt' : 'Select encoding',
        \ 'lst' : ['"cp936", "utf-8"', '"utf-8", "cp936"'],
        \ 'cmd' : 'QuickfixMakeIconv',
        \ 'arg' : [l:type,]
        \ })
endfunction
" }}}
" }}}

" option {{{
" Required: 'yehuohan/popset'

" s:opt {{{
let s:opt = {
    \ 'lst' : {
        \ 'conceallevel' : [2, 0],
        \ 'foldcolumn'   : [1, 0],
        \ 'virtualedit'  : ['all', ''],
        \ 'signcolumn'   : ['no', 'auto'],
        \ },
    \ 'func' : {
        \ 'number' : 'OptFuncNumber',
        \ 'syntax' : 'OptFuncSyntax',
        \ },
    \ }
" }}}

" FUNCTION: OptionInv(opt) {{{ 切换参数值（bool取反）
function! OptionInv(opt)
    execute printf('set inv%s', a:opt)
    execute printf('echo "%s = " . &%s', a:opt, a:opt)
endfunction
" }}}

" FUNCTION: OptionLst(opt) {{{ 切换参数值（列表循环取值）
function! OptionLst(opt)
    let l:lst = s:opt.lst[a:opt]
    let l:idx = index(l:lst, eval('&' . a:opt))
    let l:idx = (l:idx + 1) % len(l:lst)
    execute printf('set %s=%s', a:opt, l:lst[l:idx])
    execute printf('echo "%s = " . &%s', a:opt, a:opt)
endfunction
" }}}

" FUNCTION: OptionFunc(opt) {{{ 切换参数值（函数取值）
function! OptionFunc(opt)
    let Fn = function(s:opt.func[a:opt])
    call Fn()
endfunction
" }}}

" FUNCTION: OptFuncNumber() {{{ 切换显示行号
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

" FUNCTION: OptFuncSyntax() {{{ 切换高亮
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

" funcs {{{
" FUNCTION: FuncEditTempFile(suffix, ntab) {{{ 编辑临时文件
" @param suffix: 临时文件附加后缀
" @param ntab: 在新tab中打开
function! FuncEditTempFile(suffix, ntab)
    let l:tempfile = fnamemodify(tempname(), ':r')
    if empty(a:suffix)
        let l:tempfile .= '.tmp'
    else
        let l:tempfile .= '.' . a:suffix
    endif
    if a:ntab
        execute 'tabedit ' . l:tempfile
    else
        execute 'edit ' . l:tempfile
    endif
endfunction
"}}}

" FUNCTION: FuncDiffFile(filename, mode) {{{ 文件对比
function! FuncDiffFile(filename, mode)
    if a:mode ==# 's'
        execute 'diffsplit ' . a:filename
    elseif a:mode ==# 'v'
        execute 'vertical diffsplit ' . a:filename
    endif
endfunction
" }}}

" FUNCTION: FuncDivideSpace(string, pos) range {{{ 添加分隔符
function! FuncDivideSpace(string, pos) range
    let l:chars = split(a:string)

    for k in range(a:firstline, a:lastline)
        let l:line = getline(k)
        let l:fie = ' '
        for ch in l:chars
            let l:pch = '\m\s*\M' . escape(ch, '\') . '\m\s*\C'
            if a:pos == 'h'
                let l:sch = l:fie . escape(ch, '&\')
            elseif a:pos == 'c'
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
    call SetExecLast('call FuncDivideSpace(''' . a:string . ''', ''' . a:pos . ''')')
endfunction
let FuncDivideSpaceH = function('ExecInput', [['Divide H: '], 'FuncDivideSpace', 'h'])
let FuncDivideSpaceC = function('ExecInput', [['Divide C: '], 'FuncDivideSpace', 'c'])
let FuncDivideSpaceL = function('ExecInput', [['Divide L: '], 'FuncDivideSpace', 'l'])
let FuncDivideSpaceD = function('ExecInput', [['Delete D: '], 'FuncDivideSpace', 'd'])
" }}}

" FUNCTION: FuncAppendCmd(str, flg) {{{ 将命令结果作为文本插入
function! FuncAppendCmd(str, flg)
    if a:flg ==# 'call'
        let l:as = match(a:str, '(')
        let l:ae = -1   " match(a:str, ')') - 1
        let l:str = a:str[0 : l:as - 1]
        let l:args = GetArgs(a:str[l:as + 1 : l:ae - 1])
        let l:result = call(l:str, l:args)
        if type(l:result) != v:t_string
            let l:result = string(l:result)
        endif
    elseif a:flg ==# 'exec'
        let l:result = execute(a:str)
    endif
    call append(line('.'), split(l:result, "\n"))
endfunction
let FuncAppendCmdExec = function('ExecInput', [['Command: ', '', 'command'] , 'FuncAppendCmd', 'exec'])
let FuncAppendCmdCall = function('ExecInput', [['Function: ', '', 'function'], 'FuncAppendCmd', 'call'])
" }}}

" FUNCTION: FuncSwitchFile() {{{ 切换文件
let s:sf = [
    \ {'lhs': ['c', 'cc', 'cpp', 'cxx'],
    \  'rhs': ['h', 'hh', 'hpp', 'hxx']},
    \ ]
function! FuncSwitchFile()
    let l:ext = expand('%:e')
    let l:file = expand('%:p:r')
    let l:try = []
    for k in range(len(s:sf))
        if index(s:sf[k].lhs, l:ext, 0, 1) >= 0
            let l:try = s:sf[0].rhs
            break
        elseif index(s:sf[k].rhs, l:ext, 0, 1) >= 0
            let l:try = s:sf[0].lhs
            break
        endif
    endfor
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
" }}}

" FUNCTION: FuncGotoKeyword(mode) {{{ 查找Vim关键字
function! FuncGotoKeyword(mode)
    let l:exec = 'help '
    if a:mode ==# 'n'
        let l:word = expand('<cword>')
    elseif a:mode ==# 'v'
        let l:word = GetSelected()
    endif

    " 添加关键字
    let l:exec .= l:word
    if IsNVim()
        " nvim用自己的帮助文件，只有英文的
        let l:exec .= '@en'
    endif

    execute l:exec
endfunction
" }}}

" FUNCTION: FuncFcitx2en() FuncFcitx2zh() {{{ 切换Fcitx输入法
if IsLinux()
function! FuncFcitx2en()
    if 2 == system('fcitx-remote')
        let l:t = system('fcitx-remote -c')
    endif
endfunction
function! FuncFcitx2zh()
    if 1 == system('fcitx-remote')
        let l:t = system('fcitx-remote -o')
    endif
endfunction
endif
" }}}
" }}}
" }}} End

" User Settings {{{
" basic {{{
    syntax on                           " 语法高亮
    filetype plugin indent on           " 打开文件类型检测
    set number                          " 显示行号
    set relativenumber                  " 显示相对行号
    set cursorline                      " 高亮当前行
    set cursorcolumn                    " 高亮当前列
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
    set noimdisable                     " 切换Normal模式时，自动换成英文输入法
    set noerrorbells                    " 关闭错误信息响铃
    set visualbell t_vb=                " 关闭响铃(vb, visualbell)和可视闪铃(t_vb，即闪屏)，即normal模式时按esc会有响铃
    set belloff=all                     " 关闭所有事件的响铃
    set helplang=cn,en                  " 优先查找中文帮助
if IsVim()
    set renderoptions=                  " 设置正常显示unicode字符
    if &term == 'xterm' || &term == 'xterm-256color'
        " 终端光标设置，适用于urxvt,st,xterm,gnome-termial
        " 5,6: 竖线，  3,4: 横线，  1,2: 方块
        let &t_SI = "\<Esc>[6 q"        " 进入Insert模式
        let &t_EI = "\<Esc>[2 q"        " 退出Insert模式
    endif
endif
" }}}

" gui {{{
let s:gui_fontsize = 12

" Gui-vim {{{
if IsGVim()
" FUNCTION: GuiAdjustFontSize(inc) {{{
function! GuiAdjustFontSize(inc)
    let s:gui_fontsize += a:inc
    if IsLinux()
        execute 'set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ ' . s:gui_fontsize
        execute 'set guifontwide=WenQuanYi\ Micro\ Hei\ Mono\ ' . s:gui_fontsize
    elseif IsWin()
        execute 'set guifont=Consolas_For_Powerline:h' . s:gui_fontsize . ':cANSI'
        execute 'set guifontwide=Microsoft_YaHei_Mono:h' . (s:gui_fontsize - 1). ':cGB2312'
    elseif IsMac()
        execute 'set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h' . s:gui_fontsize
    endif
endfunction
" }}}

    set guioptions-=m                   " 隐藏菜单栏
    set guioptions-=T                   " 隐藏工具栏
    set guioptions-=L                   " 隐藏左侧滚动条
    set guioptions-=r                   " 隐藏右侧滚动条
    set guioptions-=b                   " 隐藏底部滚动条
    set guioptions-=e                   " 不使用GUI标签
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

" FUNCTION: GuiAdjustFontSize(inc) {{{
function! GuiAdjustFontSize(inc)
    let s:gui_fontsize += a:inc
    if IsLinux()
        execute 'Guifont! WenQuanYi Micro Hei Mono:h' . s:gui_fontsize
        execute 'Guifont! DejaVu Sans Mono for Powerline:h' . s:gui_fontsize
    elseif IsWin()
        "Guifont! YaHei Mono For Powerline:h12
        "Guifont! Microsoft YaHei Mono:h12
        execute 'Guifont! Consolas For Powerline:h' . s:gui_fontsize
    endif
endfunction
" }}}

" FUNCTION: s:NVimQt_setGui() {{{
function! s:NVimQt_setGui()
if IsNVimQt()
    call GuiAdjustFontSize(0)
    GuiLinespace 0
    GuiTabline 0
    GuiPopupmenu 0
    " 基于Qt-Gui的设置
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

" auto command {{{
augroup UserSettingsCmd
    "autocmd[!]  [group]  {event}     {pattern}  {nested}  {cmd}
    "autocmd              BufNewFile  *                    set fileformat=unix
    autocmd!

    autocmd BufNewFile *                set fileformat=unix
    autocmd BufRead,BufNewFile *.tex    set filetype=tex
    autocmd BufRead,BufNewFile *.tikz   set filetype=tex
    autocmd BufRead,BufNewFile *.gv     set filetype=dot

    autocmd Filetype vim        setlocal foldmethod=marker
    autocmd Filetype c          setlocal foldmethod=syntax
    autocmd Filetype cpp        setlocal foldmethod=syntax
    autocmd Filetype python     setlocal foldmethod=indent
    autocmd FileType go         setlocal expandtab
    autocmd FileType javascript setlocal foldmethod=syntax

    autocmd Filetype vim,help nnoremap <buffer> <S-k> :call FuncGotoKeyword('n')<CR>
    autocmd Filetype vim,help vnoremap <buffer> <S-k> :call FuncGotoKeyword('v')<CR>
augroup END
" }}}
" }}} End

" User Mappings {{{
" basic {{{
    " 重复上次操作命令
    nnoremap <leader>. :call ExecLast()<CR>
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
    nnoremap <leader>if :call OptionLst('foldcolumn')<CR>
    nnoremap <leader>is :call OptionLst('signcolumn')<CR>
    nnoremap <leader>in :call OptionFunc('number')<CR>
    nnoremap <leader>ih :call OptionFunc('syntax')<CR>
if IsLinux()
    inoremap <Esc> <Esc>:call FuncFcitx2en()<CR>
endif
" }}}

" copy&paste {{{
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
        execute "vnoremap <leader>'" . t          . ' "' . t . 'y'
        execute "nnoremap <leader>'" . t          . ' "' . t . 'p'
        execute "nnoremap <leader>'" . toupper(t) . ' "' . t . 'P'
        " 快速执行宏
        execute "nnoremap <leader>2" . t . ' :call ExecMacro("' . t . '")<CR>'
    endfor
" }}}

" tabs, buffers, quickfix, windows {{{
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
    nnoremap <leader>qk :call QuickfixBasic('ck')<CR>
    " 打开/关闭location-list
    nnoremap <leader>lo :call QuickfixBasic('lo')<CR>
    nnoremap <leader>lc :call QuickfixBasic('lc')<CR>
    nnoremap <leader>lj :call QuickfixBasic('lj')<CR>
    nnoremap <leader>lk :call QuickfixBasic('lk')<CR>
    " 预览quickfix和location-list
    nnoremap <M-Space> :call QuickfixPreview()<CR>
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
    nnoremap <M-s> <C-w>h
    nnoremap <M-d> <C-w>j
    nnoremap <M-e> <C-w>k
    nnoremap <M-f> <C-w>l
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
    nnoremap <M-Up> :resize+5<CR>
    nnoremap <M-Down> :resize-5<CR>
    nnoremap <M-Left> :vertical resize-5<CR>
    nnoremap <M-Right> :vertical resize+5<CR>
" }}}

" file diff {{{
    " 文件比较，自动补全文件和目录
    nnoremap <silent> <leader>ds
        \ :call ExecInput(['File: ', '', 'file', expand('%:p:h')], 'FuncDiffFile', 's')<CR>
    nnoremap <silent> <leader>dv
        \ :call ExecInput(['File: ', '', 'file', expand('%:p:h')], 'FuncDiffFile', 'v')<CR>
    " 比较当前文件（已经分屏）
    nnoremap <leader>dt :diffthis<CR>
    " 关闭文件比较，与diffthis互为逆命令
    nnoremap <leader>do :diffoff<CR>
    " 更新比较结果
    nnoremap <leader>du :diffupdate<CR>
    " 应用差异到别一文件，[range]<leader>dp，range默认为1行
    nnoremap <leader>dp
        \ :<C-U>execute '.,+' . string(v:count1-1) . 'diffput'<CR>
    " 拉取差异到当前文件，[range]<leader>dg，range默认为1行
    nnoremap <leader>dg
        \ :<C-U>execute '.,+' . string(v:count1-1) . 'diffget'<CR>
    " 下一个diff
    nnoremap <leader>dj ]c
    " 前一个diff
    nnoremap <leader>dk [c
" }}}

" terminal {{{
if IsWin()
    nnoremap <leader>tz :terminal<CR>
else
    nnoremap <leader>tz :terminal zsh<CR>
endif
if IsVim()
    set termwinkey=<C-l>
    tnoremap <Esc> <C-l>N
else
    tnoremap <C-l> <C-\><C-n><C-w>
    tnoremap <Esc> <C-\><C-n>
endif
" }}}

" project {{{
    " 创建临时文件
    nnoremap <silent> <leader>ei
        \ :call ExecInput(['Suffix: '], 'FuncEditTempFile', 0)<CR>
    nnoremap <silent> <leader>eti
        \ :call ExecInput(['Suffix: '], 'FuncEditTempFile', 1)<CR>
    for [key, val] in items({
            \ 'n' : '',
            \ 'c' : 'c',
            \ 'a' : 'cpp',
            \ 'p' : 'py',
            \ 'g' : 'go',
            \})
        execute 'nnoremap <silent> <leader>e'  . key . ' :call FuncEditTempFile("' . val . '", 0)<CR>'
        execute 'nnoremap <silent> <leader>et' . key . ' :call FuncEditTempFile("' . val . '", 1)<CR>'
    endfor
    " 常用操作
    nnoremap <leader>dh :call FuncDivideSpaceH()<CR>
    nnoremap <leader>dc :call FuncDivideSpaceC()<CR>
    nnoremap <leader>dl :call FuncDivideSpaceL()<CR>
    nnoremap <leader>dd :call FuncDivideSpaceD()<CR>
    nnoremap <leader>ae :call FuncAppendCmdExec()<CR>
    nnoremap <leader>af :call FuncAppendCmdCall()<CR>
    nnoremap <leader>sf :call FuncSwitchFile()<CR>
    nnoremap <leader>se :call RunScript('exe')<CR>
    nnoremap <leader>sa :call RunScript('async')<CR>
    " 编译运行当前文件或项目
    nnoremap <leader>rf  :call RunFile()<CR>
    nnoremap <leader>rj  :call RunCell()<CR>
    nnoremap <leader>ra  :call RpArg()<CR>
    nnoremap <leader>rQ  :call RpQMake()<CR>
    nnoremap <leader>rq  :call RpQMakeRun()<CR>
    nnoremap <leader>rcq :call RpQMakeClean()<CR>
    nnoremap <leader>rG  :call RpCMake()<CR>
    nnoremap <leader>rg  :call RpCMakeRun()<CR>
    nnoremap <leader>rcg :call RpCMakeClean()<CR>
    nnoremap <leader>rM  :call RpMake()<CR>
    nnoremap <leader>rm  :call RpMakeRun()<CR>
    nnoremap <leader>rcm :call RpMakeClean()<CR>
    nnoremap <leader>rV  :call RpVs()<CR>
    nnoremap <leader>rv  :call RpVsRun()<CR>
    nnoremap <leader>rcv :call RpVsClean()<CR>
    nnoremap <leader>rh  :call RpSphinx()<CR>
    nnoremap <leader>rH  :call RpSphinxRun()<CR>
    nnoremap <leader>rch :call RpSphinxClean()<CR>
    " 调试
if IsVim()
    packadd termdebug
endif
" }}}

" find&search {{{
    " /?
    nnoremap <leader><Esc> :nohlsearch<CR>
    nnoremap i :nohlsearch<CR>i
    " *,#使用\< \>，而g*,g# 不使用\< \>
    nnoremap <leader>8  *
    nnoremap <leader>3  #
    nnoremap <leader>g8 g*
    nnoremap <leader>g3 g#
    vnoremap <silent> /
        \ ""y<Bar>:execute '/\c' . @"<CR>
    nnoremap <silent> <leader>/
        \ :execute '/\c' . expand('<cword>')<CR>
    " FindWow
    for key in s:fw.mappings
        execute 'nnoremap <leader>' . key ':call FindWow("' . key . '", "n")<CR>'
    endfor
    for key in s:fw.mappings
        execute 'vnoremap <leader>' . key ':call FindWow("' . key . '", "v")<CR>'
    endfor
    nnoremap <leader>fk :call FindWowKill()<CR>
    nnoremap <leader>ff :call FindWowFuzzy('ff', 0)<CR>
    nnoremap <leader>fh :call FindWowFuzzy('fh', 0)<CR>
    nnoremap <leader>fg :call FindWowFuzzy('fg', 0)<CR>
    nnoremap <leader>fc :call FindWowFuzzy('fc', 0)<CR>
    nnoremap <leader>frf :call FindWowFuzzy('ff', 1)<CR>
    nnoremap <leader>frh :call FindWowFuzzy('fh', 1)<CR>
    nnoremap <leader>frg :call FindWowFuzzy('fg', 1)<CR>
    nnoremap <leader>frc :call FindWowFuzzy('fc', 1)<CR>
    nnoremap <leader>fee :call FindWowSetEngine('engine')<CR>
    nnoremap <leader>fes :call FindWowSetEngine('rg')<CR>
    nnoremap <leader>fez :call FindWowSetEngine('fuzzy')<CR>
    nnoremap <leader>fet :call FindWowRoot()<CR>
    nnoremap <leader>fea :call FindWowSetArgs('rfg')<CR>
    nnoremap <leader>fer :call FindWowSetArgs('r')<CR>
    nnoremap <leader>fef :call FindWowSetArgs('f')<CR>
    nnoremap <leader>feg :call FindWowSetArgs('g')<CR>
" }}}
" }}} End
