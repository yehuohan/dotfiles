let s:use = SvarUse()

" Options {{{
" Defaults {{{
set synmaxcol=512                       " 最大高亮列数
set number                              " 显示行号
set relativenumber                      " 显示相对行号
set numberwidth=1                       " 行号最小宽度
set signcolumn=number                   " 共用number的区域用于显示sign
set cursorline                          " 高亮当前行
set cursorcolumn                        " 高亮当前列
set colorcolumn=80                      " 设置宽度参考线
set hlsearch                            " 设置高亮显示查找到的文本
set incsearch                           " 预览当前的搜索内容
set termguicolors                       " 在终端中使用24位彩色
set expandtab                           " 将Tab用Space代替，方便显示缩进标识indentLine
set tabstop=4                           " 设置Tab键宽4个空格
set softtabstop=4                       " 设置按<Tab>或<BS>移动的空格数
set shiftwidth=4                        " 设置>和<命令移动宽度为4
set nowrap                              " 默认关闭折行
set noequalalways                       " 禁止自动调窗口大小
set textwidth=0                         " 关闭自动换行
set listchars=tab:ﲒ,eol:↲,space:·,nbsp:␣,precedes:<,extends:>,trail:~
                                        " 不可见字符显示, ' ﲒ ײַ'
let &showbreak='↪ '                     " wrap标志符
set autoindent                          " 使用autoindent缩进
set nobreakindent                       " 折行时不缩进
set conceallevel=2                      " 显示高样样式中conceal掉的字符
set concealcursor=nvic                  " 设置nvic模式下不显示conceal掉的字符
set foldenable                          " 充许折叠
set foldopen-=search                    " 查找时不自动展开折叠
set foldcolumn=0                        " 0~12,折叠标识列，分别用“-”和“+”而表示打开和关闭的折叠
set foldmethod=indent                   " 设置折叠，默认为缩进折叠
set foldlevel=99                        " 折叠层数，高于level的会自动折叠
set foldlevelstart=99                   " 编辑另一个buffer时设置的foldlevel值
set scrolloff=3                         " 光标上下保留的行数
set nostartofline                       " 执行滚屏等命令时，不改变光标列位置
set laststatus=2                        " 一直显示状态栏
set noshowmode                          " 命令行栏不显示VISUAL等字样
set completeopt=menuone,preview         " 补全显示设置
set wildmenu                            " 使能命令补全
set backspace=indent,eol,start          " Insert模式下使用BackSpace删除
set title                               " 允许设置titlestring
set hidden                              " 允许在未保存文件时切换buffer
set bufhidden=                          " 跟随hidden设置
set nobackup                            " 不生成备份文件
set nowritebackup                       " 覆盖文件前，不生成备份文件
set autochdir                           " 自动切换当前目录为当前文件所在的目录
set noautowrite                         " 禁止自动保存文件
set noautowriteall                      " 禁止自动保存文件
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,latin1
                                        " 解码尝试序列
set fileformat=unix                     " 以unix格式保存文本文件，即CR作为换行符
set magic                               " 默认使用magic匹配
set ignorecase                          " 不区别大小写搜索
set smartcase                           " 有大写字母时才区别大小写搜索
set notildeop                           " 使切换大小写的~，类似于c,y,d等操作符
set nrformats=bin,octal,hex,alpha       " CTRL-A-X支持数字和字母
set mouse=a                             " 使能鼠标
set noimdisable                         " 不禁用输入法
set nospell                             " 默认关闭拼写检查
set spelllang=en_us                     " 设置拼写语言
set visualbell                          " 使用可视响铃代替鸣声
set noerrorbells                        " 关闭错误信息响铃
set belloff=all                         " 关闭所有事件的响铃
set timeout                             " 打开映射超时检测
set ttimeout                            " 打开键码超时检测
set timeoutlen=1000                     " 映射超时时间为1000ms
set ttimeoutlen=70                      " 键码超时时间为70ms

" 终端Alt键映射处理：如 Alt+x，实际连续发送 <Esc>x 的键码
"<1> set <M-x>=x                      " 设置键码，这里的是一个字符，即<Esc>的键码（按i-C-v, i-C-[输入）
"    nnoremap <M-x>  :CmdTest<CR>       " 按键码超时时间检测
"<2> nnoremap <Esc>x :CmdTest<CR>       " 按映射超时时间检测
"<3> nnoremap x    :CmdTest<CR>       " 按映射超时时间检测
for t in split('q w e r t y u i o p a s d f g h j k l z x c v b n m ; , .', ' ')
    execute 'set <M-'. t . '>=' . t
endfor

if &term == 'xterm' || &term == 'xterm-256color'
    set t_vb=                           " 关闭终端可视闪铃，即normal模式时按esc会有响铃
    let &t_SI = "\<Esc>[6 q"            " 进入Insert模式，5,6:竖线
    let &t_SR = "\<Esc>[3 q"            " 进入Replace模式，3,4:横线
    let &t_EI = "\<Esc>[2 q"            " 退出Insert模式，1,2:方块
endif
" }}}

" Struct: s:opt {{{
let s:opt = {
    \ 'lst' : {
        \ 'conceallevel' : [2, 0],
        \ 'virtualedit'  : ['all', ''],
        \ 'laststatus'   : [2, 3],
        \ },
    \ 'fns' : {},
    \ }
" Function: s:opt.fns.number() dict {{{ 切换显示行号
function! s:opt.fns.number() dict
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

" Function: s:opt.fns.syntax() {{{ 切换高亮
function! s:opt.fns.syntax()
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

" Function: OptionInv(opt) {{{ 切换参数值（bool取反）
function! OptionInv(opt)
    execute printf('setlocal inv%s', a:opt)
    echo printf('%s = %s', a:opt, eval('&' . a:opt))
endfunction
" }}}

" Function: OptionLst(opt) {{{ 切换参数值（列表循环取值）
function! OptionLst(opt)
    let l:lst = s:opt.lst[a:opt]
    let l:idx = index(l:lst, eval('&' . a:opt))
    let l:idx = (l:idx + 1) % len(l:lst)
    execute printf('set %s=%s', a:opt, l:lst[l:idx])
    echo printf('%s = %s', a:opt, eval('&' . a:opt))
endfunction
" }}}

" Function: OptionFns(opt) {{{ 切换参数值（函数取值）
function! OptionFns(opt)
    call s:opt.fns[a:opt]()
endfunction
" }}}

nnoremap <leader>iw :call OptionInv('wrap')<CR>
nnoremap <leader>il :call OptionInv('list')<CR>
nnoremap <leader>ii :call OptionInv('ignorecase')<CR>
nnoremap <leader>ie :call OptionInv('expandtab')<CR>
nnoremap <leader>ib :call OptionInv('scrollbind')<CR>
nnoremap <leader>ip :call OptionInv('spell')<CR>
nnoremap <leader>iv :call OptionLst('virtualedit')<CR>
nnoremap <leader>ic :call OptionLst('conceallevel')<CR>
nnoremap <leader>is :call OptionLst('laststatus')<CR>
nnoremap <leader>in :call OptionFns('number')<CR>
nnoremap <leader>ih :call OptionFns('syntax')<CR>
" }}}

" Autocmds {{{
" Function: s:onLargeFile() {{{
function! s:onLargeFile()
    let l:fsize = getfsize(Expand('<afile>'))
    if l:fsize >= 5 * 1024 * 1024 || l:fsize == -2
        let b:statusline_check_enabled = v:false
        set eventignore+=FileType
        setlocal undolevels=-1
        setlocal noswapfile
    else
        set eventignore-=FileType
    endif
endfunction
" }}}

" Function: s:onWinAlter(flag) {{{
function! s:onWinAlter(flag)
    if a:flag
        " Alter enter
        if exists('b:alter_view') && (!&diff) && (&filetype !=# 'qf')
            call winrestview(b:alter_view)
            unlet! b:alter_view
        endif
    else
        " Alter leave
        if (!&diff) && (&filetype!=# 'qf')
            let b:alter_view = winsaveview()
        endif
    endif
endfunction
" }}}

augroup SetupCmd
    autocmd!
    autocmd BufNewFile *                            setlocal fileformat=unix
    autocmd BufRead,BufNewFile *.nvim               setlocal filetype=vim
    autocmd BufRead,BufNewFile *.tex                setlocal filetype=tex
    autocmd BufRead,BufNewFile *.log                setlocal filetype=log
    autocmd BufRead,BufNewFile *.usf,*.ush          setlocal filetype=hlsl
    autocmd BufRead,BufNewFile *.uproject,*.uplugin setlocal filetype=jsonc
    autocmd Filetype vim,tex                        setlocal foldmethod=marker
    autocmd Filetype c,cpp,rust                     setlocal foldmethod=syntax
    autocmd Filetype glsl,hlsl                      setlocal foldmethod=syntax
    autocmd Filetype python                         setlocal foldmethod=indent foldignore=
    autocmd FileType txt,log                        setlocal foldmethod=manual
    autocmd BufReadPre * call s:onLargeFile()
    autocmd BufEnter * call s:onWinAlter(v:true)
    autocmd BufLeave * call s:onWinAlter(v:false)
augroup END
" }}}

" Gui {{{
set guioptions=M                        " 完全禁用Gui界面元素
let g:did_install_default_menus = 1     " 禁止加载缺省菜单
let g:did_install_syntax_menu = 1       " 禁止加载Syntax菜单

function! GuiSetFonts(inc)
    let s:use.ui.font.size += a:inc
    let s:use.ui.font_wide.size += a:inc
    execute printf('set guifont=%s:h%d', escape(s:use.ui.font.name, ' '), s:use.ui.font.size)
    execute printf('set guifontwide=%s:h%d', escape(s:use.ui.font_wide.name, ' '), s:use.ui.font_wide.size)
endfunction
call GuiSetFonts(0)
nnoremap <k0> :call GuiSetFonts(0)<CR>
nnoremap <kPlus> :call GuiSetFonts(1)<CR>
nnoremap <kMinus> :call GuiSetFonts(-1)<CR>

set lines=25
set columns=90
set linespace=0
if IsWin()
    nnoremap <leader>tf
        \ <Cmd>call libcallnr('gvimfullscreen.dll', 'ToggleFullScreen', 0)<CR>
endif
" }}}

" Mappings {{{
" Basic {{{
" Mark跳转
nnoremap ' `
nnoremap ` '
" 回退操作
nnoremap <S-u> <C-r>
" 行移动
nnoremap > >>
nnoremap < <<
" 加减序号
noremap <leader>aj <C-x>
noremap <leader>ak <C-a>
vnoremap <leader>agj g<C-x>
vnoremap <leader>agk g<C-a>
" 大小写切换
noremap <leader>u ~
" 行移动
noremap j gj
noremap k gk
noremap <S-l> $
noremap <S-h> ^
" 折叠
nnoremap <leader>zc zC
nnoremap <leader>zo zO
nnoremap <leader>zm zM
nnoremap <leader>zr zR
" 滚屏
nnoremap <C-j> <C-e>
nnoremap <C-k> <C-y>
nnoremap <M-j> <C-d>
nnoremap <M-k> <C-u>
nnoremap <C-h> zh
nnoremap <C-l> zl
nnoremap <M-h> 16zh
nnoremap <M-l> 16zl
nnoremap zh zt
nnoremap zl zb
" 命令行
cnoremap <C-v> <C-r>+
cnoremap <C-p> <C-r>0
cnoremap <M-n> <Down>
cnoremap <M-m> <Up>
cnoremap <M-j> <C-n>
cnoremap <M-k> <C-p>
cnoremap <M-h> <Left>
cnoremap <M-l> <Right>
cnoremap <M-o> <C-Right>
cnoremap <M-i> <C-Left>
cnoremap <M-u> <C-b>
cnoremap <M-p> <C-e>
" }}}

" Cmdline {{{
nnoremap <leader>.         :call ExecLast(1)<CR>
nnoremap <leader><leader>. :call ExecLast(0)<CR>
nnoremap <C-;> @:
vnoremap <leader><leader>; <Cmd>call feedkeys(':' . GetSelected(''), 'n')<CR>
" 替换
nnoremap <leader><leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>
vnoremap <leader><leader>s <Cmd>call feedkeys(':%s/' . GetSelected('') . '/', 'n')<CR>
" 排序
nnoremap <leader><leader>S :sort fr //<Left>
vnoremap <leader><leader>S :<C-u>sort fr /\%><C-r>=getpos("'<")[2]-1<CR>c.*\%<<C-r>=getpos("'>")[2]+1<CR>c/
" 查看help文档
nnoremap <leader><leader>k :h <C-r><C-w>
vnoremap <leader><leader>k <Cmd>call feedkeys(':h ' . GetSelected(''), 'n')<CR>
" HEX编辑
nnoremap <leader>xx :%!xxd<CR>
nnoremap <leader>xr :%!xxd -r<CR>
" }}}

" Search {{{
nnoremap <leader><Esc> :nohlsearch<CR>
nnoremap i <Cmd>nohlsearch<CR>i
nnoremap <leader>8 *
nnoremap <leader>3 #
nnoremap <leader>* /\V\C\<<C-r><C-w>\><CR>
nnoremap <leader># ?\V\C\<<C-r><C-w>\><CR>
vnoremap <leader>8 /\V\c\<<C-r>=escape(GetSelected(''), '\/')<CR>\><CR>
vnoremap <leader>3 ?\V\c\<<C-r>=escape(GetSelected(''), '\/')<CR>\><CR>
nnoremap <leader>/ /\V\c<C-r><C-w><CR>
vnoremap <leader>/ /\V\c<C-r>=escape(GetSelected(''), '\/')<CR><CR>
nnoremap <leader><leader>/ /<C-r><C-w>
vnoremap <leader><leader>/ /<C-r>=GetSelected('')<CR>
" }}}

" Copy & Paste {{{
" 行复制
nnoremap yL y$
nnoremap yH y^
" yank append
nnoremap ya
    \ <Cmd>
    \ execute 'silent normal! "9' . v:count1 . 'yy' <Bar>
    \ let @0 .= @" <Bar>
    \ echo v:count1 . ' lines append' <CR>
nnoremap yd
    \ <Cmd>
    \ execute 'silent normal! ' . v:count1 . 'dd' <Bar>
    \ let @0 .= @" <Bar>
    \ echo v:count1 . ' deleted lines append' <CR>
nnoremap <leader>p "0p
nnoremap <leader>P "0P
nnoremap <leader>ap p`[<Left>
nnoremap <leader>aP P`[
" ctrl-c & ctrl-v
vnoremap <leader>c "+y
nnoremap <leader>cp "+p
nnoremap <leader>cP "+P
vnoremap <C-c> "+y
nnoremap <C-v> "+p
inoremap <C-v> <Esc>"+pa
inoremap <M-v> <C-v>
" 矩形选择
noremap vv <C-v>
xnoremap <C-g> <C-g><Cmd>echo 'mode: ' . string(mode(1))<CR>
snoremap <C-g> <C-g><Cmd>echo 'mode: ' . string(mode(1))<CR>

for t in split('q w e r t y u i o p a s d f g h j k l z x c v b n m 0 1 2 3 4 5 6 7 8 9', ' ')
    " 寄存器快速复制与粘贴
    execute printf('vnoremap <leader>''%s "%sy', t, t)
    execute printf('nnoremap <leader>''%s "%sp', t, t)
    execute printf('nnoremap <leader>''%s "%sP', toupper(t), t)
    " 快速执行宏
    execute printf('nnoremap <leader>2%s :call ExecMacro("%s")<CR>', t, t)
endfor
" }}}

" Tab, Buffer, Window {{{
" FUNCTION: WinMoveSpliter(dir, inc) range {{{ 移动窗口的分界，改变窗口大小
" 只有最bottom-right的窗口是移动其top-left的分界，其余窗口移动其bottom-right分界
function! WinMoveSpliter(dir, inc) range
    let l:wnr = winnr()
    let l:pos = win_screenpos(l:wnr)
    let l:hei = winheight(l:wnr) + l:pos[0] + &cmdheight
    let l:wid = winwidth(l:wnr) - 1 + l:pos[1]
    let l:all_hei = &lines
    let l:all_wid = &columns

    let l:inc = a:inc * v:count1
    if a:dir ==# 'e'
        execute printf('resize%s%d', (l:hei >= l:all_hei && l:pos[0] >= 3) ? '+' : '-', l:inc)
    elseif a:dir ==# 'd'
        execute printf('resize%s%d', (l:hei >= l:all_hei && l:pos[0] >= 3) ? '-' : '+', l:inc)
    elseif a:dir ==# 's'
        execute printf('vertical resize%s%d', l:wid >= l:all_wid ? '+' : '-', l:inc)
    elseif a:dir ==# 'f'
        execute printf('vertical resize%s%d', l:wid >= l:all_wid ? '-' : '+', l:inc)
    endif
endfunction
" }}}

" tab/buffer切换(使用Popc的tab切换)
"nnoremap <M-u> gT
"nnoremap <M-p> gt
nnoremap <leader>bl <C-^>
nnoremap <leader>ba <Cmd>execute ':tabnext ' . tabpagenr('#')<CR>
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
nnoremap <silent> <M-e> <Cmd>call WinMoveSpliter('e', 5)<CR>
nnoremap <silent> <M-s> <Cmd>call WinMoveSpliter('s', 5)<CR>
nnoremap <silent> <M-f> <Cmd>call WinMoveSpliter('f', 5)<CR>
nnoremap <silent> <M-d> <Cmd>call WinMoveSpliter('d', 5)<CR>
nnoremap <silent> <M-E> <Cmd>call WinMoveSpliter('e', 1)<CR>
nnoremap <silent> <M-D> <Cmd>call WinMoveSpliter('d', 1)<CR>
nnoremap <silent> <M-S> <Cmd>call WinMoveSpliter('s', 1)<CR>
nnoremap <silent> <M-F> <Cmd>call WinMoveSpliter('f', 1)<CR>
" }}}

" Quickfix {{{
" Function: QuickfixType() {{{ quickfix类型
function! QuickfixType()
    let l:type = ''
    if &filetype ==# 'qf'
        let l:dict = getwininfo(win_getid())
        if l:dict[0].quickfix && !l:dict[0].loclist
            let l:type = 'c'
        elseif l:dict[0].quickfix && l:dict[0].loclist
            let l:type = 'l'
        endif
    endif
    return l:type
endfunction
" }}}

" Function: QuickfixPreview() {{{ 预览
function! QuickfixPreview()
    let l:type = QuickfixType()
    if !empty(l:type)
        let l:last_winnr = winnr()
        execute l:type . 'rewind ' . line('.')
        silent! normal! zOzz
        execute l:last_winnr . 'wincmd w'
    endif
endfunction
" }}}

" Function: QuickfixTabEdit() {{{ 新建Tab打开窗口
function! QuickfixTabEdit()
    let l:type = QuickfixType()
    if !empty(l:type)
        let l:enr = line('.')
        tabedit
        execute l:type . 'rewind ' . l:enr
        silent! normal! zOzz
        execute 'botright ' . l:type . 'open'
    endif
endfunction
" }}}

" Function: QuickfixIconv() {{{ 编码转换
function! QuickfixIconv()
    let l:type = QuickfixType()
    if !empty(l:type)
        call PopSelection({
            \ 'opt' : 'select encoding',
            \ 'lst' : ['"cp936", "utf-8"', '"utf-8", "cp936"'],
            \ 'cmd' : 'QuickfixDoIconv',
            \ 'arg' : l:type,
            \ })
    endif
endfunction

function! QuickfixDoIconv(sopt, argstr, type)
    let [l:from, l:to] = GetArgs(a:argstr)
    if a:type ==# 'c'
        let l:list = getqflist()
        for t in l:list
            let t.text = iconv(t.text, l:from, l:to)
        endfor
        call setqflist(l:list)
    elseif a:type ==# 'l'
        let l:list = getloclist(0)
        for t in l:list
            let t.text = iconv(t.text, l:from, l:to)
        endfor
        call setloclist(0, l:list)
    endif
endfunction
" }}}

nnoremap <leader>qo <Cmd>botright copen<CR>
nnoremap <leader>qO <Cmd>cclose <Bar> vertical botright copen 55<CR>
nnoremap <leader>qc
    \ <Cmd>
    \ if &filetype ==# 'qf' <Bar> wincmd p <Bar> endif <Bar>
    \ cclose<CR>
nnoremap <leader>qj <Cmd>cnext <Bar> silent! normal! zOzz<CR>
nnoremap <leader>qJ <Cmd>clast <Bar> silent! normal! zOzz<CR>
nnoremap <leader>qk <Cmd>cprevious <Bar> silent! normal! zOzz<CR>
nnoremap <leader>qK <Cmd>cfirst <Bar> silent! normal! zOzz<CR>
nnoremap <leader>lo <Cmd>botright lopen<CR>
nnoremap <leader>lO <Cmd>lclose <Bar> vertical botright lopen 35<CR>
nnoremap <leader>lc
    \ <Cmd>
    \ if &filetype ==# 'qf' <Bar> wincmd p <Bar> endif <Bar>
    \ lclose<CR>
nnoremap <leader>lj <Cmd>lnext <Bar> silent! normal! zOzz<CR>
nnoremap <leader>lJ <Cmd>llast <Bar> silent! normal! zOzz<CR>
nnoremap <leader>lk <Cmd>lprevious <Bar> silent! normal! zOzz<CR>
nnoremap <leader>lK <Cmd>lfirst <Bar> silent! normal! zOzz<CR>
nnoremap <C-Space>  :call QuickfixPreview()<CR>
nnoremap <leader>qt :call QuickfixTabEdit()<CR>
nnoremap <leader>qi :call QuickfixIconv()<CR>
" 将quickfix中的内容复制location-list
nnoremap <leader>ql
    \ <Cmd>
    \ call setloclist(0, getqflist()) <Bar>
    \ vertical botright lopen 35<CR>
" }}}

" Diff {{{
nnoremap <leader>ds <Cmd>call Input2Fn(['File: ', '', 'file', Expand('%', ':p:h')], {filename -> execute('diffsplit ' . filename)})<CR>
nnoremap <leader>dv <Cmd>call Input2Fn(['File: ', '', 'file', Expand('%', ':p:h')], {filename -> execute('vertical diffsplit ' . filename)})<CR>
" 比较当前文件（已经分屏）
nnoremap <leader>dt :diffthis<CR>
nnoremap <leader>do :diffoff<CR>
nnoremap <leader>du :diffupdate<CR>
nnoremap <leader>dp <Cmd>execute '.,+' . string(v:count1-1) . 'diffput'<CR>
nnoremap <leader>dg <Cmd>execute '.,+' . string(v:count1-1) . 'diffget'<CR>
nnoremap <leader>dj ]c
nnoremap <leader>dk [c
" }}}
" }}}
