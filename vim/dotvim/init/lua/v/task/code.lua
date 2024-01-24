local nlib = require('v.nlib')
local a = nlib.a
local async = a._async
local await = a._await
local replace = nlib.u.replace
local sequence = nlib.u.sequence
local task = require('v.task')
local throw = error

--- @type Configer Workspace config for code
local wsc = nlib.new_configer({
    key = '',
    file = '',
    type = '',
    envs = '',
    garg = '',
    barg = '',
    earg = '',
    msvc = false, -- Setup msvc environment
    stage = 'run',
    outer = true, -- Prioritize finding the outermost file relative to wdir
    style = 'ansi',
    verbose = '',
    tout = {},
})

--- @class CodeVars
--- @field barg(string) Build arguments
--- @field bsrc(string) Build source file
--- @field bout(string) Build output file
--- @field earg(string) Execution arguments
--- @field gtar(string) Generator target
--- @field garg(string) Generate arguments
--- @field stage(string) Task stage from {'build', 'run', 'clean', 'test'}

--- @class CodeTable Single code file tasks according to filetype
--- For codes: cmd {barg} {bsrc} => {bout} {earg}
-- stylua: ignore start
local codes = {
    nvim       = { cmd = 'nvim {barg} -l {bsrc} {earg}' },
    c          = { cmd = 'gcc -g {barg} {bsrc} -o "{bout}" && "./{bout}" {earg}' },
    cpp        = { cmd = 'g++ -g -std=c++20 {barg} {bsrc} -o "{bout}" && "./{bout}" {earg}' },
    rust       = { cmd = IsWin() and 'rustc {barg} {bsrc} -o "{bout}.exe" && "./{bout}" {earg}'
                                  or 'rustc {barg} {bsrc} -o "{bout}" && "./{bout}" {earg}',
                   efm = [[\ %#-->\ %f:%l:%c,\%m\ %f:%l:%c]] },
    python     = { cmd = 'python {bsrc} {earg}', efm = [[%*\sFile\ \"%f\"\,\ line\ %l\,\ %m]]
                                                    .. [[,%*\sFile\ \"%f\"\,\ line\ %l]] },
    lua        = { cmd = 'lua {bsrc} {earg}', efm = [[%.%#:\ %f:%l:\ %m]]
                                                 .. [[,\ %#%f:%l:\ %m]] },
    java       = { cmd = 'javac {barg} {bsrc} && java "{bout}" {earg}' },
    julia      = { cmd = 'julia {bsrc} {earg}' },
    go         = { cmd = 'go run {bsrc} {earg}' },
    javascript = { cmd = 'node {bsrc} {earg}' },
    typescript = { cmd = 'node {bsrc} {earg}' },
    just       = { cmd = 'just -f {bsrc} {earg}', efm = [[\ %#-->\ %f:%l:%c]] },
    make       = { cmd = 'make -f {bsrc} {earg}', efm = [[make:\ ***\ [%f:%l:\ %m]] },
    cmake      = { cmd = 'cmake {earg} -P {bsrc}', efm = [[CMake\ Error\ at\ %f:%l\ %#%m:]]
                                                      .. [[,\ \ %f:%l\ (%m)]] },
    sh         = { cmd = 'bash ./{bsrc} {earg}' },
    ps1        = { cmd = 'Powershell -ExecutionPolicy Bypass -File {bsrc} {earg}' },
    dosbatch   = { cmd = '{bsrc} {earg}' },
    glsl       = { cmd = 'glslangValidator {earg} {bsrc}', efm = [[%+P%f,ERROR:\ %c:%l:\ %m,%-Q]] },
    json       = { cmd = 'python -m json.tool {bsrc}' },
    html       = { cmd = 'firefox {bsrc}' },
    tex        = { cmd = 'xelatex -file-line-error {bsrc} && sioyek "{bout}.pdf"', efm = [[%f:%l:\ %m]] },
}
-- stylua: ignore end

--- @class PackTable Project package tasks
--- For packs: generate {garg} {gtar} => build {barg} {bout} => run/clean/test {earg}
local packs = {
    just = 'just {barg}',
    make = 'make {barg}',
    cmake = {
        'cmake -G "{gtar}" -DCMAKE_INSTALL_PREFIX=_VOut {garg} -S . -B _VOut',
        'cmake --build _VOut {barg}',
        'cmake --install _VOut',
    },
    cargo = 'cargo {stage} {barg} -- {earg}',
    _pats = {
        tar = [[^TARGET%s*:?=%s*([%w%-_]+)%s*$]], -- TARGET := <bout>
        pro = [[^project%s*%(%s*([%w%-_]+).*%).*$]], -- project(<bout>)
        pho = [[^%.PHONY:%s*([%w%-_]+)%s*$]], -- .PHONY: <barg>
    },
    _exec = '"./{bout}" {earg}',
    _msvc = 'vcvars64.bat',
    _vout = '_VOut',
}

--- @return string|nil
local function pat_text(pattern, file)
    for line in io.lines(file) do
        local res = string.match(line, pattern)
        if res then
            return res
        end
    end
end

--- @return table<string>
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

    local files = vim.fs.find(function(name, path)
        local re = vim.regex('\\c' .. pattern)
        -- Require checking file's existence, because vim.fs.normalize's bug(old version):
        -- vim.fs.normalize('C:/') will return 'C:', which is equal to '.' for vim.fs.find.
        return re:match_str(name) and (vim.fn.filereadable(path .. '/' .. name) == 1)
    end, {
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
    cfg.tout.efm = codes.lua.efm

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
    cfg.tout.efm = codes[cfg.type].efm

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
    cfg.tout.efm = codes.just.efm .. ',' .. codes.cmake.efm .. ',' .. vim.o.errorformat

    local rep = {}
    rep.barg = cfg.barg
    if cfg.stage == 'clean' then
        rep.barg = 'clean'
    end

    local cmds = {}
    cmds[#cmds + 1] = (IsWin() and cfg.msvc) and packs._msvc or nil
    cmds[#cmds + 1] = replace(packs.just, rep)

    return sequence(cmds)
end

function _hdls.make(cfg)
    cfg.tout.efm = codes.make.efm .. ',' .. codes.cmake.efm .. ',' .. vim.o.errorformat

    local rep = {}
    rep.barg = cfg.barg
    rep.bout = (cfg.stage ~= 'build') and pat_text(packs._pats.tar, cfg.file) or nil
    rep.bout = rep.bout and packs._vout .. '/' .. rep.bout
    rep.earg = cfg.earg
    if cfg.stage == 'clean' then
        rep.barg = 'clean'
        rep.bout = nil
    end

    local cmds = {}
    cmds[#cmds + 1] = (IsWin() and cfg.msvc) and packs._msvc or nil
    cmds[#cmds + 1] = replace(packs.make, rep)
    cmds[#cmds + 1] = rep.bout and replace(packs._exec, rep) or nil

    return sequence(cmds)
end

function _hdls.cmake(cfg)
    local outdir = cfg.wdir .. '/' .. packs._vout
    if cfg.stage == 'clean' then
        vim.fn.delete(outdir, 'rf')
        throw(string.format('%s was removed', outdir), 0)
    end
    vim.fn.mkdir(outdir, 'p')
    cfg.tout.efm = codes.cmake.efm .. ',' .. vim.o.errorformat

    local rep = {}
    rep.gtar = cfg.target
    rep.garg = cfg.garg
    rep.barg = cfg.barg
    rep.bout = (cfg.stage ~= 'build') and pat_text(packs._pats.pro, cfg.file) or nil
    rep.bout = rep.bout and packs._vout .. '/' .. rep.bout
    rep.earg = cfg.earg
    local cmds = {}
    cmds[#cmds + 1] = (IsWin() and cfg.msvc) and packs._msvc or nil
    cmds[#cmds + 1] = replace(packs.cmake[1], rep)
    cmds[#cmds + 1] = replace(packs.cmake[2], rep)
    cmds[#cmds + 1] = replace(packs.cmake[3], rep)
    cmds[#cmds + 1] = rep.bout and replace(packs._exec, rep) or nil

    return sequence(cmds)
end

function _hdls.cargo(cfg)
    cfg.tout.efm = codes.rust.efm

    local rep = {}
    rep.stage = cfg.stage
    rep.barg = cfg.barg
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
    cfg.target = rhs.target
    return _hdls[rhs.fn](cfg)
end

--- @class CodeHandleArgs Provide more args for _sels
local _args = {}

function _args.nvim(dic, cfg) dic.barg.lst = { '--headless', '--noplugin' } end

function _args.file(dic, cfg)
    dic.barg.lst = { '-static' }
    dic.earg.lst = { '--summary' }
end

function _args.just(dic, cfg)
    dic.barg.lst = nlib.u.str2arg(vim.fn.system('just --summary --unsorted -f ' .. cfg.file))
end

function _args.make(dic, cfg) dic.barg.lst = pat_list(packs._pats.pho, cfg.file) end

function _args.cmake(dic, cfg)
    dic.garg.lst = { '-DCMAKE_BUILD_TYPE=Release' }
    dic.barg.lst = { '--target tags', '-j4' }
end

function _args.cargo(dic, cfg)
    dic.barg.lst = { '--package <test>' }
    dic.earg.lst = { '--nocapture' }
end

--- Update _sels.dic
--- @param rhs(CodeHandleMap)
--- @param dic(table) What to update
--- @param cfg(TaskConfig)
local function update_sels(rhs, dic, cfg)
    dic.garg = { lst = {} }
    dic.barg = { lst = {} }
    dic.earg = { lst = {} }
    if rhs then
        cfg.file = pat_file(rhs.pat)
        if not cfg.file then
            vim.notify(string.format('None of %s was found!', rhs.pat))
            return false
        end
        _args[rhs.fn](dic, cfg)
    end
    return true
end

--- @class CodeHandleMap
--- @field fn(string) Function name for CodeHandles
--- @field desc(string)
--- @field pat(string|nil) File pattern to get item from CodeTable or PackTable
--- @field target(string|nil)

-- stylua: ignore start
--- @type table<string,CodeHandleMap>
local _maps = {
    { 'l', 'f', 'j', 'm', 'u', 'n', 'i', 'o' },
    l = { fn = 'nvim',   desc = 'Nvim lua' },
    f = { fn = 'file',   desc = 'Single file' },
    j = { fn = 'just',   desc = 'Just',        pat = 'Justfile' },
    m = { fn = 'make',   desc = 'Make',        pat = 'Makefile' },
    u = { fn = 'cmake',  desc = 'CMake Unix',  pat = 'CMakeLists', target = 'Unix Makefiles' },
    n = { fn = 'cmake',  desc = 'CMake NMake', pat = 'CMakeLists', target = 'NMake Makefiles' },
    i = { fn = 'cmake',  desc = 'CMake Ninja', pat = 'CMakeLists', target = 'Ninja' },
    o = { fn = 'cargo',  desc = 'Cargo rust',  pat = 'Cargo.toml' },
}

local _keys = {
    'Rp' , 'Rj' , 'Rm' , 'Ru' , 'Rn' , 'Ri' , 'Ro' , 'Rf', 'Rl',
    'rp' , 'rj' , 'rm' , 'ru' , 'rn' , 'ri' , 'ro' , 'rf', 'rl',
    'rcp', 'rcj', 'rcm', 'rcu', 'rcn', 'rci', 'rco',
    'rbp', 'rbj', 'rbm', 'rbu', 'rbn', 'rbi', 'rbo',
}
-- stylua: ignore end

--- @type PopSelection Selection for code task
local _sels = {
    opt = 'config code task',
    lst = nil,
    -- lst for kt.E != p
    lst_d = { 'envs', 'garg', 'barg', 'earg', 'msvc', 'stage', 'outer', 'style' },
    -- lst for kt.E = p
    lst_p = { 'key', 'file', 'type', 'envs', 'garg', 'barg', 'earg', 'msvc', 'stage', 'style' },
    -- lst for CodeWscInit
    lst_i = { 'envs', 'msvc', 'outer', 'style', 'verbose' },
    dic = {
        key = { lst = _maps[1], dic = vim.tbl_map(function(h) return h.desc end, _maps) },
        file = { cpl = 'file' },
        type = { cpl = 'filetype' },
        envs = { lst = { 'PATH=' }, cpl = 'environment' },
        garg = vim.empty_dict(),
        barg = vim.empty_dict(),
        earg = vim.empty_dict(),
        msvc = vim.empty_dict(),
        stage = { lst = { 'build', 'run', 'clean', 'test' } },
        outer = vim.empty_dict(),
        style = { lst = { 'term', 'ansi', 'raw', 'job' } },
        verbose = {
            lst = { 'a', 'w', 'b', 't', 'h', 'n' },
            dic = {
                a = 'Show all',
                w = 'Show code wsc',
                b = 'Show bufs',
                t = 'Show without trimed',
                h = 'Show highlights',
                n = 'Show line number',
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
        wsc:reinit(wsc:get())
        vim.notify('Code task wsc is reinited!')
    end
end

--- Entry of code task
--- @param kt(table) [rR][cb][p...]
---                  [%S][%A][%E  ]
--- kt.S
---     r : build and run task
---     R : modify code task config
--- kt.A
---     c : clean task
---     b : build without run
--- kt.E
--      ? : from _maps
---     p : run task from task.wsc.code
--- Forward
---     R^p => r^p (r^p means r[kt.E != p])
---     Rp  => rp  => r^p
local entry = async(function(kt, bang)
    wsc:reinit()

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
        if not update_sels(_maps[kt.E], _sels.dic, wsc) then
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

    -- Run code task
    vim.cmd.wall({ mods = { silent = true, emsg_silent = true } })
    wsc.key = kt.E
    wsc.stage = (kt.A == 'b' and 'build') or (kt.A == 'c' and 'clean') or wsc.stage
    wsc.tout.open = true
    wsc.tout.jump = false
    wsc.tout.scroll = true
    wsc.tout.append = false
    wsc.tout.title = task.title.Code
    wsc.tout.style = wsc.style
    wsc.tout.verbose = bang and 'a' or wsc.verbose
    if wsc.tout.verbose:match('[aw]') then
        vim.notify(('resovle = %s, restore = %s\n%s'):format(resovle, restore, vim.inspect(wsc)))
    end
    local ok, msg = pcall(function()
        wsc.cmd = dispatch(_maps[wsc.key], wsc)
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
    })

    vim.api.nvim_create_user_command(
        'Code',
        function(opts) entry(keys2kt(opts.args), opts.bang) end,
        { bang = true, nargs = 1 }
    )
    vim.api.nvim_create_user_command('CodeWsc', function(opts)
        if opts.bang then
            wsc:reinit()
        end
        vim.print(wsc)
    end, { bang = true, nargs = 0 })
    vim.api.nvim_create_user_command('CodeWscInit', function()
        wsc:reinit()
        _sels.lst = _sels.lst_i
        _sels.evt = evt_i
        vim.fn.PopSelection(_sels)
    end, { nargs = 0 })
end

return { setup = setup }
