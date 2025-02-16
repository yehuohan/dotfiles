local nlib = require('v.nlib')
local a = nlib.a
local async = a._async
local await = a._await
local replace = nlib.u.replace
local sequence = nlib.u.sequence
local task = require('v.task')
local throw = error

--- @type Configer Workspace config for code
--- Support modeline: vim@code{ style = 'term', efm = [[%l:%c]], efm_fts = {...}, ... }: ...
local wsc = nlib.new_configer({
    key = '',
    file = '',
    type = '',
    envs = '',
    barg = '',
    earg = '',
    msvc = false, -- Setup msvc environment
    outer = true, -- Prioritize finding the outermost file relative to wdir
    style = 'ansi',
    encoding = '', -- Setup output encoding
    verbose = '',
})

--- @class CodeVars
--- @field barg(string) Build arguments
--- @field bsrc(string) Build source file
--- @field bout(string) Build output file
--- @field earg(string) Execution arguments

--- @class CodeTable Single code file tasks according to filetype
--- For codes: cmd {barg} {bsrc} => {bout} {earg}
-- stylua: ignore start
local codes = {
    nvim       = { cmd = 'nvim {barg} -l {bsrc} {earg}' },
    c          = { cmd = 'gcc {barg} {bsrc} -o "{bout}" && "./{bout}" {earg}',
                   efm = [[%f:%l:%c: %m]] },
    cpp        = { cmd = 'g++ -std=c++20 {barg} {bsrc} -o "{bout}" && "./{bout}" {earg}',
                   efm = [[%f:%l:%c: %m]] },
    rust       = { cmd = IsWin() and 'rustc {barg} {bsrc} -o "{bout}.exe" && "./{bout}" {earg}'
                                  or 'rustc {barg} {bsrc} -o "{bout}" && "./{bout}" {earg}',
                   efm = { [[%Eerror:%m,%C %#%[%^ ]%# %#%f:%l:%c %#,]]
                        .. [[%Wwarning:%m,%C %#%[%^ ]%# %#%f:%l:%c %#]],
                           [[ %#%[%^ ]%# %#%f:%l:%c %#]] }},
    python     = { cmd = 'python {bsrc} {earg}',
                   efm = [[%*\sFile \"%f\"\, line %l\, %m,]]
                      .. [[%*\sFile \"%f\"\, line %l]] },
    lua        = { cmd = 'lua {bsrc} {earg}', efm = [[%.%#: %f:%l: %m, %#%f:%l: %m]] },
    julia      = { cmd = 'julia {bsrc} {earg}' },
    glsl       = { cmd = 'glslangValidator {earg} {bsrc}', efm = [[%+P%f,ERROR: %c:%l: %m,%-Q]] },
    java       = { cmd = 'javac {barg} {bsrc} && java "{bout}" {earg}' },
    javascript = { cmd = 'node {bsrc} {earg}', efm = [[%f:%l]] },
    typescript = { cmd = 'node {bsrc} {earg}', efm = [[%f:%l]] },
    just       = { cmd = 'just -f {bsrc} {earg}',
                   efm = { [[%Eerror:%m,%C %#%[%^ ]%# %#%f:%l:%c %#]],
                           [[ %#%[%^ ]%# %#%f:%l:%c %#]] }},
    make       = { cmd = 'make -f {bsrc} {earg}', efm = [[make: *** [%f:%l:%m] Error %n]] },
    cmake      = { cmd = 'cmake {earg} -P {bsrc}', efm = [[%ECMake Error at %f:%l:]] },
    sh         = { cmd = 'bash ./{bsrc} {earg}',
                   efm = [[%f: 行 %l: %m,%f: line %l: %m]] },
    ps1        = { cmd = 'Powershell -ExecutionPolicy Bypass -File {bsrc} {earg}',
                   efm = [[所在位置 %f:%l 字符: %c,At %f:%l char:%c]],
                   enc = 'cp936' },
    dosbatch   = { cmd = '{bsrc} {earg}', enc = 'cp936' },
    html       = { cmd = 'firefox {bsrc}' },
    json       = { cmd = 'python -m json.tool {bsrc}' },
    typst      = { cmd = 'typst compile {bsrc} && sioyek "{bout}.pdf"',
                   efm = { [[%Eerror:%m,%C %#%[%^ ]%# %#%\%\%\%\?%\%\%f:%l:%c %#]],
                           [[ %#%[%^ ]%# %#%\%\%\%\?%\%\%f:%l:%c %#]] }},
    tex        = { cmd = 'xelatex -file-line-error {bsrc} && sioyek "{bout}.pdf"', efm = [[%f:%l: %m]] },
}
-- stylua: ignore end

--- @class PackTable Project package tasks
local packs = {
    just = 'just {barg}',
    make = 'make {barg}',
    cargo = 'cargo {barg} -- {earg}',
    _pats = {
        phony = [[^%.PHONY:%s*([%w%-_]+)%s*$]], -- .PHONY: <barg>
    },
    _msvc = 'vcvars64.bat',
}

--- Fetch and combine errorformats
--- @param types(string[])
--- @return string[]
local function fetch_efm(types)
    local res1 = {}
    local res2 = {}
    for _, ft in ipairs(types) do
        local efm = codes[ft].efm
        if type(efm) == 'table' then
            res1[#res1 + 1] = efm[1]
            res2[#res2 + 1] = efm[2]
        elseif type(efm) == 'string' then
            res1[#res1 + 1] = efm
            res2[#res2 + 1] = efm
        end
    end
    return {
        table.concat(res1, ','),
        table.concat(res2, ','),
    }
end

--- @return string[]
local function pat_list(pattern, file)
    local lst = {}
    for line in io.lines(file) do
        local res = string.match(line, pattern)
        lst[#lst + 1] = res
    end
    return lst
end

--- @return string
local function pat_file(pattern)
    if not pattern then
        return vim.fs.normalize(vim.api.nvim_buf_get_name(0))
    end
    local files = vim.fs.find({ pattern }, {
        upward = true,
        type = 'file',
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        limit = wsc.outer and math.huge or 1,
    })
    return files[#files]
end

--- @class CodeHandles All task handles to produce commands
local _hdls = {}

function _hdls.nvim(cfg)
    cfg.type = 'lua'
    cfg.efm = codes.lua.efm

    local rep = {}
    rep.barg = cfg.barg
    rep.bsrc = '"' .. vim.fn.fnamemodify(cfg.file, ':t') .. '"'
    rep.earg = cfg.earg
    local tbl, cmd = nlib.modeline('code', cfg.file)
    cfg:set(tbl or {})
    cmd = cmd or codes.nvim.cmd
    if cmd:sub(1, 1) == ':' then
        vim.cmd(cmd)
        throw('Executed ' .. cmd, 0)
    end
    return replace(cmd, rep)
end

function _hdls.file(cfg)
    local ft = (cfg.type ~= '') and cfg.type or vim.o.filetype
    if (not codes[ft]) or ('dosbatch' == ft and not IsWin()) then
        throw(string.format('Code task doesn\'t support "%s"', ft), 0)
    end
    cfg.type = ft
    cfg.efm = codes[cfg.type].efm
    cfg.encoding = codes[cfg.type].enc or ''

    local rep = {}
    rep.barg = cfg.barg
    rep.bsrc = '"' .. vim.fn.fnamemodify(cfg.file, ':t') .. '"'
    rep.bout = vim.fn.fnamemodify(cfg.file, ':t:r')
    rep.earg = cfg.earg
    local tbl, cmd = nlib.modeline('code', cfg.file)
    cfg:set(tbl or {})
    cmd = cmd or codes[ft].cmd
    return replace(cmd, rep)
end

function _hdls.just(cfg)
    local rep = {}
    rep.barg = cfg.barg

    local cmds = {}
    cmds[#cmds + 1] = (IsWin() and cfg.msvc) and packs._msvc or nil
    cmds[#cmds + 1] = replace(packs.just, rep)

    local tbl, cmd = nlib.modeline('code', cfg.file)
    if tbl then
        local efm = fetch_efm(vim.list_extend(tbl.efm_fts or {}, { 'just' }))
        cfg:set(tbl)
        cfg.efm = efm
        if tbl.efm then
            cfg.efm = { tbl.efm .. ',' .. efm[1], tbl.efm .. ',' .. efm[2] }
        end
    else
        local efm = fetch_efm({ 'just', 'cmake', 'c', 'rust', 'python' })
        cfg.efm = efm
    end
    cmd = cmd or sequence(cmds)
    return cmd
end

function _hdls.make(cfg)
    local rep = {}
    rep.barg = cfg.barg

    local cmds = {}
    cmds[#cmds + 1] = (IsWin() and cfg.msvc) and packs._msvc or nil
    cmds[#cmds + 1] = replace(packs.make, rep)

    local tbl, cmd = nlib.modeline('code', cfg.file)
    if tbl then
        local efm = fetch_efm(vim.list_extend(tbl.efm_fts or {}, { 'make' }))
        cfg:set(tbl)
        cfg.efm = efm
        if tbl.efm then
            cfg.efm = { tbl.efm .. ',' .. efm[1], tbl.efm .. ',' .. efm[2] }
        end
    else
        local efm = fetch_efm({ 'make', 'cmake', 'c' })
        cfg.efm = efm
    end
    cmd = cmd or sequence(cmds)
    return cmd
end

function _hdls.cargo(cfg)
    cfg.efm = codes.rust.efm

    local rep = {}
    rep.barg = cfg.barg
    if rep.barg == '' then
        rep.barg = 'run'
    end
    rep.earg = cfg.earg
    return replace(packs.cargo, rep)
end

--- Dispatch task handle and return task command
--- @param rhs(CodeHandleMap)
--- @param cfg(TaskConfig)
--- @return string
local function dispatch(rhs, cfg)
    if cfg.file == '' then
        cfg.file = pat_file(rhs.pat)
        if not cfg.file then
            throw(string.format('None of %s was found!', rhs.pat), 0)
        end
    end
    cfg.wdir = vim.fs.dirname(cfg.file)
    return _hdls[rhs.fn](cfg)
end

--- @class CodeHandleArgs Provide more args for _sels
local _args = {}

function _args.nvim(dic, file)
    dic.barg.lst = {
        '--headless',
        '--noplugin',
        '-u NONE -i NONE',
    }
end

function _args.file(dic, file)
    dic.barg.lst = { '-g', '-static' }
    dic.earg.lst = { '--summary' }
end

function _args.just(dic, file)
    dic.barg.lst = nlib.u.str2arg(vim.fn.system('just --summary --unsorted -f ' .. file))
end

function _args.make(dic, file)
    dic.envs.lst = { 'PATH=.', 'BUILD_TYPE=Release' }
    dic.barg.lst = pat_list(packs._pats.phony, file)
end

function _args.cargo(dic, file)
    dic.envs.lst = { 'RUST_BACKTRACE=1', 'RUST_BACKTRACE=full' }
    dic.barg.lst = {
        'run',
        'build',
        'clean',
        'check',
        'clippy',
        'test --package <what>',
        'doc --no-deps',
    }
    dic.earg.lst = { '--nocapture' }
end

--- Update _sels.dic
--- @param rhs(CodeHandleMap)
--- @param dic(table) The _sels.dic to update
--- @return boolean
local function update_sels(rhs, dic)
    dic.envs = { lst = { 'PATH=.' }, cpl = 'environment' }
    dic.barg = { lst = {} }
    dic.earg = { lst = {} }
    if rhs then
        -- Must not save to wsc.file here, as wsc.outer may changed
        local file = pat_file(rhs.pat)
        if not file then
            vim.notify(string.format('None of %s was found to update _sels!', rhs.pat))
            return false
        end
        _args[rhs.fn](dic, file)
    end
    return true
end

--- @class CodeHandleMap
--- @field fn(string) Function name for CodeHandles
--- @field desc(string)
--- @field pat(string|nil) File pattern to get item from CodeTable or PackTable

-- stylua: ignore start
--- @type table<string,CodeHandleMap>
local _maps = {
    { 'l', 'f', 'j', 'm', 'o' },
    l = { fn = 'nvim',   desc = 'Nvim lua' },
    f = { fn = 'file',   desc = 'Single file' },
    j = { fn = 'just',   desc = 'Just',        pat = 'Justfile' },
    m = { fn = 'make',   desc = 'Make',        pat = 'Makefile' },
    o = { fn = 'cargo',  desc = 'Cargo rust',  pat = 'Cargo.toml' },
}

local _keys = {
    'Rp' , 'Rj' , 'Rm' , 'Ro' , 'Rf' , 'Rl' ,
    'rp' , 'rj' , 'rm' , 'ro' , 'rf' , 'rl' ,
    'rtp', 'rtj', 'rtm', 'rto', 'rtf', 'rtl',
    'rgp', 'rgj', 'rgm', 'rgo', 'rgf', 'rgl',
}
-- stylua: ignore end

--- @type PopSelection Selection for code task
local _sels = {
    opt = 'setup code task',
    lst = nil,
    -- lst for kt.E != p
    lst_d = { 'envs', 'barg', 'earg', 'msvc', 'outer', 'style', 'encoding', 'verbose' },
    -- lst for kt.E = p
    lst_p = { 'key', 'file', 'type', 'envs', 'barg', 'earg', 'msvc', 'style', 'encoding' },
    -- lst for CodeWscInit
    lst_i = { 'envs', 'msvc', 'outer', 'style', 'encoding', 'verbose' },
    dic = {
        key = { lst = _maps[1], dic = vim.tbl_map(function(h) return h.desc end, _maps) },
        file = { lst = {}, cpl = 'file' },
        type = { lst = { 'just', 'python' }, cpl = 'filetype' },
        envs = vim.empty_dict(),
        barg = vim.empty_dict(),
        earg = vim.empty_dict(),
        msvc = vim.empty_dict(),
        outer = vim.empty_dict(),
        style = { lst = { 'term', 'ansi', 'job' } },
        encoding = { lst = { 'utf-8', 'cp936' } },
        verbose = {
            lst = { 'a', 'w', 'e', 'h', 'r' },
            dic = {
                a = 'Enable all = wehr',
                w = 'Show code wsc',
                e = 'Disable errorformat',
                h = 'Tag highlights with (row, col-start, col-end)',
                r = 'Keep raw line string',
            },
        },
    },
    sub = {
        lst = { true, false },
        cmd = function(sopt, sel) wsc[sopt] = sel end,
        get = function(sopt) return wsc[sopt] end,
    },
}

--- @type PopSelectionEvent
local function evt_p(name)
    if name == 'onCR' then
        if wsc.file ~= '' then
            wsc.file = vim.fs.normalize(vim.fn.fnamemodify(wsc.file, ':p'))
            if wsc.type == '' then
                wsc.type = vim.filetype.match({ filename = wsc.file }) or ''
            end
        end
    end
end

--- @type PopSelectionEvent
local function evt_i(name)
    if name == 'onCR' then
        wsc:new(wsc:get())
        vim.notify('Code task wsc is reinited!')
    end
end

--- Entry of code task
--- @param kt(table) [rR][  ][p...]
---                  [%S][%A][%E  ]
--- kt.S
---     r : run task
---     R : modify code task config
--- kt.A
---     t : set wsc.style = 'term'
--- kt.E
---     ? : from _maps
---     p : run task from task.wsc.code
--- Forward
---     R^p => r^p (r^p means r[kt.E != p])
---     Rp  => rp  => r^p
local entry = async(function(kt, bang)
    wsc:new()

    local resovle = false
    local restore = false
    if kt.S == 'R' then
        -- Forward R* => r*
        _sels.lst = _sels.lst_d
        _sels.evt = nil
        resovle = true
    end
    if kt.E == 'p' then
        local __wsc = task.wsc.code
        wsc:set(__wsc, _sels.lst_p)
        if __wsc.key and _maps[__wsc.key] and not resovle then
            -- Forward rp => r^p
            kt.E = __wsc.key
        else
            -- Forward Rp => r^p
            _sels.lst = _sels.lst_p
            _sels.evt = evt_p
            resovle = true
            restore = true
        end
    end

    -- Need to resolve config
    if resovle then
        if not update_sels(_maps[kt.E], _sels.dic) then
            return
        end
        if not await(a.pop_selection(_sels)) then
            return
        end
    end
    -- Need to re-store config back
    if restore then
        kt.E = wsc.key
        task.wsc.code = wsc:get()
    end
    -- Set config
    if kt.A == 't' then
        wsc.style = 'term'
    elseif kt.A == 'g' then
        wsc.style = 'job'
    end

    -- Run task
    vim.cmd.wall({ mods = { silent = true, emsg_silent = true } })
    wsc.key = kt.E
    local ok, msg = pcall(function()
        wsc.cmd = dispatch(_maps[wsc.key], wsc)
        wsc.tout = {
            efm = wsc.efm,
            open = true,
            jump = false,
            scroll = true,
            append = false,
            title = task.title.Code,
            style = wsc.style,
            encoding = wsc.style == 'job' and wsc.encoding or '',
            verbose = bang and 'a' or wsc.verbose,
        }
        if wsc.tout.verbose:match('[ae]') then
            wsc.tout.efm = ' '
        end
        if wsc.tout.verbose:match('[aw]') then
            vim.notify(('resovle = %s, restore = %s\n%s'):format(resovle, restore, vim.inspect(wsc)))
        end
        task.run(wsc)
        nlib.recall(function() task.run(wsc) end)
    end)
    if not ok then
        vim.notify(tostring(msg))
    end
end)

local function setup()
    task.wsc.code = wsc:get()

    -- Keys mapping to table
    local keys2kt = function(keys)
        return {
            S = keys:sub(1, 1),
            A = keys:sub(2, -2),
            E = keys:sub(-1, -1),
        }
    end
    for _, keys in ipairs(_keys) do
        nlib.m.nnore({ '<leader>' .. keys, function() entry(keys2kt(keys)) end })
    end
    nlib.m.nnore({
        '<leader>rv',
        function()
            local ft = vim.o.filetype
            if ft == 'lua' or ft == 'vim' then
                vim.cmd.write()
                vim.cmd.source('%')
                vim.notify('Source completed')
            end
        end,
        desc = 'Source vim script',
    })

    vim.api.nvim_create_user_command(
        'Code',
        function(opts) entry(keys2kt(opts.args), opts.bang) end,
        { bang = true, nargs = 1 }
    )
    vim.api.nvim_create_user_command('CodeWsc', function(opts)
        if opts.bang then
            wsc:new()
        end
        vim.print(wsc)
    end, { bang = true, nargs = 0 })
    vim.api.nvim_create_user_command('CodeWscInit', function()
        wsc:new()
        _sels.lst = _sels.lst_i
        _sels.evt = evt_i
        vim.fn.PopSelection(_sels)
    end, { nargs = 0 })
end

return { setup = setup }
