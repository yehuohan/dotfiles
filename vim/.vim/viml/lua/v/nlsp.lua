local use = vim.fn.SvarUse()
local nnoremap = require('v.maps').nnoremap
local vnoremap = require('v.maps').vnoremap
local inoremap = require('v.maps').inoremap


-- server settings
local function __mason()
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
        ['rust-analyzer'] = {
            updates = {
                checkOnStartup = false,
                channel = 'nightly',
            },
            cargo = { allFeatures = true, },
            notifications = { cargoTomlNotFound = false, },
            diagnostics = { disabled = {'inactive-code'}, },
            procMacro = { enable = true, },
        },
    }
    lspconfig.pyright.setup{
        python = {
            analysis = {
                stubPath = 'typings',
            },
        },
    }
    lspconfig.sumneko_lua.setup{ }
    lspconfig.vimls.setup{ }
    -- lspconfig.ltex.setup{ }
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

local kind_texts = {
    buffer        = 'Buf',
    nvim_lsp      = 'Lsp',
    ultisnips     = 'Snp',
    nvim_lua      = 'Lua',
    latex_symbols = 'Tex',
}

-- completion settings
local function __cmp()
    vim.api.nvim_set_hl(0, 'CmpItemMenu', { ctermfg = 175, fg = '#d3869b', italic = true })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { ctermfg = 208, fg = '#fe8019' })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { ctermfg = 208, fg = '#fe8019' })
    vim.api.nvim_set_hl(0, 'CmpItemKind', { ctermfg = 142, fg = '#b8bb26' })

    local cmp = require('cmp')
    cmp.setup{
        mapping = {
            ['<M-i>'] = cmp.mapping(function()
                if cmp.visible()
                then cmp.abort()
                else cmp.complete()
                end
            end, {'i'}),
            ['<M-j>'] = cmp.mapping.select_next_item(),
            ['<M-k>'] = cmp.mapping.select_prev_item(),
            ['<M-n>'] = cmp.mapping.scroll_docs(4),
            ['<M-m>'] = cmp.mapping.scroll_docs(-4),
            ['<M-f>'] = cmp.mapping.scroll_docs(4),
            ['<M-d>'] = cmp.mapping.scroll_docs(-4),
        },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'ultisnips' },
            { name = 'path' },
            -- { name = 'nvim_lua' },
            -- { name = 'dictionary' },
            -- { name = 'latex_symbols' },
            -- { name = 'nvim_lsp_signature_help' },
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
            format = function(entry, vitem)
                local ico = kind_icons[vitem.kind]
                local txt = kind_texts[entry.source.name]
                vitem.kind = string.format(' %s', ico[1])
                if string.len(vitem.abbr) > 80 then
                    vitem.abbr = string.sub(vitem.abbr, 1, 78) .. ' …'
                end
                if txt then
                    vitem.menu = string.format('%4s %3s', ico[2], txt)
                else
                    vitem.menu = string.format('%4s', ico[2])
                end
                return vitem
            end
        },
    }
    cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' }
        }
    })
    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        })
    })


    vim.diagnostic.config({
        virtual_text = { prefix = '▪' },
    })

    inoremap{     '<M-o>', vim.lsp.buf.signature_help}
    nnoremap{        'gd', vim.lsp.buf.definition}
    nnoremap{        'gD', vim.lsp.buf.declaration}
    nnoremap{'<leader>gd', vim.lsp.buf.definition}
    nnoremap{'<leader>gD', vim.lsp.buf.declaration}
    nnoremap{'<leader>gi', vim.lsp.buf.implementation}
    nnoremap{'<leader>gt', vim.lsp.buf.type_definition}
    nnoremap{'<leader>gr', vim.lsp.buf.references}
    nnoremap{'<leader>gf', function() vim.lsp.buf.code_action({apply = true}) end}
    nnoremap{'<leader>ga', vim.lsp.buf.code_action}
    nnoremap{'<leader>gn', vim.lsp.buf.rename}
    nnoremap{'<leader>gh', vim.lsp.buf.hover}
    -- nnoremap{'<leader>gj', vim.lsp.buf.jump_float}
    -- nnoremap{'<leader>gc', vim.lsp.buf.clear_float}
    nnoremap{'<leader>of', vim.lsp.buf.format}
    vnoremap{'<leader>of', vim.lsp.buf.format}
    nnoremap{'<leader>oj', function() vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR }) end}
    nnoremap{'<leader>ok', function() vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR }) end}
    nnoremap{'<leader>oJ', vim.diagnostic.goto_next}
    nnoremap{'<leader>oK', vim.diagnostic.goto_prev}
    nnoremap{'<leader>oi', vim.diagnostic.open_float}
    -- nnoremap{'<leader>od', vim.diagnostic.toggle}
    -- nnoremap{'<leader>ow', vim.lsp.buf.manage_workspace_folder}
    -- nnoremap{'<leader>oc', vim.lsp.buf.execute_command}
    -- vim.diagnostic.setloclist()
    nnoremap{'<leader>om', ':Mason<CR>'}
end

local function nlsp_setup()
if use.nlsp then
    __mason()
    __cmp()
end
end

return {
    setup = nlsp_setup
}
