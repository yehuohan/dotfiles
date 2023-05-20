local Err = require('v.task').Err.Code

-- Workspace config for code
local wsc = {}
local wsc_initialization = {
    key = '',
    file = '',
    type = '',
    garg = '',
    barg = '',
    earg = '',
    -- deploy = '',
    -- lowest = '',
}

-- Command replacements
-- @garg Generate arguments
-- @barg Build arguments
-- @earg Execution arguments
-- @src Source file
-- @out Output file
local singles = {}
local projects = {}
local task = {}

-- Single file tasks
singles = {
    c = { cmd = 'gcc -g {barg} {src} -o "{out}" && "./{out}" {earg}' },
    cpp = { cmd = 'g++ -g -std=c++20 {barg} {src} -o "{out}" && "./{out}" {earg}' },
    python = { cmd = 'python {src} {earg}' },
    lua = { cmd = 'lua {src} {earg}' },
}

-- Project tasks
projects = {
    make = {},
    cmake = {},
    cargo = {},
    sphinx = {},
}

local function replace(cmd, rep)
    return string.gsub(cmd, '{(%w+)}', rep)
end

function task.file(cfg)
    local ft = (cfg.type ~= '') and cfg.type or vim.o.filetype
    if (not singles[ft]) or ('dosbatch' == ft and not IsWin()) then
        error('Code task doesn\'t support "' .. ft .. '"', Err)
    end
    cfg.type = ft

    local rep = {}
    rep.barg = cfg.barg
    rep.earg = cfg.earg
    rep.src = '"' .. vim.fn.fnamemodify(cfg.file, ':t') .. '"'
    rep.out = vim.fn.fnamemodify(cfg.file, ':t:r')
    local cmd = replace(singles[ft].cmd, rep)

    return {
        cmd = cmd,
    }
end

function task.make(cfg) end

function task.cmake(cfg) end

function task.cargo(cfg) end

function task.sphinx(cfg) end

local function run(cfg)
    cfg.file = vim.api.nvim_buf_get_name(0)
    cfg.wdir = vim.fn.fnamemodify(cfg.file, ':h')

    local kts = {
        i = task.file,
    }
    local tfn = kts[cfg.key]
    local opts = tfn(cfg)
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
        -- 'unique',
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
        'ri',
        -- 'rl' for nvim -l,
        --  'Rp',  'Rm',  'Ru',  'Rn',  'Rj',  'Ra',  'Rh',  'Rf',
        --  'rp',  'rm',  'ru',  'rn',  'rj',  'ra',  'rh',  'rf',
        -- 'rcp', 'rcm', 'rcu', 'rcn', 'rcj', 'rca', 'rch',
        -- 'rbp', 'rbm', 'rbu', 'rbn', 'rbj', 'rba', 'rbh',
    }
    -- Convert key mapping to key table
    local keys2kt = function(keys)
        return {
            S = keys:sub(1, 1),
            A = keys:sub(2, -2),
            E = keys:sub(-1, -1),
        }
    end
    local m = require('v.maps')
    for _, k in ipairs(mappings) do
        m.nnore({
            '<leader>' .. k,
            function()
                code(keys2kt(k))
            end,
        })
    end
end

return {
    setup = setup,
}
