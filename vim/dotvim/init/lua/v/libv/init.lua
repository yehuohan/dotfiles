--- @class LibvModule
local M = {}

--- Configer {
---     opt0 = xxx,
---     opt1 = {xxx},
---     ...,
---     <metatable> = ConfigerMethod {
---         fn0 = xxx,
---         fn1 = xxx,
---         ...,
---         <metatable> = ConfigerExtra {
---             eopt0 = xxx,
---             eopt1 = {xxx},
---             ...,
---         },
---     },
--- }
--- @alias Configer table An useful configer with saveable options
--- @alias ConfigerMethod table Configer's methods
--- @alias ConfigerExtra table Configer's extra non-saveable options

--- Create a configer
--- Configer need metatable for internal usage, so metatable from `opts` will be droped
--- @param opts(table) Savable options of configer
--- @return Configer
function M.new_configer(opts)
    if type(opts) ~= 'table' then
        error('Initial saveable options shoule be a table')
    end
    local copy_opts = M.u.deepcopy(opts)

    --- Create non-saveable options for each sub-tables
    --- @param nsc(ConfigerExtra)
    local function sub_non_savable_config(nsc, init_opts)
        for ik, iv in pairs(init_opts) do
            if type(iv) == 'table' then
                nsc[ik] = {}
                sub_non_savable_config(nsc[ik], iv)

                local B = {}
                B.__index = function(t, k) return rawget(t, k) or nsc[ik][k] end
                B.__newindex = function(t, k, v)
                    if (type(k) == 'number') and (1 <= k) and (k <= #t + 1) then
                        rawset(t, k, v)
                    else
                        nsc[ik][k] = v
                    end
                end
                setmetatable(init_opts[ik], B)
            end
        end
    end

    --- Create non-saveable options
    --- @return ConfigerExtra
    local function non_savable_config(init_opts)
        local nsc = {}
        nsc.__index = nsc
        sub_non_savable_config(nsc, init_opts)
        return nsc
    end

    --- @type ConfigerMethod
    local C = {}
    setmetatable(C, non_savable_config(opts))
    C.__index = C
    C.__newindex = function(t, k, v)
        if rawget(t, k) then
            -- New savable option(actually this won't happen with __newindex)
            rawset(t, k, v)
        elseif rawget(C, k) then
            error(string.format('The key "%s" is a config method that should not be modified', k))
        else
            -- New non-savable option
            -- C == getmetatable(t)
            -- nsc == getmetatable(C)
            getmetatable(getmetatable(t))[k] = v
        end
    end

    --- Get only savable options as a table
    function C:get() return M.u.deepcopy(self) end

    --- Setup config's current options
    --- * All savable options in mask will be merged from new_opts;
    --- * All non-savable options will be keeped.
    function C:set(new_opts, mask) M.u.deepmerge(self, new_opts, mask) end

    --- Reinit config's options
    --- * The initial options will be repleaced with reinit_opts;
    --- * All savable options will be cleared first, then reinited with reinit_opts;
    --- * All non-savable options will be cleared.
    function C:reinit(reinit_opts)
        if reinit_opts then
            copy_opts = M.u.deepcopy(reinit_opts)
        end
        for k, _ in pairs(self) do
            rawset(self, k, nil)
        end
        for k, v in pairs(copy_opts) do
            if type(v) == 'table' then
                rawset(self, k, M.u.deepcopy(v))
            else
                rawset(self, k, v)
            end
        end
        -- C == getmetatable(self)
        setmetatable(C, non_savable_config(self))
    end

    return setmetatable(opts, C)
end

--- @alias Chanor function A channel lines processor for terminal's stdout
--- @class ChanorOptions Chanor options according to OnTaskOutput.params
--- @field style(string|nil)
--- @field verbose(string|nil)

--- Create a chanor
--- @param opts(ChanorOptions|nil)
--- @return Chanor
function M.new_chanor(opts)
    local style = opts and opts.style
    local verbose = opts and opts.verbose or ''

    local ansi = require('v.libv.ansi').new()
    local out_idx = 1
    local pending = ''

    --- Process raw data stream
    --- @param str(string) String to be processed
    --- @param is_pending(boolean|nil) Is str a pending string or not
    --- @return string|nil Pending string that can't be break into multi-lines
    local function process_lines(str, is_pending)
        str = str:gsub('\r', '') -- Remove ^M
        if style == 'ansi' then
            return ansi.feed(str, is_pending, verbose)
        else
            local bufs = ansi.bufs()
            if not is_pending then
                bufs[#bufs + 1] = str
            else
                return str
            end
        end
    end

    --- Process raw data stream from terminal's stdout
    --- @param data(table<string>|nil) nil means all processed buffer lines should be displayed
    --- @return table<string> lines Processed lines
    --- @return table highlights Processed highlights for lines
    return function(data)
        local bufs = ansi.bufs()
        local hlts = ansi.hlts()

        -- Process raw data into lines according to ':h channel-lines'
        local eof = (not data) or (#data == 1 and data[1] == '')
        local end_idx = #bufs
        if eof then
            if pending ~= '' then
                process_lines(pending)
                pending = ''
                end_idx = #bufs
            end
        elseif data then
            local num = #data
            pending = pending .. data[1]
            local rest = process_lines(pending, num == 1)
            pending = rest or ''
            for k = 2, num - 1, 1 do
                process_lines(data[k])
            end
            if num >= 2 then
                pending = data[num]
            end
            end_idx = #bufs - 1
        end

        -- Copy returned lines and highlights
        local lines = {}
        local highlights = {}
        for k = out_idx, end_idx, 1 do
            if bufs[k] then
                lines[#lines + 1] = bufs[k]
            end
            if hlts[k] and style == 'ansi' then
                highlights[#highlights + 1] = hlts[k]
            end
            out_idx = out_idx + 1
        end

        -- Reset locals
        if not data then
            if verbose:match('[ab]') then
                vim.notify(('num = %d\n%s'):format(#bufs, vim.inspect(bufs)))
            end
            ansi.reset()
            out_idx = 1
            pending = ''
        end

        return lines, highlights
    end
end

--- Get selected text
--- When used with 'vmap', '<Cmd>' is required and ':' will cause issue.
--- @param sep(string|nil): Join with sep for multi-lines text
function M.get_selected(sep)
    local reg_var = vim.fn.getreg('9', 1)
    local reg_mode = vim.fn.getregtype('9')
    if vim.fn.mode() == 'n' then
        vim.cmd.normal({ args = { 'gv"9y' }, bang = true, mods = { silent = true } })
    else
        vim.cmd.normal({ args = { '"9y' }, bang = true, mods = { silent = true } })
    end
    local selected = vim.fn.getreg('9')
    vim.fn.setreg('9', reg_var, reg_mode)

    if sep then
        return vim.fn.join(vim.fn.split(selected, '\n'), sep)
    else
        return selected
    end
end

--- Get extended modeline
--- @param tag(string) Tag for extended modeline
function M.modeline(tag, file)
    local pat = [[^.*vim@]] .. tag .. [[(.*):%s*(.*)$]] -- vim@<tag>{<tbl>}: <cmd>
    local num = 0
    for line in io.lines(file) do
        num = num + 1
        if num <= vim.o.modelines then
            local tbl, cmd = line:match(pat)
            if tbl and cmd then
                if cmd:match('^%s*$') then
                    cmd = nil
                end
                local res = tbl:match('^{.*}$') and loadstring('return ' .. tbl)
                if res then
                    local ok, opts = pcall(res)
                    if not ok then
                        vim.notify('Wrong table from modeline: ' .. tbl)
                    end
                    tbl = ok and opts or nil
                else
                    tbl = nil
                end
                return tbl, cmd
            end
        end
    end
end

--- @class RecallOptions
--- @field feedcmd(boolean|nil) Feed command into command line

--- @type string|function
local __cmdfn
--- Store/recall command or function
--- @param cmdfn(string|function) Vim command string or function
--- @param opts(RecallOptions|nil)
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
-- async
--------------------------------------------------------------------------------
--- @class AsyncSubModule
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
--- @alias PopSelectionEvent function

--- Async PopSelection
--- @param sel(PopSelection)
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
-- utils
--------------------------------------------------------------------------------
--- @class UtilsSubModule
local _u = {}
M.u = _u

--- Split string arguments with blanks
--- Attention: currently each arg can't contain any blanks.
--- @return table List of arguments
function _u.str2arg(str) return vim.split(str, '%s+', { trimempty = true }) end

--- Parse string to table of environment variables
--- @param str(string) Input with format 'VAR0=var0 VAR1=var1'
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
--- @param cmd(string) String command with format 'cmd {arg}'
--- @param rep(table) Replacement with { arg = 'val' }
function _u.replace(cmd, rep) return vim.trim(string.gsub(cmd, '{(%w+)}', rep)) end

--- Sequence commands
--- @param cmdlist(table<string>) Command list to join with ' && '
function _u.sequence(cmdlist) return table.concat(cmdlist, ' && ') end

--- Deep copy variable
--- @param mt(boolean|nil) Copy metatable or not
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
--- @param dst(table) The table to merge into, and metable will be keeped
--- @param src(table) The table to merge from
--- @param mask(table|nil) Mask what will be merged from `src`, nil means all masked
function _u.deepmerge(dst, src, mask)
    for k, v in pairs(src) do
        if (not mask) or vim.tbl_contains(mask, k) then
            if type(v) == 'table' then
                if type(dst[k]) ~= 'table' then
                    dst[k] = {}
                end
                _u.deepmerge(dst[k], v, mask and mask[k])
            else
                rawset(dst, k, v)
            end
        end
    end
end

--------------------------------------------------------------------------------
-- map
--------------------------------------------------------------------------------
--- @class MapSubModule
local _m = {}
M.m = _m

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
--- 'map' and 'mnore' works at normal and visual mode by default here
--- ```lua
---      local m = require('v.libv').m
---      m.add({'n', 'v'}, {'<leader>', ':echo b:<CR>', buffer = true})
---      m.nore{'<leader>', ':echo b:<CR>', silent = true, buffer = 9}
--- ```
--- @param mods(string|table) Mapping modes
--- @param opts(table) Mapping options with {lhs, rhs, **kwargs}
-- stylua: ignore start
function _m.add(mods, opts)     setmap(mods, opts[1], opts[2], setopts(opts, { remap = true })) end
function _m.addnore(mods, opts) setmap(mods, opts[1], opts[2], setopts(opts, { noremap = true })) end

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
