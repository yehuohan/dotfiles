local M = {}

local a = require('v.libv').a
local async = a._async
local await = a._await
local str2env = require('v.task').str2env
local replace = require('v.task').replace
local sequence = require('v.task').sequence
local throw = error

--- Workspace config for fzer
M.wsc = {}
local wsc_initialization = {
    key = '',
    file = '',
    type = '',
    envs = '',
    garg = '',
    barg = '',
    earg = '',
    stage = 'run',
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

M.entry = async(function(kt, debug) end)

function M.setup() end

return M
