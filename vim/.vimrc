
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Vimrc: configuration for vim, gvim, neovim and neovim-qt. set the path of
"        'Global settings' before using this vimrc.
" Github: https://github.com/yehuohan/dotconfigs
" Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

"===============================================================================
" My Notes
"===============================================================================
" {{{
" Help {{{
    " :help       = 查看Vim帮助
    " :help index = 查看帮助列表
    " <S-k>       = 快速查看光标所在cword或选择内容的vim帮助
    " :help *@en  = 指定查看英文(en，cn即为中文)帮助
" }}}

" Map {{{
    " - Normal模式下使用<leader>代替<C-?>,<S-?>,<A-?>，
    " - Insert模式下map带ctrl,alt的快捷键
    " - 尽量不改变vim原有键位的功能定义
    " - 尽量一只手不同时按两个键，且连续按键相隔尽量近
    " - 尽量不映射偏远的按键（F1~F12，数字键等），且集中于'j,k,i,o'键位附近
    " - 调换Esc和CapsLock键
"  }}}

" Substitute {{{
"   :%s     - 所有行
"   :'<,'>s - 所选范圈
"   :n,$s   - 第n行到最一行
"   :.,ns   - 当前行到第n行
"   :.,+30s - 从当前行开始的30行
"   :'s,'es - 从ms标记到me标记的范围
"   :s//g   - 替换一行中所有找到的字符串
"   :s//c   - 替换前要确认
"
"   :s/ar\[i\]/\*(ar+i)/
"       ar[i] 替换成 *(ar+)，注意：对于 * . / \ [ ] 需要转义
"   :s/"\([A-J]\)"/"Group \1"/
"       将"X" 替换成 "Group X"，其中X可为A-J， \( \) 表示后面用 \1 引用 () 的内容
"   :s/"\(.*\)"/set("\1")/
"       将“*" 替换成 set("*") ，其中 .* 为任意字符
"   :s/text/\rtext/
"       \r相当于一个回车的效果
"   :s/text\n/text/
"       查找内容为text，且其后是回车
"   :s/\s\+$//g
"       去除尾部空格
"   /\<str\>
"       匹配整个单词(如可以匹配 "the str is"，但不能匹配 "string")
" }}}

" Visual {{{
    " c/r/y : 修改/替换/复制
    " I/A   : 在选择区域前面/后面输入
    " d/x   : 直接删除，不输入
    " ~/u/U : 大小写转换
    " >/<   : 右/左移
    " =     : 按equalprg命令格式化所选内容
    " !     : 按外部命令过滤所选内容
" }}}

" Software {{{
    " Python      : 需要在vim编译时添加Python支持
    " LLVM(Clang) : YouCompleteMe补全
    " fzf         : Fzf模糊查找
    " ripgrep     : Rg文本查找
    " ctags       : tags生成
    " fireFox     : Markdown,ReStructruedText等标记文本预览
    " fcitx       : Linux下的输入法
" }}}

" }}}

"===============================================================================
" Platform
"===============================================================================
" {{{
" vim or nvim, with or without gui
" {{{
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

" linux or win
" {{{
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

" term
" {{{
function! IsTermType(tt)
    if &term ==? a:tt
        return 1
    else
        return 0
    endif
endfunction
" }}}
" }}}

"===============================================================================
" Global settings
"===============================================================================
" {{{
if IsVim()
set nocompatible                        " 不兼容vi快捷键
endif
let mapleader="\<Space>"                " 使用Space作为leader
                                        " Space只在Normal或Command或Visual模式下map，不适合在Insert模式下map
" 特殊键
nnoremap ; :
nnoremap : ;
vnoremap ; :

" Path
" {{{
    let s:home_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
    " vim插件路径
    if IsLinux()
        " 链接root-vimrc到user's vimrc
        let $VimPluginPath=s:home_path . '/.vim'
    elseif IsWin()
        let $VimPluginPath=s:home_path . '\vimfiles'
        " windows下将HOME设置VIM的安装路径
        let $HOME=$VIM
    elseif IsGw()
        let $VimPluginPath='/c/MyApps/Vim/vimfiles'
    elseif IsMac()
        let $VimPluginPath=s:home_path . '/.vim'
    endif
    set rtp+=$VimPluginPath             " 添加 .vim 和 vimfiles 到 rtp(runtimepath)

    if IsWin()
        let s:path_vcvars32  = 'D:/VS2017/VC/Auxiliary/Build/vcvars32.bat'
        let s:path_vcvars64  = 'D:/VS2017/VC/Auxiliary/Build/vcvars64.bat'
        let s:path_nmake_x86 = 'D:/VS2017/VC/Tools/MSVC/14.13.26128/bin/Hostx86/x86/nmake.exe'
        let s:path_nmake_x64 = 'D:/VS2017/VC/Tools/MSVC/14.13.26128/bin/Hostx64/x64/nmake.exe'
        let s:path_qmake_x86 = 'D:/Qt/5.10.1/msvc2017_64/bin/qmake.exe'
        let s:path_qmake_x64 = 'D:/Qt/5.10.1/msvc2017_64/bin/qmake.exe'
        let s:path_vcvars = s:path_vcvars64
        let s:path_nmake  = s:path_nmake_x64
        let s:path_qmake  = s:path_qmake_x64
    endif
    if (IsWin() || IsGw())
        let s:path_browser_chrome = 'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe'
        let s:path_browser_firefox = 'D:/Mozilla Firefox/firefox.exe'
    elseif IsLinux()
        let s:path_browser_chrome = '/usr/bin/chrome'
        let s:path_browser_firefox = '/usr/bin/firefox'
    endif
    let s:path_browser = s:path_browser_firefox
" }}}

" Exe
" {{{
if !executable('rg')    | echo 'Warning: No ripgerp(rg)' | endif
if !executable('ctags') | echo 'Warning: No ctags'       | endif
if !executable('fzf')   | echo 'Warning: No fzf'         | endif
" }}}

" 键码设定
" {{{
set timeout                             " 打开映射超时检测
set ttimeout                            " 打开键码超时检测
set timeoutlen=1000                     " 映射超时时间为1000ms
set ttimeoutlen=70                      " 键码超时时间为70ms

" 键码设置 {{{
if IsVim()
" 键码示例 {{{
    " 终端Alt键映射处理：如 Alt+x，实际连续发送 <Esc>x 编码
    " 以下三种方法都可以使按下 Alt+x 后，执行 CmdTest 命令，但超时检测有区别
    "<1> set <M-x>=x  " 设置键码，这里的是一个字符，即<Esc>的编码，不是^和[放在一起
                        " 在终端的Insert模式，按Ctrl+v再按Alt+x可输入
    "    nnoremap <M-x> :CmdTest<CR>    " 按键码超时时间检测
    "<2> nnoremap <Esc>x :CmdTest<CR>   " 按映射超时时间检测
    "<3> nnoremap x  :CmdTest<CR>     " 按映射超时时间检测
" }}}

    set encoding=utf-8                  " 内部内部需要使用utf-8编码
    set <M-d>=d
    set <M-f>=f
    set <M-h>=h
    set <M-j>=j
    set <M-k>=k
    set <M-l>=l
    set <M-u>=u
    set <M-i>=i
    set <M-o>=o
    set <M-p>=p
    set <M-n>=n
    set <M-m>=m
endif
" }}}

" }}}
" }}}

"===============================================================================
" Plug Settings
"===============================================================================
" {{{
call plug#begin($VimPluginPath.'/bundle')   " 可选设置，可以指定插件安装位置

" 基本编辑
" {{{
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
    "
" }}}

" multiple-cursors {{{ 多光标编辑
    Plug 'terryma/vim-multiple-cursors'
    let g:multi_cursor_use_default_mapping=0
                                        " 取消默认按键
    let g:multi_cursor_start_key='<C-n>'
                                        " 进入Multiple-cursors Model
                                        " 可以自己选定区域（包括矩形选区），或自动选择当前光标<cword>
    let g:multi_cursor_next_key='<C-n>'
    let g:multi_cursor_prev_key='<C-p>'
    let g:multi_cursor_skip_key='<C-x>'
    let g:multi_cursor_quit_key='<Esc>'
" }}}

" textmanip {{{ 块编辑
    Plug 't9md/vim-textmanip'
    let g:textmanip_enable_mappings = 0
    function! SetTextmanipMode(mode)
        let g:textmanip_current_mode = a:mode
        echo 'textmanip mode: ' . g:textmanip_current_mode
    endfunction

    " 切换Insert/Replace Mode
    xnoremap <M-i> :<C-u>call SetTextmanipMode('insert')<CR>gv
    xnoremap <M-o> :<C-u>call SetTextmanipMode('replace')<CR>gv
    " C-i 与 <Tab>等价
    xnoremap <C-i> :<C-u>call SetTextmanipMode('insert')<CR>gv
    xnoremap <C-o> :<C-u>call SetTextmanipMode('replace')<CR>gv
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

" vim-over {{{ 替换预览
    Plug 'osyo-manga/vim-over'
    nnoremap <leader>sp :OverCommandLine<CR>
    vnoremap <leader>sp :OverCommandLine<CR>
" }}}

" incsearch {{{ 查找预览
    Plug 'haya14busa/incsearch.vim'
    Plug 'haya14busa/incsearch-fuzzy.vim'
    let g:incsearch#auto_nohlsearch = 1 " 停止搜索时，自动关闭高亮

    " 设置查找时页面滚动映射
    augroup PluginIncsearch
        autocmd!
        autocmd VimEnter * call s:incsearchKeymap()
    augroup END
    function! s:incsearchKeymap()
        IncSearchNoreMap <C-j> <Over>(incsearch-next)
        IncSearchNoreMap <C-k> <Over>(incsearch-prev)
        IncSearchNoreMap <M-j> <Over>(incsearch-scroll-f)
        IncSearchNoreMap <M-k> <Over>(incsearch-scroll-b)
    endfunction
    function! PreviewPattern(prompt)
        " 预览pattern
        let l:old_pat = histget('/', -1)
        try
            call incsearch#call({
                                    \ 'command': '/',
                                    \ 'is_stay': 1,
                                    \ 'prompt': a:prompt
                                \})
        " E117: 函数不存在
        catch /^Vim\%((\a\+)\)\=:E117/
            return ''
        endtry
        let l:pat = histget('/', -1)
        return (l:pat ==# l:old_pat) ? '' : l:pat
    endfunction

    nmap /  <Plug>(incsearch-forward)
    nmap ?  <Plug>(incsearch-backward)
    nmap g/ <Plug>(incsearch-stay)
    nmap z/ <Plug>(incsearch-fuzzy-/)
    nmap z? <Plug>(incsearch-fuzzy-?)
    nmap zg/ <Plug>(incsearch-fuzzy-stay)
    nmap n  <Plug>(incsearch-nohl-n)
    nmap N  <Plug>(incsearch-nohl-N)
    " *,#使用\< \>，而g*,g# 不使用\< \>
    nmap *  <Plug>(incsearch-nohl-*)
    nmap #  <Plug>(incsearch-nohl-#)
    nmap g* <Plug>(incsearch-nohl-g*)
    nmap g# <Plug>(incsearch-nohl-g#)
    nmap <leader>8  <Plug>(incsearch-nohl-*)
    nmap <leader>3  <Plug>(incsearch-nohl-#)
    nmap <leader>g8 <Plug>(incsearch-nohl-g*)
    nmap <leader>g3 <Plug>(incsearch-nohl-g#)
" }}}

" Fzf {{{ 模糊查找
    " linux下直接pacman -S fzf
    " win下载fzf.exe放入bundle/fzf/bin/下
    if IsWin()
        Plug 'junegunn/fzf'
    endif
    Plug 'junegunn/fzf.vim'
    let g:fzf_command_prefix = 'Fzf'
    nnoremap <leader>fF :FzfFiles
" }}}

" LeaderF {{{ 模糊查找
if IsLinux()
    Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }
    augroup PluginLeaderF
        autocmd!
        autocmd VimEnter * autocmd! LeaderF_Mru
    augroup END
elseif IsWin()
    Plug 'Yggdroot/LeaderF', { 'do': './install.bat' }
else
    Plug 'Yggdroot/LeaderF'
endif
    let g:Lf_CacheDirectory = $VimPluginPath
    let g:Lf_StlSeparator = {'left': '', 'right': '', 'font': ''}
    let g:Lf_ShortcutF = ''
    let g:Lf_ShortcutB = ''
    let g:Lf_ReverseOrder = 1
    nnoremap <leader>lf :LeaderfFile<CR>
    nnoremap <leader>lF :LeaderfFile
    nnoremap <leader>lu :LeaderfFunction<CR>
    nnoremap <leader>lU :LeaderfFunctionAll<CR>
    nnoremap <leader>ll :LeaderfLine<CR>
    nnoremap <leader>lL :LeaderfLineAll<CR>
    nnoremap <leader>lb :LeaderfBuffer<CR>
    nnoremap <leader>lB :LeaderfBufferAll<CR>
    nnoremap <leader>lr :LeaderfRgInteractive<CR>
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
    Plug 'brooth/far.vim'
    let g:far#file_mask_favorites = ['%', '*.txt']
    nnoremap <leader>sr :Farp<CR>
                                        " Search and Replace, 使用Fardo和Farundo来更改替换结果
    nnoremap <leader>fd :Fardo<CR>
    nnoremap <leader>fu :Farundo<CR>
" }}}

" tabular {{{ 字符对齐
    Plug 'godlygeek/tabular'
    " /,/r2l0   -   第1个field使用第1个对齐符（右对齐），再插入2个空格
    "               第2个field使用第2个对齐符（左对齐），再插入0个空格
    "               第3个field又重新从第1个对齐符开始（对齐符可以有多个，循环使用）
    "               这样就相当于：需对齐的field使用第1个对齐符，分割符(,)field使用第2个对齐符
    " /,\zs     -   将分割符(,)作为对齐内容field里的字符
    vnoremap <leader>al :Tabularize /
    nnoremap <leader>al :Tabularize /
" }}}

" smooth-scroll {{{ 平滑滚动
    Plug 'terryma/vim-smooth-scroll'
    nnoremap <M-n> :call smooth_scroll#down(&scroll, 0, 2)<CR>
    nnoremap <M-m> :call smooth_scroll#up(&scroll, 0, 2)<CR>
    nnoremap <M-j> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>
    nnoremap <M-k> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
" }}}

" expand-region {{{ 快速块选择
    Plug 'terryma/vim-expand-region'
    nmap <C-p> <Plug>(expand_region_expand)
    vmap <C-p> <Plug>(expand_region_expand)
    nmap <C-u> <Plug>(expand_region_shrink)
    vmap <C-u> <Plug>(expand_region_shrink)
" }}}

" vim-textobj-user {{{ 文本对象
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

" vim-repeat {{{ 重复命令
    Plug 'tpope/vim-repeat'
    function! SetRepeatExecution(string)
        let s:execution = a:string
        try
            call repeat#set("\<Plug>RepeatExecute", v:count)
        " E117: 函数不存在
        catch /^Vim\%((\a\+)\)\=:E117/
        endtry
    endfunction
    function! RepeatExecute()
        if !empty(s:execution)
            execute s:execution
        endif
    endfunction
    nnoremap <Plug>RepeatExecute :call RepeatExecute()<CR>
    nnoremap <leader>. :call RepeatExecute()<CR>
" }}}
" }}}

" 界面管理
" {{{
" theme {{{ Vim主题
    Plug 'morhetz/gruvbox'
    set rtp+=$VimPluginPath/bundle/gruvbox/
    " 背景选项：dark, medium, soft
    let g:gruvbox_contrast_dark='soft'

    Plug 'junegunn/seoul256.vim'
    set rtp+=$VimPluginPath/bundle/seoul256.vim/
    let g:seoul256_background=236       " 233(暗) ~ 239(亮)
    let g:seoul256_light_background=256 " 252(暗) ~ 256(亮)

    Plug 'altercation/vim-colors-solarized'
    set rtp+=$VimPluginPath/bundle/vim-colors-solarized/

    set background=dark
    colorscheme gruvbox
" }}}

" lightline {{{ 状态栏
    Plug 'itchyny/lightline.vim'
    "                    
    " ► ✘ ⌘ ▫ ▪ ★ ☆ • ≡ ፨ ♥
    let g:lightline = {
        \ 'enable'              : {'statusline': 1, 'tabline': 0},
        \ 'colorscheme'         : 'gruvbox',
        \ 'separator'           : {'left': '', 'right': ''},
        \ 'subseparator'        : {'left': '', 'right': ''},
        \ 'tabline_separator'   : {'left': '', 'right': ''},
        \ 'tabline_subseparator': {'left': '', 'right': ''},
        \ 'active': {
                \ 'left' : [['mode', 'paste'],
                \           ['popc_segr'],
                \           ['all_fileinfo', 'fw_filepath']],
                \ 'right': [['all_lineinfo', 'indent', 'trailing'],
                \           ['all_format'],
                \           ['fw.rootdir']],
                \ },
        \ 'inactive': {
                \ 'left' : [['absolutepath']],
                \ 'right': [['all_lineinfo']],
                \ },
        \ 'tabline' : {
                \ 'left' : [['tabs']],
                \ 'right': [['close']],
                \ },
        \ 'component': {
                \ 'all_lineinfo': '0X%02B ≡%3p%%   %04l/%L  %-2v',
                \ 'all_fileinfo': '%{winnr()},%-3n%{&ro?"":""}%M',
                \ 'all_format'  : '%{&ft!=#""?&ft." • ":""}%{&fenc!=#""?&fenc:&enc}[%{&ff}]',
                \ 'popc_segl'   : '%{&ft==#"Popc"?popc#ui#GetStatusLineSegments("l")[0]:""}',
                \ 'popc_segc'   : '%{&ft==#"Popc"?popc#ui#GetStatusLineSegments("c")[0]:""}',
                \ 'popc_segr'   : '%{&ft==#"Popc"?popc#ui#GetStatusLineSegments("r")[0]:""}',
                \ },
        \ 'component_function': {
                \ 'mode'        : 'LightlineMode',
                \ 'indent'      : 'LightlineCheckMixedIndent',
                \ 'trailing'    : 'LightlineCheckTrailing',
                \ 'fw_filepath' : 'LightlineFilepath',
                \ 'fw.rootdir'  : 'LightlineFindworking',
                \ },
        \ 'component_expand': {
                \},
        \ 'component_type': {
                \ },
        \ }
    augroup PluginLightline
        autocmd!
        autocmd ColorScheme * call s:lightlineColorScheme()
    augroup END
    function! s:lightlineColorScheme()
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
    function! LightlineMode()
        let fname = expand('%:t')
        return fname == '__Tagbar__' ? 'Tagbar' :
            \ fname =~ 'NERD_tree' ? 'NERDTree' :
            \ &ft ==# 'Popc' ? popc#ui#GetStatusLineSegments('l')[0] :
            \ &ft ==# 'startify' ? 'Startify' :
            \ winwidth(0) > 60 ? lightline#mode() : ''
    endfunction
    function! LightlineCheckMixedIndent()
        let l:ret = search('\t', 'nw')
        return (l:ret == 0) ? '' : 'I:'.string(l:ret)
    endfunction
    function! LightlineCheckTrailing()
        let ret = search('\s\+$', 'nw')
        return (l:ret == 0) ? '' : 'T:'.string(l:ret)
    endfunction
    function! LightlineFilepath()
        let l:fw = FindWorkingGet()
        let l:fp = fnamemodify(expand('%'), ':p')
        return empty(l:fw) ? l:fp : substitute(l:fp, escape(l:fw[0], '\'), '...', '')
    endfunction
    function! LightlineFindworking()
        let l:fw = FindWorkingGet()
        return empty(l:fw) ? '' : (l:fw[0] . '[' . l:fw[1] .']')
    endfunction
" }}}

" rainbow {{{ 彩色括号
    Plug 'luochen1990/rainbow'
    let g:rainbow_active = 1
    nnoremap <leader>tr :RainbowToggle<CR>
" }}}

" indent-line {{{ 显示缩进标识
    Plug 'Yggdroot/indentLine'
    "let g:indentLine_char = '|'        " 设置标识符样式
    let g:indentLinet_color_term=200    " 设置标识符颜色
    nnoremap <leader>ti :IndentLinesToggle<CR>
" }}}

" Pop Selection {{{ 弹出选项
    Plug 'yehuohan/popset'
    let g:Popset_SelectionData = [
        \{
            \ 'opt' : ['filetype', 'ft'],
            \ 'dsr' : 'When this option is set, the FileType autocommand event is triggered.',
            \ 'lst' : ['cpp', 'c', 'python', 'vim', 'go', 'markdown', 'help', 'text',
                     \ 'sh', 'matlab', 'conf', 'make', 'javascript', 'json', 'html'],
            \ 'dic' : {
                    \ 'cpp'        : 'Cpp file',
                    \ 'c'          : 'C file',
                    \ 'python'     : 'Python script file',
                    \ 'vim'        : 'Vim script file',
                    \ 'go'         : 'Go Language',
                    \ 'markdown'   : 'MarkDown file',
                    \ 'help'       : 'Vim help doc',
                    \ 'sh'         : 'Linux shell script',
                    \ 'conf'       : 'Config file',
                    \ 'make'       : 'Makefile of .mak file',
                    \ 'javascript' : 'JavaScript file',
                    \ 'json'       : 'Json file',
                    \ 'html'       : 'Html file',
                    \},
            \ 'cmd' : 'popset#data#SetEqual',
        \},
        \{
            \ 'opt' : ['colorscheme', 'colo'],
            \ 'lst' : ['gruvbox', 'seoul256', 'seoul256-light', 'solarized'],
            \ 'cmd' : '',
        \},]
    " set option with PSet
    nnoremap <leader>so :PSet
    nnoremap <leader>sa :PSet popset<CR>
" }}}

" popc {{{ buffer管理
    Plug 'yehuohan/popc', {'branch': 'dev'}
    set hidden
    let g:Popc_jsonPath = $VimPluginPath
    let g:Popc_useTabline = 1
    let g:Popc_useStatusline = 1
    let g:Popc_usePowerFont = 1
    let g:Popc_separator = {'left' : '', 'right': ''}
    let g:Popc_subSeparator = {'left' : '', 'right': ''}
    nnoremap <C-Space> :Popc<CR>
    inoremap <C-Space> <Esc>:Popc<CR>
    nnoremap <leader><leader>h :PopcBuffer<CR>
    nnoremap <M-u> :PopcBufferSwitchLeft<CR>
    nnoremap <M-p> :PopcBufferSwitchRight<CR>
    nnoremap <leader><leader>b :PopcBookmark<CR>
    nnoremap <leader><leader>w :PopcWorkspace<CR>
    nnoremap <leader><leader>fw :call PopcWksSearch()<CR>
    function! PopcWksSearch()
        let l:wks_root = popc#layer#wks#GetCurrentWks()[1]
        if !empty(l:wks_root)
            execute ':LeaderfFile ' . l:wks_root
        endif
    endfunction
" }}}

" nerd-tree {{{ 目录树导航
    Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTree']}
    let g:NERDTreeShowHidden=1
    let g:NERDTreeMapPreview = 'go'     " 预览打开
    let g:NERDTreeMapChangeRoot = 'cd'  " 更改根目录
    let g:NERDTreeMapChdir = 'CW'       " 更改CWD
    let g:NERDTreeMapCWD = 'CD'         " 更改根目录为CWD
    let g:NERDTreeMapJumpNextSibling = '<C-n>'
                                        " 下一个Sibling
    let g:NERDTreeMapJumpPrevSibling = '<C-p>'
                                        " 前一个Sibling
    nnoremap <leader>te :NERDTreeToggle<CR>
    nnoremap <leader>tE :execute ':NERDTree ' . expand('%:p:h')<CR>
" }}}

" vim-startify {{{ vim会话界面
    Plug 'mhinz/vim-startify'
    if IsLinux()
        let g:startify_bookmarks = [ {'c': '~/.vimrc'},
                                    \ '~/.zshrc',
                                    \ '~/.config/i3/config',
                                    \ '~/.config/nvim/init.vim'
                                    \]
    elseif IsWin()
        let g:startify_bookmarks = [ {'c': '$VimPluginPath/../_vimrc'},
                                    \ '$VimPluginPath/../vimfiles/.ycm_extra_conf.py',
                                    \ '$APPDATA/../Local/nvim/init.vim'
                                    \]
    elseif IsMac()
        let g:startify_bookmarks = [ {'c': '~/.vimrc'}, '~/.zshrc']
    endif
    let g:startify_lists = [
            \ {'type': 'bookmarks', 'header': ['   Bookmarks']},
            \ {'type': 'files',     'header': ['   Recent Files']},
            \ ]
    nnoremap <leader>su :Startify<CR>   " start ui of vim-startify
" }}}

" bookmarks {{{ 书签管理
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
    nnoremap <leader>tm :SignatureToggleSigns<CR>
    nnoremap <leader>ma :SignatureListBufferMarks<CR>
    nnoremap <leader>mc :<C-U>call signature#mark#Purge('all')<CR>
    nnoremap <leader>mx :<C-U>call signature#marker#Purge()<CR>
    nnoremap <M-d> :<C-U>call signature#mark#Goto('prev', 'line', 'pos')<CR>
    nnoremap <M-f> :<C-U>call signature#mark#Goto('next', 'line', 'pos')<CR>
" }}}

" undo {{{ 撤消历史
    Plug 'mbbill/undotree'
    nnoremap <leader>tu :UndotreeToggle<CR>
" }}}
" }}}

" 代码编写
" {{{
" YouCompleteMe {{{ 自动补全
    " Completion Params: install.py安装参数
    "   --clang-completer : C-famlily，基于Clang补全，需要安装Clang
    "   --go-completer    : Go，基于Gocode/Godef补全，需要安装Go
    "   --js-completer    : Javascript，基于Tern补全，需要安装node和npm
    "   --java-completer  : Java补全，需要安装JDK8
    " Linux: 使用install.py安装
    "   先安装python-dev, python3-dev, cmake, llvm, clang
    "   "./install.py --clang-completer --go-completer --js-completer --java-completer --system-libclang"
    "   ycm使用python命令指向的版本(如2.7或3.6)
    " Windows: 使用install.py安装
    "   先安装python, Cmake, VS, 7-zip
    "   "install.py --clang-completer --go-completer --js-completer --java-completer --msvc 14 --build-dir <ycm_build>"
    "   自己指定vs版本，自己指定build路径，编译完成后，可以删除<ycm_build>
    "   如果已经安装了clang，可以使用--system-libclang参数，就不必再下载clang了
    function! YcmBuild(info)
        " info is a dictionary with 3 fields
        " - name:   name of the plugin
        " - status: 'installed', 'updated', or 'unchanged'
        " - force:  set on PlugInstall! or PlugUpdate!
        if a:info.status == 'installed' || a:info.force
            if IsLinux()
                !./install.py --clang-completer --go-completer --java-completer --system-libclang
            elseif IsWin()
                !./install.py --clang-completer --go-completer --js-completer --java-completer --msvc 14 --build-dir ycm_build
            endif
        endif
    endfunction
    Plug 'Valloric/YouCompleteMe', { 'do': function('YcmBuild') }
    let g:ycm_global_ycm_extra_conf=$VimPluginPath.'/.ycm_extra_conf.py'
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
    let g:ycm_key_list_stop_completion = ['<C-y>']              " 关闭补全menu
    let g:ycm_key_invoke_completion = '<C-l>'                   " 显示补全内容
    let g:ycm_key_detailed_diagnostics = ''                     " 直接map :YcmShowDetailedDiagnostic命令即可
    let g:ycm_key_list_select_completion = ['<C-j>', '<C-n>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<C-k>', '<C-p>', '<Up>']
    nnoremap <leader>gt :YcmCompleter GoTo<CR>
    nnoremap <leader>gi :YcmCompleter GoToInclude<CR>
    nnoremap <leader>gd :YcmCompleter GoToDefinition<CR>
    nnoremap <leader>gD :YcmCompleter GoToDeclaration<CR>
    nnoremap <leader>gr :YcmCompleter GoToReferences<CR>
    nnoremap <leader>gp :YcmCompleter GetParent<CR>
    nnoremap <leader>gk :YcmCompleter GetDoc<CR>
    nnoremap <leader>gy :YcmCompleter GetType<CR>
    nnoremap <leader>gf :YcmCompleter FixIt<CR>
    nnoremap <leader>gc :YcmCompleter ClearCompilationFlagCache<CR>
    nnoremap <leader>gs :YcmCompleter RestartServer<CR>
    nnoremap <leader>yr :YcmRestartServer<CR>
    nnoremap <leader>yd :YcmShowDetailedDiagnostic<CR>
    nnoremap <leader>yD :YcmDiags<CR>
    nnoremap <leader>yc :call YcmCreateCppConf()<CR>
    nnoremap <leader>yj :call YcmCreateJsConf()<CR>
    function! YcmCreateCppConf()
        " 在当前目录下创建.ycm_extra_conf.py
        if !filereadable('.ycm_extra_conf.py')
            let l:file = readfile(g:ycm_global_ycm_extra_conf)
            call writefile(l:file, '.ycm_extra_conf.py')
        endif
        execute 'edit .ycm_extra_conf.py'
    endfunction
    function! YcmCreateJsConf()
        " 在当前目录下创建.tern-project
        if !filereadable('.tern-project')
            let l:file = readfile($VimPluginPath.'/.tern-project')
            call writefile(l:file, '.tern-project')
        endif
        execute 'edit .tern-project'
    endfunction
" }}}

" ultisnips {{{ 代码片段插入
    Plug 'yehuohan/ultisnips'           " snippet插入引擎（vmap的映射，与vim-textmanip的<C-i>有冲突）
    Plug 'honza/vim-snippets'           " snippet合集
    " 使用:UltiSnipsEdit编辑g:UltiSnipsSnippetsDir中的snippet文件
    let g:UltiSnipsSnippetsDir = $VimPluginPath . '/mySnippets'
    let g:UltiSnipsSnippetDirectories=['UltiSnips', 'mySnippets']
                                        " 自定义mySnippets合集
    let g:UltiSnipsExpandTrigger='<Tab>'
    let g:UltiSnipsListSnippets='<C-Tab>'
    let g:UltiSnipsJumpForwardTrigger='<C-j>'
    let g:UltiSnipsJumpBackwardTrigger='<C-k>'
" }}}

" ale {{{ 语法检测
    Plug 'w0rp/ale'
    " 语法引擎:
    "   VimScript : vint
    let g:ale_completion_enabled = 0    " 使能ale补全(只支持TypeScript)
    let g:ale_linters = {'java' : []}   " 禁用Java检测
    let g:ale_sign_error = '✘'
    let g:ale_sign_warning = '►'
    let g:ale_set_loclist = 1
    let g:ale_set_quickfix = 0
    let g:ale_echo_delay = 10           " 显示语文错误的延时时间
    let g:ale_lint_delay = 300          " 文本更改后的延时检测时间
    let g:ale_enabled = 0               " 默认关闭ALE检测
    nnoremap <leader>ta :execute ':ALEToggle'<Bar>echo 'AleToggle:' . g:ale_enabled<CR>
" }}}

" neoformat {{{ 代码格式化
    Plug 'sbdchd/neoformat'
    let g:neoformat_basic_format_align = 1
    let g:neoformat_basic_format_retab = 1
    let g:neoformat_basic_format_trim = 1
    let g:neoformat_c_astyle = {
        \ 'exe' : 'astyle',
        \ 'args' : ['--style=allman'],
        \ 'stdin' : 1,
        \ }
    let g:neoformat_cpp_astyle = g:neoformat_c_astyle
    let g:neoformat_java_astyle = {
        \ 'exe' : 'astyle',
        \ 'args' : ['--mode=java --style=google'],
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
    Plug 'majutsushi/tagbar'
    if IsLinux()
        let g:tagbar_ctags_bin='/usr/bin/ctags'
    elseif IsWin()
        let g:tagbar_ctags_bin=$VIM.'\vim81\ctags.exe'
    endif                               " 设置ctags路径，需要安装ctags
    let g:tagbar_width=30
    let g:tagbar_map_showproto=''       " 取消tagbar对<Space>的占用
    nnoremap <leader>tt :TagbarToggle<CR>
                                        " 可以 ctags -R 命令自行生成tags
" }}}

" nerd-commenter {{{ 批量注释
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

" file switch {{{ c/c++文件切换
    Plug 'derekwyatt/vim-fswitch'
    nnoremap <Leader>of :FSHere<CR>
    nnoremap <Leader>os :FSSplitRight<CR>
    let g:fsnonewfiles='on'
" }}}

" AsyncRun {{{ 导步运行程序
    Plug 'skywind3000/asyncrun.vim'
    if IsWin()
        let g:asyncrun_encs = 'cp936'   " 即'gbk'编码
    endif
    nnoremap <leader>rr :AsyncRun
    nnoremap <leader>rs :AsyncStop<CR>
    augroup PluginAsyncrun
        autocmd!
        autocmd User AsyncRunStart call asyncrun#quickfix_toggle(8, 1)
    augroup END
" }}}

" vim-quickhl {{{ 单词高亮
    Plug 't9md/vim-quickhl'
    nmap <leader>hw <Plug>(quickhl-manual-this)
    xmap <leader>hw <Plug>(quickhl-manual-this)
    nmap <leader>hs <Plug>(quickhl-manual-this-whole-word)
    xmap <leader>hs <Plug>(quickhl-manual-this-whole-word)
    nmap <leader>hm <Plug>(quickhl-cword-toggle)
    nnoremap <leader>hc :call quickhl#manual#clear_this('n')<CR>
    vnoremap <leader>hc :call quickhl#manual#clear_this('v')<CR>
    nmap <leader>hr <Plug>(quickhl-manual-reset)

    nnoremap <leader>th :QuickhlManualLockWindowToggle<CR>
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
    Plug 'octol/vim-cpp-enhanced-highlight'
" }}}
" }}}

" 软件辅助
" {{{
" vimcdoc {{{ 中文帮助文档
    Plug 'yianwillis/vimcdoc'
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
    let g:mkdp_browser = s:path_browser
    nnoremap <leader>vm :call ViewMarkdown()<CR>
    function! ViewMarkdown() abort
        let g:mkdp_browser = s:path_browser
        if !get(b:, 'MarkdownPreviewToggleBool')
            echo 'Open markdown preview'
        else
            echo 'Close markdown preview'
        endif
        call mkdp#util#toggle_preview()
    endfunction
" }}}

" reStructruedText {{{
if !(IsWin() && IsNVim())
    " 需要安装 https://github.com/Rykka/instant-rst.py
    Plug 'Rykka/riv.vim', {'for': 'rst'}
    Plug 'Rykka/InstantRst', {'for': 'rst'}
    let g:instant_rst_browser = s:path_browser
if IsWin()
    " 需要安装 https://github.com/mgedmin/restview
    nnoremap <leader>vr :execute ':AsyncRun restview ' . expand('%:p:t')<Bar>cclose<CR>
else
    nnoremap <leader>vr :call ViewRst()<CR>
endif
    function! ViewRst() abort
        if g:_instant_rst_daemon_started
            StopInstantRst
            echo 'StopInstantRst'
        else
            InstantRst
        endif
    endfunction
endif
" }}}

" open-browser.vim {{{ 在线搜索
    Plug 'tyru/open-browser.vim'
    let g:openbrowser_default_search='baidu'
    nmap <leader>bs <Plug>(openbrowser-smart-search)
    vmap <leader>bs <Plug>(openbrowser-smart-search)
    " search funtion - google, baidu, github
    function! OpenBrowserSearchInGoogle(engine, mode)
        if a:mode ==# 'n'
            call openbrowser#search(expand('<cword>'), a:engine)
        elseif a:mode ==# 'v'
            call openbrowser#search(GetSelectedContent(), a:engine)
        endif
    endfunction
    nnoremap <leader>big :OpenBrowserSearch -google
    nnoremap <leader>bg  :call OpenBrowserSearchInGoogle('google', 'n')<CR>
    vnoremap <leader>bg  :call OpenBrowserSearchInGoogle('google', 'v')<CR>
    nnoremap <leader>bib :OpenBrowserSearch -baidu
    nnoremap <leader>bb  :call OpenBrowserSearchInGoogle('baidu', 'n')<CR>
    vnoremap <leader>bb  :call OpenBrowserSearchInGoogle('baidu', 'v')<CR>
    nnoremap <leader>bih :OpenBrowserSearch -github
    nnoremap <leader>bh  :call OpenBrowserSearchInGoogle('github', 'n')<CR>
    vnoremap <leader>bh  :call OpenBrowserSearchInGoogle('github', 'v')<CR>
"}}}
" }}}

" Disabled Plugins
" {{{
" easy-align {{{ 字符对齐
    "Plug 'junegunn/vim-easy-align'
    "xmap <leader>ga <Plug>(EasyAlign)
    "nmap <leader>ga <Plug>(EasyAlign)
" }}}
" }}}

call plug#end()                         " required
" }}}

"===============================================================================
" User functions
"===============================================================================
" {{{
" Basic and misc {{{
" 切换显示隐藏字符 {{{
function! InvConceallevel()
    if &conceallevel == 0
        set conceallevel=2
    else
        set conceallevel=0              " 显示markdown等格式中的隐藏字符
    endif
    echo 'conceallevel = ' . &conceallevel
endfunction
" }}}

" 切换虚拟编辑 {{{
function! InvVirtualedit()
    if &virtualedit == ''
        set virtualedit=all
    else
        set virtualedit=""
    endif
    echo 'virtualedit = ' . &virtualedit
endfunction
" }}}

" 切换透明背影（需要系统本身支持透明） {{{
let s:inv_transparent_bg_flg = 0
function! InvTransParentBackground()
    if s:inv_transparent_bg_flg == 1
        hi Normal ctermbg=235
        let s:inv_transparent_bg_flg = 0
    else
        hi Normal ctermbg=NONE
        let s:inv_transparent_bg_flg = 1
    endif
endfunction
" }}}

" 切换显示行号 {{{
let s:inv_number_type=1
function! InvNumberType()
    if s:inv_number_type == 1
        let s:inv_number_type = 2
        set nonumber
        set norelativenumber
    elseif s:inv_number_type == 2
        let s:inv_number_type = 3
        set number
        set norelativenumber
    elseif s:inv_number_type == 3
        let s:inv_number_type = 1
        set number
        set relativenumber
    endif
endfunction
" }}}

" 切换显示折叠列 {{{
function! InvFoldColumeShow()
    if &foldcolumn == 0
        set foldcolumn=1
    else
        set foldcolumn=0
    endif
    echo 'foldcolumn = ' . &foldcolumn
endfunction
" }}}

" 切换显示标志列 {{{
function! InvSigncolumn()
    if &signcolumn == 'auto'
        set signcolumn=no
    else
        set signcolumn=auto
    endif
    echo 'signcolumn = ' . &signcolumn
endfunction
" }}}

" 切换高亮 {{{
function! InvHighLight()
    if exists('g:syntax_on')
        syntax off
        echo 'syntax off'
    else
        syntax on
        echo 'syntax on'
    endif
endfunction
" }}}

" 切换滚屏bind {{{
function! InvScrollBind()
    if &scrollbind == 1
        set noscrollbind
    else
        set scrollbind
    endif
    echo 'scrollbind = ' . &scrollbind
endfunction
" }}}

" 切换成x86或x64编译环境 {{{
let s:complile_type = 'x64'
function! ToggleX86X64()
    if IsWin()
        if 'x86' ==# s:complile_type
            let s:complile_type = 'x64'
            let s:path_vcvars = s:path_vcvars64
            let s:path_nmake = s:path_nmake_x64
            let s:path_qmake = s:path_qmake_x64
        else
            let s:complile_type = 'x86'
            let s:path_vcvars = s:path_vcvars32
            let s:path_nmake = s:path_nmake_x86
            let s:path_qmake = s:path_qmake_x86
        endif
        echo 'Complile Type: ' . s:complile_type
    endif
endfunction
" }}}

" {{{ 切换浏览器路径
function! ToggleBrowserPath()
    if s:path_browser ==# s:path_browser_firefox
        let s:path_browser = s:path_browser_chrome
    else
        let s:path_browser = s:path_browser_firefox
    endif
    echo 'Browser Path: ' . s:path_browser
endfunction
" }}}

" Linux-Fcitx输入法切换 {{{
if IsLinux()
function! LinuxFcitx2En()
    if 2 == system('fcitx-remote')
        let l:t = system('fcitx-remote -c')
    endif
endfunction
function! LinuxFcitx2Zh()
    if 1 == system('fcitx-remote')
        let l:t = system('fcitx-remote -o')
    endif
endfunction
endif
" }}}

" 查找Vim关键字 {{{
function! GotoKeyword(mode)
    let l:exec = 'help '
    if a:mode ==# 'n'
        let l:word = expand('<cword>')
    elseif a:mode ==# 'v'
        let l:word = GetSelectedContent()
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

" 去除尾部空白 {{{
function! RemoveTrailingSpace()
    let l:save = winsaveview()
    %s/\s\+$//e
    call winrestview(l:save)
endfunction
" }}}
" }}}

" Project run {{{
" FUNCTION: ExecCompile(str) {{{
function! ExecCompile(str)
    let l:exec = ((exists(':AsyncRun') == 2) ? ':AsyncRun ' : '!') . a:str
    execute l:exec
    return l:exec
endfunction
" }}}

" FUNCTION: ComplileFile(argstr) {{{
" @param argstr: 想要传递的命令参数
function! ComplileFile(argstr)
    let l:ext      = expand('%:e')      " 扩展名
    let l:filename = expand('%:t')      " 文件名，不带路径，带扩展名
    let l:name     = expand('%:t:r')    " 文件名，不带路径，不带扩展名
    let exec       = ''

    " 生成可执行字符串
    if 'c' ==? l:ext
    "{{{
        let l:exec .= 'gcc -static ' . a:argstr . ' -o ' . l:name . ' ' . l:filename
        let l:exec .= ' && "./' . l:name . '"'
    "}}}
    elseif 'cpp' ==? l:ext
    "{{{
        let l:exec .= 'g++ -std=c++11 -static ' . a:argstr . ' -o ' . l:name . ' ' . l:filename
        let l:exec .= ' && "./' . l:name . '"'
    "}}}
    elseif 'py' ==? l:ext || 'pyw' ==? l:ext
    "{{{
        let l:exec .= 'python ' . l:filename
        let l:exec .= ' ' . a:argstr
    "}}}
    elseif 'jl' ==? l:ext
    "{{{
        let l:exec .= 'julia ' . l:filename
        let l:exec .= ' ' . a:argstr
    "}}}
    elseif 'go' ==? l:ext
    "{{{
        let l:exec .= ' go run ' . l:filename
    "}}}
    elseif 'java' ==? l:ext
    "{{{
        let l:exec .= 'javac ' . l:filename
        let l:exec .= ' && java ' . l:name
    "}}}
    elseif 'json' ==? l:ext
    " {{{
        let l:exec .= 'python -m json.tool %'
    " }}}
    elseif 'm' ==? l:ext
    "{{{
        let l:exec .= 'matlab -nosplash -nodesktop -r ' . l:name[3:-2]
    "}}}
    elseif 'sh' ==? l:ext
    "{{{
        if IsLinux() || IsGw()
            let l:exec .= ' ./' . l:filename
            let l:exec .= ' ' . a:argstr
        else
            return
        endif
    "}}}
    elseif 'bat' ==? l:ext
    "{{{
        if IsWin()
            let l:exec .= ' ' . l:filename
            let l:exec .= ' ' . a:argstr
        else
            return
        endif
    "}}}
    elseif 'html' ==? l:ext
    "{{{
        let l:exec .= '"' . s:path_browser . '"' . ' ' . l:filename
    "}}}
    else
        return
    endif

    call SetRepeatExecution(ExecCompile(l:exec))
endfunction
" }}}

" FUNCTION: ComplileFileArgs(sopt, arg) {{{
function! ComplileFileArgs(sopt, arg)
    if a:arg ==# 'charset'
        call ComplileFile('-finput-charset=utf-8 -fexec-charset=gbk')
    endif
endfunction
let g:complile_args = {
    \ 'opt' : ['cppargs'],
    \ 'lst' : ['charset'],
    \ 'dic' : {
            \ 'charset' : '-finput-charset=utf-8 -fexec-charset=gbk',
            \},
    \ 'cmd' : 'ComplileFileArgs'}
" }}}

" FUNCTION: FindProjectFile(...) {{{
" @param 1: 工程文件，如*.pro
" @param 2: 查找起始目录，默认从当前目录向上查找到根目录
" @return 返回找到的文件路径列表
function! FindProjectFile(...)
    if a:0 == 0
        return ''
    endif
    let l:marker = a:1
    let l:start_dir = (a:0 >= 2) ? a:2 : '.'
    let l:dir      = fnamemodify(l:start_dir, ':p:h')
    let l:dir_last = ''
    let l:pfile    = ''

    while l:dir !=# l:dir_last
        let l:pfile = glob(l:dir . '/' . l:marker)
        if !empty(l:pfile)
            break
        endif

        let l:dir_last = l:dir
        let l:dir = fnamemodify(l:dir, ':p:h:h')
    endwhile

    return split(l:pfile, "\n")
endfunction
" }}}

" FUNCTION: FindProjectTarget(str, type) {{{
" @param str: 工程文件路径，如*.pro
" @param type: 工程文件类型，如qmake, make
function! FindProjectTarget(str, type)
    let l:target = '"./' . fnamemodify(a:str, ':t:r') . '"'
    if a:type == 'qmake' || a:type == 'make'
        for line in readfile(a:str)
            if line =~? '^\s*TARGET\s*='
                let l:target = split(line, '=')[1]
                let l:target = substitute(l:target, '^\s\+', '', 'g')
                let l:target = substitute(l:target, '\s\+$', '', 'g')
                let l:target = '"./' . l:target . '"'
            endif
        endfor
    endif
    return l:target
endfunction
" }}}

" FUNCTION: ComplileProject(str, fn, args) {{{
" 当找到多个Project File时，会弹出选项以供选择。
" @param str: 工程文件名，可用通配符，如*.pro
" @param fn: 编译工程文件的函数，需要采用popset插件
" @param args: 编译工程文件函数的附加参数，需要采用popset插件
function! ComplileProject(str, fn, args)
    let l:prj = FindProjectFile(a:str)
    if len(l:prj) == 1
        let Fn = function(a:fn)
        call Fn('', l:prj[0], a:args)
    elseif len(l:prj) > 1
        call PopSelection({
            \ 'opt' : ['Please select the project file'],
            \ 'lst' : l:prj,
            \ 'cmd' : a:fn,
            \}, 0, a:args)
    else
        echo 'None of ' . a:str . ' was found!'
    endif
endfunction
" }}}

" FUNCTION: ComplileProjectQmake(sopt, sel, args) {{{
" 用于popset的函数，用于编译qmake工程并运行生成的可执行文件。
" @param sopt: 参数信息，未用到，只是传入popset的函数需要
" @param sel: pro文件路径
" @param args: make命令附加参数列表
function! ComplileProjectQmake(sopt, sel, args)
    let l:filename = '"./' . fnamemodify(a:sel, ':p:t') . '"'
    let l:name     = FindProjectTarget(a:sel, 'qmake')
    let l:filedir  = fnameescape(fnamemodify(a:sel, ':p:h'))
    let l:olddir   = fnameescape(getcwd())
    let l:exec     = ''

    " change cwd
    execute 'lcd ' . l:filedir

    " execute shell code
    if IsLinux()
        let l:exec .= 'qmake ' . l:filename
        let l:exec .= ' && make'
    elseif IsWin()
        let l:exec .= s:path_qmake . ' -r ' . l:filename
        let l:exec .= ' && ' . s:path_vcvars
        let l:exec .= ' && ' . s:path_nmake . ' -f Makefile.Debug'
    else
        return
    endif
    if empty(a:args)
        let l:exec .= ' && ' . l:name
    else
        let l:exec .= ' ' . join(a:args)
    endif
    call ExecCompile(l:exec)

    " change back cwd
    execute 'lcd ' . l:olddir
endfunction
" }}}

" FUNCTION: ComplileProjectMakefile(sopt, sel, args) {{{
" 用于popset的函数，用于编译makefile工程并运行生成的可执行文件。
" @param sopt: 参数信息，未用到，只是传入popset的函数需要
" @param sel: makefile文件路径
" @param args: make命令附加参数列表
function! ComplileProjectMakefile(sopt, sel, args)
    let l:filename = '"./' . fnamemodify(a:sel, ':p:t') . '"'
    let l:name     = FindProjectTarget(a:sel, 'make')
    let l:filedir  = fnameescape(fnamemodify(a:sel, ':p:h'))
    let l:olddir   = fnameescape(getcwd())
    let l:exec     = ''

    " change cwd
    execute 'lcd ' . l:filedir

    " execute shell code
    let l:exec .= 'make'
    if empty(a:args)
        let l:exec .= ' && ' . l:name
    else
        let l:exec .= ' ' . join(a:args)
    endif
    call ExecCompile(l:exec)

    " change back cwd
    execute 'lcd ' . l:olddir
endfunction
"}}}

" FUNCTION: ComplileProjectHtml(sopt, sel, args) {{{
" 用于popset的函数，用于打开index.html
" @param sopt: 参数信息，未用到，只是传入popset的函数需要
" @param sel: index.html路径
function! ComplileProjectHtml(sopt, sel, args)
    call ExecCompile('"' . s:path_browser . '" "' . a:sel . '"')
endfunction
" }}}

" Run compliler
let RC_Qmake      = function('ComplileProject', ['*.pro', 'ComplileProjectQmake', []])
let RC_QmakeClean = function('ComplileProject', ['*.pro', 'ComplileProjectQmake', ['clean']])
let RC_Make       = function('ComplileProject', ['[mM]akefile', 'ComplileProjectMakefile', []])
let RC_MakeClean  = function('ComplileProject', ['[mM]akefile', 'ComplileProjectMakefile', ['clean']])
let RC_Html       = function('ComplileProject', ['[iI]ndex.html', 'ComplileProjectHtml', []])
" }}}

" Execute function {{{
" FUNCTION: ExecFuncInput(prompt, text, cmpl, fn, ...) range {{{
" @param prompt: input的提示信息
" @param text: input的缺省输入
" @param cmpl: input的输入输入补全
" @param fn: 要运行的函数，参数为input的输入，和可变输入参数
function! ExecFuncInput(prompt, text, cmpl, fn, ...) range
    if empty(a:cmpl)
        let l:inpt = input(a:prompt, a:text)
    else
        let l:inpt = input(a:prompt, a:text, a:cmpl)
    endif
    if empty(l:inpt)
        return
    endif
    let l:args = [l:inpt]
    if a:0 > 0
        call extend(l:args, a:000)
    endif
    let l:range = (a:firstline == a:lastline) ? '' : (string(a:firstline) . ',' . string(a:lastline))
    let Fn = function(a:fn, l:args)
    execute l:range . 'call Fn()'
endfunction
" }}}

" FUNCTION: FuncSort() range {{{ 预览sort匹配
function! FuncSort() range
    let l:pat = PreviewPattern('sort pattern: /')
    if empty(l:pat)
        return
    endif
    let l:range = (a:firstline == a:lastline) ? '' : (string(a:firstline) . ',' . string(a:lastline))
    call feedkeys(':' . l:range . 'sort /' . l:pat . '/', 'n')
endfunction
" }}}

" FUNCTION: FuncEditTempFile(suffix, ntab) {{{
" 编辑临时文件
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

" FUNCTION: FuncDiffFile(filename, mode) {{{
function! FuncDiffFile(filename, mode)
    if a:mode == 's'
        execute 'diffsplit ' . a:filename
    elseif a:mode == 'v'
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
    call SetRepeatExecution('call FuncDivideSpace("' . a:string . '", "' . a:pos . '")')
endfunction
let DivideSpaceH = function('ExecFuncInput', ['Divide H Space(split with space): ', '', '', 'FuncDivideSpace', 'h'])
let DivideSpaceC = function('ExecFuncInput', ['Divide C Space(split with space): ', '', '', 'FuncDivideSpace', 'c'])
let DivideSpaceL = function('ExecFuncInput', ['Divide L Space(split with space): ', '', '', 'FuncDivideSpace', 'l'])
let DivideSpaceD = function('ExecFuncInput', ['Divide D Space(split with space): ', '', '', 'FuncDivideSpace', 'd'])
" }}}
" }}}

" Search {{{
" FUNCTION: GetSelectedContent() {{{ 获取选区内容
function! GetSelectedContent()
    let l:reg_var = getreg('0', 1)
    let l:reg_mode = getregtype('0')
    normal! gv"0y
    let l:word = getreg('0')
    call setreg('0', l:reg_var, l:reg_mode)
    return l:word
endfunction
" }}}

" FUNCTION: GetMultiFilesCompletion(arglead, cmdline, cursorpos) {{{ 多文件自动补全
function! GetMultiFilesCompletion(arglead, cmdline, cursorpos)
    let l:complete = []
    let l:arglead_list = ['']
    let l:arglead_first = ''
    let l:arglead_glob = ''
    let l:files_list = []

    " process glob path-string
    if !empty(a:arglead)
        let l:arglead_list = split(a:arglead, ' ')
        let l:arglead_first = join(l:arglead_list[0:-2], ' ')
        let l:arglead_glob = l:arglead_list[-1]
    endif

    " glob non-hidden and hidden files(but no . and ..) with ignorecase
    set wildignorecase
    set wildignore+=.,..
    let l:files_list = split(glob(l:arglead_glob . "*") . "\n" . glob(l:arglead_glob . "\.[^.]*"), "\n")
    set wildignore-=.,..

    if len(l:arglead_list) == 1
        let l:complete = l:files_list
    else
        for item in l:files_list
            call add(l:complete, l:arglead_first . ' ' . item)
        endfor
    endif
    return l:complete
endfunction
" }}}

" FUNCTION: FindWorking(type, mode) {{{ 超速查找
" {{{
augroup UserFunctionSearch
    autocmd!
    autocmd VimEnter * call FindWorkingRoot()
    autocmd VimEnter * let s:fw_rg = exists('loaded_grep') ? 1 : 0
    autocmd User Grepper call FindWorkingHighlight(s:fw.pattern)
augroup END
let s:fw = {
    \ 'command'  : '',
    \ 'pattern'  : '',
    \ 'location' : '',
    \ 'options'  : '',
    \ 'root'     : '',
    \ 'filters'  : '',
    \ 'strings'  : [],
    \}
function! s:fw.run() dict
    let l:exec = s:fw.command . ' ' . s:fw.pattern . ' ' . s:fw.location . ' ' . s:fw.options
    execute l:exec
    if s:fw_rg
        call FindWorkingHighlight(s:fw.pattern)
    endif
    call SetRepeatExecution(l:exec)
endfunction
let s:fw_markers = ['.root', '.git', '.svn']
let s:fw_nvmaps = [
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
function! FindWorking(type, mode)
    " doc
    " {{{
    " Required: based on 'mhinz/vim-grepper' or 'yegappan/grep', 'Yggdroot/LeaderF' and 'yehuohan/popc'
    " Option: [fF][lav][btopr][IiWwSs=]
    "         [%1][%2 ][%3   ][4%     ]
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
    "  '' : find with working root-filter
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
            if a:type =~? 'i'
                let l:pat = input(' What to find: ')
            elseif a:type =~? '[ws]'
                let l:pat = expand('<cword>')
            endif
        elseif a:mode ==# 'v'
            let l:selected = GetSelectedContent()
            if a:type =~? 'i'
                let l:pat = input(' What to find: ', l:selected)
            elseif a:type =~? '[ws]'
                let l:pat = l:selected
            endif
        endif
        if a:type =~ '='
            let l:pat = getreg('+')
        endif
        let l:pat = escape(l:pat, ' -#%')       " escape 'Space,-,#,%'
        if !empty(l:pat) && a:type =~# 'l'
            let l:pat = '-e "' . l:pat .'"'     " used for 'Leaderf rg'
        endif
        return l:pat
    endfunction
    " }}}
    " FUNCTION: s:parseLocation() closure {{{
    function! s:parseLocation() closure
        let l:loc = ''
        if a:type =~# 'b'
            let l:loc = expand('%')
        elseif a:type =~# 't'
            let l:loc = join(popc#layer#buf#GetFiles('sigtab'), ' ')
        elseif a:type =~# 'o'
            let l:loc = join(popc#layer#buf#GetFiles('alltab'), ' ')
        elseif a:type =~# 'p'
            let l:loc = input(' Where to find: ', '', 'customlist,GetMultiFilesCompletion')
        elseif a:type =~# 'r'
            let l:loc = FindWorkingSet() ? s:fw.root : ''
        else
            if empty(s:fw.root)
                call FindWorkingRoot()
            endif
            if empty(s:fw.root)
                call FindWorkingSet()
            endif
            let l:loc = s:fw.root
        endif
        return l:loc
    endfunction
    " }}}
    " FUNCTION: s:parseOptions() closure {{{
    function! s:parseOptions() closure
        let l:opt = ''
        if a:type =~? 's'     | let l:opt .= '-w ' | endif
        if a:type =~# '[iws]' | let l:opt .= '-i ' | elseif a:type =~# '[IWS]' | let l:opt .= '-s ' | endif
        if !empty(s:fw.filters) && a:type !~# '[btop]'
            let l:opt .= '-g "*.{' . s:fw.filters . '}" '
        endif
        if a:type =~# 'F'
            let l:opt .= input(' Args to append: ', '')
        endif
        return l:opt
    endfunction
    " }}}
    " FUNCTION: s:parseCommand() closure {{{
    function! s:parseCommand() closure
        if a:type =~# 'l'
            let l:cmd = ':Leaderf rg --nowrap'
        elseif a:type =~# 'a'
            let l:cmd = s:fw_rg ? ':RgAdd' : 'Grepper -noprompt -tool rg -append -query'
        else
            let l:cmd = s:fw_rg ? ':Rg'    : 'Grepper -noprompt -tool rg -query'
            let s:fw.strings = []
        endif
        return l:cmd
    endfunction
    " }}}
    " FUNCTION: s:parseVimgrep() closure {{{
    function! s:parseVimgrep() closure
        if a:type !~# 'v'
            return 0
        endif

        " get pattern and set options
        let s:fw.pattern = s:parsePattern()
        if empty(s:fw.pattern) | return 0 | endif
        let l:pat = (a:type =~? 's') ? ('\<' . s:fw.pattern . '\>') : (s:fw.pattern)
        let l:pat .= (a:type =~# '[iws]') ? '\c' : '\C'

        " set loaction
        let l:loc = '%'
        if a:type =~# 'p'
            let l:loc = input(' Where to find: ', '', 'customlist,GetMultiFilesCompletion')
            if empty(l:loc) | return 0 | endif
        endif

        " execute vimgrep
        execute 'vimgrep /' . l:pat . '/j ' . l:loc
        echo 'Finding...'
        if empty(getqflist())
            echo 'No match: ' . l:pat
        else
            botright copen
            call FindWorkingHighlight(s:fw.pattern)
        endif
        return 1
    endfunction
    " }}}

    " try use vimgrep first
    if s:parseVimgrep() | return | endif

    " find pattern
    let s:fw.pattern = s:parsePattern()
    if empty(s:fw.pattern) | return | endif

    " find location
    let s:fw.location = s:parseLocation()
    if empty(s:fw.location) | return | endif

    " find options
    let s:fw.options = s:parseOptions()

    " find command
    let s:fw.command = s:parseCommand()

    " Find Working
    call s:fw.run()
endfunction
" }}}

" FUNCTION: FindWorkingRoot() {{{ 检测root路径
function! FindWorkingRoot()
    if empty(s:fw_markers)
        return
    endif

    let l:dir = fnamemodify('.', ':p:h')
    let l:dir_last = ''
    while l:dir !=# l:dir_last
        let l:dir_last = l:dir
        for m in s:fw_markers
            let l:root = l:dir . '/' . m
            if filereadable(l:root) || isdirectory(l:root)
                let s:fw.root = fnameescape(l:dir)
                return
            endif
        endfor
        let l:dir = fnamemodify(l:dir, ':p:h:h')
    endwhile
endfunction
" }}}

" FUNCTION: FindWorkingSet() {{{ 设置root路径
function! FindWorkingSet()
    let l:root = input(' Where (Root) to find: ', '', 'dir')
    if empty(l:root)
        return 0
    endif
    let s:fw.root = fnamemodify(l:root, ':p')
    let s:fw.filters = input(' Which (Filter) to find: ', '')
    return 1
endfunction
" }}}

" FUNCTION: FindWorkingGet() {{{ 获取root信息
function! FindWorkingGet()
    if empty(s:fw.root)
        return []
    endif
    return [s:fw.root, s:fw.filters]
endfunction
" }}}

" FUNCTION: FindWorkingFile(r) {{{ 查找文件
function! FindWorkingFile(r)
    if a:r
        let l:root = input(' Where (Root) to find: ', '', 'dir')
        if empty(l:root)
            return 0
        endif
        let s:fw.root = fnamemodify(l:root, ':p')
    endif
    if empty(s:fw.root)
        call FindWorkingRoot()
    endif
    if empty(s:fw.root)
        call FindWorkingSet()
    endif
    execute ':LeaderfFile ' . s:fw.root
endfunction
" }}}

" FUNCTION: FindWorkingHighlight(...) {{{ 高亮字符串
function! FindWorkingHighlight(...)
    if &filetype ==# 'leaderf'
        " use leaderf's highlight
    elseif &filetype ==# 'qf'
        if a:0 >= 1
            call add(s:fw.strings, escape(a:1, '/*'))
        endif
        for str in s:fw.strings
            execute 'syntax match IncSearch /' . str . '/'
        endfor
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
            let l:type = 'q'
        elseif l:dict[0].quickfix && l:dict[0].loclist
            let l:type = 'l'
        endif
        let l:line = line('.')
    endif
    return [l:type, l:line]
endfunction
" }}}

" FUNCTION: QuickfixTabEdit() {{{ 新建Tab打开窗口
function! QuickfixTabEdit()
    let [l:type, l:line] = QuickfixGet()
    if empty(l:type)
        return
    endif

    execute 'tabedit'
    if l:type ==# 'q'
        execute 'crewind ' . l:line
        silent! normal! zO
        silent! normal! zz
        execute 'botright copen'
    elseif l:type ==# 'l'
        execute 'lrewind ' . l:line
        silent! normal! zO
        silent! normal! zz
        execute 'botright lopen'
    endif
    call FindWorkingHighlight()
endfunction
" }}}

" FUNCTION: QuickfixPreview() {{{ 预览
function! QuickfixPreview()
    let [l:type, l:line] = QuickfixGet()
    if empty(l:type)
        return
    endif

    let l:last_winnr = winnr()
    if l:type ==# 'q'
        execute 'crewind ' . l:line
    elseif l:type ==# 'l'
        execute 'lrewind ' . l:line
    endif
    silent! normal! zO
    silent! normal! zz
    execute l:last_winnr . 'wincmd w'
endfunction
" }}}
" }}}
" }}}

"===============================================================================
" User Settings
"===============================================================================
" {{{
" Term
" {{{
    syntax on                           " 语法高亮
    set number                          " 显示行号
    set relativenumber                  " 显示相对行号
    set cursorline                      " 高亮当前行
    set cursorcolumn                    " 高亮当前列
    set hlsearch                        " 设置高亮显示查找到的文本
    set termguicolors                   " 在终端中使用24位彩色
if IsVim()
    set renderoptions=                  " 设置正常显示unicode字符
endif
    set expandtab                       " 将Tab用Space代替，方便显示缩进标识indentLine
    set tabstop=4                       " 设置Tab键宽4个空格
    set softtabstop=4                   " 设置按<Tab>或<BS>移动的空格数
    set shiftwidth=4                    " 设置>和<命令移动宽度为4
    set nowrap                          " 默认关闭折行
    set textwidth=0                     " 关闭自动换行
    set listchars=eol:$,tab:>-,trail:~,space:.
                                        " 不可见字符显示
    set autoindent                      " 使用autoindent缩进
    set nobreakindent                   " 折行时不缩进
    set conceallevel=0                  " 显示markdown等格式中的隐藏字符
    set foldenable                      " 充许折叠
    set foldcolumn=0                    " 0~12,折叠标识列，分别用“-”和“+”而表示打开和关闭的折叠
    set foldmethod=indent               " 设置折叠，默认为缩进折叠
                                        " manual : 手工定义折叠
                                        " indent : 更多的缩进表示更高级别的折叠
                                        " expr   : 用表达式来定义折叠
                                        " syntax : 用语法高亮来定义折叠
                                        " diff   : 对没有更改的文本进行折叠
                                        " marker : 对文中的标记折叠，默认使用{{{,}}}标记
    set scrolloff=3                     " 光标上下保留的行数
    set laststatus=2                    " 一直显示状态栏
    set noshowmode                      " 命令行栏不显示VISUAL等字样
    set completeopt=menuone,preview     " 补全显示设置
    set backspace=2                     " Insert模式下使用BackSpace删除
    set title                           " 允许设置titlestring
    set hidden                          " 允许在未保存文件时切换buffer
    set bufhidden=                      " 跟随hidden设置
    set nobackup                        " 不生成备份文件
    set nowritebackup                   " 覆盖文件前，不生成备份文件
    set autochdir                       " 自动切换当前目录为当前文件所在的目录
    set noautowrite                     " 禁止自动保存文件
    set noautowriteall                  " 禁止自动保存文件
    set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
                                        " 尝试解码序列
    set encoding=utf-8                  " vim内部使用utf-8编码
    set fileformat=unix                 " 以unix格式保存文本文件，即CR作为换行符
    set ignorecase                      " 不区别大小写搜索
    set smartcase                       " 有大写字母时才区别大小写搜索
    set notildeop                       " 使切换大小写的~，类似于c,y,d等操作符
    set nrformats=bin,octal,hex,alpha   " CTRL-A-X支持数字和字母
    set noimdisable                     " 切换Normal模式时，自动换成英文输入法
    set noerrorbells                    " 关闭错误信息响铃
    set visualbell t_vb=                " 关闭响铃(vb, visualbell)和可视闪铃(t_vb，即闪屏)，即normal模式时按esc会有响铃
    set belloff=all                     " 关闭所有事件的响铃
    set helplang=cn,en                  " 优先查找中文帮助

    " 终端光标设置
if IsVim()
    if IsTermType('xterm') || IsTermType('xterm-256color')
        " 适用于urxvt,st,xterm,gnome-termial
        " 5,6: 竖线，  3,4: 横线，  1,2: 方块
        let &t_SI = "\<Esc>[6 q"        " 进入Insert模式
        let &t_EI = "\<Esc>[2 q"        " 退出Insert模式
    endif
endif
" }}}

" Gui
" {{{
if IsGVim()
    set guioptions-=m                   " 隐藏菜单栏
    set guioptions-=T                   " 隐藏工具栏
    set guioptions-=L                   " 隐藏左侧滚动条
    set guioptions-=r                   " 隐藏右侧滚动条
    set guioptions-=b                   " 隐藏底部滚动条
    set guioptions-=e                   " 不使用GUI标签

    if IsLinux()
        set lines=20
        set columns=100
        "set guifont=DejaVu\ Sans\ Mono\ 13
        set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 13.5
        set linespace=0                 " required by Powerline Font
        set guifontwide=WenQuanYi\ Micro\ Hei\ Mono\ 13.5
    elseif IsWin()
        set lines=25
        set columns=100
        "set guifont=Consolas:h13:cANSI
        set guifont=Consolas_For_Powerline:h12:cANSI
        set linespace=0                 " required by Powerline Font
        set guifontwide=Microsoft_YaHei_Mono:h11:cGB2312
        nnoremap <leader>tf <Esc>:call libcallnr('gvimfullscreen.dll', 'ToggleFullScreen', 0)<CR>
                                        " gvim全屏
    elseif IsMac()
        set lines=30
        set columns=100
        set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h15
    endif
endif

if IsNVim()
augroup UserSettingsGui
    autocmd!
    autocmd VimEnter * call s:setGuifontNVimQt()
augroup END

" FUNCTION: s:setGuifontNVimQt() {{{ neovim-qt设置
function! s:setGuifontNVimQt()
if IsNVimQt()
    if IsLinux()
        Guifont! WenQuanYi Micro Hei Mono:h13
        Guifont! DejaVu Sans Mono for Powerline:h13
    elseif IsWin()
        " 先设置一次中文（缺省）字体，再设置英文字体(BUG:有时有问题)
        "Guifont! YaHei Mono For Powerline:h12
        Guifont! Microsoft YaHei Mono:h12
        Guifont! Consolas For Powerline:h12
    endif
    GuiLinespace 0
    GuiTabline 0
    nnoremap <leader>tf :call GuiWindowFullScreen(!g:GuiWindowFullScreen)<CR>
                                        " neovim-qt全屏
endif
endfunction
" }}}
endif
" }}}

" Auto Command
" {{{
augroup UserSettingsCmd
    "autocmd[!]  [group]  {event}     {pattern}  {nested}  {cmd}
    "autocmd              BufNewFile  *                    set fileformat=unix
    autocmd!

    autocmd BufNewFile *    set fileformat=unix
    autocmd GuiEnter *      set t_vb=   " 关闭可视闪铃(即闪屏)
    autocmd BufEnter *.tikz set filetype=tex

    autocmd Filetype vim    setlocal foldmethod=marker
    autocmd Filetype c      setlocal foldmethod=syntax
    autocmd Filetype cpp    setlocal foldmethod=syntax
    autocmd Filetype python setlocal foldmethod=indent
    autocmd FileType go     setlocal expandtab
    autocmd FileType javascript setlocal foldmethod=syntax

    " Help keys
    autocmd Filetype vim,help nnoremap <buffer> <S-k> :call GotoKeyword('n')<CR>
    autocmd Filetype vim,help vnoremap <buffer> <S-k> :call GotoKeyword('v')<CR>
    " 预览Quickfix和Location-list
    autocmd Filetype qf       nnoremap <buffer> <M-Space> :call QuickfixPreview()<CR>
augroup END
" }}}
" }}}

"===============================================================================
" User Key-Maps
"===============================================================================
" {{{
" Basic Edit {{{
    " 回退操作
    nnoremap <S-u> <C-r>
    " 大小写转换
    nnoremap <leader>u ~
    vnoremap <leader>u ~
    nnoremap <leader>gu g~
    " 矩形选择
    nnoremap vv <C-v>
    vnoremap vv <C-v>
    " 加减序号
    nnoremap <C-h> <C-x>
    nnoremap <C-l> <C-a>
    vnoremap <leader>aj <C-x>
    vnoremap <leader>ak <C-a>
    vnoremap <leader>agj g<C-x>
    vnoremap <leader>agk g<C-a>
    " 去除尾部空白
    nnoremap <leader>rt :call RemoveTrailingSpace()<CR>
    " HEX编辑
    nnoremap <leader>xx :%!xxd<CR>
    nnoremap <leader>xr :%!xxd -r<CR>
    " 空格分隔
    nnoremap <leader>dh :call DivideSpaceH()<CR>
    nnoremap <leader>dc :call DivideSpaceC()<CR>
    nnoremap <leader>dl :call DivideSpaceL()<CR>
    nnoremap <leader>dd :call DivideSpaceD()<CR>
    " 显示折行
    nnoremap <leader>iw :set invwrap<CR>
    " 显示不可见字符
    nnoremap <leader>il :set invlist<CR>
    nnoremap <leader>iv :call InvVirtualedit()<CR>
    nnoremap <leader>ic :call InvConceallevel()<CR>
    nnoremap <leader>it :call InvTransParentBackground()<CR>
    nnoremap <leader>in :call InvNumberType()<CR>
    nnoremap <leader>if :call InvFoldColumeShow()<CR>
    nnoremap <leader>is :call InvSigncolumn()<CR>
    nnoremap <leader>ih :call InvHighLight()<CR>
    nnoremap <leader>ib :call InvScrollBind()<CR>
    nnoremap <leader>tc :call ToggleX86X64()<CR>
    nnoremap <leader>tb :call ToggleBrowserPath()<CR>
    if IsLinux()
        inoremap <Esc> <Esc>:call LinuxFcitx2En()<CR>
    endif
" }}}

" Copy and paste{{{
    vnoremap <leader>y ygv
    vnoremap <leader>c "+y
    vnoremap <C-c> "+y
    nnoremap <C-v> "+p
    inoremap <C-v> <Esc>"+pi
    " 粘贴通过y复制的内容
    nnoremap <leader>p "0p
    nnoremap <leader>P "0P

    let s:lower_chars = split('q w e r t y u i o p a s d f g h j k l z x c v b n m', ' ')
    let s:digital_chars = split('1 2 3 4 5 6 7 8 9 0', ' ')

    " 寄存器快速复制与粘贴
    for t in s:lower_chars
        execute "vnoremap <leader>'" . t            .   ' "' . t . 'y'
        execute "nnoremap <leader>'" . t            .   ' "' . t . 'p'
        execute "nnoremap <leader>'" . toupper(t)   .   ' "' . t . 'P'
    endfor
    for t in s:digital_chars
        execute "vnoremap <leader>'" . t            .   ' "' . t . 'y'
        execute "nnoremap <leader>'" . t            .   ' "' . t . 'p'
    endfor
    " 快速执行宏
    for t in s:lower_chars
        execute "nnoremap <leader>2" . t            .   ' @' . t
    endfor
" }}}

" Move and goto{{{
    " 扩展匹配符(%)功能
if IsVim()
    packadd matchit
endif
    " 嵌套映射匹配符(%)
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
    nnoremap <M-h> 16zh
    nnoremap <M-l> 16zl
    " 命令行移动
    cnoremap <M-h> <Left>
    cnoremap <M-l> <Right>
    cnoremap <M-k> <C-Right>
    cnoremap <M-j> <C-Left>
    cnoremap <M-i> <C-B>
    cnoremap <M-o> <C-E>
" }}}

" Tab, Buffer, Quickfix, Windows {{{
    " Tab切换
    nnoremap <M-i> gT
    nnoremap <M-o> gt
    " Buffer切换
    nnoremap <leader>bn :bnext<CR>
    nnoremap <leader>bp :bprevious<CR>
    nnoremap <leader>bl :b#<Bar>execute 'set buflisted'<CR>
    " 打开/关闭Quickfix
    nnoremap <leader>qo :botright copen<Bar>call FindWorkingHighlight()<CR>
    nnoremap <leader>qc :cclose<Bar>wincmd p<CR>
    nnoremap <leader>qj :cnext<Bar>execute'silent! normal! zO'<Bar>execute'normal! zz'<CR>
    nnoremap <leader>qk :cprevious<Bar>execute'silent! normal! zO'<Bar>execute'normal! zz'<CR>
    " 打开/关闭Location-list
    nnoremap <leader>lo :botright lopen<Bar>call FindWorkingHighlight()<CR>
    nnoremap <leader>lc :lclose<Bar>wincmd p<CR>
    nnoremap <leader>lj :lnext<Bar>execute'silent! normal! zO'<Bar>execute'normal! zz'<CR>
    nnoremap <leader>lk :lprevious<Bar>execute'silent! normal! zO'<Bar>execute'normal! zz'<CR>
    " 在新Tab中打开列表项
    nnoremap <leader>qt :call QuickfixTabEdit()<CR>
    nnoremap <leader>lt :call QuickfixTabEdit()<CR>
    " 分割窗口
    nnoremap <leader>ws <C-w>s
    nnoremap <leader>wv <C-W>v
    " 移动焦点
    nnoremap <leader>wc <C-w>c
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
    " 修改尺寸
    nnoremap <leader>w= <C-w>=
    inoremap <C-Up> <Esc>:resize+1<CR>i
    inoremap <C-Down> <Esc>:resize-1<CR>i
    inoremap <C-Left> <Esc>:vertical resize-1<CR>i
    inoremap <C-Right> <Esc>:vertical resize+1<CR>i
    nnoremap <C-Up> :resize+1<CR>
    nnoremap <C-Down> :resize-1<CR>
    nnoremap <C-Left> :vertical resize-1<CR>
    nnoremap <C-Right> :vertical resize+1<CR>
    nnoremap <M-Up> :resize+5<CR>
    nnoremap <M-Down> :resize-5<CR>
    nnoremap <M-Left> :vertical resize-5<CR>
    nnoremap <M-Right> :vertical resize+5<CR>
" }}}

" Terminal {{{
if has('terminal')
    nnoremap <leader>tz :terminal zsh<CR>
    set termwinkey=<C-l>
if IsVim()
    tnoremap <Esc> <C-l>N
    packadd termdebug
else
    tnoremap <Esc> <C-\><C-n>
endif
endif
" }}}

" Program and function {{{
    " 建立临时文件
    nnoremap <leader>ei :call ExecFuncInput('TempFile Suffix:', '', '', 'FuncEditTempFile', 0)<CR>
    nnoremap <leader>en :call FuncEditTempFile (''   , 0)<CR>
    nnoremap <leader>ec :call FuncEditTempFile ('c'  , 0)<CR>
    nnoremap <leader>ea :call FuncEditTempFile ('cpp', 0)<CR>
    nnoremap <leader>ep :call FuncEditTempFile ('py' , 0)<CR>
    nnoremap <leader>eg :call FuncEditTempFile ('go' , 0)<CR>
    nnoremap <leader>em :call FuncEditTempFile ('m'  , 0)<CR>
    nnoremap <leader>eti :call ExecFuncInput('TempFile Suffix:', '', '', 'FuncEditTempFile', 1)<CR>
    nnoremap <leader>etn :call FuncEditTempFile(''   , 1)<CR>
    nnoremap <leader>etc :call FuncEditTempFile('c'  , 1)<CR>
    nnoremap <leader>eta :call FuncEditTempFile('cpp', 1)<CR>
    nnoremap <leader>etp :call FuncEditTempFile('py' , 1)<CR>
    nnoremap <leader>etg :call FuncEditTempFile('go' , 1)<CR>
    nnoremap <leader>etm :call FuncEditTempFile('m'  , 1)<CR>
    " 排序
    nnoremap <leader>ss :call FuncSort()<CR>

    " 编译运行当前文件
    nnoremap <leader>rf :call ComplileFile('')<CR>
    nnoremap <leader>rq :call RC_Qmake()<CR>
    nnoremap <leader>rm :call RC_Make()<CR>
    nnoremap <leader>rcq :call RC_QmakeClean()<CR>
    nnoremap <leader>rcm :call RC_MakeClean()<CR>
    nnoremap <leader>rh :call RC_Html()<CR>
    nnoremap <leader>ra :call PopSelection(g:complile_args, 0)<CR>
    nnoremap <leader>ri :call ExecFuncInput('Compile Args: ', '', 'customlist,GetMultiFilesCompletion', 'ComplileFile')<CR>
    nnoremap <leader>rd :Termdebug<CR>

    let g:termdebug_wide = 150
    tnoremap <F1> <C-l>:Gdb<CR>
    tnoremap <F2> <C-l>:Program<CR>
    tnoremap <F3> <C-l>:Source<CR>
    nnoremap <F1> :Gdb<CR>
    nnoremap <F2> :Program<CR>
    nnoremap <F3> :Source<CR>
    nnoremap <F4> :Stop<CR>
    nnoremap <F5> :Run<CR>
    nnoremap <F6> :Continue<CR>
    " Termdebug模式下，K会自动map成Evaluate
    nnoremap <leader>ge :Evaluate<CR>
    vnoremap <leader>ge :Evaluate<CR>
    nnoremap <F7> :Evaluate<CR>
    vnoremap <F7> :Evaluate<CR>
    nnoremap <F8> :Clear<CR>
    nnoremap <F9> :Break<CR>
    nnoremap <F10> :Over<CR>
    nnoremap <F11> :Step<CR>
" }}}

" File diff {{{
    " 文件比较，自动补全文件和目录
    nnoremap <leader>ds :call ExecFuncInput('File: ', '', 'file', 'FuncDiffFile', 's')<CR>
    nnoremap <leader>dv :call ExecFuncInput('File: ', '', 'file', 'FuncDiffFile', 'v')<CR>
    " 比较当前文件（已经分屏）
    nnoremap <leader>dt :diffthis<CR>
    " 关闭文件比较，与diffthis互为逆命令
    nnoremap <leader>do :diffoff<CR>
    " 更新比较结果
    nnoremap <leader>du :diffupdate<CR>
    " 应用差异到别一文件，[range]<leader>dp，range默认为1行
    nnoremap <leader>dp :<C-U>execute '.,+' . string(v:count1-1) . 'diffput'<CR>
    " 拉取差异到当前文件，[range]<leader>dg，range默认为1行
    nnoremap <leader>dg :<C-U>execute '.,+' . string(v:count1-1) . 'diffget'<CR>
    " 下一个diff
    nnoremap <leader>dj ]c
    " 前一个diff
    nnoremap <leader>dk [c
" }}}

" Find and search{{{
    " 查找选择的内容
    vnoremap / "*y<Bar>:execute'let g:__str__=getreg("*")'<Bar>execute'/' . g:__str__<CR>
    " 查找当前光标下的内容
    nnoremap <leader>/ :execute'let g:__str__=expand("<cword>")'<Bar>execute '/' . g:__str__<CR>

    " FindWorking查找
    for item in s:fw_nvmaps
        execute 'nnoremap <leader>' . item ':call FindWorking("' . item . '", "n")<CR>'
    endfor
    for item in s:fw_nvmaps
        execute 'vnoremap <leader>' . item ':call FindWorking("' . item . '", "v")<CR>'
    endfor
    nnoremap <leader>ff :call FindWorkingFile(0)<CR>
    nnoremap <leader>frf :call FindWorkingFile(1)<CR>
    nnoremap <leader>fR :call FindWorkingRoot()<CR>
" }}}
" }}}
