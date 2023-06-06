--- Quickfix output for task

local function get_qfwinid()
    local hwin = vim.fn.getqflist({ winid = 0 }).winid
    if hwin > 0 and vim.api.nvim_win_is_valid(hwin) then
        return hwin
    end
end

local function try_scroll_to_bottom(hwin, auto_scroll, dnum)
    if hwin then
        local hbuf = vim.api.nvim_win_get_buf(hwin)
        local line_cur = vim.api.nvim_win_get_cursor(hwin)[1]
        local line_num = vim.api.nvim_buf_line_count(hbuf)

        if hwin == vim.api.nvim_get_current_win() then
            if line_cur + 1 >= (line_num - dnum) then
                vim.api.nvim_win_set_cursor(hwin, { line_cur + dnum, 0 })
            end
        else
            if auto_scroll then
                vim.api.nvim_win_set_cursor(hwin, { line_num, 0 })
            end
        end
    end
end

local function try_copen(hwin, open, jump)
    if open then
        if hwin then
            if jump then
                vim.api.nvim_set_current_win(hwin)
            end
        else
            vim.cmd([[botright copen 8]])
            if not jump then
                vim.cmd.wincmd('p')
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
            desc = 'Open the quickfix on output',
            type = 'boolean',
            default = false,
        },
        jump = {
            desc = 'Jump to quickfix window',
            type = 'boolean',
            default = false,
        },
        scroll = {
            desc = 'Auto scroll quickfix window to bottom when not focused',
            type = 'boolean',
            default = false,
        },
        connect_pty = {
            desc = 'Connect to PTY when running task',
            type = 'boolean',
            default = false,
        },
        out_rawdata = {
            desc = 'Output raw data from stdout',
            type = 'boolean',
            default = false,
        },
        out_rawline = {
            desc = 'Output raw lines processed from stdout data',
            type = 'boolean',
            default = false,
        },
        hl_ansi_sgr = {
            desc = 'Highlight ANSI color with SGR when connect_pty is enabled',
            type = 'boolean',
            default = false,
        },
    },
    constructor = function(params)
        local comp = {
            start_time = nil,
            ansior = nil,
        }

        comp.on_init = function(self, task)
            self.ansior = require('v.libv').new_ansior({
                connect_pty = params.connect_pty,
                out_rawline = params.out_rawline,
                hl_ansi_sgr = params.hl_ansi_sgr,
            })
        end

        comp.on_start = function(self, task)
            if params.save then
                vim.cmd.wall() -- Auto save all files before start task
            end
            self.start_time = os.time()
            try_copen(get_qfwinid(), params.open, params.jump)
            vim.fn.setqflist({}, 'r', {
                lines = { string.format('[%s]', task.name) },
            })
        end

        comp.on_complete = function(self, task, status, result)
            local duration = os.time() - self.start_time
            local lines = params.out_rawdata and {} or self.ansior()
            lines[#lines + 1] = string.format('[Completed in %ss with %s]', duration, status)
            vim.fn.setqflist({}, 'a', {
                lines = lines,
                efm = params.errorformat,
            })
            try_scroll_to_bottom(get_qfwinid(), params.scroll, #lines)
        end

        comp.on_output = function(self, task, data)
            local lines = params.out_rawdata and data or self.ansior(data)
            vim.fn.setqflist({}, 'a', {
                lines = lines,
                efm = params.errorformat,
            })
            try_scroll_to_bottom(get_qfwinid(), params.scroll, #lines)
        end

        return comp
    end,
}
