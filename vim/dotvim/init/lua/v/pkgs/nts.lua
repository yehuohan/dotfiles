local use = require('v.use')
local m = require('v.nlib').m

local function pkg_nts()
    if vim.fn.empty(use.xgit) == 0 then
        for _, c in pairs(require('nvim-treesitter.parsers').get_parser_configs()) do
            c.install_info.url = c.install_info.url:gsub('https://github.com', use.xgit)
        end
    end
    local parser_dir = vim.env.DotVimLocal .. '/.treesitter'
    require('nvim-treesitter.configs').setup({
        parser_install_dir = parser_dir,
        --neovim's builtin: { 'bash', 'c', 'vim', 'lua', 'python', 'markdown', 'markdown_inline' },
        --ensure_installed = { 'cpp', 'rust', 'cmake', 'glsl', 'hlsl', 'wgsl', 'json', 'jsonc' },
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
                init_selection = '<M-g>',
                node_incremental = '<M-g>',
                node_decremental = '<M-a>',
                scope_incremental = '<M-q>',
            },
        },
        matchup = { enable = true },
    })
    vim.opt.runtimepath:prepend(parser_dir)
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
end

return {
    'nvim-treesitter/nvim-treesitter',
    cond = use.nts,
    version = '*',
    config = pkg_nts,
    event = 'VeryLazy',
}
