local libv = require('v.libv')
local a = libv.a
local async = a._async
local await = a._await
local task = require('v.task')
local replace = task.replace
local sequence = task.sequence
local throw = error

--- Workspace config for code
local wsc = libv.new_configer({
    key = '',
    file = '',
    type = '',
    envs = '',
    garg = '',
    barg = '',
    earg = '',
    stage = 'run',
    fs_find_one = false, -- Find the closest file relative to wdir
    enable_msvc = false, -- Setup msvc environment
    connect_pty = true,
    hl_ansi_sgr = true,
    out_rawdata = false,
    verbose = '',
})

--- Single code file tasks according to filetype
--- @var barg(string) Build arguments
--- @var bsrc(string) Build source file
--- @var bout(string) Build output file
--- @var earg(string) Execution arguments
-- stylua: ignore start
local codes = {
    nvim       = { cmd = 'nvim -l {bsrc} {earg}' },
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

--- Project package tasks
--- @var gtar(string) Generator target
--- @var garg(string) Generate arguments
--- @var stage(string) Task stage from {'build', 'run', 'clean', 'test'}
local packs = {
    make = 'make {barg}',
    cmake = {
        'cmake -G "{gtar}" -DCMAKE_INSTALL_PREFIX=_VOut {garg} -S . -B _VOut',
        'cmake --build _VOut {barg}',
        'cmake --install _VOut',
    },
    cargo = 'cargo {stage} {barg} -- {earg}',
    sphinx = {
        'make clean',
        'make html',
    },
    _pats = {
        tar = [[^TARGET%s*:?=%s*([%w%-_]+)%s*$]], -- TARGET := <bout>
        pro = [[^project%s*%(%s*([%w%-_]+).*%).*$]], -- project(<bout>)
        pho = [[^%.PHONY:%s*([%w%-_]+)%s*$]], -- .PHONY: <barg>
    },
    _exec = '"./{bout}" {earg}',
    _msvc = 'vcvars64.bat',
    _vout = '_VOut',
}

local function pat_text(pattern, file)
    for line in io.lines(file) do
        local res = string.match(line, pattern)
        if res then
            return res
        end
    end
end

local function pat_list(pattern, file)
    local lst = {}
    for line in io.lines(file) do
        local res = string.match(line, pattern)
        lst[#lst + 1] = res
    end
    return lst
end

local function pat_file(pattern)
    if not pattern then
        return vim.fs.normalize(vim.api.nvim_buf_get_name(0))
    end

    local files = vim.fs.find(function(name, path)
        local re = vim.regex('\\c' .. pattern)
        -- Require checking file's existence, because vim.fs.normalize's bug:
        -- vim.fs.normalize('C:/') will return 'C:', which is equal to '.' for vim.fs.find.
        return re:match_str(name) and (vim.fn.filereadable(path .. '/' .. name) == 1)
    end, {
        upward = true,
        type = 'file',
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        limit = wsc.fs_find_one and 1 or math.huge,
    })
    return files[#files]
end

--- All task handle functions
local _hdls = {}

function _hdls.nvim(cfg)
    local ft = vim.o.filetype
    if ft == 'vim' then
        vim.cmd.write()
        vim.cmd.source('%')
        throw('Source completed', 0)
    else
        cfg.type = 'lua'
        cfg.efm = codes.lua.efm

        local rep = {}
        rep.bsrc = '"' .. vim.fn.fnamemodify(cfg.file, ':t') .. '"'
        rep.earg = cfg.earg

        return replace(codes.nvim.cmd, rep)
    end
end

function _hdls.file(cfg)
    local ft = (cfg.type ~= '') and cfg.type or vim.o.filetype
    if (not codes[ft]) or ('dosbatch' == ft and not IsWin()) then
        throw(string.format('Code task doesn\'t support "%s"', ft), 0)
    end
    cfg.type = ft
    cfg.efm = codes[cfg.type].efm

    local rep = {}
    rep.barg = cfg.barg
    rep.bsrc = '"' .. vim.fn.fnamemodify(cfg.file, ':t') .. '"'
    rep.bout = vim.fn.fnamemodify(cfg.file, ':t:r')
    rep.earg = cfg.earg
    return replace(codes[ft].cmd, rep)
end

function _hdls.make(cfg)
    cfg.efm = codes.make.efm .. ',' .. codes.cmake.efm .. ',' .. vim.o.errorformat

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
    cmds[#cmds + 1] = (IsWin() and cfg.enable_msvc) and packs._msvc or nil
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
    cfg.efm = codes.cmake.efm .. ',' .. vim.o.errorformat

    local rep = {}
    rep.gtar = cfg.target
    rep.garg = cfg.garg
    rep.barg = cfg.barg
    rep.bout = (cfg.stage ~= 'build') and pat_text(packs._pats.pro, cfg.file) or nil
    rep.bout = rep.bout and packs._vout .. '/' .. rep.bout
    rep.earg = cfg.earg
    local cmds = {}
    cmds[#cmds + 1] = (IsWin() and cfg.enable_msvc) and packs._msvc or nil
    cmds[#cmds + 1] = replace(packs.cmake[1], rep)
    cmds[#cmds + 1] = replace(packs.cmake[2], rep)
    cmds[#cmds + 1] = replace(packs.cmake[3], rep)
    cmds[#cmds + 1] = rep.bout and replace(packs._exec, rep) or nil

    return sequence(cmds)
end

function _hdls.cargo(cfg)
    cfg.efm = codes.rust.efm

    local rep = {}
    rep.stage = cfg.stage
    rep.barg = cfg.barg
    rep.earg = cfg.earg
    return replace(packs.cargo, rep)
end

function _hdls.sphinx(cfg)
    local cmd
    if cfg.stage == 'clean' then
        cmd = packs.sphinx[1]
    else
        cmd = sequence({
            packs.sphinx[2],
            'firefox build/html/index.html',
        })
    end
    return cmd
end

--- Dispatch task handle and return task command
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

-- stylua: ignore start
local _maps = {
    { 'l', 'f', 'm', 'u', 'n', 'j', 'o', 'h' },
    l = { fn = 'nvim',   desc = 'Nvim lua' },
    f = { fn = 'file',   desc = 'Single file' },
    m = { fn = 'make',   desc = 'Make',        pat = 'Makefile' },
    u = { fn = 'cmake',  desc = 'CMake Unix',  pat = 'CMakeLists', target = 'Unix Makefiles' },
    n = { fn = 'cmake',  desc = 'CMake NMake', pat = 'CMakeLists', target = 'NMake Makefiles' },
    j = { fn = 'cmake',  desc = 'CMake Ninja', pat = 'CMakeLists', target = 'Ninja' },
    o = { fn = 'cargo',  desc = 'Cargo rust',  pat = 'Cargo.toml' },
    h = { fn = 'sphinx', desc = 'Sphinx doc',  pat = IsWin() and 'make.bat' or 'Makefile' },
}

local _keys = {
    'Rp' , 'Rm' , 'Ru' , 'Rn' , 'Rj' , 'Ro' , 'Rh' , 'Rf',
    'rp' , 'rm' , 'ru' , 'rn' , 'rj' , 'ro' , 'rh' , 'rf', 'rl',
    'rcp', 'rcm', 'rcu', 'rcn', 'rcj', 'rco', 'rch',
    'rbp', 'rbm', 'rbu', 'rbn', 'rbj', 'rbo', 'rbh',
}
-- stylua: ignore end

--- Selections for code task
local _sels = {
    opt = 'config code task',
    lst = nil,
    -- lst for kt.E != p
    lst_d = { 'envs', 'garg', 'barg', 'earg', 'stage' },
    -- lst for kt.E = p
    lst_p = { 'key', 'file', 'type', 'envs', 'garg', 'barg', 'earg', 'stage' },
    -- lst for CodeWscInit
    lst_i = {
        'fs_find_one',
        'enable_msvc',
        'connect_pty',
        'hl_ansi_sgr',
        'out_rawdata',
        'verbose',
    },
    dic = {
        key = {
            lst = _maps[1],
            dic = vim.tbl_map(function(h) return h.desc end, _maps),
        },
        file = { cpl = 'file' },
        type = { cpl = 'filetype' },
        envs = { lst = { 'PATH=' }, cpl = 'environment' },
        garg = vim.empty_dict(),
        barg = vim.empty_dict(),
        earg = vim.empty_dict(),
        stage = { lst = { 'build', 'run', 'clean', 'test' } },
        fs_find_one = vim.empty_dict(),
        enable_msvc = vim.empty_dict(),
        connect_pty = vim.empty_dict(),
        hl_ansi_sgr = vim.empty_dict(),
        out_rawdata = vim.empty_dict(),
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

local function evt_i(name)
    if name == 'onCR' then
        wsc:reinit(wsc:get())
        vim.notify('Code task wsc is reinited!')
    end
end

--- Arguments for _sels
local _args = {}

function _args.nvim(cfg) end

function _args.file()
    local dic = _sels.dic
    dic.barg.lst = { '-static' }
end

function _args.make(cfg)
    local dic = _sels.dic
    dic.barg.lst = pat_list(packs._pats.pho, cfg.file)
end

function _args.cmake(cfg)
    local dic = _sels.dic
    dic.garg.lst = { '-DCMAKE_BUILD_TYPE=Release' }
    dic.barg.lst = { '--target tags', '-j4' }
end

function _args.cargo(cfg)
    local dic = _sels.dic
    dic.earg.lst = { '--nocapture' }
end

function _args.sphinx(cfg) end

--- Update _sels with _args
local function update_sels(rhs, cfg)
    local dic = _sels.dic
    dic.garg = { lst = {} }
    dic.barg = { lst = {} }
    dic.earg = { lst = {} }

    if rhs then
        cfg.file = pat_file(rhs.pat)
        if not cfg.file then
            vim.notify(string.format('None of %s was found!', rhs.pat))
            return false
        end
        _args[rhs.fn](cfg)
    end

    return true
end

--- Entry of code task
--- @param kt(table) [rR][cb][p...]
---                  [%1][%2][%3  ]
--- %1 = kt.S
---      r : build and run task
---      R : modify code task config
--- %2 = kt.A
---      c : clean task
---      b : build without run
--- %3 = kt.E from codes and packs
---      p : run task from task.wsc.code
--- Forward:
---      R^p => r^p (r^p means r[kt.E != p])
---      Rp  => rp  => r^p
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
        wsc:set(__wsc)
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
        if not update_sels(_maps[kt.E], wsc) then
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
    wsc.key = kt.E
    wsc.stage = (kt.A == 'b' and 'build') or (kt.A == 'c' and 'clean') or wsc.stage
    wsc.verbose = bang and 'a' or wsc.verbose
    if wsc.verbose:match('[aw]') then
        vim.notify(('resovle = %s, restore = %s\n%s'):format(resovle, restore, vim.inspect(wsc)))
    end
    wsc.qf_save = true
    wsc.qf_open = true
    wsc.qf_jump = false
    wsc.qf_scroll = true
    wsc.qf_append = false
    wsc.qf_title = task.title.Code
    local ok, msg = pcall(function()
        wsc.cmd = dispatch(_maps[wsc.key], wsc)
        task.run(wsc)
        libv.recall(function() task.run(wsc) end)
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
        libv.m.nnore({ '<leader>' .. keys, function() entry(keys2kt(keys)) end })
    end

    vim.api.nvim_create_user_command(
        'Code',
        function(opts) entry(keys2kt(opts.args), opts.bang) end,
        { bang = true, nargs = 1 }
    )
    vim.api.nvim_create_user_command('CodeWsc', function() vim.print(wsc) end, { nargs = 0 })
    vim.api.nvim_create_user_command('CodeWscInit', function()
        wsc:reinit()
        _sels.lst = _sels.lst_i
        _sels.evt = evt_i
        vim.fn.PopSelection(_sels)
    end, { nargs = 0 })
end

return { setup = setup }
