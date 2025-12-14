--- Display task output into quickfix or terminal

local PAUSE_PATS = {
    '请按任意键继续. . .',
    'Press any key to continue . . .',
    '按 Enter 键继续...:',
    'Press Enter to continue...:',
}

--- @type Qfer
local qfer = require('v.task.qfer').get()

--- @class ToutTerminal
--- @field twin table<integer,integer> The pined terminal(vterm) window handle for each tabpage
--- @field task table|nil The task output to terminal
local term = {
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

--- @param pin boolean|nil Pin task output to the terminal or not
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
    vim.wo[hwin].number = false
    vim.wo[hwin].relativenumber = false
    vim.wo[hwin].signcolumn = 'no'
end

function term.stop()
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
--- @field params Tout.Params Parameters to sync task output
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
        hltexts = {
            desc = 'Text to highlight from task outputs at quickfix window',
            type = 'string', -- Actually use string[]
            default = '',
        },
        title = {
            desc = 'Set quickfix title as a identifier',
            type = 'string',
            default = 'v.task',
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

    cpt.on_start = function(_, task)
        local function qfer_start()
            cpt.start_time = vim.fn.reltime()
            qfer.task = task
            qfer.title = params.title
            qfer.hltexts = params.hltexts
            qfer.fetch()
            qfer.open(params.open, params.jump)
            qfer.lcd(task.cwd)
            qfer.begin_block(task.name, 'Identifier', params.append)
        end

        if params.style == 'term' then
            term.redir(task, true)
        else
            if qfer.task then
                local fzer = require('v.task').title.Fzer
                if qfer.title ~= fzer and params.title == fzer then
                    term.redir(qfer.task)
                    qfer_start()
                else
                    term.redir(task)
                end
            else
                qfer_start()
            end
        end
    end

    cpt.on_complete = function(_, task, status, result)
        if qfer.task and qfer.task.id == task.id then
            local dt = vim.fn.reltimefloat(vim.fn.reltime(cpt.start_time))
            local lines, highlights = cpt.chanor()
            qfer.fetch()
            qfer.add_lines(lines, highlights, params.efm, params.encoding)
            qfer.end_block(('%s in %0.2fs'):format(status, dt), 'Overseer' .. status)
            if params.scroll then
                qfer.scroll(#lines + 1)
            end
            qfer.task = nil
        elseif term.task and term.task.id == task.id then
            term.stop()
        end
    end

    cpt.on_output = function(_, task, data)
        if qfer.task and qfer.task.id == task.id then
            local encoding = params.encoding
            local chan_id = task.strategy.job_id
            -- React to pause command
            for _, str in ipairs(data) do
                local txt = str
                if encoding ~= '' then
                    txt = vim.iconv(str, encoding, vim.o.encoding)
                end
                if IsWin() then
                    for _, pat in ipairs(PAUSE_PATS) do
                        if txt and txt:match(pat) then
                            vim.api.nvim_chan_send(chan_id, '\x0D')
                            break
                        end
                    end
                end
            end

            local lines, highlights = cpt.chanor(data)
            qfer.fetch()
            qfer.add_lines(lines, highlights, params.efm, encoding)
            if params.scroll then
                qfer.scroll(#lines)
            end
        end
    end

    return cpt
end

return M
