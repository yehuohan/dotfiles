local nlib = require('v.nlib')

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
    if cfg.tout.style == 'job' then
        opts.strategy = { 'jobstart', use_terminal = false }
    else
        opts.strategy = 'terminal'
    end
    cfg.tout[1] = 'on_task_output'
    opts.components = {
        cfg.tout,
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

--- Goto the quickfix item
--- @param qfwin integer Quickfix window handle
function M.qf_goto(qfwin)
    -- Open with absolute file path
    local row = vim.fn.line('.', qfwin)
    local item = vim.fn.getqflist()[row]
    if item.bufnr > 0 then
        vim.api.nvim_set_current_win(vim.fn.win_getid(vim.fn.winnr('#')))
        if not vim.b.sets_large_file then
            vim.cmd.edit({ args = { vim.api.nvim_buf_get_name(item.bufnr) } })
        end
        local pos = { item.lnum, item.col > 0 and (item.col - 1) or 0 }
        vim.api.nvim_win_set_cursor(0, pos)
    end
    vim.fn.setqflist({}, 'a', { idx = row })
end

--- Adapt quickfix output like terminal
--- @param qfwin integer Quickfix window handle
function M.qf_adapt(qfwin)
    vim.api.nvim_win_call(qfwin, function()
        vim.cmd.syntax({ args = { [[match vTaskQF /\m^|| / conceal]] } })
        vim.cmd.syntax({ args = { [[match vTaskQF /\m^|| {{{ / conceal]] } })
        vim.cmd.syntax({ args = { [[match vTaskQF /\m^|| }}} / conceal]] } })
    end)
    vim.api.nvim_set_option_value('number', false, { win = qfwin })
    vim.api.nvim_set_option_value('relativenumber', false, { win = qfwin })
    vim.api.nvim_set_option_value('signcolumn', 'no', { win = qfwin })
end

--- Highlight specified strings from quickfix output
--- @param qfwin integer Quickfix window handle
--- @param texts string[]|nil Text array to highlight
function M.qf_hlstr(qfwin, texts)
    if type(texts) == 'table' then
        vim.api.nvim_win_call(qfwin, function()
            for _, txt in ipairs(texts) do
                local etxt = vim.fn.escape(txt, [[/\]])
                vim.cmd.syntax({ args = { ([[match IncSearch /\V\c%s/]]):format(etxt) } })
            end
        end)
    end
end

--- Setup quickfix window for task result
local function setup_quickfix()
    vim.api.nvim_create_autocmd('BufWinEnter', {
        group = 'v.Task',
        callback = function(args)
            local qf = vim.fn.getqflist({ winid = 1, qfbufnr = 1, title = 1, context = 1 })
            if qf.qfbufnr ~= args.buf then
                return
            end
            nlib.m.nnore({ '<CR>', function() M.qf_goto(qf.winid) end, buffer = qf.qfbufnr })
            if (qf.winid > 0) and vim.api.nvim_win_is_valid(qf.winid) then
                M.qf_adapt(qf.winid)
                if qf.title == M.title.Fzer then
                    M.qf_hlstr(qf.winid, qf.context.hltext)
                end
            end
        end,
    })
    vim.api.nvim_set_hl(0, 'QuickFixLine', { bg = '#505050' })
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
        'display_duration',
        'on_output_summarize',
        'on_exit_set_status',
        'on_complete_dispose',
        'unique',
    }
    local opts = {
        -- `overseer.run_template` requires 'jobstart' to get a clean 'on_task_output'
        strategy = { 'jobstart', use_terminal = false },
        templates = { 'builtin' },
        dap = false,
        form = { win_opts = { winblend = 0 } },
        task_list = {
            direction = 'right',
            bindings = {
                ['i'] = 'Edit',
                ['p'] = 'TogglePreview',
                ['o'] = 'OpenQuickFix',
                ['O'] = function() require('overseer.task_list.sidebar').get():run_action('restart') end,
                ['K'] = function() require('overseer.task_list.sidebar').get():run_action('stop') end,
                ['D'] = function() require('overseer.task_list.sidebar').get():run_action('dispose') end,
            },
        },
        component_aliases = {
            default = components,
            default_vscode = components,
        },
    }
    local overseer = require('overseer')
    overseer.setup(opts)

    nlib.m.nnore({
        '<leader>ru',
        function() overseer.run_template({ prompt = 'never' }) end,
        desc = 'Run overseer template without prompt',
    })
    nlib.m.nnore({
        '<leader>rU',
        function() overseer.run_template({ prompt = 'allow' }) end,
        desc = 'Run overseer template with prompt',
    })
    nlib.m.nnore({
        '<leader>rk',
        function()
            local list = overseer.list_tasks()
            if #list > 0 then
                list[#list]:stop()
            end
        end,
        desc = 'Kill the last overseer task',
    })
    nlib.m.nnore({
        '<leader>rK',
        function()
            local list = overseer.list_tasks()
            for _, t in ipairs(list) do
                t:stop()
            end
        end,
        desc = 'Kill all overseer tasks',
    })
    nlib.m.nnore({ '<leader>tk', '<Cmd>OverseerToggle<CR>' })
end

function M.setup()
    -- Setup task commands
    vim.api.nvim_create_user_command('TaskWsc', function() vim.print(M.wsc) end, { nargs = 0 })
    vim.api.nvim_create_user_command(
        'TaskRun',
        function(opts) M.cmd(opts.args, opts.bang) end,
        { bang = true, nargs = 1 }
    )
    nlib.m.nnore({ '<leader><leader>r', ':TaskRun<Space>' })
    nlib.m.nnore({ '<leader><leader>R', ':TaskRun!<Space>' })
    nlib.m.vnore({
        '<leader><leader>r',
        function() vim.api.nvim_feedkeys(':TaskRun ' .. nlib.get_selected(''), 'n', true) end,
        desc = ':RunTask',
    })
    nlib.m.vnore({
        '<leader><leader>R',
        function() vim.api.nvim_feedkeys(':TaskRun! ' .. nlib.get_selected(''), 'n', true) end,
        desc = ':RunTask!',
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

    setup_overseer()
    setup_quickfix()
    require('v.task.code').setup()
    require('v.task.fzer').setup()
end

return M
