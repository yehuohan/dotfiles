local M = {}

--- Task workspace config
M.wsc = {
    code = {},
    fzer = {},
}

--- Task outputs to highlight at quickfix window
M.hlstr = {}

--- Parse string to table of environment variables
--- @param str(string) Input with format 'VAR0=var0 VAR1=var1'
--- @return (table) Environment table with { VAR0 = 'var0', VAR1 = 'var1' }
function M.str2env(str)
    local env = {}
    for _, seg in ipairs(vim.split(str, '%s+', { trimempty = true })) do
        local var = vim.split(seg, '=', { trimempty = true })
        env[var[1]] = var[2]
    end
    return env
end

--- Repleace command's placeholders
--- @param cmd(string) String command with format 'cmd {arg}'
--- @param rep(table) Replacement with { arg = 'val' }
function M.replace(cmd, rep) return vim.trim(string.gsub(cmd, '{(%w+)}', rep)) end

--- Sequence commands
--- @param cmdlist(table<string>) Command list to join with ' && '
function M.sequence(cmdlist) return table.concat(cmdlist, ' && ') end

--- Run task
--- @param cfg(table) Task config
---     - cmd(string) Task command that includes args
---     - wdir(string) Wording directory
---     - envs(string) Environment variables
---     - qf_xxx 'on_quickfix' params
function M.run(cfg)
    local opts = {}
    opts.cmd = cfg.cmd
    opts.cwd = cfg.wdir
    opts.env = cfg.envs and M.str2env(cfg.envs)
    if not cfg.connect_pty then
        opts.strategy = { 'jobstart', use_terminal = false }
    end
    opts.metadata = { verbose = cfg.verbose }
    opts.components = {
        {
            'on_quickfix',
            errorformat = cfg.efm,
            save = cfg.qf_save,
            open = cfg.qf_open,
            jump = cfg.qf_jump,
            scroll = cfg.qf_scroll,
            append = cfg.qf_append,
            title = cfg.qf_title,
            connect_pty = cfg.connect_pty,
            hl_ansi_sgr = cfg.hl_ansi_sgr,
            out_rawdata = cfg.out_rawdata,
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

function M.setup()
    -- Setup task commands
    vim.api.nvim_create_user_command('TaskWsc', function() vim.print(M.wsc) end, { nargs = 0 })
    vim.api.nvim_create_user_command('TaskRun', function(opts)
        local cfg = {
            cmd = opts.args,
            wdir = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
            qf_save = false,
            qf_open = true,
            qf_jump = false,
            qf_scroll = true,
            qf_append = false,
            qf_title = 'v.task',
            connect_pty = true,
            hl_ansi_sgr = true,
            out_rawdata = false,
            verbose = opts.bang and 'a',
        }
        M.run(cfg)
    end, { bang = true, nargs = 1, complete = 'shellcmd' })
    local m = require('v.libv').m
    m.nnore({ '<leader><leader>r', ':TaskRun<Space>' })
    m.nnore({ '<leader><leader>R', ':TaskRun!<Space>' })
    m.vnore({
        '<leader><leader>r',
        function()
            vim.api.nvim_feedkeys(':TaskRun ' .. require('v.libv').get_selected(''), 'n', true)
        end,
    })
    m.vnore({
        '<leader><leader>R',
        function()
            vim.api.nvim_feedkeys(':TaskRun! ' .. require('v.libv').get_selected(''), 'n', true)
        end,
    })

    -- Save and restore workspace config
    vim.api.nvim_create_augroup('TaskWorkSpace', { clear = true })
    vim.api.nvim_create_autocmd('User', {
        group = 'TaskWorkSpace',
        pattern = 'PopcLayerWksSavePre',
        callback = function() vim.fn['popc#layer#wks#SetSettings'](M.wsc) end,
    })
    vim.api.nvim_create_autocmd('User', {
        group = 'TaskWorkSpace',
        pattern = 'PopcLayerWksLoaded',
        callback = function()
            M.wsc = vim.tbl_deep_extend('force', M.wsc, vim.fn['popc#layer#wks#GetSettings']())
            if M.wsc.fzer.path == '' then
                M.wsc.fzer.path = vim.fn['popc#layer#wks#GetCurrentWks']('root')
            end
            require('v.task.fzer').setwsc(M.wsc.fzer)
        end,
    })

    -- Setup quickfix window
    vim.api.nvim_create_autocmd('BufWinEnter', {
        group = 'TaskWorkSpace',
        callback = function(args)
            local qf = vim.fn.getqflist({ winid = 0, qfbufnr = 0, title = 0 })
            if qf.qfbufnr ~= args.buf then
                return
            end
            if (qf.winid > 0) and vim.api.nvim_win_is_valid(qf.winid) then
                for _, str in ipairs(M.hlstr) do
                    vim.fn.win_execute(
                        qf.winid,
                        ([[syntax match IncSearch /\V\c%s/]]):format(vim.fn.escape(str, '\\/'))
                    )
                end
                vim.fn.win_execute(qf.winid, [[syntax match vTaskOnqf /\m^|| / conceal]])
                vim.fn.win_execute(qf.winid, [[syntax match vTaskOnqf /\m^|| {{{ / conceal]])
                vim.fn.win_execute(qf.winid, [[syntax match vTaskOnqf /\m^|| }}} / conceal]])
                vim.api.nvim_win_set_option(qf.winid, 'number', false)
                vim.api.nvim_win_set_option(qf.winid, 'relativenumber', false)
                vim.api.nvim_win_set_option(qf.winid, 'signcolumn', 'no')
            end
        end,
    })
    vim.api.nvim_set_hl(0, 'QuickFixLine', { bg = '#505050' })

    require('v.task.code').setup()
    require('v.task.fzer').setup()
end

return M
