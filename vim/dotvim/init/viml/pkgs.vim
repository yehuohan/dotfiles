let s:use = exists('*SvarUse') ? SvarUse() : v:lua.require('v.use').get()

if !exists('*IsWin')
function! IsWin()
    return (has('win32') || has('win64'))
endfunction
endif

if !exists('*IsGw')
function! IsGw()
    return has('win32unix')
endfunction
endif

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
    \ 's'     : '<Cmd>HopChar1<CR>',
    \ }
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

" expand-region {{{ 快速块选择
map <M-r> <Plug>(expand_region_expand)
map <M-w> <Plug>(expand_region_shrink)
" }}}

" traces {{{ 预览增强
" 支持:s, :g, :v, :sort, :range预览
let g:traces_num_range_preview = 1      " 支持范围:N,M预览
" }}}
" }}}

" Component {{{
" theme {{{ Vim主题
let g:gruvbox_contrast_dark = 'soft'    " 背景选项：dark, medium, soft
let g:gruvbox_italic = 1
let g:gruvbox_invert_selection = 0
let g:one_allow_italics = 1
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
let g:Popc_jsonPath = $DotVimLocal
let g:Popc_useFloatingWin = 1
let g:Popc_highlight = {
    \ 'text'     : 'Pmenu',
    \ 'selected' : 'CursorLineNr',
    \ }
let g:Popc_useTabline = 1
let g:Popc_useStatusline = 1
let g:Popc_usePowerFont = s:use.ui.patch
if s:use.ui.patch
let g:Popc_selectPointer = ''
let g:Popc_separator = {'left' : '', 'right': ''}
let g:Popc_subSeparator = {'left' : '', 'right': ''}
endif
let g:Popc_wksSaveUnderRoot = 0
let g:Popc_wksRootPatterns = ['.popc', '.git', '.svn', '.hg', 'tags']
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
nnoremap <leader>te :NERDTreeToggle<CR>
nnoremap <leader>tE <Cmd>execute ':NERDTree ' . Expand('%', ':p:h')<CR>
" }}}

" screensaver {{{ 屏保
nnoremap <leader>ss <Cmd>ScreenSaver clock<CR>
" }}}

" fzf {{{ 模糊查找
let g:fzf_command_prefix = 'Fzf'
let g:fzf_layout = { 'down': '40%' }
let g:fzf_preview_window = ['right:40%,border-sharp']
let $FZF_DEFAULT_OPTS='--bind alt-j:down,alt-k:up'
nnoremap <leader><leader>f :Fzf
augroup PkgFzf
    autocmd!
    autocmd Filetype fzf tnoremap <buffer> <Esc> <C-c>
augroup END
" }}}

" LeaderF {{{ 模糊查找
if s:use.has_py
" autocmd VimEnter * call execute('autocmd! LeaderF_Mru')
let g:Lf_CacheDirectory = $DotVimLocal
let g:Lf_PreviewInPopup = 1
let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0}
let g:Lf_StlSeparator = s:use.ui.patch ? {'left': '', 'right': ''} : {'left': '', 'right': ''}
let g:Lf_ShowDevIcons = 0
let g:Lf_ShortcutF = ''
let g:Lf_ShortcutB = ''
let g:Lf_ReverseOrder = 1
let g:Lf_ShowHidden = 1                 " 搜索隐藏文件和目录
let g:Lf_DefaultExternalTool = 'rg'
let g:Lf_UseVersionControlTool = 1
"let g:Lf_ExternalCommand = 'rg --files --no-ignore "%s"'
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
nnoremap <leader>lm :LeaderfMru<CR>
endif
" }}}
" }}}

" Coding {{{
" coc {{{ 自动补全
if s:use.coc
let g:coc_config_home = $DotVimMisc
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
nmap <leader>gt <Plug>(coc-type-definition)
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
nnoremap <leader>od <Cmd>call CocAction('diagnosticToggle')<CR>
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
endif
" }}}

" ultisnips {{{ 代码片段
if s:use.has_py
function! PkgLoadSnip(filename)
    return join(readfile($DotVimMisc . '/template/' . a:filename), "\n")
endfunction
let g:UltiSnipsEditSplit = 'vertical'
let g:UltiSnipsSnippetDirectories = [$DotVimDir . '/snips', 'UltiSnips']
let g:UltiSnipsExpandTrigger = '<Tab>'
let g:UltiSnipsJumpForwardTrigger = '<M-l>'
let g:UltiSnipsJumpBackwardTrigger = '<M-h>'
let g:UltiSnipsListSnippets = '<M-u>'
endif
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

" Vista {{{ 代码Tags
let g:vista_echo_cursor = 0
let g:vista_stay_on_open = 0
let g:vista_disable_statusline = 1
nnoremap <leader>tv :Vista!!<CR>
nnoremap <leader>vc :Vista coc<CR>
" }}}

" quickhl {{{ 单词高亮
map <leader>hw <Plug>(quickhl-manual-this)
map <leader>hs <Plug>(quickhl-manual-this-whole-word)
map <leader>hc <Plug>(quickhl-manual-clear)
nmap <leader>hr <Plug>(quickhl-manual-reset)
nmap <leader>th <Plug>(quickhl-manual-toggle)
" }}}

" floaterm {{{ 终端浮窗
if has('nvim')
tnoremap <C-l> <C-\><C-n><C-w>
tnoremap <Esc> <C-\><C-n>
else
set termwinkey=<C-l>
tnoremap <Esc> <C-l>N
endif
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
" }}}

" Utils {{{
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
    \ cal Notify(g:_instant_rst_daemon_started ? 'Close rst' : 'Open rst') <Bar>
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
