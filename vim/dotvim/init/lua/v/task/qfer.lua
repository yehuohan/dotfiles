local nlib = require('v.nlib')

--- @class Qfer
--- @field ns integer Quickfix highlight namespace
--- @field qwin integer|nil Quickfix window handle
--- @field qbuf integer|nil Quickfix buffer handle

local Q = {}
Q.__index = Q

--- Re-get quickfix window and buffer handles
function Q:reget()
    self.qwin = nil
    self.qbuf = nil
    local qlst = vim.fn.getqflist({ winid = 0, qfbufnr = 0 })
    if qlst.winid > 0 and vim.api.nvim_win_is_valid(qlst.winid) then
        self.qwin = qlst.winid
    end
    if qlst.qfbufnr > 0 and vim.api.nvim_buf_is_valid(qlst.qfbufnr) then
        self.qbuf = qlst.qfbufnr
    end
end

--- Open quickfix window
function Q:open(auto_open, auto_jump)
    if auto_open then
        if self.qwin then
            if auto_jump then
                vim.api.nvim_set_current_win(self.qwin)
            end
        else
            vim.cmd.copen({ count = 8, mods = { split = 'botright' } })
            if not auto_jump then
                vim.cmd.wincmd('p')
            end
        end
    end
    self:reget()
end

--- Change quickfix cwd
function Q:lcd(cwd)
    if self.qwin then
        vim.api.nvim_win_call(self.qwin, function() vim.cmd.lcd({ args = { cwd } }) end)
    end
end

--- Add quickfix highlight
function Q:highlight(hl, line, cs, ce)
    vim.api.nvim_buf_set_extmark(
        self.qbuf,
        self.ns,
        line,
        cs + 3, -- '+3' for offset form '|| '
        { end_col = ce + 3, hl_group = hl }
    )
end

--- Clear quickfix namespace
function Q:clear_namespace()
    if self.qbuf then
        vim.api.nvim_buf_clear_namespace(self.qbuf, self.ns, 0, -1)
    end
end

function Q:append_lines(lines, highlights, efm)
    vim.fn.setqflist({}, 'a', {
        lines = lines,
        efm = efm,
    })
    if self.qbuf then
        for _, hls in ipairs(highlights) do
            for _, hl in ipairs(hls) do
                self:highlight(hl[1], hl[2], hl[3], hl[4])
            end
        end
    end
end

function Q:begin_block(qfwin, qfbuf, title, context, line, append)
    local msg = string.format('{{{ [%s] %s', os.date('%H:%M:%S'), line)
    vim.fn.setqflist({}, append and 'a' or 'r', {
        lines = { msg },
        efm = ' ', -- Avoid match time string
        title = title,
        context = context,
        -- context = { hltext = params.hltext },
    })
    if qfbuf then
        local row = vim.api.nvim_buf_line_count(qfbuf) - 1
        qf.highlight('Constant', row, 5, 13)

        qf.highlight('Identifier', row, 15, string.len(msg))
    end
    if qfwin and title == require('v.task').title.Fzer then
        _qf.hlstr(qfwin, context)
    end
end

function Q:end_block() end

local function new_qfer(namespace)
    return setmetatable({
        ns = vim.api.nvim_create_namespace(namespace),
        qwin = nil,
        qbuf = nil,
    }, Q)
end

return { new = new_qfer }
