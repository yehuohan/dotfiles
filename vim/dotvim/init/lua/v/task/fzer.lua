local nlib = require('v.nlib')
local a = nlib.a
local async = a._async
local await = a._await
local replace = nlib.u.replace
local task = require('v.task')

--- @type Configer Workspace config for fzer
local wsc = nlib.new_configer({
    envs = '',
    path = '',
    paths = {},
    glob = '!_VOut',
    globs = {},
    hidden = true,
    ignore = true,
    options = '',
    vimgrep = false,
    fuzzier = 'telescope',
})

--- @return string[]
local function rg_paths()
    -- rg supports multi-paths via cmp-path
    local locstr = vim.fn.input('Location: ', '', 'file')
    if locstr ~= '' then
        -- The return paths should be double-quoted
        return vim.tbl_map(
            function(path) return vim.fs.normalize(vim.fn.fnamemodify(path, ':p')) end,
            nlib.u.str2arg(locstr)
        )
    end
    return {}
end

--- @return string[]
local function rg_globs()
    if wsc.glob ~= '' then
        return vim.tbl_map(
            function(glob) return ('-g%s'):format(glob) end,
            nlib.u.str2arg(wsc.glob)
        )
    end
    return {}
end

--- @return string[]
local function rg_hidden() return wsc.hidden and { '--hidden' } or {} end

--- @return string[]
local function rg_ignore() return wsc.ignore and {} or { '--no-ignore' } end

--- @class FzerVars
--- @field opt(string) Options
--- @field pat(string) Pattern
--- @field loc(string) Location

--- @class Fuzzier
--- @field file(string|function)
--- @field live(string|function)
--- @field tags(string|function)

--- @class FzerTable Fuzzy finder tasks
--- @field rg(string)
--- @field fzf(Fuzzier)
--- @field leader(Fuzzier)
--- @field telescope(Fuzzier)
local fzer = {
    rg = 'rg --vimgrep -F {opt} -e "{pat}" {loc}',
    fzf = {
        file = ':FzfFiles {loc}',
        live = function(rep)
            if IsWin() then
                rep.loc = string.gsub(rep.loc, '/', '\\') -- Fzf preview needs '\' path
            end
            local grep_cmd = replace(
                'rg --column --line-number --no-heading --color=always --smart-case {opt} -e "{pat}" {loc}',
                rep
            )
            vim.fn['fzf#vim#grep'](grep_cmd, vim.fn['fzf#vim#with_preview'](), 0)
        end,
        tags = ':FzfTags {pat}',
    },
    leaderf = {
        file = ':Leaderf file --input "{pat}" "{loc}"',
        live = ':Leaderf rg --nowrap {opt} -e "{pat}" {loc}',
        tags = ':Leaderf tag --nowrap --input "{pat}"',
    },
    telescope = {
        file = 'find_files',
        live = 'grep_string',
        tags = 'tags',
    },
}

setmetatable(fzer.fzf, {
    __call = function(self, rhs, args)
        local rep = {
            pat = args.pat,
            loc = table.concat(args.loc, ' '),
            opt = table.concat(args.opt, ' '),
        }
        local strfn = self[rhs]
        if type(strfn) == 'function' then
            self[rhs](rep)
        elseif type(strfn) == 'string' then
            local cmd = replace(strfn, rep)
            vim.cmd(cmd)
        end
    end,
})

setmetatable(fzer.leaderf, {
    __call = function(self, rhs, args)
        local rep = {
            pat = args.pat,
            loc = table.concat(args.loc, ' '),
            opt = table.concat(args.opt, ' '),
        }
        local cmd = replace(self[rhs], rep)
        vim.cmd(cmd)
    end,
})

setmetatable(fzer.telescope, {
    __call = function(self, rhs, args)
        local picker = self[rhs]
        require('telescope.builtin')[picker]({
            cwd = args.loc[1],
            hidden = wsc.hidden, -- For find_files
            no_ignore = not wsc.ignore, -- For find_files
            search_file = args.pat ~= '' and args.pat or nil, -- For find_files
            search_dirs = args.loc, -- For find_files, grep_string
            search = args.pat, -- For grep_string
            additional_args = args.opt, -- For grep_string with rg
            -- ctags_file = '', -- For tags
        })
    end,
})

-- stylua: ignore start
local _keys = {
     'fi',  'fbi',  'fpi',  'Fi',  'fI',  'fbI',  'fpI',  'FI',
     'fw',  'fbw',  'fpw',  'Fw',  'fW',  'fbW',  'fpW',  'FW',
     'fs',  'fbs',  'fps',  'Fs',  'fS',  'fbS',  'fpS',  'FS',
     'fy',  'fby',  'fpy',  'Fy',  'fY',  'fbY',  'fpY',  'FY',
     'fu',  'fbu',  'fpu',  'Fu',  'fU',  'fbU',  'fpU',  'FU',
    'fai', 'fabi', 'fapi', 'Fai', 'faI', 'fabI', 'fapI', 'FaI',
    'faw', 'fabw', 'fapw', 'Faw', 'faW', 'fabW', 'fapW', 'FaW',
    'fas', 'fabs', 'faps', 'Fas', 'faS', 'fabS', 'fapS', 'FaS',
    'fay', 'faby', 'fapy', 'Fay', 'faY', 'fabY', 'fapY', 'FaY',
    'fau', 'fabu', 'fapu', 'Fau', 'faU', 'fabU', 'fapU', 'FaU',
}

local _keys_fuzzier = {
    'ff', 'fpf', 'Ff',
    'fl', 'fpl', 'Fl',
    'fh', 'fph', 'Fh',
}

local _maps_fuzzier = { f = 'file', l = 'live', h = 'tags' }
-- stylua: ignore end

--- @type PopSelection Selection for fzer task
local _sels = {
    opt = 'config fzer task',
    lst = nil,
    -- lst for rg
    lst_r = { 'envs', 'path', 'glob', 'hidden', 'ignore', 'options', 'vimgrep' },
    -- lst for fuzzier
    lst_f = { 'envs', 'path', 'glob', 'hidden', 'ignore', 'options', 'fuzzier' },
    dic = {
        envs = { lst = { 'PATH=' }, cpl = 'environment' },
        path = { dsr = 'cached fzer path list', lst = wsc.paths, cpl = 'file' },
        glob = { dsr = function() return table.concat(rg_globs(), ' ') end, lst = wsc.globs },
        hidden = vim.empty_dict(),
        ignore = vim.empty_dict(),
        options = { lst = { '-w', '-i', '-s', '-S', '--no-fixed-strings', '--encoding gbk' } },
        vimgrep = vim.empty_dict(),
        fuzzier = { lst = { 'fzf', 'leaderf', 'telescope' } },
    },
    evt = function(name)
        if name == 'onCR' then
            if wsc.path ~= '' then
                wsc.path = vim.fs.normalize(vim.fn.fnamemodify(wsc.path, ':p'))
                if not vim.tbl_contains(wsc.paths, wsc.path) then
                    table.insert(wsc.paths, wsc.path)
                end
            end
            if wsc.glob ~= '' then
                if not vim.tbl_contains(wsc.globs, wsc.glob) then
                    table.insert(wsc.globs, wsc.glob)
                end
            end
            wsc:reinit(wsc:get())
        end
    end,
    sub = {
        lst = { true, false },
        cmd = function(sopt, sel) wsc[sopt] = sel end,
        get = function(sopt) return wsc[sopt] end,
    },
}

--- @return string
local function parse_pat(kt)
    local pat = ''
    if vim.fn.mode() == 'n' then
        if kt.E:match('[iI]') then
            pat = vim.fn.input('Pattern: ')
        elseif kt.E:match('[wWsS]') then
            pat = vim.fn.expand('<cword>')
        end
    else
        local selected = nlib.get_selected()
        if kt.E:match('[iI]') then
            pat = vim.fn.input('Pattern: ', selected)
        elseif kt.E:match('[wWsS]') then
            pat = selected
        end
    end
    if kt.E:match('[yY]') then
        pat = vim.fn.getreg('0')
    elseif kt.E:match('[uU]') then
        pat = vim.fn.getreg('+')
    end
    return pat
end

--- @return string[]
local function parse_loc(kt)
    local loc = {}
    local restore = false
    if kt.B == 'b' then
        loc = { vim.fs.normalize(vim.api.nvim_buf_get_name(0)) }
    elseif kt.B == 'p' then
        loc = rg_paths()
        if #loc > 0 then
            if wsc.path == '' then
                wsc.path = loc[1]
            end
            for _, dir in ipairs(loc) do
                if not vim.tbl_contains(wsc.paths, dir) then
                    table.insert(wsc.paths, dir)
                end
            end
            restore = true
        end
    else
        if wsc.path == '' then
            wsc.path = nlib.try_root() or vim.fs.dirname(vim.api.nvim_buf_get_name(0))
            if not vim.tbl_contains(wsc.paths, wsc.path) then
                table.insert(wsc.paths, wsc.path)
            end
            restore = true
        end
        loc = { wsc.path }
    end
    -- Need reinit wsc when modified path or paths
    if restore then
        wsc:reinit(wsc:get())
        task.wsc.fzer = wsc:get()
    end
    return loc
end

--- @return string[]
local function parse_opt(kt)
    local opt = {}
    if kt.E:match('[sS]') then
        opt[#opt + 1] = '-w' -- --word-regexp
    end
    if kt.E:match('[iwsyu]') then
        opt[#opt + 1] = '-i' -- --ignore-case
    elseif kt.E:match('[IWSYU]') then
        opt[#opt + 1] = '-s' -- --case-sensitive
    end
    if not kt.A:match('[p]') then
        -- Custom paths may conflict with rg's glob and ignore rules
        vim.list_extend(opt, rg_globs())
        vim.list_extend(opt, rg_hidden())
        vim.list_extend(opt, rg_ignore())
    end
    if wsc.options ~= '' then
        vim.list_extend(opt, nlib.u.str2arg(wsc.options))
    end
    return opt
end

--- Entry of fzer task
--- @param kt(table): [fF][av][bp][IiWwSsYyUu]
---                   [%S][%A][%B][%E        ]
--- kt.S
---     F : find with modified fzer task config
--- kt.A
---     '': find with wsc
---     a : append results
--- kt.B
---     '': find with wsc
---     b : use current buffer
---     p : input path
--- kt.E
---     y : text from register "0
---     u : text from register "+ (clipboard of system)
---     Normal Mode:
---         i : input
---         w : word
---         s : word with boundaries
---     Visual Mode:
---         i : input with selected
---         w : visual with selected
---         s : selected with boundaries
---     LowerCase: [iwsyu] ignorecase
---     UpperCase: [IWSYU] case insensitive
local entry = async(function(kt, bang)
    wsc:reinit()

    -- Parse rg pattern
    local rep = {}
    rep.pat = parse_pat(kt)
    if rep.pat == '' then
        return
    end
    rep.pat = vim.fn.escape(rep.pat, '"')

    -- Modify fzer config
    if kt.S == 'F' then
        _sels.lst = _sels.lst_r
        _sels.dic.path.lst = wsc.paths
        _sels.dic.glob.lst = wsc.globs
        if not await(a.pop_selection(_sels)) then
            return
        end
        task.wsc.fzer = wsc:get()
    end

    -- Parse rg location and options
    rep.loc = table.concat(parse_loc(kt), ' ')
    if rep.loc == '' then
        return
    end
    rep.opt = table.concat(parse_opt(kt), ' ')

    -- Run fzer task
    wsc.cmd = replace(fzer.rg, rep)
    wsc.wdir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    wsc.tout = {
        open = true,
        jump = true,
        scroll = false,
        append = kt.A == 'a',
        title = task.title.Fzer,
        style = 'job',
        encoding = '',
        verbose = bang and 'a',
    }
    if not wsc.tout.append then
        task.hlstr = {}
    end
    table.insert(task.hlstr, rep.pat)
    if bang then
        vim.notify(vim.inspect(wsc))
    end
    task.run(wsc)
    nlib.recall(function() task.run(wsc) end)
end)

--- Entry of fzer.fuzzier task
--- @param kt(table): [fF][p   ][flh]
---                   [%S][%A/B][%E ]
--- kt.S
---     F : fuzzier with inputing args
--- kt.A/B
---     p : input temp path
--- kt.E
---     f : fuzzier.file
---     l : fuzzier.live
---     h : fuzzier.tags with <cword> by default
local entry_fuzzier = async(function(kt)
    wsc:reinit()

    -- Parse fuzzier pattern
    local rep = { pat = '' }
    if vim.fn.mode() == 'n' then
        if kt.E == 'h' then
            rep.pat = vim.fn.expand('<cword>')
        end
    else
        rep.pat = nlib.get_selected()
    end

    -- Modify fzer.fuzzier config
    if kt.S == 'F' then
        _sels.lst = _sels.lst_f
        _sels.dic.path.lst = wsc.paths
        _sels.dic.glob.lst = wsc.globs
        if not await(a.pop_selection(_sels)) then
            return
        end
        task.wsc.fzer = wsc:get()
    end

    -- Parse location for fuzzier and options for fuzzier.live
    rep.loc = parse_loc(kt)
    if #rep.loc == 0 then
        return
    end
    rep.opt = parse_opt(kt)

    -- Run fzer.fuzzier task
    local rhs = _maps_fuzzier[kt.E]
    fzer[wsc.fuzzier](rhs, rep)
    nlib.recall(function() fzer[wsc.fuzzier](rhs, rep) end)
end)

local function setup()
    task.wsc.fzer = wsc:get()

    -- Keys mapping to table
    local keys2kt = function(keys)
        return {
            S = keys:sub(1, 1),
            A = keys:sub(2, -2):sub(1, 1),
            B = keys:sub(2, -2):sub(-1, -1),
            E = keys:sub(-1, -1),
        }
    end
    for _, keys in ipairs(_keys) do
        nlib.m.nore({ '<leader>' .. keys, function() entry(keys2kt(keys)) end })
    end
    for _, keys in ipairs(_keys_fuzzier) do
        nlib.m.nore({ '<leader>' .. keys, function() entry_fuzzier(keys2kt(keys)) end })
    end

    vim.api.nvim_create_user_command(
        'Fzer',
        function(opts) entry(keys2kt(opts.args), opts.bang) end,
        { bang = true, nargs = 1 }
    )
    vim.api.nvim_create_user_command('FzerWsc', function(opts)
        if opts.bang then
            wsc:reinit()
        end
        vim.print(wsc)
    end, { bang = true, nargs = 0 })
end

return {
    setup = setup,
    setwsc = function(__wsc)
        wsc:set(__wsc)
        wsc:reinit(wsc:get())
    end,
}
