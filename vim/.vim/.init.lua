--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- .init.lua: configuration for neovim.
-- Github: https://github.com/yehuohan/dotconfigs
-- Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

vim.env.DotVimPath      = vim.fn.resolve(vim.fn.expand('<sfile>:p:h'))
vim.env.DotVimMiscPath  = vim.env.DotVimPath .. '/misc'
vim.env.DotVimCachePath = vim.env.DotVimPath .. '/.cache'
vim.opt.rtp:prepend(vim.env.DotVimPath)
vim.o.packpath = vim.o.rtp

if require('ostype').is_win() then
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

require('env')
require('use')
require('plugins')
require('user.style')
require('user.gui')
require('user.mappings')
