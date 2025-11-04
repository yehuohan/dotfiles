--- @File: neovim configuration init.lua
--- @Github: https://github.com/yehuohan/dotfiles
--- @Author: <yehuohan@qq.com>, <yehuohan@gmail.com>

function IsLinux()
    return (vim.fn.has('unix') == 1) and (vim.fn.has('macunix') == 0) and (vim.fn.has('win32unix') == 0)
end

function IsWin() return (vim.fn.has('win32') == 1) or (vim.fn.has('win64') == 1) end

function IsGw() return vim.fn.has('win32unix') == 1 end

function IsMac() return vim.fn.has('mac') == 1 end

--- Setup profiler
--- View with chrome://tracing or https://ui.perfetto.dev
local function setup_profiler(dotvim, startup)
    vim.opt.rtp:prepend(dotvim .. '/bundle/profile.nvim')

    local prof = require('profile')
    prof.instrument_autocmds()
    if startup then
        prof.start('*') -- Profile all pattern
    else
        prof.instrument('*')
    end
    vim.keymap.set('', '<F2>', function()
        local file = dotvim .. '/local/profile.json'
        if prof.is_recording() then
            prof.stop()
            prof.export(file)
            vim.notify('Dumped to ' .. file)
        else
            prof.start('*')
            vim.notify('Start profiling')
        end
    end)
end

--- Load extra { "path" : [], "vars": {} } from env.json
local function setup_env()
    local fp = io.open(vim.env.DotVimLocal .. '/env.json')
    if fp then
        local ex = vim.json.decode(fp:read('*a'))
        local sep = IsWin() and ';' or ':'
        vim.env.PATH = vim.env.PATH .. sep .. table.concat(ex.path, sep)
        for name, val in pairs(ex.vars) do
            vim.env[name] = val
        end
    end
end

local function setup(dotvim)
    -- setup_profiler(dotvim, true)

    vim.env.DotVimDir = dotvim
    vim.env.DotVimInit = dotvim .. '/init'
    vim.env.DotVimShare = dotvim .. '/share'
    vim.env.DotVimLocal = dotvim .. '/local'
    setup_env()

    if IsWin() then
        vim.g.python3_host_prog = vim.env.DOT_APPS .. '/miniconda3/python.exe'
    else
        vim.g.python3_host_prog = vim.env.DOT_APPS .. '/miniconda3/bin/python'
    end
    vim.g.node_host_prog = vim.env.DotVimLocal .. '/node_modules/neovim/bin/cli.js'
    vim.o.encoding = 'utf-8'
    vim.g.mapleader = ' '
    vim.keymap.set('n', ';', ':', { noremap = true })
    vim.keymap.set('x', ';', ':', { noremap = true })
    vim.keymap.set('n', ':', ';', { noremap = true })
    vim.keymap.set('', '<CR>', '<CR>', { remap = true })
    vim.keymap.set('', '<Tab>', '<Tab>', { remap = true })

    require('v.use').setup()
    require('v.pkgs').setup()
    require('v.task').setup()
    require('v.sets').setup()
end

return { setup = setup }
-- return { setup = require('v.test.mini') }
