local replace = require('v.task').replace
local sequence = require('v.task').sequence

-- Workspace config for code
local wsc = {}
local wsc_initialization = {
    key = '',
    file = '',
    type = '',
    garg = '',
    barg = '',
    earg = '',
    stage = 'run', -- 'build', 'run', 'clean', 'test'
}

-- Command placeholders
-- @var garg Generate arguments
-- @var gtar Generator target
-- @var barg Build arguments
-- @var bsrc Build source file
-- @var bout Build output file
-- @var earg Execution arguments
local singles = {}
local projects = {}

-- Single file tasks according to filetype
singles = {
    c = { cmd = 'gcc -g {barg} {bsrc} -o "{bout}" && "./{bout}" {earg}' },
    cpp = { cmd = 'g++ -g -std=c++20 {barg} {bsrc} -o "{bout}" && "./{bout}" {earg}' },
    python = { cmd = 'python {bsrc} {earg}' },
    lua = { cmd = 'lua {bsrc} {earg}' },
}

-- Project tasks
projects = {
    make = 'make {barg}',
    cmake = {
        'cmake -DCMAKE_INSTALL_PREFIX=. {garg} -G "{gtar}" ..',
        'cmake --build . {barg}',
        'cmake --install .',
    },
    cargo = {},
    sphinx = {},
    _msvc = 'vcvars64.bat',
    _exec = '"./{bout}" {earg}',
}

-- Task functions
local task = {}

function task.file(cfg)
    local ft = (cfg.type ~= '') and cfg.type or vim.o.filetype
    if (not singles[ft]) or ('dosbatch' == ft and not IsWin()) then
        error(string.format('Code task doesn\'t support "%s"', ft), 0)
    end
    cfg.type = ft

    local rep = {}
    rep.barg = cfg.barg
    rep.bsrc = '"' .. vim.fn.fnamemodify(cfg.file, ':t') .. '"'
    rep.bout = vim.fn.fnamemodify(cfg.file, ':t:r')
    rep.earg = cfg.earg
    local cmd = replace(singles[ft].cmd, rep)

    return {
        cmd = cmd,
    }
end

function task.make(cfg)
    if cfg.stage == 'clean' then
        cfg.barg = 'clean'
    end

    local rep = {}
    rep.barg = cfg.barg
    rep.bout = nil
    rep.earg = cfg.earg
    local cmds = {}
    cmds[#cmds + 1] = IsWin() and projects._msvc or nil
    cmds[#cmds + 1] = replace(projects.make, rep)
    cmds[#cmds + 1] = rep.bout and replace(projects._exec, rep) or nil

    return {
        cmd = sequence(cmds),
    }
end

function task.cmake(cfg)
    local vdir = '__VBuildOut'
    if cfg.stage == 'clean' then
        error(string.format('%s was removed', vdir ), 0)
    end

    -- vim.fn.mkdir(cfg.wdir .. '/' .. vdir, 'p')
    -- local rep = {}
end

function task.cargo(cfg) end

function task.sphinx(cfg) end

function task.nvim(cfg) end

local function up_iter(pat)
    local names = function(name)
        local re = vim.regex('\\c' .. pat)
        return re:match_str(name)
    end
    return vim.fs.find(names, {
        upward = true,
        type = 'file',
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        limit = math.huge,
    })
end

setmetatable(task, {
    __call = function(self, cfg)
        if not self._ then
            self._ = {
                l = { fn = task.nvim },
                f = { fn = task.file },
                m = { fn = task.make, pat = 'Makefile' },
                u = { fn = task.cmake, pat = 'CMakeLists' },
                n = { fn = task.cmake, pat = 'CMakeLists' },
                j = { fn = task.cmake, pat = 'CMakeLists' },
                a = { fn = task.cargo, pat = 'Cargo.toml' },
                h = { fn = task.sphinx, pat = IsWin() and 'make.bat' or 'Makefile' },
            }
        end

        local t = self._[cfg.key]
        if t.pat then
            local files = up_iter(t.pat)
            if #files == 0 then
                error(string.format('None of %s was found!', t.pat), 0)
            end
            cfg.file = files[#files]
        else
            cfg.file = vim.api.nvim_buf_get_name(0)
        end
        cfg.wdir = vim.fn.fnamemodify(cfg.file, ':h')
        return t.fn(cfg)
    end,
})

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

local function kt2config(kt)
    wsc:reinit()
    wsc.key = kt.E
    return wsc
end

local function code(kt)
    if kt.S == 'R' then
        vim.notify('R')
    elseif kt.A == 'p' then
        vim.notify('p')
    else
        local config = kt2config(kt)
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

    local mappings = {
        'rl' ,
        'Rp' , 'Rm' , 'Ru' , 'Rn' , 'Rj' , 'Ra' , 'Rh' , 'Rf',
        'rp' , 'rm' , 'ru' , 'rn' , 'rj' , 'ra' , 'rh' , 'rf',
        'rcp', 'rcm', 'rcu', 'rcn', 'rcj', 'rca', 'rch',
        'rbp', 'rbm', 'rbu', 'rbn', 'rbj', 'rba', 'rbh',
    }
    -- Convert mapping keys to table
    local keys2kt = function(keys)
        return {
            S = keys:sub(1, 1),
            A = keys:sub(2, -2),
            E = keys:sub(-1, -1),
        }
    end
    local m = require('v.maps')
    for _, keys in ipairs(mappings) do
        m.nnore({
            '<leader>' .. keys,
            function()
                code(keys2kt(keys))
            end,
        })
    end
end

return {
    setup = setup,
}
