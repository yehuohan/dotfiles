local pkgs = {
    {
        'yehuohan/hop.nvim',
        config = function()
            require('hop').setup({ match_mappings = { 'zh', 'zh_sc' }, extensions = {} })
            vim.keymap.set('n', 's', '<Cmd>HopChar1MW<CR>', { remap = true })
        end,
    },
    {
        'yehuohan/popc',
        init = function()
            vim.g.Popc_jsonPath = vim.env.DotVimLocal
            vim.g.Popc_useFloatingWin = 1
            vim.g.Popc_useNerdSymbols = 0
            vim.keymap.set('n', '<leader><leader>h', '<Cmd>PopcBuffer<CR>', { noremap = true })
        end,
    },
}

--- Setup the target pkgs to debug
local function setup_pkgs(targets)
    local url = 'https://github.com'
    local bundle = vim.env.DotVimDir .. '/bundle'
    vim.opt.runtimepath:prepend(bundle .. '/lazy.nvim')
    require('lazy').setup(targets, {
        root = bundle,
        defaults = { lazy = false },
        git = { url_format = url .. '/%s.git' },
        install = { missing = false },
        readme = { root = vim.env.DotVimLocal .. '/lazy' },
        performance = { rtp = { reset = false, paths = { vim.env.DotVimInit } } },
    })
end

--- A minimal debug environment
return function(dotvim)
    vim.env.DotVimDir = dotvim
    vim.env.DotVimInit = dotvim .. '/init'
    vim.env.DotVimShare = dotvim .. '/share'
    vim.env.DotVimLocal = dotvim .. '/local'
    vim.g.mapleader = ' '

    setup_pkgs(pkgs)
end
