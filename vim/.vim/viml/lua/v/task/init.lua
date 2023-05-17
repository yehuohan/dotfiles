local M = {}

-- Task error type
M.Err = {
    Code = 0,
    Find = 1,
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
end

return M
