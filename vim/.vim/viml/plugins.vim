let s:use = Sv_use()

" Struct: s:plug {{{
let s:plug = {
    \ 'onVimEnter' : {'exec': []},
    \ 'onDelay'    : {'delay': 700, 'load': [], 'exec': []},
    \ }
" Function: s:plug.reg(event, type, name) dict {{{
function! s:plug.reg(event, type, name) dict
    call add(self[a:event][a:type], a:name)
endfunction
" }}}

" Function: s:plug.run(timer) dict {{{
function! s:plug.run(timer) dict
    call plug#load(self.onDelay.load)
    call execute(self.onDelay.exec)
endfunction
" }}}

" Function: s:plug.init() dict {{{
function! s:plug.init() dict
    if !empty(self.onVimEnter.exec)
        augroup PluginPlug
            autocmd!
            autocmd VimEnter * call execute(s:plug.onVimEnter.exec)
        augroup END
    endif
    if !empty(self.onDelay.load)
        call timer_start(self.onDelay.delay, funcref('s:plug.run', [], s:plug))
    endif
endfunction
" }}}
" }}}

" Plug {{{
if s:use.fastgit
    let g:plug_url_format = 'https://hub.fastgit.org/%s.git'
endif
call plug#begin($DotVimPath.'/bundle')  " 设置插件位置，且自动设置了syntax enable和filetype plugin indent on
    " editing
if IsNVim()
    Plug 'yehuohan/hop.nvim'
else
    Plug 'yehuohan/vim-easymotion'
endif
    Plug 'haya14busa/incsearch.vim'
    Plug 'haya14busa/incsearch-fuzzy.vim'
    Plug 'rhysd/clever-f.vim'
    Plug 'mg979/vim-visual-multi'
    Plug 't9md/vim-textmanip'
    Plug 'markonm/traces.vim'
    Plug 'junegunn/vim-easy-align'
    Plug 'psliwka/vim-smoothie'
    Plug 'terryma/vim-expand-region'
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-indent'
    Plug 'kana/vim-textobj-function'
    Plug 'glts/vim-textobj-comment'
    Plug 'adriaanzon/vim-textobj-matchit'
    Plug 'lucapette/vim-textobj-underscore'
    Plug 'tpope/vim-repeat'
    Plug 'kshenoy/vim-signature'
    Plug 'Konfekt/FastFold'
    Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
    " managers
    Plug 'morhetz/gruvbox'
    Plug 'rakr/vim-one'
if s:use.lightline
    Plug 'yehuohan/lightline.vim'
endif
    Plug 'luochen1990/rainbow'
    Plug 'Yggdroot/indentLine'
    Plug 'yehuohan/popc'
    Plug 'yehuohan/popset'
    Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTree']}
if s:use.startify
    Plug 'mhinz/vim-startify'
endif
    Plug 'itchyny/screensaver.vim'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
if s:use.leaderf
    Plug 'Yggdroot/LeaderF', {'do': IsWin() ? './install.bat' : './install.sh'}
endif
    " codings
if s:use.ycm
    function! Plug_ycm_build(info)
        " (first installed) or (PlugInstall! or PlugUpdate!)
        if a:info.status == 'installed' || a:info.force
            if IsWin()
                !python install.py --clangd-completer --msvc 15 --build-dir ycm_build
            else
                !python install.py --clangd-completer --build-dir ycm_build
            endif
        endif
    endfunction
    Plug 'ycm-core/YouCompleteMe', {'do': function('Plug_ycm_build'), 'on': []}
endif
if s:use.coc
    Plug 'neoclide/coc.nvim', {'branch': 'release', 'on': []}
    Plug 'neoclide/jsonc.vim'
endif
if s:use.nlsp
    Plug 'neovim/nvim-lspconfig'
    Plug 'kabouzeid/nvim-lspinstall'
    Plug 'hrsh7th/nvim-compe'
endif
if s:use.snip
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
endif
    Plug 'sbdchd/neoformat', {'on': 'Neoformat'}
    Plug 'jiangmiao/auto-pairs'
    Plug 'tpope/vim-surround'
    Plug 'majutsushi/tagbar', {'on': 'TagbarToggle'}
    Plug 'scrooloose/nerdcommenter'
    Plug 't9md/vim-quickhl'
    Plug 'RRethy/vim-illuminate'
if IsNVim()
    Plug 'norcalli/nvim-colorizer.lua', {'on': 'ColorizerToggle'}
else
    Plug 'lilydjwg/colorizer', {'on': 'ColorToggle'}
endif
    Plug 'skywind3000/asyncrun.vim'
    Plug 'skywind3000/asyncrun.extra'
    Plug 'voldikss/vim-floaterm'
    Plug 'yehuohan/popc-floaterm'
    Plug 'tpope/vim-fugitive', {'on': ['G', 'Git']}
if s:use.spector
    Plug 'puremourning/vimspector'
endif
    Plug 'euclidianAce/BetterLua.vim', {'for': 'lua'}
    Plug 'bfrg/vim-cpp-modern', {'for': ['c', 'cpp']}
    Plug 'rust-lang/rust.vim'
    Plug 'tikhomirov/vim-glsl'
    Plug 'beyondmarc/hlsl.vim', {'for': 'hlsl'}
    Plug 'JuliaEditorSupport/julia-vim', {'for': 'julia'}
    " utils
if s:use.utils
if IsVim()
    Plug 'yianwillis/vimcdoc', {'for': 'help'}
endif
    Plug 'gabrielelana/vim-markdown', {'for': 'markdown'}
    Plug 'iamcco/markdown-preview.nvim', {'for': 'markdown', 'do': { -> mkdp#util#install()}}
    Plug 'joker1007/vim-markdown-quote-syntax', {'for': 'markdown'}
    Plug 'Rykka/riv.vim', {'for': 'rst'}
    Plug 'Rykka/InstantRst', {'for': 'rst'}
    Plug 'lervag/vimtex', {'for': 'tex'}
    Plug 'tyru/open-browser.vim'
    Plug 'arecarn/vim-crunch'
    Plug 'arecarn/vim-selection'
    Plug 'voldikss/vim-translator'
    Plug 'brglng/vim-im-select'
endif
call plug#end()
" }}}

" Editing {{{
" hop, easy-motion {{{ 快速跳转
if IsNVim()
    silent! lua require'hop'.setup({ dict_list = { 'ascii', 'zh_sc' }, create_hl_autocmd = true })
    noremap s <Cmd>HopChar1MW<CR>
    noremap <leader>ms <Cmd>HopChar2MW<CR>
    noremap <leader><leader>s <Cmd>HopPatternMW<CR>
    noremap <leader>j <Cmd>HopLineStartMW<CR>
    noremap <leader><leader>j <Cmd>HopLineMW<CR>
    noremap <leader>mw <Cmd>HopWord<CR>
else
    let g:EasyMotion_dict = 'zh-cn'     " 支持简体中文拼音
    let g:EasyMotion_do_mapping = 0     " 禁止默认map
    let g:EasyMotion_smartcase = 1      " 不区分大小写
    nmap s <Plug>(easymotion-overwin-f)
    nmap <leader>ms <Plug>(easymotion-overwin-f2)
    nmap <leader><leader>s <Plug>(easymotion-sn)
    nmap <leader>j <Plug>(easymotion-bd-jk)
    nmap <leader><leader>j <Plug>(easymotion-overwin-line)
    nmap <leader>mw <Plug>(easymotion-bd-w)
endif
    nnoremap <silent><expr>  z/ incsearch#go(incsearch#config#fuzzy#make({'prompt': 'z/'}))
    nnoremap <silent><expr> zg/ incsearch#go(incsearch#config#fuzzy#make({'prompt': 'z/', 'is_stay': 1}))
" }}}

" clever-f {{{ 行跳转
    let g:clever_f_across_no_line = 1
    let g:clever_f_show_prompt = 1
    let g:clever_f_smart_case = 1
" }}}

" vim-visual-multi {{{ 多光标编辑
    " Usage: https://github.com/mg979/vim-visual-multi/wiki
    " Tab: 切换cursor/extend模式
    " C-n: 添加word或selected region作为cursor
    " C-Up/Down: 移动当前position并添加cursor
    " <VM_leader>a: 查找当前word作为cursor
    " <VM_leader>/: 查找regex作为cursor（n/N用于查找下/上一个）
    " <VM_leader>,: 添加当前position作为cursor（使用/或arrows或Hop跳转位置）
    " <VM_leader>a <VM_leader>c: 添加visual区域作为cursor
    " v: 文本对象（类似于viw等）
    let g:VM_mouse_mappings = 0         " 禁用鼠标
    let g:VM_leader = ','
    let g:VM_maps = {
        \ 'Find Under'         : '<C-n>',
        \ 'Find Subword Under' : '<C-n>',
        \ 'Select All'         : ',a',
        \ 'Add Cursor At Pos'  : ',,',
        \ 'Select Operator'    : 'v',
        \ }
    let g:VM_custom_remaps = {
        \ '<C-p>' : '[',
        \ '<C-s>' : 'q',
        \ '<C-c>' : 'Q',
        \ 's'     : '<Cmd>HopChar1<CR>',
        \ }
" }}}

" textmanip {{{ 块编辑
    let g:textmanip_enable_mappings = 0
    " 切换Insert/Replace Mode
    xnoremap <M-o>
        \ <Cmd>
        \ let g:textmanip_current_mode = (g:textmanip_current_mode == 'replace') ? 'insert' : 'replace' <Bar>
        \ echo 'textmanip mode: ' . g:textmanip_current_mode<CR>
    xmap <C-o> <M-o>
    " 更据Mode使用Move-Insert或Move-Replace
    xmap <C-j> <Plug>(textmanip-move-down)
    xmap <C-k> <Plug>(textmanip-move-up)
    xmap <C-h> <Plug>(textmanip-move-left)
    xmap <C-l> <Plug>(textmanip-move-right)
    " 更据Mode使用Duplicate-Insert或Duplicate-Replace
    xmap <M-j> <Plug>(textmanip-duplicate-down)
    xmap <M-k> <Plug>(textmanip-duplicate-up)
    xmap <M-h> <Plug>(textmanip-duplicate-left)
    xmap <M-l> <Plug>(textmanip-duplicate-right)
" }}}

" traces {{{ 预览增强
    " 支持:s, :g, :v, :sort, :range预览
    let g:traces_num_range_preview = 1  " 支持:N,M预览
" }}}

" easy-align {{{ 字符对齐
    let g:easy_align_bypass_fold = 1
    let g:easy_align_ignore_groups = [] " 默认任何group都进行对齐
    " 默认对齐内含段落（Text Object: vip）
    nmap <leader>al <Plug>(LiveEasyAlign)ip
    xmap <leader>al <Plug>(LiveEasyAlign)
    ":EasyAlign[!] [N-th] DELIMITER_KEY [OPTIONS]
    ":EasyAlign[!] [N-th]/REGEXP/[OPTIONS]
    nnoremap <leader><leader>a vip:EasyAlign<Space>*//<Left>
    vnoremap <leader><leader>a :EasyAlign<Space>*//<Left>
    nnoremap <leader><leader>A vip:EasyAlign<Space>
    vnoremap <leader><leader>A :EasyAlign<Space>
" }}}

" smoothie {{{ 平滑滚动
    let g:smoothie_no_default_mappings = v:true
    let g:smoothie_update_interval = 30
    let g:smoothie_base_speed = 20
    nmap <M-n> <Plug>(SmoothieDownwards)
    nmap <M-m> <Plug>(SmoothieUpwards)
    nmap <M-j> <Plug>(SmoothieForwards)
    nmap <M-k> <Plug>(SmoothieBackwards)
" }}}

" expand-region {{{ 快速块选择
    map <M-r> <Plug>(expand_region_expand)
    map <M-w> <Plug>(expand_region_shrink)
" }}}

" textobj-user {{{ 文本对象
    " vdc-ia-wWsp(b[<t{B"'`
    " vdc-ia-ifcmu
    let g:textobj_indent_no_default_key_mappings = 1
    omap aI <Plug>(textobj-indent-a)
    omap iI <Plug>(textobj-indent-i)
    omap ai <Plug>(textobj-indent-same-a)
    omap ii <Plug>(textobj-indent-same-i)
    xmap aI <Plug>(textobj-indent-a)
    xmap iI <Plug>(textobj-indent-i)
    xmap ai <Plug>(textobj-indent-same-a)
    xmap ii <Plug>(textobj-indent-same-i)
    omap au <Plug>(textobj-underscore-a)
    omap iu <Plug>(textobj-underscore-i)
    xmap au <Plug>(textobj-underscore-a)
    xmap iu <Plug>(textobj-underscore-i)
    nnoremap <leader>tv :call Plug_to_motion('v')<CR>
    nnoremap <leader>tV :call Plug_to_motion('V')<CR>
    nnoremap <leader>td :call Plug_to_motion('d')<CR>
    nnoremap <leader>tD :call Plug_to_motion('D')<CR>

    function! Plug_to_motion(motion)
        call PopSelection({
            \ 'opt' : 'select text object motion',
            \ 'lst' : split('w W s p ( b [ < t { B " '' ` i f c m u', ' '),
            \ 'cmd' : {sopt, sel -> execute('normal! ' . tolower(a:motion) . (a:motion =~# '\l' ? 'i' : 'a' ) . sel)}
            \ })
    endfunction
" }}}

" signature {{{ 书签管理
    let g:SignatureMap = {
        \ 'Leader'            : "m",
        \ 'PlaceNextMark'     : "m,",
        \ 'ToggleMarkAtLine'  : "m.",
        \ 'PurgeMarksAtLine'  : "m-",
        \ 'DeleteMark'        : '', 'PurgeMarks'        : '', 'PurgeMarkers'      : '',
        \ 'GotoNextLineAlpha' : '', 'GotoPrevLineAlpha' : '', 'GotoNextLineByPos' : '', 'GotoPrevLineByPos' : '',
        \ 'GotoNextSpotAlpha' : '', 'GotoPrevSpotAlpha' : '', 'GotoNextSpotByPos' : '', 'GotoPrevSpotByPos' : '',
        \ 'GotoNextMarker'    : '', 'GotoPrevMarker'    : '', 'GotoNextMarkerAny' : '', 'GotoPrevMarkerAny' : '',
        \ 'ListBufferMarks'   : '', 'ListBufferMarkers' : '',
    \ }
    nnoremap <leader>ts :SignatureToggleSigns<CR>
    nnoremap <leader>ma :SignatureListBufferMarks<CR>
    nnoremap <leader>mc :call signature#mark#Purge('all')<CR>
    nnoremap <leader>ml :call signature#mark#Purge('line')<CR>
    nnoremap <M-,>      :call signature#mark#Goto('prev', 'line', 'pos')<CR>
    nnoremap <M-.>      :call signature#mark#Goto('next', 'line', 'pos')<CR>
" }}}

" FastFold {{{ 更新折叠
    let g:fastfold_savehook = 0         " 只允许手动更新folds
    let g:fastfold_fold_command_suffixes = ['x','X','a','A','o','O','c','C']
    let g:fastfold_fold_movement_commands = ['z[', 'z]', 'zj', 'zk']
                                        " 允许指定的命令更新folds
    nmap <leader>zu <Plug>(FastFoldUpdate)
" }}}

" undotree {{{ 撤消历史
    nnoremap <leader>tu :UndotreeToggle<CR>
" }}}
" }}}

" Manager {{{
" theme {{{ Vim主题(ColorScheme, StatusLine, TabLine)
    let g:gruvbox_contrast_dark='soft'  " 背景选项：dark, medium, soft
    let g:gruvbox_italic = 1
    let g:one_allow_italics = 1
    try
        set background=dark
        colorscheme gruvbox
    catch /^Vim\%((\a\+)\)\=:E185/      " E185: 找不到主题
        silent! colorscheme default
    endtry
if s:use.lightline
    let g:lightline = {
        \ 'enable' : {'statusline': 1, 'tabline': 0},
        \ 'colorscheme' : 'gruvbox',
        \ 'active': {
                \ 'left' : [['mode'], [],
                \           ['msg_left']],
                \ 'right': [['chk_trailing', 'chk_indent', 'all_info'],
                \           ['all_format'],
                \           ['msg_right']],
                \ },
        \ 'inactive': {
                \ 'left' : [['msg_left']],
                \ 'right': [['lite_info'],
                \           ['msg_right']],
                \ },
        \ 'tabline' : {
                \ 'left' : [['tabs']],
                \ 'right': [['close']],
                \ },
        \ 'component': {
                \ 'all_format': '%{&ft!=#""?&ft."/":""}%{&fenc!=#""?&fenc:&enc}/%{&ff}',
                \ 'all_info'  : 'U%B %p%% %l/%L $%v %{winnr()}.%n%{&mod?"+":""}',
                \ 'lite_info' : '%l/%L $%v %{winnr()}.%n%{&mod?"+":""}',
                \ },
        \ 'component_function': {
                \ 'mode'      : 'Plug_ll_mode',
                \ 'msg_left'  : 'Plug_ll_msgLeft',
                \ 'msg_right' : 'Plug_ll_msgRight',
                \ },
        \ 'component_expand': {
                \ 'chk_indent'  : 'Plug_ll_checkMixedIndent',
                \ 'chk_trailing': 'Plug_ll_checkTrailing',
                \ },
        \ 'component_type': {
                \ 'chk_indent'  : 'error',
                \ 'chk_trailing': 'error',
                \ },
        \ 'fallback' : {'tagbar': 0, 'nerdtree': 0, 'Popc': 0, 'coc-explorer': '%{getcwd()}'},
        \ }
    if s:use.powerfont
        let g:lightline.separator            = {'left': '', 'right': ''}
        let g:lightline.subseparator         = {'left': '', 'right': ''}
        let g:lightline.tabline_separator    = {'left': '', 'right': ''}
        let g:lightline.tabline_subseparator = {'left': '', 'right': ''}
        let g:lightline.component = {
                \ 'all_format': '%{&ft!=#""?&ft."":""}%{&fenc!=#""?&fenc:&enc}%{&ff}',
                \ 'all_info'  : 'U%B %p%% %l/%L %v %{winnr()}.%n%{&mod?"+":""}',
                \ 'lite_info' : '%l/%L %v %{winnr()}.%n%{&mod?"+":""}',
                \ }
    endif
    nnoremap <leader>tl :call lightline#toggle()<CR>
    nnoremap <leader>tk
        \ <Cmd>
        \ let b:lightline_check_flg = !get(b:, 'lightline_check_flg', 1) <Bar>
        \ call lightline#update() <Bar>
        \ echo 'b:lightline_check_flg = ' . b:lightline_check_flg<CR>

    " Augroup: PluginLightline {{{
    augroup PluginLightline
        autocmd!
        autocmd ColorScheme * call Plug_ll_colorScheme()
        autocmd CursorHold,BufWritePost * call Plug_ll_checkRefresh()
    augroup END

    function! Plug_ll_colorScheme()
        if !exists('g:loaded_lightline')
            return
        endif
        try
            let g:lightline.colorscheme = g:colors_name
            call lightline#init()
            call lightline#colorscheme()
            call lightline#update()
        catch /^Vim\%((\a\+)\)\=:E117/  " E117: 函数不存在
        endtry
    endfunction

    function! Plug_ll_checkRefresh()
        if get(b:, 'lightline_changedtick', 0) == b:changedtick
            return
        endif
        unlet! b:lightline_changedtick
        call lightline#update()
        let b:lightline_changedtick = b:changedtick
    endfunction
    " }}}

    " Function: lightline components {{{
    function! Plug_ll_mode()
        return &ft ==# 'tagbar' ? 'Tagbar' :
            \ &ft ==# 'nerdtree' ? 'NERDTree' :
            \ &ft ==# 'qf' ? (QuickfixType() ==# 'c' ? 'Quickfix' : 'Location') :
            \ &ft ==# 'help' ? 'Help' :
            \ &ft ==# 'Popc' ? 'Popc' :
            \ &ft ==# 'startify' ? 'Startify' :
            \ winwidth(0) > 60 ? lightline#mode() : ''
    endfunction

    function! Plug_ll_msgLeft()
        if &ft ==# 'qf'
            return 'cwd = ' . getcwd()
        else
            let s:ws = Sv_ws()
            return exists('s:ws.fw.path') ?
                \ substitute(expand('%:p'), '^' . escape(expand(s:ws.fw.path), '\'), '', '') :
                \ expand('%:p')
        endif
    endfunction

    function! Plug_ll_msgRight()
        let s:ws = Sv_ws()
        return exists('s:ws.fw.path') ? s:ws.fw.path : ''
    endfunction

    function! Plug_ll_checkMixedIndent()
        if !get(b:, 'lightline_check_flg', 1)
            return ''
        endif
        let l:ret = search('\m\(\t \| \t\)', 'nw')
        return (l:ret == 0) ? '' : 'M:'.string(l:ret)
    endfunction

    function! Plug_ll_checkTrailing()
        if !get(b:, 'lightline_check_flg', 1)
            return ''
        endif
        let ret = search('\m\s\+$', 'nw')
        return (l:ret == 0) ? '' : 'T:'.string(l:ret)
    endfunction
    " }}}
endif
" }}}

" rainbow {{{ 彩色括号
    let g:rainbow_active = 1
    nnoremap <leader>tr :RainbowToggle<CR>
    augroup PluginRainbow
        autocmd!
        autocmd Filetype cmake RainbowToggleOff
    augroup END
" }}}

" indentLine {{{ 显示缩进标识
    let g:indentLine_char = '⁞'         " 设置标识符样式
    let g:indentLinet_color_term = 200  " 设置标识符颜色
    nnoremap <leader>ti :IndentLinesToggle<CR>
" }}}

" popset {{{ 弹出选项
    let g:Popset_SelectionData = [{
            \ 'opt' : ['colorscheme', 'colo'],
            \ 'lst' : ['gruvbox', 'one'],
        \}]
    nnoremap <leader><leader>p :PopSet<Space>
    nnoremap <leader>sp :PopSet popset<CR>
" }}}

" popc {{{ buffer管理
    let g:Popc_jsonPath = $DotVimCachePath
    let g:Popc_useFloatingWin = 1
    let g:Popc_highlight = {
        \ 'text'     : 'Pmenu',
        \ 'selected' : 'CursorLineNr',
        \ }
    let g:Popc_useTabline = 1
    let g:Popc_useStatusline = 1
    let g:Popc_usePowerFont = s:use.powerfont
if s:use.powerfont
    let g:Popc_selectPointer = ''
    let g:Popc_separator = {'left' : '', 'right': ''}
    let g:Popc_subSeparator = {'left' : '', 'right': ''}
endif
    let g:Popc_useLayerPath = 0
    let g:Popc_useLayerRoots = ['.popc', '.git', '.svn', '.hg', 'tags', '.LfGtags']
    let g:Popc_enableLog = 1
    nnoremap <leader><leader>h :PopcBuffer<CR>
    nnoremap <M-u> :PopcBufferSwitchTabLeft!<CR>
    nnoremap <M-p> :PopcBufferSwitchTabRight!<CR>
    nnoremap <M-i> :PopcBufferSwitchLeft!<CR>
    nnoremap <M-o> :PopcBufferSwitchRight!<CR>
    nnoremap <C-i> :PopcBufferJumpPrev<CR>
    nnoremap <C-o> :PopcBufferJumpNext<CR>
    nnoremap <C-u> <C-o>
    nnoremap <C-p> <C-i>
    nnoremap <leader>wq :PopcBufferClose!<CR>
    nnoremap <leader><leader>b :PopcBookmark<CR>
    nnoremap <leader><leader>w :PopcWorkspace<CR>
    nnoremap <leader>ty
        \ <Cmd>
        \ let g:Popc_tablineLayout = (get(g:, 'Popc_tablineLayout', 0) + 1) % 3 <Bar>
        \ call call('popc#stl#TabLineSetLayout',
        \           [['buffer', 'tab'], ['buffer', ''], ['', 'tab']][g:Popc_tablineLayout])<CR>
" }}}

" nerdtree {{{ 目录树导航
    let g:NERDTreeShowHidden = 1
    let g:NERDTreeDirArrowExpandable = '▸'
    let g:NERDTreeDirArrowCollapsible = '▾'
    let g:NERDTreeMapActivateNode = 'o'
    let g:NERDTreeMapOpenRecursively = 'O'
    let g:NERDTreeMapPreview = 'go'
    let g:NERDTreeMapCloseDir = 'x'
    let g:NERDTreeMapOpenInTab = 't'
    let g:NERDTreeMapOpenInTabSilent = 'gt'
    let g:NERDTreeMapOpenSplit = 's'
    let g:NERDTreeMapPreviewSplit = 'gs'
    let g:NERDTreeMapOpenVSplit = 'i'
    let g:NERDTreeMapPreviewVSplit = 'gi'
    let g:NERDTreeMapJumpLastChild = 'J'
    let g:NERDTreeMapJumpFirstChild = 'K'
    let g:NERDTreeMapJumpNextSibling = '<C-n>'
    let g:NERDTreeMapJumpPrevSibling = '<C-p>'
    let g:NERDTreeMapJumpParent = 'p'
    let g:NERDTreeMapChangeRoot = 'cd'
    let g:NERDTreeMapChdir = ''
    let g:NERDTreeMapCWD = ''
    let g:NERDTreeMapUpdir = 'u'
    let g:NERDTreeMapUpdirKeepOpen = 'U'
    let g:NERDTreeMapRefresh = 'r'
    let g:NERDTreeMapRefreshRoot = 'R'
    let g:NERDTreeMapToggleHidden = '.'
    let g:NERDTreeMapToggleZoom = 'Z'
    let g:NERDTreeMapQuit = 'q'
    let g:NERDTreeMapToggleFiles = 'F'
    let g:NERDTreeMapMenu = 'M'
    nnoremap <leader>te :NERDTreeToggle<CR>
    nnoremap <leader>tE
        \ <Cmd>execute ':NERDTree ' . expand('%:p:h')<CR>
" }}}

" startify {{{ 启动首页
if s:use.startify
if IsWin()
    let g:startify_bookmarks = [ {'c': '$DotVimPath/.init.vim'},
                                \{'d': '$LOCALAPPDATA/nvim/init.vim'},
                                \{'o': '$DotVimCachePath/todo.md'} ]
else
    let g:startify_bookmarks = [ {'c': '~/.vim/.init.vim'},
                                \{'d': '~/.config/nvim/init.vim'},
                                \{'o': '$DotVimCachePath/todo.md'} ]
endif
    let g:startify_lists = [
            \ {'type': 'bookmarks', 'header': ['   Bookmarks']},
            \ {'type': 'files',     'header': ['   Recent Files']},
            \ ]
    let g:startify_files_number = 8
    let g:startify_custom_header = 'startify#pad(startify#fortune#cowsay(Plug_stt_todo(), "─", "│", "┌", "┐", "┘", "└"))'
    nnoremap <leader>su :Startify<CR>
    augroup PluginStartify
        autocmd!
        autocmd User StartifyReady setlocal conceallevel=0
    augroup END

    function! Plug_stt_todo()
        if filereadable($DotVimCachePath.'/todo.md')
            let l:todo = filter(readfile($DotVimCachePath.'/todo.md'), 'v:val !~ "\\m^[ \t]*$"')
            return empty(l:todo) ? '' : l:todo
        else
            return ''
        endif
    endfunction
endif
" }}}

" screensaver {{{ 屏保
    nnoremap <leader>ss :ScreenSaver<CR>
" }}}

" fzf {{{ 模糊查找
    let g:fzf_command_prefix = 'Fzf'
    let g:fzf_layout = { 'down': '40%' }
    let g:fzf_preview_window = ['right:40%,border-sharp']
    nnoremap <leader><leader>f :Fzf
    augroup PluginFzf
        autocmd!
        autocmd Filetype fzf tnoremap <buffer> <Esc> <C-c>
    augroup END
" }}}

" LeaderF {{{ 模糊查找
if s:use.leaderf
    "call s:plug.reg('onVimEnter', 'exec', 'autocmd! LeaderF_Mru')
    let g:Lf_CacheDirectory = $DotVimCachePath
    "let g:Lf_WindowPosition = 'popup'
    "let g:Lf_PreviewInPopup = 1
    let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0}
    let g:Lf_StlSeparator = s:use.powerfont ? {'left': '', 'right': ''} : {'left': '', 'right': ''}
    let g:Lf_ShowDevIcons = 0
    let g:Lf_ShortcutF = ''
    let g:Lf_ShortcutB = ''
    let g:Lf_ReverseOrder = 1
    let g:Lf_ShowHidden = 1             " 搜索隐藏文件和目录
    let g:Lf_GtagsAutoGenerate = 0      " 禁止自动生成gtags
    let g:Lf_Gtagslabel = 'native-pygments'
                                        " gtags: pip install Pygments
    let g:Lf_GtagsStoreInRootMarker = 1
    let g:Lf_WildIgnore = {
        \ 'dir': ['.git', '.svn', '.hg'],
        \ 'file': []
        \ }
    nnoremap <leader><leader>l :Leaderf
    nnoremap <leader>lf :LeaderfFile<CR>
    nnoremap <leader>lu :LeaderfFunction<CR>
    nnoremap <leader>lU :LeaderfFunctionAll<CR>
    nnoremap <leader>lt :LeaderfBufTag<CR>
    nnoremap <leader>lT :LeaderfBufTagAll<CR>
    nnoremap <leader>ll :LeaderfLine<CR>
    nnoremap <leader>lL :LeaderfLineAll<CR>
    nnoremap <leader>lb :LeaderfBuffer<CR>
    nnoremap <leader>lB :LeaderfBufferAll<CR>
    nnoremap <leader>lr :LeaderfRgInteractive<CR>
    nnoremap <leader>lm :LeaderfMru<CR>
    nnoremap <leader>lM :LeaderfMruCwd<CR>
    nnoremap <leader>ls :LeaderfSelf<CR>
    nnoremap <leader>lh :LeaderfHistorySearch<CR>
    nnoremap <leader>le :LeaderfHistoryCmd<CR>
endif
" }}}
" }}}

" Codings {{{
" YouCompleteMe {{{ 自动补全
if s:use.ycm
    call s:plug.reg('onDelay', 'load', 'YouCompleteMe')
    let g:ycm_global_ycm_extra_conf = $DotVimMiscPath . '/.ycm_extra_conf.py'
    let g:ycm_enable_diagnostic_signs = 1                       " 开启语法检测
    let g:ycm_max_diagnostics_to_display = 30
    let g:ycm_warning_symbol = '►'                              " Warning符号
    let g:ycm_error_symbol = '✘'                                " Error符号
    let g:ycm_auto_start_csharp_server = 0                      " 禁止C#补全
    let g:ycm_cache_omnifunc = 0                                " 禁止缓存匹配项，每次都重新生成匹配项
    let g:ycm_complete_in_strings = 1                           " 开启对字符串补全
    let g:ycm_complete_in_comments = 1                          " 开启对注释补全
    let g:ycm_collect_identifiers_from_comments_and_strings = 0 " 收集注释和字符串补全
    let g:ycm_collect_identifiers_from_tags_files = 1           " 收集标签补全
    let g:ycm_seed_identifiers_with_syntax = 1                  " 收集语法关键字补全
    let g:ycm_use_ultisnips_completer = 1                       " 收集UltiSnips补全
    let g:ycm_autoclose_preview_window_after_insertion = 1      " 自动关闭预览窗口
    let g:ycm_filetype_whitelist = {'*': 1}                     " YCM只在whitelist出现且blacklist未出现的filetype工作
    let g:ycm_language_server = []                              " LSP支持
    let g:ycm_semantic_triggers = {'tex' : g:vimtex#re#youcompleteme}
    let g:ycm_key_detailed_diagnostics = ''                     " 直接使用:YcmShowDetailedDiagnostic命令
    let g:ycm_key_list_select_completion = ['<C-j>', '<M-j>', '<C-n>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<C-k>', '<M-k>', '<C-p>', '<Up>']
    let g:ycm_key_list_stop_completion = ['<C-y>']              " 关闭补全menu
    let g:ycm_key_invoke_completion = '<C-l>'                   " 显示补全内容，YCM使用completefunc，使用omnifunc集成其它补全
    imap <M-l> <C-l>
    imap <M-y> <C-y>
    nnoremap <leader>gg :YcmCompleter<CR>
    nnoremap <leader>gt :YcmCompleter GoTo<CR>
    nnoremap <leader>gI :YcmCompleter GoToInclude<CR>
    nnoremap         gd :YcmCompleter GoToDefinition<CR>
    nnoremap         gD :YcmCompleter GoToDeclaration<CR>
    nnoremap <leader>gd :YcmCompleter GoToDefinition<CR>
    nnoremap <leader>gD :YcmCompleter GoToDeclaration<CR>
    nnoremap <leader>gi :YcmCompleter GoToImplementation<CR>
    nnoremap <leader>gr :YcmCompleter GoToReferences<CR>
    nnoremap <leader>gp :YcmCompleter GetParent<CR>
    nnoremap <leader>gh :YcmCompleter GetDoc<CR>
    nnoremap <leader>gy :YcmCompleter GetType<CR>
    nnoremap <leader>gf :YcmCompleter FixIt<CR>
    nnoremap <leader>gc :YcmCompleter ClearCompilationFlagCache<CR>
    nnoremap <leader>gs :YcmCompleter RestartServer<CR>
    nnoremap <leader>yr :YcmRestartServer<CR>
    nnoremap <leader>yd :YcmDiags<CR>
    nnoremap <leader>yD :YcmDebugInfo<CR>
endif
" }}}

" coc {{{ 自动补全
if s:use.coc
    call s:plug.reg('onDelay', 'load', 'coc.nvim')
    call s:plug.reg('onDelay', 'exec', 'call s:Plug_coc_settings()')
    function! s:Plug_coc_settings()
        for [sec, val] in items(Env_coc_settings())
            call coc#config(sec, val)
        endfor
    endfunction
    let g:coc_config_home = $DotVimMiscPath
    let g:coc_data_home = $DotVimCachePath . '/.coc'
    let g:coc_global_extensions = keys(filter(copy(s:use.coc_exts), 'v:val'))
    let g:coc_status_error_sign = '✘'
    let g:coc_status_warning_sign = '!'
    let g:coc_filetype_map = {}
    let g:coc_snippet_next = '<C-j>'
    let g:coc_snippet_prev = '<C-k>'
    "inoremap <silent><expr> <Tab>
    "    \ pumvisible() ? coc#_select_confirm() :
    "    \ coc#expandable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
    "    \ Plug_coc_check_bs() ? "\<Tab>" :
    "    \ coc#refresh()
    "function! Plug_coc_check_bs() abort
    "    let col = col('.') - 1
    "    return !col || getline('.')[col - 1]  =~# '\s'
    "endfunction
    inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
    inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
    imap <M-j> <C-j>
    imap <M-k> <C-k>
    inoremap <silent><expr> <C-l>
        \ pumvisible() ? "\<C-g>u" : coc#refresh()
    imap <M-l> <C-l>
    inoremap <C-o> <Cmd>call CocActionAsync('showSignatureHelp')<CR>
    imap <M-o> <C-o>
    nnoremap <silent><nowait><expr> <M-f> coc#float#has_scroll() ? coc#float#scroll(1) : ":call WinMoveSpliter('f', 5)\<CR>"
    nnoremap <silent><nowait><expr> <M-d> coc#float#has_scroll() ? coc#float#scroll(0) : ":call WinMoveSpliter('d', 5)\<CR>"
    inoremap <silent><nowait><expr> <M-f> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<CR>" : "\<Right>"
    inoremap <silent><nowait><expr> <M-d> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<CR>" : "\<Left>"
    vnoremap <silent><nowait><expr> <M-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<M-f>"
    vnoremap <silent><nowait><expr> <M-d> coc#float#has_scroll() ? coc#float#scroll(0) : "\<M-d>"
    nmap         gd <Plug>(coc-definition)
    nmap         gD <Plug>(coc-declaration)
    nmap <leader>gd <Plug>(coc-definition)
    nmap <leader>gD <Plug>(coc-declaration)
    nmap <leader>gi <Plug>(coc-implementation)
    nmap <leader>gr <Plug>(coc-references)
    nmap <leader>gt <Plug>(coc-type-definition)
    nmap <leader>gf <Plug>(coc-fix-current)
    nmap <leader>gn <Plug>(coc-rename)
    nmap <leader>gj <Plug>(coc-float-jump)
    nnoremap <leader>gh <Cmd>call CocActionAsync('doHover')<CR>
    nnoremap <leader>gs <Cmd>CocCommand clangd.switchSourceHeader<CR>
    nnoremap <leader>gm <Cmd>CocCommand clangd.symbolInfo<CR>
    nmap <leader>oi <Plug>(coc-diagnostic-info)
    nmap <leader>oj <Plug>(coc-diagnostic-next-error)
    nmap <leader>ok <Plug>(coc-diagnostic-prev-error)
    nmap <leader>oJ <Plug>(coc-diagnostic-next)
    nmap <leader>oK <Plug>(coc-diagnostic-prev)
    nnoremap <leader>oD <Cmd>call CocAction('diagnosticToggle')<CR>
    nnoremap <leader>od
        \ <Cmd>
        \ call coc#config('diagnostic.enable', !coc#util#get_config('diagnostic').enable) <Bar>
        \ echo 'diagnostic.enable: ' . coc#util#get_config('diagnostic').enable<CR>
    nnoremap <leader>or <Cmd>call CocActionAsync('diagnosticRefresh')<CR>
    vnoremap <leader>of <Cmd>call CocActionAsync('formatSelected', 'v')<CR>
    nnoremap <leader>of <Cmd>call CocActionAsync('format')<CR>
    nnoremap <leader>oR :CocRestart<CR>
    nnoremap <leader>on :CocConfig<CR>
    nnoremap <leader>oN :CocLocalConfig<CR>
    nnoremap <leader>ol <Cmd>CocList lists<CR>
    nnoremap <leader>os <Cmd>CocList --normal sources<CR>
    nnoremap <leader>ox <Cmd>CocList --normal extensions<CR>
    " coc-extensions
    nnoremap <leader>oy <Cmd>CocList --normal yank<CR>
    nnoremap <leader>oe <Cmd>CocCommand explorer<CR>
    nmap <leader>oc <Plug>(coc-calc-result-append)
    highlight default link CocMenuSel CursorLineNr
endif
" }}}

" ultisnips {{{ 代码片段
if s:use.snip
    let g:UltiSnipsEditSplit = 'vertical'
    let g:UltiSnipsSnippetDirectories = [$DotVimPath . '/snips', 'UltiSnips']
    let g:UltiSnipsExpandTrigger = '<Tab>'
    let g:UltiSnipsJumpForwardTrigger = '<C-j>'
    let g:UltiSnipsJumpBackwardTrigger = '<C-k>'
    let g:UltiSnipsListSnippets = '<C-u>'
    imap <M-u> <C-u>
endif
" }}}

" neoformat {{{ 代码格式化
    let g:neoformat_basic_format_align = 1
    let g:neoformat_basic_format_retab = 1
    let g:neoformat_basic_format_trim = 1
    let g:neoformat_c_astyle = {
        \ 'exe' : 'astyle',
        \ 'args' : ['--style=attach', '--pad-oper'],
        \ 'stdin' : 1,
        \ }
    let g:neoformat_cpp_astyle = g:neoformat_c_astyle
    let g:neoformat_java_astyle = {
        \ 'exe' : 'astyle',
        \ 'args' : ['--mode=java --style=google', '--pad-oper'],
        \ 'stdin' : 1,
        \ }
    let g:neoformat_python_autopep8 = {
        \ 'exe': 'autopep8',
        \ 'args': ['-s 4', '-E'],
        \ 'replace': 1,
        \ 'stdin': 1,
        \ 'env': ['DEBUG=1'],
        \ 'valid_exit_codes': [0, 23],
        \ 'no_append': 1,
        \ }
    let g:neoformat_enabled_c = ['astyle']
    let g:neoformat_enabled_cpp = ['astyle']
    let g:neoformat_enabled_java = ['astyle']
    let g:neoformat_enabled_python = ['autopep8']
    noremap <leader>fc :Neoformat<CR>
" }}}

" auto-pairs {{{ 自动括号
    let g:AutoPairsShortcutToggle = ''
    let g:AutoPairsShortcutFastWrap = '<M-p>'
    let g:AutoPairsShortcutJump = ''
    let g:AutoPairsShortcutFastBackInsert = ''
    nnoremap <leader>tp :call AutoPairsToggle()<CR>
" }}}

" surround {{{ 添加包围符
    let g:surround_no_mappings = 1      " 取消默认映射
    " 修改和删除Surround
    nmap <leader>sd <Plug>Dsurround
    nmap <leader>sc <Plug>Csurround
    nmap <leader>sC <Plug>CSurround
    " 给Text Object添加Surround
    nmap ys <Plug>Ysurround
    nmap yS <Plug>YSurround
    nmap <leader>sw ysiw
    nmap <leader>si ysw
    nmap <leader>sW ySiw
    nmap <leader>sI ySw
    " 给行添加Surround
    nmap <leader>sl <Plug>Yssurround
    nmap <leader>sL <Plug>YSsurround
    xmap <leader>sw <Plug>VSurround
    xmap <leader>sW <Plug>VgSurround
" }}}

" tagbar {{{ 代码结构查看
    let g:tagbar_width = 30
    let g:tagbar_map_showproto = ''     " 取消tagbar对<Space>的占用
    nnoremap <leader>tt :TagbarToggle<CR>
" }}}

" nerdcommenter {{{ 批量注释
    let g:NERDCreateDefaultMappings = 0
    let g:NERDSpaceDelims = 0           " 在Comment后添加Space
    nmap <leader>cc <Plug>NERDCommenterComment
    nmap <leader>cm <Plug>NERDCommenterMinimal
    nmap <leader>cs <Plug>NERDCommenterSexy
    nmap <leader>cb <Plug>NERDCommenterAlignBoth
    nmap <leader>cl <Plug>NERDCommenterAlignLeft
    nmap <leader>ci <Plug>NERDCommenterInvert
    nmap <leader>cy <Plug>NERDCommenterYank
    nmap <leader>ce <Plug>NERDCommenterToEOL
    nmap <leader>ca <Plug>NERDCommenterAppend
    nmap <leader>ct <Plug>NERDCommenterAltDelims
    nmap <leader>cu <Plug>NERDCommenterUncomment
" }}}

" quickhl {{{ 单词高亮
    map <leader>hw <Plug>(quickhl-manual-this)
    map <leader>hs <Plug>(quickhl-manual-this-whole-word)
    map <leader>hc <Plug>(quickhl-manual-clear)
    nmap <leader>hr <Plug>(quickhl-manual-reset)
    nmap <leader>th <Plug>(quickhl-manual-toggle)
" }}}

" illuminate {{{ 自动高亮
    let g:Illuminate_delay = 250
    let g:Illuminate_ftblacklist = ['nerdtree', 'tagbar', 'coc-explorer']
    nnoremap <leader>tg :IlluminationToggle<CR>
    highlight link illuminatedWord MatchParen
" }}}

" colorizer {{{ 颜色预览
if IsNVim()
    nnoremap <leader>tc :ColorizerToggle<CR>
else
    let g:colorizer_nomap = 1
    let g:colorizer_startup = 0
    nnoremap <leader>tc :ColorToggle<CR>
endif
" }}}

" asyncrun {{{ 导步运行程序
    let g:asyncrun_open = 8             " 自动打开quickfix window
    let g:asyncrun_save = 1             " 自动保存当前文件
    let g:asyncrun_local = 1            " 使用setlocal的efm
    nnoremap <leader><leader>r :AsyncRun<Space>
    vnoremap <leader><leader>r
        \ <Cmd>call feedkeys(':AsyncRun ' . GetSelected(''), 'n')<CR>
    nnoremap <leader>rk :AsyncStop<CR>
" }}}

" floaterm {{{ 终端浮窗
if IsNVim()
    tnoremap <C-l> <C-\><C-n><C-w>
    tnoremap <Esc> <C-\><C-n>
else
    set termwinkey=<C-l>
    tnoremap <Esc> <C-l>N
endif
    nnoremap <leader>tZ :terminal<CR>
    nnoremap <leader>tz :FloatermToggle<CR>
    nnoremap <leader><leader>m :Popc Floaterm<CR>
    nnoremap <leader><leader>z :FloatermNew<Space>
    tnoremap <M-u> <C-\><C-n>:FloatermFirst<CR>
    tnoremap <M-i> <C-\><C-n>:FloatermPrev<CR>
    tnoremap <M-o> <C-\><C-n>:FloatermNext<CR>
    tnoremap <M-p> <C-\><C-n>:FloatermLast<CR>
    tnoremap <M-q> <C-\><C-n>:FloatermKill<CR>
    tnoremap <M-h> <C-\><C-n>:FloatermHide<CR>
    tnoremap <M-n> <C-\><C-n>:FloatermUpdate --height=0.6 --width=0.6<CR>
    tnoremap <M-m> <C-\><C-n>:FloatermUpdate --height=0.9 --width=0.9<CR>
    tnoremap <M-l> <C-\><C-n>:FloatermUpdate --position=topright<CR>
    tnoremap <M-c> <C-\><C-n>:FloatermUpdate --position=center<CR>
    nnoremap <leader>mf :FloatermNew lf<CR>
    highlight default link FloatermBorder Constant
" }}}

" vimspector {{{ 调试
if s:use.spector
    let g:vimspector_install_gadgets = ['debugpy', 'vscode-cpptools', 'CodeLLDB']
    nmap <F3>   <Plug>VimspectorStop
    nmap <F4>   <Plug>VimspectorRestart
    nmap <F5>   <Plug>VimspectorContinue
    nmap <F6>   <Plug>VimspectorPause
    nmap <F7>   <Plug>VimspectorToggleConditionalBreakpoint
    nmap <F8>   <Plug>VimspectorAddFunctionBreakpoint
    nmap <F9>   <Plug>VimspectorToggleBreakpoint
    nmap <F10>  <Plug>VimspectorStepOver
    nmap <F11>  <Plug>VimspectorStepInto
    nmap <F12>  <Plug>VimspectorStepOut
    nnoremap <leader>dr :VimspectorReset<CR>
    nnoremap <leader>de :VimspectorEval<Space>
    nnoremap <leader>dw :VimspectorWatch<Space>
    nnoremap <leader>dh :VimspectorShowOutput<Space>
    nnoremap <leader>db
        \ <Cmd>call PopSelection({
            \ 'opt' : 'select debug configuration',
            \ 'lst' : keys(json_decode(join(readfile('.vimspector.json'))).configurations),
            \ 'cmd' : {sopt, sel -> vimspector#LaunchWithSettings({'configuration': sel})}
            \})<CR>
endif
" }}}

" julia {{{ Julia支持
    let g:default_julia_version = 'devel'
    let g:latex_to_unicode_tab = 1      " 使用<Tab>输入unicode字符
    nnoremap <leader>tn :call LaTeXtoUnicode#Toggle()<CR>
" }}}
" }}}

" Utils {{{
if s:use.utils
" MarkDown {{{
    let g:markdown_include_jekyll_support = 0
    let g:markdown_enable_mappings = 0
    let g:markdown_enable_spell_checking = 0
    let g:markdown_enable_folding = 0   " 感觉MarkDown折叠引起卡顿时，关闭此项
    let g:markdown_enable_conceal = 0   " 在Vim中显示MarkDown预览
    let g:mkdp_auto_start = 0
    let g:mkdp_auto_close = 1
    let g:mkdp_refresh_slow = 0         " 即时预览MarkDown
    let g:mkdp_command_for_global = 0   " 只有markdown文件可以预览
    let g:mkdp_browser = 'firefox'
    nnoremap <leader>vm
        \ <Cmd>
        \ echo get(b:, 'MarkdownPreviewToggleBool') ? 'Close markdown preview' : 'Open markdown preview' <Bar>
        \ call mkdp#util#toggle_preview()<CR>
    nnoremap <leader>tb
        \ <Cmd>
        \ let g:mkdp_browser = (g:mkdp_browser ==# 'firefox') ? 'chrome' : 'firefox' <Bar>
        \ echo 'Browser: ' . g:mkdp_browser<CR>
" }}}

" ReStructruedText {{{
    let g:riv_auto_format_table = 0
    let g:riv_i_tab_pum_next = 0
    let g:riv_ignored_imaps = '<Tab>,<S-Tab>,<CR>'
    let g:riv_ignored_nmaps = '<Tab>,<S-Tab>,<CR>'
    let g:riv_ignored_vmaps = '<Tab>,<S-Tab>,<CR>'
    let g:instant_rst_browser = 'firefox'
if IsWin()
    " 需要安装 https://github.com/mgedmin/restview
    nnoremap <leader>vr
        \ <Cmd>
        \ execute ':AsyncRun restview ' . expand('%:p:t') <Bar>
        \ cclose<CR>
else
    " 需要安装 https://github.com/Rykka/instant-rst.py
    nnoremap <leader>vr
        \ <Cmd>
        \ echo g:_instant_rst_daemon_started ? 'Close rst' : 'Open rst' <Bar>
        \ execute g:_instant_rst_daemon_started ? 'StopInstantRst' : 'InstantRst'<CR>
endif
" }}}

" vimtex {{{ Latex
    let g:vimtex_cache_root = $DotVimCachePath . '/.vimtex'
    let g:vimtex_view_general_viewer = 'SumatraPDF'
    let g:vimtex_complete_enabled = 1   " 使用vimtex#complete#omnifunc补全
    let g:vimtex_complete_close_braces = 1
    let g:vimtex_compiler_method = 'latexmk'
                                        " TexLive中包含了latexmk
    nmap <leader>at <Plug>(vimtex-toc-toggle)
    nmap <leader>ap <Plug>(vimtex-compile-ss)
    nmap <leader>aP <Plug>(vimtex-compile)
    nmap <leader>as <Plug>(vimtex-stop)
    nmap <leader>ac <Plug>(vimtex-clean)
    nmap <leader>am <Plug>(vimtex-toggle-main)
    nmap <leader>av <Plug>(vimtex-view)
" }}}

" open-browser {{{ 在线搜索
    let g:openbrowser_default_search = 'bing'
    let g:openbrowser_search_engines = {'bing' : 'https://bing.com/search?q={query}'}
    map <leader>bs <Plug>(openbrowser-smart-search)
    nnoremap <leader>big :OpenBrowserSearch -google<Space>
    nnoremap <leader>bib :OpenBrowserSearch -bing<Space>
    nnoremap <leader>bih :OpenBrowserSearch -github<Space>
    nnoremap <leader>bb  <Cmd>call openbrowser#search(expand('<cword>'), 'bing')<CR>
    nnoremap <leader>bg  <Cmd>call openbrowser#search(expand('<cword>'), 'google')<CR>
    nnoremap <leader>bh  <Cmd>call openbrowser#search(expand('<cword>'), 'github')<CR>
    vnoremap <leader>bb  <Cmd>call openbrowser#search(GetSelected(' '), 'bing')<CR>
    vnoremap <leader>bg  <Cmd>call openbrowser#search(GetSelected(' '), 'google')<CR>
    vnoremap <leader>bh  <Cmd>call openbrowser#search(GetSelected(' '), 'github')<CR>
" }}}

" crunch {{{ 计算器
    let g:crunch_user_variables = {
        \ 'e': '2.718281828459045',
        \ 'pi': '3.141592653589793'
        \ }
    nnoremap <leader><leader>e :Crunch<Space>
    nnoremap <leader>ev
        \ <Cmd>execute 'silent .,+' . string(v:count1-1) . 'Crunch'<CR>
    vnoremap <leader>ev :Crunch<CR>
" }}}

" translator {{{ 翻译
    let g:translator_default_engines = ['haici', 'youdao']
    nmap <Leader>tw <Plug>TranslateW
    vmap <Leader>tw <Plug>TranslateWV
    nnoremap <leader><leader>t :TranslateW<Space>
    vnoremap <leader><leader>t
        \ <Cmd>call feedkeys(':TranslateW ' . GetSelected(' '), 'n')<CR>
	highlight default link TranslatorBorder Constant
" }}}

" im-select {{{ 输入法
if IsWin() || IsGw()
    let g:im_select_get_im_cmd = 'im-select'
    let g:im_select_default = '1033'    " 输入法代码：切换到期望的默认输入法，运行im-select
endif
    let g:ImSelectSetImCmd = {key -> ['im-select', key]}
" }}}
endif
" }}}

call s:plug.init()
