--- Simple test code for debug
--- vim@code{ style = 'ansi' }: nvim --headless --noplugin -u NONE -i NONE -n -c "source test.lua | :qa!"

local T = {}

local dir_this = vim.fn.getcwd()
local dir_init = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(dir_this)))
local dir_bundle = vim.fs.dirname(dir_init) .. '/bundle'

function T.chanor()
    vim.opt.rtp:prepend(dir_init)
    local nlib = require('v.nlib')

    vim.o.lines = 25
    vim.o.columns = 80
    local chanor = nlib.new_chanor({ style = 'ansi' })
    local data = { 'This is test data\r' }

    local lines, _ = chanor(data)
    local _lines, _ = chanor(nil)
    vim.list_extend(lines, _lines)
    for _, line in ipairs(lines) do
        vim.print(line)
    end
end

function T.sqljson()
    -- { 'kkharji/sqlite.lua', lazy = true }
    vim.g.sqlite_clib_path = dir_init .. '/../local/lib/sqlite3.dll'
    vim.opt.rtp:prepend(dir_bundle .. '/sqlite.lua')

    local name = 'sqljson'
    local data = { version = { major = 3, minor = 12 } }
    for k = 1, 20000 do
        data['attach' .. tostring(k)] = { 'sql', 'json' }
    end
    local data_str = vim.json.encode(data)

    local sql = require('sqlite')
    local db = sql.open(':memery:')
    db:execute([[create table rets(
        id integer primary key,
        name text,
        data text
    );]])
    db:execute(([[insert into rets (name, data) values ('%s', '%s')]]):format(name, data_str))

    local s = vim.fn.reltime()
    local res
    for _ = 1, 100 do
        res = db:eval([[select name, json_extract(data, '$.version.minor') as ver from rets;]])
    end
    vim.print(('%f s'):format(vim.fn.reltimefloat(vim.fn.reltime(s))))
    vim.print(res)

    s = vim.fn.reltime()
    for _ = 1, 100 do
        res = vim.json.decode(data_str).version.minor
    end
    vim.print(('%f s'):format(vim.fn.reltimefloat(vim.fn.reltime(s))))
    vim.print(('ver = %s'):format(res))

    db:close()
end

T.chanor()
T.sqljson()
vim.print('')

return T
