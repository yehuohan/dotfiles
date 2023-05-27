local replace = require('v.task').replace
local sequence = require('v.task').sequence
local throw = error

-- Workspace config for code
local wsc = {}
local wsc_initialization = {
    key = '',
    file = '',
    type = '',
    garg = '',
    barg = '',
    earg = '',
    stage = 'run',
}

-- Single code file tasks according to filetype
-- @var barg Build arguments
-- @var bsrc Build source file
-- @var bout Build output file
-- @var earg Execution arguments
local codes = {
    nvim = { cmd = 'nvim -l {bsrc} {earg}' },
    c = { cmd = 'gcc -g {barg} {bsrc} -o "{bout}" && "./{bout}" {earg}' },
    cpp = { cmd = 'g++ -g -std=c++20 {barg} {bsrc} -o "{bout}" && "./{bout}" {earg}' },
    python = { cmd = 'python {bsrc} {earg}' },
    lua = { cmd = 'lua {bsrc} {earg}' },
}

-- Project package tasks
-- @var gtar Generator target
-- @var garg Generate arguments
-- @var stage Task stage from {'build', 'run', 'clean', 'test'}
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

-- Task functions
local task = {}

function task.nvim(cfg)
    local ft = vim.o.filetype
    if ft == 'vim' then
        vim.cmd[[silent w]]
        vim.cmd[[source %]]
        throw("Source completed", 0)
    else
        -- Take as lua forcefully
        cfg.type = 'lua'
        local rep = {}
        rep.bsrc = '"' .. vim.fn.fnamemodify(cfg.file, ':t') .. '"'
        rep.earg = cfg.earg

        return {
            cmd = replace(codes.nvim.cmd, rep)
        }
    end
end

function task.file(cfg)
    local ft = (cfg.type ~= '') and cfg.type or vim.o.filetype
    if (not codes[ft]) or ('dosbatch' == ft and not IsWin()) then
        throw(string.format('Code task doesn\'t support "%s"', ft), 0)
    end
    cfg.type = ft

    local rep = {}
    rep.barg = cfg.barg
    rep.bsrc = '"' .. vim.fn.fnamemodify(cfg.file, ':t') .. '"'
    rep.bout = vim.fn.fnamemodify(cfg.file, ':t:r')
    rep.earg = cfg.earg
    local cmd = replace(codes[ft].cmd, rep)

    return {
        cmd = cmd,
    }
end

function task.make(cfg)
    local rep = {}
    rep.barg = cfg.barg
    rep.bout = (cfg.stage ~= 'build') and patout(cfg.file, packs._pats.tar) or nil
    rep.bout = packs._vdir .. '/' .. rep.bout
    rep.earg = cfg.earg
    if cfg.stage == 'clean' then
        rep.barg = 'clean'
        rep.bout = nil
    end

    local cmds = {}
    cmds[#cmds + 1] = IsWin() and packs._msvc or nil
    cmds[#cmds + 1] = replace(packs.make, rep)
    cmds[#cmds + 1] = rep.bout and replace(packs._exec, rep) or nil

    return {
        cmd = sequence(cmds),
    }
end

function task.cmake(cfg)
    local outdir = cfg.wdir .. '/' .. packs._vdir
    if cfg.stage == 'clean' then
        vim.fn.delete(outdir, 'rf')
        throw(string.format('%s was removed', packs._vdir), 0)
    end
    vim.fn.mkdir(outdir, 'p')
    cfg.wdir = outdir

    local rep = {}
    rep.gtar = {
        u = 'Unix Makefiles',
        n = 'NMake Makefiles',
        j = 'Ninja',
    }
    rep.gtar = rep.gtar[cfg.key]
    rep.garg = cfg.garg
    rep.barg = cfg.barg
    rep.bout = (cfg.stage ~= 'build') and patout(cfg.file, packs._pats.pro) or nil
    rep.earg = cfg.earg
    local cmds = {}
    cmds[#cmds + 1] = (IsWin() and (cfg.key == 'n' or cfg.key == 'j')) and packs._msvc or nil
    cmds[#cmds + 1] = replace(packs.cmake[1], rep)
    cmds[#cmds + 1] = replace(packs.cmake[2], rep)
    cmds[#cmds + 1] = replace(packs.cmake[3], rep)
    cmds[#cmds + 1] = rep.bout and replace(packs._exec, rep) or nil

    return {
        cmd = sequence(cmds),
    }
end

function task.cargo(cfg)
    cfg.type = 'rust'

    local rep = {}
    rep.stage = cfg.stage
    rep.barg = cfg.barg
    rep.earg = cfg.earg
    local cmd = replace(packs.cargo, rep)

    return {
        cmd = cmd
    }
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

    return {
        cmd = cmd,
    }
end

task._ = {
    l = { fn = task.nvim },
    f = { fn = task.file },
    m = { fn = task.make, pat = 'Makefile' },
    u = { fn = task.cmake, pat = 'CMakeLists' },
    n = { fn = task.cmake, pat = 'CMakeLists' },
    j = { fn = task.cmake, pat = 'CMakeLists' },
    o = { fn = task.cargo, pat = 'Cargo.toml' },
    h = { fn = task.sphinx, pat = IsWin() and 'make.bat' or 'Makefile' },
}

setmetatable(task, {
    __call = function(self, cfg)
        local t = self._[cfg.key]
        if t.pat then
            local files = vim.fs.find(function(name)
                local re = vim.regex('\\c' .. t.pat)
                return re:match_str(name)
            end, {
                upward = true,
                type = 'file',
                path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
                limit = math.huge,
            })
            if #files == 0 then
                throw(string.format('None of %s was found!', t.pat), 0)
            end
            cfg.file = files[#files]
        else
            cfg.file = vim.api.nvim_buf_get_name(0)
        end
        cfg.wdir = vim.fn.fnamemodify(cfg.file, ':h')
        return t.fn(cfg)
    end,
})

-- Run code task
local function run(cfg)
    local opts = task(cfg)
    opts.cwd = cfg.wdir
    opts.components = {
        {
            'on_output_quickfix',
            open = true,
            -- errorformat = '',
        },
        'display_duration',
        'on_output_summarize',
        'on_exit_set_status',
        'on_complete_dispose',
        'unique',
    }
    require('v.task').run(opts)
end

-- Parse code task config from keys table
local function parse_config(kt)
    wsc:reinit()
    wsc.key = kt.E
    wsc.stage = (kt.A == 'b' and 'build') or (kt.A == 'c' and 'clean') or wsc.stage
    return wsc
end

local function entry(kt)
    if kt.S == 'R' then
        vim.notify('R')
    elseif kt.E == 'p' then
        vim.notify('p')
    else
        local config = parse_config(kt)
        local ok, msg = pcall(run, config)
        if not ok then
            vim.notify(tostring(msg))
        end
    end
end

local function setup()
    local __wsc = require('v.task').wsc
    wsc = require('v.libv').new_config(wsc_initialization)
    wsc:set(__wsc.code)
    __wsc.code = wsc

    -- Convert mapping keys to table
    local keys2kt = function (keys)
        return {
            S = keys:sub(1, 1),
            A = keys:sub(2, -2),
            E = keys:sub(-1, -1),
        }
    end
    -- Mapping keys
    local mappings = {
        'rl' ,
        'Rp' , 'Rm' , 'Ru' , 'Rn' , 'Rj' , 'Ro' , 'Rh' , 'Rf',
        'rp' , 'rm' , 'ru' , 'rn' , 'rj' , 'ro' , 'rh' , 'rf',
        'rcp', 'rcm', 'rcu', 'rcn', 'rcj', 'rco', 'rch',
        'rbp', 'rbm', 'rbu', 'rbn', 'rbj', 'rbo', 'rbh',
    }
    local m = require('v.maps')
    for _, keys in ipairs(mappings) do
        m.nnore({
            '<leader>' .. keys,
            function()
                entry(keys2kt(keys))
            end,
        })
    end
end

return {
    setup = setup,
}
