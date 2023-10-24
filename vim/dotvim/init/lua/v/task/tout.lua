--- Display task output into quickfix or terminal

local PAUSE_PATS = {
    '请按任意键继续. . .',
    'Press any key to continue . . .',
}

local function buf_add_highlight(buf, ns, hl, line, cs, ce)
    vim.api.nvim_buf_add_highlight(
        buf,
        ns,
        hl,
        line, -- '+1' for on_start's command line, '-1' for zero-based line
        cs + 3, -- '+3' for offset form '|| '
        ce + 3
    )
end

local function get_qf()
    local qf = {}
    local lst = vim.fn.getqflist({ winid = 0, qfbufnr = 0 })
    if lst.winid > 0 and vim.api.nvim_win_is_valid(lst.winid) then
        qf.hwin = lst.winid
    end
    if lst.qfbufnr > 0 and vim.api.nvim_buf_is_valid(lst.qfbufnr) then
        qf.hbuf = lst.qfbufnr
    end
    return qf
end

local function qf_open(qf, auto_open, auto_jump)
    if auto_open then
        if qf.hwin then
            if auto_jump then
                vim.api.nvim_set_current_win(qf.hwin)
            end
        else
            vim.cmd.copen({ count = 8, mods = { split = 'botright' } })
            if not auto_jump then
                vim.cmd.wincmd('p')
            end
        end
    end
    return get_qf()
end

local function qf_scroll(qf, dnum)
    if not qf.hwin then
        return
    end

    local line_cur = vim.api.nvim_win_get_cursor(qf.hwin)[1]
    local line_num = vim.api.nvim_buf_line_count(qf.hbuf)
    if qf.hwin == vim.api.nvim_get_current_win() then
        if line_cur + 1 >= (line_num - dnum) then
            vim.api.nvim_win_set_cursor(qf.hwin, { line_cur + dnum, 0 })
        end
    else
        vim.api.nvim_win_set_cursor(qf.hwin, { line_num, 0 })
    end
end

local function qf_display(qf, lines, highlights, ns, efm)
    vim.fn.setqflist({}, 'a', {
        lines = lines,
        efm = efm,
    })
    if qf.hbuf then
        for _, hls in ipairs(highlights) do
            for _, hl in ipairs(hls) do
                buf_add_highlight(qf.hbuf, ns, hl[1], hl[2], hl[3], hl[4])
            end
        end
    end
end

--- Redir task output into terminal
local function redir_term(task)
    vim.cmd.split({ range = { 8 } })
    local hwin = vim.api.nvim_get_current_win()
    vim.cmd.wincmd('p')
    vim.api.nvim_win_set_buf(hwin, task:get_bufnr())
    vim.api.nvim_win_set_option(hwin, 'number', false)
    vim.api.nvim_win_set_option(hwin, 'relativenumber', false)
    vim.api.nvim_win_set_option(hwin, 'signcolumn', 'no')
end

--- @class ToutContext of task output
--- @field ns(number) Namespace for highlight
--- @field title(TaskTitle|nil)
--- @field qf_task(table|nil) Task output on quickfix window
local ctx = {
    ns = vim.api.nvim_create_namespace('v.task.tout'),
    title = nil,
    qf_task = nil,
}

--- @class OnTaskOutput
--- @field params(table) Parameters to sync task output
local M = {
    desc = 'Sync task output into the quickfix(default) or terminal',
    params = {
        errorformat = {
            desc = 'See :help errorformat',
            type = 'string',
            optional = true,
            default_from_task = true,
        },
        open = {
            desc = 'Open the quickfix window',
            type = 'boolean',
            default = false,
        },
        jump = {
            desc = 'Jump to quickfix window',
            type = 'boolean',
            default = false,
        },
        scroll = {
            desc = 'Auto scroll quickfix window to bottom',
            type = 'boolean',
            default = false,
        },
        append = {
            desc = 'Append result to quickfix list',
            type = 'boolean',
            default = false,
        },
        title = {
            desc = 'Set quickfix title as a identifier',
            type = 'string',
            default = 'v.task.tout',
        },
        PTY = {
            desc = 'Connect to PTY when running task',
            type = 'boolean',
            default = false,
        },
        SGR = {
            desc = 'Highlight ANSI color with SGR when PTY is enabled',
            type = 'boolean',
            default = false,
        },
        RAW = {
            desc = 'Output raw data from stdout',
            type = 'boolean',
            default = false,
        },
        verbose = {
            desc = 'Output verbose for debug',
            type = 'string',
            default = false,
        },
    },
}

function M.constructor(params)
    local cpt = {
        start_time = nil,
        --- @type Chanor|nil
        chanor = nil,
    }

    local function default_start(task)
        ctx.qf_task = task
        ctx.title = params.title
        cpt.start_time = os.time()

        local qf = qf_open(get_qf(), params.open, params.jump)
        if qf.hwin then
            vim.api.nvim_win_call(qf.hwin, function() vim.cmd.lcd({ args = { task.cwd } }) end)
        end
        if qf.hbuf and ctx.ns and not params.append then
            vim.api.nvim_buf_clear_namespace(qf.hbuf, ctx.ns, 0, -1)
        end

        -- Add head message
        local msg = string.format('{{{ [%s] %s', os.date('%H:%M:%S'), task.name)
        vim.fn.setqflist({}, params.append and 'a' or 'r', {
            lines = { msg },
            efm = ' ', -- Avoid match time string
            title = params.title,
        })
        if qf.hbuf then
            local line = vim.api.nvim_buf_line_count(qf.hbuf) - 1
            buf_add_highlight(qf.hbuf, ctx.ns, 'Constant', line, 5, 13)
            buf_add_highlight(qf.hbuf, ctx.ns, 'Identifier', line, 15, string.len(msg))
        end
    end

    local function default_complete(task, status, result)
        local dt = os.time() - cpt.start_time
        local qf = get_qf()
        local lines, highlights = cpt.chanor()
        qf_display(qf, lines, highlights, ctx.ns, params.errorformat)

        -- Add tail message
        local msg = string.format('}}} [%s] %s in %ds', os.date('%H:%M:%S'), status, dt)
        vim.fn.setqflist({}, 'a', {
            lines = { msg },
            efm = ' ', -- Avoid match time string
        })
        if qf.hbuf then
            local line = vim.api.nvim_buf_line_count(qf.hbuf) - 1
            local hlgrp = 'Overseer' .. status
            buf_add_highlight(qf.hbuf, ctx.ns, 'Constant', line, 5, 13)
            buf_add_highlight(qf.hbuf, ctx.ns, hlgrp, line, 15, string.len(msg))
        end
        if params.scroll then
            qf_scroll(qf, #lines + 1)
        end

        -- Setup fold
        if qf.hwin then
            vim.api.nvim_win_set_option(qf.hwin, 'foldmethod', 'marker')
            vim.api.nvim_win_set_option(qf.hwin, 'foldmarker', '{{{,}}}')
            vim.fn.win_execute(qf.hwin, 'silent! normal! zO')
        end
        ctx.qf_task = nil
    end

    local function default_output(task, data)
        -- React to pause command
        if IsWin() then
            for _, str in ipairs(data) do
                for _, pat in ipairs(PAUSE_PATS) do
                    if str:match(pat) then
                        vim.api.nvim_chan_send(task.strategy.chan_id, ' ')
                    end
                end
            end
        end

        local qf = get_qf()
        local lines, highlights = cpt.chanor(data)
        qf_display(qf, lines, highlights, ctx.ns, params.errorformat)
        if params.scroll then
            qf_scroll(qf, #lines)
        end
    end

    cpt.on_init = function(self, task)
        self.chanor = require('v.libv').new_chanor({
            PTY = params.PTY,
            SGR = params.SGR,
            RAW = params.RAW,
            verbose = params.verbose,
        })
    end

    cpt.on_start = function(self, task)
        if ctx.qf_task then
            local fzer = require('v.task').title.Fzer
            if ctx.title ~= fzer and params.title == fzer then
                redir_term(ctx.qf_task)
                default_start(task)
            else
                redir_term(task)
            end
        else
            default_start(task)
        end
    end

    cpt.on_complete = function(self, task, status, result)
        if ctx.qf_task and ctx.qf_task.id == task.id then
            default_complete(task, status, result)
        end
    end

    cpt.on_output = function(self, task, data)
        if ctx.qf_task and ctx.qf_task.id == task.id then
            default_output(task, data)
        end
    end

    return cpt
end

return M
