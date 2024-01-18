local lsp = {
    {
        'hrsh7th/nvim-cmp',
        config = function()
            require('mason').setup({ install_root_dir = vim.env.DotVimLocal .. '/.mason' })
            require('mason-lspconfig').setup({})
            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local opts = {
                function(server_name) lspconfig[server_name].setup({ capabilities = capabilities }) end,
            }
            require('mason-lspconfig').setup_handlers(opts)
            local cmp = require('cmp')
            cmp.setup({
                mapping = {
                    ['<M-i>'] = cmp.mapping(function() cmp.complete() end, { 'i' }),
                    ['<M-j>'] = cmp.mapping(function() cmp.select_next_item() end, { 'i', 'c' }),
                    ['<M-k>'] = cmp.mapping(function() cmp.select_prev_item() end, { 'i', 'c' }),
                },
                sources = cmp.config.sources({ { name = 'nvim_lsp' } }),
                preselect = cmp.PreselectMode.None,
            })
        end,
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'neovim/nvim-lspconfig',
            'hrsh7th/cmp-nvim-lsp',
        },
    },
}

--- Setup the target pkgs to debug
local function setup_pkgs(targets)
    local use = require('v.use')
    local url = 'https://github.com'
    if vim.fn.empty(use.xgit) == 0 then
        url = use.xgit
    end
    local bundle = vim.env.DotVimDir .. '/bundle'
    vim.opt.runtimepath:prepend(bundle .. '/lazy.nvim')
    require('lazy').setup(targets, {
        root = bundle,
        defaults = { lazy = false },
        lockfile = vim.env.DotVimLocal .. '/lazy/lazy-lock.json',
        git = { url_format = url .. '/%s.git' },
        install = { missing = false },
        readme = { root = vim.env.DotVimLocal .. '/lazy/readme' },
        performance = { rtp = { reset = false, paths = { vim.env.DotVimInit } } },
        state = vim.env.DotVimLocal .. '/lazy/state.json',
    })
end

--- A minimal debug environment
return function(dotvim)
    vim.env.DotVimDir = dotvim
    vim.env.DotVimInit = dotvim .. '/init'
    vim.env.DotVimWork = dotvim .. '/work'
    vim.env.DotVimLocal = dotvim .. '/local'
    vim.env.NVimConfigDir = vim.fn.stdpath('config')
    require('v.use').setup()

    setup_pkgs(lsp)
end
