local use = require('v.use')
local nlib = require('v.nlib')
local m = nlib.m

--------------------------------------------------------------------------------
-- Editor
--------------------------------------------------------------------------------
-- 匹配符跳转
local function pkg_matchup()
    -- packadd matchit
    vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    m.nxmap({ 'M', '%' })
end

-- 快速高亮
local function pkg_quickhl()
    m.nxmap({ '<leader>hw', '<Plug>(quickhl-manual-this)' })
    m.nxmap({ '<leader>hs', '<Plug>(quickhl-manual-this-whole-word)' })
    m.nxmap({ '<leader>hc', '<Plug>(quickhl-manual-clear)' })
    m.nmap({ '<leader>hr', '<Plug>(quickhl-manual-reset)' })
    m.nmap({ '<leader>th', '<Plug>(quickhl-manual-toggle)' })
end

-- 彩虹括号
local function pkg_rainbow()
    local rainbow = require('rainbow-delimiters')
    vim.g.rainbow_delimiters = { log = { level = vim.log.levels.OFF } }
    m.nnore({ '<leader>tr', function() rainbow.toggle(0) end, desc = 'Toggle rainbow' })
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
                    tpl.file_button(vim.fn.stdpath('config') .. '/init.lua', 'd'),
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

-- 主题
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
            vim.fn.setreg('0', copy)
            vim.fn.setreg('+', copy)
            vim.notify('Copied: ' .. copy)
        end
    end

    --- Edit file
    local edit = function(preview)
        return function(state)
            require('neo-tree.sources.filesystem.commands').open(state)
            local node = state.tree:get_node()
            if preview and node.type == 'file' then
                vim.cmd.wincmd('p')
            end
        end
    end

    require('neo-tree').setup({
        sources = { 'filesystem' },
        enable_git_status = use.has_git,
        use_popups_for_input = false,
        use_default_mappings = false,
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
                ['i'] = 'open_vsplit',
                ['gi'] = 'open_split',
                ['t'] = 'open_tabnew',
                ['p'] = { 'toggle_preview', config = { use_float = true } },
                ['J'] = 'last_sibling',
                ['K'] = 'first_sibling',
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
            filtered_items = { hide_gitignored = use.has_git },
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

-- Buffer,Bookmarks,Workspace管理
local function pkg_popc()
    vim.g.Popc_enableLog = 1
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
    vim.g.Popc_bufIgnoredType = { 'Popc', 'qf', 'sagaoutline' }
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
end

-- Mini插件库
local function pkg_mini()
    -- 自动对齐
    require('mini.align').setup({ mappings = { start = '', start_with_preview = 'ga' } })
    m.nmap({ '<leader>al', 'gaip' })
    m.xmap({ '<leader>al', 'ga' })

    -- 代码注释
    require('mini.comment').setup()
    m.nmap({ '<leader>cl', 'gcc' })
    m.nmap({ '<leader>cu', 'gcc' })

    -- 高亮Word
    vim.api.nvim_create_autocmd('CursorMoved', {
        group = 'v.Pkgs',
        callback = function()
            vim.b.minicursorword_disable = vim.tbl_contains({
                'Popc',
                'neo-tree',
            }, vim.bo.filetype)
        end,
    })
    require('mini.cursorword').setup({ delay = 10 })

    -- 显示缩进
    require('mini.indentscope').setup({ symbol = '┋' })

    -- 移动选区
    require('mini.move').setup({
        mappings = {
            left = '<C-h>',
            right = '<C-l>',
            down = '<C-j>',
            up = '<C-k>',
            line_left = '',
            line_right = '',
            line_down = '',
            line_up = '',
        },
    })

    -- 自动括号
    require('mini.pairs').setup()

    -- 添加包围符
    require('mini.surround').setup({
        mappings = {
            add = 'ys',
            delete = 'ds',
            replace = 'cs',
            find = '',
            find_left = '',
            highlight = '',
            update_n_lines = '',
            suffix_last = '',
            suffix_next = '',
        },
    })
    m.nmap({ '<leader>sw', 'ysiw' })
    m.xmap({ 'vs', [[:<C-u>lua MiniSurround.add('visual')<CR>]], silent = true })
    m.xdel({ 'ys' })
end

-- Snacks插件库
local function pkg_snacks()
    require('snacks').setup({
        -- 显示缩进
        indent = {
            indent = { char = '┊' },
            scope = { enabled = false, char = '┋' },
        },
        -- 扩展vim.notify
        notifier = {
            margin = { bottom = 1 },
            top_down = false,
        },
        -- 扩展vim.ui.input
        input = {},
        -- 扩展vim.ui.select
        picker = {
            layout = { preset = 'telescope' },
            db = { sqlite3_path = IsWin() and vim.env.DotVimShare .. '/lib/sqlite3.dll' or nil },
            win = {
                input = {
                    keys = {
                        ['<CR>'] = { 'confirm', mode = { 'n', 'i' } },
                        ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
                        ['<Tab>'] = { '<Esc>', mode = { 'i' }, expr = true },
                        ['<M-n>'] = { 'history_forward', mode = { 'i' } },
                        ['<M-m>'] = { 'history_back', mode = { 'i' } },
                        ['<M-j>'] = { 'list_down', mode = { 'i' } },
                        ['<M-k>'] = { 'list_up', mode = { 'i' } },
                        ['<M-d>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
                        ['<M-f>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
                        ['<M-p>'] = { 'toggle_preview', mode = { 'i', 'n' } },
                    },
                },
            },
        },
        styles = {
            input = {
                width = 30,
                relative = 'cursor',
                b = { completion = use.pkgs.blink },
            },
        },
    })
    m.nnore({ '<leader>dm', require('snacks').notifier.hide, desc = 'Hide all notifications' })
    m.nnore({ '<leader>vn', require('snacks').notifier.show_history, desc = 'Show all notifications' })
end

--------------------------------------------------------------------------------
-- Coding
--------------------------------------------------------------------------------
-- 模糊查找
local function pkg_telescope()
    local telescope = require('telescope')
    local builtin = require('telescope.builtin')
    telescope.setup({
        defaults = {
            color_devicons = true,
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
        pickers = {
            keymaps = { modes = { 'n', 'i', 'c', 'x', 's', 'v', 't', 'l', 'o' } },
        },
        extensions = {
            fzf = {
                override_generic_sorter = true,
                override_file_sorter = true,
            },
            frecency = {
                db_safe_mode = false, -- `true` will break vim.ui.select
                auto_validate = true,
                sorter = require('telescope.config').values.file_sorter(),
            },
        },
    })
    telescope.load_extension('fzf')
    telescope.load_extension('frecency')
    telescope.load_extension('nerdy')
    m.nnore({ '<leader><leader>f', ':Telescope<Space>' })
    m.nnore({
        '<leader>lf',
        function()
            local bufname = vim.api.nvim_buf_get_name(0)
            builtin.find_files({ cwd = vim.fs.dirname(bufname), hidden = true })
        end,
        desc = 'Telescope files',
    })
    m.nnore({
        '<leader>lg',
        function()
            local bufname = vim.api.nvim_buf_get_name(0)
            builtin.grep_string({ cwd = vim.fs.dirname(bufname), search = '', search_dirs = { bufname } })
        end,
        desc = 'Telescope grep string',
    })
    m.nnore({ '<leader>lb', ':Telescope buffers<CR>' })
    m.nnore({ '<leader>ll', ':Telescope current_buffer_fuzzy_find<CR>' })
    m.nnore({ '<leader>lm', ':Telescope keymaps<CR>' })
    m.nnore({ '<leader>lr', ':Telescope frecency<CR>' })
    m.nnore({ '<leader>ln', ':Telescope nerdy<CR>' })
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
        desc = 'Expand snippet or <Tab>',
    })
    m.addnore({ 'i', 's' }, { '<M-l>', function() snip.jump(1) end, desc = 'Next snippet placeholder' })
    m.addnore({ 'i', 's' }, { '<M-h>', function() snip.jump(-1) end, desc = 'Prev snippet placeholder' })
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
    m.nxnore({ '<leader>fo', conform.format, desc = 'Format code' })
end

-- 快速跳转
local function pkg_hop()
    local hop = require('hop')
    hop.setup({ match_mappings = { 'noshift', 'zh', 'zh_sc' } })
    m.nxnore({ 's', '<Cmd>HopChar<CR>' })
    m.nxnore({ 'S', '<Cmd>HopWord<CR>' })
    m.addnore({ 'n', 'x', 'o' }, { 'f', '<Cmd>HopCharCL<CR>' })
    m.addnore({ 'n', 'x', 'o' }, { 'F', '<Cmd>HopAnywhereCL<CR>' })
    m.nxnore({ '<leader>j', '<Cmd>HopVertical<CR>' })
    m.nxnore({ '<leader>k', '<Cmd>HopLineStart<CR>' })
    m.nnore({
        '<leader>wi',
        function()
            hop.wrap({
                oneshot = true,
                match = function(_, wctx, lctx)
                    if require('hop.window').is_cursor_line(wctx, lctx) then
                        local jt = wctx.cursor
                        return { b = jt.col, e = jt.col, off = jt.off, virt = jt.virt }
                    end
                end,
            }, {
                keys = 'fdsjklaweriop',
                hint_upper = true,
                auto_jump_one_target = false,
                msg_no_targets = function() vim.notify('There’s only one window', vim.log.levels.ERROR) end,
            })
        end,
        desc = 'Pick window',
    })
end

-- 多光标编辑
local function pkg_multicursor()
    local mc = require('multicursor-nvim')
    mc.setup()
    m.nnore({ ',c', mc.toggleCursor, desc = 'Toggle cursor' })
    m.xnore({
        ',c',
        function()
            mc.action(function(ctx)
                ctx:forEachCursor(function(cur) cur:splitVisualLines() end)
            end)
            mc.feedkeys('<Esc>', { remap = false, keycodes = true })
        end,
        desc = 'Create cursors from visual',
    })
    m.nxnore({ ',v', function() mc.matchAddCursor(1) end, desc = 'Create cursors from word/selection' })
    m.xnore({ ',m', mc.matchCursors, desc = 'Match cursors from visual' })
    m.xnore({ ',s', mc.splitCursors, desc = 'Split cursors from visual' })
    m.nnore({ ',a', mc.alignCursors, desc = 'Align cursors' })
    mc.addKeymapLayer(function(lyr)
        local hop = require('hop')
        local move_mc = require('hop.jumper').move_multicursor
        lyr({ 'n', 'x' }, 's', function() hop.char({ jump = move_mc }) end)
        lyr({ 'n', 'x' }, 'S', function() hop.word({ jump = move_mc }) end)
        lyr({ 'n', 'x', 'o' }, 'f', 'f')
        lyr({ 'n', 'x', 'o' }, 'F', 'F')
        lyr({ 'n', 'x' }, '<leader>j', function() hop.vertical({ jump = move_mc }) end)
        lyr({ 'n', 'x' }, '<leader>k', function() hop.vertical({ jump = move_mc }) end)

        lyr({ 'n', 'x' }, 'n', function() mc.matchAddCursor(1) end)
        lyr({ 'n', 'x' }, 'N', function() mc.matchAddCursor(-1) end)
        lyr({ 'n', 'x' }, 'm', function() mc.matchSkipCursor(1) end)
        lyr({ 'n', 'x' }, 'M', function() mc.matchSkipCursor(-1) end)
        lyr('n', '<leader><Esc>', mc.disableCursors)
        lyr('n', '<Esc>', function()
            if mc.cursorsEnabled() then
                mc.clearCursors()
            else
                mc.enableCursors()
            end
        end)
    end)
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

--------------------------------------------------------------------------------
-- Misc
--------------------------------------------------------------------------------
-- Markdown
local function pkg_markview()
    require('markview').setup({
        preview = {
            modes = { 'n', 'no', 'c', 'v', 'V', '\22' },
        },
    })
    m.nnore({ '<leader>tm', ':Markview toggle<CR>' })
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
            local state = peek.is_open() and 'disabled' or 'enabled'
            if peek.is_open() then
                peek.close()
            else
                peek.open()
            end
            vim.notify('Markdown preview is ' .. state)
        end,
        desc = 'Visualize markdown',
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
    vim.g.vimtex_cache_root = vim.fn.stdpath('data') .. '/vimtex'
    vim.g.vimtex_view_general_viewer = 'sioyek'
    vim.g.vimtex_complete_enabled = 1 -- 使用vimtex#complete#omnifunc补全
    vim.g.vimtex_complete_close_braces = 1
    vim.g.vimtex_compiler_method = 'latexmk'
    m.nmap({ '<leader>va', '<Plug>(vimtex-view)' })
    m.nmap({ '<leader>ab', '<Plug>(vimtex-compile-ss)' })
    m.nmap({ '<leader>aB', '<Plug>(vimtex-compile)' })
    m.nmap({ '<leader>ak', '<Plug>(vimtex-stop-all)' })
end

-- 按键提示
local function pkg_which_key()
    local which_key = require('which-key')
    which_key.setup({
        preset = 'classic',
        keys = {
            scroll_down = '<M-j>',
            scroll_up = '<M-k>',
        },
        replace = {
            key = { function(key) return key end },
        },
        icons = {
            breadcrumb = '',
            separator = '󰁔',
        },
    })
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

-- 翻译
local function pkg_trans()
    -- https://github.com/skywind3000/ECDICT
    -- unzip stardict.7z
    -- generate ecdictSqlite.db from stardict.csv via del_bfz.py
    require('Trans').setup({
        dir = vim.env.DotVimLocal .. '/ecdict', -- ultimate.db
        theme = 'dracula',
        frontend = {
            default = {
                animation = {
                    open = false,
                    close = false,
                },
            },
        },
    })
    m.nxnore({ '<leader>tw', '<Cmd>Translate<CR>' })
    m.nnore({ '<leader><leader>t', '<Cmd>TranslateInput<CR>' })
end

-- 输入法切换
local function pkg_im_select()
    require('im_select').setup({
        set_default_events = { 'InsertLeave' },
        set_previous_events = { 'InsertEnter' },
        async_switch_im = true,
    })
end

--------------------------------------------------------------------------------
-- Lazy
--------------------------------------------------------------------------------
local pkgs = {
    -- Libraries
    { 'stevearc/profile.nvim', lazy = true },
    { 'nvim-tree/nvim-web-devicons', lazy = true, cond = use.ui.icon },
    { 'nvim-lua/plenary.nvim', lazy = true },
    { 'MunifTanjim/nui.nvim', lazy = true },
    { 'nvim-neotest/nvim-nio', lazy = true },
    { 'honza/vim-snippets' },
    {
        'kkharji/sqlite.lua',
        lazy = true,
        init = function()
            vim.g.sqlite_clib_path = IsWin() and vim.env.DotVimShare .. '/lib/sqlite3.dll' or nil
        end,
    },

    -- Editor
    { 'andymass/vim-matchup', config = pkg_matchup, event = 'VeryLazy' },
    { 't9md/vim-quickhl', config = pkg_quickhl, event = 'VeryLazy' },
    { 'HiPhish/rainbow-delimiters.nvim', config = pkg_rainbow, submodules = false, event = 'VeryLazy' },
    { 'lukas-reineke/virt-column.nvim', opts = { char = '┊' }, event = 'VeryLazy' },
    { 'goolord/alpha-nvim', config = pkg_alpha },
    { 'ellisonleao/gruvbox.nvim', config = pkg_gruvbox, event = 'VeryLazy' },
    { 'polirritmico/monokai-nightasty.nvim', event = 'VeryLazy' },
    { 'nvim-neo-tree/neo-tree.nvim', config = pkg_neotree, event = 'VeryLazy' },
    { 'yehuohan/popc', init = pkg_popc, event = 'VeryLazy' },
    { 'yehuohan/popset', dependencies = { 'yehuohan/popc' }, event = 'VeryLazy' },
    { 'echasnovski/mini.nvim', config = pkg_mini, event = 'VeryLazy' },
    { 'folke/snacks.nvim', config = pkg_snacks, event = 'VeryLazy' },

    -- Coding
    require('v.pkgs.nstl'),
    require('v.pkgs.ndap'),
    require('v.pkgs.nlsp'),
    require('v.pkgs.nts'),
    { 'stevearc/overseer.nvim' }, -- Setup from v.task
    { 'nvim-telescope/telescope.nvim', config = pkg_telescope, event = 'VeryLazy' },
    { 'nvim-telescope/telescope-fzf-native.nvim', lazy = true, build = use.has_build and 'make' },
    { 'nvim-telescope/telescope-frecency.nvim', lazy = true },
    { '2kabhishek/nerdy.nvim', lazy = true },
    { 'junegunn/fzf.vim', init = pkg_fzf, dependencies = { 'junegunn/fzf' }, event = 'VeryLazy' },
    { 'L3MON4D3/LuaSnip', config = pkg_snip, event = 'VeryLazy', submodules = false },
    { 'stevearc/conform.nvim', config = pkg_conform, event = 'VeryLazy' },
    { 'yehuohan/hop.nvim', config = pkg_hop, event = 'VeryLazy' },
    { 'jake-stewart/multicursor.nvim', config = pkg_multicursor, event = 'VeryLazy' },
    { 'yehuohan/marks.nvim', config = pkg_marks, event = 'VeryLazy' },
    { 'kmontocam/nvim-conda', ft = 'python' },
    { 'rust-lang/rust.vim', event = 'VeryLazy' },
    { 'NoahTheDuke/vim-just', ft = 'just' },

    -- Misc
    { 'OXY2DEV/markview.nvim', config = pkg_markview, ft = 'markdown', submodules = false },
    { 'toppair/peek.nvim', config = pkg_peek, ft = 'markdown', build = 'deno task build:fast' },
    { 'chomosuke/typst-preview.nvim', config = pkg_typst, ft = 'typst' },
    { 'lervag/vimtex', config = pkg_tex, ft = 'tex' },
    { 'folke/which-key.nvim', cond = use.pkgs.which_key, config = pkg_which_key, event = 'VeryLazy' },
    { 'uga-rosa/ccc.nvim', config = pkg_ccc, event = 'VeryLazy' },
    { 'itchyny/screensaver.vim', keys = { { '<leader>ss', '<Cmd>ScreenSaver clock<CR>' } } },
    { 'JuanZoran/Trans.nvim', config = pkg_trans, event = 'VeryLazy' },
    { 'keaising/im-select.nvim', cond = use.pkgs.im_select, config = pkg_im_select, event = 'VeryLazy' },
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
        git = { url_format = url .. '/%s.git' },
        install = { missing = false },
        readme = {
            root = vim.env.DotVimLocal .. '/lazy',
            files = { 'README.md', 'lua/**/README.md', 'cookbook.md' },
        },
        performance = {
            rtp = { reset = false, paths = { vim.env.DotVimInit } },
        },
    })

    vim.api.nvim_create_autocmd('ColorScheme', {
        group = 'v.Pkgs',
        callback = function()
            vim.api.nvim_set_hl(0, 'MiniCursorword', { bg = '#505060', ctermbg = 60 })
            vim.api.nvim_set_hl(0, 'MiniCursorwordCurrent', { link = 'MiniCursorword' })
            vim.api.nvim_set_hl(0, 'SnacksPicker', { bg = 'none', nocombine = true })
            vim.api.nvim_set_hl(0, 'SnacksPickerBorder', { bg = 'none', nocombine = true })
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
