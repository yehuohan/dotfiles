--------------------------------------------------------------------------------
-- init.lua: configuration for neovim
-- Github: https://github.com/yehuohan/dotconfigs
-- Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
--------------------------------------------------------------------------------

function IsLinux()
    return (vim.fn.has('unix') == 1)
        and (vim.fn.has('macunix') == 0)
        and (vim.fn.has('win32unix') == 0)
end

function IsWin() return (vim.fn.has('win32') == 1) or (vim.fn.has('win64') == 1) end

function IsGw() return vim.fn.has('win32unix') == 1 end

function IsMac() return vim.fn.has('mac') == 1 end

local function setup_env()
    local fp = io.open(vim.env.DotVimLocal .. '/.env.json')
    if fp then
        -- Load extra {'path':[], 'vars':{}} from .env.json
        local ex = vim.json.decode(fp:read('*a'))
        local sep = IsWin() and ';' or ':'
        vim.env.PATH = vim.env.PATH .. sep .. table.concat(ex.path, sep)
        for name, val in pairs(ex.vars) do
            vim.env[name] = val
        end
    end
end

local function setup(dotvim)
    vim.env.DotVimDir = dotvim
    vim.env.DotVimInit = dotvim .. '/init'
    vim.env.DotVimVimL = dotvim .. '/init/viml'
    vim.env.DotVimWork = dotvim .. '/work'
    vim.env.DotVimLocal = dotvim .. '/local'
    vim.env.NVimConfigDir = vim.fn.stdpath('config')
    setup_env()

    if IsWin() then
        vim.g.python3_host_prog = vim.env.APPS_HOME .. '/_packs/apps/python/current/python.exe'
        vim.g.node_host_prog = vim.env.DotVimLocal .. '/node_modules/neovim/bin/cli.js'
    else
        vim.g.python3_host_prog = '/usr/bin/python3'
        vim.g.node_host_prog = vim.env.DotVimLocal .. '/node_modules/neovim/bin/cli.js'
    end
    vim.o.encoding = 'utf-8'
    vim.g.mapleader = ' '
    vim.keymap.set('n', ';', ':', { noremap = true })
    vim.keymap.set('v', ';', ':', { noremap = true })
    vim.keymap.set('n', ':', ';', { noremap = true })
    vim.keymap.set('', '<CR>', '<CR>', { remap = true })
    vim.keymap.set('', '<Tab>', '<Tab>', { remap = true })

    require('v.use').setup()
    require('v.pkgs').setup()
    require('v.sets').setup()
    require('v.task').setup()
    require('v.misc').setup()
end

return { setup = setup }
