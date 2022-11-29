local use = vim.fn.SvarUse()
local map      = require('v.maps').map
local nmap     = require('v.maps').nmap
local vmap     = require('v.maps').vmap
local xmap     = require('v.maps').xmap
local smap     = require('v.maps').smap
local omap     = require('v.maps').omap
local imap     = require('v.maps').imap
local lmap     = require('v.maps').lmap
local cmap     = require('v.maps').cmap
local tmap     = require('v.maps').tmap
local noremap  = require('v.maps').noremap
local nnoremap = require('v.maps').nnoremap
local vnoremap = require('v.maps').vnoremap
local xnoremap = require('v.maps').xnoremap
local snoremap = require('v.maps').snoremap
local onoremap = require('v.maps').onoremap
local inoremap = require('v.maps').inoremap
local lnoremap = require('v.maps').lnoremap
local cnoremap = require('v.maps').cnoremap
local tnoremap = require('v.maps').tnoremap


--------------------------------------------------------------------------------
-- Editor
--------------------------------------------------------------------------------
-- 快速跳转
local function pkg_hop()
    require('hop').setup{
        match_mappings = { 'zh', 'zh_sc' },
        create_hl_autocmd = true,
    }
    noremap{'s', '<Cmd>HopChar1MW<CR>'}
    noremap{'f', '<Cmd>HopChar1CurrentLine<CR>'}
    noremap{'F', '<Cmd>HopAnywhereCurrentLine<CR>'}
    noremap{'<leader>ms', '<Cmd>HopPatternMW<CR>'}
    noremap{'<leader>j', '<Cmd>HopLineCursor<CR>'}
    noremap{'<leader><leader>j', '<Cmd>HopLine<CR>'}
    noremap{'<leader>mj', '<Cmd>HopLineStart<CR>'}
    noremap{'<leader>mw', '<Cmd>HopWord<CR>'}
end

-- 书签管理
local function pkg_marks()
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
end

-- 块编辑
local function pkg_gomove()
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
end

-- 平滑滚动
local function pkg_neoscroll()
    local neoscroll = require('neoscroll')
    neoscroll.setup{
        mappings = {},
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
end

-- 窗口跳转
local function pkg_winpick()
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
end

-- 窗口移动
local function pkg_winshift()
    require('winshift').setup{ }
    nnoremap{'<C-m>', ':WinShift<CR>'}
end

--------------------------------------------------------------------------------
-- Component
--------------------------------------------------------------------------------
-- 启动首页
local function pkg_alpha()
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
end

-- 消息提示
local function pkg_notify()
    require('notify').setup{
        max_width = function()
            return vim.api.nvim_get_option('columns') * 0.7
        end,
        minimum_width = 30,
        top_down = false,
    }
    vim.notify = require('notify')
    nnoremap{'<leader>dm', function() vim.notify.dismiss() end}
end

-- ui界面美化
local function pkg_dressing()
    require('dressing').setup{
        input = { enabled = true },
        select = { enabled = true },
    }
end

-- 字体图标
local function pkg_icon_picker()
    require('icon-picker').setup{ disable_legacy_commands = true }
    nnoremap{'<leader>ip', '<Cmd>IconPickerNormal alt_font symbols nerd_font emoji<CR>'}
    nnoremap{'<leader>iP', '<Cmd>IconPickerYank alt_font symbols nerd_font emoji<CR>'}
    inoremap{'<M-p>', '<Cmd>IconPickerInsert alt_font symbols nerd_font emoji<CR>'}
end

-- 刻度线
local function pkg_virt_column()
    require('virt-column').setup{ char = '┊' }
end

-- 滑动条
local function pkg_scrollbar()
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
end

-- 目录树导航
local function pkg_tree()
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
        actions = {
            open_file = {
                resize_window = false,
            },
        },
        filesystem_watchers = { enable = false },
        diagnostics = { enable = false },
        git = { enable = false },
    }
    nnoremap{'<leader>tt', ':NvimTreeToggle<CR>'}
    nnoremap{'<leader>tT',
        function()
            local tapi = require('nvim-tree.api')
            tapi.tree.close()
            tapi.tree.open(vim.fn.expand('%:p:h'))
        end}
end

-- 模糊查找
local function pkg_telescope()
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
end

--------------------------------------------------------------------------------
-- Coding
--------------------------------------------------------------------------------
-- 列表视图
local function pkg_trouble()
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
end

-- 颜色预览
local function pkg_ccc()
    nnoremap{'<leader>tc', ':CccHighlighterToggle<CR>'}
    nnoremap{'<leader>lp', ':CccPick<CR>'}
    local ccc = require('ccc')
    ccc.setup{
        disable_default_mappings = true,
        mappings = {
            ['<CR>'] = ccc.mapping.complete,
            ['q'] = ccc.mapping.quit,
            ['m'] = ccc.mapping.toggle_input_mode,
            ['f'] = ccc.mapping.toggle_output_mode,
            ['a'] = ccc.mapping.toggle_alpha,
            ['l'] = ccc.mapping.increase1,
            ['o'] = ccc.mapping.increase5,
            ['L'] = ccc.mapping.increase10,
            ['h'] = ccc.mapping.decrease1,
            ['i'] = ccc.mapping.decrease5,
            ['H'] = ccc.mapping.decrease10,
        },
    }
end

-- 自动括号
local function pkg_autopairs()
    require('nvim-autopairs').setup{
        map_cr = false,
    }
    nnoremap{'<leader>tp',
        function()
            local ap = require('nvim-autopairs').state.disabled
            print('Auto pairs:', ap)
            require('nvim-autopairs').state.disabled = not ap
        end}
end

-- 批量注释
local function pkg_comment()
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
end

-- 添加包围符
local function pkg_surround()
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
end

-- 代码折叠
local function pkg_ufo()
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
end

-- 语法树
local function pkg_treesitter()
if use.treesitter then
    require('nvim-treesitter.configs').setup{
        parser_install_dir = vim.env.DotVimCache .. '/.treesitter',
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
                node_decremental = '<M-a>',
                scope_incremental = '<M-v>',
            },
        },
        rainbow = {
            enable = true,
            extended_mode = true,
            max_file_lines = nil,
        }
    }
    vim.opt.runtimepath:append(vim.env.DotVimCache .. '/.treesitter')
    nnoremap{'<leader>sh', ':TSBufToggle highlight<CR>'}
    nnoremap{'<leader>si', ':TSBufToggle indent<CR>'}
    nnoremap{'<leader>ss', ':TSBufToggle incremental_selection<CR>'}
end
end

local function pkg_setup()
    -- Editor
    pkg_hop()
    pkg_marks()
    pkg_gomove()
    pkg_neoscroll()
    pkg_winpick()
    pkg_winshift()
    -- Component
    pkg_alpha()
    pkg_notify()
    pkg_dressing()
    pkg_icon_picker()
    pkg_virt_column()
    pkg_scrollbar()
    pkg_tree()
    pkg_telescope()
    -- Coding
    pkg_trouble()
    pkg_ccc()
    pkg_autopairs()
    pkg_comment()
    pkg_surround()
    pkg_ufo()
    pkg_treesitter()
end

return {
    setup = pkg_setup
}
