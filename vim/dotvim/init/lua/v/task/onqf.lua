--- Quickfix output for task

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
            vim.cmd([[botright copen 8]])
            if not auto_jump then
                vim.cmd.wincmd('p')
            end
        end
    end
end

local function try_scroll_to_bottom(qf, auto_scroll, dnum)
    if qf.hwin then
        local line_cur = vim.api.nvim_win_get_cursor(qf.hwin)[1]
        local line_num = vim.api.nvim_buf_line_count(qf.hbuf)

        if qf.hwin == vim.api.nvim_get_current_win() then
            if line_cur + 1 >= (line_num - dnum) then
                vim.api.nvim_win_set_cursor(qf.hwin, { line_cur + dnum, 0 })
            end
        else
            if auto_scroll then
                vim.api.nvim_win_set_cursor(qf.hwin, { line_num, 0 })
            end
        end
    end
end

local function setup_window(qf) end

local function display_and_highlight(qf, lines, highlights, ns, efm)
    vim.fn.setqflist({}, 'a', {
        lines = lines,
        efm = efm,
    })
    if qf.hbuf then
        for _, hls in ipairs(highlights) do
            for _, hl in ipairs(hls) do
                vim.api.nvim_buf_add_highlight(
                    qf.hbuf,
                    ns,
                    hl[1],
                    hl[2], -- '+1' for on_start's command line, '-1' for zero-based line
                    hl[3] + 3, -- '+3' for offset form '|| '
                    hl[4] + 3
                )
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
            ns = nil,
        }

        comp.on_init = function(self, task)
            self.ns = vim.api.nvim_create_namespace('v.task.onqf')
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
            local qf = get_qf()
            if qf.hbuf and self.ns then
                vim.api.nvim_buf_clear_namespace(qf.hbuf, self.ns, 0, -1)
            end
            try_copen(qf, params.open, params.jump)
            vim.fn.setqflist({}, 'r', {
                lines = { string.format('[%s]', task.name) },
            })
            self.start_time = os.time()
        end

        comp.on_complete = function(self, task, status, result)
            local duration = os.time() - self.start_time
            local lines, highlights = {}, {}
            if params.out_rawdata then
                lines = {}
            else
                lines, highlights = self.ansior()
            end
            lines[#lines + 1] = string.format('[Completed in %ss with %s]', duration, status)
            local qf = get_qf()
            display_and_highlight(qf, lines, highlights, self.ns, params.errorformat)
            try_scroll_to_bottom(qf, params.scroll, #lines)
        end

        comp.on_output = function(self, task, data)
            local lines, highlights = {}, {}
            if params.out_rawdata then
                lines = data
            else
                lines, highlights = self.ansior(data)
            end
            local qf = get_qf()
            display_and_highlight(qf, lines, highlights, self.ns, params.errorformat)
            try_scroll_to_bottom(qf, params.scroll, #lines)
        end

        return comp
    end,
}
