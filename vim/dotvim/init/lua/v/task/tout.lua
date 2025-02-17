--- Display task output into quickfix or terminal

local PAUSE_PATS = {
    '请按任意键继续. . .',
    'Press any key to continue . . .',
    '按 Enter 键继续...:',
    'Press Enter to continue...:',
}

--- @class ToutQuickfix
--- @field ns(integer) Quickfix highlight namespace
--- @field hwin(integer|nil) Quickfix window handle
--- @field hbuf(integer|nil) Quickfix buffer handle
--- @field task(table|nil) The task output to quickfix
--- @field title(TaskTitle|nil)
local qf = {
    ns = vim.api.nvim_create_namespace('v.task.tout'),
    hwin = nil,
    hbuf = nil,
    task = nil,
    title = nil,
}

function qf.get()
    qf.hwin = nil
    qf.hbuf = nil
    local lst = vim.fn.getqflist({ winid = 0, qfbufnr = 0 })
    if lst.winid > 0 and vim.api.nvim_win_is_valid(lst.winid) then
        qf.hwin = lst.winid
    end
    if lst.qfbufnr > 0 and vim.api.nvim_buf_is_valid(lst.qfbufnr) then
        qf.hbuf = lst.qfbufnr
    end
end

function qf.open(auto_open, auto_jump, append)
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

    qf.get()
    if qf.hwin then
        vim.api.nvim_win_call(qf.hwin, function() vim.cmd.lcd({ args = { qf.task.cwd } }) end)
    end
    if qf.hbuf and not append then
        vim.api.nvim_buf_clear_namespace(qf.hbuf, qf.ns, 0, -1)
    end
end

function qf.scroll(dnum)
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

function qf.highlight(hl, line, cs, ce)
    vim.api.nvim_buf_add_highlight(
        qf.hbuf,
        qf.ns,
        hl,
        line, -- '+1' for on_start's command line, '-1' for zero-based line
        cs + 3, -- '+3' for offset form '|| '
        ce + 3
    )
end

function qf.display(lines, highlights, efm, encoding)
    if encoding ~= '' then
        for k, _ in ipairs(lines) do
            lines[k] = vim.iconv(lines[k], encoding, vim.o.encoding)
        end
    end
    vim.fn.setqflist({}, 'a', {
        lines = lines,
        efm = efm,
    })
    if qf.hbuf then
        for _, hls in ipairs(highlights) do
            for _, hl in ipairs(hls) do
                qf.highlight(hl[1], hl[2], hl[3], hl[4])
            end
        end
    end
end

function qf.react(data, chan_id, encoding)
    for _, str in ipairs(data) do
        local txt = str
        if encoding ~= '' then
            txt = vim.iconv(str, encoding, vim.o.encoding)
        end
        -- React to pause command
        if IsWin() then
            for _, pat in ipairs(PAUSE_PATS) do
                if txt and txt:match(pat) then
                    vim.api.nvim_chan_send(chan_id, '\x0D')
                end
            end
        end
    end
end

---@param cpt Tout.Component
---@param params Tout.Params
function qf.on_start(task, cpt, params)
    cpt.start_time = vim.fn.reltime()
    qf.title = params.title
    qf.task = task
    qf.get()
    qf.open(params.open, params.jump, params.append)

    -- Add head message
    local msg = string.format('{{{ [%s] %s', os.date('%H:%M:%S'), task.name)
    vim.fn.setqflist({}, params.append and 'a' or 'r', {
        lines = { msg },
        efm = ' ', -- Avoid match time string
        title = params.title,
        context = { hltext = params.hltext },
    })
    if qf.hbuf then
        local line = vim.api.nvim_buf_line_count(qf.hbuf) - 1
        qf.highlight('Constant', line, 5, 13)
        qf.highlight('Identifier', line, 15, string.len(msg))
    end
    if qf.hwin and params.title == require('v.task').title.Fzer then
        require('v.task').qf_hlstr(qf.hwin, params.hltext)
    end
end

---@param cpt Tout.Component
---@param params Tout.Params
function qf.on_complete(task, status, result, cpt, params)
    local encoding = params.encoding
    local dt = vim.fn.reltimefloat(vim.fn.reltime(cpt.start_time))
    local lines, highlights = cpt.chanor()

    qf.get()
    qf.display(lines, highlights, params.efm, encoding)

    -- Add tail message
    local msg = string.format('}}} [%s] %s in %0.2fs', os.date('%H:%M:%S'), status, dt)
    vim.fn.setqflist({}, 'a', {
        lines = { msg },
        efm = ' ', -- Avoid match time string
    })
    if qf.hbuf then
        local line = vim.api.nvim_buf_line_count(qf.hbuf) - 1
        local hlgrp = 'Overseer' .. status
        qf.highlight('Constant', line, 5, 13)
        qf.highlight(hlgrp, line, 15, string.len(msg))
    end
    if params.scroll then
        qf.scroll(#lines + 1)
    end

    -- Setup fold
    if qf.hwin then
        vim.api.nvim_set_option_value('foldmethod', 'marker', { win = qf.hwin })
        vim.api.nvim_set_option_value('foldmarker', '{{{,}}}', { win = qf.hwin })
        vim.fn.win_execute(qf.hwin, 'silent! normal! zO')
    end
    qf.task = nil
end

---@param cpt Tout.Component
---@param params Tout.Params
function qf.on_output(task, data, cpt, params)
    local encoding = params.encoding
    local chan_id = params.style == 'job' and task.strategy.job_id or task.strategy.chan_id
    qf.react(data, chan_id, encoding)

    local lines, highlights = cpt.chanor(data)
    qf.get()
    qf.display(lines, highlights, params.efm, encoding)
    if params.scroll then
        qf.scroll(#lines)
    end
end

--- @class ToutTerminal
--- @field twin(table<integer,integer>) The pined terminal(vterm) window handle for each tabpage
--- @field task(table|nil) The task output to terminal
local term = {
    -- hwin = nil,
    twin = {},
    task = nil,
}

--- Close the pined window of current tabpage
function term.close()
    local tab = vim.api.nvim_get_current_tabpage()
    if vim.api.nvim_win_is_valid(term.twin[tab]) then
        vim.api.nvim_win_close(term.twin[tab], false)
    end
end

--- @param pin(boolean|nil) Pin task output to the terminal or not
function term.redir(task, pin)
    local tab = vim.api.nvim_get_current_tabpage()
    local hwin
    if pin then
        term.task = task
        if not term.twin[tab] or (not vim.api.nvim_win_is_valid(term.twin[tab])) then
            vim.cmd.split({ range = { 8 }, mods = { split = 'botright' } })
            term.twin[tab] = vim.api.nvim_get_current_win()
            vim.cmd.wincmd('p')
            require('v.nlib').m.nnore({ '<leader>vc', term.close, desc = "Colse tout's terminal" })
        end
        hwin = term.twin[tab]
    else
        vim.cmd.split({ range = { 8 } })
        hwin = vim.api.nvim_get_current_win()
        vim.cmd.wincmd('p')
    end
    vim.api.nvim_win_set_buf(hwin, task:get_bufnr())
    vim.api.nvim_set_option_value('number', false, { win = hwin })
    vim.api.nvim_set_option_value('relativenumber', false, { win = hwin })
    vim.api.nvim_set_option_value('signcolumn', 'no', { win = hwin })
end

function term.on_complete(task, status, result)
    local tab = vim.api.nvim_get_current_tabpage()
    if term.twin[tab] and vim.api.nvim_win_is_valid(term.twin[tab]) then
        local cursor = vim.api.nvim_win_get_cursor(term.twin[tab])
        vim.api.nvim_win_set_cursor(term.twin[tab], { cursor[1], 0 })
    end
    term.task = nil
end

--- @alias Tout.Params table
--- @alias Tout.Component table
--- @class Tout
--- @field params(Tout.Params) Parameters to sync task output
--- For params.style:
---     'term' : termopen + terminal
---     'ansi' : termopen + quickfix with highlighted ANSI
---     'job'  : jobstart + quickfix
local M = {
    desc = 'Sync task output into the quickfix(default) or terminal',
    params = {
        efm = {
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
        hltext = {
            desc = 'Text to highlight from task outputs at quickfix window',
            type = 'string', -- Actually use string[]
            default = '',
        },
        title = {
            desc = 'Set quickfix title as a identifier',
            type = 'string',
            default = 'v.task.tout',
        },
        style = {
            desc = 'Choose the display style {term, ansi, job}',
            type = 'string',
            default = 'ansi',
        },
        encoding = {
            desc = "Display encoding (works with style = 'job')",
            type = 'string',
            default = '',
        },
        verbose = {
            desc = 'Output verbose for quickfix debug',
            type = 'string',
            default = false,
        },
    },
}

function M.constructor(params)
    --- @type Tout.Component
    local cpt = {
        start_time = nil,
        --- @type Chanor|nil
        chanor = nil,
    }

    cpt.on_init = function(self, task)
        self.chanor = require('v.nlib').new_chanor({
            style = params.style,
            verbose = params.verbose,
        })
        -- Resolve errorformat for 'ansi' style to make one quickfix item only take one buffer line
        if type(params.efm) == 'table' then
            if #params.efm > 1 and params.style == 'ansi' then
                params.efm = params.efm[2]
            else
                params.efm = params.efm[1]
            end
        end
        if params.efm == '' then
            params.efm = ' ' -- The errorformat can be nil, but can't be ''
        end
    end

    cpt.on_start = function(self, task)
        if params.style == 'term' then
            term.redir(task, true)
        else
            if qf.task then
                local fzer = require('v.task').title.Fzer
                if qf.title ~= fzer and params.title == fzer then
                    term.redir(qf.task)
                    qf.on_start(task, cpt, params)
                else
                    term.redir(task)
                end
            else
                qf.on_start(task, cpt, params)
            end
        end
    end

    cpt.on_complete = function(self, task, status, result)
        if qf.task and qf.task.id == task.id then
            qf.on_complete(task, status, result, cpt, params)
        elseif term.task and term.task.id == task.id then
            term.on_complete(task, status, result)
        end
    end

    cpt.on_output = function(self, task, data)
        if qf.task and qf.task.id == task.id then
            qf.on_output(task, data, cpt, params)
        end
    end

    return cpt
end

return M
