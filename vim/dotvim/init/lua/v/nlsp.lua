local api = vim.api
local use = require('v.use').get()
local m = require('v.libv').m

local function __servers()
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
    require('mason-lspconfig').setup_handlers({
        function(server_name)
            lspconfig[server_name].setup({
                capabilities = capabilities,
            })
        end,
        ['cmake'] = function()
            lspconfig.cmake.setup({
                capabilities = capabilities,
                init_options = {
                    buildDirectory = '__VBuildOut',
                },
            })
        end,
        ['rust_analyzer'] = function()
            lspconfig.rust_analyzer.setup({
                capabilities = capabilities,
                settings = {
                    ['rust-analyzer'] = {
                        updates = {
                            checkOnStartup = false,
                            channel = 'nightly',
                        },
                        cargo = { allFeatures = true },
                        notifications = { cargoTomlNotFound = false },
                        diagnostics = { disabled = { 'inactive-code' } },
                        procMacro = { enable = true },
                    },
                },
            })
        end,
        ['pyright'] = function()
            lspconfig.pyright.setup({
                capabilities = capabilities,
                settings = {
                    python = {
                        analysis = {
                            stubPath = 'typings',
                        },
                    },
                },
            })
        end,
        ['lua_ls'] = function()
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = { version = 'Lua 5.2' }, -- LuaJIT
                        workspace = {
                            library = {
                                vim.env.DotVimInit .. '/lua',
                                vim.env.VIMRUNTIME .. '/lua',
                                vim.env.VIMRUNTIME .. '/lua/vim',
                                vim.env.VIMRUNTIME .. '/lua/vim/lsp',
                                vim.env.VIMRUNTIME .. '/lua/vim/treesitter',
                            },
                        },
                        telemetry = { enable = false },
                        format = {
                            enable = false,
                        },
                    },
                },
            })
        end,
    })
end

-- stylua: ignore start
local kind_icons = {
    Text          = { '', 'Txt'  },
    Method        = { '', 'Meth' },
    Function      = { '', 'Fun'  },
    Constructor   = { '', 'CnSt' },
    Field         = { '', 'Fied' },
    Variable      = { 'ω', 'Var'  },
    Class         = { 'ﴯ', 'Cla'  },
    Interface     = { '', 'InF'  },
    Module        = { '', 'Mod'  },
    Property      = { 'ﰠ', 'Prop' },
    Unit          = { '', 'Unit' },
    Value         = { '', 'Val'  },
    Enum          = { '', 'Enum' },
    Keyword       = { '', 'Key'  },
    Snippet       = { '', 'Snip' },
    Color         = { '', 'Clr'  },
    File          = { '', 'File' },
    Reference     = { '', 'Ref'  },
    Folder        = { '', 'Dir'  },
    EnumMember    = { '', 'EnuM' },
    Constant      = { '', 'Cons' },
    Struct        = { '', 'Stru' },
    Event         = { '', 'Evnt' },
    Operator      = { '', 'Oprt' },
    TypeParameter = { '', 'TyPa' },
}

local kind_sources = {
    buffer          = 'Buf',
    nvim_lsp        = 'Lsp',
    nvim_lua        = 'Lua',
    ultisnips       = 'Snp',
    cmdline         = 'Cmd',
    cmdline_history = 'Cmh',
    path            = 'Pth',
    calc            = 'Cal',
    IM              = 'IMs',
    latex_symbols   = 'Tex',
    spell           = 'Spl', -- It's enabling depends on 'spell' option
}
-- stylua: ignore end

local function cmp_format(entry, vitem)
    local ico = kind_icons[vitem.kind]
    local src = kind_sources[entry.source.name] or entry.source.name
    if use.ui.patch then
        vitem.kind = string.format(' %s', ico[1])
    else
        vitem.kind = string.format(' %s', ico[2]:sub(1, 1))
    end
    if string.len(vitem.abbr) > 80 then
        vitem.abbr = string.sub(vitem.abbr, 1, 78) .. ' …'
    end
    vitem.menu = string.format('%3s.%s', src, ico[2])
    return vitem
end

local function __hl()
    -- stylua: ignore start
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

    api.nvim_set_hl(0, 'LspSignatureActiveParameter', {link = 'Tag' })
    api.nvim_set_hl(0, 'DiagnosticUnderlineError'   , {undercurl = true, sp = 'Red' })
    api.nvim_set_hl(0, 'DiagnosticUnderlineWarn'    , {undercurl = true, sp = 'Orange' })
    api.nvim_set_hl(0, 'DiagnosticUnderlineInfo'    , {undercurl = true, sp = 'LightBlue' })
    api.nvim_set_hl(0, 'DiagnosticUnderlineHint'    , {link = 'Comment' })
    -- stylua: ignore end
end

local function __completion()
    local cmp_im = require('cmp_im')
    cmp_im.setup({
        tables = require('cmp_im_zh').tables({ 'wubi', 'pinyin' }),
        maxn = 5,
    })
    m.add({ 'n', 'v', 'c', 'i' }, {
        '<M-;>',
        function()
            vim.notify(string.format('IM is %s', cmp_im.toggle() and 'enabled' or 'disabled'))
        end,
    })

    local cmp = require('cmp')
    local cmp_mappings = {
        ['<M-i>'] = cmp.mapping(function() cmp.complete() end, { 'i' }),
        ['<M-u>'] = cmp.mapping(
            function()
                cmp.complete({
                    config = {
                        sources = { { name = 'ultisnips' } },
                    },
                })
            end,
            { 'i' }
        ),
        ['<M-e>'] = cmp.mapping(function() cmp.abort() end, { 'i', 'c' }),
        ['<M-j>'] = cmp.mapping(function() cmp.select_next_item() end, { 'i', 'c' }),
        ['<M-k>'] = cmp.mapping(function() cmp.select_prev_item() end, { 'i', 'c' }),
        ['<M-n>'] = cmp.mapping.scroll_docs(4),
        ['<M-m>'] = cmp.mapping.scroll_docs(-4),
        ['<M-f>'] = cmp.mapping.scroll_docs(4),
        ['<M-d>'] = cmp.mapping.scroll_docs(-4),
        ['<M-y>'] = cmp.mapping(
            function()
                cmp.complete({
                    config = {
                        sources = { { name = 'cmdline_history' } },
                    },
                })
            end,
            { 'c' }
        ),
        ['<Tab>'] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_next_item()
            else
                cmp.complete()
            end
        end, { 'c' }),
        ['<S-Tab>'] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_prev_item()
            else
                cmp.complete()
            end
        end, { 'c' }),
        ['<Space>'] = cmp.mapping(cmp_im.select(), { 'i', 'c' }),
        ['1'] = cmp.mapping(cmp_im.select(1), { 'i', 'c' }),
        ['2'] = cmp.mapping(cmp_im.select(2), { 'i', 'c' }),
        ['3'] = cmp.mapping(cmp_im.select(3), { 'i', 'c' }),
        ['4'] = cmp.mapping(cmp_im.select(4), { 'i', 'c' }),
        ['5'] = cmp.mapping(cmp_im.select(5), { 'i', 'c' }),
        ['6'] = cmp.mapping(cmp_im.select(6), { 'i', 'c' }),
        ['7'] = cmp.mapping(cmp_im.select(7), { 'i', 'c' }),
        ['8'] = cmp.mapping(cmp_im.select(8), { 'i', 'c' }),
        ['9'] = cmp.mapping(cmp_im.select(9), { 'i', 'c' }),
        ['0'] = cmp.mapping(cmp_im.select(10), { 'i', 'c' }),
    }
    m.imap({ '<C-j>', '<M-j>' })
    m.imap({ '<C-k>', '<M-k>' })

    cmp.setup({
        mapping = cmp_mappings,
        snippet = {
            expand = function(args) vim.fn['UltiSnips#Anon'](args.body) end,
        },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'nvim_lua' },
            { name = 'ultisnips' },
            { name = 'path' },
            { name = 'calc' },
            { name = 'IM' },
        }, {
            { name = 'buffer' },
        }),
        window = {
            completion = {
                border = 'none',
                winhighlight = 'Normal:Pmenu,CursorLine:Visual,FloatBorder:Pmenu,Search:None',
                col_offset = -2,
                side_padding = 0,
            },
            documentation = {
                max_width = 80,
            },
        },
        formatting = {
            fields = { 'kind', 'abbr', 'menu' },
            format = cmp_format,
        },
    })
    cmp.setup.filetype({ 'tex', 'latex', 'markdown', 'restructuredtext', 'text', 'help' }, {
        sources = cmp.config.sources({
            { name = 'ultisnips' },
            { name = 'path' },
            { name = 'calc' },
            { name = 'IM' },
        }, {
            { name = 'latex_symbols' },
            { name = 'spell' },
        }),
    })
    cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp_mappings,
        sources = {
            { name = 'IM' },
            { name = 'buffer' },
        },
    })
    cmp.setup.cmdline({ ':', '@' }, {
        mapping = cmp_mappings,
        sources = cmp.config.sources({
            { name = 'IM' },
            { name = 'path' },
        }, {
            { name = 'cmdline' },
        }),
    })
end

local function __lsp()
    vim.lsp.set_log_level(vim.lsp.log_levels.OFF)
    if use.ui.patch then
        for name, icon in pairs({
            DiagnosticSignError = '🗴',
            DiagnosticSignWarn = '',
            DiagnosticSignInfo = '►',
            DiagnosticSignHint = '',
        }) do
            vim.fn.sign_define(name, { text = icon, texthl = name, numhl = name })
        end
    end
    vim.diagnostic.config({
        virtual_text = { prefix = '▪' },
    })

    require('lspsaga').setup({
        ui = {
            border = 'single',
        },
        scroll_preview = {
            scroll_down = '<M-f>',
            scroll_up = '<M-d>',
        },
        code_action = {
            keys = {
                quit = { 'q', '<Esc>' },
            },
        },
        lightbulb = {
            enable = false,
        },
        diagnostic = {
            on_insert = false,
        },
        symbol_in_winbar = {
            enable = true,
            separator = use.ui.patch and '  ' or ' > ',
        },
    })

    require('lsp_signature').setup({
        bind = true,
        doc_lines = 50,
        max_height = 50,
        max_width = 80,
        hint_enable = true,
        hint_prefix = '» ',
        handler_opts = {
            border = 'none',
        },
        padding = ' ',
        toggle_key = '<M-o>',
        select_signature_key = '<M-l>',
    })
end

local function __mappings()
    m.inore({ '<M-o>', vim.lsp.buf.signature_help })
    m.nnore({ 'gd', vim.lsp.buf.definition })
    m.nnore({ 'gD', vim.lsp.buf.declaration })
    m.nnore({ '<leader>gd', vim.lsp.buf.definition })
    m.nnore({ '<leader>gD', vim.lsp.buf.declaration })
    m.nnore({ '<leader>gi', vim.lsp.buf.implementation })
    m.nnore({ '<leader>gt', vim.lsp.buf.type_definition })
    m.nnore({ '<leader>gr', vim.lsp.buf.references })
    m.nnore({ '<leader>gn', vim.lsp.buf.rename })
    m.nnore({ '<leader>gf', function() vim.lsp.buf.code_action({ apply = true }) end })
    -- m.nnore{'<leader>ga', vim.lsp.buf.code_action}
    -- m.nnore{'<leader>gh', vim.lsp.buf.hover}
    m.nnore({ '<leader>ga', '<Cmd>Lspsaga code_action<CR>' })
    m.nnore({ '<leader>gh', '<Cmd>Lspsaga hover_doc<CR>' })
    m.nnore({ '<leader>gp', '<Cmd>Lspsaga peek_definition<CR>' })
    m.nnore({ '<leader>gs', '<Cmd>Lspsaga lsp_finder<CR>' })
    m.nnore({ '<leader>go', '<Cmd>Lspsaga outline<CR>' })

    m.nore({ '<leader>of', vim.lsp.buf.format })
    m.nnore({ '<leader>od', vim.diagnostic.setloclist })
    m.nnore({ '<leader>oi', vim.diagnostic.open_float })
    local opts = { severity = vim.diagnostic.severity.ERROR }
    m.nnore({ '<leader>oj', function() vim.diagnostic.goto_next(opts) end })
    m.nnore({ '<leader>ok', function() vim.diagnostic.goto_prev(opts) end })
    m.nnore({ '<leader>oJ', vim.diagnostic.goto_next })
    m.nnore({ '<leader>oK', vim.diagnostic.goto_prev })
    -- TODO: list for workspace, sources, servers, commands
    -- m.nnore{'<leader>ow', vim.lsp.buf.manage_workspace_folder}
    -- m.nnore{'<leader>oc', vim.lsp.buf.execute_command}
    m.nnore({ '<leader><leader>o', ':LspStart<Space>' })
    m.nnore({ '<leader>oR', ':LspRestart<CR>' })
    m.nnore({ '<leader>ol', ':LspInfo<CR>' })
    m.nnore({ '<leader>om', ':Mason<CR>' })
    m.nnore({ '<leader>os', ':CmpStatus<CR>' })
    m.nnore({ '<leader>oh', '<Cmd>ClangdSwitchSourceHeader<CR>' })
end

return {
    setup = function()
        if use.nlsp then
            __servers()
            __hl()
            __completion()
            __lsp()
            __mappings()
        end
    end,
}
