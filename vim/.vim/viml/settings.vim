let s:use = Sv_use()

" Style {{{
    set synmaxcol=512                   " 最大高亮列数
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
    set listchars=tab:⤜⤚→,eol:↲,space:·,nbsp:␣,precedes:<,extends:>,trail:~
                                        " 不可见字符显示
    set autoindent                      " 使用autoindent缩进
    set nobreakindent                   " 折行时不缩进
    set conceallevel=0                  " 显示高样样式中的隐藏字符
    set foldenable                      " 充许折叠
    set foldopen-=search                " 查找时不自动展开折叠
    set foldcolumn=0                    " 0~12,折叠标识列，分别用“-”和“+”而表示打开和关闭的折叠
    set foldmethod=indent               " 设置折叠，默认为缩进折叠
    set scrolloff=3                     " 光标上下保留的行数
    set nostartofline                   " 执行滚屏等命令时，不改变光标列位置
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
    set noimdisable                     " 不禁用输入法
    set visualbell                      " 使用可视响铃代替鸣声
    set noerrorbells                    " 关闭错误信息响铃
    set belloff=all                     " 关闭所有事件的响铃
    set helplang=en,cn                  " help-doc顺序
    set timeout                         " 打开映射超时检测
    set ttimeout                        " 打开键码超时检测
    set timeoutlen=1000                 " 映射超时时间为1000ms
    set ttimeoutlen=70                  " 键码超时时间为70ms
if IsVim()
    " 终端Alt键映射处理：如 Alt+x，实际连续发送 <Esc>x 的键码
    "<1> set <M-x>=x                  " 设置键码，这里的是一个字符，即<Esc>的键码（按i-C-v, i-C-[输入）
    "    nnoremap <M-x>  :CmdTest<CR>   " 按键码超时时间检测
    "<2> nnoremap <Esc>x :CmdTest<CR>   " 按映射超时时间检测
    "<3> nnoremap x    :CmdTest<CR>   " 按映射超时时间检测
    for t in split('q w e r t y u i o p a s d f g h j k l z x c v b n m ; , .', ' ')
        execute 'set <M-'. t . '>=' . t
    endfor
    set renderoptions=                  " 设置正常显示unicode字符
    if &term == 'xterm' || &term == 'xterm-256color'
        set t_vb=                       " 关闭终端可视闪铃，即normal模式时按esc会有响铃
        let &t_SI = "\<Esc>[6 q"        " 进入Insert模式，5,6:竖线
        let &t_SR = "\<Esc>[3 q"        " 进入Replace模式，3,4:横线
        let &t_EI = "\<Esc>[2 q"        " 退出Insert模式，1,2:方块
    endif
endif

" Function: s:onLargeFile() {{{
function! s:onLargeFile()
    let l:fsize = getfsize(expand('<afile>'))
    if l:fsize >= 5 * 1024 * 1024 || l:fsize == -2
        let b:lightline_check_flg = 0   " 禁止MixedIndent和Trailing检测
        setlocal filetype=log
        setlocal undolevels=-1
        setlocal noswapfile
    endif
endfunction
" }}}

augroup UserSettingsCmd
    autocmd!
    autocmd BufNewFile *                set fileformat=unix
    autocmd BufRead,BufNewFile *.tex    set filetype=tex
    autocmd BufRead,BufNewFile *.log    set filetype=log
    autocmd Filetype vim,tex            setlocal foldmethod=marker
    autocmd Filetype c,cpp,javascript   setlocal foldmethod=syntax
    autocmd Filetype python             setlocal foldmethod=indent
    autocmd FileType txt,log            setlocal foldmethod=manual
    autocmd BufReadPre *                call s:onLargeFile()
augroup END
" }}}

" Gui {{{
    set guioptions=M                    " 完全禁用Gui界面元素
    let g:did_install_default_menus = 1 " 禁止加载缺省菜单
    let g:did_install_syntax_menu = 1   " 禁止加载Syntax菜单
    nnoremap <kPlus> :call GuiAdjustFontSize(1)<CR>
    nnoremap <kMinus> :call GuiAdjustFontSize(-1)<CR>
    let s:gui_fontsize = 12
    if IsWin()
        let s:gui_font = s:use.powerfont ? 'Consolas\ For\ Powerline' : 'Consolas'
        let s:gui_fontwide = IsVim() ? 'Microsoft\ YaHei\ Mono' : 'Microsoft\ YaHei\ UI'
    else
        let s:gui_font = s:use.powerfont ? 'DejaVu\ Sans\ Mono\ for\ Powerline' : 'DejaVu\ Sans'
        let s:gui_fontwide = 'WenQuanYi\ Micro\ Hei\ Mono'
    endif
    function! GuiAdjustFontSize(inc)
        let s:gui_fontsize += a:inc
        execute printf('set guifont=%s:h%d', s:gui_font, s:gui_fontsize)
        execute printf('set guifontwide=%s:h%d', s:gui_fontwide, s:gui_fontsize - 1)
    endfunction

" Gui-vim {{{
if IsVim() && has('gui_running')
    set lines=25
    set columns=90
    set linespace=0
    call GuiAdjustFontSize(0)
    if IsWin()
        nnoremap <leader>tf :call libcallnr('gvimfullscreen.dll', 'ToggleFullScreen', 0)<CR>
    endif
endif
" }}}

if IsNVim()
" Gui-neovim {{{
    set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
        \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
        \,sm:block-blinkwait175-blinkoff150-blinkon175
augroup UserSettingsGui
    autocmd!
    autocmd UIEnter * call s:NVimQt_setGui()
augroup END

" Function: s:NVimQt_setGui() {{{
function! s:NVimQt_setGui()
    if exists('g:GuiLoaded') " 在UIEnter之后才起作用
        GuiLinespace 0
        GuiTabline 0
        GuiPopupmenu 0
        call GuiAdjustFontSize(0)
        nnoremap <RightMouse> :call GuiShowContextMenu()<CR>
        inoremap <RightMouse> <Esc>:call GuiShowContextMenu()<CR>
        vnoremap <RightMouse> :call GuiShowContextMenu()<CR>gv
        nnoremap <leader>tf :call GuiWindowFullScreen(!g:GuiWindowFullScreen)<CR>
        nnoremap <leader>tm :call GuiWindowMaximized(!g:GuiWindowMaximized)<CR>
    endif
endfunction
" }}}
" }}}

" Gui-neovide {{{
if exists('g:neovide')
    set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
    let g:neovide_cursor_antialiasing = v:false
    let g:neovide_cursor_vfx_mode = "railgun"
    call GuiAdjustFontSize(4)
endif
" }}}
endif
" }}}

" Mappings {{{
" Basic {{{
    " 回退操作
    nnoremap <S-u> <C-r>
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
    " 大小写切换
    nnoremap <leader>u ~
    vnoremap <leader>u ~
    " 匹配符跳转
if IsVim()
    packadd matchit
endif
    nmap <S-s> %
    vmap <S-s> %
    " 行移动
    nnoremap j gj
    vnoremap j gj
    nnoremap k gk
    vnoremap k gk
    nnoremap <S-l> $
    nnoremap <S-h> ^
    vnoremap <S-l> $
    vnoremap <S-h> ^
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
    " 排序
    nnoremap <silent> <leader><leader>s :call feedkeys(':sort nr /', 'n')<CR>
    nnoremap <silent> <leader><leader>S :call feedkeys(':sort! nr /', 'n')<CR>
    vnoremap <silent> <leader><leader>s
        \ :call feedkeys(printf(':sort nr /\%%>%dc.*\%%<%dc/', getpos("'<")[2]-1, getpos("'>")[2]+1), 'n')<CR>
    vnoremap <silent> <leader><leader>S
        \ :call feedkeys(printf(':sort! nr /\%%>%dc.*\%%<%dc/', getpos("'<")[2]-1, getpos("'>")[2]+1), 'n')<CR>
    " HEX编辑
    nnoremap <leader>xx :%!xxd<CR>
    nnoremap <leader>xr :%!xxd -r<CR>
    " lua的echo测试代码
    nnoremap <leader><leader>u :lua print(
    nnoremap <leader><leader>U :lua print(vim.inspect(
    " 查看help文档
    nnoremap <silent> <leader><leader>k
        \ :call feedkeys(':h ' . expand('<cword>'), 'n')<CR>
    vnoremap <silent> <leader><leader>k
        \ :call feedkeys(':h ' . GetSelected(), 'n')<CR>
" }}}

" Copy & Paste {{{
    " 行复制
    nnoremap yL y$
    nnoremap yH y^
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
        execute printf('nnoremap <leader>2%s :call ExecMacro("%s")<CR>', t, t)
    endfor
" }}}

" Tab, Buffer, Window {{{
    " tab切换
    nnoremap <M-u> gT
    nnoremap <M-p> gt
    " buffer切换
    nnoremap <leader>bn :bnext<CR>
    nnoremap <leader>bp :bprevious<CR>
    nnoremap <leader>bl <C-^>
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
        \ :call Input2Fn(['File: ', '', 'file', expand('%:p:h')], {filename -> execute('diffsplit ' . filename)})<CR>
    nnoremap <silent> <leader>dv
        \ :call Input2Fn(['File: ', '', 'file', expand('%:p:h')], {filename -> execute('vertical diffsplit ' . filename)})<CR>
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

" Search {{{
    nnoremap <leader><Esc> :nohlsearch<CR>
    nnoremap i :nohlsearch<CR>i
    nnoremap <leader>8  *
    nnoremap <leader>3  #
    vnoremap <silent> <leader>8
        \ :call execute('/\V\c\<' . escape(GetSelected(), '\/') . '\>')<CR>
    vnoremap <silent> <leader>3
        \ :call execute('?\V\c\<' . escape(GetSelected(), '\/') . '\>')<CR>
    nnoremap <silent> <leader>/
        \ :execute '/\V\c' . escape(expand('<cword>'), '\/')<CR>
    vnoremap <silent> <leader>/
        \ :call execute('/\V\c' . escape(GetSelected(), '\/'))<CR>
    vnoremap <silent> <leader><leader>/
        \ :call feedkeys('/' . GetSelected(), 'n')<CR>
" }}}
" }}}
