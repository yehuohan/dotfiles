--- Quickfix output for task

local function get_qfwinid()
    local hwin = vim.fn.getqflist({ winid = 0 }).winid
    if hwin > 0 and vim.api.nvim_win_is_valid(hwin) then
        return hwin
    end
end

local function try_scroll_to_bottom(hwin)
    if hwin then
        local hbuf = vim.api.nvim_win_get_buf(hwin)
        local line_cur = vim.api.nvim_win_get_cursor(hwin)[1]
        local line_num = vim.api.nvim_buf_line_count(hbuf)
        if line_cur + vim.api.nvim_win_get_height(hwin) >= line_num then
            vim.api.nvim_win_set_cursor(hwin, { line_num, 0 })
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
            default = true,
        },
        open = {
            desc = 'Open the quickfix on output',
            type = 'boolean',
            default = false,
        },
        ansi_color = {
            desc = 'Highlight with ansi colors',
            type = 'boolean',
            default = false,
        },
        items_only = {
            desc = 'Only show lines that match the errorformat',
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
            -- Auto save all files before start task
            if params.save then
                vim.cmd.wall()
            end
            self.ansior = require('v.libv').new_ansior({ keep_ansi_color = params.ansi_color })
        end

        comp.on_reset = function(self, task)
            self.start_time = nil
            self.ansior = require('v.libv').new_ansior({ keep_ansi_color = params.ansi_color })
        end

        comp.on_start = function(self, task)
            self.start_time = os.time()
            if params.open and (not get_qfwinid()) then
                vim.cmd([[botright copen 8]])
                vim.cmd.wincmd('p')
            end
            vim.fn.setqflist({}, 'r', {
                lines = { string.format('[%s]', task.name) },
            })
        end

        comp.on_complete = function(self, task, status, result)
            local duration = os.time() - self.start_time
            vim.fn.setqflist({}, 'a', {
                lines = { string.format('[Completed in %ss with %s]', duration, status) },
            })
            try_scroll_to_bottom(get_qfwinid())
        end

        comp.on_output = function(self, task, data)
            local lines = self.ansior(data)
            vim.fn.setqflist({}, 'a', {
                lines = lines,
                efm = params.errorformat,
            })
            try_scroll_to_bottom(get_qfwinid())
        end

        -- There's issue of displaying Chinese with strategy = { 'jobstart', use_terminal = false }
        -- comp.on_output_lines = function(self, task, lines)
        --     vim.fn.setqflist({}, 'a', {
        --         lines = lines,
        --         efm = params.errorformat,
        --     })
        --     try_scroll_to_bottom(get_qfwinid())
        -- end

        return comp
    end,
}
