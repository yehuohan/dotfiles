--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- .init.lua: configuration for neovim.
-- Github: https://github.com/yehuohan/dotconfigs
-- Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local fn = vim.fn

vim.env.DotVimPath      = fn.resolve(fn.expand('<sfile>:p:h'))
vim.env.DotVimMiscPath  = vim.env.DotVimPath .. '/misc'
vim.env.DotVimCachePath = vim.env.DotVimPath .. '/.cache'
vim.opt.rtp:append(vim.env.DotVimPath)

vim.o.encoding = 'utf-8'
vim.g.mapleader = ' '
vim.api.nvim_set_keymap('n' , ';' , ':' , { noremap = true })
vim.api.nvim_set_keymap('v' , ';' , ':' , { noremap = true })
vim.api.nvim_set_keymap('n' , ':' , ';' , { noremap = true })

require('env')
require('use')
require('plugs')
require('users.style')
require('users.gui')
require('users.mappings')
