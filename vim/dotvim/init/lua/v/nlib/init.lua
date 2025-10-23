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
    local bufs, ansi = require('v.nlib._ansi').new(verbose)
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
            bufs, ansi = require('v.nlib._ansi').new(verbose)
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
        })
        api.nvim_set_current_win(hwin) -- Avoid break original window view when closed floating windows
    end
    __term.hwin = hwin

    -- Open terminal
    if not __term.hbuf then
        __term.hbuf = hbuf
        fn.jobstart(opts and opts.cmd or { vim.o.shell }, {
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

-- M.a = require('v.nlib.libasync')
M.e = require('v.nlib.libexts')
M.u = require('v.nlib.libutils')
M.m = require('v.nlib.libkeymap')

return M
