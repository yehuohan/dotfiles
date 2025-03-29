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

--- @class TaskQuickfix Better quickfix for task
--- @field hwin integer|nil The view window handle

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

--- @type TaskQuickfix
local _qf = { hwin = nil }
M.qf = _qf

--- For BufWinEnter
function _qf.enter(args)
    local qf = vim.fn.getqflist({ winid = 1, qfbufnr = 1, title = 1, context = 1 })
    if qf.qfbufnr ~= args.buf then
        return
    end
    nlib.m.nnore({ 'p', function() _qf.view(qf.winid) end, buffer = qf.qfbufnr })
    nlib.m.nnore({ '<CR>', function() _qf.jump(qf.winid) end, buffer = qf.qfbufnr })
    if (qf.winid > 0) and vim.api.nvim_win_is_valid(qf.winid) then
        _qf.adapt(qf.winid)
        if qf.title == M.title.Fzer then
            _qf.hlstr(qf.winid, qf.context.hltext)
        end
    end
end

--- For WinLeave
function _qf.leave(args)
    local qf = vim.fn.getqflist({ qfbufnr = 1 })
    if qf.qfbufnr == args.buf then
        if _qf.hwin and vim.api.nvim_win_is_valid(_qf.hwin) then
            vim.api.nvim_win_close(_qf.hwin, false)
            _qf.hwin = nil
        end
    end
end

--- View content of current quickfix item
--- @param qfwin integer Quickfix window handle
function _qf.view(qfwin)
    local row = vim.fn.line('.', qfwin)
    local item = vim.fn.getqflist()[row]
    if item.bufnr > 0 then
        if _qf.hwin and vim.api.nvim_win_is_valid(_qf.hwin) then
            local cur = vim.api.nvim_win_get_cursor(_qf.hwin)
            if cur[1] == item.lnum and cur[2] == item.col - 1 then
                -- Toggle view
                vim.api.nvim_win_close(_qf.hwin, false)
                _qf.hwin = nil
            else
                -- Switch buffer
                vim.api.nvim_win_set_buf(_qf.hwin, item.bufnr)
                vim.api.nvim_win_set_cursor(_qf.hwin, { item.lnum, item.col - 1 })
            end
        else
            -- Create view
            local qfwin_hei = vim.fn.winheight(qfwin)
            _qf.hwin = vim.api.nvim_open_win(item.bufnr, false, {
                relative = 'win',
                win = qfwin,
                anchor = 'SW',
                width = vim.o.columns,
                height = math.min(vim.o.lines - qfwin_hei - 6, 16),
                col = 0,
                row = -1,
                border = 'single',
            })
            vim.wo[_qf.hwin].winblend = 10
            vim.wo[_qf.hwin].winhighlight = 'NormalFloat:Normal,FloatBorder:Normal'
            vim.api.nvim_win_set_cursor(_qf.hwin, { item.lnum, item.col - 1 })
        end
    else
        -- Close view
        if _qf.hwin and vim.api.nvim_win_is_valid(_qf.hwin) then
            vim.api.nvim_win_close(_qf.hwin, false)
            _qf.hwin = nil
        end
    end
end

--- jump to the quickfix item
--- @param qfwin integer Quickfix window handle
function _qf.jump(qfwin)
    -- Open with absolute file path
    local row = vim.fn.line('.', qfwin)
    local item = vim.fn.getqflist()[row]
    if item.bufnr > 0 then
        vim.api.nvim_set_current_win(vim.fn.win_getid(vim.fn.winnr('#')))
        vim.cmd.edit({ args = { vim.api.nvim_buf_get_name(item.bufnr) } })
        local pos = { item.lnum, item.col > 0 and (item.col - 1) or 0 }
        vim.api.nvim_win_set_cursor(0, pos)
    end
    vim.fn.setqflist({}, 'a', { idx = row })
end

--- Adapt quickfix output like terminal
--- @param qfwin integer Quickfix window handle
function _qf.adapt(qfwin)
    vim.api.nvim_win_call(qfwin, function()
        vim.cmd.syntax({ args = { [[match vTaskQF /\m^|| / conceal]] } })
        vim.cmd.syntax({ args = { [[match vTaskQF /\m^|| {{{ / conceal]] } })
        vim.cmd.syntax({ args = { [[match vTaskQF /\m^|| }}} / conceal]] } })
    end)
    vim.wo[qfwin].number = false
    vim.wo[qfwin].relativenumber = false
    vim.wo[qfwin].signcolumn = 'no'
end

--- Highlight specified strings from quickfix output
--- @param qfwin integer Quickfix window handle
--- @param texts string[]|nil Text array to highlight
function _qf.hlstr(qfwin, texts)
    if type(texts) == 'table' then
        vim.api.nvim_win_call(qfwin, function()
            for _, txt in ipairs(texts) do
                local etxt = vim.fn.escape(txt, [[/\]])
                vim.cmd.syntax({ args = { ([[match IncSearch /\V\c%s/]]):format(etxt) } })
            end
        end)
    end
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
        function() vim.api.nvim_feedkeys(':TaskRun ' .. nlib.e.selected(''), 'n', true) end,
        desc = ':RunTask',
    })
    nlib.m.vnore({
        '<leader><leader>R',
        function() vim.api.nvim_feedkeys(':TaskRun! ' .. nlib.e.selected(''), 'n', true) end,
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

    -- Setup quickfix window for task result
    vim.api.nvim_create_autocmd('BufWinEnter', { group = 'v.Task', callback = _qf.enter })
    vim.api.nvim_create_autocmd('WinLeave', { group = 'v.Task', callback = _qf.leave })
    vim.api.nvim_set_hl(0, 'QuickFixLine', { bg = '#505050' })

    setup_overseer()
    require('v.task.code').setup()
    require('v.task.fzer').setup()
end

return M
