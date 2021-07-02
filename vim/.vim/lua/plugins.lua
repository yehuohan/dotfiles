-- vim:fdm=marker
local fn = vim.fn
local map = vim.api.nvim_set_keymap
local g = vim.g
local use = require('use').use


-- Plug {{{
-- 设置插件位置，且自动设置了syntax enable和filetype plugin indent on
fn['plug#begin'](vim.env.DotVimPath .. '/bundle')
vim.cmd([[
    " editing
    Plug 'yehuohan/vim-easymotion'
    Plug 'haya14busa/incsearch.vim'
    Plug 'haya14busa/incsearch-fuzzy.vim'
    Plug 'rhysd/clever-f.vim'
    Plug 'mg979/vim-visual-multi'
    Plug 't9md/vim-textmanip'
    Plug 'markonm/traces.vim'
    Plug 'godlygeek/tabular', {'on': 'Tabularize'}
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
    Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}

    " managers
    Plug 'morhetz/gruvbox'
    Plug 'yehuohan/popc'
    Plug 'yehuohan/popset'
]])
fn['plug#end']()
-- }}}

-- Editing {{{
-- easy-motion {{{ 快速跳转
g.EasyMotion_dict = 'zh-cn'             -- 支持简体中文拼音
g.EasyMotion_do_mapping = 0             -- 禁止默认map
g.EasyMotion_smartcase = 1              -- 不区分大小写
map('n', 's'         , [[<Plug>(easymotion-overwin-f)]]   , {})
map('n', '<leader>ms', [[<Plug>(easymotion-sn)]]          , {})
map('n', '<leader>j' , [[<Plug>(easymotion-bd-jk)]]       , {})
map('n', '<leader>k' , [[<Plug>(easymotion-overwin-line)]], {})
map('n', '<leader>mw', [[<Plug>(easymotion-bd-w)]]        , {})
map('n', '<leader>me', [[<Plug>(easymotion-bd-e)]]        , {})
map('n', 'z/',
    [[incsearch#go(incsearch#config#fuzzy#make({'prompt': 'z/'}))]],
    { noremap = true, silent = true, expr = true })
map('n', 'zg/',
    [[incsearch#go(incsearch#config#fuzzy#make({'prompt': 'z/', 'is_stay': 1}))]],
    { noremap = true, silent = true, expr = true })
-- }}}

-- clever-f {{{ 行跳转
g.clever_f_show_prompt = 1
-- }}}

-- vim-visual-multi {{{ 多光标编辑
-- Usage: https://github.com/mg979/vim-visual-multi/wiki
-- Tab: 切换cursor/extend模式
-- C-n: 添加word或selected region作为cursor
-- C-Up/Down: 移动当前position并添加cursor
-- <VM_leader>A: 查找当前word作为cursor
-- <VM_leader>/: 查找regex作为cursor（n/N用于查找下/上一个）
-- <VM_leader>\: 添加当前position作为cursor（使用/或arrows跳转位置）
-- <VM_leader>a <VM_leader>c: 添加visual区域作为cursor
-- s: 文本对象（类似于viw等）
g.VM_mouse_mappings = 0         -- 禁用鼠标
g.VM_leader = '\\'
g.VM_maps = {
    ['Find Under']         = '<C-n>',
    ['Find Subword Under'] = '<C-n>',
}
g.VM_custom_remaps = {
    ['<C-p>'] = '[',
    ['<C-s>'] = 'q',
    ['<C-c>'] = 'Q',
}
-- }}}

-- textmanip {{{ 块编辑
g.textmanip_enable_mappings = 0
-- 切换Insert/Replace Mode
map('x', '<M-o>',
    [[:<C-U>let g:textmanip_current_mode = (g:textmanip_current_mode == 'replace') ? 'insert' : 'replace'<Bar>]] ..
    [[:echo 'textmanip mode: ' . g:textmanip_current_mode<CR>gv]],
    { silent = true })
map('x', '<C-o>', '<M-o>', { silent = true })
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
-- }}}

-- tabular {{{ 字符对齐
-- /,/r2l0   -   第1个field使用第1个对齐符（右对齐），再插入2个空格
--               第2个field使用第2个对齐符（左对齐），再插入0个空格
--               第3个field又重新从第1个对齐符开始（对齐符可以有多个，循环使用）
--               这样就相当于：需对齐的field使用第1个对齐符，分割符(,)field使用第2个对齐符
-- /,\zs     -   将分割符(,)作为对齐内容field里的字符
map('n', '<leader><leader>a', [[:Tabularize /]], { noremap = true })
map('v', '<leader><leader>a', [[:Tabularize /]], { noremap = true })
-- }}}

-- easy-align {{{ 字符对齐
-- 默认对齐内含段落（Text Object: vip）
map('n', '<leader>ga', [[<Plug>(EasyAlign)ip]], {})
map('x', '<leader>ga', [[<Plug>(EasyAlign)]],   {})
-- 命令格式
-- :EasyAlign[!] [N-th]DELIMITER_KEY[OPTIONS]
-- :EasyAlign[!] [N-th]/REGEXP/[OPTIONS]
map('n', '<leader><leader>g',
    [[:let g:easy_align_range = v:lua.require'users.libs'.get_range('^[ \t]*$', '^[ \t]*$')<Bar>]] ..
    [[:call feedkeys(':' . join(g:easy_align_range, ',') . 'EasyAlign ', 'n')<CR>]],
    { noremap = true, silent = true })
map('v', '<leader><leader>g', [[:EasyAlign<Space>]], {})
-- }}}

-- smoothie {{{ 平滑滚动
g.smoothie_no_default_mappings = true
g.smoothie_update_interval = 30
g.smoothie_base_speed = 20
map('n', '<M-n>', [[<Plug>(SmoothieDownwards)]], { silent = true })
map('n', '<M-m>', [[<Plug>(SmoothieUpwards)]]  , { silent = true })
map('n', '<M-j>', [[<Plug>(SmoothieForwards)]] , { silent = true })
map('n', '<M-k>', [[<Plug>(SmoothieBackwards)]], { silent = true })
-- }}}

-- expand-region {{{ 快速块选择
map('n', '<C-p>', [[<Plug>(expand_region_expand)]], {})
map('v', '<C-p>', [[<Plug>(expand_region_expand)]], {})
map('n', '<C-u>', [[<Plug>(expand_region_shrink)]], {})
map('v', '<C-u>', [[<Plug>(expand_region_shrink)]], {})
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

-- undotree {{{ 撤消历史
map('n', '<leader>tu', [[:UndotreeToggle<CR>]], { noremap = true })
-- }}}
-- }}}

-- Manager {{{
-- theme {{{ Vim主题(ColorScheme, StatusLine, TabLine)
g.gruvbox_contrast_dark = 'soft'        -- 背景选项：dark, medium, soft
g.gruvbox_italic = 1
g.one_allow_italics = 1
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
g.Popc_usePowerFont = 1
if use.powerfont then
    g.Popc_selectPointer = ''
    g.Popc_separator = {left = '', right = ''}
    g.Popc_subSeparator = {left = '', right = ''}
else
    g.Popc_selectPointer = '►'
    g.Popc_separator = {left = '', right = ''}
    g.Popc_subSeparator = {left = '│', right = '│'}
end
g.Popc_useLayerPath = 0
g.Popc_useLayerRoots = {'.popc', '.git', '.svn', '.hg', 'tags', '.LfGtags'}
g.Popc_enableLog = 1
map('n', '<leader><leader>h', [[:PopcBuffer<CR>]]           , { noremap = true })
map('n', '<M-i>'            , [[:PopcBufferSwitchLeft<CR>]] , { noremap = true })
map('n', '<M-o>'            , [[:PopcBufferSwitchRight<CR>]], { noremap = true })
map('n', '<C-i>'            , [[:PopcBufferJumpPrev<CR>]]   , { noremap = true })
map('n', '<C-o>'            , [[:PopcBufferJumpNext<CR>]]   , { noremap = true })
map('n', '<C-h>'            , [[<C-o>]]                     , { noremap = true })
map('n', '<C-l>'            , [[<C-i>]]                     , { noremap = true })
map('n', '<leader>wq'       , [[:PopcBufferClose!<CR>]]     , { noremap = true })
map('n', '<leader><leader>b', [[:PopcBookmark<CR>]]         , { noremap = true })
map('n', '<leader><leader>w', [[:PopcWorkspace<CR>]]        , { noremap = true })
map('n', '<leader>ty',
    [=[:let g:Popc_tabline_layout = (get(g:, 'Popc_tabline_layout', 0) + 1) % 3<Bar>]=] ..
    [=[:call call('popc#stl#TabLineSetLayout', [['buffer', 'tab'], ['buffer', ''], ['', 'tab']][g:Popc_tabline_layout])<CR>]=],
    { noremap = true, silent = true })
-- }}}
-- }}}
