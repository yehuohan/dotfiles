--- Simple testcases for neovim configration
--- vim@code: nvim --headless --noplugin -u NONE -i NONE -n -c "set rtp+=../../../../bundle/plenary.nvim | runtime plugin/plenary.vim | PlenaryBustedDirectory ."
--- vim@code: :PlenaryBustedFile %

local dir_this = vim.fn.getcwd()
local dir_base = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(dir_this)))
vim.opt.rtp:prepend(dir_base)
local libv = require('v.libv')

local EQ = assert.are.same -- The table's metatable won't be compared
local OK = assert.has_no.errors
local NOK = assert.has.errors

describe('libv', function()
    describe('. utils', function()
        -- libv.u.str2env
        it('. str2env', function()
            local str = ' VAR0=var0   VAR1=var1 '
            local env = libv.u.str2env(str)
            EQ({ VAR0 = 'var0', VAR1 = 'var1' }, env)
        end)

        -- libv.u.replace
        it('. replace', function()
            local cmd = 'nvim {arg} -l {src}'
            local rep = { arg = '--headless', src = 'test.lua' }
            local out = libv.u.replace(cmd, rep)
            EQ('nvim --headless -l test.lua', out)
        end)

        -- libv.u.deepcopy
        it('. deepcopy', function()
            local function check(orig)
                local copy

                -- Without table as key
                copy = libv.u.deepcopy(orig, true)
                EQ({ foo = { 'bar' }, null = vim.NIL }, copy)
                EQ({ sub = { 'tbl' } }, getmetatable(copy))

                copy = libv.u.deepcopy(orig, false)
                EQ({ foo = { 'bar' }, null = vim.NIL }, copy)
                EQ(nil, getmetatable(copy))

                -- With table as key
                local mkey = { abc = 'abc' }
                setmetatable(mkey, { cba = 'cba' })
                orig[mkey] = 'mkey'

                copy = libv.u.deepcopy(orig, true)
                EQ({ sub = { 'tbl' } }, getmetatable(copy))
                for k, v in pairs(copy) do
                    if type(k) == 'table' then
                        EQ({ abc = 'abc' }, k)
                        EQ({ cba = 'cba' }, getmetatable(k))
                        EQ('mkey', v)
                    end
                end

                copy = libv.u.deepcopy(orig, false)
                EQ(nil, getmetatable(copy))
                for k, v in pairs(copy) do
                    if type(k) == 'table' then
                        EQ({ abc = 'abc' }, k)
                        EQ(nil, getmetatable(k))
                        EQ('mkey', v)
                    end
                end
            end

            local orig
            orig = { foo = { 'bar' }, null = vim.NIL }
            setmetatable(orig, { sub = { 'tbl' } })
            check(orig)
            vim.cmd("let g:Orig = { 'foo' : ['bar'], 'null' : v:null }")
            orig = vim.g.Orig
            setmetatable(orig, { sub = { 'tbl' } })
            check(orig)
        end)

        -- lib.v.deepmerge
        it('. deepmerge', function()
            local dst = { foo = { 'bar' } }
            setmetatable(dst, { m1 = { 'aaa' } })
            setmetatable(dst.foo, { m2 = { 'bbb' } })
            local src = { foo = { 'BAR', bar = { 'FOO' }, abc = 'cba' } }
            setmetatable(src, { M1 = { 'AAA' } })
            setmetatable(src.foo, { M2 = { 'BBB' } })

            libv.u.deepmerge(dst, src, { 'foo', foo = { 1, 'bar' } })
            EQ({ foo = { 'BAR', bar = { 'FOO' } } }, dst)
            EQ({ m1 = { 'aaa' } }, getmetatable(dst))
            EQ({ m2 = { 'bbb' } }, getmetatable(dst.foo))

            libv.u.deepmerge(dst, src)
            EQ({ foo = { 'BAR', bar = { 'FOO' }, abc = 'cba' } }, dst)
            EQ({ m1 = { 'aaa' } }, getmetatable(dst))
            EQ({ m2 = { 'bbb' } }, getmetatable(dst.foo))
        end)
    end)

    -- libv.new_configer
    describe('. new_configer', function()
        it('. new', function()
            NOK(function() libv.new_configer() end)
            OK(function() libv.new_configer({}) end)
        end)

        it('. modify methods', function()
            local cfg = libv.new_configer({})
            NOK(function() cfg.get = 'foo' end)
            NOK(function() cfg.set = 'foo' end)
            NOK(function() cfg.reinit = 'foo' end)
        end)

        it('. modify savable and non-savable options', function()
            -- Seperate savable and non-savable option of one configer
            local cfg = libv.new_configer({ file = 'foo.c' })
            EQ({ file = 'foo.c' }, cfg)
            cfg.file = 'foo.cpp'
            cfg.type = 'cpp'
            EQ('foo.cpp', rawget(cfg, 'file'))
            EQ(nil, rawget(cfg, 'type'))
            EQ('cpp', rawget(getmetatable(getmetatable(cfg)), 'type'))
            -- Seperate non-savable option between configers
            local cfg2 = libv.new_configer({ file = 'bar.c' })
            cfg2.type = 'c'
            EQ('cpp', rawget(getmetatable(getmetatable(cfg)), 'type'))
            EQ('c', rawget(getmetatable(getmetatable(cfg2)), 'type'))
        end)

        it('. get/set/reinit', function()
            local cfg = libv.new_configer({ file = 'foo.c', args = { '-g' } })
            -- .get
            local out = cfg:get()
            EQ({ file = 'foo.c', args = { '-g' } }, out)
            EQ(nil, getmetatable(out))
            -- .set
            cfg.type = 'c'
            cfg:set({ cmd = 'gcc', args = { '-f' } }, { 'cmd' })
            EQ({ cmd = 'gcc', file = 'foo.c', args = { '-g' } }, cfg)
            cfg:set({ cmd = 'gcc', args = { '-f' } })
            EQ({ cmd = 'gcc', file = 'foo.c', args = { '-f' } }, cfg)
            EQ('c', rawget(getmetatable(getmetatable(cfg)), 'type'))
            -- .reinit
            cfg:reinit()
            EQ({ file = 'foo.c', args = { '-g' } }, cfg)
            EQ(nil, rawget(getmetatable(getmetatable(cfg)), 'type'))
        end)

        it('. new/reinit with multi-level-table-option', function()
            local function check(cfg)
                local ab2 = { 'a', 'b', 2 }
                local AB2 = { 'A', 'B', 2 }
                cfg.args[#cfg.args + 1] = '-b'
                cfg.args[5] = '-c'
                cfg.args[ab2] = 'ab2'
                cfg.args.num = 2
                cfg.args.inp = 'src'
                cfg.args.ARGS[#cfg.args.ARGS + 1] = '-B'
                cfg.args.ARGS[5] = '-C'
                cfg.args.ARGS[AB2] = 'AB2'
                cfg.args.ARGS.CNT = 2
                cfg.args.ARGS.OUT = 'BIN'
                EQ({
                    cmd = 'gcc',
                    file = 'foo.c',
                    args = { '-a', '-b', num = 2, ARGS = { '-A', '-B', CNT = 2 } },
                }, cfg)
                EQ({
                    [5] = '-c',
                    [ab2] = 'ab2',
                    inp = 'src',
                    ARGS = {
                        [5] = '-C',
                        [AB2] = 'AB2',
                        OUT = 'BIN',
                    },
                }, getmetatable(getmetatable(cfg)).args)
            end

            local cfg1 = libv.new_configer({
                cmd = 'gcc',
                file = 'foo.c',
                args = { '-a', num = 1, ARGS = { '-A', CNT = 1 } },
            })
            check(cfg1)
            local cfg2 = libv.new_configer({ file = 'bar.c' })
            cfg2:reinit({
                cmd = 'gcc',
                file = 'foo.c',
                args = { '-a', num = 1, ARGS = { '-A', CNT = 1 } },
            })
            check(cfg2)
        end)

        it('. encode/decode to/from json', function()
            local opts = { cmd = 'g++', file = 'test.cpp', args = { '-g' } }
            local cfg = libv.new_configer(opts)
            cfg.type = 'cpp'
            local str = vim.json.encode(cfg)
            local tbl = vim.json.decode(str)
            EQ(opts, tbl)
        end)
    end)

    -- libv.new_chanor
    it('. new_chanor', function()
        local data = require('v.test.data')
        local chanor = libv.new_chanor({ style = 'ansi' })
        local chunk
        local lines = {}
        for _, d in ipairs(data[1]) do
            chunk, __ = chanor(d)
            vim.list_extend(lines, chunk)
        end
        EQ('', lines[8])
        EQ('', lines[10])
        EQ('Hello Rust', lines[#lines])

        -- for _, line in ipairs(lines) do
        --     vim.print(vim.inspect(line))
        -- end
    end)

    -- libv.modeline
    it('. modeline', function()
        local mocked1 = io.lines
        local mocked2 = vim.notify
        io.lines = function(data)
            local idx = 0
            return function()
                idx = idx + 1
                return idx <= #data and data[idx]
            end
        end
        local msg
        vim.notify = function(data) EQ(msg, data) end

        local tbl, cmd
        local lines = {
            { [[-- vim@code: nvim -l test.lua]] },
            { [[-- vim@code { }: nvim -l test.lua]] },
            { [[-- vim@code{ }: nvim -l test.lua]] },
            { [[-- vim@code{ foo - BAR }: nvim -l test.lua]] },
            { [[-- vim@code{ envs = { TEST = 'test'}, args = '--headless' }: 	]] },
            { [[-- vim@code{ envs = { TEST = 'test'}, args = '--headless' }: nvim -l test.lua]] },
        }

        tbl, cmd = libv.modeline('code', lines[1])
        EQ(nil, tbl)
        EQ('nvim -l test.lua', cmd)

        tbl, cmd = libv.modeline('code', lines[2])
        EQ(nil, tbl)
        EQ('nvim -l test.lua', cmd)

        tbl, cmd = libv.modeline('code', lines[3])
        EQ({}, tbl)
        EQ('nvim -l test.lua', cmd)

        msg = 'Wrong table from modeline: { foo - BAR }'
        tbl, cmd = libv.modeline('code', lines[4])
        EQ(nil, tbl)
        EQ('nvim -l test.lua', cmd)

        tbl, cmd = libv.modeline('code', lines[5])
        EQ({ envs = { TEST = 'test' }, args = '--headless' }, tbl)
        EQ(nil, cmd)

        tbl, cmd = libv.modeline('code', lines[6])
        EQ({ envs = { TEST = 'test' }, args = '--headless' }, tbl)
        EQ('nvim -l test.lua', cmd)

        io.lines = mocked1
        vim.notify = mocked2
    end)
end)
