local M = {}

-- Task workspace config
M.wsc = {
    root = '',
    code = {},
    find = {},
}

-- Repleace command's placeholders
function M.replace(cmd, rep)
    return vim.trim(string.gsub(cmd, '{(%w+)}', rep))
end

-- Sequence commands
function M.sequence(cmdlist)
    return table.concat(cmdlist, ' && ')
end

function M.run(opts)
    local overseer = require('overseer')
    local task = overseer.new_task(opts)
    task:start()
end

function M.setup()
    require('v.task.code').setup()
    require('v.task.find').setup()

    local m = require('v.maps')
    m.nnore({ '<leader>tk', '<Cmd>OverseerToggle<CR>' })

    -- vim.api.nvim_create_augroup('TaskWorkSpace', { clear = true })
    -- vim.api.nvim_create_autocmd('User', {
    --     pattern = 'PopcLayerWksSavePre',
    --     callback = function()
    --         vim.fn['popc#layer#wks#SetSettings'](M.wsc)
    --     end,
    --     group = 'TaskWorkSpace',
    -- })
    -- vim.api.nvim_create_autocmd('User', {
    --     pattern = 'PopcLayerWksLoaded',
    --     callback = function()
    --         M.wsc = vim.tbl_deep_extend('force', M.wsc, vim.fn['popc#layer#wks#GetSettings']())
    --     end,
    --     group = 'TaskWorkSpace',
    -- })
end

return M
