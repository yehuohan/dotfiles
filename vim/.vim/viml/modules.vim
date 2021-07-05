function! Sv_ws()
    return s:ws
endfunction

" Libs {{{
" Function: GetSelected() {{{ 获取选区内容
function! GetSelected()
    let l:reg_var = getreg('0', 1)
    let l:reg_mode = getregtype('0')
    normal! gv"0y
    let l:word = getreg('0')
    call setreg('0', l:reg_var, l:reg_mode)
    return l:word
endfunction
" }}}

" Function: GetRange(pats, pate) {{{ 获取特定的内容的范围
" @param pats: 起始行匹配模式，start为pats所在行
" @param pate: 结束行匹配模式，end为pate所在行
" @return 返回列表[start, end]
function! GetRange(pats, pate)
    let l:start = search(a:pats, 'bcnW')
    let l:end = search(a:pate, 'cnW')
    if l:start == 0
        let l:start = 1
    endif
    if l:end == 0
        let l:end = line('$')
    endif
    return [l:start, l:end]
endfunction
" }}}

" Function: GetEval(str, type) {{{ 获取计算结果
function! GetEval(str, type)
    if a:type ==# 'command'
        let l:result = execute(a:str)
    elseif a:type ==# 'function'
        let l:result = eval(a:str)
    elseif a:type ==# 'registers'
        let l:result = eval('@' . a:str)
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
    function! s:parseArgs(...) closure
        let l:args = a:000
    endfunction
    execute 'call s:parseArgs(' . a:str . ')'
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
        execute 'lcd ' . a:3
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

nnoremap <Plug>ExecLast :call ExecLast(1)<CR>
nnoremap <leader>. :call ExecLast(1)<CR>
nnoremap <leader><leader>. :call ExecLast(0)<CR>
nnoremap <M-;> @:
vnoremap <silent> <leader><leader>;
    \ :call feedkeys(':' . GetSelected(), 'n')<CR>
nnoremap <silent> <leader>ae
    \ :call Input2Fn(['Command: ', '', 'command'], {str -> append(line('.'), GetEval(str, 'command'))})<CR>
nnoremap <silent> <leader>af
    \ :call Input2Fn(['Function: ', '', 'function'], {str -> append(line('.'), GetEval(str, 'function'))})<CR>
vnoremap <silent> <leader>ae :call append(line('.'), GetEval(GetSelected(), 'command'))<CR>
vnoremap <silent> <leader>af :call append(line('.'), GetEval(GetSelected(), 'function'))<CR>
" }}}

" Workspace {{{
" Required: 'yehuohan/popc', 'yehuohan/popset'
"           'skywind3000/asyncrun.vim', 'voldikss/floaterm'
"           'Yggdroot/LeaderF', 'junegunn/fzf.vim'

let s:ws = {'root': '', 'rp': {}, 'fw': {}}
let s:wsd = {
    \ 'rp': {'hl': 'WarningMsg', 'str': ['/\V\c|| "\=[RP]Warning: \.\*\$/hs=s+3']},
    \ 'fw': {'hl': 'IncSearch', 'str': []},
    \ }

augroup UserModulesWorkspace
    autocmd!
    autocmd User PopcLayerWksSavePre call popc#layer#wks#SetSettings(s:ws)
    autocmd User PopcLayerWksLoaded call extend(s:ws, popc#layer#wks#GetSettings(), 'force') |
                                    \ let s:ws.root = popc#layer#wks#GetCurrentWks('root') |
                                    \ if empty(get(s:ws.fw, 'path', '')) |
                                    \   let s:ws.fw.path = s:ws.root |
                                    \ endif
    autocmd User AsyncRunStop call s:wsd.display()
    autocmd Filetype qf call s:wsd.display()
augroup END

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

" Project {{{
" Struct: s:rp {{{
" @attribute proj: project类型
" @attribute type: filetype类型
let s:rp = {
    \ 'proj' : {
        \ 'f' : ['s:FnFile'  , v:null                           ],
        \ 'j' : ['s:FnCell'  , v:null                           ],
        \ 'q' : ['s:FnGMake' , '*.pro'                          ],
        \ 'u' : ['s:FnGMake' , 'cmakelists.txt'                 ],
        \ 'n' : ['s:FnGMake' , 'cmakelists.txt'                 ],
        \ 'm' : ['s:FnMake'  , 'makefile'                       ],
        \ 'a' : ['s:FnCargo' , 'Cargo.toml'                     ],
        \ 'h' : ['s:FnSphinx', IsWin() ? 'make.bat' : 'makefile'],
        \ },
    \ 'type' : {
        \ 'c'          : [IsWin() ? 'gcc -g %s %s -o %s.exe && %s %s' : 'gcc -g %s %s -o %s && ./%s %s',
                                                    \ 'abld', 'srcf', 'outf', 'outf', 'arun'],
        \ 'cpp'        : [IsWin() ? 'g++ -g -std=c++17 %s %s -o %s.exe && %s %s' : 'g++ -g -std=c++17 %s %s -o %s && ./%s %s',
                                                    \ 'abld', 'srcf', 'outf', 'outf', 'arun'],
        \ 'rust'       : [IsWin() ? 'rustc %s %s -o %s.exe && %s %s' : 'rustc %s %s -o %s && ./%s %s',
                                                    \ 'abld', 'srcf', 'outf', 'outf', 'arun'],
        \ 'java'       : ['javac %s && java %s %s'  , 'srcf', 'outf', 'arun'],
        \ 'python'     : ['python %s %s'            , 'srcf', 'arun'        ],
        \ 'julia'      : ['julia %s %s'             , 'srcf', 'arun'        ],
        \ 'lua'        : ['lua %s %s'               , 'srcf', 'arun'        ],
        \ 'go'         : ['go run %s %s'            , 'srcf', 'arun'        ],
        \ 'javascript' : ['node %s %s'              , 'srcf', 'arun'        ],
        \ 'typescript' : ['node %s %s'              , 'srcf', 'arun'        ],
        \ 'dart'       : ['dart %s %s'              , 'srcf', 'arun'        ],
        \ 'make'       : ['make -f %s %s'           , 'srcf', 'arun'        ],
        \ 'sh'         : ['bash ./%s %s'            , 'srcf', 'arun'        ],
        \ 'dosbatch'   : ['%s %s'                   , 'srcf', 'arun'        ],
        \ 'glsl'       : ['glslangValidator %s %s'  , 'abld', 'srcf'        ],
        \ 'tex'        : ['xelatex -file-line-error %s && SumatraPDF %s.pdf', 'srcf', 'outf'],
        \ 'matlab'     : ['matlab -nosplash -nodesktop -r %s', 'outf'],
        \ 'json'       : ['python -m json.tool %s'  , 'srcf'],
        \ 'markdown'   : ['typora %s'               , 'srcf'],
        \ 'html'       : ['firefox %s'              , 'srcf'],
        \ },
    \ 'cell' : {
        \ 'python' : ['python', '^#%%' , '^#%%' ],
        \ 'julia'  : ['julia' , '^#%%' , '^#%%' ],
        \ 'lua'    : ['lua'   , '^--%%', '^--%%'],
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
    \ 'pat' : {
        \ 'target'  : '\mTARGET\s*:\?=\s*\(\<[a-zA-Z0-9_][a-zA-Z0-9_\-]*\)',
        \ 'project' : '\mproject(\(\<[a-zA-Z0-9_][a-zA-Z0-9_\-]*\)',
        \ 'name'    : '\mname\s*=\s*\(\<[a-zA-Z0-9_][a-zA-Z0-9_\-]*\)',
        \ },
    \ 'mappings' : [
        \  'Rp',  'Rq',  'Ru',  'Rn',  'Rm',  'Ra',  'Rh',  'Rf',
        \  'rp',  'rq',  'ru',  'rn',  'rm',  'ra',  'rh',  'rf', 'rj',
        \ 'rcp', 'rcq', 'rcu', 'rcn', 'rcm', 'rca', 'rch',
        \ 'rbp', 'rbq', 'rbu', 'rbn', 'rbm', 'rba', 'rbh',
        \ 'rlp', 'rlq', 'rlu', 'rln', 'rlm', 'rla', 'rlh', 'rlf',
        \ 'rtp', 'rtq', 'rtu', 'rtn', 'rtm', 'rta', 'rth', 'rtf',
        \ 'rop', 'roq', 'rou', 'ron', 'rom', 'roa', 'roh',
        \ ]
    \ }
" Function: s:rp.glob(pat, low) {{{
" @param pat: 文件匹配模式，如*.pro
" @param low: true:查找到存在pat的最低层目录 false:查找到存在pat的最高层目录
" @return 返回找到的文件列表
function! s:rp.glob(pat, low) dict
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

" Function: s:rp.pstr(file, pat) {{{
" @param pat: 匹配模式，必须使用 \(\) 来提取字符串
" @return 返回匹配的字符串结果
function! s:rp.pstr(file, pat)
    for l:line in readfile(a:file)
        let l:res = matchlist(l:line, a:pat)
        if !empty(l:res)
            return l:res[1]
        endif
    endfor
    return ''
endfunction
" }}}

" Function: s:rp.run(cfg) dict {{{
" @param cfg = {
"   key: proj的类型
"   term: 运行的终端类型
"   type: 用于设置encoding, errorformat ...
" }
function! s:rp.run(cfg) dict
    " get file and wdir for calling l:Fn before use type because l:Fn may change filetype
    let [l:Fn, l:pat] = self.proj[a:cfg.key]
    if !has_key(a:cfg, 'file')
        if l:pat == v:null
            let a:cfg.file = expand('%:p')
        else
            let a:cfg.file = self.glob(l:pat, a:cfg.lowest)
            if empty(a:cfg.file)
                throw 'None of ' . l:pat . ' was found!'
            endif
            let a:cfg.file = a:cfg.file[0]
        endif
    endif
    let a:cfg.wdir = fnamemodify(a:cfg.file, ':h')
    let l:cmd = function(l:Fn)(a:cfg)

    " set efm and enc
    let l:type = get(a:cfg, 'type', '')
    if has_key(self.efm, l:type)
        execute 'setlocal efm=' . self.efm[l:type]
    endif
    let g:asyncrun_encs = get(self.enc, l:type, (IsWin() || IsGw()) ? 'gbk' : 'utf-8')

    " execute
    let l:dir = fnameescape(a:cfg.wdir)
    let l:exec = printf(':AsyncRun -cwd=%s ', l:dir)
    if !empty(a:cfg.term)
        let l:exec .= printf('-mode=term -pos=%s ', a:cfg.term)
    endif
    let l:exec .= l:cmd
    execute 'lcd ' . l:dir
    call SetExecLast(l:exec)
    execute l:exec
endfunction
" }}}
" }}}

" Function: RunProject(keys, [cfg]) {{{
" {{{
" @param keys: [rR][cblto][p...]
"              [%1][%2   ][%3  ]
" Run: %1
"   r : build and run
"   R : insert or append global args(can use with %2 together)
" Command: %2
"   c : clean project
"   b : build without run
"   l : run project in floaterm
"   t : run project in terminal
"   o : use project with the lowest directory
" Project: %3
"   p : run project from s:ws.rp
"   ... : supported project from s:rp.proj
" @param cfg: first priority of config
" }}}
function! RunProject(keys, ...)
    if a:keys =~# 'R'
        " config project
        let l:cfg = {
            \ 'term': '', 'agen': '', 'abld': '', 'arun': '',
            \ 'deploy': 'run',
            \ 'lowest': 0,
            \ }
        let l:sel = {
            \ 'opt' : 'config project',
            \ 'lst' : ['term', 'agen', 'abld', 'arun', 'deploy', 'lowest'],
            \ 'dic' : {
                \ 'term': {'lst': ['right', 'bottom', 'floaterm']},
                \ 'agen': {'lst': ['-DTEST=']},
                \ 'abld': {'lst': ['-static', 'tags', '--target tags']},
                \ 'arun': {'lst': ['--nocapture']},
                \ 'deploy': {'lst': ['build', 'run', 'clean', 'test']},
                \ 'lowest': {'lst': [0, 1]},
                \ },
            \ 'sub' : {
                \ 'cmd' : {sopt, sel -> extend(l:cfg, {sopt : sel})},
                \ 'get' : {sopt -> l:cfg[sopt]},
                \ },
            \ 'onCR': {sopt -> call('RunProject', ['r' . a:keys[1:-1], l:cfg])}
            \ }
        if a:keys =~# 'p'
            call extend(l:cfg, {'key': '', 'file': '', 'type': ''})
            call extend(l:cfg, s:ws.rp)
            let l:sel.lst = ['key', 'file', 'type'] + l:sel.lst
            let l:sel.dic['key'] = {'lst': keys(s:rp.proj), 'dic': map(deepcopy(s:rp.proj), {key, val -> val[0]})}
            let l:sel.dic['file'] = {'cpl': 'file'}
            let l:sel.dic['type'] = {'cpl': 'filetype'}
        endif
        call PopSelection(l:sel)
    elseif a:keys =~# 'p'
        " save config of project
        if a:0 > 0
            let s:ws.rp = a:1
            let s:ws.rp.file = fnamemodify(s:ws.rp.file, ':p')
            if empty(s:ws.rp.type)
                let s:ws.rp.type = getbufvar(fnamemodify(s:ws.rp.file, ':t'), '&filetype', &filetype)
            endif
        endif
        call RunProject(has_key(s:ws.rp, 'key') ? a:keys[0:-2] : ('R' . a:keys[1:-1]), s:ws.rp)
    else
        " run project with config
        try
            let l:cfg = {
                \ 'key'   : a:keys[-1:-1],
                \ 'term'  : (a:keys =~# 'l') ? 'floaterm' : ((a:keys =~# 't') ? 'right' : ''),
                \ 'deploy': (a:keys =~# 'b') ? 'build' : ((a:keys =~# 'c') ? 'clean' : 'run'),
                \ 'lowest': (a:keys =~# 'o') ? 1 : 0,
                \ 'agen': '', 'abld': '', 'arun': '',
                \ }
            if a:0 > 0
                call extend(l:cfg, a:1)
            endif
            call s:rp.run(l:cfg)
        catch
            echo v:exception
        endtry
    endif
endfunction
" }}}

" Function: s:FnFile(cfg) {{{
function! s:FnFile(cfg)
    let l:type = get(a:cfg, 'type', &filetype)
    if !has_key(s:rp.type, l:type) || ('dosbatch' ==? l:type && !IsWin())
        throw 's:rp.type doesn''t support "' . l:type . '"'
    else
        let a:cfg.type = l:type
        let a:cfg.srcf = '"' . fnamemodify(a:cfg.file, ':t') . '"'
        let a:cfg.outf = '"' . fnamemodify(a:cfg.file, ':t:r') . '"'
        let l:pstr = map(copy(s:rp.type[l:type]), {key, val -> (key == 0) ? val : get(a:cfg, val, '')})
        return call('printf', l:pstr)
    endif
endfunction
" }}}

" Function: s:FnCell(cfg) {{{
function! s:FnCell(cfg)
    let l:type = &filetype
    if !has_key(s:rp.cell, l:type)
        throw 's:rp.cell doesn''t support "' . l:type . '"'
    else
        let [l:bin, l:pats, l:pate] = s:rp.cell[l:type]
        let l:exec = printf(':%sAsyncRun %s', join(GetRange(l:pats, l:pate), ','), l:bin)
        execute l:exec
        throw l:exec
    endif
endfunction
" }}}

" Function: s:FnMake(cfg) {{{
function! s:FnMake(cfg)
    if a:cfg.deploy ==# 'clean'
        let l:cmd = 'make clean'
    else
        let l:cmd = 'make ' . a:cfg.abld
        if a:cfg.deploy ==# 'run'
            let l:outfile = s:rp.pstr(a:cfg.file, s:rp.pat.target)
            if empty(l:outfile)
                let l:cmd .= ' && echo "[RP]Warning: No executable file, try add TARGET"'
            else
                let l:cmd .= printf(' && "./__VBuildOut/%s" %s', l:outfile, a:cfg.arun)
            endif
        endif
    endif
    return l:cmd
endfunction
" }}}

" Function: s:FnGMake(cfg) {{{
" generate make from cmake, qmake ...
function! s:FnGMake(cfg)
    let l:outdir = a:cfg.wdir . '/__VBuildOut'
    if a:cfg.deploy ==# 'clean'
        call delete(l:outdir, 'rf')
        throw '__VBuildOut was removed'
    else
        silent! call mkdir(l:outdir, 'p')
        if a:cfg.key ==# 'u'
            let l:cmd = printf('cmake %s -G "Unix Makefiles" .. && cmake --build . %s', a:cfg.agen, a:cfg.abld)
        elseif a:cfg.key ==# 'n'
            let l:cmd = printf('vcvars64.bat && cmake %s -G "NMake Makefiles" .. && cmake --build . %s',  a:cfg.agen, a:cfg.abld)
        elseif a:cfg.key ==# 'q'
            let l:srcfile = fnamemodify(a:cfg.file, ':t')
            if IsWin()
                let l:cmd = printf('vcvars64.bat && qmake %s ../"%s" && nmake %s', a:cfg.agen, l:srcfile, a:cfg.abld)
            else
                let l:cmd = printf('qmake %s ../"%s" && make %s', a:cfg.agen, l:srcfile, a:cfg.abld)
            endif
        endif
        let l:cmd = printf('cd __VBuildOut && %s && cd ..', l:cmd)

        if a:cfg.deploy ==# 'run'
            let l:outfile = s:rp.pstr(a:cfg.file, a:cfg.key ==# 'q' ? s:rp.pat.target : s:rp.pat.project)
            if empty(l:outfile)
                let l:cmd .= ' && echo "[RP]Warning: No executable file, try add project() or TARGET"'
            else
                let l:cmd .= printf(' && "./__VBuildOut/%s" %s', l:outfile, a:cfg.arun)
            endif
        endif
        return l:cmd
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

for key in s:rp.mappings
    execute printf('nnoremap <leader>%s :call RunProject("%s")<CR>', key, key)
endfor
" }}}

" Find {{{
" Struct: s:fw {{{
" @attribute engine: see FindW, FindWFuzzy, FindWKill
" @attribute rg: 预置的rg搜索命令，用于搜索指定文本
" @attribute fuzzy: 预置的模糊搜索命令，用于文件和文本等模糊搜索
let s:fw = {
    \ 'cmd' : '',
    \ 'opt' : '',
    \ 'pat' : '',
    \ 'loc' : '',
    \ 'engine' : {
        \ 'rg' : '', 'fuzzy' : '',
        \ 'sel-fuzzy': {
            \ 'opt' : 'select fuzzy engine',
            \ 'lst' : ['fzf', 'leaderf'],
            \ 'cmd' : {sopt, arg -> s:fw.setEngine('fuzzy', arg)},
            \ 'get' : {sopt -> s:fw.engine.fuzzy},
            \ },
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
            \ 'ff' : ':FzfFiles',
            \ 'fF' : ':FzfFiles',
            \ 'fl' : ':execute "FzfRg " . expand("<cword>")',
            \ 'fL' : ':FzfRg',
            \ 'fh' : ':execute "FzfTags " . expand("<cword>")',
            \ 'fH' : ':FzfTags'
            \ },
        \ 'leaderf' : {
            \ 'ff' : ':Leaderf file',
            \ 'fF' : ':Leaderf file --cword',
            \ 'fl' : ':Leaderf rg --nowrap --cword',
            \ 'fL' : ':Leaderf rg --nowrap',
            \ 'fh' : ':Leaderf tag --nowrap --cword',
            \ 'fH' : ':Leaderf tag --nowrap',
            \ 'fd' : ':execute "Leaderf gtags --auto-jump -d " .expand("<cword>")',
            \ 'fg' : ':execute "Leaderf gtags -r " .expand("<cword>")',
            \ }
        \ },
    \ 'mappings' : {'rg' :[], 'fuzzy' : []}
    \ }
" s:fw.mappings {{{
let s:fw.mappings.rg = [
    \  'fi',  'fbi',  'fti',  'foi',  'fpi',  'fI',  'fbI',  'ftI',  'foI',  'fpI',  'Fi',  'FI',
    \  'fw',  'fbw',  'ftw',  'fow',  'fpw',  'fW',  'fbW',  'ftW',  'foW',  'fpW',  'Fw',  'FW',
    \  'fs',  'fbs',  'fts',  'fos',  'fps',  'fS',  'fbS',  'ftS',  'foS',  'fpS',  'Fs',  'FS',
    \  'f=',  'fb=',  'ft=',  'fo=',  'fp=',  'f=',  'fb=',  'ft=',  'fo=',  'fp=',  'F=',  'F=',
    \ 'fai', 'fabi', 'fati', 'faoi', 'fapi', 'faI', 'fabI', 'fatI', 'faoI', 'fapI', 'Fai', 'FaI',
    \ 'faw', 'fabw', 'fatw', 'faow', 'fapw', 'faW', 'fabW', 'fatW', 'faoW', 'fapW', 'Faw', 'FaW',
    \ 'fas', 'fabs', 'fats', 'faos', 'faps', 'faS', 'fabS', 'fatS', 'faoS', 'fapS', 'Fas', 'FaS',
    \ 'fa=', 'fab=', 'fat=', 'fao=', 'fap=', 'fa=', 'fab=', 'fat=', 'fao=', 'fap=', 'Fa=', 'Fa=',
    \ 'fvi', 'fvpi', 'fvI',  'fvpI',
    \ 'fvw', 'fvpw', 'fvW',  'fvpW',
    \ 'fvs', 'fvps', 'fvS',  'fvpS',
    \ 'fv=', 'fvp=', 'fv=',  'fvp=',
    \ ]
let s:fw.mappings.fuzzy = [
    \  'Ff',  'FF',  'Fl',  'FL',  'Fh',  'FH',
    \  'ff',  'fF',  'fl',  'fL',  'fh',  'fH',  'fd',  'fg',
    \ 'fpf', 'fpF', 'fpl', 'fpL', 'fph', 'fpH', 'fpd', 'fpg',
    \ ]
" }}}

" Function: s:fw.unifyPath(path) dict {{{
function! s:fw.unifyPath(path) dict
    let l:path = fnamemodify(a:path, ':p')
    if l:path =~# '[/\\]$'
        let l:path = strcharpart(l:path, 0, strchars(l:path) - 1)
    endif
    return l:path
endfunction
" }}}

" Function: s:fw.setEngine(type, engine) dict {{{
function! s:fw.setEngine(type, engine) dict
    let self.engine[a:type] = a:engine
    call extend(self.engine, self[a:type][a:engine], 'force')
endfunction
" }}}

" Function: s:fw.exec() dict {{{
function! s:fw.exec() dict
    " format: printf('cmd %s %s %s',<opt>,<pat>,<loc>)
    let l:exec = printf(self.cmd, self.opt, self.pat, self.loc)
    let g:asyncrun_encs="utf-8"
    call SetExecLast(l:exec)
    execute l:exec
endfunction
" }}}

call s:fw.setEngine('rg', 'asyncrun')
call s:fw.setEngine('fuzzy', 'leaderf')
" }}}

" Function: s:getMultiDirs() {{{
function! s:getMultiDirs()
    let l:loc = Input2Str('Location: ', '', 'customlist,GetMultiFilesCompletion', expand('%:p:h'))
    return empty(l:loc) ? [] :
        \ map(split(l:loc, '|'), {key, val -> (val =~# '[/\\]$') ? val[0:-2] : val})
endfunction
" }}}

" Function: s:parsePattern(keys, mode) {{{
function! s:parsePattern(keys, mode)
    let l:pat = ''
    if a:mode ==# 'n'
        if a:keys =~? 'i'
            let l:pat = Input2Str('Pattern: ')
        elseif a:keys =~? '[ws]'
            let l:pat = expand('<cword>')
        endif
    elseif a:mode ==# 'v'
        let l:selected = GetSelected()
        if a:keys =~? 'i'
            let l:pat = Input2Str('Pattern: ', l:selected)
        elseif a:keys =~? '[ws]'
            let l:pat = l:selected
        endif
    endif
    if a:keys =~ '='
        let l:pat = getreg('+')
    endif
    return l:pat
endfunction
" }}}

" Function: s:parseLocation(keys) {{{
function! s:parseLocation(keys)
    let l:loc = ''
    if a:keys =~# 'b'
        let l:loc = expand('%:p')
    elseif a:keys =~# 't'
        let l:loc = join(popc#layer#buf#GetFiles('sigtab'), '" "')
    elseif a:keys =~# 'o'
        let l:loc = join(popc#layer#buf#GetFiles('alltab'), '" "')
    elseif a:keys =~# 'p'
        let l:loc = join(s:getMultiDirs(), '" "')
    else
        if empty(get(s:ws.fw, 'path', ''))
            let s:ws.fw.path = popc#utils#FindRoot()
        endif
        let l:loc = empty(s:ws.fw.path) ? '.' : s:ws.fw.path
    endif
    return l:loc
endfunction
" }}}

" Function: s:parseOptions(keys) {{{
function! s:parseOptions(keys)
    let l:opt = ''
    if a:keys =~? 's'     | let l:opt .= '-w ' | endif
    if a:keys =~# '[iws]' | let l:opt .= '-i ' | elseif a:keys =~# '[IWS]' | let l:opt .= '-s ' | endif
    if a:keys !~# '[btop]'
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

" Function: s:parseCommand(keys) {{{
function! s:parseCommand(keys)
    if a:keys =~# 'a'
        let l:cmd = s:fw.engine.sa
    else
        let l:cmd = s:fw.engine.sr
        let s:wsd.fw.str = []
    endif
    return l:cmd
endfunction
" }}}

" Function: s:parseVimgrep(keys) {{{
function! s:parseVimgrep(keys)
    " get options in which %s is the pattern
    let l:opt = (a:keys =~? 's') ? '\<%s\>' : '%s'
    let l:opt .= (a:keys =~# '[iws]') ? '\c' : '\C'
    let s:fw.opt = ''

    " get loaction
    let l:loc = '%'
    if a:keys =~# 'p'
        let l:loc = join(s:getMultiDirs())
        if empty(l:loc) | return v:false | endif
    endif
    let s:fw.loc = l:loc

    " get command
    let s:wsd.fw.str = []
    cgetexpr '[rg by vimgrep]'
    let s:fw.cmd = printf(':vimgrepadd %%s /%s/j %%s | :botright copen | caddexpr "[Finished]"', l:opt)
    return v:true
endfunction
" }}}

" Function: FindW(keys, mode, [cfg]) {{{ 查找
" {{{
" @param keys: [fF][av][btop][IiWwSs=]
"              [%1][%2][%3  ][4%     ]
" Find: %1
"   F : find with inputing args
" Command: %2
"   '': find with rg by default, see s:fw.engine.sr
"   a : find with rg append, see s:fw.engine.sa
"   v : find with vimgrep
" Location: %3
"   b : find in current buffer(%)
"   t : find in buffers of tab via popc
"   o : find in buffers of all tabs via popc
"   p : find with inputing path
"  '' : find with s:ws.fw
" Pattern: %4
"   = : find text from clipboard
"   Normal Mode: mode='n'
"   i : find input
"   w : find word
"   s : find word with boundaries
"   Visual Mode: mode='v'
"   i : find input    with selected
"   w : find visual   with selected
"   s : find selected with boundaries
"   LowerCase: [iws] find in ignorecase
"   UpperCase: [IWS] find in case match
" @param mode: mapping mode of keys
" @param cfg: first priority of config
" }}}
function! FindW(keys, mode, ...)
    if a:keys =~# 'F'
        " input config
        let l:cfg = extend({'path': '', 'filters': '', 'globlst': '', 'exargs': ''}, s:ws.fw)
        let l:sel = {
            \ 'opt' : 'config find',
            \ 'lst' : ['path', 'filters', 'globlst', 'exargs'],
            \ 'dic' : {
                \ 'path': {'cpl': 'file'},
                \ 'filters': {'dsr': {sopt -> '-g*.{' . l:cfg.filters . '}'}},
                \ 'globlst': {'dsr': {sopt -> '-g' . join(split(l:cfg.globlst), ' -g')}, 'cpl': 'file'},
                \ 'exargs': {'lst' : ['--no-fixed-strings', '--hidden', '--no-ignore', '--encoding gbk']},
                \ },
            \ 'sub' : {
                \ 'cmd' : {sopt, sel -> extend(l:cfg, {sopt : sel})},
                \ 'get' : {sopt -> l:cfg[sopt]},
                \ },
            \ 'onCR': {sopt -> call('FindW', ['f' . a:keys[1:-1], a:mode, l:cfg])}
            \ }
        call PopSelection(l:sel)
    else
        " save config
        if a:0 > 0
            let s:ws.fw = a:1
            let s:ws.fw.path = s:fw.unifyPath(s:ws.fw.path)
        else
            call extend(s:ws.fw, {'path': '', 'filters': '', 'globlst': '', 'exargs': ''}, 'keep')
        endif
        " find with config
        let l:pat = s:parsePattern(a:keys, a:mode)
        if empty(l:pat) | return | endif
        if a:keys =~# 'v'
            if !s:parseVimgrep(a:keys) | return | endif
            let s:fw.pat = l:pat
        else
            let s:fw.loc = s:parseLocation(a:keys)
            if empty(s:fw.loc) | return | endif
            let s:fw.opt = s:parseOptions(a:keys)
            let s:fw.cmd = s:parseCommand(a:keys)
            let s:fw.pat = escape(l:pat, s:fw.engine.chars)
        endif
        call add(s:wsd.fw.str, printf('/\V\c%s/', escape(l:pat, '\/')))
        call s:fw.exec()
    endif
endfunction
" }}}

" Function: FindWFuzzy(keys) {{{ 模糊搜索
" {{{
" @param keys: [fF][p ][fFlLhHdg]
"              [%1][%2][%3      ]
" Find: %1
"   F : find with inputing path
" Location: %2
"   p : find with inputing temp path
" Action: %3
"   f : fuzzy files
"   F : fuzzy files with <cword>
"   l : fuzzy line text with <cword>
"   L : fuzzy line text
"   h : fuzzy ctags with <cword>
"   H : fuzzy ctags
"   d : fuzzy gtags definitions with <cword>
"   g : fuzzy gtags references with <cword>
" }}}
function! FindWFuzzy(keys)
    let l:f = (a:keys[0] ==# 'F') ? 1 : 0
    let l:p = (a:keys[1] ==# 'p') ? 1 : 0
    let l:path = get(s:ws.fw, 'path', '')

    if !l:f && !l:p && empty(l:path)
        let l:path = popc#utils#FindRoot()
        let s:ws.fw.path = l:path
    endif
    if l:f || l:p || empty(l:path)
        let l:path = Input2Str('fuzzy path: ', '', 'dir', expand('%:p:h'))
        if empty(l:path)
            return
        endif
    endif
    if l:f
        let s:ws.fw.path = s:fw.unifyPath(l:path)
    endif

    if !empty(l:path)
        let l:exec = printf(":lcd %s | %s", l:path, s:fw.engine[tolower(a:keys[0]) . a:keys[-1:]])
        call SetExecLast(l:exec)
        execute l:exec
    endif
endfunction
" }}}

let FindWKill = function('execute', [s:fw.engine.sk])
let FindWSetFuzzy = function('popset#set#PopSelection', [s:fw.engine['sel-fuzzy']])
for key in s:fw.mappings.rg
    execute printf('nnoremap <leader>%s :call FindW("%s", "n")<CR>', key, key)
    execute printf('vnoremap <leader>%s :call FindW("%s", "v")<CR>', key, key)
endfor
for key in s:fw.mappings.fuzzy
    execute printf('nnoremap <leader>%s :call FindWFuzzy("%s")<CR>', key, key)
endfor
nnoremap <leader>fk :call FindWKill()<CR>
nnoremap <leader>fu :call FindWSetFuzzy()<CR>
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
                \ 'lst' : ['.ycm_extra_conf.py', 'pyrightconfig.json', '.vimspector.json'],
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
            let l:pch = '\m\s*\M' . escape(ch, '\') . '\m\s*\C'
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

let RunScript = function('popset#set#PopSelection', [s:rs.sel])
nnoremap <leader>se :call RunScript()<CR>
nnoremap <silent> <leader>ei
    \ :call Input2Fn(['Suffix: '], 'FnEditFile', 0)<CR>
nnoremap <silent> <leader>eti
    \ :call Input2Fn(['Suffix: '], 'FnEditFile', 1)<CR>
nnoremap <leader>ec  :call FnEditFile('c', 0)<CR>
nnoremap <leader>etc :call FnEditFile('c', 1)<CR>
nnoremap <leader>ea  :call FnEditFile('cpp', 0)<CR>
nnoremap <leader>eta :call FnEditFile('cpp', 1)<CR>
nnoremap <leader>er  :call FnEditFile('rs', 0)<CR>
nnoremap <leader>etr :call FnEditFile('rs', 1)<CR>
nnoremap <leader>ep  :call FnEditFile('py', 0)<CR>
nnoremap <leader>etp :call FnEditFile('py', 1)<CR>
nnoremap <silent> <leader>eh :call Input2Fn(['Divide H: '], 'FnInsertSpace', 'h')<CR>
nnoremap <silent> <leader>eb :call Input2Fn(['Divide B: '], 'FnInsertSpace', 'b')<CR>
nnoremap <silent> <leader>el :call Input2Fn(['Divide L: '], 'FnInsertSpace', 'l')<CR>
nnoremap <silent> <leader>ed :call Input2Fn(['Divide D: '], 'FnInsertSpace', 'd')<CR>
nnoremap <silent> <leader>sf
    \ :call FnSwitchFile({'lhs': ['c', 'cc', 'cpp', 'cxx'], 'rhs': ['h', 'hh', 'hpp', 'hxx']})<CR>
" }}}

" Quickfix {{{
" Function: QuickfixOps(kyes) {{{ 基本操作
function! QuickfixOps(keys)
    let l:type = a:keys[0]
    let l:oprt = a:keys[1]
    if l:oprt ==# 'o'
        execute 'botright ' . l:type . 'open'
    elseif l:oprt ==# 'c'
        if &filetype ==#'qf'
            wincmd p
        endif
        execute l:type . 'close'
    else
        let l:tbl = {
            \ 'l': {'j': 'lnext', 'J': 'llast', 'k': 'lprevious', 'K': 'lfirst'},
            \ 'c': {'j': 'cnext', 'J': 'clast', 'k': 'cprevious', 'K': 'cfirst'}}
        execute l:tbl[l:type][l:oprt]
        silent! normal! zO
        normal! zz
    endif
endfunction
" }}}

" Function: QuickfixGet() {{{ 类型与编号
function! QuickfixGet()
    let l:type = ''
    let l:line = 0
    if &filetype ==# 'qf'
        let l:dict = getwininfo(win_getid())
        if l:dict[0].quickfix && !l:dict[0].loclist
            let l:type = 'c'
        elseif l:dict[0].quickfix && l:dict[0].loclist
            let l:type = 'l'
        endif
        let l:line = line('.')
    endif
    return [l:type, l:line]
endfunction
" }}}

" Function: QuickfixPreview() {{{ 预览
function! QuickfixPreview()
    let [l:type, l:line] = QuickfixGet()
    if empty(l:type)
        return
    endif

    let l:last_winnr = winnr()
    execute l:type . 'rewind ' . l:line
    silent! normal! zO
    silent! normal! zz
    execute l:last_winnr . 'wincmd w'
endfunction
" }}}

" Function: QuickfixTabEdit() {{{ 新建Tab打开窗口
function! QuickfixTabEdit()
    let [l:type, l:line] = QuickfixGet()
    if empty(l:type)
        return
    endif

    tabedit
    execute l:type . 'rewind ' . l:line
    silent! normal! zO
    silent! normal! zz
    execute 'botright ' . l:type . 'open'
endfunction
" }}}

" Function: QuickfixDoIconv() {{{ 编码转换
function! QuickfixDoIconv(sopt, argstr, type)
    let [l:from, l:to] = GetArgs(a:argstr)
    if a:type[0] ==# 'c'
        let l:list = getqflist()
        for t in l:list
            let t.text = iconv(t.text, l:from, l:to)
        endfor
        call setqflist(l:list)
    elseif a:type[0] ==# 'l'
        let l:list = getloclist(0)
        for t in l:list
            let t.text = iconv(t.text, l:from, l:to)
        endfor
        call setloclist(0, l:list)
    endif
endfunction
function! QuickfixIconv()
    let l:type = QuickfixGet()[0]
    if empty(l:type)
        return
    endif
    call PopSelection({
        \ 'opt' : 'select encoding',
        \ 'lst' : ['"cp936", "utf-8"', '"utf-8", "cp936"'],
        \ 'cmd' : 'QuickfixDoIconv',
        \ 'arg' : [l:type,]
        \ })
endfunction
" }}}

nnoremap <leader>qo :call QuickfixOps('co')<CR>
nnoremap <leader>qc :call QuickfixOps('cc')<CR>
nnoremap <leader>qj :call QuickfixOps('cj')<CR>
nnoremap <leader>qJ :call QuickfixOps('cJ')<CR>
nnoremap <leader>qk :call QuickfixOps('ck')<CR>
nnoremap <leader>qK :call QuickfixOps('cK')<CR>
nnoremap <leader>lo :call QuickfixOps('lo')<CR>
nnoremap <leader>lc :call QuickfixOps('lc')<CR>
nnoremap <leader>lj :call QuickfixOps('lj')<CR>
nnoremap <leader>lJ :call QuickfixOps('lJ')<CR>
nnoremap <leader>lk :call QuickfixOps('lk')<CR>
nnoremap <leader>lK :call QuickfixOps('lK')<CR>
nnoremap <C-Space>  :call QuickfixPreview()<CR>
nnoremap <leader>qt :call QuickfixTabEdit()<CR>
nnoremap <leader>qi :call QuickfixIconv()<CR>
" 将quickfix中的内容复制location-list
nnoremap <leader>ql
    \ :call setloclist(0, getqflist())<Bar>
    \ :vertical botright lopen 35<CR>
" }}}

" Options {{{
" Struct: s:opt {{{
let s:opt = {
    \ 'lst' : {
        \ 'conceallevel' : [2, 0],
        \ 'virtualedit'  : ['all', ''],
        \ 'signcolumn'   : ['no', 'yes', 'auto'],
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
    execute printf('echo "%s = " . &%s', a:opt, a:opt)
endfunction
" }}}

" Function: OptionLst(opt) {{{ 切换参数值（列表循环取值）
function! OptionLst(opt)
    let l:lst = s:opt.lst[a:opt]
    let l:idx = index(l:lst, eval('&' . a:opt))
    let l:idx = (l:idx + 1) % len(l:lst)
    execute printf('set %s=%s', a:opt, l:lst[l:idx])
    execute printf('echo "%s = " . &%s', a:opt, a:opt)
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
nnoremap <leader>iv :call OptionLst('virtualedit')<CR>
nnoremap <leader>ic :call OptionLst('conceallevel')<CR>
nnoremap <leader>is :call OptionLst('signcolumn')<CR>
nnoremap <leader>in :call OptionFns('number')<CR>
nnoremap <leader>ih :call OptionFns('syntax')<CR>
" }}}
