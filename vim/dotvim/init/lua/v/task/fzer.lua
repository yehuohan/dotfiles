local libv = require('v.libv')
local a = libv.a
local async = a._async
local await = a._await
local task = require('v.task')
local replace = task.replace

--- @type Configer Workspace config for fzer
local wsc = libv.new_configer({
    envs = '',
    path = '',
    pathlst = {},
    globlst = '!_VOut',
    options = '',
    vimgrep = false,
    fuzzier = 'leaderf',
})

local function rg_paths()
    -- rg supports multi-paths via cmp-path
    local locstr = vim.fn.input('Location: ', '', 'file')
    if locstr ~= '' then
        -- The return paths should be double-quoted
        return vim.tbl_map(
            function(path) return vim.fs.normalize(vim.fn.fnamemodify(path, ':p')) end,
            libv.u.str2arg(locstr)
        )
    end
    return {}
end

local function rg_globs()
    if wsc.globlst ~= '' then
        return vim.tbl_map(
            function(glob) return ('-g%s'):format(glob) end,
            libv.u.str2arg(wsc.globlst)
        )
    end
    return {}
end

local function uproot()
    local dirlst = vim.fs.find({ '.git' }, {
        upward = true,
        type = 'directory',
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        limit = math.huge,
    })
    local dir = dirlst[#dirlst]
    if dir then
        dir = vim.fs.dirname(dir)
        wsc.path = dir
        table.insert(wsc.pathlst, dir)
        return dir
    end
end

--- @alias FuzzierHandle string|function
--- @class Fuzzier
--- @field file(FuzzierHandle)
--- @field live(FuzzierHandle)
--- @field tags(FuzzierHandle)

--- @class FzerTable Fuzzy finder tasks
--- @var opt(string) Options
--- @var pat(string) Pattern
--- @var loc(string) Location
local fzer = {
    rg = 'rg --vimgrep -F {opt} -e "{pat}" {loc}',
    _fzf = {
        file = ':FzfFiles {loc}',
        live = function(rep)
            if IsWin() then
                rep.loc = string.gsub(rep.loc, '/', '\\') -- Fzf preview need '\' path
            end
            local grep_cmd = replace(
                'rg --column --line-number --no-heading --color=always --smart-case {opt} -e "{pat}" {loc}',
                rep
            )
            vim.fn['fzf#vim#grep'](grep_cmd, vim.fn['fzf#vim#with_preview'](), 0)
        end,
        tags = ':FzfTags {pat}',
    },
    _leaderf = {
        file = ':Leaderf file --input "{pat}" "{loc}"',
        live = ':Leaderf rg --nowrap {opt} -e "{pat}" {loc}',
        tags = ':Leaderf tag --nowrap --input "{pat}"',
    },
    _telescope = {
        file = 'find_files',
        live = 'grep_string',
        tags = 'tags',
    },
}

function fzer.fzf(rhs, args)
    local rep = {
        pat = args.pat,
        loc = table.concat(args.loc, ' '),
        opt = table.concat(args.opt, ' '),
    }
    local strfn = fzer._fzf[rhs]
    if type(strfn) == 'function' then
        fzer._fzf[rhs](rep)
    elseif type(strfn) == 'string' then
        local cmd = replace(strfn, rep)
        vim.cmd(cmd)
    end
end

function fzer.leaderf(rhs, args)
    local rep = {
        pat = args.pat,
        loc = table.concat(args.loc, ' '),
        opt = table.concat(args.opt, ' '),
    }
    local cmd = replace(fzer._leaderf[rhs], rep)
    vim.cmd(cmd)
end

function fzer.telescope(rhs, rep)
    local picker = fzer._telescope[rhs]
    require('telescope.builtin')[picker]({
        cwd = rep.loc[1],
        search = rep.pat,
        search_file = rep.pat,
        search_dirs = rep.loc,
        additional_args = rep.opt,
    })
end

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
    lst_r = { 'envs', 'path', 'globlst', 'options', 'vimgrep' },
    -- lst for fuzzier
    lst_f = { 'envs', 'path', 'globlst', 'options', 'fuzzier' },
    dic = {
        envs = { lst = { 'PATH=' }, cpl = 'environment' },
        path = {
            dsr = 'cached fzer path list',
            lst = wsc.pathlst,
            cpl = 'file',
        },
        globlst = { dsr = function() return table.concat(rg_globs(), ' ') end },
        options = {
            lst = {
                '--word-regexp',
                '--no-fixed-strings',
                '--hidden',
                '--no-ignore',
                '--encoding gbk',
            },
        },
        vimgrep = { lst = { true, false } },
        fuzzier = { lst = { 'fzf', 'leaderf', 'telescope' } },
    },
    evt = function(name)
        if name == 'onCR' then
            if wsc.path ~= '' then
                wsc.path = vim.fs.normalize(vim.fn.fnamemodify(wsc.path, ':p'))
                if not vim.tbl_contains(wsc.pathlst, wsc.path) then
                    table.insert(wsc.pathlst, wsc.path)
                end
            end
            wsc:reinit(wsc:get())
        end
    end,
    sub = {
        cmd = function(sopt, sel) wsc[sopt] = sel end,
        get = function(sopt) return wsc[sopt] end,
    },
}

local function parse_pat(kt)
    local pat = ''
    if vim.fn.mode() == 'n' then
        if kt.E:match('[iI]') then
            pat = vim.fn.input('Pattern: ')
        elseif kt.E:match('[wWsS]') then
            pat = vim.fn.expand('<cword>')
        end
    else
        local selected = libv.get_selected()
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

local function parse_loc(kt)
    if kt.B == 'b' then
        return { vim.fs.normalize(vim.api.nvim_buf_get_name(0)) }
    elseif kt.B == 'p' then
        return rg_paths()
    else
        local loc = wsc.path
        if loc == '' then
            loc = uproot() or vim.fs.dirname(vim.api.nvim_buf_get_name(0))
        end
        return { loc }
    end
end

local function parse_opt(kt)
    local opt = {}
    if kt.E:match('[sS]') then
        opt[#opt + 1] = '-w'
    end
    if kt.E:match('[iwsyu]') then
        opt[#opt + 1] = '-i'
    elseif kt.E:match('[IWSYU]') then
        opt[#opt + 1] = '-s'
    end
    if not kt.A:match('[p]') then
        vim.list_extend(opt, rg_globs()) -- Custom paths may conflict with rg's globs
    end
    if wsc.options ~= '' then
        vim.list_extend(opt, libv.u.str2arg(wsc.options))
    end
    return opt
end

--- Entry of fzer task
--- @param kt(table): [fF][av][bp][IiWwSsYyUu]
---                   [%1][%2][%3][4%        ]
--- %1 = kt.S
---     F : find with modified fzer task config
--- %2 = kt.A
---     '': find with wsc
---     a : append results
--- %3 = kt.B
---     '': find with wsc
---     b : use current buffer
---     p : input paths
--- %4 = kt.E
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
---         y : text from register "0
---         u : text from register "+ (clipboard of system)
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
        _sels.dic.path.lst = wsc.pathlst
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
        save = false,
        open = true,
        jump = true,
        scroll = false,
        append = kt.A == 'a',
        title = task.title.Fzer,
        PTY = false,
        SGR = false,
        RAW = false,
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
    libv.recall(function() task.run(wsc) end)
end)

--- Entry of fzer.fuzzier task
--- @param kt(table): [fF][p ][flh]
---                   [%1][%2][%3 ]
--- %1 = kt.S
---     F : fuzzier with inputing args
--- %2 = kt.A/B
---     p : input temp path
--- %3 = kt.E
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
        rep.pat = libv.get_selected()
    end

    -- Modify fzer.fuzzier config
    if kt.S == 'F' then
        _sels.lst = _sels.lst_f
        _sels.dic.path.lst = wsc.pathlst
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
    libv.recall(function() fzer[wsc.fuzzier](rhs, rep) end)
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
        libv.m.nore({ '<leader>' .. keys, function() entry(keys2kt(keys)) end })
    end
    for _, keys in ipairs(_keys_fuzzier) do
        libv.m.nore({ '<leader>' .. keys, function() entry_fuzzier(keys2kt(keys)) end })
    end

    vim.api.nvim_create_user_command(
        'Fzer',
        function(opts) entry(keys2kt(opts.args), opts.bang) end,
        { bang = true, nargs = 1 }
    )
    vim.api.nvim_create_user_command('FzerWsc', function() vim.print(wsc) end, { nargs = 0 })
end

return {
    setup = setup,
    setwsc = function(__wsc)
        wsc:set(__wsc)
        wsc:reinit(wsc:get())
    end,
}
