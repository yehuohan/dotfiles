-- vim:fdm=marker
local fn = vim.fn
local map = vim.api.nvim_set_keymap
local g = vim.g
local use = require('v.use').use


-- Plug {{{
-- 设置插件位置，且自动设置了syntax enable和filetype plugin indent on
fn['plug#begin'](vim.env.DotVimPath .. '/bundle')
vim.cmd([[
    " editing
    Plug 'phaazon/hop.nvim'
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
    Plug 'yehuohan/popc'
    Plug 'yehuohan/popset'
]])
fn['plug#end']()
-- }}}

-- Editing {{{
-- hop {{{ 快速跳转
require'hop'.setup({ dict_list = { 'ascii', 'zh_sc' }, create_hl_autocmd = true })
map('', 's'                , [[<Cmd>HopChar1MW<CR>]]    , { noremap = true })
map('', '<leader>ms'       , [[<Cmd>HopChar2MW<CR>]]    , { noremap = true })
map('', '<leader><leader>s', [[<Cmd>HopPatternMW<CR>]]  , { noremap = true })
map('', '<leader>j'        , [[<Cmd>HopLineStartMW<CR>]], { noremap = true })
map('', '<leader><leader>j', [[<Cmd>HopLineMW<CR>]]     , { noremap = true })
map('', '<leader>mw'       , [[<Cmd>HopWord<CR>]]       , { noremap = true })
map('', 'z/',
    [[incsearch#go(incsearch#config#fuzzy#make({'prompt': 'z/'}))]],
    { noremap = true, silent = true, expr = true })
map('n', 'zg/',
    [[incsearch#go(incsearch#config#fuzzy#make({'prompt': 'z/', 'is_stay': 1}))]],
    { noremap = true, silent = true, expr = true })
-- }}}

-- clever-f {{{ 行跳转
g.clever_f_across_no_line = 1
g.clever_f_show_prompt = 1
g.clever_f_smart_case = 1
-- }}}

-- vim-visual-multi {{{ 多光标编辑
-- Usage: https://github.com/mg979/vim-visual-multi/wiki
-- Tab: 切换cursor/extend模式
-- C-n: 添加word或selected region作为cursor
-- C-Up/Down: 移动当前position并添加cursor
-- <VM_leader>a: 查找当前word作为cursor
-- <VM_leader>/: 查找regex作为cursor（n/N用于查找下/上一个）
-- <VM_leader>\: 添加当前position作为cursor（使用/或arrows或Hop跳转位置）
-- <VM_leader>a <VM_leader>c: 添加visual区域作为cursor
-- v: 文本对象（类似于viw等）
g.VM_mouse_mappings = 0         -- 禁用鼠标
g.VM_leader = ','
g.VM_maps = {
    ['Find Under']         = '<C-n>',
    ['Find Subword Under'] = '<C-n>',
    ['Select All']         = ',a',
    ['Add Cursor At Pos']  = ',,',
    ['Select Operator']    = 'v',
}
g.VM_custom_remaps = {
    ['<C-p>'] = '[',
    ['<C-s>'] = 'q',
    ['<C-c>'] = 'Q',
    ['s']     = '<Cmd>HopChar1<CR>',
}
-- }}}

-- textmanip {{{ 块编辑
g.textmanip_enable_mappings = 0
-- 切换Insert/Replace Mode
map('x', '<M-o>',
    [[<Cmd>]] ..
    [[let g:textmanip_current_mode = (g:textmanip_current_mode == 'replace') ? 'insert' : 'replace'<Bar>]] ..
    [[echo 'textmanip mode: ' . g:textmanip_current_mode<CR>]], {})
map('x', '<C-o>', '<M-o>', {})
-- 更据Mode使用Move-Insert或Move-Replace
map('x', '<C-j>', [[<Plug>(textmanip-move-down)]] , {})
map('x', '<C-k>', [[<Plug>(textmanip-move-up)]]   , {})
map('x', '<C-h>', [[<Plug>(textmanip-move-left)]] , {})
map('x', '<C-l>', [[<Plug>(textmanip-move-right)]], {})
-- 更据Mode使用Duplicate-Insert或Duplicate-Replace
map('x', '<M-j>', [[<Plug>(textmanip-duplicate-down)]] , {})
map('x', '<M-k>', [[<Plug>(textmanip-duplicate-up)]]   , {})
map('x', '<M-h>', [[<Plug>(textmanip-duplicate-left)]] , {})
map('x', '<M-l>', [[<Plug>(textmanip-duplicate-right)]], {})
-- }}}

-- traces {{{ 预览增强
-- 支持:s, :g, :v, :sort, :range预览
g.traces_num_range_preview = 1          -- 支持:N,M预览
-- }}}

-- easy-align {{{ 字符对齐
g.easy_align_bypass_fold = 1
g.easy_align_ignore_groups = {}         -- 默认任何group都进行对齐
-- 默认对齐内含段落（Text Object: vip）
map('n', '<leader>al', [[<Plug>(EasyAlign)ip]], {})
map('x', '<leader>al', [[<Plug>(EasyAlign)]],   {})
-- :EasyAlign[!] [N-th] DELIMITER_KEY [OPTIONS]
-- :EasyAlign[!] [N-th]/REGEXP/[OPTIONS]
map('n', '<leader><leader>a', [[vip:EasyAlign<Space>*//<Left>]], { noremap = true })
map('v', '<leader><leader>a', [[:EasyAlign<Space>*//<Left>]]   , { noremap = true })
map('n', '<leader><leader>A', [[vip:EasyAlign<Space>]]         , { noremap = true })
map('v', '<leader><leader>A', [[:EasyAlign<Space>]]            , { noremap = true })
-- }}}

-- smoothie {{{ 平滑滚动
g.smoothie_no_default_mappings = true
g.smoothie_update_interval = 30
g.smoothie_base_speed = 20
map('n', '<M-n>', [[<Plug>(SmoothieDownwards)]], {})
map('n', '<M-m>', [[<Plug>(SmoothieUpwards)]]  , {})
map('n', '<M-j>', [[<Plug>(SmoothieForwards)]] , {})
map('n', '<M-k>', [[<Plug>(SmoothieBackwards)]], {})
-- }}}

-- expand-region {{{ 快速块选择
map('', '<M-r>', [[<Plug>(expand_region_expand)]], {})
map('', '<M-w>', [[<Plug>(expand_region_shrink)]], {})
-- }}}

-- textobj-user {{{ 文本对象
-- vdc-ia-wWsp(b[<t{B"'`
-- vdc-ia-ifcmu
g.textobj_indent_no_default_key_mappings = 1
map('o', 'aI', [[<Plug>(textobj-indent-a)]]     , {})
map('o', 'iI', [[<Plug>(textobj-indent-i)]]     , {})
map('o', 'ai', [[<Plug>(textobj-indent-same-a)]], {})
map('o', 'ii', [[<Plug>(textobj-indent-same-i)]], {})
map('v', 'aI', [[<Plug>(textobj-indent-a)]]     , {})
map('v', 'iI', [[<Plug>(textobj-indent-i)]]     , {})
map('v', 'ai', [[<Plug>(textobj-indent-same-a)]], {})
map('v', 'ii', [[<Plug>(textobj-indent-same-i)]], {})
map('o', 'au', [[<Plug>(textobj-underscore-a)]] , {})
map('o', 'iu', [[<Plug>(textobj-underscore-i)]] , {})
map('v', 'au', [[<Plug>(textobj-underscore-a)]] , {})
map('v', 'iu', [[<Plug>(textobj-underscore-i)]] , {})
map('n', '<leader>tv', [[:lua PlugToMotion('v')<CR>]], { noremap = true })
map('n', '<leader>tV', [[:lua PlugToMotion('V')<CR>]], { noremap = true })
map('n', '<leader>td', [[:lua PlugToMotion('d')<CR>]], { noremap = true })
map('n', '<leader>tD', [[:lua PlugToMotion('D')<CR>]], { noremap = true })

local textobj_motion = vim.regex('/l')
function PlugToMotion(motion)
    fn.PopSelection({
        opt = 'select text object motion',
        lst = vim.split([[w W s p ( b [ < t { B " ' ` i f c m u]], ' '),
        cmd = function(_, sel)
            local c = ''
            if textobj_motion:match_str(motion)
            then c = 'i'
            else c = 'a' end
            vim.cmd(string.format('normal! %s%s%s', string.lower(motion), c, sel))
        end
    })
end
-- }}}

-- signature {{{ 书签管理
g.SignatureMap = {
    Leader            = 'm',
    PlaceNextMark     = 'm,',
    ToggleMarkAtLine  = 'm.',
    PurgeMarksAtLine  = 'm-',
    DeleteMark        = '', PurgeMarks        = '', PurgeMarkers      = '',
    GotoNextLineAlpha = '', GotoPrevLineAlpha = '', GotoNextLineByPos = '', GotoPrevLineByPos = '',
    GotoNextSpotAlpha = '', GotoPrevSpotAlpha = '', GotoNextSpotByPos = '', GotoPrevSpotByPos = '',
    GotoNextMarker    = '', GotoPrevMarker    = '', GotoNextMarkerAny = '', GotoPrevMarkerAny = '',
    ListBufferMarks   = '', ListBufferMarkers = '',
}
map('n', '<leader>ts', [[:SignatureToggleSigns<CR>]], { noremap = true })
map('n', '<leader>ma', [[:SignatureListBufferMarks<CR>]], { noremap = true })
map('n', '<leader>mc', [[:call signature#mark#Purge('all')<CR>]], { noremap = true })
map('n', '<leader>ml', [[:call signature#mark#Purge('line')<CR>]], { noremap = true })
map('n', '<M-,>',      [[:call signature#mark#Goto('prev', 'line', 'pos')<CR>]], { noremap = true })
map('n', '<M-.>',      [[:call signature#mark#Goto('next', 'line', 'pos')<CR>]], { noremap = true })
-- }}}

-- FastFold {{{ 更新折叠
g.fastfold_savehook = 0                 -- 只允许手动更新folds
g.fastfold_fold_command_suffixes = {'x','X','a','A','o','O','c','C'}
g.fastfold_fold_movement_commands = {'z[', 'z]', 'zj', 'zk'}
                                        -- 允许指定的命令更新folds
map('n', '<leader>zu', [[<Plug>(FastFoldUpdate)]], {})
-- }}}

-- undotree {{{ 撤消历史
map('n', '<leader>tu', [[:UndotreeToggle<CR>]], { noremap = true })
-- }}}
-- }}}

-- Manager {{{
-- theme {{{ Vim主题(ColorScheme, StatusLine, TabLine)
g.gruvbox_contrast_dark = 'soft'        -- 背景选项：dark, medium, soft
g.gruvbox_italic = 1
vim.o.background = 'dark'
if not pcall(vim.cmd, [[colorscheme gruvbox]]) then
    vim.cmd[[colorscheme default]]
end
-- }}}

-- popset {{{ 弹出选项
g.Popset_SelectionData = {{
        opt = {'colorscheme', 'colo'},
        lst = {'gruvbox', 'one'},
    }}
map('n', '<leader><leader>p', ':PopSet<Space>'    , { noremap = true })
map('n', '<leader>sp'       , ':PopSet popset<CR>', { noremap = true })
-- }}}

-- popc {{{ buffer管理
g.Popc_jsonPath = vim.env.DotVimCachePath
g.Popc_useFloatingWin = 1
g.Popc_highlight = {
    text     = 'Pmenu',
    selected = 'CursorLineNr',
}
g.Popc_usePowerFont = 1
g.Popc_useTabline = 1
g.Popc_useStatusline = 1
g.Popc_usePowerFont = use.powerfont
if use.powerfont then
    g.Popc_selectPointer = ''
    g.Popc_separator = {left = '', right = ''}
    g.Popc_subSeparator = {left = '', right = ''}
end
g.Popc_useLayerPath = 0
g.Popc_useLayerRoots = {'.popc', '.git', '.svn', '.hg', 'tags', '.LfGtags'}
g.Popc_enableLog = 1
map('n', '<leader><leader>h', [[:PopcBuffer<CR>]]               , { noremap = true })
map('n', '<M-u>'            , [[:PopcBufferSwitchTabLeft!<CR>]] , { noremap = true })
map('n', '<M-p>'            , [[:PopcBufferSwitchTabRight!<CR>]], { noremap = true })
map('n', '<M-i>'            , [[:PopcBufferSwitchLeft!<CR>]]    , { noremap = true })
map('n', '<M-o>'            , [[:PopcBufferSwitchRight!<CR>]]   , { noremap = true })
map('n', '<C-i>'            , [[:PopcBufferJumpPrev<CR>]]       , { noremap = true })
map('n', '<C-o>'            , [[:PopcBufferJumpNext<CR>]]       , { noremap = true })
map('n', '<C-u>'            , [[<C-o>]]                         , { noremap = true })
map('n', '<C-p>'            , [[<C-i>]]                         , { noremap = true })
map('n', '<leader>wq'       , [[:PopcBufferClose!<CR>]]         , { noremap = true })
map('n', '<leader><leader>b', [[:PopcBookmark<CR>]]             , { noremap = true })
map('n', '<leader><leader>w', [[:PopcWorkspace<CR>]]            , { noremap = true })
map('n', '<leader>ty',
    [=[<Cmd>]=] ..
    [=[let g:Popc_tabline_layout = (get(g:, 'Popc_tabline_layout', 0) + 1) % 3<Bar>]=] ..
    [=[call call('popc#stl#TabLineSetLayout', [['buffer', 'tab'], ['buffer', ''], ['', 'tab']][g:Popc_tabline_layout])<CR>]=],
    { noremap = true })
-- }}}
-- }}}
