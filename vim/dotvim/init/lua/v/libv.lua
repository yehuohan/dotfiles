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
---     - keep_ansi_color(boolean) Keep ANSI color code or not
---     - keep_raw(boolean) Keep raw output (^M is still cleaned)
function M.new_ansior(opts)
    local keep_ansi_color = opts and opts.keep_ansi_color
    local keep_raw = opts and opts.keep_raw

    local cur_row = 1
    local buf_idx = 1
    local buffers = { '' }

    --- Trim all ANSI code and invalid chars
    local function trim_line(str)
        return str
            :gsub('\x1b%].*[\x07\x9c]', '') -- Remove OSC code
            :gsub('\x1b%[[%d%?;]*[a-zA-Z]', '') -- Remove all ANSI code
    end

    --- Generate next line that ends with a CSI(Control Sequence Introducer) code
    local function next_csi(str)
        -- K: erase in line
        -- H: set cursor position
        -- m: set SGR(Select Graphic Rendition) -- TODO highlight ANSI color
        local pat = '\x1b%[([%d:;<=>%?]*)([KH])'
        local ci = 1

        return function()
            if ci < 0 then
                return nil
            end
            local si, ei, args, byte = string.find(str, pat, ci)
            if si then
                local line = string.sub(str, ci, ei)
                ci = ei + 1
                return line, args, byte
            else
                local line = string.sub(str, ci)
                ci = -1
                return line
            end
        end
    end

    --- Process lines
    --- @param lines(table) Table to store processed lines
    --- @param str(string) String to be processed
    local function process_lines(lines, str)
        for line, args, byte in next_csi(str) do
            lines[#lines + 1] = line
            cur_row = cur_row + 1

            -- Get lastest cursor row
            local row = nil
            if byte == 'H' then
                row = string.match(args, '(%d*);*%d*')
                row = (row ~= '') and tonumber(row) or 1
            end

            -- Update current cursor row
            while row and cur_row ~= row do
                if cur_row < row then
                    lines[#lines + 1] = ' '
                    cur_row = cur_row + 1
                else
                    lines[#lines] = nil
                    cur_row = cur_row - 1
                end
            end
        end
    end

    --- ANSI data stream to process
    --- If data is nil, all buffers will be processed and returned
    return function(data)
        local lines = {}

        -- Append data to buffers
        local ei = #buffers
        if data then
            -- local eof = (#data == 1 and data[1] == '')
            buffers[#buffers] = buffers[#buffers] .. data[1]
            vim.list_extend(buffers, data, 2)
            ei = ei - 5 -- Delay for cursor computation
        end
        -- Process buffers to lines
        for idx = buf_idx, ei, 1 do
            local str = buffers[idx]:gsub('\r', '') -- Remove ^M
            if keep_ansi_color then
                if str ~= '' then
                    process_lines(lines, str)
                end
            else
                lines[#lines + 1] = str
            end
            buf_idx = buf_idx + 1
        end
        -- All buffers are processed and to be returned
        if not data then
            cur_row = 1
            buf_idx = 1
            buffers = { '' }
        end

        return keep_raw and lines or vim.tbl_map(trim_line, lines)
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
