--- Neovim lua library
local M = {}

--- Create new config
function M.new_config(opt)
    if type(opt) ~= 'table' then
        error('Initial config shoule be a table')
    end

    -- Create initial values
    local initialization = vim.deepcopy(opt)

    -- Config's non-savable options
    local non_savable_config = function()
        local nsc = {}
        nsc.__index = nsc
        return nsc
    end

    -- Config's methods
    local C = {}
    setmetatable(C, non_savable_config())
    C.__index = C
    C.__newindex = function(t, k, v)
        if rawget(t, k) then
            -- New savable option
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

    --- Add an option to config
    function C:add(k, v)
        rawset(self, k, v)
        initialization[k] = v
    end

    --- Delete an option from config
    function C:del(k)
        rawset(self, k, nil)
        initialization[k] = nil
    end

    --- Get only savable options as a table
    function C:get()
        local t = {}
        for k, v in pairs(self) do
            if type(v) == 'table' then
                t[k] = vim.deepcopy(v)
            else
                t[k] = v
            end
        end
        return t
    end

    --- Setup config's current options
    --- * All savable options will be extend with new_opt;
    --- * All non-savable options will be keeped.
    function C:set(new_opt)
        for k, v in pairs(new_opt) do
            if type(v) == 'table' then
                rawset(self, k, vim.deepcopy(v))
            else
                rawset(self, k, v)
            end
        end
    end

    --- Reinit config's options
    --- * The initial options will be repleaced with init_opt;
    --- * All savable options will be cleared first, then reinited with init_opt;
    --- * All non-savable options will be cleared.
    function C:reinit(init_opt)
        if init_opt then
            initialization = vim.deepcopy(init_opt)
        end
        for k, _ in pairs(self) do
            rawset(self, k, nil)
        end
        self:set(initialization)
        -- C == getmetatable(self)
        setmetatable(C, non_savable_config())
    end

    return setmetatable(opt, C)
end

--- A simple ANSI escape sequences processor for terminal's stdout
--- @param opts(table)
--      - keep_ansi_color(boolean) Keep ANSI color code or not
function M.new_ansior(opts)
    local keep_ansi_color = opts and opts.keep_ansi_color
    local cur_row = 1 -- Current cursor row position
    local pending = ''

    --- Trim all ANSI code and invalid chars
    local function trim_line(str)
        local trimed = str
            :gsub('\r$', '') -- Remove ^M
            :gsub('\x1b%].*\x07', '') -- Remove ']0;.*'
        if keep_ansi_color then
            trimed = trimed:gsub('\x1b%[[%d%?;]*[a-ln-zA-Z]', '') -- Keep ANSI color only
        else
            trimed = trimed:gsub('\x1b%[[%d%?;]*[a-zA-Z]', '') -- Remove all ANSI code
        end
        return trimed
    end

    --- Generate next line with the lastest cursor row position
    local function next_line(str)
        local pat = '\x1b%[(%d*);%d*H'
        -- local pats = {
        --     '\x1b%[(%d*)B', -- Move cursor down by N
        --     '\x1b%[(%d*)E', -- Move cursor N lines down
        --     '\x1b%[(%d*);%d*H', -- Set cursor position
        -- }
        local ci = 1

        return function()
            if ci < 0 then
                return nil
            end
            local si, ei, row = string.find(str, pat, ci)
            if si then
                local line = string.sub(str, ci, ei)
                ci = ei + 1
                return line, row and tonumber(row)
            else
                local line = string.sub(str, ci)
                ci = -1
                return line
            end
        end
    end

    --- Append processed lines
    --- @param lines(table) Table to store processed lines
    --- @param str(string) String to be processed
    local function append_lines(lines, str)
        for line, row in next_line(str) do
            table.insert(lines, line)
            repeat
                cur_row = cur_row + 1
                if row and cur_row < row then
                    -- Append blank line to catch the lastest row
                    table.insert(lines, ' ')
                end
            until (not row) or cur_row >= row
        end
    end

    return function(data)
        local lines = {}

        for idx, chunk in ipairs(data) do
            -- [''] means EOF
            if idx == 1 then
                if chunk == '' then
                    append_lines(lines, pending)
                    pending = ''
                else
                    pending = pending .. chunk
                end
            else
                if data[1] ~= '' then
                    append_lines(lines, pending)
                end
                pending = chunk
            end
        end

        return vim.tbl_map(trim_line, lines)
    end
end

--------------------------------------------------------------------------------
-- async
--------------------------------------------------------------------------------
local _a = {}

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

--- Async PopSelection
--- @retval true Selection is confirmed
--- @retval false Selected is canceled
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
-- map
--------------------------------------------------------------------------------
local _m = {}
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

M.a = _a
M.m = _m
return M
