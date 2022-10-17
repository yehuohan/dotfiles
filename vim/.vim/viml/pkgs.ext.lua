local use = vim.fn.SvarUse()

-- Maps {{{
local setmap = vim.keymap.set
local function setopts(opts, defaults)
    local map_opts = {}
    for k, v in pairs(opts) do
        if type(k) == 'string' then
            map_opts[k] = v
        end
    end
    if defaults then
        map_opts = vim.tbl_extend('keep', map_opts, defaults)
    end
    return map_opts
end

-- map works at normal and visual mode by default here
local function map(opts)      setmap({'n', 'v'},  opts[1], opts[2], setopts(opts, { remap = true })) end
local function nmap(opts)     setmap('n', opts[1], opts[2], setopts(opts, { remap = true })) end
local function vmap(opts)     setmap('v', opts[1], opts[2], setopts(opts, { remap = true })) end
local function xmap(opts)     setmap('x', opts[1], opts[2], setopts(opts, { remap = true })) end
local function smap(opts)     setmap('s', opts[1], opts[2], setopts(opts, { remap = true })) end
local function omap(opts)     setmap('o', opts[1], opts[2], setopts(opts, { remap = true })) end
local function imap(opts)     setmap('i', opts[1], opts[2], setopts(opts, { remap = true })) end
local function lmap(opts)     setmap('l', opts[1], opts[2], setopts(opts, { remap = true })) end
local function cmap(opts)     setmap('c', opts[1], opts[2], setopts(opts, { remap = true })) end
local function tmap(opts)     setmap('t', opts[1], opts[2], setopts(opts, { remap = true })) end
local function noremap(opts)  setmap({'n', 'v'},  opts[1], opts[2], setopts(opts, { noremap = true })) end
local function nnoremap(opts) setmap('n', opts[1], opts[2], setopts(opts, { noremap = true })) end
local function vnoremap(opts) setmap('v', opts[1], opts[2], setopts(opts, { noremap = true })) end
local function xnoremap(opts) setmap('x', opts[1], opts[2], setopts(opts, { noremap = true })) end
local function snoremap(opts) setmap('s', opts[1], opts[2], setopts(opts, { noremap = true })) end
local function onoremap(opts) setmap('o', opts[1], opts[2], setopts(opts, { noremap = true })) end
local function inoremap(opts) setmap('i', opts[1], opts[2], setopts(opts, { noremap = true })) end
local function lnoremap(opts) setmap('l', opts[1], opts[2], setopts(opts, { noremap = true })) end
local function cnoremap(opts) setmap('c', opts[1], opts[2], setopts(opts, { noremap = true })) end
local function tnoremap(opts) setmap('t', opts[1], opts[2], setopts(opts, { noremap = true })) end
-- }}}

-- Editor {{{
-- hop {{{ 快速跳转
require('hop').setup{
    match_mappings = { 'zh', 'zh_sc' },
    create_hl_autocmd = true,
}
noremap{'s', '<Cmd>HopChar1MW<CR>'}
noremap{'f', '<Cmd>HopChar1CurrentLine<CR>'}
noremap{'F', '<Cmd>HopAnywhereCurrentLine<CR>'}
noremap{'<leader>ms', '<Cmd>HopPatternMW<CR>'}
noremap{'<leader>j', '<Cmd>HopLineCursorMW<CR>'}
noremap{'<leader><leader>j', '<Cmd>HopLineMW<CR>'}
noremap{'<leader>mj', '<Cmd>HopLineStartMW<CR>'}
noremap{'<leader>mw', '<Cmd>HopWord<CR>'}
-- }}}

-- marks {{{ 书签管理
require('marks').setup{
    default_mappings = false,
    force_write_shada = true,
    cyclic = false,
    mappings = {
        toggle_mark = 'm',
        delete_line = '<leader>ml',
        delete_buf = '<leader>mc',
        next = '<M-.>',
        prev = '<M-,>',
    }
}
nnoremap{'<leader>ts', ':MarksToggleSigns<CR>'}
nnoremap{'<leader>ma', ':MarksListBuf<CR>'}
-- }}}

-- gomove {{{ 块编辑
require('gomove').setup {
    map_defaults = false,
    reindent = true,
    undojoin = true,
    move_past_end_col = false,
}
xmap{'<C-j>', '<Plug>GoVSMDown'}
xmap{'<C-k>', '<Plug>GoVSMUp'}
xmap{'<C-h>', '<Plug>GoVSMLeft'}
xmap{'<C-l>', '<Plug>GoVSMRight'}
xmap{'<M-j>', '<Plug>GoVSDDown'}
xmap{'<M-k>', '<Plug>GoVSDUp'}
xmap{'<M-h>', '<Plug>GoVSDLeft'}
xmap{'<M-l>', '<Plug>GoVSDRight'}
-- }}}

-- neoscroll {{{ 平滑滚动
local neoscroll = require('neoscroll')
neoscroll.setup{
    hide_cursor = false,
    stop_eof = true,
}
nnoremap{'<M-n>',
    function()
        if use.coc and vim.fn['coc#float#has_scroll']() == 1 then
            vim.fn['coc#float#scroll'](1)
        else
            neoscroll.scroll(vim.wo.scroll, true, 200)
        end
    end, {silent = true, nowait = true, expr = true} }
nnoremap{'<M-m>',
    function()
        if use.coc and vim.fn['coc#float#has_scroll']() == 1 then
            vim.fn['coc#float#scroll'](0)
        else
            neoscroll.scroll(-vim.wo.scroll, true, 200)
        end
    end, {silent = true, nowait = true, expr = true} }
nnoremap{'<M-j>', function() neoscroll.scroll(vim.api.nvim_win_get_height(0), true, 300) end }
nnoremap{'<M-k>', function() neoscroll.scroll(-vim.api.nvim_win_get_height(0), true, 300) end }
-- }}}

-- winpick {{{ 窗口跳转
local winpick = require('winpick')
winpick.setup{
    border = 'none',
    prompt = "Pick a window: ",
    format_label = winpick.defaults.format_label,
    chars = { 'f', 'j', 'd', 'k', 's', 'l' },
}
nnoremap{'<leader>wi',
    function()
        local winid, _ = winpick.select()
        if winid then
            vim.api.nvim_set_current_win(winid)
        end
    end}
-- }}}

-- winshift {{{ 窗口移动
require('winshift').setup{ }
nnoremap{'<C-m>', ':WinShift<CR>'}
-- }}}
-- }}}

-- Component {{{
-- alpha {{{ 启动首页
local tmp = require('alpha.themes.startify')
tmp.nvim_web_devicons.enabled = use.ui.patch
tmp.section.header.val = function()
    if vim.fn.filereadable(vim.env.DotVimCache .. '/todo.md') == 1 then
        local todo = vim.fn.filter(vim.fn.readfile(vim.env.DotVimCache .. '/todo.md'), 'v:val !~ "\\m^[ \t]*$"')
        if vim.tbl_isempty(todo) then
            return ''
        end
        return todo
    else
        return ''
    end
end
tmp.section.bookmarks = {
    type = 'group',
    val = {
        { type = 'padding', val = 1 },
        { type = 'text', val = 'Bookmarks', opts = { hl = 'SpecialComment' } },
        { type = 'padding', val = 1 },
        { type = 'group', val = {
            tmp.file_button('$DotVimDir/.init.vim', 'c'),
            tmp.file_button('$NVimConfigDir/init.vim', 'd'),
            tmp.file_button('$DotVimCache/todo.md', 'o'),
        }},
    },
}
tmp.section.mru = {
    type = 'group',
    val = {
        { type = 'padding', val = 1 },
        { type = 'text', val = 'Recent Files', opts = { hl = 'SpecialComment' } },
        { type = 'padding', val = 1 },
        { type = 'group', val = function() return { tmp.mru(0, false, 8) } end },
    },
}
tmp.config.layout = {
    { type = 'padding', val = 1 },
    tmp.section.header,
    { type = 'padding', val = 2 },
    tmp.section.top_buttons,
    tmp.section.bookmarks,
    tmp.section.mru,
    { type = 'padding', val = 1 },
    tmp.section.bottom_buttons,
}
require('alpha').setup(tmp.config)
nnoremap{'<leader>su', ':Alpha<CR>'}
-- }}}

-- notify {{{ 消息提示
require('notify').setup{ }
vim.notify = require('notify')
-- }}}

-- dressing {{{ 字体图标
require('dressing').setup{
    input = { enabled = true },
    select = { enabled = true },
}
-- }}}

-- icon-picker {{{ 字体图标
require('icon-picker').setup{ disable_legacy_commands = true }
nnoremap{'<leader>ip', '<Cmd>IconPickerNormal alt_font symbols nerd_font emoji<CR>'}
nnoremap{'<leader>iP', '<Cmd>IconPickerYank alt_font symbols nerd_font emoji<CR>'}
inoremap{'<M-p>', '<Cmd>IconPickerInsert alt_font symbols nerd_font emoji<CR>'}
-- }}}

-- virt-column {{{ 刻度线
require('virt-column').setup{ char = '┊' }
-- }}}

-- scrollbar {{{ 滑动条
require('scrollbar').setup{
    handle = {
        text = '┃',
        color = nil,
        cterm = nil,
        highlight = 'Normal',
        hide_if_all_visible = true,
    },
    handlers = {
        diagnostic = false,
        search = false,
    },
    autocmd = {
        render = {
            'BufWinEnter',
            'TabEnter',
            'TermEnter',
            'WinEnter',
            'CmdwinLeave',
            'TextChanged',
            'VimResized',
            'WinScrolled',
        },
        clear = {
            'BufWinLeave',
            'TabLeave',
            'TermLeave',
            'WinLeave',
        },
    },
}
-- }}}

-- nvim-tree {{{ 目录树导航
local tcb = require('nvim-tree.config').nvim_tree_callback
require('nvim-tree').setup{
    auto_reload_on_write = false,
    view = {
        mappings = {
            custom_only = true,
            list = {
                { key = {'<CR>', 'o', '<2-LeftMouse>'},
                                 cb = tcb('edit') },
                { key = 'i'    , cb = tcb('vsplit') },
                { key = 'gi'   , cb = tcb('split') },
                { key = 't'    , cb = tcb('tabnew') },
                { key = '<Tab>', cb = tcb('preview') },
                { key = 'cd'   , cb = tcb('cd') },
                { key = 'u'    , cb = tcb('dir_up') },
                { key = 'K'    , cb = tcb('first_sibling') },
                { key = 'J'    , cb = tcb('last_sibling') },
                { key = '<C-p>', cb = tcb('prev_sibling') },
                { key = '<C-n>', cb = tcb('next_sibling') },
                { key = 'p'    , cb = tcb('parent_node') },
                { key = '.'    , cb = tcb('toggle_dotfiles') },
                { key = 'm'    , cb = tcb('toggle_file_info') },
                { key = 'r'    , cb = tcb('refresh') },
                { key = 'q'    , cb = tcb('close') },
                { key = '?'    , cb = tcb('toggle_help') },
                { key = 'O'    , cb = tcb('system_open') },
                { key = 'A'    , cb = tcb('create') },
                { key = 'D'    , cb = tcb('remove') },
                { key = 'R'    , cb = tcb('rename') },
                { key = '<C-r>', cb = tcb('full_rename') },
                { key = 'X'    , cb = tcb('cut') },
                { key = 'C'    , cb = tcb('copy') },
                { key = 'P'    , cb = tcb('paste') },
                { key = 'y'    , cb = tcb('copy_name') },
                { key = 'Y'    , cb = tcb('copy_absolute_path') },
            },
        },
    },
    renderer = {
        indent_markers = {
            enable = true,
            icons = {
                corner = '└ ',
                edge = '│ ',
                none = '  ',
            },
        },
    },
    diagnostics = { enable = false },
    git = { enable = false },
}
nnoremap{'<leader>tt', ':NvimTreeToggle<CR>'}
-- }}}

-- telescope {{{ 模糊查找
require('telescope').setup{
    defaults = {
        borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        color_devicons = true,
        history = {
            path = vim.env.DotVimCache  .. '/telescope_history',
        },
        mappings = {
            i = {
                ['<M-j>'] = 'move_selection_next',
                ['<M-k>'] = 'move_selection_previous',
            },
        }
    }
}
nnoremap{'<leader><leader>n', ':Telescope<Space>'}
nnoremap{'<leader>nf', ':Telescope find_files<CR>'}
nnoremap{'<leader>nl', ':Telescope live_grep<CR>'}
nnoremap{'<leader>nm', ':Telescope oldfiles<CR>'}
-- }}}
-- }}}

-- Coding {{{
-- trouble {{{ 列表视图
require('trouble').setup{
    mode = 'quickfix',
    icons = true,
    action_keys = {
        jump_close = {'O'},
        toggle_fold = {'zA', 'za', 'o'},
    },
    auto_preview = false,
}
nnoremap{'<leader>vq', ':TroubleToggle quickfix<CR>'}
nnoremap{'<leader>vl', ':TroubleToggle loclist<CR>'}
-- }}}

-- colorizer {{{ 颜色预览
nnoremap{'<leader>tc', ':ColorizerToggle<CR>'}
-- }}}

-- autopairs {{{ 自动括号
require('nvim-autopairs').setup{
    map_cr = false,
}
nnoremap{'<leader>tp',
    function()
        local ap = require('nvim-autopairs').state.disabled
        print('Auto pairs:', ap)
        require('nvim-autopairs').state.disabled = not ap
    end}
-- }}}

-- comment {{{ 批量注释
require('Comment').setup{
    toggler = { line = 'gcc', block = 'gbc' },
    opleader = { line = 'gc', block = 'gb' },
    mappings = {
        basic = true,
        extra = false,
        extended = false,
    },
}
local comment = require('Comment.api')
nnoremap{'<leader>ci', function() comment.toggle.linewise.count(vim.v.count1) end}
nnoremap{'<leader>cl', function() comment.comment.linewise.count(vim.v.count1) end}
nnoremap{'<leader>cu',
    function()
        -- ignore errors when uncommenting a non-commented line
        pcall(function() comment.uncomment.linewise.count(vim.v.count1) end)
    end}
-- }}}

-- surround {{{ 添加包围符
require('nvim-surround').setup{
    keymaps = {
        visual = 'vs',
        visual_line = 'vS',
        normal = 'ys',
        normal_line = 'yS',
        normal_cur = 'ysl',
        normal_cur_line = 'ysL',
        delete = 'ds',
        change = 'cs',
    },
}
nmap{'<leader>sw', 'ysiw'}
nmap{'<leader>sW', 'ySiw'}
-- }}}

-- ufo {{{ 代码折叠
local ufo = require('ufo')
ufo.setup{
    fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local res = {}
        local tag = '» '
        if use.ui.patch then
            tag = ' '
        end
        local tag_wid = vim.fn.strdisplaywidth(tag)

        for k, chunk in ipairs(virtText) do
            if k == 1 then
                -- only match whitespace characters of first chunk
                local txt = chunk[1]
                local s, e = vim.regex([[^\s*]]):match_str(txt)
                if s and e then
                    local wid = vim.fn.strdisplaywidth(txt:sub(s, e))
                    if wid >= tag_wid then
                        txt = txt:sub(e + 1)
                        if wid > tag_wid then
                            tag = tag .. ('·'):rep(wid - tag_wid - 1) .. ' '
                        end
                    end
                end
                table.insert(res, {tag, 'Comment'})
                table.insert(res, {txt, chunk[2]})
            else
                table.insert(res, chunk)
            end
        end
        table.insert(res, {('  %d '):format(endLnum - lnum), 'MoreMsg'})
        return res
    end,
    provider_selector = function(bufnr, filetype, buftype)
        return ''
    end
}
nnoremap{'<leader>to',
    function()
        local bufnr = vim.api.nvim_get_current_buf()
        if ufo.hasAttached(bufnr) then
            ufo.detach(bufnr)
        else
            ufo.attach(bufnr)
        end
    end}
-- }}}

-- illuminate {{{ 自动高亮
require('illuminate').configure{
    delay = 200,
    filetypes_denylist = { 'nerdtree', 'NvimTree' },
}
nnoremap{'<leader>tg', ':IlluminateToggle<CR>'}
vim.cmd[[
highlight link illuminatedWordText MatchParen
highlight link illuminatedWordRead MatchParen
]]
-- }}}

-- treesitter {{{ 语法树
if use.treesitter then
require('nvim-treesitter.configs').setup{
    parser_install_dir = vim.env.DotVimLocal,
    --ensure_installed = { 'c', 'cpp', 'rust', 'vim', 'lua', 'python', 'markdown', 'markdown_inline', },
    --auto_install = true,
    highlight = {
        enable = true,
        disable = { 'markdown', 'markdown_inline' },
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
        disable = { 'python' },
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<M-g>',
            node_incremental = '<M-g>',
            node_decremental = '<M-t>',
            scope_incremental = '<M-v>',
        },
    },
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil,
    }
}
vim.opt.runtimepath:append(vim.env.DotVimLocal)
nnoremap{'<leader>sh', ':TSBufToggle highlight<CR>'}
nnoremap{'<leader>si', ':TSBufToggle indent<CR>'}
nnoremap{'<leader>ss', ':TSBufToggle incremental_selection<CR>'}
end
-- }}}
-- }}}

-- Utils {{{
-- }}}

-- vim: fdm=marker
