local util = require('overseer.util')

local function try_scroll_to_bottom()
    local hwin = vim.fn.getqflist({ winid = 0 }).winid

    if vim.api.nvim_win_is_valid(hwin) then
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
        items_only = {
            desc = 'Only show lines that match the errorformat',
            type = 'boolean',
            default = false,
        },
        set_diagnostics = {
            desc = 'Add the matching items to vim.diagnostics',
            type = 'boolean',
            default = false,
        },
    },
    constructor = function(params)
        local comp = {
            start_time = nil,
        }

        comp.on_init = function(self, task)
            -- Auto save all files before start task
            if params.save then
                vim.cmd.wall()
            end
        end

        comp.on_reset = function(self, task)
            self.start_time = nil
        end

        comp.on_start = function(self, task)
            self.start_time = os.time()
            vim.cmd([[botright copen 8]])
            vim.cmd.wincmd('p')
            vim.fn.setqflist({}, 'r', {
                lines = { string.format('[%s]', task.name) },
            })
        end

        comp.on_complete = function(self, task, status, result)
            self.duration = os.time() - self.start_time
            vim.fn.setqflist({}, 'a', {
                lines = { string.format('[Completed in %ss with %s]', self.duration, status) },
            })
            try_scroll_to_bottom()
        end

        comp.on_output = function(self, task, data)
            -- vim.fn.setqflist({}, 'a', {
            --     lines = data,
            --     efm = params.errorformat,
            -- })
            -- try_scroll_to_bottom()
        end

        comp.on_output_lines = function(self, task, lines)
            vim.fn.setqflist({}, 'a', {
                lines = lines,
                efm = params.errorformat,
            })
            try_scroll_to_bottom()
        end

        return comp
    end,
}
