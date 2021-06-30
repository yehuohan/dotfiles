--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- .init.lua: configuration for neovim.
-- Github: https://github.com/yehuohan/dotconfigs
-- Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

vim.env.DotVimPath      = vim.fn.resolve(vim.fn.expand('<sfile>:p:h'))
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
require('plugins')
require('users.style')
require('users.gui')
require('users.mappings')
