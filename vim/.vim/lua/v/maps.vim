
" Autocmds {{{
augroup UserSetsCmd
    autocmd!
    autocmd BufNewFile *                    set fileformat=unix
    autocmd BufRead,BufNewFile *.tex        set filetype=tex
    autocmd BufRead,BufNewFile *.log        set filetype=log
    autocmd BufRead,BufNewFile *.usf,*ush   set filetype=hlsl
    autocmd Filetype vim,tex                setlocal foldmethod=marker
    autocmd Filetype c,cpp,javascript       setlocal foldmethod=syntax
    autocmd Filetype python                 setlocal foldmethod=indent
    autocmd FileType txt,log                setlocal foldmethod=manual
    autocmd BufReadPre * call v:lua.require('v.sets').onLargeFile()
augroup END
" }}}

" Mappings {{{
" Misc {{{
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
" 匹配符跳转
packadd matchit
map <S-s> %
map <S-m> %
" 行移动
noremap j gj
noremap k gk
noremap <S-l> $
noremap <S-h> ^
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
nnoremap <leader><leader>o :sort nr //<Left>
nnoremap <leader><leader>O :sort! nr //<Left>
vnoremap <leader><leader>o
    \ :<C-u>sort nr /\%><C-r>=getpos("'<")[2]-1<CR>c.*\%<<C-r>=getpos("'>")[2]+1<CR>c/
vnoremap <leader><leader>O
    \ :<C-u>sort! nr /\%><C-r>=getpos("'<")[2]-1<CR>c.*\%<<C-r>=getpos("'>")[2]+1<CR>c/
" HEX编辑
nnoremap <leader>xx :%!xxd<CR>
nnoremap <leader>xr :%!xxd -r<CR>
" lua的echo测试代码
nnoremap <leader><leader>u :lua print(
nnoremap <leader><leader>U :lua print(vim.inspect(
" 查看help文档
nnoremap <leader><leader>k :h <C-r><C-w>
vnoremap <leader><leader>k
    \ <Cmd>call feedkeys(':h ' . v:lua.require'v.mods'.GetSelected(''), 'n')<CR>
" }}}

" Search {{{
nnoremap <leader><Esc> :nohlsearch<CR>
nnoremap i <Cmd>nohlsearch<CR>i
nnoremap <leader>8 *
nnoremap <leader>3 #
vnoremap <leader>8 /\V\c\<<C-r>=escape(v:lua.require'v.mods'.GetSelected(''), '\/')<CR>\><CR>
vnoremap <leader>3 ?\V\c\<<C-r>=escape(v:lua.require'v.mods'.GetSelected(''), '\/')<CR>\><CR>
nnoremap <leader>/ /\V\c<C-r><C-w><CR>
vnoremap <leader>/ /\V\c<C-r>=escape(v:lua.require'v.mods'.GetSelected(''), '\/')<CR><CR>
nnoremap <leader><leader>/ /<C-r><C-w>
vnoremap <leader><leader>/ /<C-r>=v:lua.require'v.mods'.GetSelected('')<CR>
" }}}
" }}}
