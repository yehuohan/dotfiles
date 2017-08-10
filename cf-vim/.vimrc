
"===============================================================================
" file   : vimrc
" brief  : configuration for vim and gvim
" e-mail : 550034086@qq.com, yehuohan@gmail.com
" author : yehuohan
"===============================================================================

"===============================================================================
" My Notes
"===============================================================================
" [*]带python编译 {
    " 	使用MinGw-x64，更改.mak文件：
    " 	ARCH=i686								- 使用32位，python也使用32位
    " 	CC := $(CROSS_COMPILE)gcc -m32			- 32位编绎
    " 	CXX := $(CROSS_COMPILE)g++ -m32			- 32位编绎
    " 	WINDRES := windres --target=pe-i386		- 资源文件添加i386编绎
    "	若全部使用64位，则同样更改参数即可
" }
" 查看帮助 {
    " :help       = 查看Vim帮助
    " :help index = 查看帮助列表
    " <S-k>       = 快速查看光标所在cword或选择内容的vim帮助
    " :help *@en  = 指定查看英文(en，cn即为中文)帮助
" }
" 替换字符串{
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
    "		将"X" 替换成 "Group X"，其中X可为A-J， \( \) 表示后面用 \1 引用 () 的内容
    "	:s/"\(.*\)"/set("\1")/
    "	    将“*" 替换成 set("*") ，其中 .* 为任意字符
    "	:s/text/\rtext/
    "	    \r相当于一个回车的效果
    "	:s/text\n/text/
    "	    查找内容为text，且其后是回车
" }



"===============================================================================
" Platform
"===============================================================================
" vim or nvim {
    silent function! IsNVim()
        return has('nvim')
    endfunction
" }

" linux or win {
    silent function! IsLinux()
        return has('unix') && !has('macunix') && !has('win32unix')
    endfunction
    silent function! IsWin()
        return  (has('win32') || has('win64'))
    endfunction
    silent function! IsGw()
        " GNU for windows
        return (has('win32unix'))
    endfunction
" }

" gui or term {
    silent function! IsGui()
        return has("gui_running")
    endfunction
    function! IsTermType(tt)
        if &term ==? a:tt
            return 1
        else
            return 0
    endfunction
" }

" path {
    " vim插件路径
    if IsLinux()
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
" }


"===============================================================================
" Defined functions
"===============================================================================
" 扩展名检测
let s:file_ext=expand("%:e")         
function! FileExtIs(ext)
    if a:ext ==? s:file_ext
        return 1
    else
        return 0
    endif
endfunction

" 隐藏字符显示
function! InvConceallevel()
    if &conceallevel == 0
        set conceallevel=2
    elseif &conceallevel == 2
        set conceallevel=0                  " 显示markdown等格式中的隐藏字符
    endif
endfunction

" 透明背影控制（需要系统本身支持透明）
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

" 编译环境函数
function! F5ComplileFile(argstr)
    let l:ext=expand("%:e")                         " 扩展名
    if IsLinux()
        let l:filename="\"".expand("./%:t")."\""    " 文件名，不带路径，带扩展名 
        let l:name="\"".expand("./%:t:r")."\""      " 文件名，不带路径，不带扩展名
    elseif IsWin()
        let l:filename="\"".expand("%:t")."\""      " 文件名，不带路径，带扩展名 
        let l:name="\"".expand("%:t:r")."\""        " 文件名，不带路径，不带扩展名
    endif
    " 先切换目录
    exec "cd %:h"
    " ==? 忽略大小写比较， ==# 进行大小写比较
    if "c" ==? l:ext
        " c
        execute ":AsyncRun gcc ".a:argstr." -o ".l:name." ".l:filename." && ".l:name
    elseif "cpp" ==? l:ext
        " c++
        execute ":AsyncRun g++ -std=c++11 ".a:argstr." -o ".l:name." ".l:filename." && ".l:name
    elseif "py" ==? l:ext || "pyw" ==? l:ext
        " python
        execute ":AsyncRun python ".l:filename
    endif
endfunction

" linux-fcitx输入法切换 
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


"===============================================================================
" Event handle
"===============================================================================
if IsGui()
    autocmd GuiEnter * set t_vb=        " 关闭可视闪铃(即闪屏)
endif
if IsLinux()
    "autocmd InsertLeave * call LinuxFcitx2En()
    inoremap <esc> <esc>:call LinuxFcitx2En()<CR>
endif


"===============================================================================
" Settings 
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
    set listchars=eol:$,tab:>-,trail:~,space:.
                                        " 不可见字符显示
    set conceallevel=0                  " 显示markdown等格式中的隐藏字符

    " 终端光标设置
    if IsTermType("xterm") || IsTermType("xterm-256color")
        " compatible for urxvt,st,xterm,gnome-termial
        " 5,6: 竖线
        " 3,4: 横线
        " 1,2: 方块
        let &t_SI = "\<Esc>[6 q"        " 进入Insert模式
        let &t_EI = "\<Esc>[2 q"        " 退出Insert模式
    endif
" }

" Edit{
    set backspace=2                     " Insert模式下使用BackSpace删除
    set nobackup                        " 不生成备份文件
    set autochdir						" 自动切换当前目录为当前文件所在的目录
    set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
                                        " 尝试解码序列
    set encoding=utf-8                  " vim内部使用utf-8编码
    set fileformat=unix                 " 以unix格式保存文本文件，即CR作为换行符
    set ignorecase                      " 不区别大小写搜索
    set smartcase                       " 有大写字母时才区别大小写搜索
    set noerrorbells                    " 关闭错误信息响铃
    set vb t_vb=                        " 关闭响铃(vb)和可视闪铃(t_vb，即闪屏)，即normal模式时按esc会有响铃
    set helplang=cn,en                  " 优先查找中文帮助

    if FileExtIs("c") || FileExtIs("cpp") || FileExtIs("h")
        set foldmethod=syntax           " 设置语法折叠
    elseif FileExtIs("tikz")
        set filetype=tex
    endif
" }

"===============================================================================
" Gui settings
"===============================================================================
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
        "set guifont=cousine:h12:cANSI
        set guifont=Consolas:h13:cANSI
        set guifontwide=Yahei_Mono:h13:cGB2312
        map <F11> <esc>:call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>
                                    " gvim全屏快捷键
    endif
endif



"===============================================================================
" Key-Map 
" - Normal模式下使用<leader>代替<C-?>,<S-?>,<A-?>，
" - Insert模式下map带ctrl,alt的快捷键
" - 尽量不改变vim原有键位的功能定义
" - 尽量一只手不同时按两个键
" - 尽量不映射偏远的按键（F1~F12，数字键等）
" - 建议调换Esc和CapsLock键
"
"  <leader>t? for plugins toggle command
"  <leader>i? for vim "set inv?" command
"===============================================================================
set timeout         " 打开映射超时检测
set ttimeout        " 打开键码超时检测
set timeoutlen=1000 " 映射超时时间为1000ms
set ttimeoutlen=70  " 键码超时时间为70ms

" 键码示例 {
    " 终端Alt键映射处理：如 Alt+x，实际连续发送 <esc>x 编码
    " 以下三种方法都可以使按下 Alt+x 后，执行 CmdTest 命令，但超时检测有区别
    "<1> set <M-x>=x  " 设置键码，这里的是一个字符，即<esc>的编码，不是^和[放在一起
                        " 在终端的Insert模式，按Ctrl+v再按Alt+x
    "    nnoremap <M-x> :CmdTest<CR>  " 按键码超时时间检测
    "<2> nnoremap <esc>x :CmdTest<CR> " 按映射超时时间检测
    "<3> nnoremap x  :CmdTest<CR>   " 按映射超时时间检测
" }

" 键码设置 {
    set <M-h>=h
    set <M-j>=j
    set <M-k>=k
    set <M-l>=l
" }

" 使用Space作为leader
" Space只在Normal或Command或Visual模式下map，不适合在Insert模式下map
let mapleader="\<space>"            

" map语句后别注释，也别留任何空格
" 特殊键
nnoremap ; :
vnoremap ; :

" 基本编辑 {
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
" }

" Show Setting{
    " 显示折行
    nnoremap <leader>iw :set invwrap<CR>
    " 显示不可见字符
    nnoremap <leader>il :set invlist<CR>
    " 映射隐藏字符功能，set conceallevel直接设置没交果
    nnoremap <leader>ih <esc>:call InvConceallevel()<CR>
    " 更改透明背景
    nnoremap <leader>it <esc>:call InvTransParentBackground()<CR>
" }

" copy and paste{
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
" }

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
" }

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
" }

" tab ,buffer and quickfix {
    noremap <M-h> gT
    noremap <M-l> gt

    nnoremap <leader>bn :bn<CR>
    nnoremap <leader>bp :bp<CR>
    nnoremap <leader>bl :b#<CR>

    nnoremap <leader>qo :copen<CR>
    nnoremap <leader>qc :cclose<CR>
" }

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
" }

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
" }

" Run Program map{
    " compiling and running
    noremap <F5> <esc>:call F5ComplileFile('')<CR>
    " compile args
    nnoremap <leader>cg :execute"let g:__str__=input('Compile Args: ')"<bar>call F5ComplileFile(g:__str__)<CR>
" }




"===============================================================================
" Plug and Settings
" - 插件设置全写在Plugin下
" - 安键map写在每个Plugin的最后
"===============================================================================

set rtp+=$VimPluginPath                     " add .vim or vimfiles to rtp(runtimepath)
call plug#begin($VimPluginPath."/bundle")	" alternatively, pass a path where install plugins

" user plugins 

" vimcdoc {
    " 中文帮助文档
    Plug 'vimcn/vimcdoc',{'branch' : 'release'}
" }

" asd2num {
    " asd数字输入
    Plug 'yehuohan/asd2num'
    inoremap <C-a> <esc>:Asd2NumToggle<CR>a
" }

" nerd-tree{
    " 目录树导航
    Plug 'scrooloose/nerdtree'			
    let g:NERDTreeShowHidden=1
    noremap <leader>te :NERDTreeToggle<CR>
" }

" taglist{
    " 代码结构预览
    Plug 'vim-scripts/taglist.vim'
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
" }

" YouCompleteMe{
    " 自动补全
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
    let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<C-m>', '<Up>']
    let g:ycm_autoclose_preview_window_after_insertion=1
                                                " 自动关闭预览窗口
    let g:ycm_cache_omnifunc = 0                " 禁止缓存匹配项，每次都重新生成匹配项
    nnoremap <leader>gd :YcmCompleter GoToDefinitionElseDeclaration<CR>
    nnoremap <leader>gi :YcmCompleter GoToInclude<CR>
    nnoremap <leader>gt :YcmCompleter GoTo<CR>
    nnoremap <leader>gs :YcmShowDetailedDiagnostic<CR>
    noremap <F4> :YcmDiags<CR> 
                                                " 错误列表
" }

" AsyncRun {
    " 导步运行程序
    Plug 'skywind3000/asyncrun.vim'
    augroup vimrc
        autocmd User AsyncRunStart call asyncrun#quickfix_toggle(8, 1)
    augroup END
    nnoremap <leader>r :AsyncRun 
" }

" ultisnips{
    " 代码片段插入
    Plug 'SirVer/ultisnips'               " snippet insert engine
    Plug 'honza/vim-snippets'             " snippet collection
    let g:UltiSnipsSnippetDirectories=["UltiSnips", "mySnippets"]
                                            " mySnippets is my own snippets collection
    let g:UltiSnipsExpandTrigger="<tab>"
    let g:UltiSnipsJumpForwardTrigger="<C-o>"
    let g:UltiSnipsJumpBackwardTrigger="<C-p>"
" }

" nerd-commenter{
    " 批量注释
    Plug 'scrooloose/nerdcommenter'
    let g:NERDSpaceDelims = 1               " add space after comment
    " <leader>cc for comment
    " <leader>cl/cb for comment aligned
    " <leader>cu for un-comment
" }

" air-line{
    " 状态栏
    Plug 'vim-airline/vim-airline'
    set laststatus=2
    let g:airline#extensions#ctrlspace#enabled = 1      " support for ctrlspace integration
    let g:CtrlSpaceStatuslineFunction = "airline#extensions#ctrlspace#statusline()" 
    let g:airline#extensions#ycm#enabled = 1            " support for YCM integration
    let g:airline#extensions#ycm#error_symbol = 'E:'
    let g:airline#extensions#ycm#warning_symbol = 'W:'
" }

" file switch{
    " 文件切换
    Plug 'derekwyatt/vim-fswitch'
    nnoremap <silent> <leader>fh :FSHere<CR>
" }

" multiple-cursors{
    " 多光标编辑
    Plug 'terryma/vim-multiple-cursors'
    let g:multi_cursor_use_default_mapping=0 " 取消默认按键
    let g:multi_cursor_start_key='<C-n>'     " 进入Multiple-cursors Model
                                             " 自己选定区域（包括矩形选区），或自动选择当前光标<cword>
    let g:multi_cursor_next_key='<C-n>'
    let g:multi_cursor_prev_key='<C-p>'
    let g:multi_cursor_skip_key='<C-x>'
    let g:multi_cursor_quit_key='<esc>'
" }

" vim-over {
    " 替换预览
    " substitute preview
    Plug 'osyo-manga/vim-over'
    nnoremap <leader>oc :OverCommandLine<CR>
" }

" tabular{
    " 代码对齐
    " /:/r2 means align right and insert 2 space before next field
    Plug 'godlygeek/tabular'
    " align map
    vnoremap <leader>a :Tabularize /
    nnoremap <leader>a :Tabularize /
" }

" surround and repeat{
    " add surroundings
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
" }

" easy-motion{
    " 快速跳
    Plug 'easymotion/vim-easymotion'
    let g:EasyMotion_do_mapping = 0         " 禁止默认map
    let g:EasyMotion_smartcase = 1          " 不区分大小写
    nmap s <Plug>(easymotion-overwin-f)
    nmap <leader>ss <plug>(easymotion-overwin-f2)
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
" }

" ctrl-space{
    " buffer管理
    " <h,o,l,w,b,/,?> for buffer,file,tab,workspace,bookmark,search and help
    Plug 'vim-ctrlspace/vim-ctrlspace'
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
" }

" incsearch{
    " 查找增强
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
" }

" expand-region{
    " 快速块选择
    Plug 'terryma/vim-expand-region'
    nmap <leader>er <Plug>(expand_region_expand)
    vmap <leader>er <Plug>(expand_region_expand)
    nmap <C-l> <Plug>(expand_region_expand)
    nmap <C-h> <Plug>(expand_region_shrink)
    vmap <C-l> <Plug>(expand_region_expand)
    vmap <C-h> <Plug>(expand_region_shrink)
" }

" smooth-scroll{
    " 平滑滚动
    Plug 'terryma/vim-smooth-scroll'
    nnoremap <silent> <C-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
    nnoremap <silent> <C-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
    " nnoremap <silent> <C-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>
    " nnoremap <silent> <C-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
    nnoremap <silent> <M-j> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>
    nnoremap <silent> <M-k> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
" }

" session{
    " 会话保存
    Plug 'xolox/vim-misc'
    Plug 'xolox/vim-session'
    let g:session_autosave='no'             " 自动保存会话窗口
    let g:session_autoload='yes'            " 直接打开vim，自动加载default.vim
    noremap <leader>qa :SaveSession!<CR>:qa<CR>
                                            " 关闭所有，且先保存会话
" }

" indent-line{
    " 显示缩进标识
    Plug 'Yggdroot/indentLine'			
    "let g:indentLine_char = '|'            " 设置标识符样式
    let g:indentLinet_color_term=200        " 设置标识符颜色
    nnoremap <leader>t\ :IndentLinesToggle<CR>
" }

" new-railscasts-theme{
    " 使用主题
    set rtp+=$VimPluginPath/bundle/new-railscasts-theme/
    Plug 'carakan/new-railscasts-theme'
    colorscheme new-railscasts          
    hi CursorLine   cterm=NONE ctermbg=black ctermfg=gray guibg=black guifg=NONE
    hi CursorColumn cterm=NONE ctermbg=black ctermfg=gray guibg=black guifg=NONE
    hi Search term=reverse ctermfg=white ctermbg=blue guifg=white guibg=#072f95
                                        " 设定高亮行列的颜色
                                        " cterm:彩色终端，gui:Gvim窗口，fg:前景色，bg:背景色
" }

" rainbow{
    " 彩色括号
    Plug 'luochen1990/rainbow'
    let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
    nnoremap <leader>tr :RainbowToggle<CR>
" }

" markdown-preview{
    " MarkDown预览 
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
" }

" vim-latex{
    "Plug 'vim-latex/vim-latex'
    " 暂时不用
" }

" qml {
    Plug 'crucerucalin/qml.vim'
" }
call plug#end()            " required


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" # Commands
" | Command                             | Description                                                        |
" | ----------------------------------- | ------------------------------------------------------------------ |
" | PlugInstall [name ...] [#threads]   | Install plugins                                                    |
" | PlugUpdate [name ...] [#threads]    | Install or update plugins                                          |
" | PlugClean[!]                        | Remove unused directories (bang version will clean without prompt) |
" | PlugUpgrade                         | Upgrade vim-plug itself                                            |
" | PlugStatus                          | Check the status of plugins                                        |
" | PlugDiff                            | Examine changes from the previous update and the pending changes   |
" | PlugSnapshot[!] [output path]       | Generate script for restoring the current snapshot of the plugins  |

" # Plug options
" | Option                  | Description                                      |
" | ----------------------- | ------------------------------------------------ |
" | branch / tag / commit   | Branch/tag/commit of the repository to use       |
" | rtp                     | Subdirectory that contains Vim plugin            |
" | dir                     | Custom directory for the plugin                  |
" | as                      | Use different name for the plugin                |
" | do                      | Post-update hook (string or funcref)             |
" | on                      | On-demand loading: Commands or `<Plug>`-mappings |
" | for                     | On-demand loading: File types                    |
" | frozen                  | Do not update unless explicitly specified        |

