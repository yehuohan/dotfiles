--- @class NLib Neovim library
local M = {}
local fn = vim.fn
local api = vim.api

--- @alias Configer table An useful configer with savable options
--- @alias ConfigerMethod table Configer's methods
--- @alias ConfigerSaveable table Configer's savable options without `ConfigerMethod`
--- @alias ConfigerNonSaveable table Configer's non-savable options

--- Create a configer
--- Configer need metatable for internal usage, so metatable from `opts` will be droped.
--- `table.insert()` works as `rawset()` and won't trigger `B.__newindex`:
--- opts@Configer {
---     opt = xxx,
---     arg = {
---         'abc', -- table.insert(opts.arg, 'abc')
---         <metatable> = B {
---             __index,
---             __newindex,
---         },
---     },
---     ...
---     <metatable> = C@ConfigerMethod {
---         __index,
---         __newindex,
---         __opts = { ... },
---         new(), mut(), set(), get(),
---         <metatable> = nsc@ConfigerNonSaveable {
---             ext = yyy,
---             arg = { 'ABC' }, -- opts.arg[1] = 'ABC'
---         },
---     },
--- }
--- @param opts table Savable options of configer
--- @return Configer opts with `ConfigerMethod` is called `Configer`
function M.new_configer(opts)
    if type(opts) ~= 'table' then
        error('Initial savable options shoule be a table')
    end

    --- Setup `sub_nsc` for `sub_sc`
    --- @param sub_nsc ConfigerNonSaveable Sub level non-savable options
    --- @param sub_sc ConfigerSaveable Sub level savable options
    local function setup_non_savble(sub_nsc, sub_sc)
        local B = {}
        B.__call = function(self, rhs)
            -- `sub_nsc` must NOT have metatable.
            -- Lua 5.1 `__eq` require both 'lhs' and 'rhs' have same `metatable.__eq`,
            -- So compare table address directly with `metatable.__call`.
            return self == sub_sc and sub_nsc == rhs
        end
        B.__index = function(self, k) return rawget(self, k) or sub_nsc[k] end
        B.__newindex = function(self, k, v)
            if rawget(self, k) == nil then
                sub_nsc[k] = v
            else
                rawset(self, k, v)
            end
        end
        setmetatable(sub_sc, B)
    end

    --- Deep setup non-savable options for savable options
    local function deep_non_savable(sub_nsc, sub_sc)
        for k, v in pairs(sub_sc) do
            if type(v) == 'table' then
                if type(sub_nsc[k]) ~= 'table' then
                    sub_nsc[k] = {}
                end
                if not (getmetatable(v) and getmetatable(v).__call and v(sub_nsc[k])) then
                    setup_non_savble(sub_nsc[k], v)
                end
                deep_non_savable(sub_nsc[k], v)
            end
        end
    end

    --- Create non-savable options
    --- @param init_opts table Savable options of configer
    --- @return ConfigerNonSaveable
    local function non_savable(init_opts)
        local nsc = {}
        nsc.__index = nsc
        deep_non_savable(nsc, init_opts)
        return nsc
    end

    --- @type ConfigerMethod
    local C = { __opts = M.u.deepcopy(opts) }
    setmetatable(opts, C) -- opts.metatable = C
    setmetatable(C, non_savable(opts)) -- C.metatable = nsc
    C.__index = C
    C.__newindex = function(self, k, v) -- `self` = `opts`
        if rawget(self, k) then
            -- New savable option(actually this won't happen with __newindex)
            rawset(self, k, v)
        elseif rawget(C, k) then
            error(string.format('The key "%s" is a configer method that should not be modified', k))
        else
            -- Forward `opts.__newindex` into `nsc.__newindex`
            getmetatable(getmetatable(self))[k] = v
        end
    end

    --- Re-new configer's options
    --- * Replace `C.__opts` with `new_opts`;
    --- * Replace all savable options with `C.__opts`;
    --- * Clear all non-savable options.
    --- @param new_opts table|nil New savable options of configer
    function C:new(new_opts)
        if new_opts then
            C.__opts = M.u.deepcopy(new_opts)
        end
        for k, _ in pairs(self) do
            rawset(self, k, nil)
        end
        for k, v in pairs(C.__opts) do
            if type(v) == 'table' then
                rawset(self, k, M.u.deepcopy(v))
            else
                rawset(self, k, v)
            end
        end
        setmetatable(C, non_savable(self)) -- C == getmetatable(self)
    end

    --- Modify configer's options
    --- * Merge `new_opts` into `C.__opts`;
    --- * Merge `new_opts` into all savable options;
    --- * Keep all non-savable options.
    --- @param new_opts table New savable options of configer
    function C:mut(new_opts)
        M.u.deepmerge(C.__opts, new_opts)
        M.u.deepmerge(self, new_opts, true)
        deep_non_savable(getmetatable(C), self) -- nsc == getmetatable(C)
    end

    --- Setup configer's current options
    --- Merge `new_opts` into all savable and non-savable options
    function C:set(new_opts) M.u.deepmerge(self, new_opts) end

    --- Get only savable options as a table
    --- @return ConfigerSaveable
    function C:get() return M.u.deepcopy(self) end

    return opts
end

--- @class new_chanor.Opts
--- @field style string|nil
--- @field verbose string|nil

--- Create a chanor
--- @param opts new_chanor.Opts|nil
--- @return function chanor A channel lines processor for terminal's stdout
function M.new_chanor(opts)
    local style = opts and opts.style
    local verbose = opts and opts.verbose or ''
    local verb_r = verbose:match('[ar]')

    local raws = {}
    local bufs, ansi = require('v.nlib.ansi').new(verbose)
    local buf_idx = 1
    local pending = ''

    --- Process one raw line string of data stream
    --- @param linestr string String to be processed
    --- @return string|nil Pending string that can't be break into multi-lines
    local function process_linestr(linestr)
        if verb_r then
            raws[#raws + 1] = linestr
        end
        if style == 'ansi' then
            ansi(linestr)
        else
            bufs[#bufs + 1] = { linestr:gsub('\r', '') } -- Remove ^M
        end
    end

    --- Process raw data stream from terminal's stdout
    --- @param data string[]|nil nil means all processed buffer lines should be displayed
    --- @return string[] lines Processed lines
    --- @return ANSILineHighlight[] highlights Processed highlights for lines
    return function(data)
        -- Process raw data into lines according to ':h channel-lines'
        local eof = (not data) or (#data == 1 and data[1] == '')
        if eof then
            if pending ~= '' then
                process_linestr(pending)
                pending = ''
            end
        elseif data then
            local num = #data
            process_linestr(pending .. data[1])
            pending = ''
            for k = 2, num - 1, 1 do
                process_linestr(data[k])
            end
            if num >= 2 then
                pending = data[num]
            end
        end

        -- Copy returned lines and highlights
        local lines = {}
        local highlights = {}
        for k = buf_idx, #bufs - (eof and 0 or 1), 1 do -- `ansi` may backtrace one buffer line
            lines[#lines + 1] = bufs[k][1]
            if style == 'ansi' then
                highlights[#highlights + 1] = bufs[k][2]
            end
            buf_idx = buf_idx + 1
        end

        -- Reset locals
        if not data then
            if verb_r then
                vim.notify(vim.inspect(raws))
            end
            bufs, ansi = require('v.nlib.ansi').new(verbose)
            buf_idx = 1
            pending = ''
        end

        return lines, highlights
    end
end

--- @class new_terminal.Opts
--- @field cmd table The command to run
--- @field quit boolean Quit terminal
--- @field bottom boolean Split terminal at bottom window

--- @type table
local __term = { hbuf = nil, hwin = nil }
--- Create a terminal
--- @param opts new_terminal.Opts|nil
function M.new_terminal(opts)
    local del_terminal = function()
        if __term.hwin and vim.api.nvim_win_is_valid(__term.hwin) then
            vim.api.nvim_win_close(__term.hwin, false)
        end
        if __term.hbuf and vim.api.nvim_buf_is_valid(__term.hbuf) then
            vim.api.nvim_buf_delete(__term.hbuf, { force = true })
        end
        __term = { hbuf = nil, hwin = nil }
    end

    -- Exit terminal
    if opts and opts.quit then
        del_terminal()
        return
    end

    -- Hide terminal
    if __term.hwin and vim.api.nvim_win_is_valid(__term.hwin) then
        vim.api.nvim_win_close(__term.hwin, false)
        __term.hwin = nil
        return
    end

    -- Create window
    local hbuf = __term.hbuf or api.nvim_create_buf(false, true)
    local hwin
    if opts and opts.bottom then
        vim.cmd.split({ mods = { split = 'botright' }, range = { 12 } })
        hwin = vim.api.nvim_get_current_win()
        vim.wo[hwin].number = false
        vim.wo[hwin].relativenumber = false
        vim.wo[hwin].signcolumn = 'no'
        vim.api.nvim_win_set_buf(hwin, hbuf)
    else
        local scl = opts and opts.size or 0.6
        local ofs = (1.0 - scl) / 2.0
        hwin = api.nvim_open_win(hbuf, false, {
            relative = 'editor',
            width = math.floor(scl * vim.o.columns),
            height = math.floor(scl * vim.o.lines),
            col = math.floor(ofs * vim.o.columns),
            row = math.floor(ofs * vim.o.lines),
            style = 'minimal',
            border = 'single',
        })
        vim.wo[hwin].winhighlight = 'NormalFloat:Normal,FloatBorder:Normal'
        api.nvim_set_current_win(hwin) -- Avoid break original window view when closed floating windows
    end
    __term.hwin = hwin

    -- Open terminal
    if not __term.hbuf then
        __term.hbuf = hbuf
        vim.fn.jobstart(opts and opts.cmd or { vim.o.shell }, {
            term = true,
            on_exit = function()
                -- Delete with `opts.exit` will still invoke `on_exit`
                if __term.hbuf == hbuf then
                    del_terminal()
                end
            end,
        })
    end
    vim.cmd.startinsert()
end

--------------------------------------------------------------------------------
--- @class NLib.Ext Extended neovim functionality
--------------------------------------------------------------------------------
local _e = {}
M.e = _e

--- @type string|function
local __cmdfn = nil
--- Repeat command or function
--- @param cmdfn string|function
--- @param bang boolean|nil Repeat once immediately
function _e.dotrepeat(cmdfn, bang)
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
function _e.modeline(tag, file)
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
function _e.selected(sep)
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
_e.buf_inp = {
    input = fn.input,
    word = function() return fn.expand('<cword>') end,
    line = function()
        local lnum = fn.line('.')
        return fn.join(fn.getline(lnum, lnum + vim.v.count), '\n')
    end,
}

--- @alias buf_pipe.OutHandler fun(string, opts:table)
_e.buf_out = {
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
_e.buf_proc = {
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
--- @field prompt string For `_e.buf_inp.input`
--- @field completion string For `_e.buf_inp.input`
--- @field sep string For `_e.selected`
--- @field eval string For `_e.buf_proc.eval_math`

--- Pipe the buffer text from input to output after process
--- @param inp string|buf_pipe.InpHandler|nil Only for normal mode
--- @param out string|buf_pipe.OutHandler
--- @param proc string|buf_pipe.ProcHandler|nil
--- @param opts buf_pipe.Opts|nil
function _e.buf_pipe(inp, out, proc, opts)
    opts = opts or {}
    local fninp = type(inp) == 'string' and _e.buf_inp[inp] or inp
    local fnout = type(out) == 'string' and _e.buf_out[out] or out
    local fnproc = type(proc) == 'string' and _e.buf_proc[proc] or proc
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
        opts.mode = 'v'
        txt = _e.selected(opts and opts.sep or nil)
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
function _e.buf_etmp(ft, wt)
    if not ft then
        return
    end
    wt = wt or ''
    if wt == 'floating' then
        wt = ''
        local buf = api.nvim_create_buf(true, false)
        api.nvim_open_win(buf, true, {
            relative = 'editor',
            width = math.floor(0.6 * vim.o.columns),
            height = math.floor(0.7 * vim.o.lines),
            col = 3,
            row = 2,
            border = 'single',
        })
    end
    vim.cmd[wt .. 'edit'](fn.tempname() .. '.' .. ft)
end

--- Edit buffer from template file
--- @param path string Path of template files
--- @param under_root boolean Edit or create from root
function _e.buf_etpl(path, under_root)
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
function _e.win_resize(dir, inc)
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
function _e.win_jump_floating()
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

--------------------------------------------------------------------------------
--- @class NLib.Async Async functions
--------------------------------------------------------------------------------
local _a = {}
M.a = _a

_a._await = coroutine.yield

function _a._async(func)
    return function(...) coroutine.wrap(func)(...) end
end

function _a._wrap(afunc)
    return function(...)
        local caller = coroutine.running()
        local args = { ... }
        -- Place async function's callback at the last by default
        table.insert(args, function(...)
            -- Callback args will passed to `res = await()` from resume
            coroutine.resume(caller, ...)
        end)
        coroutine.wrap(afunc)(unpack(args))
    end
end

--- @alias PopSelection table Selection of plugin popset
--- @alias PopSelectionEvent fun(name:string, ...)

--- Async PopSelection
--- @param sel PopSelection
--- @yield boolean Selection is confirmed(true) or canceled(false)
function _a.pop_selection(sel)
    local caller = coroutine.running()

    local old_evt = sel.evt
    local new_evt = function(name, ...)
        if old_evt then
            old_evt(name, ...)
        end
        if 'onCR' == name then
            coroutine.resume(caller, true)
        elseif 'onQuit' == name then
            coroutine.resume(caller, false)
        end
    end
    sel.evt = new_evt

    fn.PopSelection(sel)
end

--------------------------------------------------------------------------------
--- @class NLib.Utils
--------------------------------------------------------------------------------
local _u = {}
M.u = _u

--- Try to find root directory upward that contains marker
--- @param marker string[]|string|nil
--- @return string|nil
function _u.try_root(marker)
    return vim.fs.root(
        api.nvim_buf_get_name(0),
        marker or { '.git', 'Justfile', 'justfile', '.justfile', 'Makefile', 'makefile' }
    )
end

--- Split string arguments with blanks
--- Attention: currently each arg can't contain any blanks.
--- @return string[] List of arguments
function _u.str2arg(str) return vim.split(str, '%s+', { trimempty = true }) end

--- Parse string to table of environment variables
--- @param str string Input with format 'VAR0=var0 VAR1=var1'
--- @return table Environment table with { VAR0 = 'var0', VAR1 = 'var1' }
function _u.str2env(str)
    local env = {}
    for _, seg in ipairs(_u.str2arg(str)) do
        local var = vim.split(seg, '=', { trimempty = true })
        env[var[1]] = var[2]
    end
    return env
end

--- Repleace command's placeholders
--- @param cmd string String command with format 'cmd {arg}'
--- @param rep table Replacement with { arg = 'val' }
function _u.replace(cmd, rep) return vim.trim(string.gsub(cmd, '{(%w+)}', rep)) end

--- Sequence commands
--- @param cmdlist string[] Command list to join with ' && '
function _u.sequence(cmdlist) return table.concat(cmdlist, ' && ') end

--- Deep copy variable
--- @param mt boolean|nil Copy metatable or not
function _u.deepcopy(orig, mt)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in pairs(orig) do
            copy[_u.deepcopy(k, mt)] = _u.deepcopy(v, mt)
        end
        if mt then
            setmetatable(copy, _u.deepcopy(getmetatable(orig), mt))
        end
    else
        copy = orig
    end
    return copy
end

--- Deep merge table
--- @param dst table The table to merge into, and metatable will be keeped
--- @param src table The table to merge from, and value will be keeped for same key
--- @param raw boolean|nil Use `rawget/rawset` to avoid `dst.metatable` works
function _u.deepmerge(dst, src, raw)
    if raw then
        for k, v in pairs(src) do
            if type(v) == 'table' then
                if type(rawget(dst, k)) ~= 'table' then
                    rawset(dst, k, {})
                end
                _u.deepmerge(rawget(dst, k), v, raw)
            else
                rawset(dst, k, v)
            end
        end
    else
        for k, v in pairs(src) do
            if type(v) == 'table' then
                if type(dst[k]) ~= 'table' then
                    dst[k] = {}
                end
                _u.deepmerge(dst[k], v, raw)
            else
                dst[k] = v
            end
        end
    end
end

--------------------------------------------------------------------------------
--- @class NLib.Map
--------------------------------------------------------------------------------
local _m = {}
M.m = _m

local delmap = vim.keymap.del
local setmap = vim.keymap.set

local function setopts(opts, defaults)
    local map_opts = {}
    for k, v in pairs(opts) do
        if type(k) == 'string' then
            map_opts[k] = v
        end
    end
    if defaults then
        map_opts = vim.tbl_extend('keep', map_opts, defaults)
    end
    return map_opts
end

--- @class map.Opts Mapping options with {lhs, rhs, **kwargs}
--- @field [1] string The mapping lhs
--- @field [2] string|function The mapping rhs
--- @field remap boolean|nil
--- @field noremap boolean|nil
--- @field buffer integer|nil

--- Map functions
---
--- * 'map' and 'nore' works at 'n', 'v' and 'o'
--- * 'v' includes both 'x' and 's'
--- * avoid mapping a-z in 's' mode, which breaks editing placeholder selection of snippet/completion
---
--- ```lua
---      local m = require('v.nlib').m
---      m.add({'n', 'v'}, {'<leader>', ':echo b:<CR>', buffer = true})
---      m.del({'n', 'v'}, {'<leader>', buffer = true})
---      m.nnore{'<leader>', ':echo b:<CR>', silent = true, buffer = 9}
---      m.ndel{'<leader>', buffer = 9}
--- ```
--- @param mods string|string[] Mapping modes
--- @param opts map.Opts
-- stylua: ignore start
function _m.del(mods, opts)     delmap(mods, opts[1], setopts(opts)) end
function _m.add(mods, opts)     setmap(mods, opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.addnore(mods, opts) setmap(mods, opts[1], opts[2], setopts(opts, { noremap = true })) end

function _m.ndel(opts)   delmap('n', opts[1], setopts(opts)) end
function _m.vdel(opts)   delmap('v', opts[1], setopts(opts)) end
function _m.xdel(opts)   delmap('x', opts[1], setopts(opts)) end
function _m.sdel(opts)   delmap('s', opts[1], setopts(opts)) end
function _m.odel(opts)   delmap('o', opts[1], setopts(opts)) end
function _m.idel(opts)   delmap('i', opts[1], setopts(opts)) end
function _m.ldel(opts)   delmap('l', opts[1], setopts(opts)) end
function _m.cdel(opts)   delmap('c', opts[1], setopts(opts)) end
function _m.tdel(opts)   delmap('t', opts[1], setopts(opts)) end
function _m.map(opts)    setmap({'n', 'v', 'o'}, opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.nvmap(opts)  setmap({'n', 'v'}, opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.nxmap(opts)  setmap({'n', 'x'}, opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.nmap(opts)   setmap('n', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.vmap(opts)   setmap('v', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.xmap(opts)   setmap('x', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.smap(opts)   setmap('s', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.omap(opts)   setmap('o', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.imap(opts)   setmap('i', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.lmap(opts)   setmap('l', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.cmap(opts)   setmap('c', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.tmap(opts)   setmap('t', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.nore(opts)   setmap({'n', 'v', 'o'}, opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.nvnore(opts) setmap({'n', 'v'}, opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.nxnore(opts) setmap({'n', 'x'}, opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.nnore(opts)  setmap('n', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.vnore(opts)  setmap('v', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.xnore(opts)  setmap('x', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.snore(opts)  setmap('s', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.onore(opts)  setmap('o', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.inore(opts)  setmap('i', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.lnore(opts)  setmap('l', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.cnore(opts)  setmap('c', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.tnore(opts)  setmap('t', opts[1], opts[2], setopts(opts, { noremap = true })) end
-- stylua: ignore end

return M
