local dotvim = vim.fn.resolve(vim.fn.expand(vim.env.DOT_HOME .. '/dotvim'))
local dotvim_init = dotvim .. '/init'
vim.opt.rtp:prepend(dotvim_init)
vim.opt.packpath:prepend(dotvim_init)
require('v').setup(dotvim)
