local a = require('v.libv').a
local async = a._async
local await = a._await
local str2env = require('v.task').str2env
local replace = require('v.task').replace
local sequence = require('v.task').sequence
local throw = error

--- Workspace config for fzer
local wsc = {}
local wsc_initialization = {
    envs = '',
    path = '',
    filters = '',
    globlst = '',
    options = '',
    prefer_vimgrep = false,
    connect_pty = false,
    hl_ansi_sgr = false,
    out_rawdata = false,
}

--- Fuzzy finder tasks
--- @var opt(string) Options
--- @var pat(string) Pattern
--- @var loc(string) Location
local fzer = {
    rg = 'rg --vimgrep -F {opt} -e "{pat}" {loc}',
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

-- Task functions
local task = {}

-- stylua: ignore start
task._keys = {
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

local entry = async(function(kt, debug) end)

local function setup()
    wsc = require('v.libv').new_configer(wsc_initialization)

    vim.api.nvim_create_user_command(
        'TaskFzer',
        function(opts) entry(opts.args, opts.bang) end,
        { bang = true, nargs = 1 }
    )
    vim.api.nvim_create_user_command('TaskFzerWsc', function() vim.print(wsc) end, { nargs = 0 })
end

return {
    setup = setup,
}
