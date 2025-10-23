--- @class NLib.libexts Extended neovim functionalities
local M = {}
local fn = vim.fn
local api = vim.api

--- @type string|function
local __cmdfn = nil
--- Repeat command or function
--- @param cmdfn string|function
--- @param bang boolean|nil Repeat once immediately
function M.dotrepeat(cmdfn, bang)
    if cmdfn then
        __cmdfn = cmdfn
    end
    if (not cmdfn) or bang then
        if type(__cmdfn) == 'function' then
            __cmdfn()
        elseif type(__cmdfn) == 'string' then
            vim.cmd(__cmdfn)
        end
    end
end

--- Get extended modeline
--- @param tag string Tag for extended modeline
--- @return table|nil tbl
--- @return string|nil cmd
function M.modeline(tag, file)
    local pat1 = [[^.*vim@]] .. tag .. [[:%s*(.*)$]] -- vim@<tag>: <cmd>
    local pat2 = [[^.*vim@]] .. tag .. [[({.*}):%s*(.*)$]] -- vim@<tag>{<tbl>}: <cmd>
    local tbl, cmd
    local num = 0

    for line in io.lines(file) do
        num = num + 1
        if num <= vim.o.modelines then
            cmd = line:match(pat1)
            if cmd then
                break
            end
            tbl, cmd = line:match(pat2)
            if tbl and cmd then
                local ok, opts = pcall(function() return loadstring('return ' .. tbl)() end)
                if not ok then
                    vim.notify('Wrong table from modeline: ' .. tbl)
                end
                tbl = ok and opts or nil
                break
            end
        end
    end

    if cmd == '' then
        cmd = nil
    end
    return tbl, cmd
end

--- Get selected text
--- Use '<Cmd>' or ':<C-u>' (remove selection to enter normal mode) for vmap
--- @param sep string|nil Join with sep for multi-lines text
--- @return string
function M.selected(sep)
    local reg_var = fn.getreg('9', 1)
    local reg_mode = fn.getregtype('9')
    -- Get selected with reg for nvim_buf_get_text doesn't support block text
    if fn.mode() == 'n' then
        vim.cmd.normal({ args = { 'gv"9y' }, bang = true, mods = { silent = true } })
    else
        vim.cmd.normal({ args = { '"9y' }, bang = true, mods = { silent = true } })
    end
    local selected = fn.getreg('9')
    fn.setreg('9', reg_var, reg_mode)

    local res = sep and string.gsub(selected, '\n', sep) or selected
    return res
end

--- @alias buf_pipe.InpHandler fun(table):string
M.buf_inp = {
    input = fn.input,
    word = function() return fn.expand('<cword>') end,
    line = function()
        local lnum = fn.line('.')
        return fn.join(fn.getline(lnum, lnum + vim.v.count), '\n')
    end,
}

--- @alias buf_pipe.OutHandler fun(string, opts:table)
M.buf_out = {
    append = function(txt) fn.append(fn.line('.'), fn.split(txt, '\n')) end,
    replace = function(txt) fn.setline(fn.line('.'), txt) end,
    -- cmdline = function(txt) fn.feedkeys(txt, 'n') end,
    yank = function(txt)
        vim.notify(txt)
        fn.setreg('0', txt)
    end,
    yank_append = function(txt)
        vim.notify(txt)
        fn.setreg('0', fn.getreg('0') .. txt)
    end,
    yankcopy = function(txt)
        vim.notify(txt)
        fn.setreg('0', txt)
        fn.setreg('+', txt)
    end,
    yankcopy_append = function(txt)
        vim.notify(txt)
        fn.setreg('0', fn.getreg('0') .. txt)
        fn.setreg('+', fn.getreg('+') .. txt)
    end,
    open = function(txt)
        vim.notify(txt)
        vim.ui.open(txt)
    end,
}

--- @alias buf_pipe.ProcHandler fun(string, opts:table):string
M.buf_proc = {
    trim = function(txt)
        local lines = fn.split(txt, '\n')
        return fn.join(vim.tbl_map(vim.trim, lines), '\n')
    end,
    exec = function(txt) return fn.execute(txt) end,
    eval = function(txt) return fn.eval(txt) end,
    eval_math = function(txt, opts)
        local expr = txt:gsub('([^=]+)=[^=]*$', '%1'):gsub('%s*$', '')
        local res = fn[opts.eval](expr)
        if opts.mode == 'n' then
            return ('%s = %s'):format(expr, res)
        else
            local line = fn.getline('.')
            local col = fn.getpos("'>")[3]
            return line:sub(1, col) .. (' = %s '):format(res) .. line:sub(col + 1)
        end
    end,
}

--- @class buf_pipe.Opts Options for `inp`, `out` and `proc`
--- @field mode string 'n' or 'v'
--- @field prompt string For `M.buf_inp.input`
--- @field completion string For `M.buf_inp.input`
--- @field sep string For `M.selected`
--- @field eval string For `M.buf_proc.eval_math`

--- Pipe the buffer text from input to output after process
--- @param inp string|buf_pipe.InpHandler|nil Only for normal mode
--- @param out string|buf_pipe.OutHandler
--- @param proc string|buf_pipe.ProcHandler|nil
--- @param opts buf_pipe.Opts|nil
function M.buf_pipe(inp, out, proc, opts)
    opts = opts or {}
    local fninp = type(inp) == 'string' and M.buf_inp[inp] or inp
    local fnout = type(out) == 'string' and M.buf_out[out] or out
    local fnproc = type(proc) == 'string' and M.buf_proc[proc] or proc
    local txt = ''
    --- Input
    if fn.mode() == 'n' then
        opts.mode = 'n'
        if fninp then
            txt = fninp(opts)
        else
            vim.notify('Require input handler for normal mode')
        end
    else
        opts.mode = 'x'
        txt = M.selected(opts and opts.sep or nil)
    end
    if txt ~= '' then
        -- Process
        if fnproc ~= nil then
            txt = fnproc(txt, opts)
        end
        -- Ouptut
        if type(txt) ~= 'string' then
            txt = fn.string(txt)
        end
        fnout(txt, opts)
    else
        vim.notify("There's nothing to pipe")
    end
end

--- Edit temporary buffer
--- @param ft string|nil File type
--- @param wt string|nil Window type with 'tab' or 'floating'
function M.buf_etmp(ft, wt)
    if not ft then
        return
    end
    wt = wt or ''
    if wt == 'floating' then
        wt = ''
        local buf = api.nvim_create_buf(true, false)
        api.nvim_open_win(buf, true, {
            anchor = 'NE',
            relative = 'editor',
            width = math.floor(0.5 * vim.o.columns),
            height = math.floor(0.5 * vim.o.lines),
            col = vim.o.columns,
            row = 2,
        })
    end
    vim.cmd[wt .. 'edit'](fn.tempname() .. '.' .. ft)
end

--- Edit buffer from template file
--- @param path string Path of template files
--- @param under_root boolean Edit or create from root
function M.buf_etpl(path, under_root)
    local dir = nil
    if under_root then
        dir = M.u.try_root()
    end
    if not dir then
        dir = vim.fs.dirname(api.nvim_buf_get_name(0))
    end
    local tpls = {}
    for res, type in vim.fs.dir(path, { depth = 5 }) do
        if type == 'file' then
            tpls[#tpls + 1] = res
        end
    end
    vim.ui.select(
        vim.tbl_map(function(c) return dir .. '/' .. c end, tpls),
        { prompt = 'Select template' },
        function(choice, idx)
            if choice then
                fn.mkdir(vim.fs.dirname(choice), 'p')
                vim.cmd.edit(choice)
                if fn.filereadable(choice) == 0 then
                    vim.cmd.read({ args = { path .. '/' .. tpls[idx] }, range = { 0 } })
                end
            end
        end
    )
end

--- Resize window by moving spliter
--- @param dir boolean Move bottom(true) or right(false) spliter
--- @param inc integer The size to move
function M.win_resize(dir, inc)
    local pos = api.nvim_win_get_position(0)
    local offset = inc * vim.v.count1
    if dir then
        local cur = pos[1] + 1 + api.nvim_win_get_height(0) + vim.o.cmdheight
        local max = vim.o.lines
        if cur >= max then
            if pos[1] >= 2 then
                vim.cmd.resize({ args = { ('%+d'):format(-offset) } })
            end
        else
            fn.win_move_statusline(fn.winnr(), offset)
        end
    else
        local cur = pos[2] + api.nvim_win_get_width(0)
        local max = vim.o.columns
        if cur >= max then
            vim.cmd.resize({ args = { ('%+d'):format(-offset) }, mods = { vertical = true } })
        else
            fn.win_move_separator(fn.winnr(), offset)
        end
    end
end

--- Jump to floating window
function M.win_jump_floating()
    local wins = {}
    for _, wid in ipairs(api.nvim_tabpage_list_wins(0)) do
        if fn.win_gettype(wid) == 'popup' then
            wins[#wins + 1] = wid
        end
    end
    if #wins > 0 then
        local idx = fn.index(wins, api.nvim_get_current_win())
        if idx == -1 or (idx + 1 == #wins) then
            idx = 0
        else
            idx = idx + 1
        end
        api.nvim_set_current_win(wins[idx + 1])
    end
end

return M
