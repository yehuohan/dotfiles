
"
" vimrc configuration for vim, gvim, neovim and neovim-qt.
" set the path of 'Global settings' before using this vimrc.
" yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
"

"===============================================================================
" My Notes
"===============================================================================
" {{{
" Windows带python编译gvim
" {{{
    " [*] 设置Make_cyg_ming.mak:
    " DIRECTX=yes                         - 使用DirectX
    " ARCH=i686                           - 使用32位(x86-64为64位)，python也使用32位
    " TERMINAL=yes                        - 添加terminal特性(最新已经添加winpty)
    " CC := $(CROSS_COMPILE)gcc -m32      - 32位编绎
    " CXX := $(CROSS_COMPILE)g++ -m32     - 32位编绎
    " WINDRES := windres --target=pe-i386 - 资源文件添加i386编绎
    " DYNAMIC_PYTHON3=yes                 - Python3设置
    " PYTHON3_VER=36                      - Python3版本
    "
    " [*] 设置Make_ming.mak:
    " PYTHON3=C:/MyApps/Python36          - 没置Python3路径
    "
    " [*] 使用MinGw-x64:
    " mingw32-make -f Make_ming.mak gvim.exe
    " 若设置32位选项前编译过一次，清理一次.o文件再编译
    " 若使用64位，只需要添加Python路径和DirectX支持
" }}}

" 查看vim帮助
" {{{
    " :help       = 查看Vim帮助
    " :help index = 查看帮助列表
    " <S-k>       = 快速查看光标所在cword或选择内容的vim帮助
    " :help *@en  = 指定查看英文(en，cn即为中文)帮助
" }}}

" 按键映键策略
" {{{
    " - Normal模式下使用<leader>代替<C-?>,<S-?>,<A-?>，
    " - Insert模式下map带ctrl,alt的快捷键
    " - 尽量不改变vim原有键位的功能定义
    " - 尽量一只手不同时按两个键
    " - 尽量不映射偏远的按键（F1~F12，数字键等）
    " - 调换Esc和CapsLock键
    " - map语句后一般别注释，也别留任何空格
    "
    "  <leader>t? for plugins toggle command
    "  <leader>i? for vim "set inv?" command
"  }}}

" 替换字符串
" {{{
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

" 可视区域操作
" {{{
    " c/r/y : 修改/替换/复制
    " I/A   : 在选择区域前面/后面输入
    " d/x   : 直接删除，不输入
    " ~/u/U : 大小写转换
    " >/<   : 右/左移
    " =     : 按equalprg命令格式化所选内容
    " !     : 按外部命令过滤所选内容
" }}}

" 第三方软件
" {{{
    " Python                      : 需要在vim编译时添加Python支持
    " LLVM(Clang)                 : YouCompleteMe补全
    " fzf                         : Fzf模糊查找
    " ripgrep                     : Rg文本查找
    " ag                          : Ag文本查找
    " ctags                       : tags生成
    " global, gtags, gtags-cscope : tags查找
    " fireFox                     : Markdown,ReStructruedText等标记文本预览
    " fcitx                       : Linux下的输入法
" }}}
" }}}

"===============================================================================
" Platform
"===============================================================================
" {{{
" vim or nvim
" {{{
silent function! IsNVim()
    return (has('nvim'))
endfunction
silent function! IsVim()
    return !(has('nvim'))
endfunction
" }}}

" linux or win
" {{{
silent function! IsLinux()
    return (has('unix') && !has('macunix') && !has('win32unix'))
endfunction
silent function! IsWin()
    return (has('win32') || has('win64'))
endfunction
silent function! IsGw()
    " GNU for windows
    return (has('win32unix'))
endfunction
silent function! IsMac()
    return (has('mac'))
endfunction
" }}}

" gui or term
" {{{
silent function! IsGvim()
    return has("gui_running")
endfunction
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
set nocompatible                        " 不兼容vi快捷键
let mapleader="\<Space>"                " 使用Space作为leader
                                        " Space只在Normal或Command或Visual模式下map，不适合在Insert模式下map
" 特殊键
nnoremap ; :
nnoremap : ;
vnoremap ; :

" Path
" {{{
    let s:home_path = fnamemodify(resolve(expand("<sfile>:p")), ":h")
    " vim插件路径
    if IsLinux()
        " 链接root-vimrc到user's vimrc
        let $VimPluginPath=s:home_path . "/.vim"
    elseif IsWin()
        let $VimPluginPath=s:home_path . "\\vimfiles"
        " windows下将HOME设置VIM的安装路径
        let $HOME=$VIM
        " 未打开文件时，切换到HOME目录
        execute "cd $HOME"
    elseif IsGw()
        let $VimPluginPath="/c/MyApps/Vim/vimfiles"
    elseif IsMac()
        let $VimPluginPath=s:home_path . "/.vim"
    endif
    set rtp+=$VimPluginPath             " 添加 .vim 和 vimfiles 到 rtp(runtimepath)

    if IsWin()
        let s:path_vcvars32 = '"D:/VS2017/VC/Auxiliary/Build/vcvars32.bat"'
        let s:path_vcvars64 = '"D:/VS2017/VC/Auxiliary/Build/vcvars64.bat"'
        let s:path_nmake_x86 = '"D:/VS2017/VC/Tools/MSVC/14.13.26128/bin/Hostx86/x86/nmake.exe"'
        let s:path_nmake_x64 = '"D:/VS2017/VC/Tools/MSVC/14.13.26128/bin/Hostx64/x64/nmake.exe"'
        let s:path_qmake_x86 = '"D:/Qt/5.10.1/msvc2017_64/bin/qmake.exe"'
        let s:path_qmake_x64 = '"D:/Qt/5.10.1/msvc2017_64/bin/qmake.exe"'
    endif
    if (IsWin() || IsGw())
        let s:path_browser_chrome = '"C:/Program Files (x86)/Google/Chrome/Application/chrome.exe"'
        let s:path_browser_firefox = '"D:/Mozilla Firefox/firefox.exe"'
    elseif IsLinux()
        let s:path_browser_chrome = '"/usr/bin/chrome"'
        let s:path_browser_firefox = '"/usr/bin/firefox"'
    endif
    if IsWin()
        let s:path_vcvars  = s:path_vcvars64
        let s:path_nmake   = s:path_nmake_x64
        let s:path_qmake   = s:path_qmake_x64
    endif
    let s:path_browser = s:path_browser_firefox
" }}}

" Exe
" {{{
if !executable('rg')           | echo "Warning: No ripgerp(rg)"   | endif
if !executable("ag")           | echo "Warning: No ag"            | endif
if !executable('ctags')        | echo "Warning: No ctags"         | endif
if !executable('gtags')        | echo "Warning: No gtags"         | endif
if !executable('global')       | echo "Warning: No global"        | endif
if !executable('gtags-cscope') | echo "Warning: No gtags-csocpe)" | endif
" }}}

" 键码设定
" {{{
set timeout                             " 打开映射超时检测
set ttimeout                            " 打开键码超时检测
set timeoutlen=1000                     " 映射超时时间为1000ms
set ttimeoutlen=70                      " 键码超时时间为70ms

" 键码示例 {{{
    " 终端Alt键映射处理：如 Alt+x，实际连续发送 <Esc>x 编码
    " 以下三种方法都可以使按下 Alt+x 后，执行 CmdTest 命令，但超时检测有区别
    "<1> set <M-x>=x  " 设置键码，这里的是一个字符，即<Esc>的编码，不是^和[放在一起
                        " 在终端的Insert模式，按Ctrl+v再按Alt+x可输入
    "    nnoremap <M-x> :CmdTest<CR>    " 按键码超时时间检测
    "<2> nnoremap <Esc>x :CmdTest<CR>   " 按映射超时时间检测
    "<3> nnoremap x  :CmdTest<CR>     " 按映射超时时间检测
" }}}

" 键码设置 {{{
if IsVim()
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
" Plug and Settings
"===============================================================================
" {{{
call plug#begin($VimPluginPath."/bundle")   " 可选设置，可以指定插件安装位置

" 基本编辑类
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
        echo "textmanip mode: " . g:textmanip_current_mode
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
    augroup incsearch-keymap
        autocmd!
        autocmd VimEnter * call s:incsearch_keymap()
    augroup END
    function! s:incsearch_keymap()
        IncSearchNoreMap <C-j> <Over>(incsearch-next)
        IncSearchNoreMap <C-k> <Over>(incsearch-prev)
        IncSearchNoreMap <M-j> <Over>(incsearch-scroll-f)
        IncSearchNoreMap <M-k> <Over>(incsearch-scroll-b)
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
    nnoremap <leader>fl :FzfLines<CR>
    nnoremap <leader>fb :FzfBLines<CR>
" }}}

" grep {{{ 大范围查找
if IsVim()
    Plug 'yegappan/grep'
    "let g:Ag_Path = "$VIM."\\vim81\\ag.exe"
    "let g:Rg_Path = "$VIM."\\vim81\\rg.exe"
endif
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
    " nnoremap <silent> <C-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
    " nnoremap <silent> <C-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
    " nnoremap <silent> <C-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>
    " nnoremap <silent> <C-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
    nnoremap <silent> <M-n> :call smooth_scroll#down(&scroll, 0, 2)<CR>
    nnoremap <silent> <M-m> :call smooth_scroll#up(&scroll, 0, 2)<CR>
    nnoremap <silent> <M-j> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>
    nnoremap <silent> <M-k> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
" }}}

" expand-region {{{ 快速块选择
    Plug 'terryma/vim-expand-region'
    nmap <leader>ee <Plug>(expand_region_expand)
    nmap <leader>es <Plug>(expand_region_shrink)
    vmap <leader>ee <Plug>(expand_region_expand)
    vmap <leader>es <Plug>(expand_region_shrink)
" }}}

" FastFold {{{ 更新折叠
    Plug 'Konfekt/FastFold'
    nmap zu <Plug>(FastFoldUpdate)
    let g:fastfold_savehook = 0         " 只允许手动更新folds
    "let g:fastfold_fold_command_suffixes =  ['x','X','a','A','o','O','c','C']
    "let g:fastfold_fold_movement_commands = [']z', '[z', 'zj', 'zk']
                                        " 允许指定的命令更新folds
" }}}

" }}}

" 界面管理类
" {{{
" theme {{{ Vim主题
    Plug 'morhetz/gruvbox'
    set rtp+=$VimPluginPath/bundle/gruvbox/
    let g:gruvbox_contrast_dark='medium'" 选项：dark, medium, soft

    Plug 'junegunn/seoul256.vim'
    set rtp+=$VimPluginPath/bundle/seoul256.vim/
    let g:seoul256_background=236       " 233(暗) ~ 239(亮)
    let g:seoul256_light_background=256 " 252(暗) ~ 256(亮)

    set background=dark
    colorscheme seoul256
" }}}

" air-line {{{ 状态栏
    Plug 'vim-airline/vim-airline'
    "Plug 'vim-airline/vim-airline-themes'
if IsVim()
    set renderoptions=                  " 此设置使airline正常显示unicode字符
endif
    let g:airline_powerline_fonts = 1
    let g:airline#extensions#tabline#enabled = 1
    "let g:airline_theme='cool'
    let g:airline_theme='gruvbox'
    "                   "
    let g:airline_left_sep = ""
    let g:airline_left_alt_sep = ""
    let g:airline_right_sep = ""
    let g:airline_right_alt_sep = ""

    " 添加插件集成: ctrlspace, ale, ycm
    let g:airline#extensions#ctrlspace#enabled = 1
    let g:airline#extensions#ale#enabled = 1
    "let g:airline#extensions#ycm#enabled = 1
    "let g:airline#extensions#ycm#error_symbol = '✘:'
    "let g:airline#extensions#ycm#warning_symbol = '►:'
if IsLinux()
    "Plug 'edkolev/tmuxline.vim'
    "let g:airline#extensions#tmuxline#enalbed = 1
    "let g:airline#extensions#tmuxline#snapshot_file = "~/.tmux-status.conf"
endif
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
    nnoremap <leader>t\ :IndentLinesToggle<CR>
" }}}

" goyo {{{ 小屏浏览
    Plug 'junegunn/goyo.vim'
    nnoremap <leader>ts :Goyo<CR>
" }}}

" ctrl-space {{{ buffer管理
    " h,o,l,w,b,/,? 对应于 buffer,file,tab,workspace,bookmark,search,help
    Plug 'yehuohan/vim-ctrlspace'
    set hidden                          " 允许在未保存文件时切换buffer
    let g:CtrlSpaceCacheDir = $VimPluginPath
    let g:CtrlSpaceSetDefaultMapping = 1
    let g:CtrlSpaceProjectRootMarkers = [
         \ ".git", ".hg", ".svn", ".bzr", "_darcs", "CVS"]
                                        " Project root markers
    let g:CtrlSpaceSearchTiming = 50
    let g:CtrlSpaceStatuslineFunction = "airline#extensions#ctrlspace#statusline()"
    let g:CtrlSpaceSymbols = { "CS": "⌘"}
    let g:CtrlSpaceGlobCommand = 'ag -l --nocolor -g ""'
    " 切换按键
    nnoremap <C-Space> :CtrlSpace<CR>
    inoremap <C-Space> <Esc>:CtrlSpace<CR>
" }}}

" Pop Selection {{{ 弹出选项
    Plug 'yehuohan/popset'
    highlight link PopsetSelected Search
    let g:Popset_CompleteAll = 0
    let g:Popset_SelectionData = [
        \{
            \ 'opt' : ['filetype', 'ft'],
            \ 'dsr' : 'When this option is set, the FileType autocommand event is triggered.',
            \ 'lst' : ['cpp', 'c', 'python', 'vim', 'go', 'markdown', 'help', 'text',
                     \ 'sh', 'matlab', 'conf', 'make', 'javascript', 'html'],
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
                    \ 'html'       : 'Html file',
                    \},
            \ 'cmd' : 'popset#data#SetEqual',
        \},
        \{
            \ 'opt' : ['colorscheme', 'colo'],
            \ 'lst' : ['gruvbox', 'seoul256', 'seoul256-light'],
            \ 'cmd' : '',
        \},]
        " \{
        "     \ 'opt' : ['AirlineTheme'],
        "     \ 'lst' : popset#data#GetFileList($VimPluginPath.'/bundle/vim-airline-themes/autoload/airline/themes/*.vim'),
        "     \ 'cmd' : 'popset#data#SetExecute',
        " \}]
    " set option with PSet
    nnoremap <leader>so :PSet
    nnoremap <leader>sa :PSet popset<CR>
" }}}

" nerd-tree {{{ 目录树导航
    Plug 'scrooloose/nerdtree'
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
    nnoremap <leader>tE :NERDTree<CR>
" }}}

" vim-startify {{{ vim会话界面
    Plug 'mhinz/vim-startify'
    if IsLinux()
        let g:startify_bookmarks = [ {'c': '~/.vimrc'}, '~/.zshrc', '~/.config/i3/config' ]
        let g:startify_session_dir = '$VimPluginPath/sessions'
    elseif IsWin()
        let g:startify_bookmarks = [ {'c': '$VimPluginPath/../_vimrc'}, '$VimPluginPath/../vimfiles/.ycm_extra_conf.py']
        let g:startify_session_dir = '$VimPluginPath/sessions'
    elseif IsGw()
        let g:startify_session_dir = '~/.vim/sessions'
    elseif IsMac()
        let g:startify_bookmarks = [ {'c': '~/.vimrc'}, '~/.zshrc']
        let g:startify_session_dir = '$VimPluginPath/sessions'
    endif
    let g:startify_files_number = 10
    let g:startify_list_order = [
            \ ['   Sessions:']     , 'sessions'  ,
            \ ['   BookMarks:']    , 'bookmarks' ,
            \ ['   Recent Files:'] , 'files'     ,
            \ ['   Recent Dirs:']  , 'dir'       ,
            \ ['   Commands:']     , 'commands']
    let g:startify_session_before_save = ['silent! NERDTreeClose']
    nnoremap <leader>qa :SDelete! default<CR><Bar>:SSave default<CR><Bar>:qa<CR>
                                        " 先删除默认的，再保存会话，最后退出所有窗口
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
    nnoremap <leader>mc :<C-U>call signature#mark#Purge("all")<CR>
    nnoremap <leader>mx :<C-U>call signature#marker#Purge()<CR>
    nnoremap <M-d> :<C-U>call signature#mark#Goto("prev", "line", "pos")<CR>
    nnoremap <M-f> :<C-U>call signature#mark#Goto("next", "line", "pos")<CR>
" }}}

" undo {{{ 撤消历史
    Plug 'mbbill/undotree'
    nnoremap <leader>tu :UndotreeToggle<CR>
" }}}

" }}}

" 代码类
" {{{
" YouCompleteMe {{{ 自动补全
    " Completion Params: install.py安装参数
    "   --clang-completer : C-famlily，基于Clang补全，需要安装Clang
    "   --go-completer    : Go，基本Gocode/Godef补全，需要安装Go
    "   --js-completer    : Javascript，基于Tern补全，需要安装node和npm
    " Linux: 使用install.py安装
    "   先安装python-dev, python3-dev, cmake, llvm, clang
    "   "./install.py --clang-completer --go-completer --js-completer --system-libclang"
    "   ycm使用python命令指向的版本(如2.7或3.6)
    " Windows: 使用install.py安装
    "   先安装python, Cmake, VS, 7-zip
    "   "install.py --clang-completer --go-completer --js-completer --msvc 14 --build-dir <ycm_build>"
    "   自己指定vs版本，自己指定build路径，编译完成后，可以删除<ycm_build>
    "   如果已经安装了clang，可以使用--system-libclang参数，就不必再下载clang了
    Plug 'Valloric/YouCompleteMe'
    let g:ycm_global_ycm_extra_conf=$VimPluginPath.'/.ycm_extra_conf.py'
                                                                " C-family补全路径
    let g:ycm_enable_diagnostic_signs = 1                       " 开启语法检测
    let g:ycm_max_diagnostics_to_display = 30
    let g:ycm_warning_symbol = '►'                              " Warning符号
    let g:ycm_error_symbol = '✘'                                " Error符号
    let g:ycm_auto_start_csharp_server = 0                      " 禁止C#补全
    let g:ycm_cache_omnifunc = 0                                " 禁止缓存匹配项，每次都重新生成匹配项
    let g:ycm_complete_in_strings = 1                           " 开启对字符串补全
    let g:ycm_complete_in_comments = 0                          " 禁止对注释补全
    let g:ycm_collect_identifiers_from_comments_and_strings = 0 " 收集注释和字符串补全
    let g:ycm_collect_identifiers_from_tags_files = 1           " 收集标签补全
    let g:ycm_seed_identifiers_with_syntax = 1                  " 收集语法关键字补全
    let g:ycm_use_ultisnips_completer = 1                       " 收集UltiSnips补全
    let g:ycm_autoclose_preview_window_after_insertion = 1      " 自动关闭预览窗口
    let g:ycm_key_list_stop_completion = ['<C-y>']              " 关闭补全menu
    let g:ycm_key_invoke_completion = '<C-l>'                   " 显示补全内容
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
    let g:UltiSnipsSnippetsDir = $VimPluginPath . "/mySnippets"
    let g:UltiSnipsSnippetDirectories=["UltiSnips", "mySnippets"]
                                        " 自定义mySnippets合集
    let g:UltiSnipsExpandTrigger="<Tab>"
    let g:UltiSnipsListSnippets="<C-Tab>"
    let g:UltiSnipsJumpForwardTrigger="<C-j>"
    let g:UltiSnipsJumpBackwardTrigger="<C-k>"
" }}}

" ale {{{ 语法检测
    Plug 'w0rp/ale'
    " 语法引擎:
    "   VimScript : vint
    let g:ale_completion_enabled = 0    " 使能ale补全(只支持TypeScript)
    let g:ale_sign_error = '✘'
    let g:ale_sign_warning = '►'
    let g:ale_set_loclist = 1
    let g:ale_set_quickfix = 0
    let g:ale_echo_delay = 10           " 显示语文错误的延时时间
    let g:ale_lint_delay = 300          " 文本更改后的延时检测时间
    let g:ale_enabled = 1               " 可以使用ALEToggle切换
    nnoremap <leader>ta :execute "ALEToggle"<Bar>echo "AleToggle:" . g:ale_enabled<CR>
" }}}

" surround and repeat {{{ 添加包围符
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-repeat'

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
    xmap s <Plug>VSurround
    xmap S <Plug>VgSurround
" }}}

" auto-pairs {{{ 自动括号
    Plug 'jiangmiao/auto-pairs'
    let g:AutoPairsShortcutToggle=''
    let g:AutoPairsShortcutFastWrap=''
    let g:AutoPairsShortcutJump=''
    let g:AutoPairsShortcutFastBackInsert=''
    nnoremap <leader>tp :call AutoPairsToggle()<CR>
"}}}

" gutentags {{{ 工程结构查看
    Plug 'ludovicchabant/vim-gutentags'
    Plug 'skywind3000/gutentags_plus'
    let g:gutentags_project_root = ['.root', '.svn', '.git', '.project']
    "let g:gutentags_ctags_tagfile = '.tags'
    "let g:gutentags_cache_dir = $VimPluginPath."/.cache/.tags"
    let g:gutentags_modules = ['ctags', 'gtags_cscope']
    let g:gutentags_plus_nomap = 1
    noremap <silent> <leader>fcu :GutentagsUpdate<CR>
    noremap <silent> <leader>fcU :GutentagsUpdate!<CR>
    noremap <silent> <leader>fcs :GscopeFind s <C-R><C-W><CR>
    noremap <silent> <leader>fcd :GscopeFind g <C-R><C-W><CR>
    "noremap <silent> <leader>fcd :GscopeFind d <C-R><C-W><CR>
    noremap <silent> <leader>fcc :GscopeFind c <C-R><C-W><CR>
    "noremap <silent> <leader>fct :GscopeFind t <C-R><C-W><CR>
    "noremap <silent> <leader>fce :GscopeFind e <C-R><C-W><CR>
    noremap <silent> <leader>fcf :GscopeFind f <C-R>=expand("<cfile>")<CR><CR>
    noremap <silent> <leader>fci :GscopeFind i <C-R>=expand("<cfile>")<CR><CR>
    noremap <silent> <leader>fca :GscopeFind a <C-R><C-W><CR>
" }}}

" tagbar {{{ 代码结构查看
    Plug 'majutsushi/tagbar'
    if IsLinux()
        let g:tagbar_ctags_bin='/usr/bin/ctags'
    elseif IsWin()
        let g:tagbar_ctags_bin=$VIM."\\vim81\\ctags.exe"
    endif                               " 设置ctags路径，需要安装ctags
    let g:tagbar_width=30
    let g:tagbar_map_showproto=''       " 取消tagbar对<Space>的占用
    nnoremap <leader>tt :TagbarToggle<CR>
                                        " 可以 ctags -R 命令自行生成tags
" }}}

" nerd-commenter {{{ 批量注释
    Plug 'scrooloose/nerdcommenter'
    let g:NERDCreateDefaultMappings = 1
    let g:NERDSpaceDelims = 0           " 在Comment后添加Space
    nmap <leader>cc <Plug>NERDCommenterComment
    nmap <leader>cm <Plug>NERDCommenterMinimal
    nmap <leader>cs <Plug>NERDCommenterSexy
    " nmap <leader>cb <Plug>NERDCommenterAlignBoth  " 在vimrc中nmap有问题
    nmap <leader>cl <Plug>NERDCommenterAlignLeft
    nmap <leader>ci <Plug>NERDCommenterInvert
    nmap <leader>cy <Plug>NERDCommenterYank
    nmap <leader>ce <Plug>NERDCommenterToEOL
    nmap <leader>ca <Plug>NERDCommenterAppend
    nmap <leader>cA <Plug>NERDCommenterAltDelims
    nmap <leader>cu <Plug>NERDCommenterUncomment
" }}}

" file switch {{{ c/c++文件切换
    Plug 'derekwyatt/vim-fswitch'
    nnoremap <silent> <leader>fh :FSHere<CR>
    let g:fsnonewfiles="on"
" }}}

" AsyncRun {{{ 导步运行程序
    Plug 'skywind3000/asyncrun.vim'
    if IsWin()
        let g:asyncrun_encs = 'cp936'   " 即'gbk'编码
    endif
    nnoremap <leader>rr :AsyncRun
    nnoremap <leader>rs :AsyncStop<CR>

augroup vimrc
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
    "nmap <leader>ht <Plug>(quickhl-tag-toggle)
    "nmap <leader>hc <Plug>(quickhl-manual-clear)
    "vmap <leader>hc <Plug>(quickhl-manual-clear)
    nnoremap <leader>hc :call quickhl#manual#clear_this('n')<CR>
    vnoremap <leader>hc :call quickhl#manual#clear_this('v')<CR>
    nmap <leader>hr <Plug>(quickhl-manual-reset)

    nnoremap <leader>th :QuickhlManualLockWindowToggle<CR>
" }}}

" }}}

" 软件辅助类
" {{{
" vimcdoc {{{ 中文帮助文档
    Plug 'vimcn/vimcdoc',{'branch' : 'release'}
" }}}

" MarkDown {{{
    Plug 'gabrielelana/vim-markdown'
    let g:markdown_include_jekyll_support = 0
    let g:markdown_enable_mappings = 0
    let g:markdown_enable_spell_checking = 0
    let g:markdown_enable_folding = 1   " 感觉MarkDown折叠引起卡顿时，关闭此项
    let g:markdown_enable_conceal = 1   " 在Vim中显示MarkDown预览

    Plug 'iamcco/mathjax-support-for-mkdp'
    Plug 'iamcco/markdown-preview.vim'
    let g:mkdp_path_to_chrome = s:path_browser
    let g:mkdp_auto_start = 0
    let g:mkdp_auto_close = 1
    let g:mkdp_refresh_slow = 0         " 即时预览MarkDown
    let g:mkdp_command_for_global = 0   " 只有markdown文件可以预览
    nnoremap <leader>vm :call PreViewMarkdown()<CR>
    nnoremap <leader>tb :call ToggleBrowserPath()<CR>
    function! PreViewMarkdown() abort
        if exists(':MarkdownPreviewStop')
            MarkdownPreviewStop
            echo "MarkdownPreviewStop"
        else
            MarkdownPreview
            echo "MarkdownPreview"
        endif
    endfunction
    function! ToggleBrowserPath()
        if s:path_browser ==# s:path_browser_firefox
            let s:path_browser = s:path_browser_chrome
        else
            let s:path_browser = s:path_browser_firefox
        endif
        let g:mkdp_path_to_chrome = s:path_browser
        echo 'Browser Path: ' . s:path_browser
    endfunction
" }}}

" reStructruedText {{{
if !(IsWin() && IsNVim())
    " 需要安装 https://github.com/Rykka/instant-rst.py
    Plug 'Rykka/riv.vim'
    Plug 'Rykka/InstantRst'
    let g:instant_rst_browser = s:path_browser
if IsWin()
    " 需要安装 https://github.com/mgedmin/restview
    nnoremap <leader>vr :execute ":AsyncRun restview " . expand("%:p:t")<Bar>cclose<CR>
else
    nnoremap <leader>vr :call PreViewRst()<CR>
endif
    function! PreViewRst() abort
        if g:_instant_rst_daemon_started
            StopInstantRst
            echo "StopInstantRst"
        else
            InstantRst
        endif
    endfunction
endif
" }}}

" open-browser.vim {{{ 浏览器相关
    Plug 'tyru/open-browser.vim'
    "nmap <leader>bu <Plug>(openbrowser-open)
    "vmap <leader>bu <Plug>(openbrowser-open)
    "nmap <leader>bw <Plug>(openbrowser-search)
    "vmap <leader>bw <Plug>(openbrowser-search)
    nmap <leader>bs <Plug>(openbrowser-smart-search)
    vmap <leader>bs <Plug>(openbrowser-smart-search)
    " search funtion - google, baidu, github
    function! OpenBrowserSearchInGoogle(engine, mode)
        if a:mode ==# 'n'
            execute ":OpenBrowserSearch -". a:engine . " " . expand("<cword>")
        elseif a:mode ==# 'v'
            execute ":OpenBrowserSearch -". a:engine . " " . GetSelectedContent()
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

" autoformat {{{ 代码格式化
    "Plugin 'Chiel92/vim-autoformat'
" }}}

" }}}

call plug#end()                         " required
" }}}


"===============================================================================
" User functions
"===============================================================================
" {{{
" 基本设置 {{{

" 隐藏字符显示 {{{
function! InvConceallevel()
    if &conceallevel == 0
        set conceallevel=2
        echo "conceallevel = 2"
    else
        set conceallevel=0              " 显示markdown等格式中的隐藏字符
        echo "conceallevel = 0"
    endif
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
        echo "foldcolumn = 1"
    else
        set foldcolumn=0
        echo "foldcolumn = 0"
    endif
endfunction
" }}}

" 切换显示标志列 {{{
function! InvSigncolumn()
    if &signcolumn == "auto"
        set signcolumn=no
        echo "signcolumn = no"
    else
        set signcolumn=auto
        echo "signcolumn = auto"
    endif
endfunction
" }}}

" 切换高亮 {{{
function! InvHighLight()
    if exists("g:syntax_on")
        syntax off
        echo "syntax off"
    else
        syntax on
        echo "syntax on"
    endif
endfunction
" }}}

" Linux-Fcitx输入法切换  {{{
if IsLinux()
function! LinuxFcitx2En()
    if 2 == system("fcitx-remote")
        let l:t = system("fcitx-remote -c")
    endif
endfunction
function! LinuxFcitx2Zh()
    if 1 == system("fcitx-remote")
        let l:t = system("fcitx-remote -o")
    endif
endfunction
endif
" }}}

" }}}

" 编译环境 {{{
" Set autochdir is required.
" （因为执行编译时，是以当前文件为目标文件；
" 若禁用自动切换当前目录，会导致当前编辑的文件不一定是目标文件）
set autochdir

" FUNCTION: ToggleComplileX86X64() "{{{
" 切换成x86或x64编译环境
let s:complile_type = 'x64'
function! ToggleComplileX86X64()
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

" FUNCTION: ComplileFile(argstr) {{{
" @param argstr: 想要传递的命令参数
function! ComplileFile(argstr)
    let l:ext      = expand("%:e")                  " 扩展名
    let l:filename = '"./' . expand('%:t') . '"'    " 文件名，不带路径，带扩展名
    let l:name     = '"./' . expand('%:t:r') . '"'  " 文件名，不带路径，不带扩展名
    let l:exec_str = (exists(":AsyncRun") == 2) ? ":AsyncRun " : "!"

    " 生成可执行字符串
    if 'c' ==? l:ext
    "{{{
        let l:exec_str .= 'gcc ' . a:argstr . ' -o ' . l:name . ' ' . l:filename
        let l:exec_str .= ' && ' . l:name
    "}}}
    elseif 'cpp' ==? l:ext
    "{{{
        let l:exec_str .= 'g++ -std=c++11 ' . a:argstr . ' -o ' . l:name . ' ' . l:filename
        let l:exec_str .= ' && ' . l:name
    "}}}
    elseif 'py' ==? l:ext || 'pyw' ==? l:ext
    "{{{
        let l:exec_str .= 'python ' . l:filename
        let l:exec_str .= ' ' . a:argstr
    "}}}
    elseif 'go' ==? l:ext
    "{{{
        let l:exec_str .= ' go run ' . l:filename
    "}}}
    elseif 'm' ==? l:ext
    "{{{
        let l:exec_str .= 'matlab -nosplash -nodesktop -r ' . l:name[3:-2]
    "}}}
    elseif 'sh' ==? l:ext
    "{{{
        if IsLinux() || IsGw()
            let l:exec_str .= ' ./' . l:filename
            let l:exec_str .= ' ' . a:argstr
        else
            return
        endif
    "}}}
    elseif 'bat' ==? l:ext
    "{{{
        if IsWin()
            let l:exec_str .= ' ' . l:filename
            let l:exec_str .= ' ' . a:argstr
        else
            return
        endif
    "}}}
    elseif 'html' ==? l:ext
    "{{{
        let l:exec_str .= s:path_browser . ' ' . l:filename
    "}}}
    else
        return
    endif

    execute l:exec_str
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
    let l:dir = (a:0 >= 2) ? a:2 : "."
    let l:prj_dir      = fnamemodify(l:dir, ":p:h")
    let l:prj_dir_last = ''
    let l:prj_file     = ''

    while l:prj_dir != l:prj_dir_last
        let l:prj_file = glob(l:prj_dir . '/' . l:marker)
        if !empty(l:prj_file)
            break
        endif

        let l:prj_dir_last = l:prj_dir
        let l:prj_dir = fnamemodify(l:prj_dir, ":p:h:h")
    endwhile

    return split(l:prj_file, "\n")
endfunction
" }}}

" FUNCTION: FindProjectTarget(str, type) {{{
" @param str: 工程文件路径，如*.pro
" @param type: 工程文件类型，如qmake, make
function! FindProjectTarget(str, type)
    let l:target = '"./' . fnamemodify(a:str, ":t:r") . '"'
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

" FUNCTION: ComplileProject(str, fn) {{{
" 当找到多个Project File时，会弹出选项以供选择。
" @param str: 工程文件名，可用通配符，如*.pro
" @param fn: 编译工程文件的函数，需要采用popset插件
" @param args: 编译工程文件函数的附加参数，需要采用popset插件
function! ComplileProject(str, fn, ...)
    let l:prj = FindProjectFile(a:str)
    let l:args = (a:0 >= 1) ? a:1 : []
    if len(l:prj) == 1
        let Fn = function(a:fn)
        call Fn('', l:prj[0], l:args)
    elseif len(l:prj) > 1
        call PopSelection({
            \ 'opt' : ['Please Select your project file'],
            \ 'lst' : l:prj,
            \ 'cmd' : a:fn,
            \}, 0, l:args)
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
    let l:filename = '"./' . fnamemodify(a:sel, ":p:t") . '"'
    let l:name     = FindProjectTarget(a:sel, 'qmake')
    let l:filedir  = fnameescape(fnamemodify(a:sel, ":p:h"))
    let l:olddir   = fnameescape(getcwd())
    let l:exec_str = (exists(':AsyncRun') == 2) ? ':AsyncRun ' : '!'

    " change cwd
    execute 'lcd ' . l:filedir

    " execute shell code
    if IsLinux()
        let l:exec_str .= 'qmake ' . l:filename
        let l:exec_str .= ' && make'
    elseif IsWin()
        let l:exec_str .= s:path_qmake . " -r " . l:filename
        let l:exec_str .= ' && ' . s:path_vcvars
        let l:exec_str .= ' && ' . s:path_nmake . ' -f Makefile.Debug'
    else
        return
    endif
    if empty(a:args)
        let l:exec_str .= ' && ' . l:name
    else
        let l:exec_str .= ' ' . join(a:args)
    endif
    execute l:exec_str

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
    let l:filename = '"./' . fnamemodify(a:sel, ":p:t") . '"'
    let l:name     = FindProjectTarget(a:sel, 'make')
    let l:filedir  = fnameescape(fnamemodify(a:sel, ":p:h"))
    let l:olddir   = fnameescape(getcwd())
    let l:exec_str = (exists(':AsyncRun') == 2) ? ':AsyncRun ' : '!'

    " change cwd
    execute 'lcd ' . l:filedir

    " execute shell code
    let l:exec_str .= 'make'
    if empty(a:args)
        let l:exec_str .= ' && ' . l:name
    else
        let l:exec_str .= ' ' . join(a:args)
    endif
    execute l:exec_str

    " change back cwd
    execute 'lcd ' . l:olddir
endfunction
"}}}

" FUNCTION: ComplileProjectHtml(sopt, sel) {{{
" 用于popset的函数，用于打开index.html
" @param sopt: 参数信息，未用到，只是传入popset的函数需要
" @param sel: index.html路径
function! ComplileProjectHtml(sopt, sel)
    let l:exec_str = (exists(':AsyncRun') == 2) ? ':AsyncRun ' : '!'
    let l:exec_str .= s:path_browser . ' ' . '"' . a:sel . '"'
    execute l:exec_str
endfunction
" }}}

" Run compliler
let RC_Qmake      = function('ComplileProject', ['*.pro', 'ComplileProjectQmake'])
let RC_QmakeClean = function('ComplileProject', ['*.pro', 'ComplileProjectQmake', ['clean']])
let RC_Make       = function('ComplileProject', ['[mM]akefile', 'ComplileProjectMakefile'])
let RC_MakeClean  = function('ComplileProject', ['[mM]akefile', 'ComplileProjectMakefile', ['clean']])
let RC_Html       = function('ComplileProject', ['[iI]ndex.html', 'ComplileProjectHtml'])

" }}}

" 带参运行函数 {{{

" FUNCTION: ExecFuncInput(prompt, text, cmpl, fn, ...) {{{
" @param prompt: input的提示信息
" @param text: input的缺省输入
" @param cmpl: input的输入输入补全
" @param fn: 要运行的函数，参数为input的输入，和可变输入参数
function ExecFuncInput(prompt, text, cmpl, fn, ...)
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
    let Fn = function(a:fn, l:args)
    call Fn()
endfunction
" }}}

" FUNCTION: EditTempFile(suffix, ntab) "{{{
" 编辑临时文件
" @param suffix: 临时文件附加后缀
" @param ntab: 在新tab中打开
function EditTempFile(suffix, ntab)
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
function FuncDiffFile(filename, mode)
    if a:mode == 's'
        execute "diffsplit " . a:filename
    elseif a:mode == 'v'
        execute "vertical diffsplit " . a:filename
    endif
endfunction
" }}}

" }}}

" 查找 {{{
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

" FUNCTION: UpdateWorkingInfo(flt) {{{ 更新working信息
let s:working_root = ''
let s:working_filter = ''
function! UpdateWorkingInfo(flt)
    let l:root = input(" Where (root) to find :", "", "customlist,GetMultiFilesCompletion")
    if empty(l:root)
        return 0
    endif
    let s:working_root = fnamemodify(l:root, ':p')
    if a:flt
        let s:working_filter = input(" Which (filter) to find :", "")
    endif
    return 1
endfunction
" }}}

" FUNCTION! FindWorkingFzfFile() {{{ 工程文件查找
function! FindWorkingFzfFile()
    if empty(s:working_root)
        if !UpdateWorkingInfo(0)
            return
        endif
    endif
    silent execute(':FzfFiles ' . s:working_root)
endfunction
" }}}

" FUNCTION: FindRggrep(type, mode) {{{ 工程快速查找
let s:fkrggrep_nvmaps = [
                       \ 'fi', 'fgi', 'fri', 'fRi', 'fI', 'fgI', 'frI', 'fRI',
                       \ 'fw', 'fgw', 'frw', 'fRw', 'fW', 'fgW', 'frW', 'fRW',
                       \ 'fs', 'fgs', 'frs', 'fRs', 'fS', 'fgS', 'frS', 'fRS',
                       \ 'Fi', 'Fgi', 'Fri', 'FRi', 'FI', 'FgI', 'FrI', 'FRI',
                       \ 'Fw', 'Fgw', 'Frw', 'FRw', 'FW', 'FgW', 'FrW', 'FRW',
                       \ 'Fs', 'Fgs', 'Frs', 'FRs', 'FS', 'FgS', 'FrS', 'FRS',
                       \ ]

function! FindWorkingRggrep(type, mode)
    " {{{
    " Option: [f][grR][IiWwSs]
    " Normal Mode: mode='n'
    " i : find input
    " w : find word
    " s : find word with boundaries
    "
    " Visual Mode: mode='v'
    " i : find input    with selected
    " w : find visual   with selected
    " s : find selected with boundaries
    "
    " LowerCase: [iws] find in ignorecase
    " UpperCase: [IWS] find in case match
    "
    " Working:
    " g : find with inputing path
    " r : find with working root and filter
    " R : find with inputing working root and filter
    " F : find with no regexp match
    " }}}

    let l:command = ":Rg"
    let l:options = ""
    let l:pattern = ""
    let l:location = "%"

    " 设置查找内容
    if a:mode ==# 'n'
        if a:type =~? 'i'
            let l:pattern = input(' What to find :')
        elseif a:type =~? '[ws]'
            let l:pattern = expand('<cword>')
        endif
    elseif a:mode ==# 'v'
        let l:selected = GetSelectedContent()
        if a:type =~? 'i'
            let l:pattern = input(' What to find :', l:selected)
        elseif a:type =~? '[ws]'
            let l:pattern = l:selected
        endif
    endif
    if empty(l:pattern) | return | endif

    " 设置查找范围
    if a:type =~# 'g'
        let l:location = input(" Where to find :", "", "customlist,GetMultiFilesCompletion")
    elseif a:type =~# 'R'
        if !UpdateWorkingInfo(1) | return | endif
        let l:location = s:working_root
    elseif a:type =~# 'r'
        if empty(s:working_root)
            if !UpdateWorkingInfo(1) | return | endif
        endif
        let l:location = s:working_root
    endif
    if empty(l:location) | return | endif

    " 设置查找选项
    if a:type =~? 's'     | let l:options .= "-w " | endif
    if a:type =~# '[iws]' | let l:options .= "-i " | endif
    if !empty(s:working_filter)
        let l:options .= '-g "*.{' . s:working_filter . '}" '
    endif
    if a:type =~# 'F'
        let l:options .= "-F"
    endif

    " 使用Rg查找
    silent execute(l:command . ' ' . l:pattern . ' ' . l:location . ' ' . l:options)
endfunction
" }}}

if IsNVim()
" FUNCTION: FindVimgrep(type, mode) {{{ 快速查找
let s:findvimgrep_nvmaps = ['vi', 'vgi', 'vI', 'vgI',
                          \ 'vw', 'vgw', 'vW', 'vgW',
                          \ 'vs', 'vgs', 'vS', 'vgS',
                          \ ]
function! FindVimgrep(type, mode)
    let l:string = ''
    let l:files = '%'
    let l:selected = ''

    " 设置查找内容
    if a:mode ==# 'n'
        if a:type =~? 'i'
            let l:string = input(' What to find :')
        elseif a:type =~? '[ws]'
            let l:string = expand('<cword>')
        endif
    elseif a:mode ==# 'v'
        let l:selected = GetSelectedContent()
        if a:type =~? 'i'
            let l:string = input(' What to find :', l:selected)
        elseif a:type =~? '[ws]'
            let l:string = l:selected
        endif
    endif
    if empty(l:string) | return | endif

    " 设置查找选项
    if a:type =~? 's'     | let l:string = '\<' . l:string . '\>' | endif
    if a:type =~# '[IWS]' | let l:string = '\C' . l:string        | endif

    " 设置查找范围
    if a:type =~# 'g'
        let l:files = input(" Where to find :", "", "customlist,GetMultiFilesCompletion")
        if empty(l:files) | return | endif
    endif

    " 使用vimgrep或lvimgrep查找
    if a:type =~# 'v'
        silent execute "vimgrep /" . l:string . "/j " . l:files
        echo "Finding..."
        if empty(getqflist())
            echo "No match: " . l:string
            return
        else
            botright copen
        endif
    elseif a:type =~# 'V'
        silent execute "lvimgrep /" . l:string . "/j " . l:files
        echo "Finding..."
        if empty(getloclist(winnr()))
            echo "No match: " . l:string
            return
        else
            botright lopen
        endif
    endif
endfunction
" }}}
endif

" }}}

" 杂项 {{{

" Quickfix预览 {{{
function! PreviewQuickfixLine()
    " location-list : 每个窗口对应一个位置列表
    " quickfix      : 整个vim对应一个quickfix
    if &filetype ==# "qf"
        let l:last_winnr = winnr()
        let l:dict = getwininfo(win_getid())
        if len(l:dict) > 0
            if get(l:dict[0], "quickfix", 0) && !get(l:dict[0], "loclist", 0)
                execute "crewind " . line(".")
            elseif get(l:dict[0], "quickfix", 0) && get(l:dict[0], "loclist", 0)
                execute "lrewind " . line(".")
            else
                return
            endif
            silent! normal! zO
            normal! zz
            execute "noautocmd " . l:last_winnr . "wincmd w"
        endif
    endif
endfunction
" }}}

" 查找Vim关键字 {{{
function! GotoKeyword(mode)
    let l:exec_str = "help "
    if a:mode ==# 'n'
        let l:word = expand("<cword>")
    elseif a:mode ==# 'v'
        let l:word = GetSelectedContent()
    endif

    " 添加关键字
    let l:exec_str .= l:word
    if IsNVim()
        " nvim用自己的帮助文件，只有英文的
        let l:exec_str .= "@en"
    endif

    silent! execute l:exec_str
endfunction
" }}}

" 去除尾部空白 {{{
function! RemoveTrailingSpace()
    let l:save = winsaveview()
    %s/\s\+$//e
    call winrestview(l:save)
endfunction
" }}}

" 最大化Window {{{
let s:is_max = 0
function! ToggleWindowZoom()
    if s:is_max
        let s:is_max = 0
        execute "normal! " . s:last_tab . "gt"
        execute "noautocmd " . s:last_winnr . "wincmd w"
        silent! execute "tabclose " . s:this_tab
    else
        let s:is_max = 1
        let s:last_winnr = winnr()
        let s:last_tab = tabpagenr()
        execute "tabedit " . expand("%")
        let s:this_tab = tabpagenr()
    endif
endfunction
" }}}

" Asd2Num切换 {{{
let s:asd2num_toggle_flg = 0
let s:asd2num_map_table={
            \ "a" : "1", "s" : "2", "d" : "3", "f" : "4", "g" : "5",
            \ "h" : "6", "j" : "7", "k" : "8", "l" : "9", ";" : "0"
            \ }
function! ToggleAsd2Num()
    if(s:asd2num_toggle_flg)
        for t in items(s:asd2num_map_table)
            execute "iunmap " . t[0]
        endfor
        let s:asd2num_toggle_flg = 0
    else
        for t in items(s:asd2num_map_table)
            execute "inoremap " . t[0]. " " . t[1]
        endfor
        let s:asd2num_toggle_flg = 1
    endif
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
    set nocompatible                    " 不兼容vi快捷键
    syntax on                           " 语法高亮
    set number                          " 显示行号
    set relativenumber                  " 显示相对行号
    set cursorline                      " 高亮当前行
    set cursorcolumn                    " 高亮当前列
    set hlsearch                        " 设置高亮显示查找到的文本
    set expandtab                       " 将Tab用Space代替，方便显示缩进标识indentLine
    set tabstop=4                       " 设置Tab键宽4个空格
    set softtabstop=4                   " 设置按<Tab>或<BS>移动的空格数
    set shiftwidth=4                    " 设置>和<命令移动宽度为4
    set nowrap                          " 默认关闭折行
    set textwidth=0                     " 关闭自动换行
    set listchars=eol:$,tab:>-,trail:~,space:.
                                        " 不可见字符显示
    set autoindent                      " 使用autoindent缩进
    set conceallevel=0                  " 显示markdown等格式中的隐藏字符
    set foldenable                      " 充许折叠
    set foldcolumn=1                    " 0~12,折叠标识列，分别用“-”和“+”而表示打开和关闭的折叠
    set foldmethod=indent               " 设置折叠，默认为缩进折叠
                                        " manual : 手工定义折叠
                                        " indent : 更多的缩进表示更高级别的折叠
                                        " expr   : 用表达式来定义折叠
                                        " syntax : 用语法高亮来定义折叠
                                        " diff   : 对没有更改的文本进行折叠
                                        " marker : 对文中的标记折叠，默认使用{{{,}}}标记
    set scrolloff=3                     " 光标上下保留的行数
    set laststatus=2                    " 一直显示状态栏
    set showcmd                         " 显示寄存器命令，宏调用命令@等
    set completeopt=menuone,preview     " 补全显示设置
    set backspace=2                     " Insert模式下使用BackSpace删除
    set hidden                          " 允许在未保存文件时切换buffer
    set bufhidden=                      " 跟随hidden设置
    set nobackup                        " 不生成备份文件
    set nowritebackup                   " 覆盖文件前，不生成备份文件
    set autochdir                       " 自动切换当前目录为当前文件所在的目录
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
    set vb t_vb=                        " 关闭响铃(vb, visualbell)和可视闪铃(t_vb，即闪屏)，即normal模式时按esc会有响铃
    set helplang=cn,en                  " 优先查找中文帮助

    " 终端光标设置
    if IsTermType("xterm") || IsTermType("xterm-256color")
        " 适用于urxvt,st,xterm,gnome-termial
        " 5,6: 竖线，  3,4: 横线，  1,2: 方块
        let &t_SI = "\<Esc>[6 q"        " 进入Insert模式
        let &t_EI = "\<Esc>[2 q"        " 退出Insert模式
    endif
" }}}

" Gui
" {{{
if IsGvim()
    set guioptions-=m                   " 隐藏菜单栏
    set guioptions-=T                   " 隐藏工具栏
    set guioptions-=L                   " 隐藏左侧滚动条
    set guioptions-=r                   " 隐藏右侧滚动条
    set guioptions-=b                   " 隐藏底部滚动条
    set guioptions+=0                   " 不隐藏Tab栏

    if IsLinux()
        set lines=20
        set columns=100
        "set guifont=DejaVu\ Sans\ Mono\ 13
        set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 13.5
        set linespace=0                 " required by DejaVuSansMono for Powerline
        set guifontwide=WenQuanYi\ Micro\ Hei\ Mono\ 13.5
    elseif IsWin()
        set lines=25
        set columns=100
        "set guifont=Consolas:h13:cANSI
        set guifont=Consolas_For_Powerline:h12:cANSI
        set linespace=0                 " required by PowerlineFont
        set guifontwide=Microsoft_YaHei_Mono:h11:cGB2312
        nnoremap <leader>tf <Esc>:call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>
                                        " gvim全屏快捷键
    elseif IsMac()
        set lines=30
        set columns=100
        set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h15
    endif
endif
" }}}

" Auto Command
" {{{
augroup VimVimrc
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

    " map
    autocmd Filetype vim,help nnoremap <buffer> <S-k> :call GotoKeyword('n')<CR>
    autocmd Filetype vim,help vnoremap <buffer> <S-k> :call GotoKeyword('v')<CR>
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
    nnoremap <leader>aj <C-x>
    vnoremap <leader>aj <C-x>
    vnoremap <leader>agj g<C-x>
    nnoremap <leader>ak <C-a>
    vnoremap <leader>ak <C-a>
    vnoremap <leader>agk g<C-a>
    " 去除尾部空白
    nnoremap <leader>rt :call RemoveTrailingSpace()<CR>
    " Asd2Num
    inoremap <C-a> <Esc>:call ToggleAsd2Num()<CR>a
    " HEX编辑
    nnoremap <leader>xx :%!xxd<CR>
    nnoremap <leader>xr :%!xxd -r<CR>
" }}}

" Toggle Setting {{{
    " 显示折行
    nnoremap <leader>iw :set invwrap<CR>
    " 显示不可见字符
    nnoremap <leader>il :set invlist<CR>
    " 映射隐藏字符功能，set conceallevel直接设置没交果
    nnoremap <leader>ic :call InvConceallevel()<CR>
    " 更改透明背景
    nnoremap <leader>it :call InvTransParentBackground()<CR>
    " 切换行号类型
    nnoremap <leader>in :call InvNumberType()<CR>
    " 切换折叠列宽
    nnoremap <leader>if :call InvFoldColumeShow()<CR>
    " 切换显示标志列
    nnoremap <leader>is :call InvSigncolumn()<CR>
    " 切换高亮
    nnoremap <leader>ih :call InvHighLight()<CR>
    " Linux下自动切换中文输入法
    if IsLinux()
        "autocmd InsertLeave * call LinuxFcitx2En()
        inoremap <Esc> <Esc>:call LinuxFcitx2En()<CR>
    endif
" }}}

" Copy and paste{{{
    vnoremap <leader>y ygv
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
        execute "vnoremap <leader>'" . t          . ' "' . t . 'y'
        execute "nnoremap <leader>'" . t          . ' "' . t . 'p'
        execute "nnoremap <leader>'" . toupper(t) . ' "' . t . 'P'
    endfor
    for t in s:digital_chars
        execute "vnoremap <leader>'" . t          . ' "' . t . 'y'
        execute "nnoremap <leader>'" . t          . ' "' . t . 'p'
    endfor
    " 快速执行宏
    for t in s:lower_chars
        execute "nnoremap <leader>2" . t          . ' @' . t
    endfor
" }}}

" Move and goto{{{
    " 扩展匹配符(%)功能
if IsVim()
    packadd matchit
endif
    " 嵌套映射匹配符(%)
    nmap <S-s> %
    " 行首和行尾
    nnoremap <S-l> $
    nnoremap <S-h> ^
    vnoremap <S-l> $
    vnoremap <S-h> ^
    " 复制到行首行尾
    nnoremap y<S-l> y$
    nnoremap y<S-h> y^
    " j, k 移行
    nnoremap j gj
    nnoremap k gk
    " 折叠
    nnoremap <leader>za zA
    nnoremap <leader>zr zR
    nnoremap <leader>zm zM
    nnoremap <leader>zc zC
    nnoremap <leader>zo zO
    " 滚屏
    nnoremap <C-j> <C-e>
    nnoremap <C-k> <C-y>
    nnoremap <C-h> zh
    nnoremap <C-l> zl
    nnoremap <M-h> 16zh
    nnoremap <M-l> 16zl
    " 命令行移动
    cnoremap <M-h> <Left>
    cnoremap <M-l> <Right>
    cnoremap <M-k> <C-Left>
    cnoremap <M-j> <C-Right>
    cnoremap <M-i> <C-B>
    cnoremap <M-o> <C-E>
" }}}

" Tab, Buffer, Quickfix {{{
    " Tab切换
    nnoremap <M-i> gT
    nnoremap <M-o> gt

    " Buffer切换
    nnoremap <M-p> :bnext<CR>
    nnoremap <M-u> :bprevious<CR>
    nnoremap <leader>bn :bnext<CR>
    nnoremap <leader>bp :bprevious<CR>
    nnoremap <leader>bl :b#<Bar>execute "set buflisted"<CR>

    " 打开/关闭Quickfix
    nnoremap <leader>qo :botright copen<CR>
    nnoremap <leader>qc :cclose<CR>
    nnoremap <leader>qj :cnext<Bar>execute"silent! normal! zO"<Bar>execute"normal! zz"<CR>
    nnoremap <leader>qk :cprevious<Bar>execute"silent! normal! zO"<Bar>execute"normal! zz"<CR>
    " 打开/关闭Location-list
    nnoremap <leader>lo :botright lopen<CR>
    nnoremap <leader>lc :lclose<CR>
    nnoremap <leader>lj :lnext<Bar>execute"silent! normal! zO"<Bar>execute"normal! zz"<CR>
    nnoremap <leader>lk :lprevious<Bar>execute"silent! normal! zO"<Bar>execute"normal! zz"<CR>
    " 预览Quickfix和Location-list
    nnoremap <M-Space> :call PreviewQuickfixLine()<CR>
" }}}

" Window manager{{{
    " 分割窗口
    nnoremap <leader>ws :split<CR>
    nnoremap <leader>wv :vsplit<CR>
    " 移动焦点
    nnoremap <leader>wh <C-w>h
    nnoremap <leader>wj <C-w>j
    nnoremap <leader>wk <C-w>k
    nnoremap <leader>wl <C-w>l
    nnoremap <leader>wp <C-w>p
    nnoremap <leader>wP <C-w>P
    " 移动窗口
    nnoremap <leader>wH <C-w>H
    nnoremap <leader>wJ <C-w>J
    nnoremap <leader>wK <C-w>K
    nnoremap <leader>wL <C-w>L
    nnoremap <leader>wT <C-w>T
    nnoremap <leader>wz :call ToggleWindowZoom()<CR>
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

" Run Program {{{
    " 建立临时文件
    nnoremap <leader>ei :call ExecFuncInput('TempFile Suffix:', '', '', 'EditTempFile', 0)<CR>
    nnoremap <leader>en :call EditTempFile (''   , 0)<CR>
    nnoremap <leader>ec :call EditTempFile ('c'  , 0)<CR>
    nnoremap <leader>ea :call EditTempFile ('cpp', 0)<CR>
    nnoremap <leader>ep :call EditTempFile ('py' , 0)<CR>
    nnoremap <leader>eg :call EditTempFile ('go' , 0)<CR>
    nnoremap <leader>em :call EditTempFile ('m'  , 0)<CR>
    nnoremap <leader>eti :call ExecFuncInput('TempFile Suffix:', '', '', 'EditTempFile', 1)<CR>
    nnoremap <leader>etn :call EditTempFile(''   , 1)<CR>
    nnoremap <leader>etc :call EditTempFile('c'  , 1)<CR>
    nnoremap <leader>eta :call EditTempFile('cpp', 1)<CR>
    nnoremap <leader>etp :call EditTempFile('py' , 1)<CR>
    nnoremap <leader>etg :call EditTempFile('go' , 1)<CR>
    nnoremap <leader>etm :call EditTempFile('m'  , 1)<CR>

    " 编译运行当前文件
    nnoremap <leader>rf :call ComplileFile('')<CR>
    nnoremap <leader>rq :call RC_Qmake()<CR>
    nnoremap <leader>rm :call RC_Make()<CR>
    nnoremap <leader>rcq :call RC_QmakeClean()<CR>
    nnoremap <leader>rcm :call RC_MakeClean()<CR>
    nnoremap <leader>rh :call RC_Html()<CR>
    nnoremap <leader>tc :call ToggleComplileX86X64()<CR>
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
    nnoremap <leader>ds :call ExecFuncInput('File: ', '', 'customlist,GetMultiFilesCompletion', 'FuncDiffFile', 's')<CR>
    nnoremap <leader>dv :call ExecFuncInput('File: ', '', 'customlist,GetMultiFilesCompletion', 'FuncDiffFile', 'v')<CR>
    " 比较当前文件（已经分屏）
    nnoremap <leader>dt :diffthis<CR>
    " 关闭文件比较，与diffthis互为逆命令
    nnoremap <leader>do :diffoff<CR>
    " 更新比较结果
    nnoremap <leader>du :diffupdate<CR>
    " 应用差异到别一文件，[range]<leader>dp，range默认为1行
    nnoremap <leader>dp :<C-U>execute ".,+" . string(v:count1-1) . "diffput"<CR>
    " 拉取差异到当前文件，[range]<leader>dg，range默认为1行
    nnoremap <leader>dg :<C-U>execute ".,+" . string(v:count1-1) . "diffget"<CR>
    " 下一个diff
    nnoremap <leader>dj ]c
    " 前一个diff
    nnoremap <leader>dk [c
" }}}

" Find and search{{{
    " 查找选择的内容
    vnoremap / "*y<Bar>:execute"let g:__str__=getreg('*')"<Bar>execute"/" . g:__str__<CR>
    " 查找当前光标下的内容
    nnoremap <leader>/ :execute"let g:__str__=expand(\"<cword>\")"<Bar>execute "/" . g:__str__<CR>

    " 使用FindVimgrep查找
    for item in s:fkrggrep_nvmaps
        execute "nnoremap <leader>" . item ":call FindWorkingRggrep('" . item . "', 'n')<CR>"
    endfor
    for item in s:fkrggrep_nvmaps
        execute "vnoremap <leader>" . item ":call FindWorkingRggrep('" . item . "', 'v')<CR>"
    endfor
    nnoremap <leader>ff :call FindWorkingFzfFile()<CR>
if IsNVim()
    for item in s:findvimgrep_nvmaps
        execute "nnoremap <leader>" . item ":call FindVimgrep('" . item . "', 'n')<CR>"
    endfor
    for item in s:findvimgrep_nvmaps
        execute "vnoremap <leader>" . item ":call FindVimgrep('" . item . "', 'v')<CR>"
    endfor
endif
" }}}
" }}}

