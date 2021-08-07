--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- init.lua: configuration for neovim.
-- Github: https://github.com/yehuohan/dotconfigs
-- Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function IsLinux()
    return  (vim.fn.has('unix') == 1)
        and (vim.fn.has('macunix') == 0)
        and (vim.fn.has('win32unix') == 0)
end

function IsWin()
    return (vim.fn.has('win32') == 1) or (vim.fn.has('win64') == 1)
end

function IsGw()
    return vim.fn.has('win32unix') == 1
end

function IsMac()
    return vim.fn.has('mac') == 1
end


local function setup(dotvim)
    vim.env.DotVimPath      = dotvim
    vim.env.DotVimMiscPath  = vim.env.DotVimPath .. '/misc'
    vim.env.DotVimCachePath = vim.env.DotVimPath .. '/.cache'

    if IsWin() then
        vim.g.python3_host_prog = vim.env.APPS_HOME .. '/Python/python.exe'
        vim.g.node_host_prog = vim.env.DotVimPath .. '/local/node_modules/.bin/neovim-node-host.cmd'
        if vim.fn.filereadable(vim.g.node_host_prog) == 0 then
            vim.g.node_host_prog = vim.env.APPS_HOME .. '/nodejs/node_modules/neovim-node-host.cmd'
        end
    else
        vim.g.python3_host_prog = '/usr/bin/python3'
        vim.g.node_host_prog = vim.env.DotVimPath .. '/local/node_modules/.bin/neovim-node-host'
        if vim.fn.filereadable(vim.g.node_host_prog) == 0 then
            vim.g.node_host_prog = '/usr/bin/neovim-node-host'
        end
    end

    vim.o.encoding = 'utf-8'
    vim.g.mapleader = ' '
    vim.api.nvim_set_keymap('n' , ';' , ':' , { noremap = true })
    vim.api.nvim_set_keymap('v' , ';' , ':' , { noremap = true })
    vim.api.nvim_set_keymap('n' , ':' , ';' , { noremap = true })

    require('v.env')
    require('v.use')
    require('v.exts')
    require('v.opts')
    require('v.gui')
    require('v.maps')
end

return {
    setup = setup
}
