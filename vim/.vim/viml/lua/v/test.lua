-- nvim -l test.lua

local dir_this = vim.fn.getcwd()
local dir_base = vim.fs.dirname(vim.fs.dirname(dir_this))
vim.opt.rtp:prepend(dir_base)
local libv = require('v.libv')

local function EQ(expected, actual)
    assert(
        -- Tables are compared recursively unless they both provide the `eq` metamethod
        vim.deep_equal(expected, actual),
        string.format(
            '%s\nexpected:\n%s\nis not equal to actual:\n%s',
            debug.traceback(),
            vim.inspect(expected),
            vim.inspect(actual)
        )
    )
end

local function NEQ(expected, actual)
    assert(
        not vim.deep_equal(expected, actual),
        string.format(
            '%s\nexpected:\n%s\nis equal to actual:\n%s',
            debug.traceback(),
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

local function FAIL(f, ...)
    local status, ret = pcall(f, ...)
    assert(not status, string.format('%s:\n%s', debug.traceback(), vim.inspect(ret)))
    return ret
end

local tst = {}

function tst.new_config()
    -- Create config
    FAIL(libv.new_config)
    local cfg = OK(libv.new_config, { file = 'test.cpp' })
    EQ({ file = 'test.cpp' }, cfg)

    -- Methods
    FAIL(function()
        cfg.add = 'foo'
    end)
    FAIL(function()
        cfg.del = 'foo'
    end)
    FAIL(function()
        cfg.set = 'foo'
    end)
    FAIL(function()
        cfg.reinit = 'foo'
    end)

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
    local cfg2 = libv.new_config({})
    cfg2.args = 'args'
    EQ(nil, rawget(getmetatable(getmetatable(cfg)), 'args'))

    -- Setup config
    cfg:set({ cmd = 'gcc', args = { '-g', '-o' } })
    EQ('c', rawget(getmetatable(getmetatable(cfg)), 'type'))
    EQ({ cmd = 'gcc', file = 'test.c', args = { '-g', '-o' } }, cfg)
    NEQ({ cmd = 'gcc', file = 'test.c', args = { 'g', 'o' } }, cfg)

    -- reinit config
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

print('Test work at', dir_this)
for t, f in pairs(tst) do
    print(string.format('--- Run testcase %s ------------------------------', t))
    local status, ret = pcall(f)
    if status then
        print(string.format('--- End testcase %s ------------------------------', t))
    else
        print(ret)
        print(string.format('--- Failed testcase %s ------------------------------', t))
    end
end