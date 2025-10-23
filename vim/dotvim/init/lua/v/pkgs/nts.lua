local use = require('v.use')
local m = require('v.nlib').m

local function pkg_nts()
    if use.xgit ~= vim.NIL then
        for _, c in pairs(require('nvim-treesitter.parsers').get_parser_configs()) do
            c.install_info.url = c.install_info.url:gsub('https://github.com', use.xgit)
        end
    end
    local parser_dir = vim.env.DotVimLocal .. '/.treesitter'
    local disable = function(_, bufnr) return vim.b[bufnr].sets_large_file == true end
    require('nvim-treesitter.configs').setup({
        parser_install_dir = parser_dir,
        highlight = {
            enable = true,
            disable = disable,
            additional_vim_regex_highlighting = false,
        },
        indent = {
            enable = true,
            disable = disable,
        },
        incremental_selection = {
            enable = true,
            disable = disable,
            keymaps = {
                init_selection = '<M-r>',
                node_incremental = '<M-r>',
                node_decremental = '<M-w>',
                scope_incremental = '<M-q>',
            },
        },
        matchup = {
            enable = true,
            disable = disable,
        },
    })
    vim.opt.runtimepath:prepend(parser_dir)

    m.group_begin('treesitter')
    m.nnore({
        '<leader>sh',
        function()
            vim.cmd.TSBufToggle('highlight')
            local buf = vim.api.nvim_get_current_buf()
            local res = require('vim.treesitter.highlighter').active[buf]
            vim.notify('Treesitter highlight is ' .. (res and 'enabled' or 'disabled'))
        end,
        desc = 'Toggle treesitter highlight',
    })
    m.nnore({
        '<leader>si',
        function()
            vim.cmd.TSBufToggle('indent')
            local res = vim.bo.indentexpr == 'nvim_treesitter#indent()'
            vim.notify('Treesitter indent is ' .. (res and 'enabled' or 'disabled'))
        end,
        desc = 'Toggle treesitter indent',
    })
    m.group_end()
end

return {
    'nvim-treesitter/nvim-treesitter',
    cond = use.nts,
    version = '*',
    config = pkg_nts,
    event = 'VeryLazy',
}
