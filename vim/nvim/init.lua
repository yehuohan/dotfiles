local dotvim
if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
    dotvim = vim.env.APPS_HOME .. '/dotvim'
else
    dotvim = '~/dotvim'
end
dotvim = vim.fn.resolve(vim.fn.expand(dotvim))
local dotvim_init = dotvim .. '/init'
vim.opt.rtp:prepend(dotvim_init)
vim.opt.packpath:prepend(dotvim_init)
require('v').setup(dotvim)
