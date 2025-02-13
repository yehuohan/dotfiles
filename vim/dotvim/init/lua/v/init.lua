--- @File: neovim configuration init.lua
--- @Github: https://github.com/yehuohan/dotfiles
--- @Author: <yehuohan@qq.com>, <yehuohan@gmail.com>
---
--- @diagnostic disable: inject-field
--- @diagnostic disable: undefined-field

function IsLinux()
    return (vim.fn.has('unix') == 1) and (vim.fn.has('macunix') == 0) and (vim.fn.has('win32unix') == 0)
end

function IsWin() return (vim.fn.has('win32') == 1) or (vim.fn.has('win64') == 1) end

function IsGw() return vim.fn.has('win32unix') == 1 end

function IsMac() return vim.fn.has('mac') == 1 end

local function setup_env()
    local fp = io.open(vim.env.DotVimLocal .. '/.env.json')
    if fp then
        -- Load extra {"path":[]} from .env.json
        local ex = vim.json.decode(fp:read('*a'))
        local sep = IsWin() and ';' or ':'
        vim.env.PATH = vim.env.PATH .. sep .. table.concat(ex.path, sep)
    end
end

local function setup(dotvim)
    vim.env.DotVimDir = dotvim
    vim.env.DotVimInit = dotvim .. '/init'
    vim.env.DotVimShare = dotvim .. '/share'
    vim.env.DotVimLocal = dotvim .. '/local'
    vim.env.NVimConfigDir = vim.fn.stdpath('config')
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
    vim.keymap.set('v', ';', ':', { noremap = true })
    vim.keymap.set('n', ':', ';', { noremap = true })
    vim.keymap.set('', '<CR>', '<CR>', { remap = true })
    vim.keymap.set('', '<Tab>', '<Tab>', { remap = true })

    require('v.use').setup()
    require('v.pkgs').setup()
    require('v.task').setup()
    require('v.lite').setup()
    require('v.sets').setup()
end

return { setup = setup }
-- return { setup = require('v.test.mini') }
