local nlib = require('v.nlib')
local m = nlib.m

--- @class Qfer
--- @field ns integer Quickfix highlight namespace
--- @field qwin integer|nil Quickfix window handle
--- @field qbuf integer|nil Quickfix buffer handle
--- @field vwin integer|nil The windown handle to view quickfix item
--- @field title TaskTitle|nil
--- @field hltexts string[]|nil

--- @type Qfer
local qfer = {
    ns = vim.api.nvim_create_namespace('v.task.qfer'),
}

--- Fetch the latest quickfix window and buffer handles
function qfer.fetch()
    qfer.qwin = nil
    qfer.qbuf = nil
    local qlst = vim.fn.getqflist({ winid = 1, qfbufnr = 1 })
    if qlst.winid > 0 and vim.api.nvim_win_is_valid(qlst.winid) then
        qfer.qwin = qlst.winid
    end
    if qlst.qfbufnr > 0 and vim.api.nvim_buf_is_valid(qlst.qfbufnr) then
        qfer.qbuf = qlst.qfbufnr
    end
end

--- Open quickfix window
--- @param auto_open boolean|nil
--- @param auto_jump boolean|nil
function qfer.open(auto_open, auto_jump)
    if auto_open then
        if qfer.qwin then
            if auto_jump then
                vim.api.nvim_set_current_win(qfer.qwin)
            end
        else
            vim.cmd.copen({ count = 8, mods = { split = 'botright' } })
            if not auto_jump then
                vim.cmd.wincmd('p')
            end
            qfer.fetch()
        end
    end
end

--- Auto scroll when locate at the end of quickfix window
--- @param dnum integer The number of line to scroll down
function qfer.scroll(dnum)
    if not qfer.qwin then
        return
    end

    local line_cur = vim.api.nvim_win_get_cursor(qfer.qwin)[1]
    local line_num = vim.api.nvim_buf_line_count(qfer.qbuf)
    if qfer.qwin == vim.api.nvim_get_current_win() then
        if line_cur + 1 >= (line_num - dnum) then
            vim.api.nvim_win_set_cursor(qfer.qwin, { line_cur + dnum, 0 })
        end
    else
        vim.api.nvim_win_set_cursor(qfer.qwin, { line_num, 0 })
    end
end

--- Change quickfix cwd
function qfer.lcd(cwd)
    if qfer.qwin then
        vim.api.nvim_win_call(qfer.qwin, function() vim.cmd.lcd({ args = { cwd } }) end)
    end
end

--- Add quickfix highlight
--- Only works when quickfix buffer is valid
function qfer.add_hl(hl, line, cs, ce)
    vim.api.nvim_buf_set_extmark(
        qfer.qbuf,
        qfer.ns,
        line + 1, -- '+1' for block head line
        cs + 3, -- '+3' for offset form '|| '
        { end_col = ce + 3, hl_group = hl }
    )
end

--- Clear quickfix namespace
function qfer.clear_ns()
    if qfer.qwin then
        vim.api.nvim_buf_clear_namespace(qfer.qbuf, qfer.ns, 0, -1)
    end
end

--- Begin block with a head line
--- @param line string Block head line
--- @param line_hl string Block head line highlight
--- @param append boolean|nil Append head line or not
function qfer.begin_block(line, line_hl, append)
    if not append then
        qfer.clear_ns()
    end

    local msg = string.format('{{{ [%s] %s', os.date('%H:%M:%S'), line)
    vim.fn.setqflist({}, append and 'a' or 'r', {
        lines = { msg },
        efm = ' ', -- Avoid match time string
    })
    if qfer.qbuf then
        local row = vim.api.nvim_buf_line_count(qfer.qbuf) - 1
        qfer.add_hl('Constant', row - 1, 5, 13)
        qfer.add_hl(line_hl, row - 1, 15, string.len(msg))
    end
end

--- End block with a tail line
--- @param line string Block tail line
--- @param line_hl string Block head tail highlight
function qfer.end_block(line, line_hl)
    local msg = string.format('}}} [%s] %s', os.date('%H:%M:%S'), line)
    vim.fn.setqflist({}, 'a', {
        lines = { msg },
        efm = ' ', -- Avoid match time string
    })
    if qfer.qbuf then
        local row = vim.api.nvim_buf_line_count(qfer.qbuf) - 1
        qfer.add_hl('Constant', row - 1, 5, 13)
        qfer.add_hl(line_hl, row - 1, 15, string.len(msg))
    end

    if qfer.qwin then
        vim.wo[qfer.qwin].foldmethod = 'marker'
        vim.wo[qfer.qwin].foldmarker = '{{{,}}}'
        vim.fn.win_execute(qfer.qwin, 'silent! normal! zO')
    end
end

--- Append quickfix lines
function qfer.add_lines(lines, highlights, efm, encoding)
    if encoding ~= '' then
        for k, _ in ipairs(lines) do
            lines[k] = vim.iconv(lines[k], encoding, vim.o.encoding)
        end
    end
    vim.fn.setqflist({}, 'a', {
        lines = lines,
        efm = efm,
    })
    if qfer.qbuf then
        for _, hls in ipairs(highlights) do
            for _, hl in ipairs(hls) do
                qfer.add_hl(unpack(hl))
            end
        end
    end
end

--- Jump to the quickfix item with absolute file path
--- Only works inside quickfix window
function qfer.jump()
    local row = vim.fn.line('.', qfer.qwin)
    local item = vim.fn.getqflist()[row]
    if item.bufnr > 0 then
        vim.api.nvim_set_current_win(vim.fn.win_getid(vim.fn.winnr('#')))
        if item.bufnr ~= vim.api.nvim_get_current_buf() then -- Avoid empty undo
            vim.cmd.edit({ args = { vim.api.nvim_buf_get_name(item.bufnr) } })
        end
        vim.api.nvim_win_set_cursor(0, { item.lnum, item.col > 0 and (item.col - 1) or 0 })
    end
    vim.fn.setqflist({}, 'a', { idx = row })
end

--- View content of current quickfix item
--- Only works inside quickfix window
function qfer.view()
    local row = vim.fn.line('.', qfer.qwin)
    local item = vim.fn.getqflist()[row]
    if item.bufnr > 0 then
        if qfer.vwin and vim.api.nvim_win_is_valid(qfer.vwin) then
            local cur = vim.api.nvim_win_get_cursor(qfer.vwin)
            if cur[1] == item.lnum and cur[2] == item.col - 1 then
                qfer.close_view()
            else
                -- Switch buffer
                vim.api.nvim_win_set_buf(qfer.vwin, item.bufnr)
                vim.api.nvim_win_set_cursor(qfer.vwin, { item.lnum, item.col > 0 and (item.col - 1) or 0 })
            end
        else
            -- Create view
            local qhei = vim.fn.winheight(qfer.qwin)
            qfer.vwin = vim.api.nvim_open_win(item.bufnr, false, {
                relative = 'win',
                win = qfer.qwin,
                anchor = 'SW',
                width = vim.o.columns,
                height = math.min(vim.o.lines - qhei - 6, 16),
                col = 0,
                row = -1,
            })
            vim.wo[qfer.vwin].winblend = 10
            vim.api.nvim_win_set_cursor(qfer.vwin, { item.lnum, item.col > 0 and (item.col - 1) or 0 })
        end
    else
        qfer.close_view()
    end
end

--- Close the view window
function qfer.close_view()
    if qfer.vwin and vim.api.nvim_win_is_valid(qfer.vwin) then
        vim.api.nvim_win_close(qfer.vwin, false)
        qfer.vwin = nil
    end
end

--- For BufWinEnter
function qfer.enter(args)
    qfer.fetch()
    if qfer.qbuf ~= args.buf then
        return
    end

    --- Make quikfix output like terminal
    local opts = { conceal = true, window = qfer.qwin }
    vim.wo[qfer.qwin].number = false
    vim.wo[qfer.qwin].relativenumber = false
    vim.wo[qfer.qwin].signcolumn = 'no'
    vim.fn.matchadd('Conceal', [[\m^|| ]], 99, -1, opts)
    vim.fn.matchadd('Conceal', [[\m^|| {{{ ]], 99, -1, opts)
    vim.fn.matchadd('Conceal', [[\m^|| }}} ]], 99, -1, opts)
    if qfer.title == require('v.task').title.Fzer then
        if qfer.hltexts then
            for _, txt in ipairs(qfer.hltexts) do
                local pat = '\\V\\c' .. vim.fn.escape(txt, [[/\]])
                vim.fn.matchadd('IncSearch', pat, 99, -1, { window = qfer.qwin })
            end
        end
    end

    m.nnore({ 'p', qfer.view, buffer = qfer.qbuf })
    m.nnore({ '<CR>', qfer.jump, buffer = qfer.qbuf })
end

--- For WinLeave
function qfer.leave(args)
    qfer.fetch()
    if qfer.qbuf == args.buf then
        qfer.close_view()
    end
end

local M = {}

--- @return Qfer
function M.setup()
    vim.api.nvim_create_autocmd('BufWinEnter', { group = 'v.Task', callback = qfer.enter })
    vim.api.nvim_create_autocmd('WinLeave', { group = 'v.Task', callback = qfer.leave })
    vim.api.nvim_set_hl(0, 'QuickFixLine', { bg = '#505050' })
    return qfer
end

--- @return Qfer
function M.get() return qfer end

return M
