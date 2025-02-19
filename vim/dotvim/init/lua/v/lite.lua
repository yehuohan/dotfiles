local nlib = require('v.nlib')
local m = nlib.m

--- Some special commands for fast_cmds
--- @type table<string,string|function>
local special_cmds = {
    t = [[%s/\s\+$//ge]],
    m = [[%s/\r//ge]],
    ['Clear undo'] = function()
        local ulbak = vim.o.undolevels
        vim.o.undolevels = -1
        vim.cmd.normal({
            args = { vim.api.nvim_replace_termcodes('i<Space><Esc>x', true, true, true) },
            bang = true,
        })
        vim.o.undolevels = ulbak
    end,
}

--- Some fast commands to execute conveniently
--- @type PopSelection
local fast_cmds = {
    opt = 'execute fast command',
    lst = {
        'retab!',
        special_cmds.t,
        special_cmds.m,
        'edit ++enc=utf-8',
        'edit ++enc=cp936',
        'Assembly commands',
        'Clear undo',
    },
    dic = {
        ['retab!'] = 'retab with expandtab',
        [special_cmds.t] = 'remove trailing spaces',
        [special_cmds.m] = 'remove ^M',
        ['Assembly commands'] = {
            dsr = '',
            lst = {
                'rustc --emit asm={src}.asm {src}',
                'rustc --emit asm={src}.asm -C "llvm-args=-x86-asm-syntax=intel" {src}',
                'gcc -S -masm=att -fverbose-asm {src}',
                'gcc -S -masm=intel -fverbose-asm {src}',
            },
            cmd = function(_, sel)
                local task = require('v.task')
                task.cmd(nlib.u.replace(sel, { src = vim.api.nvim_buf_get_name(0) }))
            end,
        },
    },
    cmd = function(_, sel)
        if special_cmds[sel] then
            special_cmds[sel]()
        else
            vim.cmd(sel)
        end
    end,
}

--- Edit or create chore files
--- @param under_root(boolean) Edit or create chore file from root
local function new_chores(under_root)
    local dir = nil
    if under_root then
        dir = nlib.try_root()
    end
    if not dir then
        dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    end
    local src_dir = vim.env.DotVimShare .. '/chores'
    local chores = {}
    for res, type in vim.fs.dir(src_dir, { depth = 2 }) do
        if type == 'file' then
            chores[#chores + 1] = res
        end
    end
    vim.ui.select(
        vim.tbl_map(function(c) return dir .. '/' .. c end, chores),
        { prompt = 'Select chores to edit/create' },
        function(choice, idx)
            if choice then
                vim.fn.mkdir(vim.fs.dirname(choice), 'p')
                vim.cmd.edit(choice)
                if vim.fn.filereadable(choice) == 0 then
                    vim.cmd.read({ args = { src_dir .. '/' .. chores[idx] }, range = { 0 } })
                end
            end
        end
    )
end

--- Edit new temporary file
--- @param ft(string) File type
--- @param wt(string|nil) Window type with 'tab' or 'floating'
local function new_tmpfile(ft, wt)
    if not ft then
        return
    end
    wt = wt or ''
    if wt == 'floating' then
        wt = ''
        local buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_open_win(buf, true, {
            relative = 'editor',
            width = math.floor(0.6 * vim.o.columns),
            height = math.floor(0.7 * vim.o.lines),
            col = 3,
            row = 2,
            border = 'single',
        })
    end
    vim.cmd[wt .. 'edit'](vim.fn.tempname() .. '.' .. ft)
end

--- Evaluate string of command, function and expression
--- @param strfn(string) Evaluation function: 'eval' or 'execute'
--- @param copy_result(boolean|nil) Copy evaluation result or not
local function eval_str(strfn, copy_result)
    local str = ''
    if vim.fn.mode() == 'n' then
        local cpl = ({ execute = 'command', eval = 'function' })[strfn]
        str = vim.fn.input(('Eval %s:'):format(strfn), '', cpl)
    else
        str = nlib.get_selected('')
    end

    if str ~= '' then
        local res = vim.fn[strfn](str)
        if type(res) ~= 'string' then
            res = tostring(res)
        end

        if copy_result then
            vim.fn.setreg('0', res)
            vim.fn.setreg('+', res)
            vim.notify(res .. ' → copied')
        else
            vim.fn.append(vim.fn.line('.'), vim.fn.split(res, '\n'))
        end
    end
end

--- Evaluate math expression
--- @param strfn(string) Evaluation function: 'eval' or 'luaeval'
--- @param copy_result(boolean|nil) Copy evaluation result or not
local function eval_math(strfn, copy_result)
    local expr = ''
    local lstr = ''
    local rstr = ''
    if vim.fn.mode() == 'n' then
        expr = vim.fn.getline('.')
        expr = expr:gsub('([^=]+)=[^=]*$', '%1'):gsub('%s*$', '')
        lstr = expr
    else
        expr = nlib.get_selected('')
        local col = vim.fn.getpos("'>")[3]
        local txt = vim.fn.getline('.')
        lstr = txt:sub(1, col)
        rstr = txt:sub(col + 1)
        vim.notify(lstr .. '|' .. rstr)
    end

    if expr ~= '' then
        local res = vim.fn[strfn](expr)
        if type(res) ~= 'string' then
            res = tostring(res)
        end

        if copy_result then
            vim.fn.setreg('0', res)
            vim.fn.setreg('+', res)
            vim.notify(res .. ' -> copied')
        else
            vim.fn.setline(vim.fn.line('.'), ('%s = %s%s'):format(lstr, res, rstr))
        end
    end
end

--- Search from internet
local function net_search(engine, smart)
    local text
    local head = 'https://cn.bing.com/search?q='
    if engine == 'google' then
        head = 'https://google.com/search?q='
    end
    if vim.fn.mode() == 'n' then
        text = vim.fn.expand('<cWORD>')
        if not (smart and text:match('^https?://.*$')) then
            text = head .. vim.fn.expand('<cword>')
        end
    else
        text = nlib.get_selected(' ')
        if not (smart and text:match('^https?://.*$')) then
            text = head .. text
        end
    end
    if text then
        vim.ui.open(text)
    else
        vim.notify('Nothing to search from internet')
    end
end

local function setup()
    m.nnore({
        '<leader>se',
        function() vim.fn['popset#set#PopSelection'](fast_cmds) end,
        desc = 'Fast commands',
    })
    m.nnore({ '<leader>sl', function() new_chores(true) end, desc = 'Edit chores under root path' })
    m.nnore({ '<leader>sL', function() new_chores(false) end, desc = 'Edit chores under current path' })

    m.nnore({
        '<leader>ni',
        function() vim.ui.input({ prompt = 'Filetype:' }, new_tmpfile) end,
        desc = 'New tmpfile',
    })
    m.nnore({ '<leader>nc', function() new_tmpfile('c') end })
    m.nnore({ '<leader>na', function() new_tmpfile('cpp') end })
    m.nnore({ '<leader>nr', function() new_tmpfile('rs') end })
    m.nnore({ '<leader>np', function() new_tmpfile('py') end })
    m.nnore({ '<leader>nm', function() new_tmpfile('md') end })
    m.nnore({ '<leader>nl', function() new_tmpfile('lua') end })
    m.nnore({
        '<leader>nti',
        function()
            vim.ui.input({ prompt = 'Filetype:' }, function(ft) new_tmpfile(ft, 'tab') end)
        end,
        desc = 'New tmpfile in another tab',
    })
    m.nnore({ '<leader>ntc', function() new_tmpfile('c', 'tab') end })
    m.nnore({ '<leader>nta', function() new_tmpfile('cpp', 'tab') end })
    m.nnore({ '<leader>ntr', function() new_tmpfile('rs', 'tab') end })
    m.nnore({ '<leader>ntp', function() new_tmpfile('py', 'tab') end })
    m.nnore({ '<leader>ntm', function() new_tmpfile('md', 'tab') end })
    m.nnore({ '<leader>ntl', function() new_tmpfile('lua', 'tab') end })
    m.nnore({
        '<leader>nfi',
        function()
            vim.ui.input({ prompt = 'Filetype:' }, function(ft) new_tmpfile(ft, 'floating') end)
        end,
        desc = 'Edit tmpfile in floating window',
    })
    m.nnore({ '<leader>nfc', function() new_tmpfile('c', 'floating') end })
    m.nnore({ '<leader>nfa', function() new_tmpfile('cpp', 'floating') end })
    m.nnore({ '<leader>nfr', function() new_tmpfile('rs', 'floating') end })
    m.nnore({ '<leader>nfp', function() new_tmpfile('py', 'floating') end })
    m.nnore({ '<leader>nfl', function() new_tmpfile('lua', 'floating') end })
    m.nnore({ '<leader>nfm', function() new_tmpfile('md', 'floating') end })

    m.nore({ '<leader>af', function() eval_str('eval') end, desc = 'Append eval string' })
    m.nore({ '<leader>agf', function() eval_str('eval', true) end, desc = 'Copy eval string' })
    m.nore({ '<leader>ae', function() eval_str('execute') end, desc = 'Append exec command' })
    m.nore({ '<leader>age', function() eval_str('execute', true) end, desc = 'Copy exec command' })

    m.nore({ '<leader>ev', function() eval_math('eval') end, desc = 'Append vim math' })
    m.nore({ '<leader>egv', function() eval_math('eval', true) end, desc = 'Copy vim math' })
    m.nore({ '<leader>el', function() eval_math('luaeval') end, desc = 'Append lua math' })
    m.nore({ '<leader>egl', function() eval_math('luaeval', true) end, desc = 'Copy lua math' })
    m.nore({ '<leader>ep', function() eval_math('py3eval') end, desc = 'Append python math' })
    m.nore({ '<leader>egp', function() eval_math('py3eval', true) end, desc = 'Copy python math' })

    m.nore({ '<leader>bs', function() net_search(nil, true) end, desc = 'Smart search' })
    m.nore({ '<leader>bb', function() net_search() end, desc = 'Search with bing' })
    m.nore({ '<leader>bg', function() net_search('google') end, desc = 'Search with google' })
end

return { setup = setup }
