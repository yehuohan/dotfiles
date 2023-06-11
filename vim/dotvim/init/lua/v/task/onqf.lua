--- Quickfix output for task

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

local function try_copen(qf, auto_open, auto_jump)
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

local function try_scroll_to_bottom(qf, dnum)
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

local function display_and_highlight(qf, lines, highlights, ns, efm)
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

return {
    desc = 'Sync code task output into the quickfix',
    params = {
        errorformat = {
            desc = 'See :help errorformat',
            type = 'string',
            optional = true,
            default_from_task = true,
        },
        save = {
            desc = 'Save all files before start task',
            type = 'boolean',
            default = false,
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
            default = 'v.task.onqf',
        },
        connect_pty = {
            desc = 'Connect to PTY when running task',
            type = 'boolean',
            default = false,
        },
        hl_ansi_sgr = {
            desc = 'Highlight ANSI color with SGR when connect_pty is enabled',
            type = 'boolean',
            default = false,
        },
        out_rawdata = {
            desc = 'Output raw data from stdout',
            type = 'boolean',
            default = false,
        },
    },
    constructor = function(params)
        local comp = {
            start_time = nil,
            chanor = nil,
            ns = nil,
        }

        comp.on_init = function(self, task)
            self.ns = vim.api.nvim_create_namespace('v.task.onqf')
            self.chanor = require('v.libv').new_chanor({
                connect_pty = params.connect_pty,
                hl_ansi_sgr = params.hl_ansi_sgr,
                out_rawdata = params.out_rawdata,
                verbose = task.metadata.verbose,
            })
        end

        comp.on_start = function(self, task)
            self.start_time = os.time()

            if params.save then
                vim.cmd.wall({ mods = { silent = true, emsg_silent = true } })
            end
            local qf = try_copen(get_qf(), params.open, params.jump)
            if qf.hbuf and self.ns and not params.append then
                vim.api.nvim_buf_clear_namespace(qf.hbuf, self.ns, 0, -1)
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
                buf_add_highlight(qf.hbuf, self.ns, 'Constant', line, 5, 13)
                buf_add_highlight(qf.hbuf, self.ns, 'Identifier', line, 15, string.len(msg))
            end
        end

        comp.on_complete = function(self, task, status, result)
            local dt = os.time() - self.start_time
            local qf = get_qf()
            local lines, highlights = self.chanor()
            display_and_highlight(qf, lines, highlights, self.ns, params.errorformat)

            -- Add tail message
            local msg = string.format('}}} [%s] %s in %ds', os.date('%H:%M:%S'), status, dt)
            vim.fn.setqflist({}, 'a', {
                lines = { msg },
                efm = ' ', -- Avoid match time string
            })
            if qf.hbuf then
                local line = vim.api.nvim_buf_line_count(qf.hbuf) - 1
                local hlgrp = (status == 'SUCCESS' and 'Title')
                    or (status == 'CANCELED' and 'MoreMsg')
                    or (status == 'FAILURE' and 'WarningMsg')
                buf_add_highlight(qf.hbuf, self.ns, 'Constant', line, 5, 13)
                buf_add_highlight(qf.hbuf, self.ns, hlgrp, line, 15, string.len(msg))
            end
            if params.scroll then
                try_scroll_to_bottom(qf, #lines + 1)
            end

            -- Setup fold
            if qf.hwin then
                vim.api.nvim_win_set_option(qf.hwin, 'foldmethod', 'marker')
                vim.api.nvim_win_set_option(qf.hwin, 'foldmarker', '{{{,}}}')
                vim.fn.win_execute(qf.hwin, 'silent! normal! zO')
            end
        end

        comp.on_output = function(self, task, data)
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
            local lines, highlights = self.chanor(data)
            display_and_highlight(qf, lines, highlights, self.ns, params.errorformat)
            if params.scroll then
                try_scroll_to_bottom(qf, #lines + 1)
            end
        end

        return comp
    end,
}
