--------------------------------------------------------------------------------
-- init.lua: configuration for neovim.
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

local function init_env()
    -- Append {'path':[], 'vars':{}} from .env.json
    local sep = IsWin() and ';' or ':'
    local env_file = vim.env.DotVimLocal .. '/.env.json'
    if vim.fn.filereadable(env_file) == 1 then
        local ex = vim.json.decode(vim.fn.join(vim.fn.readfile(env_file)))
        vim.env.PATH = vim.env.PATH .. sep .. vim.fn.join(ex.path, sep)
        for name, val in pairs(ex.vars) do
            vim.env[name] = val
        end
    end
end

local function setup(dotvim)
    vim.env.DotVimDir = dotvim
    vim.env.DotVimInit = dotvim .. '/init'
    vim.env.DotVimVimL = dotvim .. '/init/viml'
    vim.env.DotVimMisc = dotvim .. '/misc'
    vim.env.DotVimLocal = dotvim .. '/local'
    vim.env.NVimConfigDir = vim.fn.stdpath('config')
    init_env()

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

    vim.cmd([[
function! IsVim()
    return !(has('nvim'))
endfunction
function! IsWin()
    return (has('win32') || has('win64'))
endfunction
function! IsNVim()
    return has('nvim')
endfunction
function! SvarUse()
    return v:lua.require('v.use').get()
endfunction
]])
    require('v.use').setup()
    vim.cmd.source(vim.env.DotVimVimL .. '/pkgs.vim')
    require('v.pkgs').setup()
    require('v.task').setup()
    require('v.misc').setup()
    vim.cmd.source(vim.env.DotVimVimL .. '/mods.vim')
    vim.cmd.source(vim.env.DotVimVimL .. '/sets.vim')
end

return { setup = setup }
