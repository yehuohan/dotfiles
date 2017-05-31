
"===============================================================================
" file   : vimrc
" brief  : configuration for vim and gvim
" e-mail : 550034086@qq.com, yehuohan@gmail.com
" author : yehuohan
"===============================================================================


"===============================================================================
" My Notes(:help index is better)
"===============================================================================
" [*]带python编译 {
" 	使用MinGw-x64，更改.mak文件：
" 	ARCH=i686								- 使用32位，python也使用32位
" 	CC := $(CROSS_COMPILE)gcc -m32			- 32位编绎
" 	CXX := $(CROSS_COMPILE)g++ -m32			- 32位编绎
" 	WINDRES := windres --target=pe-i386		- 资源文件添加i386编绎
"	若全部使用64位，则同样更改参数即可
"}
"
" [*]替换字符串{
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
"	:s/"\([A-J]\)"/"Group \1"/
"		将"X" 替换成 "Group X"，其中X可为A-J，\( \)表示后面用\1引用()的内容
"	:s/"\(.*\)"/set("\1")/
"	    将“*"替换成set("*")，其*为任意字符
"
"}



"===============================================================================
" Platform
"===============================================================================
silent function! IsLinux()
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction
silent function! IsWin()
    return  (has('win32') || has('win64'))
endfunction



"===============================================================================
" settings 
"===============================================================================
" UI{
    set nocompatible                    " 不兼容vi快捷键
    syntax on                           " 语法高亮
    set number                          " 显示行号
    set relativenumber                  " 显示相对行号
    set cursorline                      " 高亮当前行
    set cursorcolumn                    " 高亮当前列
    set hlsearch                        " 设置高亮显示查找到的文本
    set smartindent                     " 新行智能自动缩进
    set foldenable                      " 充许折叠
    set foldcolumn=1                    " 0~12,折叠标识列，分别用“-”和“+”而表示打开和关闭的折叠
    set foldmethod=indent               " 设置语文折叠
                                        " manual : 手工定义折叠
                                        " indent : 更多的缩进表示更高级别的折叠
                                        " expr   : 用表达式来定义折叠
                                        " syntax : 用语法高亮来定义折叠
                                        " diff   : 对没有更改的文本进行折叠
                                        " marker : 对文中的标志折叠
    set showcmd                         " 显示寄存器命令，宏调用命令@等
    set tabstop=4                       " 设置tab键宽4个空格
    set expandtab                       " 将Tab用Space代替，方便显示缩进标识indentLine
    set softtabstop=4                   " 设置显示的缩进为4,实际Tab可以不是4个格
    set shiftwidth=4                    " 设置>和<命令移动宽度为4
    set nowrap                          " 默认关闭折行
"}

" Edit{
    set bs=2                            " Insert模式下使用BackSpace删除
    set nobackup                        " 不生成备份文件
    set autochdir						" 自动切换当前目录为当前文件所在的目录
    set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
                                        " 尝试解码序列
    set encoding=utf-8                  " vim内部使用utf-8编码
    set fileformat=unix                 " 以unix格式保存文本文件，即CR作为换行符
    set ignorecase                      " 不区别大小写搜索
    set smartcase                       " 有大写字母时才区别大小写搜索
    set noerrorbells                    " 关闭错误信息响铃
    set vb t_vb=                        " 关闭响铃(如normal模式时按esc会有响铃)

    if IsWin()
        let $HOME=$VIM                  " windows下将HOME设置VIM的安装路径
        execute "cd $HOME" 
        " 未打开文件时，切换到HOME目录
    endif
    if IsLinux()
        let $MyVimPath="~/.vim"         " vim插件路径
    elseif IsWin()
        let $MyVimPath=$VIM."\\vimfiles"
    endif
"}

" Vim-Gui{
    if has("gui_running")
        set guioptions-=m               " 隐藏菜单栏
        set guioptions-=T               " 隐藏工具栏
        set guioptions-=L               " 隐藏左侧滚动条
        set guioptions-=r               " 隐藏右侧滚动条
        set guioptions-=b               " 隐藏底部滚动条
        set guioptions+=0               " 不隐藏Tab栏

        au GuiEnter * set t_vb=         " 关闭闪屏(关闭声音后，会用闪屏提示)

        if IsLinux()
            "set guifont=Courier\ 10\ Pitch\ 11	
            set set guifont=Ubuntu\ Mono\ 14
        elseif IsWin()
            set guifont=cousine:h12
            "set guifont=Consolas:h12
            map <F11> <esc>:call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>
                                        " gvim全屏快捷键
        endif
    endif
"}



"===============================================================================
" KeyMap 
" - Normal模式下使用<leader>代替<C-?>,<S-?>,<A-?>，
" - Insert模式下map带ctrl,shift,alt的快捷键
" - 尽量不改变vim原有键位的功能定义
" - 尽量一只手不同时按两个键
" - 建议调换Esc和CapsLock键
"===============================================================================

" 使用Space作为leader
" Space只在Normal或Command或Visual模式下map，不适在Insert模式下map
let mapleader="\<space>"            

" map语句后别注释，也别留任何空格
" 特殊键
nnoremap ; :
vnoremap ; :

" 基本插入
nnoremap <leader>a A

" 大小写转换
nnoremap <leader>u ~
vnoremap <leader>u ~

" 快速选择和矩形选择
nnoremap vv <C-v>

" wrap and fold{
    " <leader>i? for vim "set inv?" command
    nnoremap <leader>iw :set invwrap<CR>
    nnoremap <leader>zr zR
    nnoremap <leader>zm zM
"}

" copy{
    vnoremap <C-c> "+y
    nnoremap <C-v> "+p
    inoremap <C-v> <esc>"+pi
    nnoremap <leader>p "0p
"}

" move and goto{
    nnoremap <S-s> %
    nnoremap <S-l> $
    nnoremap <S-h> ^
    vnoremap <S-l> $
    vnoremap <S-h> ^
    nnoremap y<S-l> y$
    nnoremap y<S-h> y^
    nnoremap <C-j> <C-e>
    nnoremap <C-k> <C-y>
"}

" tab and buffer switch{
    noremap <C-h> gT
    noremap <C-l> gt
    nnoremap <leader>bn :bn<CR>
    nnoremap <leader>bp :bp<CR>
    nnoremap <leader>bl :b#<CR>
"}

" surrounding with words{
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
"}

" window manager{
    " window-command

    " split
    nnoremap <leader>ws :split<CR>
    nnoremap <leader>wv :vsplit<CR>

    " move focus
    nnoremap <leader>wh <C-w>h
    nnoremap <leader>wj <C-w>j
    nnoremap <leader>wk <C-w>k
    nnoremap <leader>wl <C-w>l
    nnoremap <leader>wp <C-w>p

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
"}

" find and search{
    " find-search

    " /\<the\> : can match chars in "for the vim", but can not match chars in "there"
    " /the     : can match chars in "for the vim" and also in "there"
    " search selected
    vnoremap / "9y<bar>:execute"let g:__str__=getreg('9')"<bar>execute"/" . g:__str__<CR>

    " vimgrep what input or selected
    nnoremap <leader>/ :execute"let g:__str__=input('/')"<bar>execute "vimgrep /" . g:__str__ . "/j %"<bar>copen<CR>
    vnoremap <leader>/ "9y<bar>:execute"let g:__str__=getreg('9')"<bar>execute "vimgrep /" . g:__str__ . "/j %"<bar>copen<CR>
    " find word with vimgrep
    nnoremap <leader>fw :execute"let g:__str__=expand(\"<cword>\")"<bar>execute "vimgrep /\\<" . g:__str__ . "\\>/j %"<bar>copen<CR>
"}

" F5 map{
    " compliling and running
    nmap <F5> <esc>:call F5RunFile()<CR>
    function F5RunFile()
        let l:ext=expand("%:e")                     " 扩展名
    if IsLinux()
        let l:filename="\"".expand("./%:t")."\""    " 文件名，不带路径，带扩展名 
        let l:name="\"".expand("./%:t:r")."\""      " 文件名，不带路径，不带扩展名
    elseif IsWin()
        let l:filename="\"".expand("%:t")."\""      " 文件名，不带路径，带扩展名 
        let l:name="\"".expand("%:t:r")."\""        " 文件名，不带路径，不带扩展名
    endif
        " 先切换目录
        exec "cd %:h"
        if "c" == l:ext
            " c
            execute "!gcc -o ".l:name." ".l:filename." && ".l:name
        elseif "cpp" == l:ext
            " c++
            execute "!g++ -o ".l:name." ".l:filename." && ".l:name
        elseif "py" == l:ext || "pyw" == l:ext
            " python
            execute "!python ".l:filename
        endif
    endfunction
"}



"===============================================================================
" Vundel and Settings
" - 插件设置全写在Plugin下
" - 安键map写在每个Plugin的最后
"===============================================================================

set nocompatible						" be iMproved, required
filetype off							" required

set rtp+=$MyVimPath                     " add .vim or vimfiles to runtime path
set rtp+=$MyVimPath/bundle/Vundle.vim/  " set the runtime path to include Vundle and initialize
call vundle#begin($MyVimPath."/bundle")	" alternatively, pass a path where Vundle should install plugins
                                        " call vundle#begin('~/some/path/here')
" user plugins 
Plugin 'VundleVim/Vundle.vim'			" let Vundle manage Vundle, required


" asd2num {
    " asd数字输入
    Plugin 'yehuohan/asd2num'
    inoremap <C-a> <esc>:Asd2NumToggle<CR>a
"}

" nerd-tree{
    " 目录树导航
    Plugin 'scrooloose/nerdtree'			
    " <leader>t? for Plugins toggle
    noremap <leader>te :NERDTreeToggle<CR>
"}

" taglist{
    " 代码结构预览
    Plugin 'vim-scripts/taglist.vim'
    if IsLinux()
        let Tlist_Ctags_Cmd='/usr/bin/ctags'
    elseif IsWin()
        let Tlist_Ctags_Cmd="C:\\MyApps\\Vim\\vim80\\ctags.exe"
    endif                                   " 设置ctags路径，需要apt-get install ctags
    let Tlist_Show_One_File=1               " 不同时显示多个文件的tag，只显示当前文件
    let Tlist_WinWidth = 30                 " 设置taglist的宽度
    let Tlist_Exit_OnlyWindow=1             " 如果taglist窗口是最后一个窗口，则退出vim
    let Tlist_Use_Right_Window=1            " 在右侧窗口中显示taglist窗口
    noremap <leader>tt :TlistToggle<CR>     " 可以 ctags -R 命令自行生成tags
"}

" YouCompleteMe{
    " 自动补全
    " Linux: 
    "   install python-dev, python3-dev, cmake
    "   ./install.py --clang-completer
    " Windows: 
    "   install python, Cmake, VS, 7-zip
    "   install.py --clang-completer --msvc 14 --build-dir <dir>
    "   自己指定vs版本，自己指定build路径
    Plugin 'Valloric/YouCompleteMe'			
    let g:ycm_global_ycm_extra_conf=$MyVimPath.'/.ycm_extra_conf.py'
    let g:ycm_seed_identifiers_with_syntax = 1  " 开启语法关键字补全
    let g:ycm_warning_symbol = 'W:'             " warning符号
    let g:ycm_error_symbol = 'E:'               " error符号
    let g:ycm_use_ultisnips_completer = 1       " query UltiSnips for completions
    let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<C-m>', '<Up>']
    let g:ycm_max_diagnostics_to_display = 30
    let g:ycm_autoclose_preview_window_after_insertion=1
                                                " 自动关闭预览窗口
    let g:ycm_cache_omnifunc = 0                " 禁止缓存匹配项，每次都重新生成匹配项
    let g:ycm_seed_identifiers_with_syntax = 1  " 语法关键字补全         
    let g:ycm_collect_identifiers_from_tags_files = 1 
                                                " 开启YCM标签补全
    nnoremap <leader>gd :YcmCompleter GoToDefinitionElseDeclaration<CR>
    nnoremap <leader>gi :YcmCompleter GoToInclude<CR>
    nnoremap <leader>gt :YcmCompleter GoTo<CR>
    noremap <F4> :YcmDiags<CR> 
    nnoremap <leader>gsd :YcmShowDetailedDiagnostic
                                                " 错误列表
"}

" ultisnips{
    " 代码片段插入
    Plugin 'SirVer/ultisnips'               " snippet insert engine
    Plugin 'honza/vim-snippets'             " snippet collection
    let g:UltiSnipsSnippetDirectories=["UltiSnips", "mySnippets"]
                                            " mySnippets is my own snippets colletrion
    let g:UltiSnipsExpandTrigger="<tab>"
    let g:UltiSnipsJumpForwardTrigger="<C-o>"
    let g:UltiSnipsJumpBackwardTrigger="<C-p>"
"}

" nerd-commenter{
    " 批量注释
    " <leader>cc for comment
    " <leader>cl/cb for comment aligned
    " <leader>cu for un-comment
    Plugin 'scrooloose/nerdcommenter'
    let g:NERDSpaceDelims = 1               " add space after comment
"}

" file switch{
    " 文件切换
    Plugin 'derekwyatt/vim-fswitch'
    nnoremap <silent> <leader>fh :FSHere<CR>
"}

" vim-over {
    " substitute preview
    Plugin 'osyo-manga/vim-over'
    nnoremap <leader>oc :OverCommandLine<CR>
"}

" tabular{
    " 代码对齐
    " /:/r2 means align right and insert 2 space before next field
    Plugin 'godlygeek/tabular'
    " align map
    vnoremap <leader>a :Tabularize /
"}

" surround and repeat{
    " add surroundings
    Plugin 'tpope/vim-surround'
    Plugin 'tpope/vim-repeat'

    " simplify the map to 2 operation
    " nmap yi ysw
    " nmap yw ysiw
    " nmap yl yss
    " nmap yL ySS
    
    " surround selected text in visual mode
    vmap s S
    vmap <leader>s gS
"}

" easy-motion{
    " 快速跳转
    Plugin 'easymotion/vim-easymotion'
    let g:EasyMotion_do_mapping = 0         " 禁止默认map
    let g:EasyMotion_smartcase = 1          " 不区分大小写
    nmap s <Plug>(easymotion-overwin-f)
    nmap <leader>s <plug>(easymotion-overwin-f2)
                                            " 跨分屏快速跳转到字母，
    nmap <leader>j <plug>(easymotion-j)
    nmap <leader>k <plug>(easymotion-k)
    nmap <leader>ww <plug>(easymotion-w)
    nmap <leader>W <plug>(easymotion-W)
    nmap <leader>bb <plug>(easymotion-b)
    nmap <leader>B <plug>(easymotion-B)
    nmap <leader>e <plug>(easymotion-e)
    nmap <leader>E <plug>(easymotion-E)
    nmap <leader>ge <plug>(easymotion-ge)
    nmap <leader>gE <plug>(easymotion-gE)
"}

" ctrl-space{
    " buffer管理
    " <h,o,l,w,b,/,?> for buffer,file,tab,workspace,bookmark,search and help
    Plugin 'vim-ctrlspace/vim-ctrlspace'
    set nocompatible
    set hidden
    let g:CtrlSpaceSetDefaultMapping = 1
    let g:CtrlSpaceDefaultMappingKey = "<C-Space>"      " 使用默认Map按键
    let g:CtrlSpaceProjectRootMarkers = [
         \ ".git", ".sln", ".pro",
         \".hg", ".svn", ".bzr", "_darcs", "CVS"]       " Project root markers
    " 更改配色
    hi link CtrlSpaceNormal   Special
    hi link CtrlSpaceSelected Title
    hi link CtrlSpaceSearch   Search
    hi link CtrlSpaceStatus   StatusLine
"}

" incsearch{
    " 查找增强
    Plugin 'haya14busa/incsearch.vim'
    Plugin 'haya14busa/incsearch-fuzzy.vim'

    let g:incsearch#auto_nohlsearch = 1
    xmap <tab> <Over>(incsearch-next) 
    xmap <S-tab> <Over>(incsearch-prev)
    xmap <C-j> <Over>(incsearch-scroll-f)
    xmap <c-k> <Over>(incsearch-scroll-b)
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
"}

" smooth-scroll{
    " 平滑滚动
    Plugin 'terryma/vim-smooth-scroll'
    noremap <silent> <C-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
    noremap <silent> <C-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
    noremap <silent> <C-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
    noremap <silent> <C-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>
"}

" session{
    " 会话保存
    Plugin 'xolox/vim-misc'
    Plugin 'xolox/vim-session'
    let g:session_autosave='no'             " 自动保存会话窗口
    let g:session_autoload='yes'            " 直接打开vim，自动加载default.vim
    noremap <leader>qa :SaveSession!<CR>:qa<CR>
                                            " 关闭所有，且先保存会话
"}

" indent-line{
    " 显示缩进标识
    Plugin 'Yggdroot/indentLine'			
    "let g:indentLine_char = '|'            " 设置标识符样式
    let g:indentLinet_color_term=200        " 设置标识符颜色
    nnoremap <leader>t\ :IndentLinesToggle<CR>
"}

" new-railscasts-theme{
    " 使用主题
    set rtp+=$MyVimPath/bundle/new-railscasts-theme/
    Plugin 'carakan/new-railscasts-theme'
    colorscheme new-railscasts          
    hi CursorLine   cterm=NONE ctermbg=black ctermfg=gray guibg=black guifg=NONE
    hi CursorColumn cterm=NONE ctermbg=black ctermfg=gray guibg=black guifg=NONE
    hi Search term=reverse ctermfg=white ctermbg=blue guifg=white guibg=#072f95
                                        " 设定高亮行列的颜色
                                        " cterm:彩色终端，gui:Gvim窗口，fg:前景色，bg:背景色
"}

" air-line{
    " 状态栏美观
    Plugin 'vim-airline/vim-airline'
    set laststatus=2
    let g:airline#extensions#ctrlspace#enabled = 1      " support for ctrlspace integration
    let g:CtrlSpaceStatuslineFunction = "airline#extensions#ctrlspace#statusline()" 
    let g:airline#extensions#ycm#enabled = 1            " support for YCM integration
    let g:airline#extensions#ycm#error_symbol = 'E:'
    let g:airline#extensions#ycm#warning_symbol = 'W:'
"}

" rainbow{
    " 彩色括号
    Plugin 'luochen1990/rainbow'
    let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
    nnoremap <leader>tr :RainbowToggle<CR>
"}

" markdown-preview{
    "Plugin 'iamcco/mathjax-support-for-mkdp'
    Plugin 'iamcco/markdown-preview.vim'
    if IsWin()
        let g:mkdp_path_to_chrome = "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe"
    elseif IsLinux()
        let g:mkdp_path_to_chrome = ""
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
"}

call vundle#end()            " required
filetype plugin indent on    " required

" To ignore plugin indent changes, instead use:
"filetype plugin on

""""""""""""""""""""""""""""""""""""""""""""""
" Vundel使用举例，需要位于vundle#begin/end之间
"
"Plugin 'tpope/vim-fugitive'					" plugin on GitHub repo
"Plugin 'L9'									" plugin from http://vim-scripts.org/vim/scripts.html
"Plugin 'git://git.wincent.com/command-t.git'	" Git plugin not hosted on GitHub
"Plugin 'file:///home/gmarik/path/to/plugin'	" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}		" The sparkup vim script is in a subdirectory of this repo called vim.
												" Pass the path to set the runtimepath properly.
"Plugin 'ascenator/L9', {'name': 'newL9'}		" Install L9 and avoid a Naming conflict if you've already installed a
												" different version somewhere else.
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ


