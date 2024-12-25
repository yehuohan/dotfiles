local use = require('v.use')
local nlib = require('v.nlib')
local m = nlib.m

--------------------------------------------------------------------------------
-- Editor
--------------------------------------------------------------------------------
-- 配符跳转
local function pkg_matchup()
    -- packadd matchit
    vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    m.map({ '<S-m>', '%' })
end

-- 快速跳转
local function pkg_hop()
    require('hop').setup({ match_mappings = { 'zh', 'zh_sc' }, extensions = {} })
    m.nore({ 's', '<Cmd>HopChar1MW<CR>' })
    m.nore({ 'S', '<Cmd>HopChar1<CR>' })
    m.nore({ 'f', '<Cmd>HopChar1CurrentLine<CR>' })
    m.nore({ 'F', '<Cmd>HopAnywhereCurrentLine<CR>' })
    m.nore({ '<leader>ms', '<Cmd>HopPatternMW<CR>' })
    m.nore({ '<leader>j', '<Cmd>HopVertical<CR>' })
    m.nore({ '<leader><leader>j', '<Cmd>HopLine<CR>' })
    m.nore({ '<leader>mj', '<Cmd>HopLineStart<CR>' })
    m.nore({ '<leader>mw', '<Cmd>HopWord<CR>' })
end

-- 多光标编辑
local function pkg_visual_multi()
    -- Tab: 切换cursor/extend模式
    vim.g.VM_mouse_mappings = 0 -- 禁用鼠标
    vim.g.VM_leader = ','
    vim.g.VM_maps = {
        -- stylua: ignore start
        ['Find Under']           = '<leader><leader>v',
        ['Find Subword Under']   = '<leader><leader>v',
        ['Cursor Down']          = '<C-Down>',
        ['Cursor Up']            = '<C-Up>',
        ['Select All']           = ',a',
        ['Start Regex Search']   = ',/',
        ['Add Cursor At Pos']    = ',,',
        ['Visual All']           = ',A',
        ['Visual Regex']         = ',/',
        ['Visual Cursors']       = ',c',
        ['Visual Add']           = ',a',
        ['Find Next']            = 'n',
        ['Find Prev']            = 'N',
        ['Goto Next']            = ']',
        ['Goto Prev']            = '[',
        ['Skip Region']          = 'q',
        ['Remove Region']        = 'Q',
        ['Select Operator']      = 'v',
        ['Toggle Mappings']      = ',<Space>',
        ['Toggle Single Region'] = ',<CR>',
        -- stylua: ignore end
    }
    vim.g.VM_custom_remaps = {
        ['s'] = '<Cmd>HopChar1<CR>',
    }
end

-- 字符对齐
local function pkg_easy_align()
    vim.g.easy_align_bypass_fold = 1
    vim.g.easy_align_ignore_groups = {} -- 默认任何group都进行对齐
    m.nmap({ '<leader>al', '<Plug>(LiveEasyAlign)ip' })
    m.xmap({ '<leader>al', '<Plug>(LiveEasyAlign)' })
end

-- 书签管理
local function pkg_marks()
    require('marks').setup({
        default_mappings = false,
        force_write_shada = true,
        cyclic = false,
        mappings = {
            toggle_mark = 'm',
            delete_line = '<leader>ml',
            delete_buf = '<leader>mc',
            next = '<M-.>',
            prev = '<M-,>',
        },
    })
    m.nnore({ '<leader>ts', ':MarksToggleSigns<CR>' })
    m.nnore({ '<leader>ma', ':MarksListBuf<CR>' })
end

-- 自动高亮当前word
local function pkg_cursorword()
    vim.g.cursorword_disable_filetypes = { 'neo-tree' }
    vim.g.cursorword_disable_at_startup = false
    vim.g.cursorword_min_width = 2
    vim.g.cursorword_max_width = 64
    m.nnore({ '<leader>tg', ':CursorWordToggle<CR>' })
end

-- 块编辑
local function pkg_gomove()
    require('gomove').setup({
        map_defaults = false,
        reindent = true,
        undojoin = true,
        move_past_end_col = false,
    })
    m.xmap({ '<C-j>', '<Plug>GoVSMDown' })
    m.xmap({ '<C-k>', '<Plug>GoVSMUp' })
    m.xmap({ '<C-h>', '<Plug>GoVSMLeft' })
    m.xmap({ '<C-l>', '<Plug>GoVSMRight' })
    m.xmap({ '<M-j>', '<Plug>GoVSDDown' })
    m.xmap({ '<M-k>', '<Plug>GoVSDUp' })
    m.xmap({ '<M-h>', '<Plug>GoVSDLeft' })
    m.xmap({ '<M-l>', '<Plug>GoVSDRight' })
end

-- 窗口跳转
local function pkg_window_picker()
    local window_picker = require('window-picker')
    window_picker.setup({
        hint = 'floating-big-letter',
        filter_rules = {
            autoselect_one = false,
            include_current_win = true,
            bo = { filetype = {}, buftype = {} },
        },
    })
    m.nnore({
        '<leader>wi',
        function()
            local winid = window_picker.pick_window()
            if winid and vim.api.nvim_win_is_valid(winid) then
                vim.api.nvim_set_current_win(winid)
            end
        end,
    })
end

-- 窗口移动
local function pkg_winshift()
    require('winshift').setup({})
    m.nnore({ '<leader>wm', ':WinShift<CR>' })
end

-- 块扩展
local function pkg_expand_region()
    m.map({ '<M-r>', '<Plug>(expand_region_expand)' })
    m.map({ '<M-w>', '<Plug>(expand_region_shrink)' })
end

--------------------------------------------------------------------------------
-- Component
--------------------------------------------------------------------------------
-- Colorscheme gruvbox
local function pkg_gruvbox()
    require('gruvbox').setup({
        contrast = 'soft', -- 'hard', 'soft' or ''
        italic = {
            strings = false,
            emphasis = true,
            comments = true,
            operators = false,
            folds = true,
        },
    })
end

-- 启动首页
local function pkg_alpha()
    local tpl = require('alpha.themes.startify')
    tpl.nvim_web_devicons.enabled = use.ui.icon
    tpl.section.header.val = function()
        if vim.fn.filereadable(vim.env.DotVimLocal .. '/todo.md') == 1 then
            local text = vim.fn.readfile(vim.env.DotVimLocal .. '/todo.md')
            local todo = vim.fn.filter(text, 'v:val !~ "\\m^[ \t]*$"')
            if vim.tbl_isempty(todo) then
                return ''
            end
            return todo
        else
            return ''
        end
    end
    tpl.section.bookmarks = {
        type = 'group',
        val = {
            { type = 'padding', val = 1 },
            { type = 'text', val = 'Bookmarks', opts = { hl = 'SpecialComment' } },
            { type = 'padding', val = 1 },
            {
                type = 'group',
                val = {
                    tpl.file_button(vim.env.DotVimInit .. '/lua/v/init.lua', 'c'),
                    tpl.file_button(vim.env.NVimConfigDir .. '/init.lua', 'd'),
                    tpl.file_button(vim.env.DotVimLocal .. '/todo.md', 'o'),
                },
            },
        },
    }
    tpl.section.mru = {
        type = 'group',
        val = {
            { type = 'padding', val = 1 },
            { type = 'text', val = 'Recent Files', opts = { hl = 'SpecialComment' } },
            { type = 'padding', val = 1 },
            {
                type = 'group',
                val = function() return { tpl.mru(0, nil, 8) } end,
            },
        },
    }
    tpl.section.bottom_buttons.val = {
        tpl.button(
            'q',
            'Quit',
            [[<Cmd>try <Bar>
                normal! <C-^> <Bar>
            catch <Bar>
                q <Bar>
            endtry<CR>]]
        ),
    }
    tpl.config.layout = {
        { type = 'padding', val = 1 },
        tpl.section.header,
        { type = 'padding', val = 2 },
        tpl.section.top_buttons,
        tpl.section.bookmarks,
        tpl.section.mru,
        { type = 'padding', val = 1 },
        tpl.section.bottom_buttons,
    }
    require('alpha').setup(tpl.config)
    m.nnore({ '<leader>su', ':Alpha<CR>' })
end

-- 消息提示
local function pkg_notify()
    require('notify').setup({
        max_width = function()
            return math.floor(vim.api.nvim_get_option_value('columns', { scope = 'global' }) * 0.7)
        end,
        minimum_width = 30,
        top_down = false,
    })
    vim.notify = require('notify')
    m.nnore({ '<leader>dm', function() vim.notify.dismiss({ pending = true, silent = true }) end })
end

-- 系统消息提示
local function pkg_notifications()
    local notifications = require('notifications')
    notifications.setup({
        override_notify = false,
        hist_command = 'SysNotifications',
        icons = {
            TRACE = '🔍 ',
            DEBUG = '🐞 ',
            INFO = '📣 ',
            WARN = '⚠️  ',
            ERROR = '❌ ',
            OFF = '⛔ ',
        },
    })
    vim.sysnotify = notifications.notify
end

-- 代码折叠
local function pkg_ufo()
    local ufo = require('ufo')
    ufo.setup({
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
            local res = {}
            local tag = use.ui.icon and '' or '»'
            local tag_num = use.ui.icon and '󰁂' or '~'

            for k, chunk in ipairs(virtText) do
                if k == 1 then
                    -- only match whitespace characters of first chunk
                    local txt = chunk[1]:match('|| {{{ (.*)') or chunk[1]
                    local ta, tb = txt:match('(%s*)(.*)')
                    if ta and tb then
                        local dwid = vim.fn.strdisplaywidth(ta) - vim.fn.strdisplaywidth(tag)
                        tag = tag .. ('·'):rep(dwid - 1) .. ' '
                        txt = tb
                    end
                    table.insert(res, { tag, 'Comment' })
                    table.insert(res, { txt, chunk[2] })
                else
                    table.insert(res, chunk)
                end
            end
            table.insert(res, { ('  %s%d '):format(tag_num, endLnum - lnum), 'MoreMsg' })
            return res
        end,
        provider_selector = function() return use.nts and { 'treesitter', 'indent' } or { 'indent' } end,
    })
    vim.api.nvim_set_hl(0, 'UfoFoldedBg', { bg = '#5a5555' })
    m.nnore({
        '<leader>tu',
        function()
            local bufnr = vim.api.nvim_get_current_buf()
            if ufo.hasAttached(bufnr) then
                ufo.detach(bufnr)
            else
                ufo.attach(bufnr)
            end
        end,
    })
    m.nnore({ '<leader>zr', ufo.openAllFolds })
    m.nnore({ '<leader>zm', ufo.closeAllFolds })
end

-- QF增强
local function pkg_bqf()
    require('bqf').setup({
        auto_enable = true,
        preview = { auto_preview = false },
        func_map = {
            open = '', -- bqf's open doesn't trigger popc.buf's insertion
            pscrollorig = 'zP', -- bqf's pscrollorig breaks zo to open current fold
        },
    })
end

-- Buffer,Bookmarks,Workspace管理
local function pkg_popc()
    -- vim.g.Popc_enableLog = 1
    vim.g.Popc_jsonPath = vim.env.DotVimLocal
    vim.g.Popc_useFloatingWin = 1
    vim.g.Popc_useNerdSymbols = use.ui.icon
    if use.ui.icon then
        vim.g.Popc_symbols = { Sep = { '', '' }, SubSep = { '', '' } }
    end
    vim.g.Popc_highlight = {
        text = 'Pmenu',
        selected = 'CursorLineNr',
    }
    vim.g.Popc_useTabline = 1
    vim.g.Popc_useStatusline = 1
    vim.g.Popc_wksSaveUnderRoot = 0
    vim.g.Popc_wksRootPatterns = { '.popc', '.git', '.svn', '.hg', 'tags' }
    m.nnore({ '<leader><leader>h', '<Cmd>PopcBuffer<CR>' })
    m.nnore({ '<M-u>', '<Cmd>PopcBufferSwitchTabLeft!<CR>' })
    m.nnore({ '<M-p>', '<Cmd>PopcBufferSwitchTabRight!<CR>' })
    m.nnore({ '<M-i>', '<Cmd>PopcBufferSwitchLeft!<CR>' })
    m.nnore({ '<M-o>', '<Cmd>PopcBufferSwitchRight!<CR>' })
    m.nnore({ '<M-n>', '<Cmd>PopcBufferJumpPrev<CR>' })
    m.nnore({ '<M-m>', '<Cmd>PopcBufferJumpNext<CR>' })
    m.nnore({ '<C-n>', '<C-o>' })
    m.nnore({ '<C-m>', '<C-i>' })
    m.nnore({ '<leader>wq', '<Cmd>PopcBufferClose!<CR>' })
    m.nnore({ '<leader><leader>b', '<Cmd>PopcBookmark<CR>' })
    m.nnore({ '<leader><leader>w', '<Cmd>PopcWorkspace<CR>' })

    vim.g.Popset_SelectionData = {
        {
            opt = { 'colorscheme', 'colo' },
            lst = { 'gruvbox', 'monokai-nightasty' },
        },
    }
    m.nnore({ '<leader><leader>p', ':PopSet<Space>' })
    m.nnore({ '<leader>sp', ':PopSet popset<CR>' })
    m.nnore({ '<leader><leader>m', '<Cmd>Popc Floaterm<CR>' })
end

-- 目录树
local function pkg_neotree()
    --- Goto first sibling
    local first_sibling = function(state)
        local node = state.tree:get_node()
        local parent = state.tree:get_node(node:get_parent_id())
        local siblings = parent:get_child_ids()
        require('neo-tree.ui.renderer').focus_node(state, siblings[1])
    end

    --- Goto last sibling
    local last_sibling = function(state)
        local node = state.tree:get_node()
        local parent = state.tree:get_node(node:get_parent_id())
        local siblings = parent:get_child_ids()
        require('neo-tree.ui.renderer').focus_node(state, siblings[#siblings])
    end

    --- Open file with systme
    local open_system = function(state) vim.ui.open(state.tree:get_node().path) end

    --- Copy filepath from file  node
    local copy_filepath = function(mods)
        return function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            local copy = vim.fn.fnamemodify(path, mods)
            vim.fn.setreg('"', copy)
            vim.fn.setreg('0', copy)
            vim.fn.setreg('*', copy)
            vim.fn.setreg('+', copy)
            vim.notify('Copied: ' .. copy)
        end
    end

    --- Edit file
    local edit = function(preview)
        return function(state)
            require('neo-tree.sources.filesystem.commands').open(state)
            local node = state.tree:get_node()
            if node.type == 'file' then
                if vim.fn.bufnr('#') > 0 then
                    -- No idea why the opened buffer may be unlisted(nvim-tree doesnt' have this issue)
                    -- Switch buffer twice to make the opened buffer detected by popc
                    local codes = vim.api.nvim_replace_termcodes('<C-^>', true, true, true)
                    vim.cmd.normal({ args = { codes }, bang = true })
                    vim.cmd.normal({ args = { codes }, bang = true })
                end
                if preview then
                    vim.cmd.wincmd('p')
                end
            end
        end
    end

    require('neo-tree').setup({
        sources = { 'filesystem' },
        enable_diagnostics = false,
        enable_git_status = false,
        enable_modified_markers = false,
        enable_opened_markers = false,
        enable_refresh_on_write = false,
        log_to_file = false,
        use_default_mappings = false,
        default_component_configs = {
            file_size = { enabled = false },
            type = { enabled = false },
            last_modified = { enabled = false },
            created = { enabled = false },
            symlink_target = { enabled = true },
        },
        commands = {
            edit = edit(false),
            edit_preview = edit(true),
            first_sibling = first_sibling,
            last_sibling = last_sibling,
            open_system = open_system,
            yank_absolute_path = copy_filepath(':p'),
            yank_filename = copy_filepath(':t'),
        },
        window = {
            width = 30,
            mappings = {
                ['<CR>'] = 'edit',
                ['<2-LeftMouse>'] = 'edit',
                ['o'] = 'edit',
                ['go'] = 'edit_preview',
                ['<Tab>'] = 'open_with_window_picker',
                ['i'] = 'open_vsplit',
                ['gi'] = 'open_split',
                ['t'] = 'open_tabnew',
                ['p'] = { 'toggle_preview', config = { use_float = true } },
                ['J'] = last_sibling,
                ['K'] = first_sibling,
                ['r'] = 'refresh',
                ['H'] = 'close_node',
                ['Z'] = 'close_all_subnodes',
                ['q'] = 'close_window',
                ['M'] = 'toggle_auto_expand_width',
                ['?'] = 'show_help',
                ['<Esc>'] = 'cancel',
            },
        },
        filesystem = {
            window = {
                mappings = {
                    ['.'] = 'toggle_hidden',
                    ['u'] = 'navigate_up',
                    ['cd'] = 'set_root',
                    ['m'] = 'show_file_details',
                    ['dn'] = { 'order_by_name', nowait = false },
                    ['dt'] = { 'order_by_type', nowait = false },
                    ['O'] = 'open_system',
                    ['y'] = 'yank_filename',
                    ['Y'] = 'yank_absolute_path',
                    ['a'] = { 'add', config = { show_path = 'absolute' } },
                    ['A'] = 'add_directory',
                    ['D'] = 'delete',
                    ['R'] = 'rename',
                    ['X'] = 'cut_to_clipboard',
                    ['C'] = 'copy_to_clipboard',
                    ['P'] = 'paste_from_clipboard',
                    ['L'] = 'fuzzy_finder',
                },
                fuzzy_finder_mappings = {
                    ['<M-j>'] = 'move_cursor_down',
                    ['<M-k>'] = 'move_cursor_up',
                },
            },
            bind_to_cwd = false,
            use_libuv_file_watcher = false,
        },
    })
    m.nnore({ '<leader>tt', ':Neotree toggle<CR>' })
    m.nnore({ '<leader>tT', ':Neotree left reveal_force_cwd<CR>' })
end

-- 模糊查找
local function pkg_telescope()
    local telescope = require('telescope')
    local builtin = require('telescope.builtin')
    telescope.setup({
        defaults = {
            borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
            color_devicons = true,
            history = { path = vim.env.DotVimLocal .. '/telescope_history' },
            mappings = {
                i = {
                    ['<Esc>'] = 'close',
                    ['<Tab>'] = { '<Esc>', type = 'command' },
                    ['<M-i>'] = 'toggle_selection',
                    ['<M-j>'] = 'move_selection_next',
                    ['<M-k>'] = 'move_selection_previous',
                    ['<M-n>'] = 'results_scrolling_down',
                    ['<M-m>'] = 'results_scrolling_up',
                    ['<M-h>'] = 'results_scrolling_left',
                    ['<M-l>'] = 'results_scrolling_right',
                    ['<M-f>'] = 'preview_scrolling_down',
                    ['<M-d>'] = 'preview_scrolling_up',
                    ['<M-s>'] = 'preview_scrolling_left',
                    ['<M-g>'] = 'preview_scrolling_right',
                },
            },
        },
        extensions = {
            fzf = {
                override_generic_sorter = true,
                override_file_sorter = true,
            },
            frecency = {
                db_root = vim.env.DotVimLocal,
                db_safe_mode = false, -- `true` will break vim.ui.select
                auto_validate = true,
                sorter = require('telescope.config').values.file_sorter(),
            },
        },
    })
    telescope.load_extension('fzf')
    telescope.load_extension('frecency')
    m.nnore({ '<leader><leader>f', ':Telescope<Space>' })
    m.nnore({
        '<leader>lf',
        function()
            builtin.find_files({
                cwd = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
                hidden = true,
            })
        end,
    })
    m.nnore({
        '<leader>lg',
        function()
            local bufname = vim.api.nvim_buf_get_name(0)
            builtin.grep_string({
                cwd = vim.fs.dirname(bufname),
                search = '',
                search_dirs = { bufname },
            })
        end,
    })
    m.nnore({ '<leader>lr', ':Telescope frecency<CR>' })
end

-- 模糊查找
local function pkg_fzf()
    vim.g.fzf_command_prefix = 'Fzf'
    vim.g.fzf_layout = { down = '40%' }
    vim.g.fzf_preview_window = { 'right:40%,border-sharp' }
    vim.env.FZF_DEFAULT_OPTS = '--bind alt-j:down,alt-k:up,esc:abort'
    vim.api.nvim_create_autocmd('Filetype', {
        group = 'v.Pkgs',
        pattern = { 'fzf' },
        command = 'tnoremap <buffer> <Esc> <C-c>',
    })
end

-- 模糊查找
-- 若使用Miniconda3，需要修改install.bat：
--  * comment 'py -2 ...'
--  * 'py -3 ...' => 'python ...'
local function pkg_leaderf()
    vim.g.Lf_CacheDirectory = vim.env.DotVimLocal
    vim.g.Lf_PreviewInPopup = 1
    vim.g.Lf_PreviewResult = { File = 0, Buffer = 0, Tag = 0, Rg = 0 }
    vim.g.Lf_StlSeparator = use.ui.icon and { left = '', right = '' } or { left = '', right = '' }
    vim.g.Lf_ShowDevIcons = 0
    vim.g.Lf_ShortcutF = ''
    vim.g.Lf_ShortcutB = ''
    vim.g.Lf_ReverseOrder = 1
    vim.g.Lf_ShowHidden = 1
    vim.g.Lf_DefaultExternalTool = 'rg'
    vim.g.Lf_UseVersionControlTool = 1
    vim.g.Lf_WildIgnore = { dir = { '.git', '.svn', '.hg' }, file = {} }
    vim.g.Lf_MruEnable = 0
    vim.g.Lf_GtagsAutoGenerate = 0
    vim.g.Lf_GtagsAutoUpdate = 0
    m.nnore({ '<leader>li', ':LeaderfFile<CR>' })
    m.nnore({ '<leader>lu', ':LeaderfFunction<CR>' })
    m.nnore({ '<leader>ll', ':LeaderfLine<CR>' })
end

-- Mini插件库
local function pkg_mini()
    require('mini.align').setup({
        mappings = {
            start = '',
            start_with_preview = 'ga',
        },
    })
end

--------------------------------------------------------------------------------
-- Coding
--------------------------------------------------------------------------------
-- 语法树
local function pkg_treesitter()
    if vim.fn.empty(use.xgit) == 0 then
        for _, c in pairs(require('nvim-treesitter.parsers').get_parser_configs()) do
            c.install_info.url = c.install_info.url:gsub('https://github.com', use.xgit)
        end
    end
    local parser_dir = vim.env.DotVimLocal .. '/.treesitter'
    require('nvim-treesitter.configs').setup({
        parser_install_dir = parser_dir,
        --neovim's builtin: { 'bash', 'c', 'vim', 'lua', 'python', 'markdown', 'markdown_inline' },
        --ensure_installed = { 'cpp', 'rust', 'cmake', 'glsl', 'hlsl', 'wgsl', 'json', 'jsonc' },
        --auto_install = true,
        highlight = {
            enable = true,
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
                scope_incremental = '<M-q>',
            },
        },
        matchup = { enable = true },
    })
    vim.opt.runtimepath:prepend(parser_dir)
    m.nnore({
        '<leader>sh',
        function()
            vim.cmd.TSBufToggle('highlight')
            local buf = vim.api.nvim_get_current_buf()
            local res = require('vim.treesitter.highlighter').active[buf]
            vim.notify('Treesitter highlight is ' .. (res and 'enabled' or 'disabled'))
        end,
    })
    m.nnore({
        '<leader>si',
        function()
            vim.cmd.TSBufToggle('indent')
            local res = vim.bo.indentexpr == 'nvim_treesitter#indent()'
            vim.notify('Treesitter indent is ' .. (res and 'enabled' or 'disabled'))
        end,
    })
end

-- 代码片段
local function pkg_snip()
    vim.cmd([[
function! PkgLoadSnip(filename)
    return join(readfile($DotVimShare . '/' . a:filename), "\n")
endfunction
    ]])

    local snip = require('luasnip')
    local s = snip.snippet
    local i = snip.insert_node
    local f = snip.function_node
    snip.add_snippets('all', {
        s({ trig = 'cb([~#*-_=])', dscr = 'comment box', regTrig = true }, {
            i(1, 'cmt'),
            f(function(args, parent)
                local size = 80 - 1 - vim.api.nvim_win_get_cursor(0)[2]
                local line = string.rep(parent.captures[1], size)
                local head = args[1][1]
                return { line, head, head .. line }
            end, { 1 }),
        }),
    })
    require('luasnip.loaders.from_snipmate').lazy_load({
        paths = {
            vim.env.DotVimShare .. '/snippets',
            vim.env.DotVimDir .. '/bundle/vim-snippets/snippets',
        },
    })
    m.inore({
        '<Tab>',
        function() return snip.expandable() and '<Plug>luasnip-expand-snippet' or '<Tab>' end,
        expr = true,
    })
    m.inore({ '<M-l>', function() snip.jump(1) end })
    m.snore({ '<M-l>', function() snip.jump(1) end })
    m.inore({ '<M-h>', function() snip.jump(-1) end })
    m.snore({ '<M-h>', function() snip.jump(-1) end })
end

-- 代码格式化
local function pkg_conform()
    local conform = require('conform')
    conform.setup({
        formatters_by_ft = {
            lua = { 'stylua' },
            c = { 'clang_format' },
            cpp = { 'clang_format' },
            rust = { 'rustfmt' },
            python = { 'ruff_format' },
            typst = { 'typstyle' },
        },
        default_format_opts = {
            lsp_format = 'fallback',
        },
    })
    m.nore({ '<leader>fo', conform.format })
end

-- 终端浮窗
local function pkg_floaterm()
    m.tnore({ '<C-l>', '<C-\\><C-n><C-w>' })
    m.tnore({ '<Esc>', '<C-\\><C-n>' })
    m.nnore({ '<leader>tz', ':FloatermToggle<CR>' })
    m.nnore({ '<leader><leader>z', ':FloatermNew --cwd=.<Space>' })
    m.tnore({ '<M-u>', '<C-\\><C-n>:FloatermFirst<CR>' })
    m.tnore({ '<M-i>', '<C-\\><C-n>:FloatermPrev<CR>' })
    m.tnore({ '<M-o>', '<C-\\><C-n>:FloatermNext<CR>' })
    m.tnore({ '<M-p>', '<C-\\><C-n>:FloatermLast<CR>' })
    m.tnore({ '<M-q>', '<C-\\><C-n>:FloatermKill<CR>' })
    m.tnore({ '<M-h>', '<C-\\><C-n>:FloatermHide<CR>' })
    m.tnore({ '<M-n>', '<C-\\><C-n>:FloatermUpdate --height=0.6 --width=0.6<CR>' })
    m.tnore({ '<M-m>', '<C-\\><C-n>:FloatermUpdate --height=0.9 --width=0.9<CR>' })
    m.tnore({ '<M-r>', '<C-\\><C-n>:FloatermUpdate --position=topright<CR>' })
    m.tnore({ '<M-c>', '<C-\\><C-n>:FloatermUpdate --position=center<CR>' })
    m.nnore({ '<leader>mz', ':FloatermNew --cwd=. zsh<CR>' })
    m.nnore({ '<leader>mf', ':FloatermNew --cwd=. fzf --cycle<CR>' })
    m.nnore({ '<leader>mg', ':FloatermNew --cwd=. lazygit<CR>' })
    m.nnore({ '<leader>ml', ':FloatermNew --cwd=. lf<CR>' })
end

-- 代码注释
local function pkg_comment()
    require('Comment').setup({
        toggler = { line = 'gcc', block = 'gbc' },
        opleader = { line = 'gc', block = 'gb' },
        mappings = {
            basic = true,
            extra = false,
            extended = false,
        },
    })
    local comment = require('Comment.api')
    m.nnore({ '<leader>ci', function() comment.toggle.linewise.count(vim.v.count1) end })
    m.nnore({ '<leader>cl', function() comment.comment.linewise.count(vim.v.count1) end })
    m.nnore({
        '<leader>cu',
        function()
            -- ignore errors when uncommenting a non-commented line
            pcall(function() comment.uncomment.linewise.count(vim.v.count1) end)
        end,
    })
end

-- 自动括号
local function pkg_autopairs()
    require('nvim-autopairs').setup({
        map_cr = false,
    })
    m.nnore({
        '<leader>tp',
        function()
            local ap = require('nvim-autopairs').state.disabled
            vim.notify(string.format('Auto pairs: %s', ap))
            require('nvim-autopairs').state.disabled = not ap
        end,
    })
end

-- 添加包围符
local function pkg_surround()
    require('nvim-surround').setup({
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
    })
    m.nmap({ '<leader>sw', 'ysiw' })
    m.nmap({ '<leader>sW', 'ySiw' })
end

-- 快速高亮
local function pkg_quickhl()
    m.map({ '<leader>hw', '<Plug>(quickhl-manual-this)' })
    m.map({ '<leader>hs', '<Plug>(quickhl-manual-this-whole-word)' })
    m.map({ '<leader>hc', '<Plug>(quickhl-manual-clear)' })
    m.nmap({ '<leader>hr', '<Plug>(quickhl-manual-reset)' })
    m.nmap({ '<leader>th', '<Plug>(quickhl-manual-toggle)' })
end

-- 彩虹括号
local function pkg_rainbow()
    local rainbow = require('rainbow-delimiters')
    vim.g.rainbow_delimiters = {
        log = { level = vim.log.levels.OFF },
    }
    m.nnore({ '<leader>tr', function() rainbow.toggle(0) end })
end

-- 高亮缩进块
local function pkg_hlchunk()
    require('hlchunk').setup({
        chunk = {
            enable = true,
            notify = false,
            use_treesitter = use.nts,
            style = {
                { fg = '#fe8019' }, -- Normal chunk
                { fg = '#c21f30' }, -- Wrong chunk
            },
        },
        indent = {
            enable = true,
            chars = { '⁞' },
            style = { 'Gray30' },
            exclude_filetypes = { Popc = true, screensaver = true },
        },
        line_num = { enable = false },
        blank = { enable = false },
    })
end

--------------------------------------------------------------------------------
-- Misc
--------------------------------------------------------------------------------
-- Markdown
local function pkg_markview()
    require('markview').setup({
        modes = { 'n', 'no' },
    })
    m.nore({ '<leader>tm', ':Markview toggle<CR>' })
end

-- Markdown
local function pkg_peek()
    -- Dependency: sudo pacman -S webkit2gtk
    local peek = require('peek')
    peek.setup({
        auto_load = false,
        syntax = true,
        theme = 'light',
        app = 'webview', -- 'firefox',
    })
    m.nnore({
        '<leader>vm',
        function()
            local s
            if peek.is_open() then
                s = 'disabled'
                peek.close()
            else
                s = 'enabled'
                peek.open()
            end
            vim.sysnotify('Markdown preview is ' .. s, vim.log.levels.INFO)
        end,
    })
end

-- Typst
local function pkg_typst()
    local typst = require('typst-preview')
    typst.setup({
        dependencies_bin = {
            tinymist = IsWin() and 'tinymist.cmd' or 'tinymist',
            websocat = nil,
        },
    })
    m.nnore({ '<leader>vt', ':TypstPreviewToggle<CR>' })
end

-- Latex
local function pkg_tex()
    vim.g.vimtex_cache_root = vim.env.DotVimLocal .. '/.vimtex'
    vim.g.vimtex_view_general_viewer = 'sioyek'
    vim.g.vimtex_complete_enabled = 1 -- 使用vimtex#complete#omnifunc补全
    vim.g.vimtex_complete_close_braces = 1
    vim.g.vimtex_compiler_method = 'latexmk'
    m.nmap({ '<leader>va', '<Plug>(vimtex-view)' })
    m.nmap({ '<leader>ab', '<Plug>(vimtex-compile-ss)' })
    m.nmap({ '<leader>aB', '<Plug>(vimtex-compile)' })
    m.nmap({ '<leader>ak', '<Plug>(vimtex-stop)' })
    m.nmap({ '<leader>aK', '<Plug>(vimtex-stop-all)' })
end

-- 颜色预览
local function pkg_ccc()
    m.nnore({ '<leader>tc', ':CccHighlighterToggle<CR>' })
    m.nnore({ '<leader>lp', ':CccPick<CR>' })
    local ccc = require('ccc')
    ccc.setup({
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
    })
end

-- 字体图标选择器
local function pkg_icon_picker()
    require('icon-picker').setup({
        disable_legacy_commands = true,
    })
    m.inore({ '<M-w>', '<Cmd>IconPickerInsert alt_font emoji html_colors nerd_font_v3 symbols<CR>' })
    m.nnore({ '<leader><leader>i', ':IconPickerInsert<Space>' })
end

-- 翻译
local function pkg_translator()
    vim.g.translator_default_engines = { 'haici', 'bing', 'youdao' }
    m.nmap({ '<leader>tw', '<Plug>TranslateW' })
    m.vmap({ '<leader>tw', '<Plug>TranslateWV' })
    m.nnore({ '<leader><leader>t', ':TranslateW<Space>' })
    m.vnore({
        '<leader><leader>t',
        function() vim.api.nvim_feedkeys(':TranslateW ' .. nlib.get_selected(' '), 'n', true) end,
    })
end

--------------------------------------------------------------------------------
-- Lazy
--------------------------------------------------------------------------------
local pkgs = {
    -- Editor
    { 'andymass/vim-matchup', config = pkg_matchup },
    { 'yehuohan/hop.nvim', config = pkg_hop },
    { 'mg979/vim-visual-multi', init = pkg_visual_multi },
    { 'junegunn/vim-easy-align', config = pkg_easy_align },
    { 'yehuohan/marks.nvim', config = pkg_marks },
    { 'xiyaowong/nvim-cursorword', config = pkg_cursorword },
    { 'booperlv/nvim-gomove', config = pkg_gomove },
    { 's1n7ax/nvim-window-picker', config = pkg_window_picker },
    { 'sindrets/winshift.nvim', config = pkg_winshift, keys = { '<leader>wm' } },
    { 'terryma/vim-expand-region', config = pkg_expand_region },
    { 'stevearc/dressing.nvim', opts = {} },
    { 'lukas-reineke/virt-column.nvim', opts = { char = '┊' } },

    -- Component
    { 'ellisonleao/gruvbox.nvim', config = pkg_gruvbox },
    { 'polirritmico/monokai-nightasty.nvim' },
    { 'nvim-tree/nvim-web-devicons', lazy = true, enabled = use.ui.icon },
    { -- heirline
        'rebelot/heirline.nvim',
        config = require('v.pkgs.nstl').setup,
        dependencies = { 'yehuohan/popc', 'linrongbin16/lsp-progress.nvim' },
    },
    { 'goolord/alpha-nvim', config = pkg_alpha },
    { 'rcarriga/nvim-notify', config = pkg_notify },
    { 'ObserverOfTime/notifications.nvim', config = pkg_notifications },
    { 'kevinhwang91/nvim-ufo', config = pkg_ufo, dependencies = { 'kevinhwang91/promise-async' } },
    { 'kevinhwang91/nvim-bqf', config = pkg_bqf, ft = 'qf' },
    { 'yehuohan/popc', init = pkg_popc },
    { 'yehuohan/popset', dependencies = { 'yehuohan/popc' } },
    { 'yehuohan/popc-floaterm', dependencies = { 'yehuohan/popc' } },
    { -- neo-tree
        'nvim-neo-tree/neo-tree.nvim',
        config = pkg_neotree,
        dependencies = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim' },
        keys = { '<leader>tt', '<leader>tT' },
    },
    { -- telescope
        'nvim-telescope/telescope.nvim',
        config = pkg_telescope,
        keys = { '<leader><leader>f', '<leader>lf', '<leader>lg', '<leader>lr' },
    },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'nvim-telescope/telescope-frecency.nvim' },
    { 'junegunn/fzf.vim', init = pkg_fzf, dependencies = { 'junegunn/fzf' } },
    { 'Yggdroot/LeaderF', enabled = use.has_py, init = pkg_leaderf, build = ':LeaderfInstallCExtension' },
    { 'echasnovski/mini.nvim', config = pkg_mini },

    -- Coding
    { -- cmp
        'hrsh7th/nvim-cmp',
        enabled = use.nlsp,
        config = require('v.pkgs.nlsp').setup,
        event = { 'InsertEnter' },
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'neovim/nvim-lspconfig',
            'folke/neoconf.nvim',
            { 'folke/lazydev.nvim', ft = 'lua' },
            'nvimdev/lspsaga.nvim',
            'ray-x/lsp_signature.nvim',
            -- { 'mrcjkb/rustaceanvim', ft = { 'rust' } },
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-calc',
            'yehuohan/cmp-cmdline',
            'yehuohan/cmp-path',
            'yehuohan/cmp-im',
            'yehuohan/cmp-im-zh',
            'saadparwaiz1/cmp_luasnip',
            'dmitmel/cmp-cmdline-history',
            'kdheepak/cmp-latex-symbols',
            'f3fora/cmp-spell',
            'zjp-CN/nvim-cmp-lsp-rs',
            'nvim-lua/plenary.nvim',
        },
    },
    { 'nvim-treesitter/nvim-treesitter', enabled = use.nts, version = '*', config = pkg_treesitter },
    { 'rcarriga/nvim-dap-ui', enabled = use.ndap, dependencies = { 'mfussenegger/nvim-dap' } },
    { 'L3MON4D3/LuaSnip', config = pkg_snip, dependencies = { 'honza/vim-snippets' } },
    { 'stevearc/overseer.nvim' }, -- Setup from v.task
    { 'kmontocam/nvim-conda', ft = 'python', dependencies = { 'nvim-lua/plenary.nvim' } },
    { 'stevearc/conform.nvim', config = pkg_conform },
    { 'voldikss/vim-floaterm', config = pkg_floaterm },
    { 'numToStr/Comment.nvim', config = pkg_comment },
    { 'windwp/nvim-autopairs', config = pkg_autopairs },
    { 'kylechui/nvim-surround', config = pkg_surround },
    { 't9md/vim-quickhl', config = pkg_quickhl },
    { 'HiPhish/rainbow-delimiters.nvim', init = pkg_rainbow, submodules = false },
    { 'shellRaining/hlchunk.nvim', config = pkg_hlchunk },
    { 'rust-lang/rust.vim' },
    { 'NoahTheDuke/vim-just', ft = 'just' },

    -- Misc
    { -- makrview
        'OXY2DEV/markview.nvim',
        config = pkg_markview,
        ft = 'markdown',
        submodules = false,
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    },
    { 'toppair/peek.nvim', config = pkg_peek, ft = 'markdown', build = 'deno task build:fast' },
    { 'chomosuke/typst-preview.nvim', config = pkg_typst, ft = 'typst' },
    { 'lervag/vimtex', config = pkg_tex, ft = 'tex' },
    { 'uga-rosa/ccc.nvim', config = pkg_ccc, keys = { '<leader>tc', '<leader>lp' } },
    { 'ziontee113/icon-picker.nvim', config = pkg_icon_picker, keys = { { '<M-w>', mode = 'i' } } },
    { 'itchyny/screensaver.vim', keys = { { '<leader>ss', '<Cmd>ScreenSaver clock<CR>' } } },
    { 'voldikss/vim-translator', config = pkg_translator },
    { 'keaising/im-select.nvim', opts = { set_default_events = { 'InsertLeave' } } },
}

local function clone_lazy(url, bundle)
    local lazygit = bundle .. '/lazy.nvim'
    if not vim.uv.fs_stat(lazygit) then
        vim.api.nvim_echo({ { 'Clone lazy.nvim ...', 'WarningMsg' } }, false, {})
        vim.fn.system({
            'git',
            'clone',
            '--filter=blob:none',
            url .. '/folke/lazy.nvim.git',
            '--branch=stable',
            lazygit,
        })
    end
    vim.opt.runtimepath:prepend(lazygit)
end

local function pkg_lazy()
    local url = 'https://github.com'
    if vim.fn.empty(use.xgit) == 0 then
        url = use.xgit
    end
    local bundle = vim.env.DotVimDir .. '/bundle'
    clone_lazy(url, bundle)

    vim.api.nvim_create_augroup('v.Pkgs', { clear = true })

    vim.g.loaded_gzip = 1
    vim.g.loaded_tarPlugin = 1
    vim.g.loaded_tar = 1
    vim.g.loaded_zipPlugin = 1
    vim.g.loaded_zip = 1
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.g.loaded_matchit = 1
    vim.g.loaded_matchparen = 1
    require('lazy').setup(pkgs, {
        root = bundle,
        defaults = { lazy = false },
        lockfile = vim.env.DotVimLocal .. '/lazy/lazy-lock.json',
        git = { url_format = url .. '/%s.git' },
        install = { missing = false },
        readme = { root = vim.env.DotVimLocal .. '/lazy/readme' },
        performance = { rtp = { reset = false, paths = { vim.env.DotVimInit } } },
        state = vim.env.DotVimLocal .. '/lazy/state.json',
    })

    vim.api.nvim_create_autocmd('ColorScheme', {
        group = 'v.Pkgs',
        callback = function()
            vim.api.nvim_set_hl(0, 'HopPreview', { fg = '#b8bb26', bold = true, ctermfg = 142 })
            vim.api.nvim_set_hl(0, 'CursorWord', { bg = '#505060', ctermbg = 60 })
            vim.api.nvim_set_hl(0, 'FloatermBorder', { link = 'Constant' })
            vim.api.nvim_set_hl(0, 'TranslatorBorder', { link = 'Constant' })
        end,
    })

    local ok = pcall(function()
        vim.o.background = 'dark'
        vim.cmd.colorscheme('gruvbox')
    end)
    if not ok then
        vim.cmd.colorscheme('default')
    end
end

return { setup = pkg_lazy }
