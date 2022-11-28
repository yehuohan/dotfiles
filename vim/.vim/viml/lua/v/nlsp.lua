local use = vim.fn.SvarUse()
local nnoremap = require('v.maps').nnoremap
local vnoremap = require('v.maps').vnoremap
local inoremap = require('v.maps').inoremap


local function nlsp_setup()
if use.nlsp then
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
    lspconfig.ltex.setup{ }

    local cmp = require('cmp')
    vim.api.nvim_set_hl(0, 'CmpItemMenu', { link='Comment' })
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
        }, {
            { name = 'buffer' },
        }),
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
    nnoremap{'<leader>om', ':Mason<CR>'}
end
end

return {
    setup = nlsp_setup
}
