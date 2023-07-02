local use = require('v.use')
local m = require('v.libv').m

--------------------------------------------------------------------------------
-- Editor
--------------------------------------------------------------------------------
-- 快速跳转
local function pkg_hop()
    require('hop').setup({
        match_mappings = { 'zh', 'zh_sc' },
        create_hl_autocmd = true,
    })
    m.nore({ 's', '<Cmd>HopChar1MW<CR>' })
    m.nore({ 'S', '<Cmd>HopChar1<CR>' })
    m.nore({ 'f', '<Cmd>HopChar1CurrentLine<CR>' })
    m.nore({ 'F', '<Cmd>HopAnywhereCurrentLine<CR>' })
    m.nore({ '<leader>ms', '<Cmd>HopPatternMW<CR>' })
    m.nore({ '<leader>j', '<Cmd>HopLineCursor<CR>' })
    m.nore({ '<leader><leader>j', '<Cmd>HopLine<CR>' })
    m.nore({ '<leader>mj', '<Cmd>HopLineStart<CR>' })
    m.nore({ '<leader>mw', '<Cmd>HopWord<CR>' })
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
    vim.g.cursorword_disable_filetypes = { 'nerdtree', 'NvimTree' }
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

-- 平滑滚动
local function pkg_cinnamon()
    require('cinnamon').setup({
        default_keymaps = false,
        extra_keymaps = false,
        extended_keymaps = false,
        centered = true,
        default_delay = 7,
        hide_cursor = false,
    })
    m.nnore({
        '<M-n>',
        function()
            if use.coc and vim.fn['coc#float#has_scroll']() == 1 then
                return vim.fn['coc#float#scroll'](1)
            else
                return [[<Cmd>lua Scroll('<C-d>', 1, 1)<CR>]]
            end
        end,
        expr = true,
    })
    m.nnore({
        '<M-m>',
        function()
            if use.coc and vim.fn['coc#float#has_scroll']() == 1 then
                return vim.fn['coc#float#scroll'](0)
            else
                return [[<Cmd>lua Scroll('<C-u>', 1, 1)<CR>]]
            end
        end,
        expr = true,
    })
    m.nnore({ '<M-j>', [[<Cmd>lua Scroll('<C-f>', 1, 1)<CR>]] })
    m.nnore({ '<M-k>', [[<Cmd>lua Scroll('<C-b>', 1, 1)<CR>]] })
end

-- 窗口跳转
local function pkg_winpick()
    local winpick = require('winpick')
    winpick.setup({
        border = 'none',
        prompt = 'Pick a window: ',
        format_label = winpick.defaults.format_label,
        chars = { 'f', 'j', 'd', 'k', 's', 'l' },
    })
    m.nnore({
        '<leader>wi',
        function()
            local winid, _ = winpick.select()
            if winid then
                vim.api.nvim_set_current_win(winid)
            end
        end,
    })
end

--------------------------------------------------------------------------------
-- Component
--------------------------------------------------------------------------------
-- 启动首页
local function pkg_alpha()
    local tpl = require('alpha.themes.startify')
    tpl.nvim_web_devicons.enabled = use.ui.patch
    tpl.section.header.val = function()
        if vim.fn.filereadable(vim.env.DotVimLocal .. '/todo.md') == 1 then
            local todo = vim.fn.filter(
                vim.fn.readfile(vim.env.DotVimLocal .. '/todo.md'),
                'v:val !~ "\\m^[ \t]*$"'
            )
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
                    tpl.file_button('$DotVimInit/lua/v/init.lua', 'c'),
                    tpl.file_button('$NVimConfigDir/init.vim', 'd'),
                    tpl.file_button('$DotVimLocal/todo.md', 'o'),
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
                val = function() return { tpl.mru(0, false, 8) } end,
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
        max_width = function() return vim.api.nvim_get_option('columns') * 0.7 end,
        minimum_width = 30,
        top_down = false,
    })
    vim.notify = require('notify')
    m.nnore({ '<leader>dm', function() vim.notify.dismiss() end })
end

-- 目录树导航
local function pkg_tree()
    require('nvim-tree').setup({
        on_attach = function(bufnr)
            local tapi = require('nvim-tree.api')
            -- stylua: ignore start
            m.nnore({'<CR>'         , tapi.node.open.edit             , buffer = bufnr, silent = true, nowait = true, desc = 'Open'                  })
            m.nnore({'o'            , tapi.node.open.edit             , buffer = bufnr, silent = true, nowait = true, desc = 'Open'                  })
            m.nnore({'<2-LeftMouse>', tapi.node.open.edit             , buffer = bufnr, silent = true, nowait = true, desc = 'Open'                  })
            m.nnore({'i'            , tapi.node.open.vertical         , buffer = bufnr, silent = true, nowait = true, desc = 'Open: Vertical Split'  })
            m.nnore({'gi'           , tapi.node.open.horizontal       , buffer = bufnr, silent = true, nowait = true, desc = 'Open: Horizontal Split'})
            m.nnore({'t'            , tapi.node.open.tab              , buffer = bufnr, silent = true, nowait = true, desc = 'Open: New Tab'         })
            m.nnore({'<Tab>'        , tapi.node.open.preview          , buffer = bufnr, silent = true, nowait = true, desc = 'Open Preview'          })
            m.nnore({'cd'           , tapi.tree.change_root_to_node   , buffer = bufnr, silent = true, nowait = true, desc = 'CD'                    })
            m.nnore({'u'            , tapi.tree.change_root_to_parent , buffer = bufnr, silent = true, nowait = true, desc = 'Up'                    })
            m.nnore({'K'            , tapi.node.navigate.sibling.first, buffer = bufnr, silent = true, nowait = true, desc = 'First Sibling'         })
            m.nnore({'J'            , tapi.node.navigate.sibling.last , buffer = bufnr, silent = true, nowait = true, desc = 'Last Sibling'          })
            m.nnore({'<C-p>'        , tapi.node.navigate.sibling.prev , buffer = bufnr, silent = true, nowait = true, desc = 'Previous Sibling'      })
            m.nnore({'<C-n>'        , tapi.node.navigate.sibling.next , buffer = bufnr, silent = true, nowait = true, desc = 'Next Sibling'          })
            m.nnore({'p'            , tapi.node.navigate.parent       , buffer = bufnr, silent = true, nowait = true, desc = 'Parent Directory'      })
            m.nnore({'.'            , tapi.tree.toggle_hidden_filter  , buffer = bufnr, silent = true, nowait = true, desc = 'Toggle Dotfiles'       })
            m.nnore({'m'            , tapi.node.show_info_popup       , buffer = bufnr, silent = true, nowait = true, desc = 'Info'                  })
            m.nnore({'r'            , tapi.tree.reload                , buffer = bufnr, silent = true, nowait = true, desc = 'Refresh'               })
            m.nnore({'q'            , tapi.tree.close                 , buffer = bufnr, silent = true, nowait = true, desc = 'Close'                 })
            m.nnore({'?'            , tapi.tree.toggle_help           , buffer = bufnr, silent = true, nowait = true, desc = 'Help'                  })
            m.nnore({'O'            , tapi.node.run.system            , buffer = bufnr, silent = true, nowait = true, desc = 'Run System'            })
            m.nnore({'A'            , tapi.fs.create                  , buffer = bufnr, silent = true, nowait = true, desc = 'Create'                })
            m.nnore({'D'            , tapi.fs.remove                  , buffer = bufnr, silent = true, nowait = true, desc = 'Delete'                })
            m.nnore({'R'            , tapi.fs.rename                  , buffer = bufnr, silent = true, nowait = true, desc = 'Rename'                })
            m.nnore({'<C-r>'        , tapi.fs.rename_sub              , buffer = bufnr, silent = true, nowait = true, desc = 'Rename: Omit Filename' })
            m.nnore({'X'            , tapi.fs.cut                     , buffer = bufnr, silent = true, nowait = true, desc = 'Cut'                   })
            m.nnore({'C'            , tapi.fs.copy.node               , buffer = bufnr, silent = true, nowait = true, desc = 'Copy'                  })
            m.nnore({'P'            , tapi.fs.paste                   , buffer = bufnr, silent = true, nowait = true, desc = 'Paste'                 })
            m.nnore({'y'            , tapi.fs.copy.filename           , buffer = bufnr, silent = true, nowait = true, desc = 'Copy Name'             })
            m.nnore({'Y'            , tapi.fs.copy.absolute_path      , buffer = bufnr, silent = true, nowait = true, desc = 'Copy Absolute Path'    })
            -- stylua: ignore end
        end,
        auto_reload_on_write = false,
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
    })
    m.nnore({ '<leader>tt', ':NvimTreeToggle<CR>' })
    m.nnore({
        '<leader>tT',
        function()
            local tapi = require('nvim-tree.api')
            tapi.tree.close()
            tapi.tree.open(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
        end,
    })
end

-- 对齐，文本对象, 缩进显示
local function pkg_mini()
    require('mini.align').setup({
        mappings = {
            start = '',
            start_with_preview = '<leader>al',
        },
    })

    require('mini.ai').setup({})

    local indentscope = require('mini.indentscope')
    indentscope.setup({
        draw = {
            delay = 0,
            animation = indentscope.gen_animation.none(),
        },
        symbol = '⁞',
    })
end

-- 模糊查找
local function pkg_telescope()
    require('telescope').setup({
        defaults = {
            borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
            color_devicons = true,
            history = {
                path = vim.env.DotVimLocal .. '/telescope_history',
            },
            mappings = {
                i = {
                    ['<M-j>'] = 'move_selection_next',
                    ['<M-k>'] = 'move_selection_previous',
                },
            },
        },
    })
    m.nnore({ '<leader><leader>n', ':Telescope<Space>' })
    m.nnore({ '<leader>nf', ':Telescope find_files<CR>' })
    m.nnore({ '<leader>nl', ':Telescope live_grep<CR>' })
    m.nnore({ '<leader>nm', ':Telescope oldfiles<CR>' })
end

--------------------------------------------------------------------------------
-- Coding
--------------------------------------------------------------------------------
-- 列表视图
local function pkg_trouble()
    require('trouble').setup({
        mode = 'quickfix',
        icons = true,
        action_keys = {
            jump_close = { 'O' },
            toggle_fold = { 'zA', 'za', 'o' },
        },
        auto_preview = false,
    })
    m.nnore({ '<leader>vq', ':TroubleToggle quickfix<CR>' })
    m.nnore({ '<leader>vl', ':TroubleToggle loclist<CR>' })
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

-- 自动括号
local function pkg_autopairs()
    require('nvim-autopairs').setup({
        map_cr = false,
    })
    m.nnore({
        '<leader>tp',
        function()
            local ap = require('nvim-autopairs').state.disabled
            print('Auto pairs:', ap)
            require('nvim-autopairs').state.disabled = not ap
        end,
    })
end

-- 批量注释
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

-- 代码折叠
local function pkg_ufo()
    local ufo = require('ufo')
    ufo.setup({
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
            local res = {}
            local tag = use.ui.patch and '' or '»'

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
            table.insert(res, { ('  %d '):format(endLnum - lnum), 'MoreMsg' })
            return res
        end,
        provider_selector = function(bufnr, filetype, buftype) return { 'treesitter', 'indent' } end,
    })
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
        --ensure_installed = { 'c', 'cpp', 'rust', 'vim', 'lua', 'python', 'markdown', 'markdown_inline', },
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
                init_selection = '<M-r>',
                node_incremental = '<M-r>',
                node_decremental = '<M-w>',
                scope_incremental = '<M-q>',
            },
        },
        rainbow = { enable = true },
    })
    vim.opt.runtimepath:append(parser_dir)
    m.nnore({
        '<leader>sh',
        function()
            vim.cmd([[TSBufToggle highlight]])
            local buf = vim.api.nvim_get_current_buf()
            local res = require('vim.treesitter.highlighter').active[buf]
            vim.notify('Treesitter highlight is ' .. (res and 'enabled' or 'disabled'))
        end,
    })
    m.nnore({
        '<leader>si',
        function()
            vim.cmd([[TSBufToggle indent]])
            local res = vim.bo.indentexpr == 'nvim_treesitter#indent()'
            vim.notify('Treesitter indent is ' .. (res and 'enabled' or 'disabled'))
        end,
    })
    m.nnore({ '<leader>tr', ':TSBufToggle rainbow<CR>' })
end

-- 代码格式化
local function pkg_formatter()
    require('formatter').setup({
        logging = false,
        filetype = {
            c = { require('formatter.defaults.clangformat') },
            cpp = { require('formatter.defaults.clangformat') },
            lua = { require('formatter.filetypes.lua').stylua },
            python = { require('formatter.filetypes.python').black },
        },
    })
    m.nore({ '<leader>fo', ':Format<CR>' })
end

-- 导步程序/任务
local function pkg_overseer()
    local overseer = require('overseer')
    overseer.setup({
        dap = false,
        task_list = {
            direction = 'right',
            bindings = {
                ['i'] = 'Edit',
                ['p'] = 'TogglePreview',
                ['o'] = 'OpenQuickFix',
                ['O'] = function()
                    require('overseer.task_list.sidebar').get():run_action('restart')
                end,
                ['K'] = function() require('overseer.task_list.sidebar').get():run_action('stop') end,
                ['D'] = function()
                    require('overseer.task_list.sidebar').get():run_action('dispose')
                end,
            },
        },
    })
    m.nnore({ '<leader>tk', '<Cmd>OverseerToggle<CR>' })
    m.nnore({
        '<leader>rk',
        function()
            local list = overseer.list_tasks()
            if #list > 0 then
                list[#list]:stop()
            end
        end,
    })
    m.nnore({
        '<leader>rK',
        function()
            local list = overseer.list_tasks()
            for _, t in ipairs(list) do
                t:stop()
            end
        end,
    })
end

--------------------------------------------------------------------------------
-- Utils
--------------------------------------------------------------------------------
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
            vim.notify('Markdown preview is ' .. s)
        end,
    })
end

--------------------------------------------------------------------------------
-- Lazy
--------------------------------------------------------------------------------
local function clone_lazy(url, bundle)
    local lazygit = bundle .. '/lazy.nvim'
    if not vim.loop.fs_stat(lazygit) then
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
    vim.opt.rtp:prepend(lazygit)
end

local function pkg_lazy()
    local url = 'https://github.com'
    if vim.fn.empty(use.xgit) == 0 then
        url = use.xgit
    end
    local bundle = vim.env.DotVimDir .. '/bundle'
    clone_lazy(url, bundle)

    local opts = {
        root = bundle,
        defaults = {
            lazy = false,
        },
        lockfile = vim.env.DotVimLocal .. '/lazy/lazy-lock.json',
        git = {
            url_format = url .. '/%s.git',
        },
        install = {
            missing = false,
        },
        readme = {
            root = vim.env.DotVimLocal .. '/lazy/readme',
            skip_if_doc_exists = false,
        },
        performance = {
            rtp = {
                reset = false,
                paths = { vim.env.DotVimInit },
            },
        },
        state = vim.env.DotVimLocal .. '/lazy/state.json',
    }
    require('lazy').setup({
        -- Editor
        { 'yehuohan/hop.nvim', config = pkg_hop },
        { 'yehuohan/marks.nvim', config = pkg_marks },
        { 'xiyaowong/nvim-cursorword', config = pkg_cursorword },
        { 'booperlv/nvim-gomove', config = pkg_gomove },
        { 'declancm/cinnamon.nvim', config = pkg_cinnamon },
        { 'gbrlsnchs/winpick.nvim', config = pkg_winpick },
        { -- 窗口移动
            'sindrets/winshift.nvim',
            init = function() m.nnore({ '<C-m>', ':WinShift<CR>' }) end,
            opts = {},
        },
        { -- 快速扩展块
            'olambo/vi-viz',
            config = function()
                m.nnore({ '<M-g>', '<Cmd>lua require("vi-viz").vizInit()<CR>' })
                m.xnore({ '<M-g>', '<Cmd>lua require("vi-viz").vizExpand()<CR>' })
                m.xnore({ '<M-a>', '<Cmd>lua require("vi-viz").vizContract()<CR>' })
            end,
        },
        { 'andymass/vim-matchup' },
        { 'mg979/vim-visual-multi' },
        { 'markonm/traces.vim' },

        -- Component
        {
            'rebelot/heirline.nvim',
            config = require('v.pkgs.nstl').setup,
            dependencies = { 'yehuohan/popc' },
        },
        { 'goolord/alpha-nvim', config = pkg_alpha },
        { 'rcarriga/nvim-notify', config = pkg_notify },
        { -- vim.ui界面美化
            'stevearc/dressing.nvim',
            opts = {
                input = { enabled = true },
                select = { enabled = true },
            },
        },
        { -- 字体图标选择器
            'ziontee113/icon-picker.nvim',
            init = function()
                m.inore({ '<M-w>', '<Cmd>IconPickerInsert<CR>' })
                m.nnore({ '<leader><leader>i', ':IconPickerInsert<Space>' })
            end,
            opts = { disable_legacy_commands = true },
            cmd = 'IconPickerInsert',
        },
        { 'lukas-reineke/virt-column.nvim', opts = { char = '┊' } },
        {
            'kyazdani42/nvim-tree.lua',
            config = pkg_tree,
            keys = { '<leader>tt', '<leader>tT' },
        },
        { 'echasnovski/mini.nvim', config = pkg_mini },
        {
            'nvim-telescope/telescope.nvim',
            config = pkg_telescope,
            keys = {
                '<leader><leader>n',
                '<leader>nf',
                '<leader>nl',
                '<leader>nm',
            },
        },
        { 'kyazdani42/nvim-web-devicons', lazy = true, enabled = use.ui.patch },
        { 'morhetz/gruvbox' },
        { 'rakr/vim-one' },
        { 'tanvirtin/monokai.nvim' },
        { 'Yggdroot/indentLine' },
        { 'yehuohan/popc' },
        { 'yehuohan/popset', dependencies = { 'yehuohan/popc' } },
        { 'yehuohan/popc-floaterm', dependencies = { 'yehuohan/popc' } },
        {
            'scrooloose/nerdtree',
            dependencies = {
                { 'ryanoasis/vim-devicons', enabled = use.ui.patch },
            },
            cmd = { 'NERDTreeToggle', 'NERDTree' },
        },
        { 'itchyny/screensaver.vim' },
        { 'junegunn/fzf' },
        { 'junegunn/fzf.vim' },
        { 'Yggdroot/LeaderF', enabled = use.has_py, build = ':LeaderfInstallCExtension' },

        -- Coding
        {
            'folke/trouble.nvim',
            config = pkg_trouble,
            keys = { '<leader>vq', '<leader>vl' },
        },
        {
            'uga-rosa/ccc.nvim',
            config = pkg_ccc,
            keys = { '<leader>tc', '<leader>lp' },
        },
        { 'windwp/nvim-autopairs', config = pkg_autopairs },
        { 'numToStr/Comment.nvim', config = pkg_comment },
        { 'kylechui/nvim-surround', config = pkg_surround },
        {
            'kevinhwang91/nvim-ufo',
            config = pkg_ufo,
            dependencies = { 'kevinhwang91/promise-async' },
        },
        { 'nvim-treesitter/nvim-treesitter', enabled = use.nts, config = pkg_treesitter },
        {
            'HiPhish/nvim-ts-rainbow2',
            enabled = use.nts,
            dependencies = { 'nvim-treesitter/nvim-treesitter' },
        },
        {
            'hrsh7th/nvim-cmp',
            enabled = use.nlsp,
            config = require('v.pkgs.nlsp').setup,
            event = { 'InsertEnter', 'CmdlineEnter' },
            dependencies = {
                'williamboman/mason.nvim',
                'williamboman/mason-lspconfig.nvim',
                'neovim/nvim-lspconfig',
                'glepnir/lspsaga.nvim',
                'ray-x/lsp_signature.nvim',
                -- Plug 'simrat39/rust-tools.nvim'
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-nvim-lua',
                'hrsh7th/cmp-calc',
                'yehuohan/cmp-cmdline',
                'yehuohan/cmp-path',
                'yehuohan/cmp-im',
                'yehuohan/cmp-im-zh',
                'dmitmel/cmp-cmdline-history',
                'quangnguyen30192/cmp-nvim-ultisnips',
                'kdheepak/cmp-latex-symbols',
                'f3fora/cmp-spell',
                'nvim-lua/plenary.nvim',
            },
        },
        {
            'neoclide/coc.nvim',
            enabled = use.coc,
            branch = 'release',
            config = function()
                vim.fn['coc#config']('Lua', {
                    workspace = {
                        library = {
                            vim.env.DotVimInit .. '/lua',
                            vim.env.VIMRUNTIME .. '/lua',
                            vim.env.VIMRUNTIME .. '/lua/vim',
                            vim.env.VIMRUNTIME .. '/lua/vim/lsp',
                            vim.env.VIMRUNTIME .. '/lua/vim/treesitter',
                        },
                    },
                })
            end,
            event = 'InsertEnter',
            dependencies = { 'neoclide/jsonc.vim' },
        },
        { 'mhartington/formatter.nvim', config = pkg_formatter },
        { 'stevearc/overseer.nvim', config = pkg_overseer },
        { 'SirVer/ultisnips', enabled = use.has_py, dependencies = { 'honza/vim-snippets' } },
        {
            'rcarriga/nvim-dap-ui',
            enabled = use.ndap,
            dependencies = {
                'mfussenegger/nvim-dap',
            },
        },
        { 'puremourning/vimspector', enabled = use.ndap },
        { 'liuchengxu/vista.vim', cmd = 'Vista' },
        { 't9md/vim-quickhl' },
        { 'voldikss/vim-floaterm' },
        { 'rust-lang/rust.vim' },

        -- Utils
        {
            'toppair/peek.nvim',
            ft = 'markdown',
            config = pkg_peek,
            build = 'deno task --quiet build:fast',
        },
        { 'Rykka/riv.vim', ft = 'rst' },
        { 'Rykka/InstantRst', ft = 'rst' },
        { 'lervag/vimtex', ft = 'tex' },
        { 'tyru/open-browser.vim' },
        { 'voldikss/vim-translator' },
        { 'brglng/vim-im-select' },
    }, opts)

    vim.api.nvim_create_augroup('PkgLazy', { clear = true })
    vim.api.nvim_create_autocmd('ColorScheme', {
        group = 'PkgLazy',
        callback = function()
            vim.api.nvim_set_hl(0, 'CursorWord', { ctermbg = 60, bg = '#505060' })
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
