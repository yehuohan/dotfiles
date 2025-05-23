--- Simple testcases for neovim configration
--- vim@code{ style = 'term' }: nvim --headless --noplugin -i NONE -u NONE -n -c "set rtp+=../../../../bundle/plenary.nvim | runtime plugin/plenary.vim | PlenaryBustedDirectory . {minimal_init='NONE'}"

local dir_this = vim.fn.getcwd()
local dir_init = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(dir_this)))
local dir_bundle = vim.fs.dirname(dir_init) .. '/bundle'
vim.opt.rtp:prepend(dir_init)
vim.opt.rtp:prepend(dir_bundle .. '/popc')
vim.opt.rtp:prepend(dir_bundle .. '/overseer.nvim')
require('popc').setup({ selection = { enable = true } })
require('overseer').setup()
require('plenary.busted')

local EQ = assert.are.same -- The table's metatable won't be compared
local OK = assert.has.no.errors
local NOK = assert.has.errors

--- @alias MockFnList [table, string, ...]

--- Mock some funcions
---
--- Example:
---
--- ```lua
--- local fns = { { vim, 'notify', 'print' }, { vim.fn, 'input' } }
--- local mocked = mock(fns)
--- unmock(mocked, fns)
--- ```
--- @param fns MockFnList[] All function need to mock
local function mock(fns)
    local mocked = {}
    for _, fn in ipairs(fns) do
        for k = 2, #fn do
            mocked[fn[k]] = fn[1][fn[k]]
        end
    end
    return mocked
end

--- Restor the mocked funcions
--- @param fns MockFnList[] All function need to unmock
local function unmock(mocked, fns)
    for _, fn in ipairs(fns) do
        for k = 2, #fn do
            fn[1][fn[k]] = mocked[fn[k]]
        end
    end
end

local function override_input(...)
    local idx = 0
    local inps = { ... }
    vim.fn.input = function(args)
        idx = idx + 1
        return (args.default or '') .. inps[idx]
    end
end

local function override_getcharstr(...)
    local idx = 0
    local chars = { ... }
    vim.fn.getcharstr = function()
        idx = idx + 1
        return vim.keycode(chars[idx] or '<Esc>')
    end
end

--- @param keys string
local function feedkeys(keys)
    local codes = vim.api.nvim_replace_termcodes(keys, true, false, true)
    return vim.api.nvim_feedkeys(codes, 'x', false)
end

describe('nlib', function()
    local nlib = require('v.nlib')

    -- nlib.new_configer
    describe('. new_configer', function()
        it('. initialize', function()
            ---@diagnostic disable-next-line:missing-parameter
            NOK(function() nlib.new_configer() end)
            local opts = {}
            local cfg
            OK(function() cfg = nlib.new_configer(opts) end)
            EQ(true, cfg == opts)
            EQ(true, getmetatable(cfg) ~= nil)
            EQ(true, getmetatable(getmetatable(cfg)) ~= nil)
        end)

        local cfg, nsc
        before_each(function()
            cfg = nlib.new_configer({ file = 'foo.c', args = { '-f', subs = { '-g' } } })
            nsc = { args = { subs = {} } }
            nsc.__index = nsc
        end)

        it('. methods', function()
            NOK(function() cfg.__opts = 'foo' end)
            NOK(function() cfg.new = 'foo' end)
            NOK(function() cfg.mut = 'foo' end)
            NOK(function() cfg.set = 'foo' end)
            NOK(function() cfg.get = 'foo' end)
        end)

        it('. savable and non-savable options', function()
            EQ({ file = 'foo.c', args = { '-f', subs = { '-g' } } }, cfg)
            EQ(nsc, getmetatable(getmetatable(cfg)))
            cfg.file = 'foo.rs'
            cfg.type = 'rs'
            cfg.opts = { '-o' }
            EQ('foo.rs', rawget(cfg, 'file'))
            EQ(nil, rawget(cfg, 'type'))
            EQ(nil, rawget(cfg, 'opts'))
            EQ('rs', getmetatable(getmetatable(cfg)).type)
            EQ({ '-o' }, getmetatable(getmetatable(cfg)).opts)
            cfg.args[1] = '-f1'
            cfg.args[2] = '-f2'
            rawset(cfg.args, 3, '-f3')
            cfg.args.opts = { '-a' }
            EQ({ '-f1', [3] = '-f3', subs = { '-g' } }, rawget(cfg, 'args'))
            EQ({ [2] = '-f2', subs = {}, opts = { '-a' } }, getmetatable(getmetatable(cfg)).args)
            cfg.args.subs[1] = '-g1'
            cfg.args.subs[2] = '-g2'
            cfg.args.subs.opts = { '-b' }
            EQ({ '-g1' }, cfg.args.subs)
            EQ({ [2] = '-g2', opts = { '-b' } }, getmetatable(getmetatable(cfg)).args.subs)
        end)

        it('. new', function()
            cfg.file = 'foo.rs'
            cfg.type = 'rs'
            cfg.opts = { '-o' }
            cfg.args[1] = '-f1'
            cfg.args[2] = '-f2'
            cfg.args.opts = { '-a' }
            cfg.args.subs[1] = '-g1'
            cfg.args.subs[2] = '-g2'
            cfg.args.subs.opts = { '-b' }
            cfg:new()
            EQ({ file = 'foo.c', args = { '-f', subs = { '-g' } } }, cfg)
            EQ(nsc, getmetatable(getmetatable(cfg)))
            cfg.file = 'foo.rs'
            cfg.type = 'rs'
            cfg.opts = { '-o' }
            cfg.args[1] = '-f1'
            cfg.args[2] = '-f2'
            cfg.args[3] = '-f3'
            cfg.args.opts = { '-a' }
            cfg.args.subs[1] = '-g1'
            cfg.args.subs[2] = '-g2'
            cfg.args.subs[3] = '-g3'
            cfg.args.subs.opts = { '-b' }
            cfg:new({
                path = './',
                opts = { '-o' },
                args = { '-f', subs = { '-g', opts = { '-b' } } },
            })
            cfg.args[1] = '-F'
            cfg.args[2] = '-F2'
            cfg.args.subs[1] = '-G'
            cfg.args.subs[2] = '-G2'
            cfg.args.subs.opts[2] = '-B2'
            EQ({
                path = './',
                opts = { '-o' },
                args = { '-F', subs = { '-G', opts = { '-b' } } },
            }, cfg)
            nsc.opts = {}
            nsc.args = {
                [2] = '-F2',
                subs = { [2] = '-G2', opts = { [2] = '-B2' } },
            }
            EQ(nsc, getmetatable(getmetatable(cfg)))
        end)

        it('. mut', function()
            cfg.file = 'foo.rs'
            cfg.type = 'rs'
            cfg.opts = { '-o' }
            cfg.args[1] = '-f1'
            cfg.args[2] = '-f2'
            cfg.args[3] = '-f3'
            cfg.args.opts = { '-a' }
            cfg.args.subs[1] = '-g1'
            cfg.args.subs[2] = '-g2'
            cfg.args.subs[3] = '-g3'
            cfg.args.subs.opts = { '-b' }
            cfg:mut({
                path = './',
                type = 'c',
                args = { '-f', '-e', subs = { '-g', opts = { '-b' } } },
            })
            cfg.type = 'rs'
            cfg.args[2] = '-E'
            cfg.args.subs[2] = '-G2'
            cfg.args.subs.opts[2] = '-B2'
            EQ({
                file = 'foo.rs',
                path = './',
                type = 'rs',
                args = { '-f', '-E', subs = { '-g', opts = { '-b' } } },
            }, cfg)
            nsc.type = 'rs'
            nsc.opts = { '-o' }
            nsc.args = {
                [2] = '-f2',
                [3] = '-f3',
                opts = { '-a' },
                subs = { [2] = '-G2', [3] = '-g3', opts = { '-b', '-B2' } },
            }
            EQ(nsc, getmetatable(getmetatable(cfg)))
        end)

        it('. set/get', function()
            -- .set
            cfg:set({
                file = 'foo.rs',
                type = 'rs',
                opts = { '-o' },
                args = { '-f', '-f2', opts = { '-a' }, subs = { '-G', '-g2', opts = { '-b' } } },
            })
            EQ({ file = 'foo.rs', args = { '-f', subs = { '-G' } } }, cfg)
            nsc.type = 'rs'
            nsc.opts = { '-o' }
            nsc.args = {
                [2] = '-f2',
                opts = { '-a' },
                subs = { [2] = '-g2', opts = { '-b' } },
            }
            EQ(nsc, getmetatable(getmetatable(cfg)))
            -- .get
            local res = cfg:get()
            EQ({ file = 'foo.rs', args = { '-f', subs = { '-G' } } }, res)
            EQ(nil, getmetatable(res))
        end)

        it('. encode/decode to/from json', function()
            cfg.file = 'foo.rs'
            cfg.type = 'rs'
            cfg.opts = { '-o' }
            cfg.args[1] = '-F'
            cfg.args[2] = '-f2'
            cfg.args.opts = { '-a' }
            cfg.args.subs[1] = '-G'
            cfg.args.subs[2] = '-g2'
            cfg.args.subs.opts = { '-b' }
            local str = vim.json.encode(cfg)
            local tbl = vim.json.decode(str)
            EQ({
                file = 'foo.rs',
                args = {
                    ['1'] = '-F', -- Json's dict doesn't support integer as key
                    subs = { '-G' }, -- Lua's pure list will convert to json's list
                },
            }, tbl)
            EQ(nil, getmetatable(tbl))
        end)
    end)

    -- nlib.new_chanor
    describe('. new_chanor', function()
        local data = require('v.test.data')
        local chanor
        before_each(function()
            vim.o.columns = 155
            vim.o.lines = 33
            chanor = nlib.new_chanor({ style = 'ansi' })
        end)

        -- for _, line in ipairs(lines) do vim.print(vim.inspect(line)) end
        -- for _, hl in ipairs(hls) do vim.print(vim.inspect(hl)) end
        it('. rust', function()
            local lines, hls = chanor(data.rust.inp)
            local _lines, _hls = chanor({ '' })
            vim.list_extend(lines, _lines)
            vim.list_extend(hls, _hls)
            EQ(data.rust.out, lines)
            EQ(unpack({ 0, 0, 7 }), unpack(hls[1][1], 2, 4))
            EQ(unpack({ 0, 7, 7 + 25 }), unpack(hls[1][1], 2, 4))
            EQ(unpack({ 3, 0, 1 }), unpack(hls[4][1], 2, 4))
            EQ(unpack({ 3, 2, 3 }), unpack(hls[4][2], 2, 4))
        end)

        it('. vulkan', function()
            for _ = 1, vim.o.lines do
                chanor({ '\r' })
            end
            local lines, hls = chanor(data.vulkan.inp)
            local _lines, _hls = chanor({ '' })
            vim.list_extend(lines, _lines)
            vim.list_extend(hls, _hls)
            EQ(data.vulkan.out, lines[#lines])
        end)
    end)

    -- nlib.modeline
    describe('. ext', function()
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
            tbl, cmd = nlib.e.modeline('code', lines)
            EQ(nil, tbl)
            EQ('nvim -l lua', cmd)

            lines = { [[head-foo]], [[-- vim@code { }: nvim -l lua]], [[tail-bar]] }
            tbl, cmd = nlib.e.modeline('code', lines)
            EQ(nil, tbl)
            EQ(nil, cmd)

            lines = { [[head-foo]], [[-- vim@code{ }: nvim -l lua]], [[tail-bar]] }
            tbl, cmd = nlib.e.modeline('code', lines)
            EQ({}, tbl)
            EQ('nvim -l lua', cmd)

            lines = { [[head-foo]], [[-- vim@code{ foo - BAR }: nvim -l lua]], [[tail-bar]] }
            tbl, cmd = nlib.e.modeline('code', lines)
            EQ(nil, tbl)
            EQ('nvim -l lua', cmd)
            EQ('Wrong table from modeline: { foo - BAR }', msg)

            lines = {
                [[head-foo]],
                [[-- vim@code{ envs = { FOO = 'bar'}, args = '-l' }: 	]],
                [[tail-bar]],
            }
            tbl, cmd = nlib.e.modeline('code', lines)
            EQ({ envs = { FOO = 'bar' }, args = '-l' }, tbl)
            EQ(nil, cmd)

            lines = {
                [[head-foo]],
                [[-- vim@code{ envs = { FOO = 'bar'}, args = '-l' }: nvim -l lua]],
                [[tail-bar]],
            }
            tbl, cmd = nlib.e.modeline('code', lines)
            EQ({ envs = { FOO = 'bar' }, args = '-l' }, tbl)
            EQ('nvim -l lua', cmd)

            lines = { [[head-foo]], [[-- vim@code: :Test]], [[tail-bar]] }
            tbl, cmd = nlib.e.modeline('code', lines)
            EQ(nil, tbl)
            EQ(':Test', cmd)

            unmock(mocked, fns)
        end)

        describe('. buf_pipe', function()
            local fns = { { vim, 'notify' } }
            local mocked = mock(fns)
            local msg
            vim.notify = function(_msg) msg = _msg end

            local tmp
            local nextline = '<Esc>o<Esc>:silent w<CR>yy'
            before_each(function()
                tmp = vim.fn.tempname() .. '.txt'
                vim.cmd.edit({ args = { tmp }, mods = { silent = true } })
                vim.cmd.write({ mods = { silent = true } })
                vim.fn.setreg('0', '')
                vim.fn.setreg('+', '')
            end)

            it('. exec/eval', function()
                local inp
                local input = function() return inp end -- Can't use vim.fn.input for it will block at cmdline
                local append_exec = function() nlib.e.buf_pipe(input, 'append', 'exec') end
                local append_eval = function() nlib.e.buf_pipe(input, 'append', 'eval') end
                local yankcopy_exec = function() nlib.e.buf_pipe(input, 'yankcopy', 'exec') end
                local yankcopy_eval = function() nlib.e.buf_pipe(input, 'yankcopy', 'eval') end

                inp = "echo getpos('.')"
                feedkeys(nextline)
                append_exec()
                EQ('[0, 2, 1, 0]', vim.fn.getline(vim.fn.line('.') + 1))
                feedkeys(nextline)
                feedkeys("<Esc>iecho getpos('.')<Esc>:silent w<CR>v0")
                append_exec()
                EQ('[0, 3, 1, 0]', vim.fn.getline(vim.fn.line('.') + 1))

                inp = "getpos('.')"
                feedkeys(nextline)
                append_eval()
                EQ('[0, 4, 1, 0]', vim.fn.getline(vim.fn.line('.') + 1))
                feedkeys(nextline)
                feedkeys("<Esc>igetpos('.')<Esc>:silent w<CR>v0")
                append_eval()
                EQ('[0, 5, 1, 0]', vim.fn.getline(vim.fn.line('.') + 1))

                inp = "echo getpos('.')"
                feedkeys(nextline)
                yankcopy_exec()
                EQ('\n[0, 6, 1, 0]', vim.fn.getreg('0'))
                EQ('\n[0, 6, 1, 0]', vim.fn.getreg('+'))
                EQ('\n[0, 6, 1, 0]', msg)
                feedkeys(nextline)
                feedkeys("<Esc>iecho getpos('.')<Esc>:silent w<CR>v0")
                yankcopy_exec()
                EQ('\n[0, 7, 1, 0]', vim.fn.getreg('0'))
                EQ('\n[0, 7, 1, 0]', vim.fn.getreg('+'))
                EQ('\n[0, 7, 1, 0]', msg)

                inp = "getpos('.')"
                feedkeys(nextline)
                yankcopy_eval()
                EQ('[0, 8, 1, 0]', vim.fn.getreg('0'))
                EQ('[0, 8, 1, 0]', vim.fn.getreg('+'))
                EQ('[0, 8, 1, 0]', msg)
                feedkeys(nextline)
                feedkeys("<Esc>igetpos('.')<Esc>:silent w<CR>v0")
                yankcopy_eval()
                EQ('[0, 9, 1, 0]', vim.fn.getreg('0'))
                EQ('[0, 9, 1, 0]', vim.fn.getreg('+'))
                EQ('[0, 9, 1, 0]', msg)
            end)

            it('. eval_math', function()
                local opts = {}
                local replace_math = function() nlib.e.buf_pipe('line', 'replace', 'eval_math', opts) end
                local yank_math = function() nlib.e.buf_pipe('line', 'yankcopy', 'eval_math', opts) end

                opts.eval = 'eval'
                feedkeys(nextline)
                feedkeys("<Esc>i'test' . 'math' . 'plus'<Esc>:silent w<CR>")
                replace_math()
                EQ("'test' . 'math' . 'plus' = testmathplus", vim.fn.getline('.'))
                yank_math()
                EQ("'test' . 'math' . 'plus' = testmathplus", vim.fn.getreg('0'))
                EQ("'test' . 'math' . 'plus' = testmathplus", vim.fn.getreg('+'))
                EQ("'test' . 'math' . 'plus' = testmathplus", msg)
                feedkeys('<Esc>09lv15l')
                replace_math()
                EQ("'test' . 'math' . 'plus'  = mathplus = testmathplus", vim.fn.getline('.'))
                feedkeys('<Esc>09lv15l')
                yank_math()
                EQ("'test' . 'math' . 'plus'  = mathplus  = mathplus = testmathplus", vim.fn.getreg('0'))
                EQ("'test' . 'math' . 'plus'  = mathplus  = mathplus = testmathplus", vim.fn.getreg('+'))
                EQ("'test' . 'math' . 'plus'  = mathplus  = mathplus = testmathplus", msg)

                opts.eval = 'luaeval'
                feedkeys(nextline)
                feedkeys('<Esc>i1 + math.sin(math.pi / 6) + 0.5<Esc>:silent w<CR>')
                replace_math()
                EQ('1 + math.sin(math.pi / 6) + 0.5 = 2', vim.fn.getline('.'))
                yank_math()
                EQ('1 + math.sin(math.pi / 6) + 0.5 = 2', vim.fn.getreg('0'))
                EQ('1 + math.sin(math.pi / 6) + 0.5 = 2', vim.fn.getreg('+'))
                EQ('1 + math.sin(math.pi / 6) + 0.5 = 2', msg)
                feedkeys('<Esc>03lv22l')
                replace_math()
                EQ('1 + math.sin(math.pi / 6)  = 0.5 + 0.5 = 2', vim.fn.getline('.'))
                feedkeys('<Esc>03lv22l')
                yank_math()
                EQ('1 + math.sin(math.pi / 6)  = 0.5  = 0.5 + 0.5 = 2', vim.fn.getreg('0'))
                EQ('1 + math.sin(math.pi / 6)  = 0.5  = 0.5 + 0.5 = 2', vim.fn.getreg('+'))
                EQ('1 + math.sin(math.pi / 6)  = 0.5  = 0.5 + 0.5 = 2', msg)

                opts.eval = 'py3eval'
                feedkeys(nextline)
                feedkeys('<Esc>i1 + 2**3 + 3<Esc>:silent w<CR>')
                replace_math()
                EQ('1 + 2**3 + 3 = 12', vim.fn.getline('.'))
                yank_math()
                EQ('1 + 2**3 + 3 = 12', vim.fn.getreg('0'))
                EQ('1 + 2**3 + 3 = 12', vim.fn.getreg('+'))
                EQ('1 + 2**3 + 3 = 12', msg)
                feedkeys('<Esc>03lv5l')
                replace_math()
                EQ('1 + 2**3  = 8 + 3 = 12', vim.fn.getline('.'))
                feedkeys('<Esc>03lv5l')
                yank_math()
                EQ('1 + 2**3  = 8  = 8 + 3 = 12', vim.fn.getreg('0'))
                EQ('1 + 2**3  = 8  = 8 + 3 = 12', vim.fn.getreg('+'))
                EQ('1 + 2**3  = 8  = 8 + 3 = 12', msg)
            end)

            it('. copy', function()
                feedkeys('<Esc>oneovim     <Esc>')
                feedkeys('<Esc>ovim   <Esc>')
                feedkeys('<Esc>oothers <Esc>')
                feedkeys('<Esc>o<Esc>:silent w<CR>')

                feedkeys('<Esc>gg0jyyjV')
                nlib.e.buf_pipe(nil, 'yankcopy_append')
                EQ('neovim     \nvim   \n', vim.fn.getreg('0'))
                EQ('vim   \n', vim.fn.getreg('+'))

                feedkeys('<Esc>gg0jVGk')
                nlib.e.buf_pipe(nil, 'yankcopy', 'trim')
                EQ('neovim\nvim\nothers', vim.fn.getreg('0'))
                EQ('neovim\nvim\nothers', vim.fn.getreg('+'))
            end)

            unmock(mocked, fns)
        end)
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

        -- nlib.u.deepmerge
        it('. deepmerge', function()
            local dst = { foo = { 'bar' } }
            setmetatable(dst, { m1 = { 'aaa' } })
            setmetatable(dst.foo, { m2 = { 'bbb' } })
            local src = { foo = { 'BAR', bar = { 'FOO' }, abc = 'cba' } }
            setmetatable(src, { M1 = { 'AAA' } })
            setmetatable(src.foo, { M2 = { 'BBB' } })

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

    local fns = { { task, 'run' }, { vim, 'notify', 'print' }, { vim.fn, 'input', 'getcharstr' } }
    local mocked = mock(fns)
    local cfg, msg, txt
    task.run = function(_cfg) cfg = _cfg end
    vim.notify = function(_msg) msg = _msg end
    vim.print = function(_txt) txt = _txt end

    local tmp
    before_each(function()
        override_input()
        override_getcharstr()
        tmp = vim.fn.tempname() .. '.lua'
        vim.cmd.edit({ args = { tmp }, mods = { silent = true } })
        vim.cmd.write({ mods = { silent = true } })
    end)

    -- Use `print(vim.inspect())` to debug for `vim.print` has been mocked!
    describe('. code', function()
        local wsc
        before_each(function()
            vim.cmd.CodeReset({ bang = true })
            vim.cmd.CodeWsc({ bang = false }) -- Use `CodeWsc` to get `code.wsc`
            wsc = txt
            -- print(vim.inspect(wsc))
        end)

        it('. :CodeWsc', function()
            EQ('ansi', wsc.style)
            EQ('ansi', wsc.__opts.style)
            EQ(true, getmetatable(wsc) ~= nil)
            EQ(true, getmetatable(getmetatable(wsc)) ~= nil)
        end)

        it('. :CodeReset', function()
            override_input('job')
            override_getcharstr('j', 'j', 'j', 'm', '<CR>')
            vim.cmd.CodeReset({ bang = false })
            EQ('job', wsc.style)

            override_getcharstr('<CR>')
            vim.cmd.CodeReset({ bang = false })
            EQ('job', wsc.style)

            override_getcharstr('<CR>')
            vim.cmd.CodeReset({ bang = true })
            -- `:CodeReset!` will re-create `code.wsc`, so need get new `code.wsc`
            vim.cmd.CodeWsc({ bang = false })
            EQ('ansi', txt.style)
        end)

        it('. :Code! Rp', function()
            override_input('f', tmp, 'term')
            override_getcharstr('m', 'j', 'm', 'k', 'k', 'k', 'k', 'm', '<CR>')
            vim.cmd.Code({ args = { 'Rp' }, bang = true })
            EQ(true, cfg == wsc)
            EQ('f', wsc.key)
            EQ(vim.fn.expand(tmp), vim.fn.expand(wsc.file))
            EQ('lua', wsc.type)
            EQ('term', wsc.tout.style)
            EQ(true, vim.startswith(msg, 'resovle = true, restore = true'))

            vim.cmd.TaskWsc()
            wsc = txt.code
            EQ('f', wsc.key)
            EQ(vim.fn.expand(tmp), vim.fn.expand(wsc.file))
            EQ('lua', wsc.type)
            EQ('term', wsc.style)
            EQ(nil, getmetatable(wsc))
        end)
    end)

    describe('. fzer', function()
        local wsc
        before_each(function()
            vim.cmd.FzerReset({ bang = true })
            vim.cmd.FzerWsc({ bang = false }) -- Use `FzerWsc` to get `fzer.wsc`
            wsc = txt
            -- print(vim.inspect(wsc))
        end)

        it('. :FzerWsc', function()
            EQ('!_VOut', wsc.glob)
            EQ('!_VOut', wsc.__opts.glob)
            EQ(true, getmetatable(wsc) ~= nil)
            EQ(true, getmetatable(getmetatable(wsc)) ~= nil)
        end)

        it('. :FzerReset', function()
            override_input(' *.lua')
            override_getcharstr('j', 'j', 'M', '<CR>')
            vim.cmd.FzerReset({ bang = false })
            EQ('!_VOut *.lua', wsc.glob)

            override_getcharstr('<CR>')
            vim.cmd.FzerReset({ bang = false })
            EQ('!_VOut *.lua', wsc.glob)

            override_getcharstr('<CR>')
            vim.cmd.FzerReset({ bang = true })
            -- `:FzerReset!` will re-create `fzer.wsc`, so need get new `fzer.wsc`
            vim.cmd.FzerWsc({ bang = false })
            EQ('!_VOut', txt.glob)
        end)

        it('. :Fzer fpw', function()
            feedkeys('iword<Esc>')

            EQ('', wsc.path)
            local inp = '/abc/def'
            if (vim.fn.has('win32') == 1) or (vim.fn.has('win64') == 1) then
                inp = 'Z:/abc/def'
            end
            override_input(inp)
            vim.cmd.Fzer({ args = { 'fpw' } })
            EQ(cfg, wsc)
            EQ(inp, wsc.path)
            EQ({ inp }, wsc.paths)
            EQ({ 'word' }, wsc.hltexts)
        end)

        it('. :Fzer Fw', function()
            feedkeys('iword<Esc>')

            override_getcharstr('<CR>')
            vim.cmd.Fzer({ args = { 'Fw' } })
            EQ(true, cfg == wsc)
            EQ(vim.fs.dirname(tmp), wsc.path)

            vim.cmd.TaskWsc()
            wsc = txt.fzer
            EQ({ '!_VOut' }, wsc.globs)
            EQ({ vim.fs.dirname(tmp) }, wsc.paths)
            EQ({ 'word' }, wsc.hltexts)
        end)
    end)

    unmock(mocked, fns)
end)
