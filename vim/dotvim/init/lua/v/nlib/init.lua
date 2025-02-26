--- @class NLib Neovim Library
local M = {}

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
---         set(),
---         get(),
---         ...
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

--- @alias Chanor function A channel lines processor for terminal's stdout
--- @class ChanorOptions Chanor options according to OnTaskOutput.params
--- @field style string|nil
--- @field verbose string|nil

--- Create a chanor
--- @param opts ChanorOptions|nil
--- @return Chanor
function M.new_chanor(opts)
    local style = opts and opts.style
    local verbose = opts and opts.verbose or ''
    local verb_r = verbose:match('[ar]')

    local raws = {}
    local ansi = require('v.nlib.ansi').new(verbose)
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
            ansi.feed(linestr)
        else
            local bufs = ansi.bufs()
            bufs[#bufs + 1] = { linestr:gsub('\r', '') } -- Remove ^M
        end
    end

    --- Process raw data stream from terminal's stdout
    --- @param data string[]|nil nil means all processed buffer lines should be displayed
    --- @return string[] lines Processed lines
    --- @return table highlights Processed highlights for lines
    return function(data)
        local bufs = ansi.bufs()

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
            if bufs[k] then
                lines[#lines + 1] = bufs[k][1]
                if style == 'ansi' then
                    highlights[#highlights + 1] = bufs[k][2]
                end
            end
            buf_idx = buf_idx + 1
        end

        -- Reset locals
        if not data then
            if verb_r then
                vim.notify(vim.inspect(raws))
            end
            ansi = require('v.nlib.ansi').new(verbose)
            buf_idx = 1
            pending = ''
        end

        return lines, highlights
    end
end

--- Get selected text
--- When used with 'vmap', '<Cmd>' is required and ':' will cause issue.
--- @param sep string|nil Join with sep for multi-lines text
--- @return string
function M.get_selected(sep)
    local reg_var = vim.fn.getreg('9', 1)
    local reg_mode = vim.fn.getregtype('9')
    -- Get selected with reg for nvim_buf_get_text doesn't support block text
    if vim.fn.mode() == 'n' then
        vim.cmd.normal({ args = { 'gv"9y' }, bang = true, mods = { silent = true } })
    else
        vim.cmd.normal({ args = { '"9y' }, bang = true, mods = { silent = true } })
    end
    local selected = vim.fn.getreg('9')
    vim.fn.setreg('9', reg_var, reg_mode)

    local res = sep and string.gsub(selected, '\n', sep) or selected
    return res
end

--- Try to find root directory upward that contains marker
--- @param marker string[]|string|nil
--- @return string|nil
function M.try_root(marker)
    return vim.fs.root(
        vim.api.nvim_buf_get_name(0),
        marker or { '.git', 'Justfile', 'justfile', '.justfile', 'Makefile', 'makefile' }
    )
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

--- @class RecallOptions
--- @field feedcmd boolean|nil Feed command into command line

--- @type string|function
local __cmdfn
--- Store/recall command or function
--- @param cmdfn string|function Vim command string or function
--- @param opts RecallOptions|nil
function M.recall(cmdfn, opts)
    if cmdfn then
        -- Store
        __cmdfn = cmdfn
    else
        -- Recall
        local feedcmd = opts and opts.feedcmd
        if type(__cmdfn) == 'function' then
            __cmdfn()
        elseif type(__cmdfn) == 'string' then
            if feedcmd then
                vim.api.nvim_feedkeys(__cmdfn, 'n', false)
            else
                vim.cmd(__cmdfn)
            end
        end
    end
end

--------------------------------------------------------------------------------
--- @class NLib.Async
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

    vim.fn.PopSelection(sel)
end

--------------------------------------------------------------------------------
--- @class NLib.Utils
--------------------------------------------------------------------------------
local _u = {}
M.u = _u

--- Split string arguments with blanks
--- Attention: currently each arg can't contain any blanks.
--- @return table List of arguments
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

--- Map functions
--- 'map' and 'nore' works at normal and visual mode by default here
--- ```lua
---      local m = require('v.nlib').m
---      m.add({'n', 'v'}, {'<leader>', ':echo b:<CR>', buffer = true})
---      m.del({'n', 'v'}, {'<leader>', buffer = true})
---      m.nnore{'<leader>', ':echo b:<CR>', silent = true, buffer = 9}
---      m.ndel{'<leader>', buffer = 9}
--- ```
--- @param mods string|table Mapping modes
--- @param opts table Mapping options with {lhs, rhs, **kwargs}
-- stylua: ignore start
function _m.del(mods, opts)     delmap(mods, opts[1], setopts(opts)) end
function _m.add(mods, opts)     setmap(mods, opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.addnore(mods, opts) setmap(mods, opts[1], opts[2], setopts(opts, { noremap = true })) end

function _m.ndel(opts)  delmap('n', opts[1], setopts(opts)) end
function _m.vdel(opts)  delmap('v', opts[1], setopts(opts)) end
function _m.xdel(opts)  delmap('x', opts[1], setopts(opts)) end
function _m.sdel(opts)  delmap('s', opts[1], setopts(opts)) end
function _m.odel(opts)  delmap('o', opts[1], setopts(opts)) end
function _m.idel(opts)  delmap('i', opts[1], setopts(opts)) end
function _m.ldel(opts)  delmap('l', opts[1], setopts(opts)) end
function _m.cdel(opts)  delmap('c', opts[1], setopts(opts)) end
function _m.tdel(opts)  delmap('t', opts[1], setopts(opts)) end
function _m.map(opts)   setmap({'n', 'v'}, opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.nmap(opts)  setmap('n', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.vmap(opts)  setmap('v', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.xmap(opts)  setmap('x', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.smap(opts)  setmap('s', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.omap(opts)  setmap('o', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.imap(opts)  setmap('i', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.lmap(opts)  setmap('l', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.cmap(opts)  setmap('c', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.tmap(opts)  setmap('t', opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.nore(opts)  setmap({'n', 'v'}, opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.nnore(opts) setmap('n', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.vnore(opts) setmap('v', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.xnore(opts) setmap('x', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.snore(opts) setmap('s', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.onore(opts) setmap('o', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.inore(opts) setmap('i', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.lnore(opts) setmap('l', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.cnore(opts) setmap('c', opts[1], opts[2], setopts(opts, { noremap = true })) end
function _m.tnore(opts) setmap('t', opts[1], opts[2], setopts(opts, { noremap = true })) end
-- stylua: ignore end

return M
