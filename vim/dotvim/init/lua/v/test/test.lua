--- Simple testcases for neovim configration
--- @usage nvim -l test.lua

local dir_this = vim.fn.getcwd()
local dir_base = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(dir_this)))
vim.opt.rtp:prepend(dir_base)
local libv = require('v.libv')

local function EQ(expected, actual)
    assert(
        -- Tables are compared recursively unless they both provide the `eq` metamethod
        vim.deep_equal(expected, actual),
        string.format(
            '%s\nExpect left:\n    %s\nEqual to right:\n    %s',
            string.gsub(debug.traceback(), '\t', '    '),
            vim.inspect(expected),
            vim.inspect(actual)
        )
    )
end

local function NEQ(expected, actual)
    assert(
        not vim.deep_equal(expected, actual),
        string.format(
            '%s\nExpect left:\n    %s\nNOT equal to right:\n    %s',
            string.gsub(debug.traceback(), '\t', '    '),
            vim.inspect(expected),
            vim.inspect(actual)
        )
    )
end

local function OK(f, ...)
    local status, ret = pcall(f, ...)
    assert(status, string.format('%s:\n%s', debug.traceback(), vim.inspect(ret)))
    return ret
end

local function NOK(f, ...)
    local status, ret = pcall(f, ...)
    assert(not status, string.format('%s:\n%s', debug.traceback(), vim.inspect(ret)))
    return ret
end

local tst = {}

function tst.str2env()
    local str = ' VAR0=var0   VAR1=var1 '
    local env = libv.u.str2env(str)
    EQ({ VAR0 = 'var0', VAR1 = 'var1' }, env)
    vim.print(env)
end

function tst.new_configer()
    -- Create config
    NOK(libv.new_configer)
    local cfg = OK(libv.new_configer, { file = 'test.cpp' })
    EQ({ file = 'test.cpp' }, cfg)

    -- Methods
    NOK(function() cfg.add = 'foo' end)
    NOK(function() cfg.del = 'foo' end)
    NOK(function() cfg.set = 'foo' end)
    NOK(function() cfg.reinit = 'foo' end)

    -- Modify option and non-savable option
    cfg.file = 'test.c'
    cfg.type = 'c'
    EQ('test.c', rawget(cfg, 'file'))
    EQ(nil, rawget(cfg, 'type'))
    EQ('c', rawget(getmetatable(getmetatable(cfg)), 'type'))

    -- Add and delete option
    cfg:add('cmd', 'gcc')
    cfg.cmd = 'g++'
    EQ('g++', rawget(cfg, 'cmd'))
    cfg:del('cmd')
    EQ(nil, rawget(cfg, 'cmd'))

    -- Seperate non-savable option
    local cfg2 = libv.new_configer({ exec = 'true' })
    cfg2:reinit({ exec = 'false' })
    cfg2.args = 'args'
    EQ(nil, rawget(getmetatable(getmetatable(cfg)), 'args'))

    -- Get config
    local out = cfg:get()
    EQ({ file = 'test.c' }, out)
    EQ(nil, getmetatable(out))

    -- Setup config
    cfg:set({ cmd = 'gcc', args = { '-g', '-o' } })
    EQ('c', rawget(getmetatable(getmetatable(cfg)), 'type'))
    EQ({ cmd = 'gcc', file = 'test.c', args = { '-g', '-o' } }, cfg)
    NEQ({ cmd = 'gcc', file = 'test.c', args = { 'g', 'o' } }, cfg)

    -- Reinit config
    cfg:reinit()
    EQ({ file = 'test.cpp' }, cfg)
    EQ(nil, rawget(getmetatable(getmetatable(cfg)), 'type'))
    cfg:reinit({ cmd = 'rust', file = 'test.rs' })
    cfg.type = 'rust'
    EQ({ cmd = 'rust', file = 'test.rs' }, cfg)

    -- Encode config to json
    vim.print(OK(vim.json.encode, cfg))

    vim.print(cfg)
end

function tst.new_chanor()
    local data = require('v.test.data')

    local chanor = libv.new_chanor({ connect_pty = true, hl_ansi_sgr = true })
    local chunk
    local lines = {}
    for _, d in ipairs(data[1]) do
        chunk, __ = chanor(d)
        vim.list_extend(lines, chunk)
    end
    EQ('', lines[8])
    EQ('', lines[10])
    EQ('Hello Rust', lines[#lines])

    for _, line in ipairs(lines) do
        vim.print(vim.inspect(line))
    end
end

print('Test work at', dir_this)
for t, f in vim.spairs(tst) do
    print(' ')
    print(string.format('--- Run testcase %s ------------------------------', t))
    local status, ret = pcall(f)
    if status then
        print(string.format('--- Pass testcase %s ------------------------------', t))
    else
        print(ret)
        print(string.format('--- Failed testcase %s ------------------------------', t))
    end
end
