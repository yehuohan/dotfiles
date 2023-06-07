--- Neovim lua library
local M = {}

--- An useful configer
function M.new_configer(opt)
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
--- @param opts(table) Passed from 'on_quickfix.params'
function M.new_ansior(opts)
    local connect_pty = opts and opts.connect_pty
    local out_rawline = opts and opts.out_rawline
    local hl_ansi_sgr = opts and opts.hl_ansi_sgr

    local ansi = require('v.libv.ansi')
    local cur_row = 1
    local cur_col = 1
    local erased_rows = 0
    local raw_idx = 1
    local raw_lines = {}
    local pending = ''
    local none = true

    --- Process raw lines
    --- @param str(string) String to be processed
    --- @param is_pending(boolean|nil) Is str a pending string or not
    --- @return string|nil Pending string that can't be break into multi-lines
    local function process_lines(str, is_pending)
        str = str:gsub('\r', '') -- Remove ^M

        if not connect_pty then
            if not is_pending then
                raw_lines[#raw_lines + 1] = str
            else
                return str
            end
            return
        end

        -- Process CSI code
        for last, line, args, byte in ansi.next_csi(str, ansi.CSI.Line) do
            -- The rest pending line shouldn't append into raw lines
            if is_pending and last then
                return line
            end

            -- Append a raw line at cursor position
            if line ~= '' then
                raw_lines[#raw_lines + 1] = string.rep(' ', cur_col) .. line
                cur_row = cur_row + 1
                cur_col = 1
            end

            -- Get lastest cursor position
            local row, col = nil, nil
            if byte == 'H' then
                row, col = string.match(args, '(%d*);?(%d*)')
                row = (row ~= '') and tonumber(row) or 1
                col = (col ~= '') and tonumber(col) or 1
            elseif byte == 'K' then
                -- local n = string.match(args, '(%d)K')
                -- n = (n ~= '') and tonumber(n) or 0
                erased_rows = erased_rows + 1
            end

            -- Update current cursor position
            if row then
                row = row + erased_rows
                while cur_row ~= row do
                    if cur_row < row then
                        raw_lines[#raw_lines + 1] = ''
                        cur_row = cur_row + 1
                    else
                        raw_lines[#raw_lines] = nil
                        cur_row = cur_row - 1
                    end
                end
            end
            if col then
                cur_col = col
            end
        end
    end

    --- Process colors for each raw line
    local function process_colors(lines)
        local hls = {}

        local bi = raw_idx - 1 - #lines
        for k, line in ipairs(lines) do
            local hl = {}
            local trimed = ''
            for _, part, args, byte in ansi.next_csi(line, ansi.CSI.Color) do
                local part_trimed = ''
                -- Process highlights
                if part ~= '' then
                    part_trimed = ansi.trim(part)
                    local cs = string.len(trimed) -- col_start
                    local ce = cs + string.len(part_trimed) -- col_end
                    if not none then
                        hl[#hl + 1] = { 'Identifier', bi + k, cs, ce }
                    end
                    -- part_trimed = part_trimed .. ('(%d,%d,%d)'):format(bi + k, cs, ce)
                end
                -- Process current fg and bg
                if byte == 'm' then
                    -- vim.api.nvim_set_hl
                    none = (args == '' or args == '0') and true or false
                end
                trimed = trimed .. part_trimed
            end
            hls[k] = hl
            lines[k] = trimed
        end

        return hls
    end

    --- Process data stream from terminal's stdout
    --- @param data(table<string>|nil) nil means all processed raw lines should be returned
    --- @retval lines(table<string>) Processed raw lines
    --- @retval highlights(table) Processed colors
    return function(data)
        -- Process raw data into lines
        local ei = #raw_lines
        if data then
            -- local eof = (#data == 1 and data[1] == '')
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
            ei = #raw_lines - 2
        end

        -- Copy returned lines
        local lines = {}
        if ei >= raw_idx then
            lines = vim.list_slice(raw_lines, raw_idx, ei)
            raw_idx = ei + 1
        end

        -- Process colors
        local highlights = {}
        if not out_rawline then
            if hl_ansi_sgr then
                highlights = process_colors(lines)
            else
                lines = vim.tbl_map(ansi.trim, lines)
            end
        end

        -- Reset when all raw lines are returned
        if not data then
            cur_row = 1
            cur_col = 1
            erased_rows = 0

            raw_idx = 1
            raw_lines = {}
            pending = ''
            none = true
        end

        return lines, highlights
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
