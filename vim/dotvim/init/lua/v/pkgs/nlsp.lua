--- @diagnostic disable: inject-field
--- @diagnostic disable: undefined-field

local use = require('v.use')
local m = require('v.nlib').m

--- Setup language servers
local function setup_servers()
    -- Settings
    require('neoconf').setup({
        -- Priority: lspconfig.setup() < global < local
        local_settings = '.nlsp.json',
        global_settings = 'nlsp.json',
        filetype_jsonc = use.nts,
    })
    require('lazydev').setup({})
    -- Servers
    local url = 'https://github.com/%s/releases/download/%s/%s'
    if vim.fn.empty(use.xgit) == 0 then
        url = use.xgit .. '/%s/releases/download/%s/%s'
    end
    require('mason').setup({
        install_root_dir = vim.env.DotVimLocal .. '/.mason',
        github = { download_url_template = url },
        ui = {
            check_outdated_packages_on_open = true,
            border = 'single',
            icons = {
                package_installed = '√',
                package_pending = '●',
                package_uninstalled = '○',
            },
        },
    })
    require('mason-lspconfig').setup({})
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local opts = {
        function(server_name)
            lspconfig[server_name].setup({
                capabilities = capabilities,
            })
        end,
    }
    opts['clangd'] = function()
        lspconfig.clangd.setup({
            capabilities = capabilities,
            -- Treesitter is better than clangd's semantic
            on_init = function(client) client.server_capabilities.semanticTokensProvider = nil end,
        })
    end
    opts['cmake'] = function()
        lspconfig.cmake.setup({
            capabilities = capabilities,
            init_options = { buildDirectory = '_VOut' },
        })
    end
    opts['rust_analyzer'] = function()
        lspconfig.rust_analyzer.setup({
            capabilities = capabilities,
            settings = {
                ['rust-analyzer'] = {
                    updates = { checkOnStartup = false, channel = 'nightly' },
                    cargo = { allFeatures = true },
                    notifications = { cargoTomlNotFound = false },
                },
            },
        })
    end
    opts['basedpyright'] = function()
        lspconfig.basedpyright.setup({
            capabilities = capabilities,
            -- Treesitter is better than basedpyright's semantic
            on_init = function(client) client.server_capabilities.semanticTokensProvider = nil end,
        })
    end
    opts['ruff'] = function() end -- Disable ruff server
    opts['lua_ls'] = function()
        lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    workspace = {
                        library = {
                            vim.env.DotVimInit .. '/lua',
                            vim.env.VIMRUNTIME .. '/lua',
                            vim.env.VIMRUNTIME .. '/lua/vim',
                            vim.env.VIMRUNTIME .. '/lua/vim/lsp',
                            vim.env.VIMRUNTIME .. '/lua/vim/treesitter',
                            vim.env.DotVimDir .. '/bundle/plenary.nvim/lua',
                        },
                        checkThirdParty = false,
                    },
                    telemetry = { enable = false },
                    format = { enable = false },
                    diagnostics = { disable = { 'missing-fields' } },
                },
            },
        })
    end
    opts['tinymist'] = function()
        lspconfig.tinymist.setup({
            capabilities = capabilities,
            single_file_support = true,
            offset_encoding = 'utf-8',
            settings = { formatterMode = 'typstyle' },
        })
    end
    require('mason-lspconfig').setup_handlers(opts)
end

--- Setup completion sources
local function setup_sources()
    local cmp_im = require('cmp_im')
    local cmp_im_zh = require('cmp_im_zh')
    cmp_im.setup({
        tables = cmp_im_zh.tables({ 'wubi', 'pinyin' }),
        maxn = 5,
    })
    m.add({ 'n', 'v', 'c', 'i' }, {
        '<C-;>',
        function()
            if cmp_im.toggle() then
                vim.notify('IM is enabled')
                for lhs, rhs in pairs(cmp_im_zh.symbols()) do
                    m.inore({ lhs, rhs })
                end
            else
                vim.notify('IM is disabled')
                for lhs, _ in pairs(cmp_im_zh.symbols()) do
                    m.idel({ lhs })
                end
            end
        end,
        desc = 'Toggle input method',
    })
end

-- stylua: ignore start
local kind_icons = {
    Text          = { '', 'Txt' , 1  },
    Method        = { '󰆧', 'Meth', 2  },
    Function      = { '󰊕', 'Fun' , 3  },
    Constructor   = { '', 'CnSt', 4  },
    Field         = { '󰇽', 'Fied', 5  },
    Variable      = { 'ω', 'Var' , 6  },
    Class         = { '󰠱', 'Cla' , 7  },
    Interface     = { '', 'InF' , 8  },
    Module        = { '', 'Mod' , 9  },
    Property      = { '󰜢', 'Prop', 10 },
    Unit          = { '', 'Unit', 11 },
    Value         = { '󰎠', 'Val' , 12 },
    Enum          = { '', 'Enum', 13 },
    Keyword       = { '󰌋', 'Key' , 14 },
    Snippet       = { '', 'Snip', 15 },
    Color         = { '󰏘', 'Clr' , 16 },
    File          = { '󰈙', 'File', 17 },
    Reference     = { '', 'Ref' , 18 },
    Folder        = { '󰉋', 'Dir' , 19 },
    EnumMember    = { '', 'EMem', 20 },
    Constant      = { '', 'Cons', 21 },
    Struct        = { '', 'Stru', 22 },
    Event         = { '', 'Evnt', 23 },
    Operator      = { '󰆕', 'Oprt', 24 },
    TypeParameter = { '', 'TyPa', 25 },
}

local kind_sources = {
    buffer          = 'Buf',
    nvim_lsp        = 'Lsp',
    luasnip         = 'Snp',
    cmdline         = 'Cmd',
    cmdline_history = 'CLh',
    path            = 'Pth',
    calc            = 'Cal',
    IM              = 'IMs',
    latex_symbols   = 'Tex',
    spell           = 'Spl', -- It's enabling depends on 'spell' option
}
-- stylua: ignore end

--- Format completion menu with (cmp.Entry, vim.CompletedItem)
local function cmp_format(entry, citem)
    local ico = kind_icons[citem.kind] or { '?', vim.inspect(citem.kind) }
    local src = kind_sources[entry.source.name] or entry.source.name
    citem.kind = string.format(' %s', use.ui.icon and ico[1] or ico[2]:sub(1, 1))
    if string.len(citem.abbr) > 80 then
        citem.abbr = string.sub(citem.abbr, 1, 78) .. ' …'
    end
    citem.menu = string.format('%3s.%s', src, ico[2])
    return citem
end

--- Completion's super-tab
local function cmp_supertab(fallback)
    local cmp = require('cmp')
    local snip = require('luasnip')
    if cmp.visible() and cmp.get_active_entry() then
        cmp.confirm({ select = false })
    elseif snip.expandable() then
        snip.expand()
    else
        fallback()
    end
end

--- Get select options
---@param count(integer) +1 for next and -1 for prev
local function cmp_select(count)
    local cmp = require('cmp')
    local behavior = cmp.SelectBehavior.Insert
    local entries = cmp.get_entries()
    local index_max = #entries
    if index_max > 0 then
        local index = cmp.get_selected_index() or 0
        index = index + count
        if index < 0 then
            index = index_max
        elseif index > index_max then
            index = 0
        end
        if index > 0 and entries[index].completion_item.kind == kind_icons['Snippet'][3] then
            behavior = cmp.SelectBehavior.Select
        end
    end
    return { behavior = behavior }
end

--- Setup completion framework
local function setup_completion()
    local cmp = require('cmp')
    local cmp_lsp_rs = require('cmp_lsp_rs')
    local compare = cmp.config.compare
    local opts_snip = { config = { sources = { { name = 'luasnip' } } } }
    local opts_cmdh = { config = { sources = { { name = 'cmdline_history' } } } }
    local cmp_mappings = {
        ['<Tab>'] = cmp.mapping({
            i = cmp_supertab,
            c = function() return cmp.visible() and cmp.select_next_item() or cmp.complete() end,
        }),
        ['<S-Tab>'] = cmp.mapping({
            c = function() return cmp.visible() and cmp.select_prev_item() or cmp.complete() end,
        }),
        ['<CR>'] = cmp.mapping.confirm(),
        ['<M-i>'] = cmp.mapping.complete(),
        ['<M-u>'] = cmp.mapping(function() cmp.complete(opts_snip) end, { 'i' }),
        ['<M-y>'] = cmp.mapping(function() cmp.complete(opts_cmdh) end, { 'c' }),
        ['<M-e>'] = cmp.mapping(function() cmp.abort() end, { 'i', 'c' }),
        ['<M-j>'] = cmp.mapping(function() cmp.select_next_item(cmp_select(1)) end, { 'i', 'c' }),
        ['<M-k>'] = cmp.mapping(function() cmp.select_prev_item(cmp_select(-1)) end, { 'i', 'c' }),
        ['<M-n>'] = cmp.mapping.scroll_docs(4),
        ['<M-m>'] = cmp.mapping.scroll_docs(-4),
        ['<M-f>'] = cmp.mapping.scroll_docs(4),
        ['<M-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-p>'] = cmp.mapping(
            function() vim.api.nvim_feedkeys(vim.fn.getreg('0'), 'i', false) end,
            { 'i', 'c' }
        ),
        ['<C-v>'] = cmp.mapping(
            function() vim.api.nvim_feedkeys(vim.fn.getreg('+'), 'i', false) end,
            { 'i', 'c' }
        ),
        ['<Space>'] = cmp.mapping(require('cmp_im').select(), { 'i', 'c' }),
    }
    m.imap({ '<C-j>', '<M-j>' })
    m.imap({ '<C-k>', '<M-k>' })

    cmp.setup({
        mapping = cmp_mappings,
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'lazydev', group_index = 0 }, -- Set group index to 0 to skip loading LuaLS completions
            { name = 'luasnip' },
            { name = 'path' },
            { name = 'calc' },
            { name = 'IM' },
        }, {
            { name = 'buffer' },
        }),
        preselect = cmp.PreselectMode.None,
        window = {
            completion = {
                border = 'none',
                winhighlight = 'Normal:Pmenu,CursorLine:DiffChange,FloatBorder:Pmenu,Search:None',
                col_offset = -2,
                side_padding = 0,
            },
            documentation = {
                winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
                max_width = 80,
            },
        },
        formatting = {
            fields = { 'kind', 'abbr', 'menu' },
            format = cmp_format,
        },
    })
    cmp.setup.filetype('rust', {
        sorting = {
            comparators = {
                compare.offset,
                compare.exact,
                compare.score,
                cmp_lsp_rs.comparators.inscope_inherent_import,
                cmp_lsp_rs.comparators.sort_by_label_but_underscore_last,
            },
        },
    })
    cmp.setup.filetype({ 'tex', 'latex', 'markdown', 'restructuredtext', 'text', 'help' }, {
        sources = cmp.config.sources({
            { name = 'luasnip' },
            { name = 'buffer' },
            { name = 'path' },
            { name = 'calc' },
            { name = 'IM' },
        }, {
            { name = 'latex_symbols' },
            { name = 'spell' },
        }),
    })
    cmp.setup.cmdline({ '/', '?' }, {
        sources = {
            { name = 'buffer' },
            { name = 'IM' },
        },
    })
    cmp.setup.cmdline({ ':', '@' }, {
        sources = cmp.config.sources({
            { name = 'path' },
            { name = 'IM' },
        }, {
            { name = 'cmdline' },
        }),
    })
end

--- Setup lsp highlights
local function setup_highlights()
    local api = vim.api
    -- stylua: ignore start
    api.nvim_set_hl(0, 'LspSignatureActiveParameter', {link = 'Tag' })
    api.nvim_set_hl(0, 'DiagnosticUnderlineError'   , {undercurl = true, sp = 'Red' })
    api.nvim_set_hl(0, 'DiagnosticUnderlineWarn'    , {undercurl = true, sp = 'Orange' })
    api.nvim_set_hl(0, 'DiagnosticUnderlineInfo'    , {undercurl = true, sp = 'LightBlue' })
    api.nvim_set_hl(0, 'DiagnosticUnderlineHint'    , {link = 'Comment' })

    api.nvim_set_hl(0, 'CmpItemMenu'             , {ctermfg = 175, fg = '#d3869b', italic = true })
    api.nvim_set_hl(0, 'CmpItemAbbrMatch'        , {ctermfg = 208, fg = '#fe8019' })
    api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy'   , {ctermfg = 208, fg = '#fe8019' })
    api.nvim_set_hl(0, 'CmpItemKind'             , {ctermfg = 142, fg = '#b8bb26' })
    api.nvim_set_hl(0, 'CmpItemKindText'         , {fg = '#458588' })
    api.nvim_set_hl(0, 'CmpItemKindMethod'       , {fg = '#b8bb26' })
    api.nvim_set_hl(0, 'CmpItemKindFunction'     , {fg = '#b8bb26' })
    api.nvim_set_hl(0, 'CmpItemKindConstructor'  , {fg = '#e95678' })
    api.nvim_set_hl(0, 'CmpItemKindField'        , {fg = '#e95678' })
    api.nvim_set_hl(0, 'CmpItemKindVariable'     , {fg = '#458588' })
    api.nvim_set_hl(0, 'CmpItemKindClass'        , {fg = '#cc5155' })
    api.nvim_set_hl(0, 'CmpItemKindInterface'    , {fg = '#cc5155' })
    api.nvim_set_hl(0, 'CmpItemKindModule'       , {fg = '#689d6a' })
    api.nvim_set_hl(0, 'CmpItemKindProperty'     , {fg = '#689d6a' })
    api.nvim_set_hl(0, 'CmpItemKindUnit'         , {fg = '#afd700' })
    api.nvim_set_hl(0, 'CmpItemKindValue'        , {fg = '#afd700' })
    api.nvim_set_hl(0, 'CmpItemKindEnum'         , {fg = '#61afef' })
    api.nvim_set_hl(0, 'CmpItemKindKeyword'      , {fg = '#61afef' })
    api.nvim_set_hl(0, 'CmpItemKindSnippet'      , {fg = '#cba6f7' })
    api.nvim_set_hl(0, 'CmpItemKindColor'        , {fg = '#cba6f7' })
    api.nvim_set_hl(0, 'CmpItemKindFile'         , {fg = '#e18932' })
    api.nvim_set_hl(0, 'CmpItemKindReference'    , {fg = '#1abc9c' })
    api.nvim_set_hl(0, 'CmpItemKindFolder'       , {fg = '#e18932' })
    api.nvim_set_hl(0, 'CmpItemKindEnumMember'   , {fg = '#61afef' })
    api.nvim_set_hl(0, 'CmpItemKindConstant'     , {fg = '#1abc9c' })
    api.nvim_set_hl(0, 'CmpItemKindStruct'       , {fg = '#f7bb3b' })
    api.nvim_set_hl(0, 'CmpItemKindEvent'        , {fg = '#f7bb3b' })
    api.nvim_set_hl(0, 'CmpItemKindOperator'     , {fg = '#d3869b' })
    api.nvim_set_hl(0, 'CmpItemKindTypeParameter', {fg = '#d3869b' })
    -- stylua: ignore end
end

--- Setup lsp settings
local function setup_lsp_settings()
    vim.lsp.set_log_level(vim.lsp.log_levels.OFF)
    local signs
    if use.ui.icon then
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = '🗴',
                [vim.diagnostic.severity.WARN] = '',
                [vim.diagnostic.severity.INFO] = '󰍟',
                [vim.diagnostic.severity.HINT] = '󰌶',
            },
        }
    end
    vim.diagnostic.config({ virtual_text = { prefix = '▪' }, signs = signs })

    require('lspsaga').setup({
        ui = { border = 'single' },
        scroll_preview = {
            scroll_down = '<M-n>',
            scroll_up = '<M-m>',
        },
        code_action = {
            keys = { quit = { 'q', '<Esc>' } },
        },
        lightbulb = { enable = false },
        diagnostic = { on_insert = false },
        symbol_in_winbar = {
            enable = true,
            separator = use.ui.icon and '  ' or ' > ',
        },
    })

    require('lsp_signature').setup({
        bind = true,
        doc_lines = 50,
        max_height = 50,
        max_width = 80,
        hint_enable = true,
        hint_prefix = '» ',
        handler_opts = { border = 'none' },
        padding = ' ',
        floating_window = false,
        toggle_key = '<M-o>',
        select_signature_key = '<M-p>',
    })
end

--- Setup lsp mappings
local function setup_lsp_mappings()
    -- m.inore({ '<M-o>', vim.lsp.buf.signature_help })
    m.nnore({ 'gd', vim.lsp.buf.definition })
    m.nnore({ 'gD', vim.lsp.buf.declaration })
    m.nnore({ '<leader>gd', vim.lsp.buf.definition })
    m.nnore({ '<leader>gD', vim.lsp.buf.declaration })
    m.nnore({ '<leader>gi', vim.lsp.buf.implementation })
    m.nnore({ '<leader>gy', vim.lsp.buf.type_definition })
    m.nnore({ '<leader>gr', vim.lsp.buf.references })
    m.nnore({ '<leader>gn', vim.lsp.buf.rename })
    m.nnore({
        '<leader>gf',
        function() vim.lsp.buf.code_action({ apply = true }) end,
        desc = 'Apply code action',
    })
    -- m.nnore({ '<leader>ga', vim.lsp.buf.code_action })
    -- m.nnore({ '<leader>gh', vim.lsp.buf.hover })
    m.nnore({ '<leader>ga', '<Cmd>Lspsaga code_action<CR>' })
    m.nnore({ '<leader>gh', '<Cmd>Lspsaga hover_doc<CR>' })
    m.nnore({ '<leader>gp', '<Cmd>Lspsaga peek_definition<CR>' })
    m.nnore({ '<leader>gs', '<Cmd>Lspsaga finder<CR>' })
    m.nnore({ '<leader>go', '<Cmd>Lspsaga outline<CR>' })

    m.nore({ '<leader>of', vim.lsp.buf.format })
    m.nnore({ '<leader>od', vim.diagnostic.setloclist })
    m.nnore({
        '<leader>oD',
        function()
            local filter = { bufnr = 0 }
            local enabled = vim.diagnostic.is_enabled(filter)
            vim.diagnostic.enable(not enabled, filter)
            vim.notify('Diagnostic ' .. (enabled and 'disabled' or 'enabled'))
        end,
        desc = 'Toggle lsp diagnostic',
    })
    m.nnore({
        '<leader>oH',
        function()
            local filter = { bufnr = 0 }
            local enabled = vim.lsp.inlay_hint.is_enabled(filter)
            vim.lsp.inlay_hint.enable(not enabled, filter)
            vim.notify('Inlay hint ' .. (enabled and 'disabled' or 'enabled'))
        end,
        desc = 'Toggle lsp inlay hint',
    })
    m.nnore({ '<leader>oi', vim.diagnostic.open_float })
    local opts = { severity = vim.diagnostic.severity.ERROR }
    m.nnore({ '<leader>oj', function() vim.diagnostic.goto_next(opts) end, desc = 'Next error' })
    m.nnore({ '<leader>ok', function() vim.diagnostic.goto_prev(opts) end, desc = 'Prev error' })
    m.nnore({ '<leader>oJ', vim.diagnostic.goto_next, desc = 'Next diagnostic' })
    m.nnore({ '<leader>oK', vim.diagnostic.goto_prev, desc = 'Prev diagnostic' })
    -- TODO: list for workspace, sources, servers, commands
    -- m.nnore{'<leader>ow', vim.lsp.buf.xxx_workspace_folder}
    -- m.nnore{'<leader>oe', vim.lsp.buf.execute_command}
    m.nnore({ '<leader><leader>o', ':LspStart<Space>' })
    m.nnore({ '<leader>oR', ':LspRestart<CR>' })
    m.nnore({ '<leader>ol', ':LspInfo<CR>' })
    m.nnore({ '<leader>oc', ':Neoconf<CR>' })
    m.nnore({ '<leader>oC', ':e .nlsp.json<CR>' })
    m.nnore({ '<leader>on', ':Neoconf lsp<CR>' })
    m.nnore({ '<leader>oN', ':Neoconf show<CR>' })
    m.nnore({ '<leader>om', ':Mason<CR>' })
    m.nnore({ '<leader>os', ':CmpStatus<CR>' })
    m.nnore({ '<leader>oh', '<Cmd>ClangdSwitchSourceHeader<CR>' })
end

local pkg_nslp = vim.schedule_wrap(function()
    setup_servers()
    setup_sources()
    setup_completion()
    setup_highlights()
    setup_lsp_settings()
    setup_lsp_mappings()
end)

return {
    'hrsh7th/nvim-cmp',
    cond = use.nlsp,
    config = pkg_nslp,
    event = { 'InsertEnter' },
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'neovim/nvim-lspconfig',
        'folke/neoconf.nvim',
        { 'folke/lazydev.nvim', ft = 'lua' },
        'nvimdev/lspsaga.nvim',
        'ray-x/lsp_signature.nvim',
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
        -- { 'mrcjkb/rustaceanvim', ft = { 'rust' } },
        { 'zjp-CN/nvim-cmp-lsp-rs', ft = { 'rust' } },
    },
}
