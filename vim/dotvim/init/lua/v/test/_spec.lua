--- Simple testcases for neovim configration
--- vim@code{ tout = { style = 'term'}}: nvim --headless --noplugin -u NONE -i NONE -n -c "set rtp+=../../../../bundle/plenary.nvim | runtime plugin/plenary.vim | PlenaryBustedDirectory . {minimal_init='NONE'}"

local dir_this = vim.fn.getcwd()
local dir_init = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(dir_this)))
local dir_bundle = vim.fs.dirname(dir_init) .. '/bundle'
vim.opt.rtp:prepend(dir_init)
vim.opt.rtp:prepend(dir_bundle .. '/popc')
vim.opt.rtp:prepend(dir_bundle .. '/popset')
vim.opt.rtp:prepend(dir_bundle .. '/overseer.nvim')
vim.cmd.runtime('plugin/popc.vim')
vim.cmd.runtime('plugin/popset.vim')
vim.cmd.runtime('plugin/overseer.nvim')

local EQ = assert.are.same -- The table's metatable won't be compared
local OK = assert.has_no.errors
local NOK = assert.has.errors

--- @param fns(table<table<table, string>>) All function need to mock
local function mock(fns)
    local mocked = {}
    for _, fn in ipairs(fns) do
        for k = 2, #fn do
            mocked[fn[k]] = fn[1][fn[k]]
        end
    end
    return mocked
end

--- @param fns(table<table<table, string>>) All function need to unmock
local function unmock(mocked, fns)
    for _, fn in ipairs(fns) do
        for k = 2, #fn do
            fn[1][fn[k]] = mocked[fn[k]]
        end
    end
end

--- @param keys(string)
local function feedkeys(keys)
    local codes = vim.api.nvim_replace_termcodes(keys, true, false, true)
    return vim.api.nvim_feedkeys(codes, 'x', false)
end

describe('nlib', function()
    local nlib = require('v.nlib')

    -- nlib.new_configer
    describe('. new_configer', function()
        it('. new', function()
            NOK(function() nlib.new_configer() end)
            OK(function() nlib.new_configer({}) end)
        end)

        it('. modify methods', function()
            local cfg = nlib.new_configer({})
            NOK(function() cfg.get = 'foo' end)
            NOK(function() cfg.set = 'foo' end)
            NOK(function() cfg.reinit = 'foo' end)
        end)

        it('. modify savable and non-savable options', function()
            -- Seperate savable and non-savable option of one configer
            local cfg = nlib.new_configer({ file = 'foo.c' })
            EQ({ file = 'foo.c' }, cfg)
            cfg.file = 'foo.cpp'
            cfg.type = 'cpp'
            EQ('foo.cpp', rawget(cfg, 'file'))
            EQ(nil, rawget(cfg, 'type'))
            EQ('cpp', rawget(getmetatable(getmetatable(cfg)), 'type'))
            -- Seperate non-savable option between configers
            local cfg2 = nlib.new_configer({ file = 'bar.c' })
            cfg2.type = 'c'
            EQ('cpp', rawget(getmetatable(getmetatable(cfg)), 'type'))
            EQ('c', rawget(getmetatable(getmetatable(cfg2)), 'type'))
        end)

        it('. get/set/reinit', function()
            local cfg = nlib.new_configer({ file = 'foo.c', args = { '-g' } })
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

            local cfg1 = nlib.new_configer({
                cmd = 'gcc',
                file = 'foo.c',
                args = { '-a', num = 1, ARGS = { '-A', CNT = 1 } },
            })
            check(cfg1)
            local cfg2 = nlib.new_configer({ file = 'bar.c' })
            cfg2:reinit({
                cmd = 'gcc',
                file = 'foo.c',
                args = { '-a', num = 1, ARGS = { '-A', CNT = 1 } },
            })
            check(cfg2)
        end)

        it('. encode/decode to/from json', function()
            local opts = { cmd = 'g++', file = 'test.cpp', args = { '-g' } }
            local cfg = nlib.new_configer(opts)
            cfg.type = 'cpp'
            local str = vim.json.encode(cfg)
            local tbl = vim.json.decode(str)
            EQ(opts, tbl)
        end)
    end)

    -- nlib.new_chanor
    it('. new_chanor', function()
        local data = require('v.test.data')
        local chanor = nlib.new_chanor({ style = 'ansi' })
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

    -- nlib.modeline
    it('. modeline', function()
        local fns = { { io, 'lines' }, { vim, 'notify' } }
        local mocked = mock(fns)

        io.lines = function(data)
            local idx = 0
            return function()
                idx = idx + 1
                return idx <= #data and data[idx] or nil
            end
        end
        local msg
        vim.notify = function(_msg) msg = _msg end

        local lines, tbl, cmd

        lines = { [[head-foo]], [[-- vim@code: nvim -l lua]], [[tail-bar]] }
        tbl, cmd = nlib.modeline('code', lines)
        EQ(nil, tbl)
        EQ('nvim -l lua', cmd)

        lines = { [[head-foo]], [[-- vim@code { }: nvim -l lua]], [[tail-bar]] }
        tbl, cmd = nlib.modeline('code', lines)
        EQ(nil, tbl)
        EQ(nil, cmd)

        lines = { [[head-foo]], [[-- vim@code{ }: nvim -l lua]], [[tail-bar]] }
        tbl, cmd = nlib.modeline('code', lines)
        EQ({}, tbl)
        EQ('nvim -l lua', cmd)

        lines = { [[head-foo]], [[-- vim@code{ foo - BAR }: nvim -l lua]], [[tail-bar]] }
        tbl, cmd = nlib.modeline('code', lines)
        EQ(nil, tbl)
        EQ('nvim -l lua', cmd)
        EQ('Wrong table from modeline: { foo - BAR }', msg)

        lines = {
            [[head-foo]],
            [[-- vim@code{ envs = { FOO = 'bar'}, args = '-l' }: 	]],
            [[tail-bar]],
        }
        tbl, cmd = nlib.modeline('code', lines)
        EQ({ envs = { FOO = 'bar' }, args = '-l' }, tbl)
        EQ(nil, cmd)

        lines = {
            [[head-foo]],
            [[-- vim@code{ envs = { FOO = 'bar'}, args = '-l' }: nvim -l lua]],
            [[tail-bar]],
        }
        tbl, cmd = nlib.modeline('code', lines)
        EQ({ envs = { FOO = 'bar' }, args = '-l' }, tbl)
        EQ('nvim -l lua', cmd)

        lines = { [[head-foo]], [[-- vim@code: :Test]], [[tail-bar]] }
        tbl, cmd = nlib.modeline('code', lines)
        EQ(nil, tbl)
        EQ(':Test', cmd)

        unmock(mocked, fns)
    end)

    -- nlib.a.pop_selection
    it('. async . pop_selection', function()
        local tst = { opt = '', lst = { 1, 2, 3 }, num = 0 }
        tst.cmd = function(sopt, sel) tst.num = tst.num + 1 + sel end
        tst.evt = function(name)
            if 'onCR' == name then
                tst.opt = 'foo'
            elseif 'onQuit' == name then
                tst.opt = 'bar'
            end
        end
        local res
        local entry = nlib.a._async(function(sel, val)
            sel.opt = val
            res = nlib.a._await(nlib.a.pop_selection(sel))
        end)

        entry(tst, 'FOO')
        EQ('FOO', tst.opt)
        EQ(0, tst.num)
        feedkeys('<Space>')
        EQ(0 + 1 + 1, tst.num)
        feedkeys('j<CR>')
        EQ(2 + 1 + 2, tst.num)
        EQ('foo', tst.opt)
        EQ(true, res)

        entry(tst)
        EQ(nil, tst.opt)
        feedkeys('jj<Space>')
        EQ(5 + 1 + 3, tst.num)
        feedkeys('<ESC>')
        EQ(9, tst.num)
        EQ('bar', tst.opt)
        EQ(false, res)
    end)

    describe('. utils', function()
        -- nlib.u.str2env
        it('. str2env', function()
            local str = ' VAR0=var0   VAR1=var1 '
            local env = nlib.u.str2env(str)
            EQ({ VAR0 = 'var0', VAR1 = 'var1' }, env)
        end)

        -- nlib.u.replace
        it('. replace', function()
            local cmd = 'nvim {arg} -l {src}'
            local rep = { arg = '--headless', src = 'test.lua' }
            local out = nlib.u.replace(cmd, rep)
            EQ('nvim --headless -l test.lua', out)
        end)

        -- nlib.u.deepcopy
        it('. deepcopy', function()
            local function check(orig)
                local copy

                -- Without table as key
                copy = nlib.u.deepcopy(orig, true)
                EQ({ foo = { 'bar' }, null = vim.NIL }, copy)
                EQ({ sub = { 'tbl' } }, getmetatable(copy))

                copy = nlib.u.deepcopy(orig, false)
                EQ({ foo = { 'bar' }, null = vim.NIL }, copy)
                EQ(nil, getmetatable(copy))

                -- With table as key
                local mkey = { abc = 'abc' }
                setmetatable(mkey, { cba = 'cba' })
                orig[mkey] = 'mkey'

                copy = nlib.u.deepcopy(orig, true)
                EQ({ sub = { 'tbl' } }, getmetatable(copy))
                for k, v in pairs(copy) do
                    if type(k) == 'table' then
                        EQ({ abc = 'abc' }, k)
                        EQ({ cba = 'cba' }, getmetatable(k))
                        EQ('mkey', v)
                    end
                end

                copy = nlib.u.deepcopy(orig, false)
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

            nlib.u.deepmerge(dst, src, { 'foo', foo = { 1, 'bar' } })
            EQ({ foo = { 'BAR', bar = { 'FOO' } } }, dst)
            EQ({ m1 = { 'aaa' } }, getmetatable(dst))
            EQ({ m2 = { 'bbb' } }, getmetatable(dst.foo))

            nlib.u.deepmerge(dst, src)
            EQ({ foo = { 'BAR', bar = { 'FOO' }, abc = 'cba' } }, dst)
            EQ({ m1 = { 'aaa' } }, getmetatable(dst))
            EQ({ m2 = { 'bbb' } }, getmetatable(dst.foo))
        end)
    end)
end)

describe('task', function()
    require('v')
    local task = require('v.task')
    task.setup()
    local fns = { { task, 'run' }, { vim, 'notify', 'print' }, { vim.fn, 'input' } }
    local mocked = mock(fns)

    local cfg, msg, txt, inp
    task.run = function(_cfg) cfg = _cfg end
    vim.notify = function(_msg) msg = _msg end
    vim.print = function(_txt) txt = _txt end
    vim.fn.input = function() return inp end

    local tmp
    before_each(function()
        tmp = vim.fn.tempname() .. '.lua'
        vim.cmd.edit(tmp)
        vim.cmd.write()
    end)

    it('. code . :CodeWscInit', function()
        vim.cmd.CodeWsc({ bang = true })
        EQ('ansi', txt.style)

        vim.cmd.CodeWscInit()
        feedkeys('kkmjob<CR>')
        feedkeys('<CR>')
        vim.cmd.CodeWsc({ bang = true })
        EQ('job', txt.style)

        -- Change back code.wsc, or has effect on other test items
        vim.cmd.CodeWscInit()
        feedkeys('kkmansi<CR>')
        feedkeys('<CR>')
        vim.cmd.CodeWsc({ bang = true })
        EQ('ansi', txt.style)
    end)

    it('. code . :Code! Rp', function()
        vim.cmd.Code({ args = { 'Rp' }, bang = true })
        feedkeys('mf<CR>')
        feedkeys('jm' .. tmp .. '<CR>')
        feedkeys('kkmterm<CR>')
        feedkeys('<CR>')
        EQ('f', cfg.key)
        EQ(vim.fn.expand(tmp), vim.fn.expand(cfg.file))
        EQ('lua', cfg.type)
        EQ('term', cfg.tout.style)
        EQ(true, vim.startswith(msg, 'resovle = true, restore = true'))

        vim.cmd.TaskWsc()
        EQ('f', txt.code.key)
        EQ(vim.fn.expand(tmp), vim.fn.expand(txt.code.file))
        EQ('lua', txt.code.type)
        EQ('term', txt.code.style)

        vim.cmd.CodeWsc({ bang = true })
        EQ('', txt.key)
        EQ('', txt.file)
        EQ('', txt.type)
        EQ('ansi', txt.style)
    end)

    it('. fzer . :Fzer fpw', function()
        feedkeys('iword<Esc>')

        vim.cmd.FzerWsc({ bang = true })
        EQ('', txt.path) -- wsc.path = '' for the first Fzer execution
        inp = 'Z:/abc/def'
        vim.cmd.Fzer({ args = { 'fpw' } })
        EQ(inp, cfg.path)
        vim.cmd.FzerWsc({ bang = true })
        EQ(inp, txt.path)
    end)

    it('. fzer . :Fzer Fw', function()
        feedkeys('iword<Esc>')

        vim.cmd.Fzer({ args = { 'Fw' } })
        feedkeys('jm<CR><CR>') -- Make wsc.path = ''
        EQ(vim.fs.dirname(tmp), cfg.path)
    end)

    unmock(mocked, fns)
end)
