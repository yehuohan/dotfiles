
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" My Notes
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
"   :n,$s/ar\[i\]/*(ar+i)/g
"       将第n行到最后一行的所有 ar[i] 替换成 *(ar+)
"       注意：对于 * . / \ [ ] 需要转义
"	
"	:.,30s/ar\[i\]/*(ar+i)/g
"		将当前行到第30行的所有 ar[i] 替换成 *(ar+)
"	
"	:s/"\([A-J]\)"/"Group \1"/g
"		将"X" 替换成 "Group X"，其中X可为A-J，\( \)表示后面用\1引用()的内容
"}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" display 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

syntax on							" 语法高亮
colorscheme slate                   " 使用主题
set number							" 显示行号
set cursorline						" 高亮当前行
set cursorcolumn					" 高亮当前列
hi CursorLine 	 cterm=NONE ctermbg=black ctermfg=gray guibg=NONE guifg=NONE
hi CursorColumn  cterm=NONE ctermbg=black ctermfg=gray guibg=NONE guifg=NONE
									" 设定高亮行列的颜色
									" cterm:彩色终端，gui:Gvim窗口，fg:前景色，bg:背景色
set tabstop=4						" 设置tab键宽度
set expandtab						" 将Tab用Space代替，方便显示缩进标识indentLine
retab								" 重新将Space转换为Tab
set softtabstop=4					" 设置显示的缩进为4,实际Tab可能不是4个格
set shiftwidth=4					" 设置>和<命令移动宽度为4
set smartindent						" 新行智能自动缩进
set foldenable						" 充许折叠
set foldcolumn=1					" 0~12,折叠标识列，分别用“-”和“+”而表示打开和关闭的折叠
set foldmethod=indent				" 设置语文折叠
									" manual:手工定义折叠         
									" indent:更多的缩进表示更高级别的折叠         
									" expr:用表达式来定义折叠         
									" syntax:用语法高亮来定义折叠         
									" diff:对没有更改的文本进行折叠         
									" marker:对文中的标志折叠
set hlsearch						" 设置高亮显示查找到的文本
set nocompatible				    " 不兼容vi快捷键
set nobackup                        " 不生成备份文件
set ignorecase                      " 不区别大小写搜索
set smartcase                       " 有大写字母时才区别大小写搜索
set nobackup						" 不保留备份文件
set autochdir						" 自动切换当前目录为当前文件所在的目录
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
                                    " 尝试解码序列
set bs=2                            " Insert模式下使用BackSpace删除
set showcmd                         " 显示寄存器命令，宏调用命令@等

" gui vim配置
if has("gui_running")
    set encoding=utf8               " vim内部使用utf-8编码
    colorscheme koehler 			" 设定配色方案
    set guioptions-=m               " 隐藏菜单栏
    set guioptions-=T               " 隐藏工具栏
    set guioptions+=L               " 隐藏左侧滚动条
    set guioptions+=r               " 隐藏右侧滚动条
    set guioptions+=b               " 隐藏底部滚动条
    set guioptions+=0               " 隐藏Tab栏

if has("unix")
    set guifont=Courier\ 10\ Pitch\ 11	
                                    " 设置字体
elseif has("win32") || has("win64")
    set encoding=gbk                " vim内部使用utf-8编码
    set guifont=Courier_New:h12	    " 设置字体
    map <F11> <esc>:call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>
                                    " gvim全屏快捷键
endif
endif



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" KeyMap 
" - 尽量不用ctrl,shift,alt，用<leader><leader>代替ctrl,shift或alt
" - Normal模式下使用<leader>代替<C-?>,<S-?>,<A-?>，
" - Insert模式下map带ctrl,shift,alt的快捷键
" - 尽量不改变vim原有键位的功能
" - 尽量不需要一只手同时按两个键
" - 建议调换Esc和CapsLock键
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 使用Space作为leader
" Space只在Normal或Command或Visual模式下map，不适在Insert模式下map
let mapleader="\<space>"            

" map语句后别注释，也别留任何空格
" 特殊键
nnoremap ; :
vnoremap ; :

" 基本插入
nnoremap <leader>a A
nnoremap <leader>o O

" 删除 
nnoremap <leader>d D

" 大小写转换
nnoremap <leader>` ~
vnoremap <leader>` ~

" 定位
nnoremap <leader>4 $
nnoremap <leader>6 ^
nnoremap <leader>5 %

" 搜索(find)
nnoremap <leader>3 #
nnoremap <leader>8 *
"nnoremap <leader>/ :call FindAndShow()<CR>
function! FindAndShow()
    let l:str=input('/')
    exec "vimgrep /\\<".l:str."\\>/j %"
    copen
endfunction
nnoremap <leader>/ :exec"let g:__str__=input('/')"<bar>exec "vimgrep /\\<".g:__str__."\\>/j %"<bar>copen<CR>
nnoremap <leader>ff :exec"let g:__str__=expand(\"<cword>\")"<bar>exec "vimgrep /\\<".g:__str__."\\>/j %"<bar>copen<CR>
nnoremap <leader>fj :cnext<CR>
nnoremap <leader>fk :cprevious<CR>

" 折叠
nnoremap <leader>zr zR
nnoremap <leader>zm zM

" 复制相关快捷键
vnoremap <C-c> "+y
nnoremap <C-v> "+p
inoremap <C-v> <esc>"+pi
nnoremap <leader>p "0p

" 快速选择和矩形选择
nnoremap <leader>v viw
nnoremap vv <C-v>

" i:insert,在单词两边添加抱号等
nnoremap <leader>i( viwxi(<esc>pa)<esc>     
nnoremap <leader>i< viwxi<<esc>pa><esc>
nnoremap <leader>i[ viwxi[<esc>pa]<esc>
nnoremap <leader>i{ viwxi{<esc>pa}<esc>
nnoremap <leader>i" viwxi"<esc>pa"<esc>
nnoremap <leader>i' viwxi'<esc>pa'<esc>

" Insert模式下使用hjkl移动
inoremap <C-h> <left>
inoremap <C-j> <down>
inoremap <C-k> <up>
inoremap <C-l> <right>

" n和m作为滚动
nnoremap <C-m> <C-y>
nnoremap <C-n> <C-e>

" 分割窗口
nnoremap <leader>ws :split<CR>
nnoremap <leader>wv :vsplit<CR>

" 移动到别一个分屏窗口
nnoremap <leader>wh <C-w>h
nnoremap <leader>wj <C-w>j
nnoremap <leader>wk <C-w>k
nnoremap <leader>wl <c-w>l

" 使用C-up,down,left,right调整窗口大小
inoremap <C-up> <esc>:resize+1<CR>i
inoremap <C-down> <esc>:resize-1<CR>i
inoremap <C-left> <esc>:vertical resize-1<CR>i
inoremap <C-right> <esc>:vertical resize+1<CR>i
nnoremap <C-up> <esc>:resize+1<CR>
nnoremap <C-down> <esc>:resize-1<CR>
nnoremap <C-left> <esc>:vertical resize-1<CR>
nnoremap <C-right> <esc>:vertical resize+1<CR>

" tab页选择
noremap <A-left> gT
noremap <A-right> gt


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vundel and Settings
" - 插件设置全写在Plugin下
" - 安键map写在每个Plugin的最后
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has("unix")
    let $MyVimPath="~/.vim"
elseif has("win32") || has("win64")
    let $MyVimPath=$VIM."\\vimfiles"
endif

set nocompatible						" be iMproved, required
filetype off							" required

set rtp+=$MyVimPath/bundle/Vundle.vim/  " set the runtime path to include Vundle and initialize
if has("unix")
set rtp+=~/Desktop/AnyWorkSpace         " 临时添加RunTimePath，用于开发AnyWorkSpace插件
endif

call vundle#begin($MyVimPath."/bundle")	" alternatively, pass a path where Vundle should install plugins
										" call vundle#begin('~/some/path/here')设置插件安装路径

" user plugins 
Plugin 'VundleVim/Vundle.vim'			" let Vundle manage Vundle, required


" 工作空间测试
if has("unix")
Plugin 'file:///~/Desktop/AnyWorkSpace'
endif


" 目录树导航
Plugin 'scrooloose/nerdtree'			
noremap <C-e> :NERDTreeToggle<CR>
inoremap <C-e> <esc>:NERDTreeToggle<CR> " :NERDTree 命令可以打开目录树


" 代码结构预览
Plugin 'vim-scripts/taglist.vim'
if has("unix")
    let Tlist_Ctags_Cmd='/usr/bin/ctags'
elseif has("win32") || has("win64")
    let Tlist_Ctags_Cmd="C:\\MyApps\\Vim\\vim80\\ctags.exe"
endif                                   " 设置ctags路径，需要apt-get install ctags
let Tlist_Show_One_File=1               " 不同时显示多个文件的tag，只显示当前文件
let Tlist_WinWidth = 30                 " 设置taglist的宽度
let Tlist_Exit_OnlyWindow=1             " 如果taglist窗口是最后一个窗口，则退出vim
let Tlist_Use_Right_Window=1            " 在右侧窗口中显示taglist窗口
noremap <C-T> :TlistToggle<CR>          " 可以 ctags -R 命令自行生成tags
inoremap <C-T> <esc>:TlistToggle<CR>


" 自动补全
" PluginInstall后，运行安装： ./install.py --clang-completer
"Plugin 'Valloric/YouCompleteMe'			
let g:ycm_global_ycm_extra_conf=$MyVimPath.'/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
nnoremap <leader>gd :YcmCompleter GoToDefinitionElseDeclaration<CR>
nmap <F4> :YcmDiags<CR>                 " 错误列表


" 快速批量加减注释
" <leader>cc for comment and <leader>cu for un-comment
Plugin 'scrooloose/nerdcommenter'


" 代码对齐
Plugin 'godlygeek/tabular'
vnoremap <leader>a :Tabularize /


" 快速跳转
Plugin 'easymotion/vim-easymotion'
let g:EasyMotion_do_mapping = 0         " 禁止默认map
let g:EasyMotion_smartcase = 1          " 不区分大小写
nmap s <Plug>(easymotion-overwin-f)
nmap <leader>s <plug>(easymotion-overwin-f2)
                                        " 跨分屏快速跳转到字母，
nmap <leader>j <plug>(easymotion-j)
nmap <leader>k <plug>(easymotion-k)
nmap <leader>w <plug>(easymotion-w)
nmap <leader>W <plug>(easymotion-W)
nmap <leader>b <plug>(easymotion-b)
nmap <leader>B <plug>(easymotion-B)
nmap <leader>e <plug>(easymotion-e)
nmap <leader>E <plug>(easymotion-E)
nmap <leader>ge <plug>(easymotion-ge)
nmap <leader>gE <plug>(easymotion-gE)


" 会话保存
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-session'
let g:session_autosave='no'             " 自动保存会话窗口
let g:session_autoload='yes'            " 直接打开vim，自动加载default.vim
noremap <leader>q :SaveSession<CR>:qa<CR>
                                        " 关闭所有，且先保存会话
nnoremap <C-o> :OpenSession<CR>         " 打开会话 
                                        " vim --servename session.vim，也可以打开


" 显示缩进标识
Plugin 'Yggdroot/indentLine'			
"let g:indentLine_char = '|'            " 设置标识符样式
let g:indentLinet_color_term=200        " 设置标识符颜色
noremap <C-\> :IndentLinesToggle<CR>
inoremap <C-\> <esc>:IndentLinesToggle<CR>


" 状态栏美观
Plugin 'Lokaltog/vim-powerline'		
let g:Powerline_symbols = 'fancy'


" 快速插入自定义的代码片段
"Plugin 'SirVer/ultisnips'				

" 静态语法及风格检查,支持多种语言,  ycm已经有了此功能
"Plugin 'scrooloose/syntastic'			


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
" Put your non-Plugin stuff after this line



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

