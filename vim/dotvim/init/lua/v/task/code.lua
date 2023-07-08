local libv = require('v.libv')
local a = libv.a
local async = a._async
local await = a._await
local replace = require('v.task').replace
local sequence = require('v.task').sequence
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
    cmake      = { cmd = 'cmake {earg} -P {bsrc}', efm = [[%ECMake\ Error\ at\ %f:%l\ %#%m:]] },
    sh         = { cmd = 'bash ./{bsrc} {earg}' },
    ps1        = { cmd = 'Powershell -ExecutionPolicy Bypass -File {bsrc} {earg}' },
    dosbatch   = { cmd = '{bsrc} {earg}' },
    glsl       = { cmd = 'glslangValidator {earg} {bsrc}' },
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
        'cmake -DCMAKE_INSTALL_PREFIX=. {garg} -G "{gtar}" ..',
        'cmake --build . {barg}',
        'cmake --install .',
    },
    cargo = 'cargo {stage} {barg} -- {earg}',
    sphinx = {
        'make clean',
        'make html',
    },
    _pats = {
        tar = [[^TARGET%s*:?=%s*([%w%-]+)%s*$]], -- TARGET := <bout>
        pro = [[^project%s*%(%s*([%w%-]+).*%).*$]], -- project(<bout>)
    },
    _exec = '"./{bout}" {earg}',
    _msvc = 'vcvars64.bat',
    _vdir = '__VBuildOut',
}

local function patout(file, pattern)
    for line in io.lines(file) do
        local res = string.match(line, pattern)
        if res then
            return res
        end
    end
end

--- All task functions
local task = {}

function task.nvim(cfg)
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

function task.file(cfg)
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

function task.make(cfg)
    cfg.efm = codes.make.efm .. ',' .. codes.cmake.efm .. ',' .. vim.o.errorformat

    local rep = {}
    rep.barg = cfg.barg
    rep.bout = (cfg.stage ~= 'build') and patout(cfg.file, packs._pats.tar) or nil
    rep.bout = rep.bout and packs._vdir .. '/' .. rep.bout
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

function task.cmake(cfg)
    local outdir = cfg.wdir .. '/' .. packs._vdir
    if cfg.stage == 'clean' then
        vim.fn.delete(outdir, 'rf')
        throw(string.format('%s was removed', packs._vdir), 0)
    end
    vim.fn.mkdir(outdir, 'p')
    cfg.wdir = outdir
    cfg.efm = codes.cmake.efm .. ',' .. vim.o.errorformat

    local rep = {}
    rep.gtar = cfg.target
    rep.garg = cfg.garg
    rep.barg = cfg.barg
    rep.bout = (cfg.stage ~= 'build') and patout(cfg.file, packs._pats.pro) or nil
    rep.earg = cfg.earg
    local cmds = {}
    cmds[#cmds + 1] = (IsWin() and cfg.enable_msvc) and packs._msvc or nil
    cmds[#cmds + 1] = replace(packs.cmake[1], rep)
    cmds[#cmds + 1] = replace(packs.cmake[2], rep)
    cmds[#cmds + 1] = replace(packs.cmake[3], rep)
    cmds[#cmds + 1] = rep.bout and replace(packs._exec, rep) or nil

    return sequence(cmds)
end

function task.cargo(cfg)
    cfg.efm = codes.rust.efm

    local rep = {}
    rep.stage = cfg.stage
    rep.barg = cfg.barg
    rep.earg = cfg.earg
    return replace(packs.cargo, rep)
end

function task.sphinx(cfg)
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

setmetatable(task, {
    __call = function(self, cfg)
        local t = self._maps[cfg.key]
        if cfg.file == '' then
            if t.pat then
                local files = vim.fs.find(function(name, path)
                    local re = vim.regex('\\c' .. t.pat)
                    -- Require checking file's existence, because vim.fs.normalize's bug:
                    -- vim.fs.normalize('C:/') will return 'C:', which is equal to '.' for vim.fs.find.
                    return re:match_str(name) and (vim.fn.filereadable(path .. '/' .. name) == 1)
                end, {
                    upward = true,
                    type = 'file',
                    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
                    limit = cfg.fs_find_one and 1 or math.huge,
                })
                if #files == 0 then
                    throw(string.format('None of %s was found!', t.pat), 0)
                end
                cfg.file = files[#files]
            else
                cfg.file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
            end
        end
        cfg.target = t.target
        cfg.wdir = vim.fs.dirname(cfg.file)
        return t.fn(cfg)
    end,
})

-- stylua: ignore start
task._maps = {
    l = { fn = task.nvim,   desc = 'A nvim lua' },
    f = { fn = task.file,   desc = 'A single file' },
    m = { fn = task.make,   desc = 'Make',        pat = 'Makefile' },
    u = { fn = task.cmake,  desc = 'CMake Unix',  pat = 'CMakeLists', target = 'Unix Makefiles' },
    n = { fn = task.cmake,  desc = 'CMake NMake', pat = 'CMakeLists', target = 'NMake Makefiles' },
    j = { fn = task.cmake,  desc = 'CMake Ninja', pat = 'CMakeLists', target = 'Ninja' },
    o = { fn = task.cargo,  desc = 'Cargo rust',  pat = 'Cargo.toml' },
    h = { fn = task.sphinx, desc = 'Sphinx doc',  pat = IsWin() and 'make.bat' or 'Makefile' },
}

task._keys = {
    'Rp' , 'Rm' , 'Ru' , 'Rn' , 'Rj' , 'Ro' , 'Rh' , 'Rf',
    'rp' , 'rm' , 'ru' , 'rn' , 'rj' , 'ro' , 'rh' , 'rf', 'rl',
    'rcp', 'rcm', 'rcu', 'rcn', 'rcj', 'rco', 'rch',
    'rbp', 'rbm', 'rbu', 'rbn', 'rbj', 'rbo', 'rbh',
}
-- stylua: ignore end

task._sels = {
    opt = 'config code task',
    lst = nil,
    -- lst for kt.E != p
    lst_d = { 'envs', 'garg', 'barg', 'earg', 'stage' },
    -- lst for kt.E = p
    lst_p = { 'key', 'file', 'type', 'envs', 'garg', 'barg', 'earg', 'stage' },
    -- lst for TaskCodeWsc
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
            lst = vim.fn.sort(
                vim.tbl_keys(task._maps),
                function(k0, k1) return vim.stricmp(task._maps[k0].desc, task._maps[k1].desc) end
            ),
            dic = vim.tbl_map(function(t) return t.desc end, task._maps),
        },
        file = { cpl = 'file' },
        type = { cpl = 'filetype' },
        envs = { lst = { 'PATH=' }, cpl = 'environment' },
        garg = { lst = { '-DENABLE_TEST=' }, cpl = 'environment' },
        barg = { lst = { '-static', 'tags', '--target tags', '-j32' } },
        earg = { lst = { '--nocapture' } },
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
    evt = function(name)
        if name == 'onCR' then
            local sel = task._sels
            if sel.lst == sel.lst_p then
                if wsc.file ~= '' then
                    wsc.file = vim.fs.normalize(vim.fn.fnamemodify(wsc.file, ':p'))
                    if wsc.type == '' then
                        wsc.type = vim.filetype.match({ filename = wsc.file }) or ''
                    end
                end
            elseif sel.lst == sel.lst_i then
                wsc:reinit(wsc:get())
                vim.notify('Code task wsc is reinited!')
            end
        end
    end,
    sub = {
        lst = { true, false },
        cmd = function(sopt, sel) wsc[sopt] = sel end,
        get = function(sopt) return wsc[sopt] end,
    },
}

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
        task._sels.lst = task._sels.lst_d
        resovle = true
    end
    if kt.E == 'p' then
        local __wsc = require('v.task').wsc.code
        wsc:set(__wsc)
        if __wsc.key and task._maps[__wsc.key] and not resovle then
            -- Forward rp => r^p
            kt.E = __wsc.key
        else
            -- Forward Rp => r^p
            task._sels.lst = task._sels.lst_p
            resovle = true
            restore = true
        end
    end

    -- Need to resolve config
    if resovle and (not await(a.pop_selection(task._sels))) then
        return
    end
    -- Need to re-store config back
    if restore then
        kt.E = wsc.key
        require('v.task').wsc.code = wsc:get()
    end

    -- Run code task
    wsc.key = kt.E
    wsc.stage = (kt.A == 'b' and 'build') or (kt.A == 'c' and 'clean') or wsc.stage
    wsc.verbose = bang and 'a' or wsc.verbose
    if wsc.verbose:match('[aw]') then
        vim.notify(('resovle = %s, restore = %s\n%s'):format(resovle, restore, vim.inspect(wsc)))
    end
    local ok, msg = pcall(function(cfg)
        cfg.cmd = task(cfg)
        cfg.qf_save = true
        cfg.qf_open = true
        cfg.qf_jump = false
        cfg.qf_scroll = true
        cfg.qf_append = false
        cfg.qf_title = 'v.task.code'
        require('v.task').run(cfg)
        libv.recall(function() require('v.task').run(cfg) end)
    end, wsc)
    if not ok then
        vim.notify(tostring(msg))
    end
end)

local function setup()
    require('v.task').wsc.code = wsc:get()

    -- Keys mapping to table
    local keys2kt = function(keys)
        return {
            S = keys:sub(1, 1),
            A = keys:sub(2, -2),
            E = keys:sub(-1, -1),
        }
    end
    for _, keys in ipairs(task._keys) do
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
        task._sels.lst = task._sels.lst_i
        vim.fn.PopSelection(task._sels)
    end, { nargs = 0 })
end

return { setup = setup }
