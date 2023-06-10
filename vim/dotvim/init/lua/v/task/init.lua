local M = {}

--- Task workspace config
M.wsc = {
    root = '',
    code = {},
    fzer = {},
}

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
    opts.env = M.str2env(cfg.envs)
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
    require('v.task.code').setup()
    require('v.task.fzer').setup()
    vim.api.nvim_create_user_command('TaskWsc', function() vim.print(M.wsc) end, { nargs = 0 })

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
