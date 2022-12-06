local api = vim.api
local use = vim.fn.SvarUse()
local m = require('v.maps')


local function __servers()
    require('mason').setup{
        install_root_dir = vim.env.DotVimCache .. '/.mason',
        ui = {
            check_outdated_packages_on_open = true,
            border = 'single',
            icons = {
                package_installed = '√',
                package_pending = '●',
                package_uninstalled = '○',
            },
        },
    }
    require('mason-lspconfig').setup{ }
    -- require('mason-lspconfig').setup_handlers{
    --     function(server_name)
    --         require('lspconfig')[server_name].setup{ }
    --     end
    -- }

    local lspconfig = require('lspconfig')
    lspconfig.clangd.setup{ }
    lspconfig.cmake.setup{
        init_options = {
            buildDirectory = '__VBuildOut',
        },
    }
    lspconfig.rust_analyzer.setup{
        settings = {
            ['rust-analyzer'] = {
                updates = {
                    checkOnStartup = false,
                    channel = 'nightly',
                },
                cargo = { allFeatures = true, },
                notifications = { cargoTomlNotFound = false, },
                diagnostics = { disabled = { 'inactive-code' }, },
                procMacro = { enable = true },
            },
        },
    }
    lspconfig.pyright.setup{
        settings = {
            python = {
                analysis = {
                    stubPath = 'typings',
                },
            },
        },
    }
    lspconfig.sumneko_lua.setup{
        settings = {
            Lua = {
                runtime = { version = 'Lua 5.2' }, -- LuaJIT
                workspace = {
                    library = {
                        vim.env.VIMRUNTIME .. '/lua',
                        vim.env.VIMRUNTIME .. '/lua/vim',
                        vim.env.VIMRUNTIME .. '/lua/vim/lsp',
                        vim.env.VIMRUNTIME .. '/lua/vim/treesitter',
                    }
                },
                telemetry = { enable = false },
            },
        },
    }
    lspconfig.vimls.setup{ }
    -- lspconfig.ltex.setup{ }

    m.nnore{'<leader>om', ':Mason<CR>'}
end

local kind_icons = {
    Text          = {'', 'Txt' },
    Method        = {'', 'Meth'},
    Function      = {'', 'Fun' },
    Constructor   = {'', 'CnSt'},
    Field         = {'', 'Fied'},
    Variable      = {'ω', 'Var' },
    Class         = {'ﴯ', 'Cla' },
    Interface     = {'', 'InF' },
    Module        = {'', 'Mod' },
    Property      = {'ﰠ', 'Prop'},
    Unit          = {'', 'Unit'},
    Value         = {'', 'Val' },
    Enum          = {'', 'Enum'},
    Keyword       = {'', 'Key' },
    Snippet       = {'', 'Snip'},
    Color         = {'', 'Clr' },
    File          = {'', 'File'},
    Reference     = {'', 'Ref' },
    Folder        = {'', 'Dir' },
    EnumMember    = {'', 'EnuM'},
    Constant      = {'', 'Cons'},
    Struct        = {'', 'Stru'},
    Event         = {'', 'Evnt'},
    Operator      = {'', 'Oprt'},
    TypeParameter = {'', 'TyPa'},
}

local kind_sources = {
    buffer        = ' Buf',
    nvim_lsp      = ' Lsp',
    nvim_lua      = ' Lua',
    ultisnips     = ' Snp',
    path          = ' Pth',
    calc          = ' Cal',
    latex_symbols = ' Tex',
}

local function cmp_format(entry, vitem)
    local ico = kind_icons[vitem.kind]
    local src = kind_sources[entry.source.name]
    if use.ui.patch then
        vitem.kind = string.format(' %s', ico[1])
    else
        vitem.kind = string.format(' %s', ico[2]:sub(1, 1))
    end
    if string.len(vitem.abbr) > 80 then
        vitem.abbr = string.sub(vitem.abbr, 1, 78) .. ' …'
    end
    vitem.menu = string.format('%4s%s', ico[2], src or '')
    return vitem
end

local function __completion()
    api.nvim_set_hl(0, 'CmpItemMenu', { ctermfg = 175, fg = '#d3869b', italic = true })
    api.nvim_set_hl(0, 'CmpItemAbbrMatch', { ctermfg = 208, fg = '#fe8019' })
    api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { ctermfg = 208, fg = '#fe8019' })
    api.nvim_set_hl(0, 'CmpItemKind', { ctermfg = 142, fg = '#b8bb26' })

    local cmp = require('cmp')
    cmp.setup{
        mapping = {
            ['<M-i>'] = cmp.mapping.complete(),
            ['<M-u>'] = cmp.mapping.complete({
                config = {
                    sources = { { name = 'ultisnips' } }
                }
            }),
            ['<M-e>'] = cmp.mapping.abort(),
            ['<M-j>'] = cmp.mapping.select_next_item(),
            ['<M-k>'] = cmp.mapping.select_prev_item(),
            ['<M-n>'] = cmp.mapping.scroll_docs(4),
            ['<M-m>'] = cmp.mapping.scroll_docs(-4),
            ['<M-f>'] = cmp.mapping.scroll_docs(4),
            ['<M-d>'] = cmp.mapping.scroll_docs(-4),
        },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'nvim_lua' },
            { name = 'ultisnips' },
            { name = 'path' },
            { name = 'calc' },
        }, {
            { name = 'buffer' },
        }),
        window = {
            completion = {
                winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
                col_offset = -2,
                side_padding = 0,
            },
        },
        formatting = {
            fields = { 'kind', 'abbr', 'menu' },
            format = cmp_format,
        },
    }
    cmp.setup.filetype({ 'tex', 'latex', 'markdown', 'restructuredtext', 'text', 'help' }, {
        sources = {
            { name = 'path' },
            { name = 'latex_symbols' },
            -- { name = 'spell' },
            -- { name = 'dictionary' },
        }
    })
    local cmdline_mapping = {
        ['<M-e>'] = cmp.mapping(function() cmp.abort() end, {'c'}),
        ['<M-j>'] = cmp.mapping(function() cmp.select_next_item() end, {'c'}),
        ['<M-k>'] = cmp.mapping(function() cmp.select_prev_item() end, {'c'}),
        ['<Tab>'] = cmp.mapping(function()
            if cmp.visible()
            then cmp.select_next_item()
            else cmp.complete()
            end
        end, {'c'}),
        ['<S-Tab>'] = cmp.mapping(function()
            if cmp.visible()
            then cmp.select_prev_item()
            else cmp.complete()
            end
        end, {'c'}),
    }
    cmp.setup.cmdline('/', {
        mapping = cmdline_mapping,
        sources = { { name = 'buffer' } }
    })
    cmp.setup.cmdline(':', {
        mapping = cmdline_mapping,
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        })
    })

    require('lsp_signature').setup{
        bind = true,
        hint_enable = true,
        hint_prefix = '» ',
        handler_opts = {
            border = 'none',
        },
    }
end

local function __lsp()
    api.nvim_set_hl(0, 'LspSignatureActiveParameter', { link = 'Tag' })
    api.nvim_set_hl(0, 'DiagnosticUnderlineError', { undercurl = true, sp = 'Red'  })
    api.nvim_set_hl(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = 'Orange' })
    api.nvim_set_hl(0, 'DiagnosticUnderlineInfo', { undercurl = true, sp = 'LightBlue' })
    api.nvim_set_hl(0, 'DiagnosticUnderlineHint', { link = 'Comment' })
    if use.ui.patch then
        for name, icon in pairs{
            DiagnosticSignError = '𝙭',
            DiagnosticSignWarn  = '',
            DiagnosticSignInfo  = '►',
            DiagnosticSignHint  = '',
        } do
            vim.fn.sign_define(name, { text = icon, texthl = name, numhl = name })
        end
    end
    vim.diagnostic.config({
        virtual_text = { prefix = '▪' },
    })

    m.inore{'<M-o>', vim.lsp.buf.signature_help}
    m.nnore{'gd', vim.lsp.buf.definition}
    m.nnore{'gD', vim.lsp.buf.declaration}
    m.nnore{'<leader>gd', vim.lsp.buf.definition}
    m.nnore{'<leader>gD', vim.lsp.buf.declaration}
    m.nnore{'<leader>gi', vim.lsp.buf.implementation}
    m.nnore{'<leader>gt', vim.lsp.buf.type_definition}
    m.nnore{'<leader>gr', vim.lsp.buf.references}
    m.nnore{'<leader>gf', function() vim.lsp.buf.code_action({apply = true}) end}
    m.nnore{'<leader>ga', vim.lsp.buf.code_action}
    m.nnore{'<leader>gn', vim.lsp.buf.rename}
    m.nnore{'<leader>gh', vim.lsp.buf.hover}
    m.nore{'<leader>of', vim.lsp.buf.format}
    m.nnore{'<leader>od', vim.diagnostic.setloclist}
    m.nnore{'<leader>oi', vim.diagnostic.open_float}
    m.nnore{'<leader>oj', function() vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR }) end}
    m.nnore{'<leader>ok', function() vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR }) end}
    m.nnore{'<leader>oJ', vim.diagnostic.goto_next}
    m.nnore{'<leader>oK', vim.diagnostic.goto_prev}
    -- TODO: list for workspace, sources, servers, commands
    -- m.nnore{'<leader>ow', vim.lsp.buf.manage_workspace_folder}
    -- m.nnore{'<leader>oc', vim.lsp.buf.execute_command}
    m.nnore{'<leader>oR', ':LspRestart<CR>'}
end

local function setup()
if use.nlsp then
    __servers()
    __completion()
    __lsp()
end
end

return {
    setup = setup
}
