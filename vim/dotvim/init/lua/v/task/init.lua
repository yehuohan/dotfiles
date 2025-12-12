local nlib = require('v.nlib')
local m = nlib.m

local M = {}

--- @class TaskWorkspace Task workspace config
--- @field code ConfigerSaveable
--- @field fzer ConfigerSaveable

--- @class TaskConfig Task config from a 'Configer'
--- @field cmd string Task command that includes args
--- @field wdir string Wording directory
--- @field envs string Environment variables
--- @field tout TaskOutputConfig

--- @class TaskOutputConfig
--- @field efm string|nil
--- @field open boolean
--- @field jump boolean
--- @field scroll boolean
--- @field append boolean
--- @field hltext string[]|nil
--- @field title string
--- @field style string
--- @field encoding string
--- @field verbose string|nil

--- @type TaskWorkspace
M.wsc = {
    code = {},
    fzer = {},
}

--- @enum TaskTitle Task title for different task type
M.title = {
    Task = 'v.task',
    Code = 'v.task.code',
    Fzer = 'v.task.fzer',
}

--- Run task
--- @param cfg TaskConfig
function M.run(cfg)
    local opts = {}
    opts.cmd = cfg.cmd
    opts.cwd = cfg.wdir
    opts.env = type(cfg.envs) == 'string' and nlib.u.str2env(cfg.envs) or cfg.envs
    opts.strategy = { 'jobstart', use_terminal = cfg.tout.style ~= 'job' }
    cfg.tout[1] = 'on_task_output'
    opts.components = {
        cfg.tout,
        'on_exit_set_status',
        'on_complete_dispose',
        'unique',
    }

    local overseer = require('overseer')
    local task = overseer.new_task(opts)
    task:start()
end

--- Run task command
function M.cmd(cmd, bang)
    local cfg = {
        cmd = cmd,
        wdir = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        tout = {
            open = true,
            jump = false,
            scroll = true,
            append = false,
            title = M.title.Task,
            style = 'term',
            encoding = '',
            verbose = bang and 'a',
        },
    }
    M.run(cfg)
end

--- Setup task plugin overseer
local function setup_overseer()
    local components = {
        {
            'on_task_output',
            open = true,
            jump = false,
            scroll = true,
            append = false,
            title = M.title.Task,
            style = 'job',
        },
        'on_exit_set_status',
        'on_complete_dispose',
        'unique',
    }
    local opts = {
        dap = false,
        output = { use_terminal = false, preserve_output = false },
        form = { win_opts = { winblend = 0 } },
        task_list = {
            direction = 'right',
            keymaps = {
                ['i'] = { 'keymap.run_action', opts = { action = 'edit' }, desc = 'Edit task' },
                ['o'] = {
                    'keymap.run_action',
                    opts = { action = 'open output in quickfix' },
                    desc = 'Open task output in the quickfix',
                },
                ['<S-o>'] = { 'keymap.run_action', opts = { action = 'restart' }, desc = 'Restart task' },
                ['K'] = { 'keymap.run_action', opts = { action = 'stop' }, desc = 'Stop task' },
                ['D'] = { 'keymap.run_action', opts = { action = 'dispose' }, desc = 'Dispose task' },
            },
        },
        component_aliases = {
            default = components,
            default_vscode = components,
            default_builtin = components,
        },
    }
    local overseer = require('overseer')
    overseer.setup(opts)

    m.nnore({
        '<leader>ru',
        function() overseer.run_task({ disallow_prompt = true }) end,
        desc = 'Run overseer template without prompt',
    })
    m.nnore({
        '<leader>rU',
        function() overseer.run_task({ disallow_prompt = false }) end,
        desc = 'Run overseer template with prompt',
    })
    m.nnore({
        '<leader>rk',
        function()
            local list = overseer.list_tasks()
            if #list > 0 then
                list[1]:stop()
            end
        end,
        desc = 'Kill the last overseer task',
    })
    m.nnore({
        '<leader>rK',
        function()
            local list = overseer.list_tasks()
            for _, t in ipairs(list) do
                t:stop()
            end
        end,
        desc = 'Kill all overseer tasks',
    })
    m.nnore({ '<leader>tk', '<Cmd>OverseerToggle<CR>' })
end

function M.setup()
    -- Setup task commands
    vim.api.nvim_create_user_command('TaskWsc', function() vim.print(M.wsc) end, { nargs = 0 })
    vim.api.nvim_create_user_command(
        'TaskRun',
        function(opts) M.cmd(opts.args, opts.bang) end,
        { bang = true, nargs = 1 }
    )
    m.nnore({ '<leader><leader>r', ':TaskRun<Space>' })
    m.nnore({ '<leader><leader>R', ':TaskRun!<Space>' })
    m.xnore({
        '<leader><leader>r',
        function() vim.api.nvim_feedkeys(':TaskRun ' .. nlib.e.selected(''), 'n', true) end,
        desc = ':RunTask',
    })
    m.xnore({
        '<leader><leader>R',
        function() vim.api.nvim_feedkeys(':TaskRun! ' .. nlib.e.selected(''), 'n', true) end,
        desc = ':RunTask!',
    })

    -- Save and restore workspace config
    vim.api.nvim_create_augroup('v.Task', { clear = true })
    vim.api.nvim_create_autocmd('User', {
        group = 'v.Task',
        pattern = 'PopcWorkspaceSavePre',
        callback = function() require('popc.panel.workspace').cmd_set_userdata(M.wsc) end,
    })
    vim.api.nvim_create_autocmd('User', {
        group = 'v.Task',
        pattern = 'PopcWorkspaceLoaded',
        callback = function()
            M.wsc = vim.tbl_deep_extend('force', M.wsc, require('popc.panel.workspace').cmd_get_userdata())
            if M.wsc.fzer.path == '' then
                M.wsc.fzer.path = require('popc.panel.workspace').cmd_get_wksroot()
            end
            require('v.task.fzer').setwsc(M.wsc.fzer)
        end,
    })

    setup_overseer()
    require('v.task.qfer').setup()
    require('v.task.code').setup()
    require('v.task.fzer').setup()
end

return M
