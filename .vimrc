
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
set guifont=Courier\ New\ 11		" 设置字体
set hlsearch						" 设置高亮显示查找到的文本
set nocompatible				    " 不兼容vi快捷键
set nobackup                        " 不生成备份文件
set ignorecase                      " 不区别大小写搜索
set smartcase                       " 有大写字母时才区别大小写搜索


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" KeyMap 
" - 尽量不用ctrl,shift,alt，用<leader><leader>代替ctrl,shift或alt
" - Command模式下使用<leader>代替:
" - Normal模式下使用<leader><leader>代替<C-?>,<S-?>,<A-?>，用<leader>开头表示自己定义的命令
" - Insert模式下map带ctrl,shift,alt的快捷键，不map字母或数字或<Space>开头的快捷键
" - 尽量不改变vim原有键位的功能
" - 尽量不需要一只手同时按两个键
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 使用Space作为leader
" Space只在Normal或Command或Visual模式下map，不适在Insert模式下map
" Space组合的键位，连接3个键比较顺手
let mapleader="\<space>"            

" map语句后别注释，也别留任何空格
nnoremap <leader>ww :w<CR>
nnoremap <leader>qq :q<CR>
nnoremap <leader>wq :wq<CR>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>

" 快速选择 
nnoremap <leader>s viw
nnoremap <leader>v V
    
" 矩形选择模式
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
"inoremap <C-m> <esc><C-y>i "与Enter键有冲突
"inoremap <C-n> <esc><C-e>i
nnoremap <C-m> <C-y>
nnoremap <C-n> <C-e>

" 分割窗口
nnoremap <leader>ws :split<CR>
nnoremap <leader>wv :vsplit<CR>

" 移动到别一个分屏窗口
nnoremap <leader><leader>h <C-w>h
nnoremap <leader><leader>j <C-w>j
nnoremap <leader><leader>k <C-w>k
nnoremap <leader><leader>l <c-w>l

" 使用C-up,down,left,right调整窗口大小
inoremap <C-up> <esc>:resize+1<CR>i
inoremap <C-down> <esc>:resize-1<CR>i
inoremap <C-left> <esc>:vertical resize-1<CR>i
inoremap <C-right> <esc>:vertical resize+1<CR>i
nnoremap <C-up> <esc>:resize+1<CR>
nnoremap <C-down> <esc>:resize-1<CR>
nnoremap <C-left> <esc>:vertical resize-1<CR>
nnoremap <C-right> <esc>:vertical resize+1<CR>

" 大写字母用;开头表示
"inoremap ;a A
nnoremap ;a A
nnoremap ;d D
nnoremap ;g G
nnoremap ;i I
nnoremap ;o O
nnoremap ;4 $



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vundel and Settings
" - 插件设置全写在Plugin下
" - 安键map写在每个Plugin的最后
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set nocompatible						" be iMproved, required
filetype off							" required

set rtp+=~/.vim/bundle/Vundle.vim		" set the runtime path to include Vundle and initialize
call vundle#begin()						" alternatively, pass a path where Vundle should install plugins
										" call vundle#begin('~/some/path/here')

" user plugins 
Plugin 'VundleVim/Vundle.vim'			" let Vundle manage Vundle, required

" 目录树导航
Plugin 'scrooloose/nerdtree'			
noremap <C-e> :NERDTreeToggle<CR>
inoremap <C-e> <esc>:NERDTreeToggle<CR> " :NERDTree 命令可以打开目录树
                                        " ctrl+w+h/l, 可以左右切换目录树与编辑窗口,ctrl+w连续两次，也可以切换

" 代码结构预览
Plugin 'vim-scripts/taglist.vim'
let Tlist_Ctags_Cmd = '/usr/bin/ctags'  " 设置ctags路径，需要apt-get install ctags
let Tlist_Show_One_File=1               " 不同时显示多个文件的tag，只显示当前文件
let Tlist_WinWidth = 30                 " 设置taglist的宽度
let Tlist_Exit_OnlyWindow=1             " 如果taglist窗口是最后一个窗口，则退出vim
let Tlist_Use_Right_Window=1            " 在右侧窗口中显示taglist窗口
noremap <C-T> :TlistToggle<CR>
inoremap <C-T> <esc>:TlistToggle<CR>


" 状态栏美观
Plugin 'Lokaltog/vim-powerline'		
let g:Powerline_symbols = 'fancy'


" 显示缩进标识
Plugin 'Yggdroot/indentLine'			
"let g:indentLine_char = '|'            " 设置标识符样式
let g:indentLinet_color_term=200        " 设置标识符颜色
noremap <C-\> :IndentLinesToggle<CR>
inoremap <C-\> <esc>:IndentLinesToggle<CR>


" 自动补全
" PluginInstall后，运行安装： ./install.py --clang-completer
Plugin 'Valloric/YouCompleteMe'			
let g:ycm_global_ycm_extra_conf='~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'


" 输入引号,括号时,自动补全
Plugin 'Raimondi/delimitMate'			


" 快速插入自定义的代码片段
Plugin 'SirVer/ultisnips'				


" 快速批量加减注释
Plugin 'scrooloose/nerdcommenter'		


" 静态语法及风格检查,支持多种语言
Plugin 'scrooloose/syntastic'			


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

