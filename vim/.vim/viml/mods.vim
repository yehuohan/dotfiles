function! SvarWs()
    return s:ws
endfunction

" Libs {{{
" Function: GetSelected(...) {{{ 获取选区内容
" GetSelected用在vmap中时需要使用<Cmd>才能正确获取选区内容，不能用':'
" @param sep: 提供sep，当选区是多行时，使用sep连接成一行
function! GetSelected(...)
    let l:reg_var = getreg('9', 1)
    let l:reg_mode = getregtype('9')
    if mode() ==# 'n'
        silent normal! gv"9y
    else
        silent normal! "9y
    endif
    let l:selected = getreg('9')
    call setreg('9', l:reg_var, l:reg_mode)

    if a:0 > 0
        return join(split(l:selected, "\n"), a:1)
    else
        return l:selected
    endif
endfunction
" }}}

" Function: GetEval(str, type) {{{ 获取计算结果
function! GetEval(str, type)
    if a:type ==# 'command'
        let l:result = execute(a:str)
    elseif a:type ==# 'function'
        let l:result = eval(a:str)
    endif
    if type(l:result) != v:t_string
        let l:result = string(l:result)
    endif
    return split(l:result, "\n")
endfunction
" }}}

" Function: GetArgs(str) {{{ 解析字符串参数到列表中
" @param str: 参数字符串，如 '"Test", 10, g:a'
" @return 返回参数列表，如 ["Test", 10, g:a]
function! GetArgs(str)
    let l:args = []
    function! s:getArgs(...) closure
        let l:args = a:000
    endfunction
    execute 'call s:getArgs(' . a:str . ')'
    return l:args
endfunction
" }}}

" Function: GetMultiFilesCompletion(arglead, cmdline, cursorpos) {{{ 多文件自动补全
" 支持带空格的命名，当有多个文件或目录时，返回的补全字符串使用'|'分隔
function! GetMultiFilesCompletion(arglead, cmdline, cursorpos)
    let l:arglead_true = ''             " 真正用于补全的arglead
    let l:arglead_head = ''             " arglead_true之前的部分
    let l:arglead_list = []             " arglead_true开头的文件和目录补全列表
    "arglead        : _true : _head
    "$xx$           : 'xx'  : text before '|'
    "$xx $ or $xx|$ : ''    : 'xx|'
    if a:arglead[-1:-1] ==# ' ' || a:arglead[-1:-1] ==# '|'
        let l:arglead_true = ''
        let l:arglead_head = a:arglead[0:-2] . '|'
    else
        let l:idx = strridx(a:arglead, '|')
        if l:idx == -1
            let l:arglead_true = a:arglead
            let l:arglead_head = ''
        else
            let l:arglead_true = a:arglead[l:idx+1 : -1]
            let l:arglead_head = a:arglead[0 : l:idx]
        endif
    endif
    " 获取_list，包括<.*>隐藏文件，忽略大小写
    let l:wigSave = &wildignore
    let l:wicSave = &wildignorecase
    set wildignore=.,..
    set wildignorecase
    let l:arglead_list = split(glob(l:arglead_true . "*") . "\n" . glob(l:arglead_true . "\.[^.]*"), "\n")
    let &wildignore = l:wigSave
    let &wildignorecase = l:wicSave
    "  返回补全列表
    if !empty(l:arglead_head)
        call map(l:arglead_list, 'l:arglead_head . v:val')
    endif
    return l:arglead_list
endfunction
" }}}

" Function: Input2Str(prompt, [text, completion, workdir]) {{{ 输入字符串
" @param workdir: 设置工作目录，用于文件和目录补全
function! Input2Str(prompt, ...)
    if a:0 == 0
        return input(a:prompt)
    elseif a:0 == 1
        return input(a:prompt, a:1)
    elseif a:0 == 2
        return input(a:prompt, a:1, a:2)
    elseif a:0 == 3
        execute 'lcd ' . escape(a:3, ' \')
        return input(a:prompt, a:1, a:2)
    endif
endfunction
" }}}

" Function: Input2Fn(iargs, fn, [fargs...]) range {{{ 输入字符串作为函数参数
" @param iargs: 用于Input2Str的参数列表
" @param fn: 要运行的函数，第一个参数必须为Input2Str的输入
" @param fargs: fn的附加参数
function! Input2Fn(iargs, fn, ...) range
    let l:inpt = call('Input2Str', a:iargs)
    if empty(l:inpt)
        return
    endif
    let l:fargs = [l:inpt]
    if a:0 > 0
        call extend(l:fargs, a:000)
    endif
    let l:range = (a:firstline == a:lastline) ? '' : (string(a:firstline) . ',' . string(a:lastline))
    let Fn = function(a:fn, l:fargs)
    execute l:range . 'call Fn()'
endfunction
" }}}

" Function: SetExecLast(string, [execution_echo]) {{{ 设置execution
function! SetExecLast(string, ...)
    let s:execution = a:string
    let s:execution_echo = (a:0 >= 1) ? a:1 : a:string
    silent! call repeat#set("\<Plug>ExecLast")
endfunction
" }}}

" Function: ExecLast() {{{ 执行上一次的execution
" @param exe: 1:运行, 0:显示
function! ExecLast(exe)
    if exists('s:execution') && !empty(s:execution)
        if a:exe
            silent execute s:execution
            if exists('s:execution_echo') && s:execution_echo != v:null
                echo s:execution_echo
            endif
        else
            call feedkeys(s:execution, 'n')
        endif
    endif
endfunction
" }}}

" Function: ExecMacro(key) {{{ 执行宏
function! ExecMacro(key)
    let l:mstr = ':normal! @' . a:key
    execute l:mstr
    call SetExecLast(l:mstr)
endfunction
" }}}

nnoremap <Plug>ExecLast    :call ExecLast(1)<CR>
nnoremap <leader>.         :call ExecLast(1)<CR>
nnoremap <leader><leader>. :call ExecLast(0)<CR>
nnoremap <M-;> @:
vnoremap <leader><leader>;
    \ <Cmd>call feedkeys(':' . GetSelected(''), 'n')<CR>
" }}}

" Workspace {{{
" Required: 'yehuohan/popc', 'yehuohan/popset'
"           'skywind3000/asyncrun.vim', 'voldikss/floaterm'
"           'Yggdroot/LeaderF', 'junegunn/fzf.vim'

" Struct s:ws {{{
let s:ws = {'root': '', 'rp': {}, 'fw': {}}
let s:wsd = {
    \ 'rp': {'hl': 'WarningMsg', 'str': ['/\V\c|| "\=[RP]Warning: \.\*\$/hs=s+3']},
    \ 'fw': {'hl': 'IncSearch', 'str': []},
    \ }
" FUNCTION: s:wsd.display() dict {{{ 设置结果显示
function! s:wsd.display() dict
    if &filetype ==# 'qf'
        let l:mod = getline('.') =~# '\V\^|| [rg' ? 'fw' : 'rp'
        if l:mod ==# 'fw'
            setlocal modifiable
            setlocal foldmethod=marker
            setlocal foldmarker=[rg,[Finished
            silent! normal! zO
        endif
        for str in self[l:mod].str
            execute printf('syntax match %s %s', self[l:mod].hl, str)
        endfor
    endif
endfunction
" }}}

augroup UserModsWorkspace
    autocmd!
    autocmd User PopcLayerWksSavePre call popc#layer#wks#SetSettings(s:ws)
    autocmd User PopcLayerWksLoaded call extend(s:ws, popc#layer#wks#GetSettings(), 'force') |
                                    \ let s:ws.root = popc#layer#wks#GetCurrentWks('root') |
                                    \ if empty(s:ws.fw.path) |
                                    \   let s:ws.fw.path = s:ws.root |
                                    \ endif
    autocmd User AsyncRunStop call s:wsd.display()
    autocmd Filetype qf call s:wsd.display()
augroup END
" }}}

" Project {{{
" Struct: s:rp {{{
" @attribute proj: project类型
" @attribute type: filetype类型
let s:rp = {
    \ 'proj' : {
        \ 'f' : ['s:FnFile'  , v:null],
        \ 'm' : ['s:FnMake'  , 'makefile'],
        \ 'u' : ['s:FnGMake' , 'cmakelists.txt'],
        \ 'n' : ['s:FnGMake' , 'cmakelists.txt'],
        \ 'j' : ['s:FnGMake' , 'cmakelists.txt'],
        \ 'q' : ['s:FnGMake' , '*.pro'],
        \ 'a' : ['s:FnCargo' , 'Cargo.toml'],
        \ 'h' : ['s:FnSphinx', IsWin() ? 'make.bat' : 'makefile'],
        \ },
    \ 'type' : {
        \ 'c'          : ['gcc -g %s %s -o "%s" && "./%s" %s',            'abld', 'srcf', 'outf', 'outf', 'arun'],
        \ 'cpp'        : ['g++ -g -std=c++17 %s %s -o "%s" && "./%s" %s', 'abld', 'srcf', 'outf', 'outf', 'arun'],
        \ 'rust'       : [IsWin() ? 'rustc %s %s -o "%s.exe" && "./%s" %s'
        \                         : 'rustc %s %s -o "%s" && "./%s" %s',   'abld', 'srcf', 'outf', 'outf', 'arun'],
        \ 'java'       : ['javac %s && java "%s" %s', 'srcf', 'outf', 'arun'],
        \ 'python'     : ['python %s %s'            , 'srcf', 'arun'],
        \ 'julia'      : ['julia %s %s'             , 'srcf', 'arun'],
        \ 'lua'        : ['lua %s %s'               , 'srcf', 'arun'],
        \ 'go'         : ['go run %s %s'            , 'srcf', 'arun'],
        \ 'javascript' : ['node %s %s'              , 'srcf', 'arun'],
        \ 'typescript' : ['node %s %s'              , 'srcf', 'arun'],
        \ 'dart'       : ['dart %s %s'              , 'srcf', 'arun'],
        \ 'make'       : ['make -f %s %s'           , 'srcf', 'arun'],
        \ 'sh'         : ['bash ./%s %s'            , 'srcf', 'arun'],
        \ 'dosbatch'   : ['%s %s'                   , 'srcf', 'arun'],
        \ 'glsl'       : ['glslangValidator %s %s'  , 'abld', 'srcf'],
        \ 'json'       : ['python -m json.tool %s'  , 'srcf'],
        \ 'markdown'   : ['typora %s'               , 'srcf'],
        \ 'html'       : ['firefox %s'              , 'srcf'],
        \ 'tex'        : ['xelatex -file-line-error %s && SumatraPDF "%s.pdf"', 'srcf', 'outf'],
        \ },
    \ 'enc' : {
        \ 'c'    : 'utf-8',
        \ 'cpp'  : 'utf-8',
        \ 'rust' : 'utf-8',
        \ 'make' : 'utf-8',
        \ 'sh'   : 'utf-8',
        \ },
    \ 'efm' : {
        \ 'python' : '%*\\sFile\ \"%f\"\\,\ line\ %l\\,\ %m',
        \ 'rust'   : '\ %#-->\ %f:%l:%c,\%m\ %f:%l:%c',
        \ 'lua'    : 'lua:\ %f:%l:\ %m',
        \ 'tex'    : '%f:%l:\ %m',
        \ 'cmake'  : '%ECMake\ Error\ at\ %f:%l\ %#%m:',
        \ },
    \ }
" s:rp_mappings {{{
const s:rp_mappings = [
        \  'Rp',  'Rm',  'Ru',  'Rn',  'Rj',  'Rq',  'Ra',  'Rh',  'Rf',
        \  'rp',  'rm',  'ru',  'rn',  'rj',  'rq',  'ra',  'rh',  'rf',
        \ 'rcp', 'rcm', 'rcu', 'rcn', 'rcj', 'rcq', 'rca', 'rch',
        \ 'rbp', 'rbm', 'rbu', 'rbn', 'rbj', 'rbq', 'rba', 'rbh',
        \ 'rlp', 'rlm', 'rlu', 'rln', 'rlj', 'rlq', 'rla', 'rlh', 'rlf',
        \ 'rtp', 'rtm', 'rtu', 'rtn', 'rtj', 'rtq', 'rta', 'rth', 'rtf',
        \ 'rep', 'rem', 'reu', 'ren', 'rej', 'req', 'rea', 'reh', 'ref',
        \ 'rop', 'rom', 'rou', 'ron', 'roj', 'roq', 'roa', 'roh',
        \ ]
" }}}

" Function: s:rp.run(cfg) dict {{{
" @param cfg = {
"   key: proj的类型
"   term: 运行的终端类型
"   type: 用于设置encoding, errorformat ...
" }
function! s:rp.run(cfg) dict
    " set file and wdir to call l:Fn before accessing type, because l:Fn may change filetype
    let [l:Fn, l:pat] = self.proj[a:cfg.key]
    if empty(a:cfg.file)
        if l:pat == v:null
            let a:cfg.file = expand('%:p')
        else
            let l:files = s:glob(l:pat, a:cfg.lowest)
            if empty(l:files)
                throw '[RP] None of ' . l:pat . ' was found!'
            endif
            let a:cfg.file = l:files[0]
        endif
    endif
    let a:cfg.wdir = fnamemodify(a:cfg.file, ':h')
    let l:cmd = function(l:Fn)(a:cfg)

    " set efm and enc
    if has_key(self.efm, a:cfg.type)
        execute 'setlocal efm=' . self.efm[a:cfg.type]
    endif
    let g:asyncrun_encs = get(self.enc, a:cfg.type, (IsWin() || IsGw()) ? 'gbk' : 'utf-8')

    " execute
    let l:dir = fnameescape(a:cfg.wdir)
    let l:exec = printf(':AsyncRun -cwd=%s ', l:dir)
    if !empty(a:cfg.term)
        let l:exec .= printf('-mode=term -pos=%s ', a:cfg.term)
    endif
    let l:exec .= l:cmd
    execute 'lcd ' . escape(l:dir, ' \')
    call SetExecLast(l:exec)
    execute l:exec
endfunction
" }}}
" }}}

" Function: s:glob(pat, low) {{{
" @param pat: 文件匹配模式，如*.pro
" @param low: true:查找到存在pat的最低层目录 false:查找到存在pat的最高层目录
" @return 返回找到的文件列表
function! s:glob(pat, low)
    let l:dir      = expand('%:p:h')
    let l:dir_last = ''

    " widows文件不区分大小写，其它需要通过正则式实现
    let l:pat = IsWin() ? a:pat :
        \ join(map(split(a:pat, '\zs'),
        \       {k,c -> (c =~? '[a-z]') ? '[' . toupper(c) . tolower(c) . ']' : c}), '')

    let l:res = ''
    while l:dir !=# l:dir_last
        let l:files = glob(l:dir . '/' . l:pat)
        if !empty(l:files)
            let l:res = l:files
            if a:low
                break
            endif
        endif
        let l:dir_last = l:dir
        let l:dir = fnamemodify(l:dir, ':p:h:h')
    endwhile
    return split(l:res, "\n")
endfunction
" }}}

" Function: s:vout(cfg) {{{
" 设置__VBuildOut输出和运行（用于FnMake和FnGMake）
function! s:vout(cfg)
    let l:dir = '__VBuildOut'
    if a:cfg.key !=# 'm'
        let l:outdir = a:cfg.wdir . '/' . l:dir
        if a:cfg.deploy ==# 'clean'
            call delete(l:outdir, 'rf')
            throw '[RP] ' . l:dir . ' was removed'
        endif
        silent! call mkdir(l:outdir, 'p')
    endif

    let l:out = ''
    if a:cfg.deploy ==# 'run'
        let l:pats = {
            \ 'target'  : '\mTARGET\s*:\?=\s*\(\<[a-zA-Z0-9_][a-zA-Z0-9_\-]*\)',
            \ 'project' : '\mproject\s*(\(\<[a-zA-Z0-9_][a-zA-Z0-9_\-]*\)',
            \ }
        let l:pat = (a:cfg.key =~# '[mq]') ? l:pats.target : l:pats.project

        let l:out = '&& echo "[RP]Warning: No executable file found"'
        for l:line in readfile(a:cfg.file)
            let l:res = matchlist(l:line, l:pat)
            if !empty(l:res)
                let l:out = printf('&& "./%s/%s" %s', l:dir, l:res[1], a:cfg.arun)
                break
            endif
        endfor
    end

    return [l:dir, l:out]
endfunction
" }}}

" FUNCTION: s:parseProps(km, [cfg]) {{{
" @param cfg: default config
function! s:parseProps(km, ...)
    let l:cfg = {
        \ 'key'   : a:km.E,
        \ 'file'  : '',
        \ 'type'  : '',
        \ 'term'  : '',
        \ 'agen'  : '',
        \ 'abld'  : '',
        \ 'arun'  : '',
        \ 'deploy': 'run',
        \ 'lowest': 0,
        \ }
    if a:0 > 0
        let l:cfg = extend(l:cfg, a:1)
    endif
    let l:cfg.term   = get({'l': 'floaterm', 't': 'right', 'e': 'external'}, a:km.A, l:cfg.term)
    let l:cfg.deploy = get({'b': 'build', 'c': 'clean'}, a:km.A, l:cfg.deploy)
    let l:cfg.lowest = (a:km.A ==# 'o') ? 1 : l:cfg.lowest
    return l:cfg
endfunction
" }}}

" FUNCTION: s:popR(km) {{{
function! s:popRonCR(sopt, earg)
    if a:earg.km.E ==# 'p'
        " save config of project
        let s:ws.rp = a:earg.cfg
        if !empty(s:ws.rp.file)
            let s:ws.rp.file = fnamemodify(s:ws.rp.file, ':p')
            if empty(s:ws.rp.type)
                let s:ws.rp.type = getbufvar(fnamemodify(s:ws.rp.file, ':t'), '&filetype', &filetype)
            endif
        endif
    endif
    call RunProject('r' . a:earg.km.E, a:earg.cfg)
endfunction

function! s:popR(km)
    let l:cfg = s:parseProps(a:km)
    " pop initial selections with km, and pass l:cfg to 'onCR' but not km.A
    let l:sel = {
        \ 'opt': 'config project',
        \ 'lst': ['term', 'agen', 'abld', 'arun', 'deploy', 'lowest'],
        \ 'dic': {
            \ 'key'   : {'lst': keys(s:rp.proj),
            \            'dic': map(deepcopy(s:rp.proj), {key, val -> val[0]})},
            \ 'file'  : {'cpl': 'file'},
            \ 'type'  : {'cpl': 'filetype'},
            \ 'term'  : {'lst': ['right', 'bottom', 'floaterm', 'external']},
            \ 'agen'  : {'lst': ['-DTEST=']},
            \ 'abld'  : {'lst': ['-static', 'tags', '--target tags', '-j32']},
            \ 'arun'  : {'lst': ['--nocapture']},
            \ 'deploy': {'lst': ['build', 'run', 'clean', 'test']},
            \ 'lowest': {'lst': [0, 1]},
            \ },
        \ 'sub': {
            \ 'cmd': {sopt, sel -> extend(l:cfg, {sopt : sel})},
            \ 'get': {sopt -> l:cfg[sopt]},
            \ },
        \ 'arg': {'km': a:km, 'cfg': l:cfg},
        \ 'onCR': funcref('s:popRonCR')
        \ }
    if a:km.E ==# 'p'
        call extend(l:cfg, {'key': '', 'file': '', 'type': ''})
        call extend(l:cfg, s:ws.rp)
        let l:sel.lst = ['key', 'file', 'type'] + l:sel.lst
    endif
    call PopSelection(l:sel)
endfunction
" }}}

" Function: RunProject(keys, [cfg]) {{{
" {{{
" @param keys: [rR][cblteo][p...]
"              [%1][%2    ][%3  ]
" Run: %1 = km.S
"   r : build and run
"   R : insert or append global args(can use with %2 together)
" Property: %2 = km.A
"   c : clean project
"   b : build without run
"   l : run project in floaterm
"   t : run project in terminal
"   e : run project in external
"   o : use project with the lowest directory
" Project: %3 = km.E
"   p : run project from s:ws.rp
"   ... : supported project from s:rp.proj
" Forward:
"   'Rp'  -> 'rp'  -> 'r^p'
"   'R^p' -> 'r^p'
"   'r^p'
" @param cfg: properties to extend
" }}}
function! RunProject(keys, ...)
    let km = {
        \ 'S': a:keys[0],
        \ 'A': a:keys[1:-2],
        \ 'E': a:keys[-1:-1],
        \ }
    if km.S ==# 'R'
        call s:popR(km)
    elseif km.E ==# 'p'
        if empty(get(s:ws.rp, 'key', ''))
            let km.S = 'R'
            call s:popR(km)
        else
            " when a:0 > 0, use s:ws.rp for km.E = 'p' at s:popRonCR
            let l:cfg = (a:0 > 0) ? deepcopy(s:ws.rp) : s:parseProps(km, s:ws.rp)
            " pass l:cfg with km to 'RunProject' but not km.A
            call RunProject(km.S . s:ws.rp.key, l:cfg)
        end
    else
        try
            call s:rp.run(get(a:000, 0, s:parseProps(km)))
		catch /\V\^[RP] /
            echo v:exception
        catch
            echo v:exception
            echo v:throwpoint
        endtry
    endif
endfunction
" }}}

" Function: s:FnFile(cfg) {{{
function! s:FnFile(cfg)
    let l:type = empty(a:cfg.type) ? &filetype : a:cfg.type
    if !has_key(s:rp.type, l:type) || ('dosbatch' ==? l:type && !IsWin())
        throw '[RP] s:rp.type doesn''t support "' . l:type . '"'
    else
        let a:cfg.type = l:type
        let a:cfg.srcf = '"' . fnamemodify(a:cfg.file, ':t') . '"'
        let a:cfg.outf = fnamemodify(a:cfg.file, ':t:r')
        let l:pstr = map(copy(s:rp.type[l:type]), {key, val -> (key == 0) ? val : get(a:cfg, val, '')})
        return call('printf', l:pstr)
    endif
endfunction
" }}}

" Function: s:FnMake(cfg) {{{
function! s:FnMake(cfg)
    if a:cfg.deploy ==# 'clean'
        let l:cmd = 'make clean'
    else
        let [_, l:out] = s:vout(a:cfg)
        let l:cmd = printf('make %s %s', a:cfg.abld, l:out)
    endif
    return l:cmd
endfunction
" }}}

" Function: s:FnGMake(cfg) {{{
" u: cmake for unix makefiles
" n: cmake for nmake makefiles
" j: cmake for ninja
" q: qmake
function! s:FnGMake(cfg)
    let [l:dir, l:out] = s:vout(a:cfg)
    if a:cfg.deploy !=# 'clean'
        let l:fmts = {
            \ 'u': 'cmake %s -G "Unix Makefiles" .. && cmake --build . %s',
            \ 'n': 'vcvars64.bat && cmake %s -G "NMake Makefiles" .. && cmake --build . %s',
            \ 'j': (IsWin() ? 'vcvars64.bat && ' : '') . 'cmake %s -G Ninja .. && cmake --build . %s',
            \ 'q': IsWin() ?
            \      'vcvars64.bat && qmake %s ../"%s" && nmake %s' :
            \      'qmake %s ../"%s" && make %s',
            \ }
        let l:fmt = l:fmts[a:cfg.key]

        if a:cfg.key ==# 'q'
            let l:srcfile = fnamemodify(a:cfg.file, ':t')
            let l:cmd = printf(l:fmt, a:cfg.agen, l:srcfile, a:cfg.abld)
        else
            let l:cmd = printf(l:fmt, a:cfg.agen, a:cfg.abld)
        endif
        return printf('cd %s && %s && cd .. %s', l:dir, l:cmd, l:out)
    endif
endfunction
" }}}

" Function: s:FnCargo(cfg) {{{
function! s:FnCargo(cfg)
    let l:cmd = printf('cargo %s %s', a:cfg.deploy, a:cfg.abld)
    if (a:cfg.deploy ==# 'run' || a:cfg.deploy ==# 'test') && !empty(a:cfg.arun)
        let l:cmd .= ' -- ' . a:cfg.arun
    endif
    let a:cfg.type = 'rust'
    return l:cmd
endfunction
" }}}

" Function: s:FnSphinx(cfg) {{{
function! s:FnSphinx(cfg)
    if a:cfg.deploy ==# 'clean'
        let l:cmd = 'make clean'
    else
        let l:cmd = 'make html ' . a:cfg.abld
        if a:cfg.deploy ==# 'run'
            let l:cmd .= ' && firefox build/html/index.html'
        endif
    endif
    return l:cmd
endfunction
" }}}

for key in s:rp_mappings
    execute printf('nnoremap <leader>%s :call RunProject("%s")<CR>', key, key)
endfor
nnoremap <leader>rv
    \ <Cmd>silent w <Bar>
    \ if &filetype==?'vim' <Bar>
    \   execute ':source %' <Bar>
    \ elseif &filetype==?'lua' <Bar>
    \   execute ':luafile %' <Bar>
    \ endif<CR>
" }}}

" Find {{{
" Struct: s:fw {{{
" @attribute engine: see FindW, FindWFuzzy
" @attribute default: 用于engine的默认参数
" @attribute rg: 预置的rg搜索命令，用于搜索指定文本
" @attribute fuzzy: 预置的模糊搜索命令，用于文件和文本等模糊搜索
let s:fw = {
    \ 'engine' : { 'rg' : '', 'fuzzy' : '' },
    \ 'default' : {
        \ 'path'   : '',
        \ 'pathlst': [],
        \ 'filters': '',
        \ 'globlst': '',
        \ 'exargs' : ''
        \ },
    \ 'rg' : {
        \ 'asyncrun' : {
            \ 'chars' : '"#%',
            \ 'sr' : ':botright copen | :AsyncRun! rg --vimgrep -F %s -e "%s" "%s"',
            \ 'sa' : ':botright copen | :AsyncRun! -append rg --vimgrep -F %s -e "%s" "%s"',
            \ 'sk' : ':AsyncStop'
            \ }
        \ },
    \ 'fuzzy' : {
        \ 'fzf' : {
            \ 'ff' : ':FzfFiles %s',
            \ 'fl' : ':FzfRg %s',
            \ 'fh' : ':FzfTags %s',
            \ },
        \ 'leaderf' : {
            \ 'ff' : ':Leaderf file --input "%s"',
            \ 'fl' : ':Leaderf rg --nowrap --input "%s"',
            \ 'fh' : ':Leaderf tag --nowrap --input "%s"',
            \ 'fd' : ':Leaderf gtags --auto-jump -d %s',
            \ 'fg' : ':Leaderf gtags -r %s',
            \ }
        \ },
    \ }
" s:fw_mappings {{{
const s:fw_mappings_rg = [
    \  'fi',  'fbi',  'fti',  'foi',  'fpi',  'Fi',  'fI',  'fbI',  'ftI',  'foI',  'fpI',  'FI',
    \  'fw',  'fbw',  'ftw',  'fow',  'fpw',  'Fw',  'fW',  'fbW',  'ftW',  'foW',  'fpW',  'FW',
    \  'fs',  'fbs',  'fts',  'fos',  'fps',  'Fs',  'fS',  'fbS',  'ftS',  'foS',  'fpS',  'FS',
    \  'fy',  'fby',  'fty',  'foy',  'fpy',  'Fy',  'fY',  'fbY',  'ftY',  'foY',  'fpY',  'FY',
    \  'fu',  'fbu',  'ftu',  'fou',  'fpu',  'Fu',  'fU',  'fbU',  'ftU',  'foU',  'fpU',  'FU',
    \ 'fai', 'fabi', 'fati', 'faoi', 'fapi', 'Fai', 'faI', 'fabI', 'fatI', 'faoI', 'fapI', 'FaI',
    \ 'faw', 'fabw', 'fatw', 'faow', 'fapw', 'Faw', 'faW', 'fabW', 'fatW', 'faoW', 'fapW', 'FaW',
    \ 'fas', 'fabs', 'fats', 'faos', 'faps', 'Fas', 'faS', 'fabS', 'fatS', 'faoS', 'fapS', 'FaS',
    \ 'fay', 'faby', 'faty', 'faoy', 'fapy', 'Fay', 'faY', 'fabY', 'fatY', 'faoY', 'fapY', 'FaY',
    \ 'fau', 'fabu', 'fatu', 'faou', 'fapu', 'Fau', 'faU', 'fabU', 'fatU', 'faoU', 'fapU', 'FaU',
    \ 'fvi', 'fvpi',  'fvI', 'fvpI',
    \ 'fvw', 'fvpw',  'fvW', 'fvpW',
    \ 'fvs', 'fvps',  'fvS', 'fvpS',
    \ 'fvy', 'fvpy',  'fvY', 'fvpY',
    \ 'fvu', 'fvpu',  'fvU', 'fvpU',
    \ ]
const s:fw_mappings_fuzzy = [
    \ 'ff', 'fpf', 'Ff',
    \ 'fl', 'fpl', 'Fl',
    \ 'fh', 'fph', 'Fh',
    \ 'fd', 'fg',
    \ ]
" }}}

" Function: s:fw.setEngine(type, engine) dict {{{
function! s:fw.setEngine(type, engine) dict
    let self.engine[a:type] = a:engine
    call extend(self.engine, self[a:type][a:engine], 'force')
endfunction
" }}}

" Function: s:fw.exec(fmt) dict {{{
function! s:fw.exec(fmt) dict
    " format: printf('<cmd> %s %s %s',<opt>,<pat>,<loc>)
    let l:exec = printf(a:fmt.cmd, a:fmt.opt, a:fmt.pat, a:fmt.loc)
    let g:asyncrun_encs="utf-8"
    call SetExecLast(l:exec)
    execute l:exec
endfunction
" }}}

call extend(s:ws.fw, s:fw.default, 'keep')
call s:fw.setEngine('rg', 'asyncrun')
call s:fw.setEngine('fuzzy', 'leaderf')
" }}}

" Function: s:unifyPath(path) {{{
function! s:unifyPath(path)
    if empty(a:path)
        return a:path
    endif
    let l:path = fnamemodify(a:path, ':p')
    if l:path =~# '[/\\]$'
        let l:path = strcharpart(l:path, 0, strchars(l:path) - 1)
    endif
    return l:path
endfunction
" }}}

" Function: s:getMultiDirs() {{{
function! s:getMultiDirs()
    let l:loc = Input2Str('Location: ', '', 'customlist,GetMultiFilesCompletion', expand('%:p:h'))
    return empty(l:loc) ? [] :
        \ map(split(l:loc, '|'), {key, val -> (val =~# '[/\\]$') ? val[0:-2] : val})
endfunction
" }}}

" Function: s:parsePattern(km) {{{
function! s:parsePattern(km)
    let l:pat = ''
    if mode() ==# 'n'
        if a:km.E ==? 'i'
            let l:pat = Input2Str('Pattern: ')
        elseif a:km.E =~? '[ws]'
            let l:pat = expand('<cword>')
        endif
    else
        let l:selected = GetSelected('')
        if a:km.E ==? 'i'
            let l:pat = Input2Str('Pattern: ', l:selected)
        elseif a:km.E =~? '[ws]'
            let l:pat = l:selected
        endif
    endif
    if a:km.E ==? 'y'
        let l:pat = getreg('0')
    elseif a:km.E ==? 'u'
        let l:pat = getreg('+')
    endif
    return l:pat
endfunction
" }}}

" Function: s:parseLocation(km) {{{
function! s:parseLocation(km)
    let l:loc = ''
    if a:km.A0 ==# 'b'
        let l:loc = expand('%:p')
    elseif a:km.A0 ==# 't'
        let l:loc = join(popc#layer#buf#GetFiles('sigtab'), '" "')
    elseif a:km.A0 ==# 'o'
        let l:loc = join(popc#layer#buf#GetFiles('alltab'), '" "')
    elseif a:km.A0 ==# 'p'
        let l:loc = join(s:getMultiDirs(), '" "')
    else
        let l:loc = s:ws.fw.path
        if empty(l:loc)
            let l:loc = popc#utils#FindRoot()
            if empty(l:loc)
                let l:loc = expand('%:p:h')
            else
                let s:ws.fw.path = l:loc
                call add(s:ws.fw.pathlst, s:ws.fw.path)
            endif
        endif
    endif
    return l:loc
endfunction
" }}}

" Function: s:parseOptions(km) {{{
function! s:parseOptions(km)
    let l:opt = ''
    if a:km.E ==? 's'       | let l:opt .= '-w ' | endif
    if a:km.E =~# '[iwsyu]' | let l:opt .= '-i ' | elseif a:km.E =~# '[IWSYU]' | let l:opt .= '-s ' | endif
    if a:km.A1 !~# '[btop]'
        if !empty(s:ws.fw.filters)
            let l:opt .= '-g"*.{' . s:ws.fw.filters . '}" '
        endif
        if !empty(s:ws.fw.globlst)
            let l:opt .= '-g' . join(split(s:ws.fw.globlst), ' -g') . ' '
        endif
        if !empty(s:ws.fw.exargs)
            let l:opt .= s:ws.fw.exargs
        endif
    endif
    return l:opt
endfunction
" }}}

" Function: s:parseCommand(km) {{{
function! s:parseCommand(km)
    if a:km.A0 ==# 'a'
        let l:cmd = s:fw.engine.sa
    else
        let l:cmd = s:fw.engine.sr
        let s:wsd.fw.str = []
    endif
    return l:cmd
endfunction
" }}}

" Function: s:parseVimgrep(km, fmt) {{{
function! s:parseVimgrep(km, fmt)
    " get options in which %s is the pattern
    let l:opt = (a:km.E ==? 's') ? '\<%s\>' : '%s'
    let l:opt .= (a:km.E =~# '[iwsyu]') ? '\c' : '\C'
    let a:fmt.opt = ''

    " get loaction
    let l:loc = '%'
    if a:km.A1 ==# 'p'
        let l:loc = join(s:getMultiDirs())
        if empty(l:loc)
            return v:false
        endif
    endif
    let a:fmt.loc = l:loc

    " get command
    let s:wsd.fw.str = []
    cgetexpr '[rg by vimgrep]'
    let a:fmt.cmd = printf(':vimgrepadd %%s /%s/j %%s | :botright copen | caddexpr "[Finished]"', l:opt)
    return v:true
endfunction
" }}}

" FUNCTION: s:popF(km, type) {{{
function! s:popFonCR(sopt, earg)
    let s:ws.fw = a:earg.cfg
    let s:ws.fw.path = s:unifyPath(s:ws.fw.path)
    if !empty(s:ws.fw.path)
        call add(s:ws.fw.pathlst, s:ws.fw.path)
        call uniq(sort(s:ws.fw.pathlst))
    endif
    if a:earg.type
        call FindW('f' . a:earg.km.A0 . a:earg.km.A1 . a:earg.km.E)
    else
        call FindWFuzzy('f' . a:earg.km.A . a:earg.km.E)
    endif
endfunction

function! s:popF(km, type)
    let l:cfg = deepcopy(s:fw.default)
    call extend(l:cfg, s:ws.fw)

    let l:sel = {
        \ 'opt': 'config find',
        \ 'lst': a:type ? ['path', 'filters', 'globlst', 'exargs'] : ['path', 'fuzzy'],
        \ 'dic': {
            \ 'path'   : {'dsr': 'cached find path list',
            \             'lst': get(s:ws.fw, 'pathlst', []),
            \             'cpl': 'file'},
            \ 'filters': {'dsr': {sopt -> '-g*.{' . l:cfg.filters . '}'}},
            \ 'globlst': {'dsr': {sopt -> '-g' . join(split(l:cfg.globlst), ' -g')},
            \             'cpl': 'file'},
            \ 'exargs' : {'lst': ['--word-regexp', '--no-fixed-strings', '--hidden', '--no-ignore', '--encoding gbk']},
            \ 'fuzzy'  : {'lst': ['fzf', 'leaderf'],
            \             'cmd': {sopt, arg -> s:fw.setEngine('fuzzy', arg)},
            \             'get': {sopt -> s:fw.engine.fuzzy}},
            \ },
        \ 'sub' : {
            \ 'cmd': {sopt, sel -> extend(l:cfg, {sopt : sel})},
            \ 'get': {sopt -> l:cfg[sopt]},
            \ },
        \ 'arg': {'km': a:km, 'cfg': l:cfg, 'type': a:type},
        \ 'onCR': funcref('s:popFonCR')
        \ }
    call PopSelection(l:sel)
endfunction
" }}}

" Function: FindW(keys) {{{ 查找
" {{{
" @param keys: [fF][av][btop][IiWwSsYyUu]
"              [%1][%2][%3  ][4%        ]
" Find: %1 = km.S
"   F : find with inputing args
" Command: %2 = km.A0
"   '': find with rg by default, see s:fw.engine.sr
"   a : find with rg append, see s:fw.engine.sa
"   v : find with vimgrep
" Location: %3 = km.A1
"   b : find in current buffer(%)
"   t : find in buffers of tab via popc
"   o : find in buffers of all tabs via popc
"   p : find with inputing path
"  '' : find with s:ws.fw
" Pattern: %4 = km.E
"   Normal Mode:
"   i : find input
"   w : find word
"   s : find word with boundaries
"   Visual Mode:
"   i : find input    with selected
"   w : find visual   with selected
"   s : find selected with boundaries
"   LowerCase: [iwsyu] find in ignorecase
"   UpperCase: [IWSYU] find in case insensitive
"   y : find text from register "0
"   u : find text from register "+ (clipboard of system)
" @param cfg: first priority of config
" }}}
function! FindW(keys)
    let km = {
        \ 'S' : a:keys[0],
        \ 'A0': a:keys[1:-2][0],
        \ 'A1': a:keys[1:-2][-1:-1],
        \ 'E' : a:keys[-1:-1],
        \ }
    if km.S ==# 'F'
        call s:popF(km, v:true)
    else
        let l:pat = s:parsePattern(km)
        if !empty(l:pat)
            let l:fmt = { 'cmd': '', 'opt': '', 'pat': '', 'loc': '' }
            if km.A0 ==# 'v'
                if !s:parseVimgrep(km, l:fmt) | return | endif
                let l:fmt.pat = l:pat
            else
                let l:fmt.loc = s:parseLocation(km)
                if empty(l:fmt.loc) | return | endif
                let l:fmt.opt = s:parseOptions(km)
                let l:fmt.cmd = s:parseCommand(km)
                let l:fmt.pat = escape(l:pat, s:fw.engine.chars)
            endif
            call add(s:wsd.fw.str, printf('/\V\c%s/', escape(l:pat, '\/')))
            call s:fw.exec(l:fmt)
        endif
    endif
endfunction
" }}}

" Function: FindWFuzzy(keys) {{{ 模糊搜索
" {{{
" @param keys: [fF][p ][flhdg]
"              [%1][%2][%3   ]
" Find: %1 = km.S
"   F : fuzzy with inputing args
" Location: %2 = km.A
"   p : fuzzy with inputing temp path
" Action: %3 = km.E
"   f : fuzzy files
"   l : fuzzy line text
"   h : fuzzy ctags and default with <cword>
"   d : fuzzy gtags definition and default with <cword>
"   g : fuzzy gtags reference and default with <cword>
" }}}
function! FindWFuzzy(keys)
    let km = {
        \ 'S': a:keys[0],
        \ 'A': a:keys[1:-2],
        \ 'E': a:keys[-1:-1],
        \ }
    if km.S ==# 'F'
        call s:popF(km, v:false)
    else
        " parse pattern
        let l:pat = ''
        if mode() ==# 'n'
            if km.E =~# '[hdg]'
                let l:pat = expand('<cword>')
            endif
        else
            let l:pat = GetSelected('')
        endif
        " parse location
        let l:loc = s:ws.fw.path
        if (km.A !=# 'p') && empty(l:loc)
            let l:loc = popc#utils#FindRoot()
            if !empty(l:loc)
                let s:ws.fw.path = l:loc
                call add(s:ws.fw.pathlst, s:ws.fw.path)
            endif
        endif
        if (km.A ==# 'p') || empty(l:loc)
            let l:loc = Input2Str('fuzzy path: ', '', 'dir', expand('%:p:h'))
        endif

        if !empty(l:loc)
            let l:exec = printf(":lcd %s | %s", escape(l:loc, ' \'), printf(s:fw.engine['f' . km.E], l:pat))
            call SetExecLast(l:exec)
            execute l:exec
        endif
    endif
endfunction
" }}}

let FindWKill = function('execute', [s:fw.engine.sk])
for key in s:fw_mappings_rg
    execute printf('noremap <leader>%s <Cmd>call FindW("%s")<CR>', key, key)
endfor
for key in s:fw_mappings_fuzzy
    execute printf('noremap <leader>%s <Cmd>call FindWFuzzy("%s")<CR>', key, key)
endfor
nnoremap <leader>fk :call FindWKill()<CR>
" }}}
" }}}

" Scripts {{{
" Struct: s:rs {{{
let s:rs = {
    \ 'sel' : {
        \ 'opt' : 'select scripts to run',
        \ 'lst' : [
            \ 'retab',
            \ '%s/\s\+$//ge',
            \ '%s/\r//ge',
            \ 'edit ++enc=utf-8',
            \ 'edit ++enc=cp936',
            \ 'syntax match QC /\v^[^|]*\|[^|]*\| / conceal',
            \ 'call mkdir(fnamemodify(tempname(), ":h"), "p")',
            \ 'Leaderf gtags --update',
            \ 'execAssembly',
            \ 'copyConfig',
            \ 'lineToTop',
            \ 'clearUndo',
            \ ],
        \ 'dic' : {
            \ 'retab' : 'retab with expandtab',
            \ '%s/\s\+$//ge' : 'remove trailing space',
            \ '%s/\r//ge' : 'remove ^M',
            \ 'execAssembly' : {
                \ 'dsr' : 'execute assembly command',
                \ 'lst' : [
                    \ 'rustc --emit asm=%.asm %',
                    \ 'rustc --emit asm=%.asm -C "llvm-args=-x86-asm-syntax=intel" %',
                    \ 'gcc -S -masm=att %',
                    \ 'gcc -S -masm=intel %',
                    \ ],
                \ 'cmd' : {sopt, arg -> execute('AsyncRun ' . arg)}
                \ },
            \ 'copyConfig' : {
                \ 'dsr' : 'copy config file',
                \ 'lst' : ['.ycm_extra_conf.py', '.clang-format', 'pyrightconfig.json', '.vimspector.json'],
                \ 'cmd' : {sopt, arg -> execute('edit ' . s:rs.fns.copyConfig(arg))},
                \ },
            \ },
        \ 'cmd' : {sopt, arg -> has_key(s:rs.fns, arg) ? s:rs.fns[arg]() : execute(arg)},
        \ },
    \ 'fns' : {}
    \ }
" Function: s:rs.fns.lineToTop() dict {{{ 冻结顶行
function! s:rs.fns.lineToTop() dict
    let l:line = line('.')
    split %
    resize 1
    call cursor(l:line, 1)
    wincmd p
endfunction
" }}}

" Function: s:rs.fns.clearUndo() dict {{{ 清除undo数据
function! s:rs.fns.clearUndo() dict
    let l:ulbak = &undolevels
    setlocal undolevels=-1
    execute "normal! a\<Bar>\<BS>\<Esc>"
    let &undolevels = l:ulbak
endfunction
" }}}

" Function: s:rs.fns.copyConfig(filename) dict {{{ 复制配置文件到当前目录
function! s:rs.fns.copyConfig(filename) dict
    let l:srcfile = $DotVimMiscPath . '/' . a:filename
    let l:dstfile = expand('%:p:h') . '/' . a:filename
    if !filereadable(l:dstfile)
        call writefile(readfile(l:srcfile), l:dstfile)
    endif
    return l:dstfile
endfunction
" }}}
" }}}

" Function: FnEditFile(suffix, ntab) {{{ 编辑临时文件
" @param suffix: 临时文件附加后缀
" @param ntab: 在新tab中打开
function! FnEditFile(suffix, ntab)
    execute printf('%s %s.%s',
                \ a:ntab ? 'tabedit' : 'edit',
                \ fnamemodify(tempname(), ':r'),
                \ empty(a:suffix) ? 'tmp' : a:suffix)
endfunction
" }}}

" Function: FnInsertSpace(string, pos) range {{{ 插入分隔符
" @param string: 分割字符，以空格分隔
" @param pos: 分割的位置
function! FnInsertSpace(string, pos) range
    let l:chars = split(a:string)

    for k in range(a:firstline, a:lastline)
        let l:line = getline(k)
        let l:fie = ' '
        for ch in l:chars
            let l:pch = '\m\s*\V' . escape(ch, '\') . '\m\s*\C'
            if a:pos == 'h'
                let l:sch = l:fie . escape(ch, '&\')
            elseif a:pos == 'b'
                let l:sch = l:fie . escape(ch, '&\') . l:fie
            elseif a:pos == 'l'
                let l:sch = escape(ch, '&\') . l:fie
            elseif a:pos == 'd'
                let l:sch = escape(ch, '&\')
            endif
            let l:line = substitute(l:line, l:pch, l:sch, 'g')
        endfor
        call setline(k, l:line)
    endfor
    call SetExecLast(':call FnInsertSpace(''' . a:string . ''', ''' . a:pos . ''')', v:null)
endfunction
" }}}

" Function: FnSwitchFile(sf) {{{ 切换文件
function! FnSwitchFile(sf)
    let l:ext = expand('%:e')
    let l:file = expand('%:p:r')
    let l:try = []
    if index(a:sf.lhs, l:ext, 0, 1) >= 0
        let l:try = a:sf.rhs
    elseif index(a:sf.rhs, l:ext, 0, 1) >= 0
        let l:try = a:sf.lhs
    endif
    for e in l:try
        if filereadable(l:file . '.' . e)
            execute 'edit ' . l:file . '.' . e
            break
        endif
    endfor
endfunction
" }}}

" FUNCTION: FnEvalStr(type, itext) {{{
" @param itext: 是否将Eval结果放入当前编辑的文本中
function! FnEvalStr(type, itext)
    let l:str = (mode() ==# 'n') ? Input2Str(printf('Eval %s: ', a:type), '', a:type) : GetSelected('')
    if empty(l:str)
        return
    endif

    let l:res = GetEval(l:str, a:type)
    if a:itext
        call append(line('.'), l:res)
    else
        call setreg('0', l:res)
        call setreg('+', l:res)
        echo ' -> copied'
    endif
endfunction
" }}}

let ScriptEval = function('popset#set#PopSelection', [s:rs.sel])
nnoremap <leader>se :call ScriptEval()<CR>
nnoremap <leader>ei
    \ <Cmd>call Input2Fn(['Suffix: '], 'FnEditFile', 0)<CR>
nnoremap <leader>eti
    \ <Cmd>call Input2Fn(['Suffix: '], 'FnEditFile', 1)<CR>
nnoremap <leader>ec  :call FnEditFile('c', 0)<CR>
nnoremap <leader>etc :call FnEditFile('c', 1)<CR>
nnoremap <leader>ea  :call FnEditFile('cpp', 0)<CR>
nnoremap <leader>eta :call FnEditFile('cpp', 1)<CR>
nnoremap <leader>er  :call FnEditFile('rs', 0)<CR>
nnoremap <leader>etr :call FnEditFile('rs', 1)<CR>
nnoremap <leader>ep  :call FnEditFile('py', 0)<CR>
nnoremap <leader>etp :call FnEditFile('py', 1)<CR>
nnoremap <leader>el  :call FnEditFile('lua', 0)<CR>
nnoremap <leader>etl :call FnEditFile('lua', 1)<CR>
nnoremap <leader>em  :call FnEditFile('md', 0)<CR>
nnoremap <leader>etm :call FnEditFile('md', 1)<CR>
nnoremap <silent> <leader>dh :call Input2Fn(['Divide Right: '] , 'FnInsertSpace', 'h')<CR>
nnoremap <silent> <leader>db :call Input2Fn(['Divide Both: ']  , 'FnInsertSpace', 'b')<CR>
nnoremap <silent> <leader>dl :call Input2Fn(['Divide Left: ']  , 'FnInsertSpace', 'l')<CR>
nnoremap <silent> <leader>dd :call Input2Fn(['Divide Delete: '], 'FnInsertSpace', 'd')<CR>
nnoremap <leader>sf
    \ <Cmd>call FnSwitchFile({'lhs': ['c', 'cc', 'cpp', 'cxx'], 'rhs': ['h', 'hh', 'hpp', 'hxx']})<CR>
noremap <leader>ae  <Cmd>call FnEvalStr('command', 1)<CR>
noremap <leader>af  <Cmd>call FnEvalStr('function', 1)<CR>
noremap <leader>age <Cmd>call FnEvalStr('command', 0)<CR>
noremap <leader>agf <Cmd>call FnEvalStr('function', 0)<CR>
" }}}
