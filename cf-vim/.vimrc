"
"
" vimrc, one configuration for vim, gvim, neovim and neovim-qt.
" yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
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
"   :s/\s\+$//g
"       去除尾部空格
"
" search with match force
" /\<the\> : can match chars in "for the vim", but can not match chars in "there"
" /the     : can match chars in "for the vim" and also in "there"
" }}}

" 第三方软件
" {{{
" Python      : 需要在vim编译时添加Python支持
" LLVM(Clang) : YouCompleteMe补全
" Ctags       : 查找创建标签
" Fzf         : Fzf模糊查找
" Ag          : Ag文本查找
" Chrome      : Markdown,ReStructruedText等标记文本预览
" Fcitx       : Linux下的输入法
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
endfunction
" }}}

" }}}


"===============================================================================
" Global settings
"===============================================================================
" {{{
set nocompatible                        " 不兼容vi快捷键
let mapleader="\<space>"                " 使用Space作为leader
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
    set rtp+=$VimPluginPath             " add .vim or vimfiles to rtp(runtimepath)

    " 浏览器路径
    let s:path_browser = ""
    if IsWin()
        let s:path_browser = '"C:/Program Files (x86)/Google/Chrome/Application/chrome.exe"'
    elseif IsLinux()
        let s:path_browser = '"/usr/bin/google-chrome"'
    endif
" }}}

" 键码设定
" {{{
set timeout                             " 打开映射超时检测
set ttimeout                            " 打开键码超时检测
set timeoutlen=1000                     " 映射超时时间为1000ms
set ttimeoutlen=70                      " 键码超时时间为70ms

" 键码示例 {{{
    " 终端Alt键映射处理：如 Alt+x，实际连续发送 <esc>x 编码
    " 以下三种方法都可以使按下 Alt+x 后，执行 CmdTest 命令，但超时检测有区别
    "<1> set <M-x>=x  " 设置键码，这里的是一个字符，即<esc>的编码，不是^和[放在一起
                        " 在终端的Insert模式，按Ctrl+v再按Alt+x可输入
    "    nnoremap <M-x> :CmdTest<CR>    " 按键码超时时间检测
    "<2> nnoremap <esc>x :CmdTest<CR>   " 按映射超时时间检测
    "<3> nnoremap x  :CmdTest<CR>     " 按映射超时时间检测
" }}}

" 键码设置 {{{
if !IsNVim()
    set encoding=utf-8                  " 内部内部需要使用utf-8编码
    set <M-d>=d
    set <M-f>=f
    set <M-h>=h
    set <M-i>=i
    set <M-j>=j
    set <M-k>=k
    set <M-l>=l
    set <M-n>=n
    set <M-m>=m
    set <M-o>=o
    set <M-p>=p
    set <M-u>=u
endif
" }}}

" }}}

" }}}


"===============================================================================
" User Defined functions
"===============================================================================
" {{{
" 隐藏字符显示 " {{{
function! InvConceallevel()
    if &conceallevel == 0
        set conceallevel=2
    else
        set conceallevel=0              " 显示markdown等格式中的隐藏字符
    endif
endfunction
" }}}

" 透明背影控制（需要系统本身支持透明） " {{{
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

" 切换显示行号 " {{{
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

" 切换显示折叠列 " {{{
function! InvFoldColumeShow()
    if &foldcolumn == 0
        set foldcolumn=1
    else
        set foldcolumn=0
    endif
endfunction
" }}}

" 切换显示标志列 {{{
function! InvSigncolumn()
    if &signcolumn == "auto"
        set signcolumn=no
    else
        set signcolumn=auto
    endif
endfunction
" }}}

" 切换高亮 {{{
function! InvHighLight()
    if exists("g:syntax_on")
        syntax off
    else
        syntax on
    endif
endfunction
" }}}

" linux-fcitx输入法切换 " {{{
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

" 编译环境函数 " {{{
" Set autochdir is required.
set autochdir

" FUNCTION: ComplileFile(argstr) {{{
" @param argstr: 想要传递的命令参数
function! ComplileFile(argstr)
    let l:ext = expand("%:e")                       " 扩展名
    let l:filename = '"./' . expand('%:t') . '"'    " 文件名，不带路径，带扩展名
    let l:name = '"./' . expand('%:t:r') . '"'      " 文件名，不带路径，不带扩展名
    let l:exec_str = "!"
    if exists(":AsyncRun") == 2
        let l:exec_str = ":AsyncRun "
    endif

    " Create execute string
    if "c" ==? l:ext
        let l:exec_str .= "gcc " . a:argstr . " -o " . l:name . " " . l:filename
        let l:exec_str .= " && " . l:name
    elseif "cpp" ==? l:ext
        let l:exec_str .= "g++ -std=c++11 " . a:argstr . " -o " . l:name . " " . l:filename
        let l:exec_str .= " && " . l:name
    elseif "py" ==? l:ext || "pyw" ==? l:ext
        let l:exec_str .= "python " . l:filename
    elseif "pro" ==? l:ext
        if IsLinux()
            let l:exec_str .= "qmake " . a:argstr . " -r -o ./DebugV/Makefile " . l:filename
            let l:exec_str .= " && cd ./DebugV"
            let l:exec_str .= " && make"
        elseif IsWin()
            let l:exec_str .= " mkdir DebugV"
            let l:exec_str .= " & cd DebugV"
            " Attetion: here shouls be <qmake ../file.pro>
            let l:exec_str .= " && qmake " . a:argstr . " -r ." . l:filename
            let l:exec_str .= " && vcvars32.bat"
            let l:exec_str .= " && nmake -f Makefile.Debug"
            " Attention: executed file must be in the same directory with .pro file
            let l:exec_str .= " && cd .."
        else
            return
        endif
        let l:exec_str .= " && " . l:name
    elseif "go" ==? l:ext
        let l:exec_str .= " go run " . l:filename
    elseif "m" ==? l:ext
        let l:exec_str .= "matlab -nosplash -nodesktop -r " . l:name[3:-2]
    elseif "sh" ==? l:ext
        if IsLinux() || IsGw()
            let l:exec_str .= " ./" . l:filename
        else
            return
        endif
    elseif "bat" ==? l:ext
        if IsWin()
            let l:exec_str .= " " . l:filename
        else
            return
        endif
    else
        return
    endif

    " execute shell code
    execute l:exec_str
endfunction
" }}}

" FUNCTION: ComplileFileArgs(sopt, arg) {{{
function! ComplileFileArgs(sopt, arg)
    if a:arg ==# "charset"
        call ComplileFile('-finput-charset=utf-8 -fexec-charset=gbk')
    endif
endfunction
" }}}

" FUNCTION: FindProjectFile(...) {{{
" @param 1: 工程文件，如*.pro
" @param 2: 查找起始目录，默认从当前目录向上查找到根目录
function! FindProjectFile(...)
    if a:0 == 0
        return ""
    endif
    let l:marker = a:1
    let l:dir = (a:0 >= 2) ? a:2 : "."
    let l:prj_dir      = fnamemodify(l:dir, ":p:h")
    let l:prj_dir_last = ""
    let l:prj_file     = ""

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

" FUNCTION: ComplileProject(str, fn) {{{
" @param str: 工程文件名，可用通配符，如*.pro
" @param fn: 编译工程文件的函数，需要采用popset插件
function! ComplileProject(str, fn)
    let l:prj = FindProjectFile(a:str)
    if len(l:prj) == 1
        let Fn = function(a:fn)
        call Fn('', l:prj[0])
    elseif len(l:prj) > 1
        call PopSelection({
            \ 'opt' : ['Please Select your project file'],
            \ 'lst' : l:prj,
            \ 'dic' : {},
            \ 'cmd' : a:fn,
            \}, 0)
    endif
endfunction
" }}}

" FUNCTION: ComplileProjectQmake(sopt, sel) {{{
function! ComplileProjectQmake(sopt, sel)
    let l:filename = '"./' . fnamemodify(a:sel, ":p:t") . '"'
    let l:name = '"./' . fnamemodify(a:sel, ":t:r") . '"'
    let l:filedir = fnameescape(fnamemodify(a:sel, ":p:h"))
    let l:olddir = fnameescape(getcwd())
    let l:exec_str = "!"
    if exists(":AsyncRun") == 2
        let l:exec_str = ":AsyncRun "
    endif

    " change cwd
    execute "lcd " . l:filedir

    " execute shell code
    if IsLinux()
        let l:exec_str .= "qmake " . " -r -o ./DebugV/Makefile " . l:filename
        let l:exec_str .= " && cd ./DebugV"
        let l:exec_str .= " && make"
    elseif IsWin()
        let l:exec_str .= " mkdir DebugV"
        let l:exec_str .= " & cd DebugV"
        " Attetion: here shouls be <qmake ../file.pro>
        let l:exec_str .= " && qmake " . " -r ." . l:filename
        let l:exec_str .= " && vcvars32.bat"
        let l:exec_str .= " && nmake -f Makefile.Debug"
        " Attention: executed file must be in the same directory with .pro file
        let l:exec_str .= " && cd .."
    else
        return
    endif
    let l:exec_str .= " && " . l:name
    execute l:exec_str

    " change back cwd
    execute "lcd " . l:olddir
endfunction
" }}}

" Run compliler
let RC_Qmake = function('ComplileProject', ['*.pro', 'ComplileProjectQmake'])

" }}}

" FindVimgrep搜索 " {{{
" FindVimgrep map-keys {{{
let s:findvimgrep_nmaps = ["fi", "fgi", "fI", "fgI",
                         \ "fw", "fgw", "fW", "fgW",
                         \ "fs", "fgs", "fS", "fgS",
                         \ "Fi", "Fgi", "FI", "FgI",
                         \ "Fw", "Fgw", "FW", "FgW",
                         \ "Fs", "Fgs", "FS", "FgS",
                         \ ]
let s:findvimgrep_vmaps = ["fi", "fgi", "fI", "fgI",
                         \ "fv", "fgv", "fV", "fgV",
                         \ "fs", "fgs", "fS", "fgS",
                         \ "Fi", "Fgi", "FI", "FgI",
                         \ "Fv", "Fgv", "FV", "FgV",
                         \ "Fs", "Fgs", "FS", "FgS",
                         \ ]
" }}}

" FUNCTION: GetMultiFilesCompletion(arglead, cmdline, cursorpos) {{{
function! GetMultiFilesCompletion(arglead, cmdline, cursorpos)
    let l:complete = []
    let l:arglead_list = [""]
    let l:arglead_first = ""
    let l:arglead_glob = ""
    let l:files_list = []

    " process glob path-string
    if !empty(a:arglead)
        let l:arglead_list = split(a:arglead, " ")
        let l:arglead_first = join(l:arglead_list[0:-2], " ")
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
            call add(l:complete, l:arglead_first . " " . item)
        endfor
    endif
    return l:complete
endfunction
" }}}

" FUNCTION: FindVimgrep(type) {{{
function! FindVimgrep(type, mode)
    " {{{
    " Normal Mode: mode='n'
    " i : find input
    " w : find word
    " s : find word with \< \>
    "
    " Visual Mode: mode='v'
    " i : find input    with selected
    " v : find visual   with selected
    " s : find selected with \< \>
    "
    " LowerCase: [iwvs] for find with user's ignorecase or smartcase setting
    " UpperCase: [IWVS] for find in case match
    "
    " Other:
    " f : find with vimgrep and show in quickfix
    " F : find with lvimgrep and show in location-list
    " g : find global with inputing path
    " }}}

    let l:string = ""
    let l:files = "%"
    let l:selected = ""

    " get what to vimgrep
    if a:mode ==# 'n'
        if a:type =~? 'i'
            let l:string = input(" What to find :")
        elseif a:type =~? '[ws]'
            let l:string = expand("<cword>")
        endif
    elseif a:mode ==# 'v'
        " get selected string in visual mode
        let l:reg_var = getreg('0', 1)
        let l:reg_mode = getregtype('0')
        normal! gv"0y
        let l:selected = getreg('0')
        call setreg('0', l:reg_var, l:reg_mode)

        if a:type =~? 'i'
            let l:string = input(" What to find :", l:selected)
        elseif a:type =~? '[vs]'
            let l:string = l:selected
        endif
    endif

    " return when nothing was got
    if empty(l:string)
        return
    endif

    " match force
    if a:type =~? 's'
        let l:string = "\\<" . l:string . "\\>"
    endif

    " match case
    if a:type =~# '[IWVS]'
        let l:string = '\C' . l:string
    endif

    " get where to vimgrep
    if a:type =~# 'g'
        let l:files = input(" Where to find :", "", "customlist,GetMultiFilesCompletion")
        if empty(l:files)
            return
        endif
    endif

    " vimgrep or lvimgrep
    if a:type =~# 'f'
        silent! execute "vimgrep /" . l:string . "/j " . l:files
        echo "Finding..."
        if empty(getqflist())
            echo "No match: " . l:string
            return
        else
            " display search results
            if a:type =~# 'g'
                vertical botright copen
                wincmd =
            else
                botright copen
            endif
        endif
    elseif a:type =~# 'F'
        silent! execute "lvimgrep /" . l:string . "/j " . l:files
        echo "Finding..."
        if empty(getloclist(winnr()))
            echo "No match: " . l:string
            return
        else
            " display search results
            if a:type =~# 'g'
                vertical botright lopen
                wincmd =
            else
                botright lopen
            endif
        endif
    endif
endfunction
" }}}

" }}}

" 查找Vim关键字 {{{
function! GotoKeyword(mode)
    let l:word = expand("<cword>")
    let l:exec_str = "help "

    if a:mode ==# 'v'
        " get selected string in visual mode
        let l:reg_var = getreg('0', 1)
        let l:reg_mode = getregtype('0')
        normal! gv"0y
        let l:word = getreg('0')
        call setreg('0', l:reg_var, l:reg_mode)
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

" Quickfix相关函数 {{{
" 编码转换 {{{
"function! ConvQuickfix(type, if, it)
"    " type: 1 for quickfix, 0 for location-list
"    let qflist = (a:type) ? getqflist() : getloclist(winnr())
"    for i in qflist
"       let i.text = iconv(i.text, a:if , a:it)
"    endfor
"    call setqflist(qflist)
"endfunction
" }}}

" 预览 {{{
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

" }}}

" asd2num切换 " {{{
let s:asd2num_toggle_flg = 0
let s:asd2num_map_table={
            \ "a" : "1", "s" : "2", "d" : "3", "f" : "4", "g" : "5",
            \ "h" : "6", "j" : "7", "k" : "8", "l" : "9", ";" : "0"
            \ }
function! ToggleAsd2num()
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

" }}}


"===============================================================================
" Plug and Settings
"===============================================================================
" {{{
call plug#begin($VimPluginPath."/bundle")   " alternatively, pass a path where install plugins

" 基本编辑类
" {{{
" easy-motion {{{ 快速跳转
    Plug 'easymotion/vim-easymotion'
    let g:EasyMotion_do_mapping = 0     " 禁止默认map
    let g:EasyMotion_smartcase = 1      " 不区分大小写
    nmap s <Plug>(easymotion-overwin-f)
    nmap <leader>ms <plug>(easymotion-overwin-f2)
                                        " 跨分屏快速跳转到字母
    nmap <leader>j <plug>(easymotion-j)
    nmap <leader>k <plug>(easymotion-k)
    nmap <leader>mw <plug>(easymotion-w)
    nmap <leader>mb <plug>(easymotion-b)
    nmap <leader>me <plug>(easymotion-e)
    nmap <leader>mg <plug>(easymotion-ge)
    nmap <leader>W <plug>(easymotion-W)
    nmap <leader>B <plug>(easymotion-B)
    nmap <leader>E <plug>(easymotion-E)
    nmap <leader>gE <plug>(easymotion-gE)
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
    let g:multi_cursor_quit_key='<esc>'
" }}}

" vim-over {{{ 替换预览
    " substitute preview
    Plug 'osyo-manga/vim-over'
    nnoremap <leader>sp :OverCommandLine<CR>
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
    " *,# with \< \> and g*,g# without \< \>
    nmap *  <Plug>(incsearch-nohl-*)
    nmap #  <Plug>(incsearch-nohl-#)
    nmap g* <Plug>(incsearch-nohl-g*)
    nmap g# <Plug>(incsearch-nohl-g#)
    nmap <leader>8  <Plug>(incsearch-nohl-*)
    nmap <leader>3  <Plug>(incsearch-nohl-#)
    nmap <leader>g8 <Plug>(incsearch-nohl-g*)
    nmap <leader>g3 <Plug>(incsearch-nohl-g#)
" }}}

" fzf {{{ 模糊查找
    " linux下直接pacman -S fzf
    " win下载fzf.exe放入bundle/fzf/bin/下
    if IsWin()
        Plug 'junegunn/fzf'
    endif
    Plug 'junegunn/fzf.vim'
    let g:fzf_command_prefix = 'Fzf'
    nnoremap <leader>fl :FzfLines<CR>
    nnoremap <leader>fb :FzfBLines<CR>
    nnoremap <leader>ff :FzfFiles
" }}}

" ag {{{ Ag大范围查找
if executable('ag')
    Plug 'rking/ag.vim'
    " https://github.com/ggreer/the_silver_searcher
    let g:ag_prg="ag --vimgrep --smart-case"
endif
" }}}

" far {{{ 查找与替换
    Plug 'brooth/far.vim'
    let g:far#file_mask_favorites = ['%', '*.txt']
    nnoremap <leader>sr :Farp<CR>
                                        " Search and Replace, 使用Fardo和Farundo来更改替换结果
    nnoremap <leader>sf :F
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
    vnoremap <leader>a :Tabularize /
    nnoremap <leader>a :Tabularize /
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
" theme {{{ gruvbox主题
    Plug 'morhetz/gruvbox'
    set rtp+=$VimPluginPath/bundle/gruvbox/
    colorscheme gruvbox
    set background=dark                 " 选项：dark, light
    let g:gruvbox_contrast_dark='medium'
                                        " 选项：dark, medium, soft
" }}}

" air-line {{{ 状态栏
    Plug 'vim-airline/vim-airline'
    "Plug 'vim-airline/vim-airline-themes'
if !IsNVim()
    set renderoptions=                  " Required by airline for showing unicode
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

    let g:airline#extensions#ctrlspace#enabled = 1
                                        " 添加ctrlspace支持
    "let g:airline#extensions#ycm#enabled = 1
                                        " 添加YCM支持
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
    " <h,o,l,w,b,/,?> for buffer,file,tab,workspace,bookmark,search and help
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
    if executable("ag")
        let g:CtrlSpaceGlobCommand = 'ag -l --nocolor -g ""'
    endif
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
            \ "lst" : ["cpp", "c", "python", "vim", "go", "markdown", "help", "text",
                     \ "sh", "matlab", "conf", "make"],
            \ "dic" : {
                    \ "python" : "Python script file",
                    \ "vim"    : "Vim script file",
                    \ "help"   : "Vim help doc",
                    \ "sh"     : "Linux shell script",
                    \ "conf"   : "Config files",
                    \ "make"   : "makefile or .mak file",
                    \},
            \ "cmd" : "popset#data#SetEqual",
        \},
        \{
            \ "opt" : ["colorscheme", "colo"],
            \ "lst" : ["gruvbox"],
            \ "dic" : {"gruvbox" : "第三方主题"},
            \ "cmd" : "",
        \},
        \{
            \ "opt" : ["cppargs"],
            \ "lst" : ["charset"],
            \ "dic" : {
                    \ "charset" : "-finput-charset=utf-8 -fexec-charset=gbk",
                    \},
            \ "cmd" : "ComplileFileArgs",
        \},]
        " \{
        "     \ "opt" : ["AirlineTheme"],
        "     \ "lst" : popset#data#GetFileList($VimPluginPath.'/bundle/vim-airline-themes/autoload/airline/themes/*.vim'),
        "     \ "dic" : {},
        "     \ "cmd" : "popset#data#SetExecute",
        " \}]
    " set option with PSet
    nnoremap <leader>so :PSet
    nnoremap <leader>sa :PSet popset<CR>
" }}}

" nerd-tree{{{ 目录树导航
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
    noremap <leader>te :NERDTreeToggle<CR>
    noremap <leader>tE :NERDTree<CR>
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
    nnoremap <leader>qa :SDelete! default<CR><bar>:SSave default<CR><bar>:qa<CR>
                                        " 先删除默认的，再保存会话，最后退出所有窗口
    nnoremap <leader>su :Startify<CR>   " start ui of vim-startify
" }}}

" bookmarks {{{ 书签管理
    Plug 'MattesGroeger/vim-bookmarks'
    let g:bookmark_sign = '⚑'
    let g:bookmark_annotation_sign = '☰'
    let g:bookmark_no_default_key_mappings = 1
                                        " 禁用默认key-maps
    let g:bookmark_auto_save = 1
    let g:bookmark_auto_save_file = $VimPluginPath."/bookmarks"
    let g:bookmark_save_per_working_dir = 0
                                        " 将所在标签保存在同一个文件
    let g:bookmark_show_toggle_warning = 0
                                        " 取消删除annotate标签的警告
    let g:bookmark_show_warning = 0     " 取消删除所有标签的警告
    let g:bookmark_location_list = 0    " 使用Location-list或Quickfix

    nnoremap <leader>mm :BookmarkToggle<CR>
    nnoremap <leader>mi :BookmarkAnnotate<CR>
    nnoremap <leader>ma :BookmarkShowAll<CR>
    nnoremap <leader>mj :BookmarkNext<CR>
    nnoremap <leader>mk :BookmarkPrev<CR>
    nnoremap <M-d> :BookmarkPrev<CR>
    nnoremap <M-f> :BookmarkNext<CR>
    nnoremap <leader>mc :BookmarkClear<CR>
    " nmap <leader>mx <Plug>BookmarkClearAll
    " nmap <leader>ml <Plug>BookmarkMoveToLine
    " nmap <leader>mkk <Plug>BookmarkMoveUp
    " nmap <leader>mjj <Plug>BookmarkMoveDown
" }}}

" undo {{{ 撤消历史
    Plug 'mbbill/undotree'
    nnoremap <leader>tu :UndotreeToggle<CR>
" }}}

" }}}

" 代码类
" {{{
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
    let g:ycm_enable_diagnostic_signs = 1
                                        " 开启语法检测
    let g:ycm_max_diagnostics_to_display = 30
    let g:ycm_warning_symbol = '►'      " Warning符号
    let g:ycm_error_symbol = '✘'        " Error符号
    let g:ycm_seed_identifiers_with_syntax = 1
                                        " 语法关键字补全
    let g:ycm_collect_identifiers_from_tags_files = 1
                                        " 开启标签补全
    let g:ycm_use_ultisnips_completer = 1
                                        " 开启UltiSnips补全
    let g:ycm_key_list_select_completion = ['<C-j>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<C-k>', '<Up>']
    let g:ycm_autoclose_preview_window_after_insertion=1
                                        " 自动关闭预览窗口
    let g:ycm_cache_omnifunc = 0        " 禁止缓存匹配项，每次都重新生成匹配项
    nnoremap <leader>gd :YcmCompleter GoToDefinitionElseDeclaration<CR>
    nnoremap <leader>gi :YcmCompleter GoToInclude<CR>
    nnoremap <leader>gt :YcmCompleter GoTo<CR>
    nnoremap <leader>yd :YcmShowDetailedDiagnostic<CR>
    nnoremap <leader>yf :YcmCompleter FixIt<CR>
    noremap <F4> :YcmDiags<CR>
                                        " 错误列表
" }}}

" vim-go {{{ Go开发环境
    Plug 'fatih/vim-go'
    " +YCM : 支持Go实时补全
    let g:go_doc_keywordprg_enabled=0   " 取消对K的映射
    let g:go_def_mapping_enabled=0      " 取消默认的按键映射
    let g:go_textobj_enabled=1          " 使用TextObject的映射
    let g:go_fmt_autosave = 0           " 禁用auto GoFmt
"}}}

" ultisnips {{{ 代码片段插入
if !(IsWin() && IsNVim())
    Plug 'SirVer/ultisnips'             " snippet插入引擎
    Plug 'honza/vim-snippets'           " snippet合集
    let g:UltiSnipsSnippetDirectories=["UltiSnips", "mySnippets"]
                                        " 自定义mySnippets合集
    let g:UltiSnipsExpandTrigger="<tab>"
    let g:UltiSnipsJumpForwardTrigger="<C-j>"
    let g:UltiSnipsJumpBackwardTrigger="<C-k>"
endif
" }}}

" surround and repeat {{{ 添加包围符
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-repeat'

    " 重新映射surround按键
    nmap <leader>sw ysiw
    nmap <leader>si ysw
    nmap <leader>sl yss
    nmap <leader>sL ySS
    " 重新映射Visual Mode下的surround按键
    vmap s S
    vmap <leader>s gS
" }}}

" auto-pairs {{{ 自动括号
    Plug 'jiangmiao/auto-pairs'
    let g:AutoPairsShortcutToggle=''
    let g:AutoPairsShortcutFastWrap=''
    let g:AutoPairsShortcutJump=''
    let g:AutoPairsShortcutFastBackInsert=''
    nnoremap <leader>tp :call AutoPairsToggle()<CR>
"}}}

" tagbar {{{ 代码结构预览
    Plug 'majutsushi/tagbar'
    if IsLinux()
        let g:tagbar_ctags_bin='/usr/bin/ctags'
    elseif IsWin()
        let g:tagbar_ctags_bin=$VIM."\\vim80\\ctags.exe"
    endif                               " 设置ctags路径，需要安装ctags
    let g:tagbar_width=30
    let g:tagbar_map_showproto=''       " 取消tagbar对<Space>的占用
    noremap <leader>tt :TagbarToggle<CR>
                                        " 可以 ctags -R 命令自行生成tags
" }}}

" nerd-commenter {{{ 批量注释
    Plug 'scrooloose/nerdcommenter'
    let g:NERDCreateDefaultMappings = 1
    let g:NERDSpaceDelims = 0           " 在Comment后添加Space
    nmap <leader>cc <plug>NERDCommenterComment
    nmap <leader>cm <plug>NERDCommenterMinimal
    nmap <leader>cs <plug>NERDCommenterSexy
    " nmap <leader>cb <plug>NERDCommenterAlignBoth  " 在vimrc中nmap有问题
    nmap <leader>cl <plug>NERDCommenterAlignLeft
    nmap <leader>ci <plug>NERDCommenterInvert
    nmap <leader>cy <plug>NERDCommenterYank
    nmap <leader>ce <plug>NERDCommenterToEOL
    nmap <leader>ca <plug>NERDCommenterAppend
    nmap <leader>cA <plug>NERDCommenterAltDelims
    nmap <leader>cu <plug>NERDCommenterUncomment
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
    Plug 'plasticboy/vim-markdown'
    Plug 'iamcco/mathjax-support-for-mkdp'
    Plug 'iamcco/markdown-preview.vim'
    let g:mkdp_path_to_chrome = s:path_browser
    let g:mkdp_auto_start = 0
    let g:mkdp_auto_close = 1
    let g:mkdp_refresh_slow = 0         " 即时预览MarkDown
    let g:mkdp_command_for_global = 0   " 只有markdown文件可以预览
    nnoremap <leader>vm :call PreViewMarkdown()<CR>
    function! PreViewMarkdown() abort
        if exists(':MarkdownPreviewStop')
            MarkdownPreviewStop
            echo "MarkdownPreviewStop"
        else
            MarkdownPreview
            echo "MarkdownPreview"
        endif
    endfunction
" }}}

" reStructruedText {{{
    " 需要安装 https://github.com/Rykka/instant-rst.py
    Plug 'Rykka/riv.vim'
    Plug 'Rykka/InstantRst'
    let g:instant_rst_browser = s:path_browser
if IsWin()
    " 需要安装 https://github.com/mgedmin/restview
    nnoremap <leader>vr :execute "AsyncRun restview " . expand("%:p:t")<bar>cclose<CR>
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
" }}}

" }}}

" 游戏
" {{{
    "Plug 'johngrib/vim-game-code-break'
    " VimGameCodeBreak
    "Plug 'johngrib/vim-game-snake'
    " VimGameSnake
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

" neovim gui font {{{ 字体设置(neovim已内置)
    "if IsNVim()
    "    Plug 'equalsraf/neovim-gui-shim'
    "endif
" }}}

" splitjoin {{{ 行间连接与分割
    "Plug 'AndrewRadev/splitjoin.vim'
    "nnoremap <leader>gj gJ
    "nnoremap <leader>gs gS
" }}}

" DrawIt {{{ 画图
    "Plug 'vim-scripts/DrawIt'
" }}}

" grammarous {{{ 文字拼写检查
    "Plug 'rhysd/vim-grammarous'
    " 中文支持不好
" }}}

" vim-latex {{{
    "Plug 'vim-latex/vim-latex'
" }}}

" qml {{{ qml高亮
    "Plug 'crucerucalin/qml.vim'
" }}}

" }}}

call plug#end()                         " required
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
    set tabstop=4                       " 设置tab键宽4个空格
    set softtabstop=4                   " 设置显示的Tab缩进为4,实际Tab可以不是4个格
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
    set nobackup                        " 不生成备份文件
    set nowritebackup                   " 不生成备份文件
    set autochdir                       " 自动切换当前目录为当前文件所在的目录
    set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
                                        " 尝试解码序列
    set encoding=utf-8                  " vim内部使用utf-8编码
    set fileformat=unix                 " 以unix格式保存文本文件，即CR作为换行符
    set ignorecase                      " 不区别大小写搜索
    set smartcase                       " 有大写字母时才区别大小写搜索
    set noimdisable                     " 切换Normal模式时，自动换成英文输入法
    set noerrorbells                    " 关闭错误信息响铃
    set vb t_vb=                        " 关闭响铃(vb, visualbell)和可视闪铃(t_vb，即闪屏)，即normal模式时按esc会有响铃
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
        "set guifont=Ubuntu\ Mono\ 13
        "set guifont=DejaVu\ Sans\ Mono\ 13
        set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 12
                                        " https://github.com/powerline/fonts
        set linespace=0                 " required by DejaVuSansMono for Powerline
        set guifontwide=WenQuanYi\ Micro\ Hei\ Mono\ 12
    elseif IsWin()
        set lines=25
        set columns=100
        "set guifont=Consolas:h13:cANSI
        set guifont=Consolas_For_Powerline:h13:cANSI
        set linespace=0                 " required by PowerlineFont
        set guifontwide=Microsoft_YaHei_Mono:h12:cGB2312
        noremap <F11> <esc>:call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>
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

    " auto-setting
    autocmd BufNewFile *    set fileformat=unix
    autocmd GuiEnter *      set t_vb=   " 关闭可视闪铃(即闪屏)
    autocmd BufEnter *.tikz set filetype=tex

    autocmd Filetype vim    setlocal foldmethod=marker
    autocmd Filetype c      setlocal foldmethod=syntax
    autocmd Filetype cpp    setlocal foldmethod=syntax
    autocmd Filetype python setlocal foldmethod=indent
    autocmd FileType go     setlocal expandtab

    " map
    autocmd Filetype vim nnoremap <buffer>          <S-k> :call GotoKeyword('n')<CR>
    autocmd Filetype vim vnoremap <buffer>          <S-k> :call GotoKeyword('v')<CR>
if -1 != match(g:plugs_order, "^vim-go$")
    " g:plugs_order是vim-plug中的变量
    autocmd FileType go setlocal errorformat&
    autocmd FileType go  nnoremap <buffer> <silent> <leader>gc :execute ":GoDoc " . expand("<cword>")<CR>
    autocmd FileType go  nnoremap <buffer> <silent> <leader>gb :GoBuild<CR>
    autocmd FileType go  nnoremap <buffer> <silent> <leader>gd :GoDef<CR>
    "autocmd FileType go  nnoremap <buffer> <silent> <leader>gr :GoRun<CR>
endif
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
    " 矩形选择
    nnoremap vv <C-v>
    " 折叠
    nnoremap <leader>zr zR
    nnoremap <leader>zm zM
    " Asd2Num
    inoremap <C-a> <esc>:call ToggleAsd2num()<CR>a
    " Linux下自动退出中文输入法
    if IsLinux()
        "autocmd InsertLeave * call LinuxFcitx2En()
        inoremap <esc> <esc>:call LinuxFcitx2En()<CR>
    endif
" }}}

" Show Setting{{{
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
" }}}

" Copy and paste{{{
    vnoremap <leader>y ygv
    vnoremap <C-c> "+y
    nnoremap <C-v> "+p
    inoremap <C-v> <esc>"+pi
    " 粘贴通过y复制的内容
    nnoremap <leader>p "0p
    nnoremap <leader>P "0P

    " 寄存器快速复制与粘贴
    let s:lower_chars = split("q w e r t y u i o p a s d f g h j k l z x c v b n m", " ")
    for t in s:lower_chars
        execute "vnoremap <leader>'" . t . "    \"" . t . "y"
        execute "nnoremap <leader>'" . t . "    \"" . t . "p"
        execute "nnoremap <leader>'" . toupper(t) . "    \"" . t . "P"
    endfor
" }}}

" Move and goto{{{
    " 扩展匹配(%)功能
if !IsNVim()
    "runtime macros/matchit.vim
    packadd matchit
endif
    " map recursively for % extended by matchit.vim
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
    " 滚屏
    nnoremap <C-j> <C-e>
    nnoremap <C-k> <C-y>
    nnoremap <C-h> zh
    nnoremap <C-l> zl
    nnoremap <M-h> 16zh
    nnoremap <M-l> 16zl
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
    nnoremap <leader>bl :b#<bar>execute "set buflisted"<CR>

    " 打开/关闭Quickfix
    nnoremap <leader>qo :botright copen<CR>
    nnoremap <leader>qc :cclose<CR>
    nnoremap <leader>qj :cnext<bar>execute"silent! normal! zO"<bar>execute"normal! zz"<CR>
    nnoremap <leader>qk :cprevious<bar>execute"silent! normal! zO"<bar>execute"normal! zz"<CR>
    " 打开/关闭Location-list
    nnoremap <leader>lo :botright lopen<CR>
    nnoremap <leader>lc :lclose<CR>
    nnoremap <leader>lj :lnext<bar>execute"silent! normal! zO"<bar>execute"normal! zz"<CR>
    nnoremap <leader>lk :lprevious<bar>execute"silent! normal! zO"<bar>execute"normal! zz"<CR>
    " 预览Quickfix和Location-list
    nnoremap <M-space> :call PreviewQuickfixLine()<CR>
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
    inoremap <C-up> <esc>:resize+1<CR>i
    inoremap <C-down> <esc>:resize-1<CR>i
    inoremap <C-left> <esc>:vertical resize-1<CR>i
    inoremap <C-right> <esc>:vertical resize+1<CR>i
    nnoremap <C-up> :resize+1<CR>
    nnoremap <C-down> :resize-1<CR>
    nnoremap <C-left> :vertical resize-1<CR>
    nnoremap <C-right> :vertical resize+1<CR>
    nnoremap <M-up> :resize+5<CR>
    nnoremap <M-down> :resize-5<CR>
    nnoremap <M-left> :vertical resize-5<CR>
    nnoremap <M-right> :vertical resize+5<CR>
" }}}

" Run Program map{{{
    " 编译运行当前文件
    noremap <F5> <esc>:call ComplileFile('')<CR>
    nnoremap <leader>rf :call ComplileFile('')<CR>
    nnoremap <leader>rq :call RC_Qmake()<CR>

    " 编译运行（输入参数）当前文件
    nnoremap <leader>ra :execute"let g:__str__=input('Compile Args: ')"<bar>call ComplileFile(g:__str__)<CR>
" }}}

" File diff {{{
    " 文件比较，自动补全文件和目录
    nnoremap <leader>ds :execute "let g:__str__=input('File: ', '', 'file')"<bar> execute "diffsplit " . g:__str__<CR>
    nnoremap <leader>dv :execute "let g:__str__=input('File: ', '', 'file')"<bar> execute "vertical diffsplit " . g:__str__<CR>
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
    vnoremap / "*y<bar>:execute"let g:__str__=getreg('*')"<bar>execute"/" . g:__str__<CR>
    " 查找当前光标下的内容
    nnoremap <leader>/ :execute"let g:__str__=expand(\"<cword>\")"<bar>execute "/" . g:__str__<CR>

    " 使用FindVimgrep查找
    for item in s:findvimgrep_nmaps
        execute "nnoremap <leader>" . item ":call FindVimgrep('" . item . "', 'n')<CR>"
    endfor
    for item in s:findvimgrep_vmaps
        execute "vnoremap <leader>" . item ":call FindVimgrep('" . item . "', 'v')<CR>"
    endfor
" }}}

" Terminal {{{
if has('terminal')
if IsNVim()
    nnoremap <leader>tz :terminal zsh<CR>
    tnoremap <esc> <C-\><C-n>
else
    nnoremap <leader>tz :terminal zsh<CR>
    set termkey=<C-w>
    tnoremap <esc> <C-w>N
    packadd termdebug
endif
endif
" }}}

" }}}


