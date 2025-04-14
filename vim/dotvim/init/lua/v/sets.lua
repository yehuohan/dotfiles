local fn = vim.fn
local api = vim.api
local use = require('v.use')
local nlib = require('v.nlib')
local e = nlib.e
local m = nlib.m

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------
local options = {
    conceallevel = { 3, 0 },
    virtualedit = { { 'block' }, { 'all' }, { 'none' } },
    laststatus = { 2, 3 },
    number = function()
        if vim.o.number and vim.o.relativenumber then
            vim.o.number = false
            vim.o.relativenumber = false
        elseif (not vim.o.number) and not vim.o.relativenumber then
            vim.o.number = true
            vim.o.relativenumber = false
        elseif vim.o.number and not vim.o.relativenumber then
            vim.o.number = true
            vim.o.relativenumber = true
        end
    end,
}

local function opt_inv(opt)
    vim.opt_local[opt] = not vim.opt_local[opt]:get()
    vim.notify(('%s = %s'):format(opt, vim.opt_local[opt]:get()))
end

local function opt_lst(opt)
    local vals = options[opt]
    local idx = fn.index(vals, vim.opt_local[opt]:get())
    idx = (idx + 1) % #vals
    vim.opt_local[opt] = vals[idx + 1]
    vim.notify(('%s = %s'):format(opt, vim.inspect(vals[idx + 1])))
end

local function setup_default_opts()
    -- stylua: ignore start
    local o = vim.o
    o.synmaxcol = 512                               -- 最大高亮列数
    o.number = true                                 -- 显示行号
    o.relativenumber = true                         -- 显示相对行号
    o.numberwidth = 1                               -- 行号最小宽度
    o.signcolumn = 'number'                         -- 共用number的区域用于显示sign
    o.cursorline = true                             -- 高亮当前行
    o.cursorcolumn = true                           -- 高亮当前列
    o.colorcolumn = '80'                            -- 设置宽度参考线
    o.hlsearch = true                               -- 设置高亮显示查找到的文本
    o.incsearch = true                              -- 预览当前的搜索内容
    o.termguicolors = true                          -- 在终端中使用24位彩色
    o.expandtab = true                              -- 将Tab用Space代替，方便显示缩进标识indentLine
    o.tabstop = 4                                   -- 设置Tab键宽4个空格
    o.softtabstop = 4                               -- 设置按<Tab>或<BS>移动的空格数
    o.shiftwidth = 4                                -- 设置>和<命令移动宽度为4
    o.wrap = false                                  -- 默认关闭折行
    o.virtualedit = 'block'                         -- 在Visual Block下使能virtualedit
    o.equalalways = false                           -- 禁止自动调窗口大小
    o.textwidth = 0                                 -- 关闭自动换行
    vim.opt.listchars = {
        tab = use.ui.icon and '󰞔' or '-->',
        eol = use.ui.icon and '󱞥' or '↲',
        space = '·',
        nbsp = '␣',
        precedes = '<',
        extends = '>',
        trail = '~',
    }                                               -- 显示不可见字符
    o.showbreak = use.ui.icon and '󱞩' or '>'        -- wrap标志符
    o.autoindent = true                             -- 使用autoindent缩进
    o.breakindent = false                           -- 折行时不缩进
    o.conceallevel = 3                              -- 显示高样样式中的隐藏字符
    o.concealcursor = 'nvic'                        -- 设置nvic模式下不显示conceal掉的字符
    o.foldenable = true                             -- 充许折叠
    o.foldcolumn = '0'                              -- 0~12,折叠标识列
    o.foldmethod = "expr"                           -- 设置折叠方式
    o.foldlevel = 99                                -- 折叠层数，高于level的会自动折叠
    o.foldlevelstart = -1                           -- 开始编辑另一个buffer时，禁止修改foldlevel
    o.foldexpr = "v:lua.vim.treesitter.foldexpr()"  -- 折叠显示内容
    o.foldtext = ""                                 -- 禁止显示foldtext，而是显示foldexpr
    vim.opt.foldopen:remove('search')               -- 查找时不自动展开折叠
    vim.opt.fillchars = {
        fold = '─',                                 -- 填充折叠尾部
    }                                               -- 设置填充字符
    o.scrolloff = 3                                 -- 光标上下保留的行数
    o.startofline = false                           -- 执行滚屏等命令时，不改变光标列位置
    o.laststatus = 3                                -- 一直显示状态栏
    o.showmode = false                              -- 命令行栏不显示VISUAL等字样
    o.wildmenu = true                               -- 使能命令补全
    o.title = true                                  -- 允许设置titlestring
    o.hidden = true                                 -- 允许在未保存文件时切换buffer
    o.bufhidden = ''                                -- 跟随hidden设置
    o.backup = false                                -- 不生成备份文件
    o.writebackup = false                           -- 覆盖文件前，不生成备份文件
    o.autochdir = true                              -- 自动切换当前目录为当前文件所在的目录
    o.autowrite = false                             -- 禁止自动保存文件
    o.autowriteall = false                          -- 禁止自动保存文件
    vim.opt.completeopt = { 'menuone', 'preview' }  -- 补全显示设置
    vim.opt.backspace = { 'indent', 'eol', 'start' }-- Insert模式下使用BackSpace删除
    vim.opt.nrformats = {
        'bin', 'octal', 'hex', 'alpha'
    }                                               -- CTRL-A-X支持数字和字母
    vim.opt.fileencodings = {
        'ucs-bom', 'utf-8', 'cp936', 'gb18030', 'big5', 'latin1'
    }                                               -- 解码尝试序列
    o.fileformat = 'unix'                           -- 以unix格式保存文本文件，即CR作为换行符
    o.magic = true                                  -- 默认使用magic匹配
    o.ignorecase = true                             -- 不区别大小写搜索
    o.smartcase = true                              -- 有大写字母时才区别大小写搜索
    o.tildeop = false                               -- 使切换大小写的~，类似于c,y,d等操作符
    o.keywordprg = ':help'                          -- K使用的command
    o.mouse = 'a'                                   -- 使能鼠标
    o.spell = false                                 -- 默认关闭拼写检查
    o.spelllang = 'en_us'                           -- 设置拼写语言
    o.visualbell = true                             -- 使用可视响铃代替鸣声
    o.errorbells = false                            -- 关闭错误信息响铃
    o.belloff = 'all'                               -- 关闭所有事件的响铃
    o.timeout = true                                -- 打开映射超时检测
    o.ttimeout = true                               -- 打开键码超时检测
    o.timeoutlen = 1000                             -- 映射超时时间为1000ms
    o.ttimeoutlen = 70                              -- 键码超时时间为70ms
    -- stylua: ignore end
end

--------------------------------------------------------------------------------
-- Autocmds
--------------------------------------------------------------------------------
local function on_large_file()
    local fsize = fn.getfsize(fn.expand('<afile>'))
    if fsize >= 5 * 1024 * 1024 or fsize == -2 then
        require('ufo').detach()
        vim.b.sets_large_file = true
        vim.b.snacks_scope = false
        vim.bo.swapfile = false
        vim.opt.eventignore:append('FileType')
        vim.notify('On large file')
    else
        vim.b.sets_large_file = false
        vim.opt.eventignore:remove('FileType')
    end
end

local function on_alter_enter()
    if vim.b.sets_alter_view and (vim.bo.filetype ~= 'qf') and not vim.wo.diff then
        fn.winrestview(vim.b.sets_alter_view)
        vim.b.sets_alter_view = nil
    end
end

local function on_alter_leave()
    if (vim.bo.filetype ~= 'qf') and not vim.wo.diff then
        vim.b.sets_alter_view = fn.winsaveview()
    end
end

local function on_UIEnter()
    use.set_fonts(0)
    m.nnore({ '<kPlus>', function() use.set_fonts(1) end })
    m.nnore({ '<kMinus>', function() use.set_fonts(-1) end })

    vim.o.guicursor = 'n-v-c-sm:block,i-ci-ve-t:ver25,r-cr-o:hor20'
        .. ',a:blinkwait500-blinkoff500-blinkon250-Cursor/lCursor'

    -- g:GuiLoaded works after UIEnter
    if vim.g.GuiLoaded then
        vim.cmd.GuiLinespace(0)
        vim.cmd.GuiTabline(0)
        vim.cmd.GuiPopupmenu(0)
        m.nvnore({ '<RightMouse>', fn.GuiShowContextMenu })
        m.inore({ '<RightMouse>', fn.GuiShowContextMenu })
        m.nnore({ '<leader>tF', [[<Cmd>call GuiWindowFullScreen(!g:GuiWindowFullScreen)<CR>]] })
        m.nnore({ '<leader>tM', [[<Cmd>call GuiWindowMaximized(!g:GuiWindowMaximized)<CR>]] })
    end

    if vim.g.neovide then
        vim.g.neovide_remember_window_size = true
        vim.g.neovide_cursor_antialiasing = false
        vim.g.neovide_cursor_vfx_mode = 'railgun'
        m.nnore({
            '<leader>tF',
            function() vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen end,
            desc = 'Toggle fullscreen',
        })
    end

    if vim.g.nvy then
        vim.o.guicursor = 'n-v-c-sm:block,i-ci-ve-t:ver25,r-cr-o:hor20'
    end
end

local function setup_default_autocmds()
    -- stylua: ignore start
    api.nvim_create_autocmd('BufNewFile', { group = 'v.Sets', command = 'setlocal fileformat=unix' })
    api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, { group = 'v.Sets', pattern = { '*.nvim' }, command = 'setlocal filetype=vim' })
    api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, { group = 'v.Sets', pattern = { 'nlsp.json', '.nlsp.json', 'tasks.json', 'launch.json' }, command = 'setlocal filetype=jsonc' })
    api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, { group = 'v.Sets', pattern = { '*.log' }, command = 'setlocal filetype=log' })
    api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, { group = 'v.Sets', pattern = { '*.hlsl', '*.usf', '*.ush' }, command = 'setlocal filetype=hlsl' })
    api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, { group = 'v.Sets', pattern = { '*.uproject', '*.uplugin', '*.gltf' }, command = 'setlocal filetype=json' })
    api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, { group = 'v.Sets', pattern = { '*.wgsl' }, command = 'setlocal filetype=wgsl' })
    api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, { group = 'v.Sets', pattern = {
            '*.vert', '*.tesc', '*.tese', '*.glsl', '*.geom', '*.frag', '*.comp',
            '*.rgen', '*.rmiss', '*.rchit', '*.rahit', '*.rint', '*.rcall',
        },
        command = 'setlocal filetype=glsl',
    })
    api.nvim_create_autocmd('Filetype', { group = 'v.Sets', pattern = { 'vim' }, command = 'setlocal foldmethod=marker' })
    api.nvim_create_autocmd('Filetype', { group = 'v.Sets', pattern = { 'text', 'log' }, command = 'setlocal foldmethod=manual' })
    api.nvim_create_autocmd('BufEnter', { group = 'v.Sets', callback = on_alter_enter })
    api.nvim_create_autocmd('BufLeave', { group = 'v.Sets', callback = on_alter_leave })
    api.nvim_create_autocmd('BufReadPre', { group = 'v.Sets', callback = on_large_file })
    -- stylua: ignore end

    api.nvim_create_autocmd('TextYankPost', {
        group = 'v.Sets',
        callback = function() vim.hl.on_yank({ higroup = 'IncSearch', timeout = 200 }) end,
    })

    --vim.o.guioptions = 'M' -- 完全禁用Gui界面元素
    vim.g.did_install_default_menus = 1 -- 禁止加载缺省菜单
    vim.g.did_install_syntax_menu = 1 -- 禁止加载Syntax菜单
    api.nvim_create_autocmd('UIEnter', { group = 'v.Sets', callback = on_UIEnter })
end

--------------------------------------------------------------------------------
-- Misc
--------------------------------------------------------------------------------
--- Some special commands for fast_cmds
--- @type table<string,string|function>
local special_cmds = {
    t = [[%s/\s\+$//ge]],
    m = [[%s/\r//ge]],
    ['Clear undo'] = function()
        local ulbak = vim.o.undolevels
        vim.o.undolevels = -1
        vim.cmd.normal({
            args = { api.nvim_replace_termcodes('i<Space><Esc>x', true, true, true) },
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
                require('v.task').cmd(nlib.u.replace(sel, { src = api.nvim_buf_get_name(0) }))
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

local function setup()
    setup_default_opts()
    m.nnore({ '<leader>iw', function() opt_inv('wrap') end, desc = 'Invert wrap' })
    m.nnore({ '<leader>il', function() opt_inv('list') end, desc = 'Invert list' })
    m.nnore({ '<leader>ii', function() opt_inv('ignorecase') end, desc = 'Invert ignorecase' })
    m.nnore({ '<leader>ie', function() opt_inv('expandtab') end, desc = 'Invert expandtab' })
    m.nnore({ '<leader>ib', function() opt_inv('scrollbind') end, desc = 'Invert scrollbind' })
    m.nnore({ '<leader>ip', function() opt_inv('spell') end, desc = 'Invert spell' })
    m.nnore({ '<leader>ic', function() opt_lst('conceallevel') end, desc = 'Invert conceallevel' })
    m.nnore({ '<leader>iv', function() opt_lst('virtualedit') end, desc = 'Invert virtualedit' })
    m.nnore({ '<leader>is', function() opt_lst('laststatus') end, desc = 'Invert laststatus' })
    m.nnore({ '<leader>in', options.number, desc = 'Invert number' })

    api.nvim_create_augroup('v.Sets', { clear = true })
    setup_default_autocmds()

    -- Fast commands
    m.nnore({ '<leader>se', function() fn.PopSelection(fast_cmds) end, desc = 'Fast commands' })

    -- New chore file
    local path = vim.env.DotVimShare .. '/chores'
    m.nnore({ '<leader>sl', function() e.buf_etpl(path, true) end, desc = 'New chore file under root' })
    m.nnore({ '<leader>sL', function() e.buf_etpl(path, false) end, desc = 'New chore file' })

    -- New tmpfile
    local prompt = { prompt = 'Filetype:' }
    m.nnore({ '<leader>ni', function() vim.ui.input(prompt, e.buf_etmp) end, desc = 'Edit tmpfile' })
    m.nnore({
        '<leader>nti',
        function()
            vim.ui.input(prompt, function(ft) e.buf_etmp(ft, 'tab') end)
        end,
        desc = 'Edit tmpfile in tab',
    })
    m.nnore({
        '<leader>nfi',
        function()
            vim.ui.input(prompt, function(ft) e.buf_etmp(ft, 'floating') end)
        end,
        desc = 'Edit tmpfile in floating',
    })
    local fts = { c = 'c', a = 'cpp', r = 'rs', p = 'py', l = 'lua', m = 'md' }
    local wts = { t = 'tab', f = 'floating' }
    for fk, fv in pairs(fts) do
        m.nnore({ '<leader>n' .. fk, function() e.buf_etmp(fv) end })
        for wk, wv in pairs(wts) do
            m.nnore({ '<leader>n' .. wk .. fk, function() e.buf_etmp(fv, wv) end })
        end
    end

    -- Execute and evaluate
    local eopts = { prompt = 'Command:', completion = 'command' }
    local fopts = { prompt = 'Expression:', completion = 'expression' }
    local append_exec = function() e.buf_pipe('input', 'append', 'exec', eopts) end
    local append_eval = function() e.buf_pipe('input', 'append', 'eval', fopts) end
    local yankcopy_exec = function() e.buf_pipe('input', 'yankcopy', 'exec', eopts) end
    local yankcopy_eval = function() e.buf_pipe('input', 'yankcopy', 'eval', fopts) end
    m.nxnore({ '<leader>ec', append_exec, desc = 'Append command result' })
    m.nxnore({ '<leader>ef', append_eval, desc = 'Append expression result' })
    m.nxnore({ '<leader>yc', yankcopy_exec, desc = 'Yank and copy command result' })
    m.nxnore({ '<leader>yf', yankcopy_eval, desc = 'Yank and copy expression result' })

    -- Evaluate math
    local vmath = function() e.buf_pipe('line', 'replace', 'eval_math', { eval = 'eval' }) end
    local lmath = function() e.buf_pipe('line', 'replace', 'eval_math', { eval = 'luaeval' }) end
    local pmath = function() e.buf_pipe('line', 'replace', 'eval_math', { eval = 'py3eval' }) end
    m.nxnore({ '<leader>ev', vmath, desc = 'Append vim math' })
    m.nxnore({ '<leader>el', lmath, desc = 'Append lua math' })
    m.nxnore({ '<leader>ep', pmath, desc = 'Append python math' })
    vmath = function() e.buf_pipe('line', 'yankcopy', 'eval_math', { eval = 'eval' }) end
    lmath = function() e.buf_pipe('line', 'yankcopy', 'eval_math', { eval = 'luaeval' }) end
    pmath = function() e.buf_pipe('line', 'yankcopy', 'eval_math', { eval = 'py3eval' }) end
    m.nxnore({ '<leader>yv', vmath, desc = 'Yank and copy vim math' })
    m.nxnore({ '<leader>yl', lmath, desc = 'Yank and copy lua math' })
    m.nxnore({ '<leader>yp', pmath, desc = 'Yank and copy python math' })

    -- Search with internet
    local bing = function(txt) return 'https://cn.bing.com/search?q=' .. txt end
    local google = function(txt) return 'https://google.com/search?q=' .. txt end
    local github = function(txt) return 'https://github.com/search?q=' .. txt end
    local smart = function(txt, opts)
        local si, ei, res = txt:find([[(h?[tf]tps?://[^ ()%[%]{}<>]+)]])
        if res then
            if opts.mode == 'n' then
                local col = fn.getpos('.')[3]
                if si <= col and col <= ei then
                    return res
                end
            else
                return res
            end
        end
        res = opts.mode == 'n' and fn.expand('<cword>') or txt
        return bing(res)
    end
    m.nxnore({ '<leader>bs', function() e.buf_pipe('line', 'open', smart) end, desc = 'Smart search' })
    m.nxnore({ '<leader>bb', function() e.buf_pipe('word', 'open', bing) end, desc = 'Search by bing' })
    m.nxnore({ '<leader>bg', function() e.buf_pipe('word', 'open', google) end, desc = 'Search by google' })
    m.nxnore({ '<leader>bh', function() e.buf_pipe('word', 'open', github) end, desc = 'Search by github' })

    -- Extra mappings
    vim.cmd.source(vim.env.DotVimInit .. '/lua/v/maps.vim')
end

return { setup = setup }
