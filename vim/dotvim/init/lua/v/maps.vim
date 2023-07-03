function ExecMacro(key)
    let l:mstr = ':normal! @' . a:key
    execute l:mstr
    call v:lua.require('v.libv').recall(l:mstr)
endfunction

" Basic {{{
nnoremap <leader><leader>q :lua os.exit(0)
nnoremap <leader>.         :lua require('v.libv').recall()<CR>
nnoremap <leader><leader>. :lua require('v.libv').recall(nil, { feedcmd = true })<CR>
nnoremap <C-;> @:
vnoremap <leader><leader>; <Cmd>call feedkeys(':' . v:lua.require('v.libv').get_selected(''), 'n')<CR>
vnoremap <leader><leader>: <Cmd>call feedkeys(':lua ' . v:lua.require('v.libv').get_selected(''), 'n')<CR>
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
nnoremap <leader>za zA
nnoremap <leader>zc zC
nnoremap <leader>zo zO
" nnoremap <leader>zm zM
" nnoremap <leader>zr zR
nnoremap <leader>zn zN
nnoremap <leader>zx zX
nnoremap <leader>zf zF
nnoremap <leader>zd zD
" 滚屏
nnoremap <C-j> <C-e>
nnoremap <C-k> <C-y>
nnoremap <C-h> zh
nnoremap <C-l> zl
nnoremap <M-h> 16zh
nnoremap <M-l> 16zl
nnoremap zh zt
nnoremap zl zb
" 命令行
cnoremap <C-v> <C-r>+
cnoremap <C-p> <C-r>0
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <M-j> <C-n>
cnoremap <M-k> <C-p>
cnoremap <M-h> <Left>
cnoremap <M-l> <Right>
cnoremap <M-o> <C-Right>
cnoremap <M-i> <C-Left>
cnoremap <M-u> <C-b>
cnoremap <M-p> <C-e>
" 替换
nnoremap <leader><leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>
vnoremap <leader><leader>s <Cmd>call feedkeys(':%s/' . v:lua.require('v.libv').get_selected('') . '/', 'n')<CR>
" 排序
nnoremap <leader><leader>S :sort fr //<Left>
vnoremap <leader><leader>S :<C-u>sort fr /\%><C-r>=getpos("'<")[2]-1<CR>c.*\%<<C-r>=getpos("'>")[2]+1<CR>c/
" lua测试代码
nnoremap <leader><leader>u :lua=<Space>
nnoremap <leader><leader>U :lua= vim.api.nvim_parse_cmd('', {})<Left><Left><Left><Left><Left><Left>
vnoremap <leader><leader>u <Cmd>call feedkeys(':lua= ' . v:lua.require('v.libv').get_selected(''), 'n')<CR>
vnoremap <leader><leader>U <Cmd>call feedkeys(':lua= vim.api.nvim_parse_cmd(''' . v:lua.require('v.libv').get_selected('') . ''', {})', 'n')<CR>
" 查看help文档
nnoremap <leader><leader>k :h <C-r><C-w>
vnoremap <leader><leader>k <Cmd>call feedkeys(':h ' . v:lua.require('v.libv').get_selected(''), 'n')<CR>
" HEX编辑
nnoremap <leader>xx :%!xxd<CR>
nnoremap <leader>xr :%!xxd -r<CR>
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
    \ call v:lua.vim.notify(v:count1 . ' lines append') <CR>
nnoremap yd
    \ <Cmd>
    \ execute 'silent normal! ' . v:count1 . 'dd' <Bar>
    \ let @0 .= @" <Bar>
    \ call v:lua.vim.notify(v:count1 . ' deleted lines append') <CR>
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
inoremap <C-v> <Esc>"+pi
inoremap <M-v> <C-v>
" 矩形选择
noremap vv <C-v>
xnoremap <C-g> <C-g><Cmd>call v:lua.vim.notify('mode: ' . string(mode(1)))<CR>
snoremap <C-g> <C-g><Cmd>call v:lua.vim.notify('mode: ' . string(mode(1)))<CR>

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
" FUNCTION: WinGotoNextFloating() {{{ 跳转到下一个floating窗口
function! WinGotoNextFloating()
    for l:wid in nvim_list_wins()
        if l:wid != nvim_get_current_win()
            let l:cfg = nvim_win_get_config(wid)
            if get(l:cfg, 'relative', '') != '' && get(l:cfg, 'focusable', v:true) == v:true
                call win_gotoid(wid)
            endif
        endif
    endfor
endfunction
" }}}

" FUNCTION: WinMoveSpliter(dir, inc) range {{{ 移动窗口的分界，改变窗口大小
" 只有最bottom-right的窗口是移动其top-left的分界，其余窗口移动其bottom-right分界
function! WinMoveSpliter(dir, inc) range
    let l:wnr = winnr()
    let l:pos = win_screenpos(l:wnr)
    let l:hei = winheight(l:wnr) + l:pos[0] + &cmdheight
    let l:hei += (empty(&winbar) ? 0 : 1)
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
nnoremap <leader>wf :call WinGotoNextFloating()<CR>
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
nnoremap <M-Up> :call WinMoveSpliter('e', 1)<CR>
nnoremap <M-Down> :call WinMoveSpliter('d', 1)<CR>
nnoremap <M-Left> :call WinMoveSpliter('s', 1)<CR>
nnoremap <M-Right> :call WinMoveSpliter('f', 1)<CR>
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
nnoremap <leader>qt :call QuickfixTabEdit()<CR>
" 将quickfix中的内容复制location-list
nnoremap <leader>ql
    \ <Cmd>
    \ call setloclist(0, getqflist()) <Bar>
    \ vertical botright lopen 35<CR>
" }}}

" Diff {{{
nnoremap <leader>dt :diffthis<CR>
nnoremap <leader>do :diffoff<CR>
nnoremap <leader>du :diffupdate<CR>
nnoremap <leader>dp <Cmd>execute '.,+' . string(v:count1-1) . 'diffput'<CR>
nnoremap <leader>dg <Cmd>execute '.,+' . string(v:count1-1) . 'diffget'<CR>
nnoremap <leader>dj ]c
nnoremap <leader>dk [c
" }}}

" Search {{{
nnoremap <leader><Esc> :nohlsearch<CR>
nnoremap i <Cmd>nohlsearch<CR>i
nnoremap <leader>8 *
nnoremap <leader>3 #
vnoremap <leader>8 /\V\c\<<C-r>=escape(v:lua.require('v.libv').get_selected(''), '\/')<CR>\><CR>
vnoremap <leader>3 ?\V\c\<<C-r>=escape(v:lua.require('v.libv').get_selected(''), '\/')<CR>\><CR>
nnoremap <leader>/ /\V\c<C-r><C-w><CR>
vnoremap <leader>/ /\V\c<C-r>=escape(v:lua.require('v.libv').get_selected(''), '\/')<CR><CR>
nnoremap <leader><leader>/ /<C-r><C-w>
vnoremap <leader><leader>/ /<C-r>=v:lua.require('v.libv').get_selected('')<CR>
" }}}
