local a = require('v.libv').a
local async = a._async
local await = a._await
local replace = require('v.task').replace

--- Workspace config for fzer
local wsc = require('v.libv').new_configer({
    envs = '',
    path = '',
    pathlst = {},
    filters = '',
    globlst = '!__VBuildOut',
    options = '',
    vimgrep = false,
    fuzzier = 'leaderf',
})

--- Fuzzy finder tasks
--- @var opt(string) Options
--- @var pat(string) Pattern
--- @var loc(string) Location
local fzer = {
    rg = 'rg --vimgrep -F {opt} -e "{pat}" "{loc}"',
    fzf = {
        file = ':FzfFiles {pat}',
        live = ':FzfRg {pat}',
        tags = ':FzfTags {pat}',
    },
    leaderf = {
        file = ':Leaderf file --input "{pat}"',
        live = ':Leaderf rg --nowrap --input "{pat}"',
        tags = ':Leaderf tag --nowrap --input "{pat}"',
    },
    telescope = {
        file = ':lua require("telescope.builtin").find_files({search_file="{pat}"})',
        live = ':lua require("telescope.builtin").live_grep({placeholder="{pat}"})',
        tags = ':lua require("telescope.builtin").tags({placeholder="{pat}"})',
    },
}

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
-- stylua: ignore end

local _sels = {
    opt = 'config fzer task',
    lst = nil,
    -- lst for rg
    lst_r = { 'envs', 'path', 'filters', 'globlst', 'options', 'vimgrep' },
    -- lst for fuzzier
    lst_f = { 'envs', 'path', 'fuzzier' },
    dic = {
        envs = { lst = { 'PATH=' }, cpl = 'environment' },
        path = {
            dsr = 'cached fzer path list',
            lst = wsc.pathlst,
            cpl = 'file',
        },
        filters = { dsr = function() return '-g*.{' .. wsc.filters .. '}' end },
        globlst = {
            dsr = function()
                return '-g' .. vim.fn.join(vim.fn.split(wsc.globlst, [[\s*,\s*]]), ' -g')
            end,
            cpl = 'file',
        },
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
            wsc.path = vim.fs.normalize(vim.fn.fnamemodify(wsc.path, ':p'))
            if wsc.path ~= '' and (not vim.tbl_contains(wsc.pathlst, wsc.path)) then
                table.insert(wsc.pathlst, wsc.path)
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
        local selected = require('v.libv').get_selected()
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
    local loc = ''
    if kt.B == 'b' then
        loc = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    elseif kt.B == 'p' then
        loc = vim.fn.input('Location: ', '', 'file')
        if loc ~= '' then
            -- Input multi-paths with '|' separated
            local loclst = vim.tbl_map(
                function(ps) return vim.fs.normalize(vim.fn.fnamemodify(ps, ':p')) end,
                vim.fn.split(loc, '|')
            )
            loc = vim.fn.join(loclst, '" "')
        end
    else
        loc = wsc.path
        if loc == '' then
            local dirs = vim.fs.find({ '.git' }, {
                upward = true,
                type = 'directory',
                path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
                limit = math.huge,
            })
            loc = dirs[#dirs] and vim.fs.dirname(dirs[#dirs]) or ''
            if loc == '' then
                loc = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
            else
                wsc.path = loc
                table.insert(wsc.pathlst, loc)
            end
        end
    end
    return loc
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
    if not kt.A:match('[bp]') then
        if wsc.filters ~= '' then
            opt[#opt + 1] = '-g"*.{' .. wsc.filters .. '}"'
        end
        if wsc.globlst ~= '' then
            opt[#opt + 1] = '-g' .. vim.fn.join(vim.fn.split(wsc.globlst, [[\s*,\s*]]), ' -g')
        end
        if wsc.options ~= '' then
            opt[#opt + 1] = wsc.options
        end
    end
    return table.concat(opt, ' ')
end

--- Entry of fzer task
--- @param kt(table): [fF][av][bp][IiWwSsYyUu]
---                   [%1][%2][%3][4%        ]
--- %1 = km.S
---     F : find with modified task parameters
--- %2 = km.A
---     '': find with wsc
---     a : append results
--- %3 = km.B
---     '': find with wsc
---     b : use current buffer
---     p : input paths
--- %4 = km.E
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

    -- Parse rg command
    local rep = {}
    rep.pat = parse_pat(kt)
    if rep.pat == '' then
        return
    end
    rep.pat = vim.fn.escape(rep.pat, '"')

    if kt.S == 'F' then
        _sels.lst = _sels.lst_r
        _sels.dic.path.lst = wsc.pathlst
        if not await(a.pop_selection(_sels)) then
            return
        end
        require('v.task').wsc.fzer = wsc:get()
    end

    rep.loc = parse_loc(kt)
    if rep.loc == '' then
        return
    end
    rep.opt = parse_opt(kt)
    wsc.cmd = replace(fzer.rg, rep)

    -- Run fzer task
    wsc.qf_append = (kt.A == 'a')
    if not wsc.qf_append then
        require('v.task').hlstr = {}
    end
    table.insert(require('v.task').hlstr, rep.pat)
    if bang then
        vim.notify(vim.inspect(wsc))
    end
    wsc.qf_save = false
    wsc.qf_open = true
    wsc.qf_jump = true
    wsc.qf_scroll = false
    wsc.qf_title = 'v.task.fzer'
    wsc.connect_pty = false
    wsc.hl_ansi_sgr = false
    wsc.out_rawdata = false
    require('v.task').run(wsc)
end)

local function setup()
    require('v.task').wsc.fzer = wsc:get()

    -- Keys mapping to table
    local keys2kt = function(keys)
        return {
            S = keys:sub(1, 1),
            A = keys:sub(2, -2):sub(1, 1),
            B = keys:sub(2, -2):sub(-1, -1),
            E = keys:sub(-1, -1),
        }
    end
    local m = require('v.libv').m
    for _, keys in ipairs(_keys) do
        m.nore({ '<leader>' .. keys, function() entry(keys2kt(keys)) end })
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
