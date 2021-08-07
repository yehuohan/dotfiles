local dotvim
if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
    dotvim = vim.env.APPS_HOME .. '/dotvim'
else
    dotvim = '~/.vim'
end
vim.opt.rtp:prepend(dotvim)
require('v').setup(dotvim)
