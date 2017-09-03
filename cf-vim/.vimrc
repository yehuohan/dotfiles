"
"
" vimrc, one configuration for vim, gvim, neovim and neovim-qt.
" yehuohan, <550034086@qq.com>, <yehuohan@gmail.com>
"
"

"===============================================================================
" My Notes
"===============================================================================
" {{{
" Windows带python编译gvim 
" {{{
    " [x] 设置Make_cyg_ming.mak:
    " DIRECTX=yes                         - 使用DirectX
    " ARCH=i686                           - 使用32位(x86-64为64位)，python也使用32位
    " TERMINAL=yes                        - 添加terminal特性
    " CC := $(CROSS_COMPILE)gcc -m32      - 32位编绎
    " CXX := $(CROSS_COMPILE)g++ -m32     - 32位编绎
    " WINDRES := windres --target=pe-i386 - 资源文件添加i386编绎
    "
    " [x] 使用MinGw-x64:
    " mingw32-make -f Make_ming.mak gvim.exe PYTHON3=C:/Python36 DYNAMIC_PYTHON3=yes PYTHON3_VER=36
    " 若设置32位选项前编译过一次，清理一次.o文件再编译
    " 若使用64位，只需要添加Python路径和DirectX支持
    "
    " [x] 添加winpty
    " 如需要termianl特性，下载winpty，且添加到PATH路径，或直接放到gvim.exe的目录中。
    " https://github.com/rprichard/winpty，到release中下载与gvim对应的32或64位，没有类unix环境就用msvc的即可
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
" }}}

" }}}


"===============================================================================
" Platform
"===============================================================================
" {{{
" vim or nvim 
" {{{
    silent function! IsNVim()
        return has('nvim')
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
" }}}

" gui or term 
" {{{
    silent function! IsGui()
        return has("gui_running")
    endfunction
    function! IsTermType(tt)
        if &term ==? a:tt
            return 1
        else
            return 0
    endfunction
" }}}

" }}}


"===============================================================================
" Global settings
"===============================================================================
" {{{
set nocompatible                    " 不兼容vi快捷键
let mapleader="\<space>"            " 使用Space作为leader
                                    " Space只在Normal或Command或Visual模式下map，不适合在Insert模式下map
" 特殊键
nnoremap ; :
vnoremap ; :

" Path 
" {{{
    " vim插件路径统一
    if IsLinux()
        " root用户和普通用户共用vimrc
        let $VimPluginPath="/home/yehuohanxing/.vim"
    elseif IsWin()
        let $VimPluginPath="C:/MyApps/Vim/vimfiles"
        " windows下将HOME设置VIM的安装路径
        let $HOME=$VIM 
        " 未打开文件时，切换到HOME目录
        execute "cd $HOME"          
    elseif IsGw()
        let $VimPluginPath="/c/MyApps/Vim/vimfiles"
    endif
    set rtp+=$VimPluginPath                     " add .vim or vimfiles to rtp(runtimepath)
" }}}

" 键码设定 
" {{{
set timeout         " 打开映射超时检测
set ttimeout        " 打开键码超时检测
set timeoutlen=1000 " 映射超时时间为1000ms
set ttimeoutlen=70  " 键码超时时间为70ms

" 键码示例 {{{
    " 终端Alt键映射处理：如 Alt+x，实际连续发送 <esc>x 编码
    " 以下三种方法都可以使按下 Alt+x 后，执行 CmdTest 命令，但超时检测有区别
    "<1> set <M-x>=x  " 设置键码，这里的是一个字符，即<esc>的编码，不是^和[放在一起
                        " 在终端的Insert模式，按Ctrl+v再按Alt+x
    "    nnoremap <M-x> :CmdTest<CR>  " 按键码超时时间检测
    "<2> nnoremap <esc>x :CmdTest<CR> " 按映射超时时间检测
    "<3> nnoremap x  :CmdTest<CR>   " 按映射超时时间检测
" }}}

" 键码设置 {{{
if !IsNVim()
    set encoding=utf-8  " 内部内部需要使用utf-8编码
    set <M-h>=h
    set <M-j>=j
    set <M-k>=k
    set <M-l>=l
endif
" }}}

" }}}

" }}}


"===============================================================================
" User Defined functions
"===============================================================================
" {{{
" 隐藏字符显示
" {{{
function! InvConceallevel()
    if &conceallevel == 0
        set conceallevel=2
    "elseif &conceallevel == 2
    else
        set conceallevel=0                  " 显示markdown等格式中的隐藏字符
    endif
endfunction
" }}}

" 透明背影控制（需要系统本身支持透明）
" {{{
let s:inv_transparent_bg_flg = 0
function! InvTransParentBackground()
    if s:inv_transparent_bg_flg == 1
        hi Normal ctermbg=234
        let s:inv_transparent_bg_flg = 0
    else
        hi Normal ctermbg=NONE
        let s:inv_transparent_bg_flg = 1
    endif
endfunction
" }}}

" 切换显示行号
" {{{
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

" 切换显示折叠列
" {{{
function! InvFoldColumeShow()
    if &foldcolumn == 0
        set foldcolumn=1
    else
        set foldcolumn=0
    endif
endfunction
" }}}

" 编译环境函数
" {{{
function! F5ComplileFile(argstr)
    let l:ext=expand("%:e")                             " 扩展名
    let l:filename='"./' . expand('%:t') . '"'          " 文件名，不带路径，带扩展名 
    let l:name='"./' . expand('%:t:r') . '"'            " 文件名，不带路径，不带扩展名
    " 执行命令
    if "c" ==? l:ext
        " c
        execute ":AsyncRun gcc ".a:argstr." -o ".l:name." ".l:filename." && ".l:name
    elseif "cpp" ==? l:ext
        " c++
        execute ":AsyncRun g++ -std=c++11 ".a:argstr." -o ".l:name." ".l:filename." && ".l:name
    elseif "py" ==? l:ext || "pyw" ==? l:ext
        " python
        execute ":AsyncRun python ".l:filename
    elseif "m" ==? l:ext
        execute ":AsyncRun matlab -nosplash -nodesktop -r " . l:name[3:-2]
    endif
endfunction
" }}}

" linux-fcitx输入法切换 
" {{{
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
" }}}

" }}}


"===============================================================================
" Plug and Settings
"===============================================================================
" {{{
call plug#begin($VimPluginPath."/bundle")   " alternatively, pass a path where install plugins

" user plugins 

" 基本编辑类 
" {{{
" asd2num {{{ asd数字输入
    Plug 'yehuohan/asd2num'
    inoremap <C-a> <esc>:Asd2NumToggle<CR>a
" }}}

" easy-motion {{{ 快速跳转
    Plug 'easymotion/vim-easymotion'
    let g:EasyMotion_do_mapping = 0         " 禁止默认map
    let g:EasyMotion_smartcase = 1          " 不区分大小写
    nmap s <Plug>(easymotion-overwin-f)
    nmap <leader>ms <plug>(easymotion-overwin-f2)
                                            " 跨分屏快速跳转到字母，
    nmap <leader>j <plug>(easymotion-j)
    nmap <leader>k <plug>(easymotion-k)
    nmap <leader>mw <plug>(easymotion-w)
    nmap <leader>mb <plug>(easymotion-b)
    nmap <leader>me <plug>(easymotion-e)
    nmap <leader>mg <plug>(easymotion-ge)
    " nmap <leader>W <plug>(easymotion-W)
    " nmap <leader>B <plug>(easymotion-B)
    " nmap <leader>E <plug>(easymotion-E)
    " nmap <leader>gE <plug>(easymotion-gE)
    "
" }}}

" multiple-cursors {{{ 多光标编辑
    Plug 'terryma/vim-multiple-cursors'
    let g:multi_cursor_use_default_mapping=0 " 取消默认按键
    let g:multi_cursor_start_key='<C-n>'     " 进入Multiple-cursors Model
                                             " 自己选定区域（包括矩形选区），或自动选择当前光标<cword>
    let g:multi_cursor_next_key='<C-n>'
    let g:multi_cursor_prev_key='<C-p>'
    let g:multi_cursor_skip_key='<C-x>'
    let g:multi_cursor_quit_key='<esc>'
" }}}

" vim-over {{{ 替换预览
    " substitute preview
    Plug 'osyo-manga/vim-over'
    nnoremap <leader>sp :OverCommandLine<CR>
" }}}

" incsearch {{{ 查找增强
    Plug 'haya14busa/incsearch.vim'
    Plug 'haya14busa/incsearch-fuzzy.vim'
    let g:incsearch#auto_nohlsearch = 1

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
    nmap *  <Plug>(incsearch-nohl-*)
    nmap #  <Plug>(incsearch-nohl-#)
    nmap <leader>8  <Plug>(incsearch-nohl-*)
    nmap <leader>3  <Plug>(incsearch-nohl-#)
    nmap g* <Plug>(incsearch-nohl-g*)
    nmap g# <Plug>(incsearch-nohl-g#)
" }}}

" fzf {{{ 模糊查找
    " linux下直接pacman -S fzf
    " win下载fzf.exe放入bundle/fzf/bin/下
    if IsWin()
        Plug 'junegunn/fzf'
    endif
    Plug 'junegunn/fzf.vim'
" }}}

" surround and repeat {{{ 添加包围符
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-repeat'

    " simplify the map
    nmap <leader>sw ysiw
    nmap <leader>si ysw
    nmap <leader>sl yss
    nmap <leader>sL ySS
    " surround selected text in visual mode
    vmap s S
    vmap <leader>s gS
" }}}

" tabular {{{ 字符对齐
    " /:/r2 means align right and insert 2 space before next field
    Plug 'godlygeek/tabular'
    " align map
    vnoremap <leader>a :Tabularize /
    nnoremap <leader>a :Tabularize /
" }}}

" undo {{{ 撤消历史
    Plug 'mbbill/undotree'
    nnoremap <leader>tu :UndotreeToggle<CR>
" }}}

" smooth-scroll {{{ 平滑滚动
    Plug 'terryma/vim-smooth-scroll'
    nnoremap <silent> <C-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
    nnoremap <silent> <C-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
    " nnoremap <silent> <C-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>
    " nnoremap <silent> <C-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
    nnoremap <silent> <M-j> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>
    nnoremap <silent> <M-k> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
" }}}

" expand-region {{{ 快速块选择
    Plug 'terryma/vim-expand-region'
    nmap <leader>ee <Plug>(expand_region_expand)
    nmap <leader>es <Plug>(expand_region_shrink)
    vmap <leader>ee <Plug>(expand_region_expand)
    vmap <leader>es <Plug>(expand_region_shrink)
    nmap <C-l> <Plug>(expand_region_expand)
    nmap <C-h> <Plug>(expand_region_shrink)
    vmap <C-l> <Plug>(expand_region_expand)
    vmap <C-h> <Plug>(expand_region_shrink)
" }}}

" }}}

" 界面管理类
" {{{
" theme {{{ 主题
    " gruvbox主题
    Plug 'morhetz/gruvbox'
    set rtp+=$VimPluginPath/bundle/gruvbox/
    colorscheme gruvbox 
    set background=dark                     " dark or light mode
    let g:gruvbox_contrast_dark='medium'    " dark, medium or soft
" }}}

" air-line {{{ 状态栏
    Plug 'vim-airline/vim-airline'
    set laststatus=2
    let g:airline#extensions#ctrlspace#enabled = 1      " support for ctrlspace integration
    let g:CtrlSpaceStatuslineFunction = "airline#extensions#ctrlspace#statusline()" 
    let g:airline#extensions#ycm#enabled = 1            " support for YCM integration
    let g:airline#extensions#ycm#error_symbol = 'E:'
    let g:airline#extensions#ycm#warning_symbol = 'W:'
" }}}

" rainbow {{{ 彩色括号
    Plug 'luochen1990/rainbow'
    let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
    nnoremap <leader>tr :RainbowToggle<CR>
" }}}

" indent-line {{{ 显示缩进标识
    Plug 'Yggdroot/indentLine'          
    "let g:indentLine_char = '|'            " 设置标识符样式
    let g:indentLinet_color_term=200        " 设置标识符颜色
    nnoremap <leader>t\ :IndentLinesToggle<CR>
" }}}

" goyo {{{ 小屏浏览
    Plug 'junegunn/goyo.vim'
    nnoremap <leader>ts :Goyo<CR>
" }}}

" ctrl-space {{{ buffer管理
    " <h,o,l,w,b,/,?> for buffer,file,tab,workspace,bookmark,search and help
    Plug 'yehuohan/vim-ctrlspace'
    set nocompatible
    set hidden                                      " 允许在未保存文件时切换buffer
    let g:CtrlSpaceCacheDir = $VimPluginPath
    let g:CtrlSpaceSetDefaultMapping = 1
    let g:CtrlSpaceProjectRootMarkers = [
         \ ".git", ".sln", ".pro",
         \".hg", ".svn", ".bzr", "_darcs", "CVS"]   " Project root markers
    let g:CtrlSpaceSearchTiming = 50
    " 切换按键
    nnoremap <C-Space> :CtrlSpace<CR>
    inoremap <C-Space> <esc>:CtrlSpace<CR>
" }}}

" Pop Selection {{{ 弹出选项
    Plug 'yehuohan/popset'
	highlight link PopsetSelected Search
    let g:Popset_CompleteAll = 0
    let g:Popset_SelectionData = [
        \{
            \ "opt" : ["filetype", "ft"],
            \ "lst" : ["cpp", "c", "python", "vim", "markdown", "help", "text"],
            \ "dic" : {
                    \ "python" : "Python script file",
                    \ "vim"    : "Vim script file",
                    \ "help"   : "Vim help doc"
                    \},
            \ "cmd" : "popset#data#SetEqual",
        \},
        \{
            \ "opt" : ["colorscheme", "colo"],
            \ "lst" : ["gruvbox"],
            \ "dic" : {"gruvbox" : "第三方主题"},
            \ "cmd" : "",
        \}]
    " set option with PSet
    nnoremap <leader>so :PSet 
" }}}

" vim-startify {{{ vim会话界面
    Plug 'mhinz/vim-startify'
    if IsLinux()
        let g:startify_bookmarks = [ {'c': '~/.vimrc'}, '~/.zshrc', '~/.config/i3/config' ]
        let g:startify_session_dir = '$VimPluginPath/sessions'
    elseif IsWin()
        let g:startify_bookmarks = [ {'c': '$VimPluginPath/../_vimrc'}]
        let g:startify_session_dir = '$VimPluginPath/sessions'
    elseif IsGw()
        let g:startify_session_dir = '~/.vim/sessions'
    endif
    let g:startify_files_number = 10
    let g:startify_list_order = [
            \ ['   Sessions:']     , 'sessions'  ,
            \ ['   BookMarks:']    , 'bookmarks' ,
            \ ['   Recent Files:'] , 'files'     ,
            \ ['   Recent Dirs:']  , 'dir'       ,
            \ ['   Commands:']     , 'commands']
    let g:startify_session_before_save = ['silent! NERDTreeClose']
    nnoremap <leader>qa :SDelete! default<CR><bar>:SSave default<CR><bar>:qa<CR>
                                            " 先删除默认的，再保存会话，最后退出所有窗口
    nnoremap <leader>su :Startify<CR>       " start ui of vim-startify
" }}}

" }}}

" 代码类
" {{{
" nerd-tree{{{ 目录树导航
    Plug 'scrooloose/nerdtree'          
    let g:NERDTreeShowHidden=1
    let g:NERDTreeMapPreview = 'go'             " 预览打开
    let g:NERDTreeMapChangeRoot = 'cd'          " 更改根目录
    let g:NERDTreeMapChdir = 'CW'               " 更改CWD
    let g:NERDTreeMapCWD = 'CD'                 " 更改根目录为CWD
    let g:NERDTreeMapJumpNextSibling = '<C-n>'  " next sibling
    let g:NERDTreeMapJumpPrevSibling = '<C-p>'  " prev sibling
    noremap <leader>te :NERDTreeToggle<CR>

" }}}

" YouCompleteMe {{{ 自动补全
    " Linux: 
    "   install python-dev, python3-dev, cmake, llvm, clang
    "   ./install.py --clang-completer --system-libclang
    " Windows: 
    "   install python, Cmake, VS, 7-zip
    "   install.py --clang-completer --msvc 14 --build-dir <ycm_build>
    "   自己指定vs版本，自己指定build路径，编译完成后，可以删除<ycm_build>
    "   如果已经安装了clang，可以使用--system-libclang参数，就不必再下载clang了
    Plug 'Valloric/YouCompleteMe'
    let g:ycm_global_ycm_extra_conf=$VimPluginPath.'/.ycm_extra_conf.py'
    let g:ycm_enable_diagnostic_signs = 1       " 开启语法检测
    let g:ycm_max_diagnostics_to_display = 30
    let g:ycm_warning_symbol = '--'             " warning符号
    let g:ycm_error_symbol = '>>'               " error符号
    let g:ycm_seed_identifiers_with_syntax = 1  " 语法关键字补全         
    let g:ycm_collect_identifiers_from_tags_files = 1 
                                                " 开启标签补全
    let g:ycm_use_ultisnips_completer = 1       " query UltiSnips for completions
    let g:ycm_key_list_select_completion = ['<C-j>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<C-k>', '<Up>']
    let g:ycm_autoclose_preview_window_after_insertion=1
                                                " 自动关闭预览窗口
    let g:ycm_cache_omnifunc = 0                " 禁止缓存匹配项，每次都重新生成匹配项
    nnoremap <leader>gd :YcmCompleter GoToDefinitionElseDeclaration<CR>
    nnoremap <leader>gi :YcmCompleter GoToInclude<CR>
    nnoremap <leader>gt :YcmCompleter GoTo<CR>
    nnoremap <leader>gs :YcmShowDetailedDiagnostic<CR>
    noremap <F4> :YcmDiags<CR> 
                                                " 错误列表
" }}}

" ultisnips {{{ 代码片段插入
    Plug 'SirVer/ultisnips'               " snippet insert engine
    Plug 'honza/vim-snippets'             " snippet collection
    let g:UltiSnipsSnippetDirectories=["UltiSnips", "mySnippets"]
                                            " mySnippets is my own snippets collection
    let g:UltiSnipsExpandTrigger="<tab>"
    let g:UltiSnipsJumpForwardTrigger="<C-j>"
    let g:UltiSnipsJumpBackwardTrigger="<C-k>"
" }}}

" tagbar {{{ 代码结构预览
    Plug 'majutsushi/tagbar'
    if IsLinux()
        let g:tagbar_ctags_bin='/usr/bin/ctags'
    elseif IsWin()
        let g:tagbar_ctags_bin="C:\\MyApps\\Vim\\vim80\\ctags.exe"
    endif                                   " 设置ctags路径，需要apt-get install ctags
    let g:tagbar_width=30
    let g:tagbar_map_showproto=''           " 取消tagbar对<Space>的占用
    noremap <leader>tt :TagbarToggle<CR>    " 可以 ctags -R 命令自行生成tags
" }}}

" nerd-commenter {{{ 批量注释
    Plug 'scrooloose/nerdcommenter'
    let g:NERDSpaceDelims = 1               " add space after comment
    " <leader>cc for comment
    " <leader>cl/cb for comment aligned
    " <leader>cu for un-comment
" }}}

" file switch {{{ c/c++文件切换
    Plug 'derekwyatt/vim-fswitch'
    nnoremap <silent> <leader>fh :FSHere<CR>
" }}}

" AsyncRun {{{ 导步运行程序
    Plug 'skywind3000/asyncrun.vim'
    augroup vimrc
        autocmd User AsyncRunStart call asyncrun#quickfix_toggle(8, 1)
    augroup END
    nnoremap <leader>rr :AsyncRun 
    nnoremap <leader>rs :AsyncStop<CR>
" }}}

" splitjoin {{{ 行间连接与分割
    "Plug 'AndrewRadev/splitjoin.vim'
    "nnoremap <leader>gj gJ
    "nnoremap <leader>gs gS
" }}}

" }}}

" 软件辅助类
" {{{
" vimcdoc {{{ 中文帮助文档
    Plug 'vimcn/vimcdoc',{'branch' : 'release'}
" }}}

" markdown-preview {{{ MarkDown预览 
    Plug 'plasticboy/vim-markdown'
    Plug 'iamcco/mathjax-support-for-mkdp'
    Plug 'iamcco/markdown-preview.vim'
    if IsWin()
        let g:mkdp_path_to_chrome = "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe"
    elseif IsLinux()
        let g:mkdp_path_to_chrome = "/usr/bin/google-chrome"
    endif
    let g:mkdp_auto_start = 0
    let g:mkdp_auto_close = 1
    let g:mkdp_refresh_slow = 0         " update preview instant
    nnoremap <leader>tm :call MarkdownPreviewToggle()<CR>
    function! MarkdownPreviewToggle()
        if exists(':MarkdownPreviewStop')
            MarkdownPreviewStop
        else
            MarkdownPreview
        endif
    endfunction
" }}}

" qml {{{ qml高亮
    Plug 'crucerucalin/qml.vim'
" }}}

" grammarous {{{ 文字拼写检查
    "Plug 'rhysd/vim-grammarous'
    " 中文支持不好
" }}}

" vim-latex {{{
    "Plug 'vim-latex/vim-latex'
    " 暂时不用
" }}}

" }}}

if IsNVim()
" neovim gui font {{{ 字体设置   
    Plug 'equalsraf/neovim-gui-shim'
" }}}
endif

call plug#end()            " required

" }}}


"===============================================================================
" User Setting
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
    set tabstop=4                       " 设置tab键宽4个空格
    set expandtab                       " 将Tab用Space代替，方便显示缩进标识indentLine
    set softtabstop=4                   " 设置显示的缩进为4,实际Tab可以不是4个格
    set shiftwidth=4                    " 设置>和<命令移动宽度为4
    set nowrap                          " 默认关闭折行
    set listchars=eol:$,tab:>-,trail:~,space:.
                                        " 不可见字符显示
    set showcmd                         " 显示寄存器命令，宏调用命令@等
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

    set backspace=2                     " Insert模式下使用BackSpace删除
    set nobackup                        " 不生成备份文件
    set autochdir                       " 自动切换当前目录为当前文件所在的目录
    set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
                                        " 尝试解码序列
    set encoding=utf-8                  " vim内部使用utf-8编码
    set fileformat=unix                 " 以unix格式保存文本文件，即CR作为换行符
    set ignorecase                      " 不区别大小写搜索
    set smartcase                       " 有大写字母时才区别大小写搜索
    set noerrorbells                    " 关闭错误信息响铃
    set vb t_vb=                        " 关闭响铃(vb)和可视闪铃(t_vb，即闪屏)，即normal模式时按esc会有响铃
    set helplang=cn,en                  " 优先查找中文帮助

    " 终端光标设置
    if IsTermType("xterm") || IsTermType("xterm-256color")
        " compatible for urxvt,st,xterm,gnome-termial
        " 5,6: 竖线，  3,4: 横线，  1,2: 方块
        let &t_SI = "\<Esc>[6 q"        " 进入Insert模式
        let &t_EI = "\<Esc>[2 q"        " 退出Insert模式
    endif

" }}}

" Gui
" {{{
if IsGui()
    set guioptions-=m               " 隐藏菜单栏
    set guioptions-=T               " 隐藏工具栏
    set guioptions-=L               " 隐藏左侧滚动条
    set guioptions-=r               " 隐藏右侧滚动条
    set guioptions-=b               " 隐藏底部滚动条
    set guioptions+=0               " 不隐藏Tab栏

    if IsLinux()
        set lines=20
        set columns=100
        "set guifont=Ubuntu\ Mono\ 13
        set guifont=DejaVu\ Sans\ Mono\ 13
    elseif IsWin()
        set lines=25
        set columns=100
        set renderoptions=type:directx
        "set guifont=cousine:h12:cANSI
        set guifont=Consolas:h13:cANSI
        set guifontwide=Yahei_Mono:h13:cGB2312
        map <F11> <esc>:call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>
                                    " gvim全屏快捷键
    endif
endif
" }}}

" Auto Command 
" {{{
    autocmd! BufEnter *.tikz set filetype=tex
    autocmd! Filetype vim set foldmethod=marker
    autocmd! Filetype c set foldmethod=syntax
    autocmd! Filetype cpp set foldmethod=syntax
    autocmd! Filetype python set foldmethod=indent

    autocmd! GuiEnter * set t_vb=                   " 关闭可视闪铃(即闪屏)
" }}}

" }}}


"===============================================================================
" User Key-Map 
"===============================================================================
" {{{
" 基本编辑 {{{
    " Linux下自动退出中文输入法
    if IsLinux()
        "autocmd InsertLeave * call LinuxFcitx2En()
        inoremap <esc> <esc>:call LinuxFcitx2En()<CR>
    endif
    " 查找vim帮助
    if IsNVim()
        " nvim用自己的帮助文件只有英文的
        nnoremap <S-k> :exec "help " . expand("<cword>"). "@en"<CR>
        nnoremap <S-m> <S-k>
    else
        nnoremap <S-k> :exec "help " . expand("<cword>")<CR>
        " 查找man帮助（linux下可用，windows下仍是查找vim帮助）
        nnoremap <S-m> <S-k>
    endif
    " j, k 移行
    nnoremap j gj
    nnoremap k gk
    " 回退操作
    nnoremap <S-u> <C-r>
    " 大小写转换
    nnoremap <leader>u ~
    vnoremap <leader>u ~
    " 矩形选择
    nnoremap vv <C-v>
    " 折叠
    nnoremap <leader>zr zR
    nnoremap <leader>zm zM
" }}}

" Show Setting{{{
    " 显示折行
    nnoremap <leader>iw :set invwrap<CR>
    " 显示不可见字符
    nnoremap <leader>il :set invlist<CR>
    " 映射隐藏字符功能，set conceallevel直接设置没交果
    nnoremap <leader>ih :call InvConceallevel()<CR>
    " 更改透明背景
    nnoremap <leader>it :call InvTransParentBackground()<CR>
    " 切换行号类型
    nnoremap <leader>in :call InvNumberType()<CR>
    " 切换折叠列宽
    nnoremap <leader>if :call InvFoldColumeShow()<CR>
" }}}

" copy and paste{{{
    vnoremap <C-c> "+y
    nnoremap <C-v> "+p
    inoremap <C-v> <esc>"+pi
    " 粘贴通过y复制的内容
    nnoremap <leader>p "0p

    " 寄存器快速复制与粘贴
    let s:table_reg_map = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
    for t in s:table_reg_map
        execute "vnoremap <leader>'" . t . "    \"" . t . "y"
        execute "nnoremap <leader>'" . t . "    \"" . t . "p"
    endfor
" }}}

" move and goto{{{
    " 行首和行尾
    nnoremap <S-s> %
    nnoremap <S-l> $
    nnoremap <S-h> ^
    vnoremap <S-l> $
    vnoremap <S-h> ^
    " 复制到行首行尾
    nnoremap y<S-l> y$
    nnoremap y<S-h> y^

    nnoremap <C-j> <C-e>
    nnoremap <C-k> <C-y>
" }}}

" surrounding with words{{{
    " text object: ?i? or ?a?
    nnoremap <leader>i( viwxi(<esc>pa)<esc>     
    nnoremap <leader>i< viwxi<<esc>pa><esc>
    nnoremap <leader>i[ viwxi[<esc>pa]<esc>
    nnoremap <leader>i{ viwxi{<esc>pa}<esc>
    nnoremap <leader>i" viwxi"<esc>pa"<esc>
    nnoremap <leader>i' viwxi'<esc>pa'<esc>
    nnoremap <leader>i/ viwxi/*<esc>pa*/<esc>
    vnoremap <leader>i( xi()<esc>hp<esc>     
    vnoremap <leader>i< xi<><esc>hp<esc>
    vnoremap <leader>i[ xi[]<esc>hp<esc>
    vnoremap <leader>i{ xi{}<esc>hp<esc>
    vnoremap <leader>i" xi""<esc>hp<esc>
    vnoremap <leader>i' xi''<esc>hp<esc>
    vnoremap <leader>i/ xi/**/<esc>hhp<esc>
" }}}

" tab ,buffer and quickfix {{{
    " tab切换
    noremap <M-h> gT
    noremap <M-l> gt
    " buffer切换
    nnoremap <leader>bn :bn<CR>
    nnoremap <leader>bp :bp<CR>
    nnoremap <leader>bl :b#<CR>
    " quickfix打开与关闭
    nnoremap <leader>qo :copen<CR>
    nnoremap <leader>qc :cclose<CR>
" }}}

" window manager{{{
    " split
    nnoremap <leader>ws :split<CR>
    nnoremap <leader>wv :vsplit<CR>
    " move focus
    nnoremap <leader>wh <C-w>h
    nnoremap <leader>wj <C-w>j
    nnoremap <leader>wk <C-w>k
    nnoremap <leader>wl <C-w>l
    nnoremap <leader>wp <C-w>p
    nnoremap <leader>wP <C-w>P
    " move window
    nnoremap <leader>wH <C-w>H
    nnoremap <leader>wJ <C-w>J
    nnoremap <leader>wK <C-w>K
    nnoremap <leader>wL <C-w>L
    nnoremap <leader>wT <C-w>T
    " reseize window with C-up/down/left/right
    inoremap <C-up> <esc>:resize+1<CR>i
    inoremap <C-down> <esc>:resize-1<CR>i
    inoremap <C-left> <esc>:vertical resize-1<CR>i
    inoremap <C-right> <esc>:vertical resize+1<CR>i
    nnoremap <C-up> <esc>:resize+1<CR>
    nnoremap <C-down> <esc>:resize-1<CR>
    nnoremap <C-left> <esc>:vertical resize-1<CR>
    nnoremap <C-right> <esc>:vertical resize+1<CR>
    nnoremap <leader>w= <C-w>=
" }}}

" find and search{{{
    " /\<the\> : can match chars in "for the vim", but can not match chars in "there"
    " /the     : can match chars in "for the vim" and also in "there"
    " search selected
    vnoremap / "9y<bar>:execute"let g:__str__=getreg('9')"<bar>execute"/" . g:__str__<CR>

    " vimgrep what input
    nnoremap <leader>/ :execute"let g:__str__=input('/')"<bar>execute "vimgrep /" . g:__str__ . "/j %"<bar>copen<CR>
    " vimgrep what selected
    vnoremap <leader>/ "9y<bar>:execute"let g:__str__=getreg('9')"<bar>execute "vimgrep /" . g:__str__ . "/j %"<bar>copen<CR>
    " find word with vimgrep
    nnoremap <leader>fw :execute"let g:__str__=expand(\"<cword>\")"<bar>execute "vimgrep /\\<" . g:__str__ . "\\>/j %"<bar>copen<CR>
" }}}

" Run Program map{{{
    " compiling and running
    noremap <F5> <esc>:call F5ComplileFile('')<CR>
    " run with args
    nnoremap <leader>ra :execute"let g:__str__=input('Compile Args: ')"<bar>call F5ComplileFile(g:__str__)<CR>
" }}}

" File diff {{{
    " 文件比较，自动补全文件和目录
    nnoremap <leader>ds :execute "let g:__str__=input('File: ', '', 'file')"<bar> execute "diffsplit " . g:__str__<CR>
    nnoremap <leader>dv :execute "let g:__str__=input('File: ', '', 'file')"<bar> execute "vertical diffsplit " . g:__str__<CR>
    " 比较当前文件（已经分屏）
    nnoremap <leader>dt :diffthis<CR>
    " 关闭文件比较，与diffthis互为逆命令
    nnoremap <leader>do :diffoff<CR>
    " 应用差异到别一文件
    nnoremap <leader>dp :diffput<CR>
    " 拉取差异到当前文件
    nnoremap <leader>dg :diffget<CR>
    " 更新比较结果
    nnoremap <leader>du :diff<CR>
    " 下一个diff
    nnoremap <leader>dj ]c
    " 前一个diff
    nnoremap <leader>dk [c
" }}}

" }}}





