--- Simple test code for debug
--- vim@code{ style = 'term' }: nvim --headless --noplugin -u NONE -i NONE -n -c "source test.lua"

local dir_this = vim.fn.getcwd()
local dir_init = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(dir_this)))
vim.opt.rtp:prepend(dir_init)

local nlib = require('v.nlib')

vim.o.lines = 25
vim.o.columns = 80
local chanor = nlib.new_chanor({ style = 'ansi' })
local data = { 'This is test data\r' }

local lines, _ = chanor(data)
local _lines, _ = chanor({ '' })
vim.list_extend(lines, _lines)
for _, line in ipairs(lines) do
    print(line)
end
