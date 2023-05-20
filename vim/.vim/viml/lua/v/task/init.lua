local M = {}

-- Task error type
M.Err = {
    Init = 1,
    Code = 2,
    Find = 3,
}

-- Task workspace config
M.wsc = {
    root = '',
    code = {},
    find = {},
}

function M.run(opts)
    local overseer = require('overseer')
    local task = overseer.new_task(opts)
    task:start()
end

function M.setup()
    require('v.task.code').setup()
    require('v.task.find').setup()

    local m = require('v.maps')
    m.nnore({ '<leader>to', '<Cmd>OverseerToggle<CR>' })

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
