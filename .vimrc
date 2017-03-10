
"""""" dispaly """""

syntax on										"语法高亮
set number										"显示行号
set cursorline									"高亮当前行
set cursorcolumn								"高亮当前列
hi CursorLine 	 cterm=NONE ctermbg=black ctermfg=green guibg=NONE guifg=NONE
hi CursorColumn  cterm=NONE ctermbg=black ctermfg=green guibg=NONE guifg=NONE
												"设定高亮行列的颜色
												"cterm:彩色终端，gui:Gvim窗口，fg:前景色，bg:背景色

set tabstop=4									"设置tab键宽度
set noexpandtab									"不用空格代替tab
set softtabstop=4								"统一缩进为4
set shiftwidth=4								"设置>和<命令移动宽度为4
set foldenable									"充许折叠
set foldcolumn=1								"0~12,折叠标识列，分别用“-”和“+”而表示打开和关闭的折叠
set foldmethod=indent							"设置语文折叠
												"manual:手工定义折叠         
												"indent:更多的缩进表示更高级别的折叠         
												"expr:用表达式来定义折叠         
												"syntax:用语法高亮来定义折叠         
												"diff:对没有更改的文本进行折叠         
												"marker:对文中的标志折叠
												
set guifont=Courier\ New\ 11					"设置字体
set hlsearch									"设置高亮显示查找到的文本
set smartindent									"新行智能自动缩进


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""" bundle """""

syntax enable									"主题显示
if has('gui_running')
    set background=dark
endif
colorscheme zellner

"let g:Powerline_symbols = 'fancy'				"状态栏美观设置

"let g:ycm_global_ycm_extra_conf='~/.vim/bundle/YouCompleteMe/cpp/ycm/.ycm_extra_conf.py'							"YouCompleteMe配置文件

"nmap <silent> <F4> :TagbarToggle<CR>			"Tagbar配置
"let g:tagbar_ctags_bin = 'ctags'
"let g:tagbar_width = 30


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""" Vundle """""

set nocompatible						" be iMproved, required
filetype off							" required

set rtp+=~/.vim/bundle/Vundle.vim		" set the runtime path to include Vundle and initialize
call vundle#begin()						" alternatively, pass a path where Vundle should install plugins
										"call vundle#begin('~/some/path/here')
										
Plugin 'VundleVim/Vundle.vim'			" let Vundle manage Vundle, required

										" 我的插件
Plugin 'scrooloose/nerdtree'			" 目录树导航
Plugin 'majutsushi/tagbar'				" 标签导航
"Plugin 'Lokaltog/vim-powerline'			" 状态栏美观
Plugin 'Yggdroot/indentLine'			" 显示缩进标识
Plugin 'Valloric/YouCompleteMe'			" 自动补全
										" PluginInstall后，运行安装：
										" ./install.py --clang-completer
"Plugin 'SirVer/ultisnips'				" 快速插入自定义的代码片段
"Plugin 'scrooloose/nerdcommenter'		" 快速批量加减注释
"Plugin 'tpope/vim-surround'				" 快速给词加环绕符号,例如引号
Plugin 'Raimondi/delimitMate'			" 输入引号,括号时,自动补全
"Plugin 'vim-multiple-cursors'			" 多光标批量操作
"Plugin 'scrooloose/syntastic'			" 静态语法及风格检查,支持多种语言
"Plugin 'altercation/vim-colors-solarized'	"经典主题

												" Vundel使用举例，需要位于vundle#begin/end之间
"Plugin 'tpope/vim-fugitive'					" plugin on GitHub repo
"Plugin 'L9'									" plugin from http://vim-scripts.org/vim/scripts.html
"Plugin 'git://git.wincent.com/command-t.git'	" Git plugin not hosted on GitHub
"Plugin 'file:///home/gmarik/path/to/plugin'	" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}		" The sparkup vim script is in a subdirectory of this repo called vim.
												" Pass the path to set the runtimepath properly.
"Plugin 'ascenator/L9', {'name': 'newL9'}		" Install L9 and avoid a Naming conflict if you've already installed a
												" different version somewhere else.


call vundle#end()            " required
filetype plugin indent on    " required


" To ignore plugin indent changes, instead use:
"filetype plugin on
"
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

