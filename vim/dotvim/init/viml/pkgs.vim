let s:use = SvarUse()

" Built-in {{{
let g:loaded_gzip = 1
let g:loaded_tarPlugin = 1
let g:loaded_tar = 1
let g:loaded_zipPlugin = 1
let g:loaded_zip = 1
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
let g:loaded_matchit = 1
let g:loaded_matchparen = 1
" }}}

" Editor {{{
" matchup {{{ 匹配符跳转
" packadd matchit
let g:matchup_matchparen_offscreen = { 'method' : 'popup' }
map <S-m> %
" }}}

" easy-motion {{{ 快速跳转
let g:EasyMotion_dict = 'zh-cn'         " 支持简体中文拼音
let g:EasyMotion_do_mapping = 0         " 禁止默认map
let g:EasyMotion_smartcase = 1          " 不区分大小写
nmap s <Plug>(easymotion-overwin-f)
nmap f <Plug>(easymotion-bd-fl)
nmap <leader>ms <Plug>(easymotion-sn)
nmap <leader>j <Plug>(easymotion-bd-jk)
nmap <leader><leader>j <Plug>(easymotion-overwin-line)
nmap <leader>mw <Plug>(easymotion-bd-w)
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

" illuminate {{{ 自动高亮
let g:Illuminate_useDeprecated = 1
let g:Illuminate_delay = 200
let g:Illuminate_ftblacklist = ['nerdtree']
nnoremap <leader>tg :IlluminationToggle<CR>
highlight link illuminatedWord MatchParen
" }}}

" textmanip {{{ 块编辑
let g:textmanip_enable_mappings = 0
" 切换Insert/Replace Mode
xnoremap <M-o>
    \ <Cmd>
    \ let g:textmanip_current_mode = (g:textmanip_current_mode == 'replace') ? 'insert' : 'replace' <Bar>
    \ echo 'textmanip mode: ' . g:textmanip_current_mode <CR>
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

" vim-visual-multi {{{ 多光标编辑
" Tab: 切换cursor/extend模式
let g:VM_mouse_mappings = 0         " 禁用鼠标
let g:VM_leader = ','
let g:VM_maps = {
    \ 'Find Under'           : '<C-n>',
    \ 'Cursor Down'          : '<C-Down>',
    \ 'Cursor Up'            : '<C-Up>',
    \ 'Select All'           : ',a',
    \ 'Start Regex Search'   : ',/',
    \ 'Add Cursor At Pos'    : ',,',
    \ 'Visual All'           : ',A',
    \ 'Visual Regex'         : ',/',
    \ 'Visual Cursors'       : ',c',
    \ 'Visual Add'           : ',a',
    \ 'Find Next'            : 'n',
    \ 'Find Prev'            : 'N',
    \ 'Goto Next'            : ']',
    \ 'Goto Prev'            : '[',
    \ 'Skip Region'          : 'q',
    \ 'Remove Region'        : 'Q',
    \ 'Select Operator'      : 'v',
    \ 'Toggle Mappings'      : ',<Space>',
    \ 'Toggle Single Region' : ',<CR>',
    \ }
let g:VM_custom_remaps = {
    \ 's' : '<Cmd>HopChar1<CR>',
    \ }
" }}}

" traces {{{ 预览增强
" 支持:s, :g, :v, :sort, :range预览
let g:traces_num_range_preview = 1      " 支持范围:N,M预览
" }}}

" easy-align {{{ 字符对齐
let g:easy_align_bypass_fold = 1
let g:easy_align_ignore_groups = []     " 默认任何group都进行对齐
" 默认对齐内含段落（Text Object: vip）
nmap <leader>al <Plug>(LiveEasyAlign)ip
xmap <leader>al <Plug>(LiveEasyAlign)
":EasyAlign[!] [N-th] DELIMITER_KEY [OPTIONS]
":EasyAlign[!] [N-th]/REGEXP/[OPTIONS]
nnoremap <leader><leader>a vip:EasyAlign<Space>*//l0><Left><Left><Left><Left>
vnoremap <leader><leader>a :EasyAlign<Space>*//l0><Left><Left><Left><Left>
nnoremap <leader><leader>A vip:EasyAlign<Space>
vnoremap <leader><leader>A :EasyAlign<Space>
" }}}

" expand-region {{{ 块扩展
map <M-r> <Plug>(expand_region_expand)
map <M-w> <Plug>(expand_region_shrink)
" }}}

" textobj-user {{{ 文本对象
" v-ai-wWsp(b[<t{B"'`
" v-ai-ifcmu
let g:textobj_indent_no_default_key_mappings = 1
omap ai <Plug>(textobj-indent-a)
omap ii <Plug>(textobj-indent-i)
xmap ai <Plug>(textobj-indent-a)
xmap ii <Plug>(textobj-indent-i)
omap au <Plug>(textobj-underscore-a)
omap iu <Plug>(textobj-underscore-i)
xmap au <Plug>(textobj-underscore-a)
xmap iu <Plug>(textobj-underscore-i)
" }}}

" FastFold {{{ 更新折叠
let g:fastfold_savehook = 0             " 只允许手动更新folds
let g:fastfold_fold_command_suffixes = ['x','X','a','A','o','O','c','C']
let g:fastfold_fold_movement_commands = ['z[', 'z]', 'zj', 'zk']
                                        " 允许指定的命令更新folds
nmap <leader>zu <Plug>(FastFoldUpdate)
" }}}
" }}}

" Component {{{
" theme {{{ Vim主题
let g:gruvbox_contrast_dark = 'soft'    " 背景选项：dark, medium, soft
let g:gruvbox_italic = 1
let g:gruvbox_invert_selection = 0
let g:one_allow_italics = 1
" }}}

" lightline {{{ StatusLine
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
            \ 'left' : [['absolutepath']],
            \ 'right': [['lite_info']],
            \ },
    \ 'tabline' : {
            \ 'left' : [['tabs']],
            \ 'right': [['close']],
            \ },
    \ 'component': {
            \ 'all_format': '%{&ft!=#""?&ft."/":""}%{&fenc!=#""?&fenc:&enc}/%{&ff}',
            \ 'all_info'  : 'U%-2B %p%% %l/%L $%v %{winnr()}.%n%{&mod?"+":""}',
            \ 'lite_info' : '%l/%L $%v %{winnr()}.%n%{&mod?"+":""}',
            \ },
    \ 'component_function': {
            \ 'mode'      : 'PkgMode',
            \ 'msg_left'  : 'PkgMsgLeft',
            \ 'msg_right' : 'PkgMsgRight',
            \ },
    \ 'component_expand': {
            \ 'chk_indent'  : 'PkgCheckMixedIndent',
            \ 'chk_trailing': 'PkgCheckTrailing',
            \ },
    \ 'component_type': {
            \ 'chk_indent'  : 'error',
            \ 'chk_trailing': 'error',
            \ },
    \ 'fallback' : {'Popc': 0, 'vista': 'Vista', 'nerdtree': 'NerdTree'},
    \ }
if s:use.ui.icon
let g:lightline.separator            = {'left': '', 'right': ''}
let g:lightline.subseparator         = {'left': '', 'right': ''}
let g:lightline.tabline_separator    = {'left': '', 'right': ''}
let g:lightline.tabline_subseparator = {'left': '', 'right': ''}
let g:lightline.component = {
        \ 'all_format': '%{&ft!=#""?&ft."":""}%{&fenc!=#""?&fenc:&enc}%{&ff}',
        \ 'all_info'  : 'U%-2B %p%% %l/%L %v %{winnr()}.%n%{&mod?"+":""}',
        \ 'lite_info' : '%l/%L %v %{winnr()}.%n%{&mod?"+":""}',
        \ }
endif

nnoremap <leader>tl :call lightline#toggle()<CR>
nnoremap <leader>tk
    \ <Cmd>
    \ let b:statusline_check_enabled = !get(b:, 'statusline_check_enabled', v:true) <Bar>
    \ call lightline#update() <Bar>
    \ echo 'b:statusline_check_enabled = ' . b:statusline_check_enabled <CR>

" Augroup: Lightline {{{
augroup PkgLightline
    autocmd!
    autocmd ColorScheme * call PkgOnColorScheme()
    autocmd CursorHold,BufWritePost * call PkgCheckRefresh()
augroup END

function! PkgOnColorScheme()
    if !exists('g:loaded_lightline')
        return
    endif
    try
        let g:lightline.colorscheme = g:colors_name
        call lightline#init()
        call lightline#colorscheme()
        call lightline#update()
    catch /^Vim\%((\a\+)\)\=:E117/      " E117: 函数不存在
    endtry
endfunction

function! PkgCheckRefresh()
    if !exists('g:loaded_lightline') || get(b:, 'lightline_changedtick', 0) == b:changedtick
        return
    endif
    unlet! b:lightline_changedtick
    call lightline#update()
    let b:lightline_changedtick = b:changedtick
endfunction
" }}}

" Function: lightline components {{{
function! PkgMode()
    return &ft ==# 'Popc' ? 'Popc' :
        \ &ft ==# 'alpha' ? 'Alpha' :
        \ &ft ==# 'startify' ? 'Startify' :
        \ &ft ==# 'qf' ? (QuickfixType() ==# 'c' ? 'Quickfix' : 'Location') :
        \ &ft ==# 'help' ? 'Help' :
        \ lightline#mode()
endfunction

function! PkgMsgLeft()
    return substitute(Expand('%', ':p'), '^' . escape(Expand(SvarWs().fw.path), '\'), '', '')
endfunction

function! PkgMsgRight()
    return SvarWs().fw.path
endfunction

function! PkgCheckMixedIndent()
    if !get(b:, 'statusline_check_enabled', v:true)
        return ''
    endif
    let l:ret = search('\m\(\t \| \t\)', 'nw')
    return (l:ret == 0) ? '' : 'M:'.string(l:ret)
endfunction

function! PkgCheckTrailing()
    if !get(b:, 'statusline_check_enabled', v:true)
        return ''
    endif
    let ret = search('\m\s\+$', 'nw')
    return (l:ret == 0) ? '' : 'T:'.string(l:ret)
endfunction
" }}}
" }}}

" startify {{{ 启动首页
let g:startify_bookmarks = [
    \ {'c': '$DotVimVimL/init.vim'},
    \ {'o': '$DotVimLocal/todo.md'} ]
let g:startify_lists = [
    \ {'type': 'bookmarks', 'header': ['   Bookmarks']},
    \ {'type': 'files',     'header': ['   Recent Files']},
    \ ]
let g:startify_files_number = 8
let g:startify_custom_header = 'startify#pad(startify#fortune#cowsay(PkgTodo(), "─", "│", "┌", "┐", "┘", "└"))'
nnoremap <leader>su :Startify<CR>

function! PkgTodo()
    if filereadable($DotVimLocal.'/todo.md')
        let l:todo = filter(readfile($DotVimLocal.'/todo.md'), 'v:val !~ "\\m^[ \t]*$"')
        return empty(l:todo) ? '' : l:todo
    else
        return ''
    endif
endfunction
" }}}

" rainbow {{{ 彩色括号
let g:rainbow_active = 1
nnoremap <leader>tr :RainbowToggle<CR>
" }}}

" indentLine {{{ 显示缩进标识
let g:indentLine_char = '⁞'             " 设置标识符样式
let g:indentLinet_color_term = 200      " 设置标识符颜色
let g:indentLine_concealcursor = 'nvic'
let g:indentLine_fileTypeExclude = ['startify', 'alpha']
nnoremap <leader>ti :IndentLinesToggle<CR>
" }}}

" popset {{{
let g:Popset_SelectionData = [{
        \ 'opt' : ['colorscheme', 'colo'],
        \ 'lst' : ['gruvbox', 'one', 'monokai_pro', 'monokai_soda'],
    \}]
nnoremap <leader><leader>p :PopSet<Space>
nnoremap <leader>sp :PopSet popset<CR>
" }}}

" popc {{{
" let g:Popc_enableLog = 1
let g:Popc_jsonPath = $DotVimLocal
let g:Popc_useFloatingWin = 1
let Popc_useNerdSymbols = s:use.ui.icon
if s:use.ui.icon
let g:Popc_symbols = { 'Sep' : ['', ''], 'SubSep': [ '', '' ] }
endif
let g:Popc_highlight = {
    \ 'text'     : 'Pmenu',
    \ 'selected' : 'CursorLineNr',
    \ }
let g:Popc_useTabline = 1
let g:Popc_useStatusline = 1
let g:Popc_wksSaveUnderRoot = 0
let g:Popc_wksRootPatterns = ['.popc', '.git', '.svn', '.hg', 'tags']
nnoremap <leader><leader>h <Cmd>PopcBuffer<CR>
nnoremap <M-u> <Cmd>PopcBufferSwitchTabLeft!<CR>
nnoremap <M-p> <Cmd>PopcBufferSwitchTabRight!<CR>
nnoremap <M-i> <Cmd>PopcBufferSwitchLeft!<CR>
nnoremap <M-o> <Cmd>PopcBufferSwitchRight!<CR>
nnoremap <C-i> <Cmd>PopcBufferJumpPrev<CR>
nnoremap <Tab> <Cmd>PopcBufferJumpPrev<CR>
nnoremap <C-o> <Cmd>PopcBufferJumpNext<CR>
nnoremap <C-u> <C-o>
nnoremap <C-p> <C-i>
nnoremap <leader>wq <Cmd>PopcBufferClose!<CR>
nnoremap <leader><leader>b <Cmd>PopcBookmark<CR>
nnoremap <leader><leader>w <Cmd>PopcWorkspace<CR>
nnoremap <leader>ty
    \ <Cmd>
    \ let g:Popc_tablineLayout = (get(g:, 'Popc_tablineLayout', 0) + 1) % 3 <Bar>
    \ call call('popc#stl#TabLineSetLayout',
    \           [['buffer', 'tab'], ['buffer', ''], ['', 'tab']][g:Popc_tablineLayout])<CR>
" }}}

" nerdtree {{{ 目录树导航
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeStatusline = -1
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:NERDTreeMapActivateNode = 'o'
let g:NERDTreeMapOpenExpl = ''
let g:NERDTreeMapOpenRecursively = ''
let g:NERDTreeMapPreview = 'go'
let g:NERDTreeMapCloseDir = 'x'
let g:NERDTreeMapOpenInTab = 't'
let g:NERDTreeMapOpenInTabSilent = 'gt'
let g:NERDTreeMapOpenVSplit = 'i'
let g:NERDTreeMapOpenSplit = 'gi'
let g:NERDTreeMapPreviewSplit = ''
let g:NERDTreeMapPreviewVSplit = ''
let g:NERDTreeMapJumpLastChild = 'J'
let g:NERDTreeMapJumpFirstChild = 'K'
let g:NERDTreeMapJumpNextSibling = '<C-n>'
let g:NERDTreeMapJumpPrevSibling = '<C-p>'
let g:NERDTreeMapJumpParent = 'p'
let g:NERDTreeMapChangeRoot = 'cd'
let g:NERDTreeMapChdir = ''
let g:NERDTreeMapCWD = ''
let g:NERDTreeMapUpdir = 'U'
let g:NERDTreeMapUpdirKeepOpen = 'u'
let g:NERDTreeMapRefresh = 'r'
let g:NERDTreeMapRefreshRoot = 'R'
let g:NERDTreeMapToggleHidden = '.'
let g:NERDTreeMapToggleZoom = 'Z'
let g:NERDTreeMapQuit = 'q'
let g:NERDTreeMapToggleFiles = 'F'
let g:NERDTreeMapMenu = 'M'
let g:NERDTreeMapToggleBookmarks = ''
nnoremap <leader>tt :NERDTreeToggle<CR>
nnoremap <leader>tT <Cmd>execute ':NERDTree ' . Expand('%', ':p:h')<CR>
" }}}

" fzf {{{ 模糊查找
let g:fzf_command_prefix = 'Fzf'
let g:fzf_layout = { 'down': '40%' }
let g:fzf_preview_window = ['right:40%,border-sharp']
let $FZF_DEFAULT_OPTS='--bind alt-j:down,alt-k:up,esc:abort'
nnoremap <leader><leader>f :Fzf
augroup PkgFzf
    autocmd!
    autocmd Filetype fzf tnoremap <buffer> <Esc> <C-c>
augroup END
" }}}

" LeaderF {{{ 模糊查找
if s:use.has_py
let g:Lf_CacheDirectory = $DotVimLocal
let g:Lf_PreviewInPopup = 1
let g:Lf_PreviewResult = {'File': 0, 'Buffer': 0, 'Mru': 0, 'Tag': 0, 'Rg': 0}
let g:Lf_StlSeparator = s:use.ui.icon ? {'left': '', 'right': ''} : {'left': '', 'right': ''}
let g:Lf_ShowDevIcons = 0
let g:Lf_ShortcutF = ''
let g:Lf_ShortcutB = ''
let g:Lf_ReverseOrder = 1
let g:Lf_ShowHidden = 1
let g:Lf_DefaultExternalTool = 'rg'
let g:Lf_UseVersionControlTool = 1
let g:Lf_WildIgnore = {
    \ 'dir': ['.git', '.svn', '.hg'],
    \ 'file': []
    \ }
let g:Lf_GtagsAutoGenerate = 0
let g:Lf_GtagsAutoUpdate = 0
nnoremap <leader><leader>l :Leaderf
nnoremap <leader>lf :LeaderfFile<CR>
nnoremap <leader>lu :LeaderfFunction<CR>
nnoremap <leader>ll :LeaderfLine<CR>
nnoremap <leader>lb :LeaderfBuffer<CR>
nnoremap <leader>lr :LeaderfMru<CR>
endif
" }}}
" }}}

" Coding {{{
" coc {{{ 自动补全
if s:use.coc
let g:coc_config_home = $DotVimShare
let g:coc_data_home = $DotVimLocal . '/.coc'
let g:coc_global_extensions = ['coc-marketplace']
let g:coc_status_error_sign = '🗴'
let g:coc_status_warning_sign = ''
let g:coc_filetype_map = {}
let g:coc_snippet_next = '<M-l>'
let g:coc_snippet_prev = '<M-h>'
" inoremap <silent><expr> <CR>
"     \ coc#pum#visible() ? coc#pum#confirm() :
"     \ "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"
inoremap <silent><expr> <M-j> coc#pum#visible() ? coc#pum#next(1) : "\<M-j>"
inoremap <silent><expr> <M-k> coc#pum#visible() ? coc#pum#prev(1) : "\<M-k>"
imap <C-j> <M-j>
imap <C-k> <M-k>
inoremap <silent><expr> <M-i> coc#refresh()
inoremap <silent><expr> <M-e> coc#pum#cancel()
inoremap <M-o> <Cmd>call CocActionAsync('showSignatureHelp')<CR>
nnoremap <M-f> <Cmd>call coc#float#scroll(1)<CR>
nnoremap <M-d> <Cmd>call coc#float#scroll(0)<CR>
inoremap <M-f> <Cmd>call coc#float#scroll(1)<CR>
inoremap <M-d> <Cmd>call coc#float#scroll(0)<CR>
nnoremap <M-n> <Cmd>call coc#float#scroll(1)<CR>
nnoremap <M-m> <Cmd>call coc#float#scroll(0)<CR>
inoremap <M-n> <Cmd>call coc#float#scroll(1)<CR>
inoremap <M-m> <Cmd>call coc#float#scroll(0)<CR>
nmap         gd <Plug>(coc-definition)
nmap         gD <Plug>(coc-declaration)
nmap <leader>gd <Plug>(coc-definition)
nmap <leader>gD <Plug>(coc-declaration)
nmap <leader>gi <Plug>(coc-implementation)
nmap <leader>gy <Plug>(coc-type-definition)
nmap <leader>gr <Plug>(coc-references)
nmap <leader>gR <Plug>(coc-references-used)
nmap <leader>gf <Plug>(coc-fix-current)
nmap <leader>gn <Plug>(coc-rename)
nmap <leader>gj <Plug>(coc-float-jump)
nmap <leader>gc <Plug>(coc-float-hide)
nmap <leader>ga <Plug>(coc-codeaction-cursor)
nnoremap <leader>gh <Cmd>call CocActionAsync('doHover')<CR>
vmap <leader>of <Plug>(coc-format-selected)
nmap <leader>of <Plug>(coc-format)
nnoremap <leader>od <Cmd>call CocAction('diagnosticList')<CR>
nnoremap <leader>oD <Cmd>call CocAction('diagnosticToggleBuffer')<CR>
nmap <leader>oi <Plug>(coc-diagnostic-info)
nmap <leader>oj <Plug>(coc-diagnostic-next-error)
nmap <leader>ok <Plug>(coc-diagnostic-prev-error)
nmap <leader>oJ <Plug>(coc-diagnostic-next)
nmap <leader>oK <Plug>(coc-diagnostic-prev)
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
nnoremap <leader>oR :CocRestart<CR>
nnoremap <leader>on :CocConfig<CR>
nnoremap <leader>oN :CocLocalConfig<CR>
nnoremap <leader>ol <Cmd>CocList --normal lists<CR>
nnoremap <leader>os <Cmd>CocList --normal sources<CR>
nnoremap <leader>ox <Cmd>CocList --normal extensions<CR>
nnoremap <leader>ow <Cmd>CocList --normal folders<CR>
nnoremap <leader>om <Cmd>CocList --normal marketplace<CR>
nnoremap <leader>oc <Cmd>CocList commands<CR>
" coc-extensions
nnoremap <leader>oh <Cmd>CocCommand clangd.switchSourceHeader<CR>
nnoremap <leader>oe <Cmd>CocCommand rust-analyzer.expandMacro<CR>
nnoremap <leader>op <Cmd>CocCommand cSpell.toggleEnableSpellChecker<CR>
nmap <leader>oe <Plug>(coc-calc-result-append)

function! PkgSetupCoc(timer)
    call plug#load('coc.nvim')
    for [sec, val] in items(Env_coc_settings())
        call coc#config(sec, val)
    endfor
endfunction
call timer_start(700, 'PkgSetupCoc')
endif
" }}}

" snipmate {{{ 代码片段
set rtp^=$DotVimShare
function! PkgLoadSnip(filename)
    return join(readfile($DotVimShare . '/' . a:filename), "\n")
endfunction
let g:snips_no_mappings = 1
imap <Tab> <Plug>snipMateTrigger
imap <M-l> <Plug>snipMateNextOrTrigger
smap <M-l> <Plug>snipMateNextOrTrigger
imap <M-h> <Plug>snipMateBack
smap <M-h> <Plug>snipMateBack
" }}}

" vimspector {{{ 调试
if s:use.ndap
let g:vimspector_install_gadgets = ['debugpy', 'vscode-cpptools', 'CodeLLDB']
nmap <F3>  <Plug>VimspectorStop
nmap <F4>  <Plug>VimspectorRestart
nmap <F5>  <Plug>VimspectorContinue
nmap <F6>  <Plug>VimspectorPause
nmap <F7>  <Plug>VimspectorToggleConditionalBreakpoint
nmap <F8>  <Plug>VimspectorAddFunctionBreakpoint
nmap <F9>  <Plug>VimspectorToggleBreakpoint
nmap <F10> <Plug>VimspectorStepOver
nmap <F11> <Plug>VimspectorStepInto
nmap <F12> <Plug>VimspectorStepOut
nnoremap <leader>dr :VimspectorReset<CR>
nnoremap <leader>de :VimspectorEval<Space>
nnoremap <leader>dw :VimspectorWatch<Space>
nnoremap <leader>dW :VimspectorShowOutput<Space>
nnoremap <leader>di
    \ <Cmd>call PopSelection({
        \ 'opt' : 'select debug configuration',
        \ 'lst' : keys(json_decode(join(readfile('.vimspector.json'))).configurations),
        \ 'cmd' : {sopt, sel -> vimspector#LaunchWithSettings({'configuration': sel})}
        \})<CR>
endif
" }}}

" auto-pairs {{{ 自动括号
let g:AutoPairsShortcutToggle = ''
let g:AutoPairsShortcutFastWrap = ''
let g:AutoPairsShortcutJump = ''
let g:AutoPairsShortcutFastBackInsert = ''
nnoremap <leader>tp :call AutoPairsToggle()<CR>
" }}}

" nerdcommenter {{{ 批量注释
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 0               " 在Comment后添加Space
nmap <leader>ci <Plug>NERDCommenterInvert
nmap <leader>cl <Plug>NERDCommenterAlignBoth
nmap <leader>cu <Plug>NERDCommenterUncomment
nmap <leader>ct <Plug>NERDCommenterAltDelims
" }}}

" surround {{{ 添加包围符
let g:surround_no_mappings = 1
xmap vs  <Plug>VSurround
xmap vS  <Plug>VgSurround
nmap ys  <Plug>Ysurround
nmap yS  <Plug>YSurround
nmap <leader>sw ysiw
nmap <leader>sW ySiw
nmap ysl <Plug>Yssurround
nmap ysL <Plug>YSsurround
nmap ds  <Plug>Dsurround
nmap cs  <Plug>Csurround
" }}}

" quickhl {{{ 快速高亮
map <leader>hw <Plug>(quickhl-manual-this)
map <leader>hs <Plug>(quickhl-manual-this-whole-word)
map <leader>hc <Plug>(quickhl-manual-clear)
nmap <leader>hr <Plug>(quickhl-manual-reset)
nmap <leader>th <Plug>(quickhl-manual-toggle)
" }}}

" asyncrun {{{ 导步运行程序
let g:asyncrun_open = 8                 " 自动打开quickfix window
let g:asyncrun_save = 1                 " 自动保存当前文件
let g:asyncrun_local = 1                " 使用setlocal的efm
nnoremap <leader><leader>r :AsyncRun<Space>
vnoremap <leader><leader>r <Cmd>call feedkeys(':AsyncRun ' . GetSelected(''), 'n')<CR>
nnoremap <leader>rk :AsyncStop<CR>
nnoremap <leader>rK :AsyncReset<CR>
" }}}

" floaterm {{{ 终端浮窗
set termwinkey=<C-l>
tnoremap <Esc> <C-l>N
nnoremap <leader>tz :FloatermToggle<CR>
nnoremap <leader><leader>m :Popc Floaterm<CR>
nnoremap <leader><leader>z :FloatermNew --cwd=.<Space>
tnoremap <M-u> <C-\><C-n>:FloatermFirst<CR>
tnoremap <M-i> <C-\><C-n>:FloatermPrev<CR>
tnoremap <M-o> <C-\><C-n>:FloatermNext<CR>
tnoremap <M-p> <C-\><C-n>:FloatermLast<CR>
tnoremap <M-q> <C-\><C-n>:FloatermKill<CR>
tnoremap <M-h> <C-\><C-n>:FloatermHide<CR>
tnoremap <M-n> <C-\><C-n>:FloatermUpdate --height=0.6 --width=0.6<CR>
tnoremap <M-m> <C-\><C-n>:FloatermUpdate --height=0.9 --width=0.9<CR>
tnoremap <M-r> <C-\><C-n>:FloatermUpdate --position=topright<CR>
tnoremap <M-c> <C-\><C-n>:FloatermUpdate --position=center<CR>
nnoremap <leader>mz :FloatermNew --cwd=. zsh<CR>
nnoremap <leader>mf :FloatermNew lf<CR>
highlight! default link FloatermBorder Constant
" }}}

" Vista {{{ 代码Tags
let g:vista_echo_cursor = 0
let g:vista_stay_on_open = 0
let g:vista_disable_statusline = 1
nnoremap <leader>tv :Vista!!<CR>
" }}}
" }}}

" Utils {{{
" MarkDown {{{
let g:markdown_include_jekyll_support = 0
let g:markdown_enable_mappings = 0
let g:markdown_enable_spell_checking = 0
let g:markdown_enable_folding = 0       " 感觉MarkDown折叠引起卡顿时，关闭此项
let g:markdown_enable_conceal = 0       " 在Vim中显示MarkDown预览
let g:markdown_enable_input_abbreviations = 0
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 1
let g:mkdp_refresh_slow = 0             " 即时预览MarkDown
let g:mkdp_command_for_global = 0       " 只有markdown文件可以预览
let g:mkdp_browser = 'firefox'
nnoremap <leader>vm
    \ <Cmd>
    \ echo get(b:, 'MarkdownPreviewToggleBool') ? 'Close markdown preview' : 'Open markdown preview' <Bar>
    \ call mkdp#util#toggle_preview()<CR>
nnoremap <leader>tb
    \ <Cmd>
    \ let g:mkdp_browser = (g:mkdp_browser ==# 'firefox') ? 'chrome' : 'firefox' <Bar>
    \ echo 'Browser: ' . g:mkdp_browser <CR>
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
    \ execute ':AsyncRun restview ' . Expand('%', ':p:t') <Bar>
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
let g:vimtex_cache_root = $DotVimLocal . '/.vimtex'
let g:vimtex_view_general_viewer = 'sioyek'
let g:vimtex_complete_enabled = 1       " 使用vimtex#complete#omnifunc补全
let g:vimtex_complete_close_braces = 1
let g:vimtex_compiler_method = 'latexmk'
nmap <leader>at <Plug>(vimtex-toc-toggle)
nmap <leader>ab <Plug>(vimtex-compile-ss)
nmap <leader>aB <Plug>(vimtex-compile)
nmap <leader>as <Plug>(vimtex-stop)
nmap <leader>ac <Plug>(vimtex-clean)
nmap <leader>am <Plug>(vimtex-toggle-main)
nmap <leader>av <Plug>(vimtex-view)
" }}}

" colorizer {{{ 颜色预览
let g:colorizer_nomap = 1
let g:colorizer_startup = 0
nnoremap <leader>tc :ColorToggle<CR>
" }}}

" screensaver {{{ 屏保
nnoremap <leader>ss <Cmd>ScreenSaver clock<CR>
" }}}

" open-browser {{{ 在线搜索
let g:openbrowser_default_search = 'bing'
let g:openbrowser_search_engines = {'bing' : 'https://cn.bing.com/search?q={query}'}
map <leader>bs <Plug>(openbrowser-smart-search)
nnoremap <leader>big :OpenBrowserSearch -google<Space>
nnoremap <leader>bib :OpenBrowserSearch -bing<Space>
nnoremap <leader>bih :OpenBrowserSearch -github<Space>
nnoremap <leader>bb  <Cmd>call openbrowser#search(Expand('<cword>'), 'bing')<CR>
nnoremap <leader>bg  <Cmd>call openbrowser#search(Expand('<cword>'), 'google')<CR>
nnoremap <leader>bh  <Cmd>call openbrowser#search(Expand('<cword>'), 'github')<CR>
vnoremap <leader>bb  <Cmd>call openbrowser#search(GetSelected(' '), 'bing')<CR>
vnoremap <leader>bg  <Cmd>call openbrowser#search(GetSelected(' '), 'google')<CR>
vnoremap <leader>bh  <Cmd>call openbrowser#search(GetSelected(' '), 'github')<CR>
" }}}

" translator {{{ 翻译
let g:translator_default_engines = ['haici', 'bing', 'youdao']
nmap <Leader>tw <Plug>TranslateW
vmap <Leader>tw <Plug>TranslateWV
nnoremap <leader><leader>t :TranslateW<Space>
vnoremap <leader><leader>t <Cmd>call feedkeys(':TranslateW ' . GetSelected(' '), 'n')<CR>
highlight! default link TranslatorBorder Constant
" }}}

" im-select {{{ 输入法
if IsWin() || IsGw()
let g:im_select_get_im_cmd = 'im-select'
let g:im_select_default = '1033'        " 输入法代码：切换到期望的默认输入法，运行im-select
endif
let g:ImSelectSetImCmd = {key -> ['im-select', key]}
" }}}
" }}}

" Plug {{{
if !empty(s:use.xgit)
    let g:plug_url_format = s:use.xgit . '/%s.git'
endif
call plug#begin($DotVimDir.'/bundle')  " 设置插件位置，且自动设置了syntax enable和filetype plugin indent on
    " editor
    Plug 'andymass/vim-matchup'
    Plug 'yehuohan/vim-easymotion'
    Plug 'kshenoy/vim-signature'
    Plug 'RRethy/vim-illuminate'
    Plug 't9md/vim-textmanip'
    Plug 'tpope/vim-repeat'
    Plug 'mg979/vim-visual-multi'
    Plug 'markonm/traces.vim'
    Plug 'junegunn/vim-easy-align'
    Plug 'terryma/vim-expand-region'
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-indent'
    Plug 'glts/vim-textobj-comment'
    Plug 'adriaanzon/vim-textobj-matchit'
    Plug 'lucapette/vim-textobj-underscore'
    Plug 'Konfekt/FastFold'
    " component
    Plug 'yehuohan/lightline.vim'
    Plug 'mhinz/vim-startify'
if s:use.ui.icon
    Plug 'ryanoasis/vim-devicons'
endif
    Plug 'morhetz/gruvbox'
    Plug 'rakr/vim-one'
    Plug 'tanvirtin/monokai.nvim'
    Plug 'luochen1990/rainbow'
    Plug 'Yggdroot/indentLine'
    Plug 'yehuohan/popc'
    Plug 'yehuohan/popset'
    Plug 'yehuohan/popc-floaterm'
    Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTree']}
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
if s:use.has_py
    Plug 'Yggdroot/LeaderF', {'do': IsWin() ? './install.bat' : './install.sh'}
endif
    " coding
if s:use.coc
    Plug 'neoclide/coc.nvim', {'branch': 'release', 'on': []}
    Plug 'neoclide/jsonc.vim'
endif
    Plug 'garbas/vim-snipmate'
    Plug 'MarcWeber/vim-addon-mw-utils'
    Plug 'honza/vim-snippets'
if s:use.ndap
    Plug 'puremourning/vimspector'
endif
    Plug 'jiangmiao/auto-pairs'
    Plug 'scrooloose/nerdcommenter'
    Plug 'tpope/vim-surround'
    Plug 't9md/vim-quickhl'
    Plug 'skywind3000/asyncrun.vim'
    Plug 'voldikss/vim-floaterm'
    Plug 'liuchengxu/vista.vim', {'on': 'Vista'}
    Plug 'bfrg/vim-cpp-modern', {'for': ['c', 'cpp']}
    Plug 'rust-lang/rust.vim'
    Plug 'tikhomirov/vim-glsl'
    Plug 'beyondmarc/hlsl.vim', {'for': 'hlsl'}
    " utils
    Plug 'gabrielelana/vim-markdown', {'for': 'markdown'}
    Plug 'joker1007/vim-markdown-quote-syntax', {'for': 'markdown'}
    Plug 'iamcco/markdown-preview.nvim', {'for': 'markdown', 'do': { -> mkdp#util#install()}}
    Plug 'Rykka/riv.vim', {'for': 'rst'}
    Plug 'Rykka/InstantRst', {'for': 'rst'}
    Plug 'lervag/vimtex', {'for': 'tex'}
    Plug 'lilydjwg/colorizer', {'on': 'ColorToggle'}
    Plug 'itchyny/screensaver.vim'
    Plug 'tyru/open-browser.vim'
    Plug 'voldikss/vim-translator'
    Plug 'brglng/vim-im-select'
call plug#end()
" }}}

try
    set background=dark
    colorscheme gruvbox
catch /^Vim\%((\a\+)\)\=:E185/
    silent! colorscheme default
endtry
