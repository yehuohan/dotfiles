local libv = require('v.libv')

local M = {}

--- @class TaskWorkspace Task workspace config
--- @field code(Configer)
--- @field fzer(Configer)

--- @class TaskConfig Task config
--- @field cmd(string) Task command that includes args
--- @field wdir(string) Wording directory
--- @field envs(string) Environment variables
--- @field tout(TaskOutputConfig)

--- @class TaskOutputConfig
--- @field efm(string)
--- @field open(boolean)
--- @field jump(boolean)
--- @field scroll(boolean)
--- @field append(boolean)
--- @field title(string)
--- @field PTY(boolean)
--- @field SGR(boolean)
--- @field RAW(boolean)
--- @field verbose(string|nil)

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

--- @type table<string> String to highlight from task outputs at quickfix window
M.hlstr = {}

--- Repleace command's placeholders
--- @param cmd(string) String command with format 'cmd {arg}'
--- @param rep(table) Replacement with { arg = 'val' }
function M.replace(cmd, rep) return vim.trim(string.gsub(cmd, '{(%w+)}', rep)) end

--- Sequence commands
--- @param cmdlist(table<string>) Command list to join with ' && '
function M.sequence(cmdlist) return table.concat(cmdlist, ' && ') end

--- Run task
--- @param cfg(TaskConfig)
function M.run(cfg)
    local opts = {}
    opts.cmd = cfg.cmd
    opts.cwd = cfg.wdir
    opts.env = cfg.envs and libv.u.str2env(cfg.envs)
    if not cfg.tout.PTY then
        opts.strategy = { 'jobstart', use_terminal = false }
    end
    opts.components = {
        {
            'on_task_output',
            errorformat = cfg.tout.efm,
            open = cfg.tout.open,
            jump = cfg.tout.jump,
            scroll = cfg.tout.scroll,
            append = cfg.tout.append,
            title = cfg.tout.title,
            PTY = cfg.tout.PTY,
            SGR = cfg.tout.SGR,
            RAW = cfg.tout.RAW,
            verbose = cfg.tout.verbose,
        },
        'display_duration',
        'on_output_summarize',
        'on_exit_set_status',
        'on_complete_dispose',
        'unique',
    }

    local overseer = require('overseer')
    local task = overseer.new_task(opts)
    task:start()
end

--- Run task command
function M.run_cmd(cmd, bang)
    local cfg = {
        cmd = cmd,
        wdir = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        tout = {
            open = true,
            jump = false,
            scroll = true,
            append = false,
            title = M.title.Task,
            PTY = true,
            SGR = true,
            RAW = false,
            verbose = bang and 'a',
        },
    }
    M.run(cfg)
end

--- Setup quickfix window for task result
local function setup_qf()
    vim.api.nvim_create_autocmd('BufWinEnter', {
        group = 'v.Task',
        callback = function(args)
            local qf = vim.fn.getqflist({ winid = 0, qfbufnr = 0, title = 0 })
            if qf.qfbufnr ~= args.buf then
                return
            end
            -- Setup key mappings
            libv.m.nnore({
                '<CR>',
                function()
                    local row = vim.fn.line('.', qf.winid)
                    local item = vim.fn.getqflist()[row]
                    if item.bufnr > 0 then
                        vim.api.nvim_set_current_win(vim.fn.win_getid(vim.fn.winnr('#')))
                        vim.cmd.edit({ args = { vim.api.nvim_buf_get_name(item.bufnr) } })
                        local pos = { item.lnum, item.col > 0 and (item.col - 1) or 0 }
                        vim.api.nvim_win_set_cursor(0, pos)
                    end
                    vim.fn.setqflist({}, 'a', { idx = row })
                end,
                buffer = qf.qfbufnr,
            })
            -- Setup window display
            if (qf.winid > 0) and vim.api.nvim_win_is_valid(qf.winid) then
                vim.api.nvim_win_call(qf.winid, function()
                    for _, str in ipairs(M.hlstr) do
                        local estr = vim.fn.escape(str, '\\/')
                        vim.cmd.syntax({ args = { ([[match IncSearch /\V\c%s/]]):format(estr) } })
                    end
                    vim.cmd.syntax({ args = { [[match vTaskOnqf /\m^|| / conceal]] } })
                    vim.cmd.syntax({ args = { [[match vTaskOnqf /\m^|| {{{ / conceal]] } })
                    vim.cmd.syntax({ args = { [[match vTaskOnqf /\m^|| }}} / conceal]] } })
                end)
                vim.api.nvim_win_set_option(qf.winid, 'number', false)
                vim.api.nvim_win_set_option(qf.winid, 'relativenumber', false)
                vim.api.nvim_win_set_option(qf.winid, 'signcolumn', 'no')
            end
        end,
    })
    vim.api.nvim_set_hl(0, 'QuickFixLine', { bg = '#505050' })
end

function M.setup()
    -- Setup task commands
    vim.api.nvim_create_user_command('TaskWsc', function() vim.print(M.wsc) end, { nargs = 0 })
    vim.api.nvim_create_user_command(
        'TaskRun',
        function(opts) M.run_cmd(opts.args, opts.bang) end,
        { bang = true, nargs = 1 }
    )
    libv.m.nnore({ '<leader><leader>r', ':TaskRun<Space>' })
    libv.m.nnore({ '<leader><leader>R', ':TaskRun!<Space>' })
    libv.m.vnore({
        '<leader><leader>r',
        function() vim.api.nvim_feedkeys(':TaskRun ' .. libv.get_selected(''), 'n', true) end,
    })
    libv.m.vnore({
        '<leader><leader>R',
        function() vim.api.nvim_feedkeys(':TaskRun! ' .. libv.get_selected(''), 'n', true) end,
    })

    -- Save and restore workspace config
    vim.api.nvim_create_augroup('v.Task', { clear = true })
    vim.api.nvim_create_autocmd('User', {
        group = 'v.Task',
        pattern = 'PopcLayerWksSavePre',
        callback = function() vim.fn['popc#layer#wks#SetSettings'](M.wsc) end,
    })
    vim.api.nvim_create_autocmd('User', {
        group = 'v.Task',
        pattern = 'PopcLayerWksLoaded',
        callback = function()
            M.wsc = vim.tbl_deep_extend('force', M.wsc, vim.fn['popc#layer#wks#GetSettings']())
            if M.wsc.fzer.path == '' then
                M.wsc.fzer.path = vim.fn['popc#layer#wks#GetCurrentWks']('root')
            end
            require('v.task.fzer').setwsc(M.wsc.fzer)
        end,
    })

    setup_qf()
    require('v.task.code').setup()
    require('v.task.fzer').setup()
end

return M
