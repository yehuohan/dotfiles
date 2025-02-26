local fn = vim.fn
local api = vim.api
local use = require('v.use')
local nlib = require('v.nlib')
local m = nlib.m

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------
local function set_default_opts()
    -- stylua: ignore start
    local o = vim.o
    o.synmaxcol = 512                                -- 最大高亮列数
    o.number = true                                  -- 显示行号
    o.relativenumber = true                          -- 显示相对行号
    o.numberwidth = 1                                -- 行号最小宽度
    o.signcolumn = 'number'                          -- 共用number的区域用于显示sign
    o.cursorline = true                              -- 高亮当前行
    o.cursorcolumn = true                            -- 高亮当前列
    o.colorcolumn = '80'                             -- 设置宽度参考线
    o.hlsearch = true                                -- 设置高亮显示查找到的文本
    o.incsearch = true                               -- 预览当前的搜索内容
    o.termguicolors = true                           -- 在终端中使用24位彩色
    o.expandtab = true                               -- 将Tab用Space代替，方便显示缩进标识indentLine
    o.tabstop = 4                                    -- 设置Tab键宽4个空格
    o.softtabstop = 4                                -- 设置按<Tab>或<BS>移动的空格数
    o.shiftwidth = 4                                 -- 设置>和<命令移动宽度为4
    o.wrap = false                                   -- 默认关闭折行
    o.virtualedit = 'block'                          -- 在Visual Block下使能virtualedit
    o.equalalways = false                            -- 禁止自动调窗口大小
    o.textwidth = 0                                  -- 关闭自动换行
    vim.opt.listchars = {
        tab = '⤜⤚→',
        eol = '↲',
        space = '·',
        nbsp = '␣',
        precedes = '<',
        extends = '>',
        trail = '~',
    }                                                -- 不可见字符显示
    o.showbreak = '↪ '                               -- wrap标志符
    o.autoindent = true                              -- 使用autoindent缩进
    o.breakindent = false                            -- 折行时不缩进
    o.conceallevel = 2                               -- 显示高样样式中的隐藏字符
    o.concealcursor = 'nvic'                         -- 设置nvic模式下不显示conceal掉的字符
    o.foldenable = true                              -- 充许折叠
    vim.opt.foldopen:remove('search')                -- 查找时不自动展开折叠
    o.foldcolumn = '0'                               -- 0~12,折叠标识列，分别用“-”和“+”而表示打开和关闭的折叠
    o.foldmethod = 'indent'                          -- 设置折叠，默认为缩进折叠
    o.foldlevel = 99                                 -- 折叠层数，高于level的会自动折叠
    o.foldlevelstart = 99                            -- 编辑另一个buffer时设置的foldlevel值
    o.scrolloff = 3                                  -- 光标上下保留的行数
    o.startofline = false                            -- 执行滚屏等命令时，不改变光标列位置
    o.laststatus = 3                                 -- 一直显示状态栏
    o.showmode = false                               -- 命令行栏不显示VISUAL等字样
    vim.opt.completeopt = { 'menuone', 'preview' }   -- 补全显示设置
    o.wildmenu = true                                -- 使能命令补全
    vim.opt.backspace = { 'indent', 'eol', 'start' } -- Insert模式下使用BackSpace删除
    o.title = true                                   -- 允许设置titlestring
    o.hidden = true                                  -- 允许在未保存文件时切换buffer
    o.bufhidden = ''                                 -- 跟随hidden设置
    o.backup = false                                 -- 不生成备份文件
    o.writebackup = false                            -- 覆盖文件前，不生成备份文件
    o.autochdir = true                               -- 自动切换当前目录为当前文件所在的目录
    o.autowrite = false                              -- 禁止自动保存文件
    o.autowriteall = false                           -- 禁止自动保存文件
    vim.opt.fileencodings = {
        'ucs-bom', 'utf-8', 'cp936', 'gb18030', 'big5', 'latin1'
    }                                                -- 解码尝试序列
    o.fileformat = 'unix'                            -- 以unix格式保存文本文件，即CR作为换行符
    o.magic = true                                   -- 默认使用magic匹配
    o.ignorecase = true                              -- 不区别大小写搜索
    o.smartcase = true                               -- 有大写字母时才区别大小写搜索
    o.tildeop = false                                -- 使切换大小写的~，类似于c,y,d等操作符
    o.keywordprg = ':help'                           -- K使用的command
    vim.opt.nrformats = {
        'bin', 'octal', 'hex', 'alpha'
    }                                                -- CTRL-A-X支持数字和字母
    o.mouse = 'a'                                    -- 使能鼠标
    o.spell = false                                  -- 默认关闭拼写检查
    o.spelllang = 'en_us'                            -- 设置拼写语言
    o.visualbell = true                              -- 使用可视响铃代替鸣声
    o.errorbells = false                             -- 关闭错误信息响铃
    o.belloff = 'all'                                -- 关闭所有事件的响铃
    o.timeout = true                                 -- 打开映射超时检测
    o.ttimeout = true                                -- 打开键码超时检测
    o.timeoutlen = 1000                              -- 映射超时时间为1000ms
    o.ttimeoutlen = 70                               -- 键码超时时间为70ms
    -- stylua: ignore end
end

local options = {
    conceallevel = { 2, 0 },
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
    syntax = function()
        if fn.exists('g:syntax_on') == 1 then
            vim.cmd.syntax({ args = { 'off' } })
            vim.notify('syntax off')
        else
            vim.cmd.syntax({ args = { 'on' } })
            vim.notify('syntax on')
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

--------------------------------------------------------------------------------
-- Autocmds
--------------------------------------------------------------------------------
local function on_large_file()
    local fsize = fn.getfsize(fn.expand('<afile>'))
    if fsize >= 5 * 1024 * 1024 or fsize == -2 then
        require('ufo').detach()
        vim.b.sets_large_file = true
        vim.bo.filetype = '_' .. vim.bo.filetype -- Stop treesitter with a wrong filetype
        vim.bo.undolevels = -1
        vim.bo.swapfile = false
        vim.opt.eventignore:append('FileType')
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

local function set_default_autocmds()
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
    api.nvim_create_autocmd('Filetype', { group = 'v.Sets', pattern = { 'vim', 'tex' }, command = 'setlocal foldmethod=marker' })
    api.nvim_create_autocmd('Filetype', { group = 'v.Sets', pattern = { 'c', 'cpp', 'rust', 'glsl', 'hlsl' }, command = 'setlocal foldmethod=syntax' })
    api.nvim_create_autocmd('Filetype', { group = 'v.Sets', pattern = { 'python' }, command = 'setlocal foldmethod=indent foldignore=' })
    api.nvim_create_autocmd('Filetype', { group = 'v.Sets', pattern = { 'txt', 'log' }, command = 'setlocal foldmethod=manual' })
    api.nvim_create_autocmd('TextYankPost', {
        group = 'v.Sets',
        callback = function() vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 }) end,
    })
    api.nvim_create_autocmd('BufReadPre', { group = 'v.Sets', callback = on_large_file })
    api.nvim_create_autocmd('BufEnter', { group = 'v.Sets', callback = on_alter_enter })
    api.nvim_create_autocmd('BufLeave', { group = 'v.Sets', callback = on_alter_leave })
    -- stylua: ignore end
end

--------------------------------------------------------------------------------
-- Gui
--------------------------------------------------------------------------------
local function set_fonts(inc)
    use.ui.fontsize = use.ui.fontsize + inc
    use.ui.widesize = use.ui.widesize + inc
    vim.o.guifont = use.ui.font .. ':h' .. tostring(use.ui.fontsize)
    vim.o.guifontwide = use.ui.wide .. ':h' .. tostring(use.ui.widesize)
end

local function on_UIEnter()
    set_fonts(0)
    m.nnore({ '<k0>', function() set_fonts(0) end })
    m.nnore({ '<kPlus>', function() set_fonts(1) end })
    m.nnore({ '<kMinus>', function() set_fonts(-1) end })

    vim.o.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr-o:hor20'
        .. ',a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor'
        .. ',sm:block-blinkwait175-blinkoff150-blinkon175'

    -- g:GuiLoaded works after UIEnter
    if vim.g.GuiLoaded then
        vim.cmd.GuiLinespace(0)
        vim.cmd.GuiTabline(0)
        vim.cmd.GuiPopupmenu(0)
        m.nore({ '<RightMouse>', fn.GuiShowContextMenu })
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
        vim.o.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20'
        vim.o.guifont = use.ui.fontback .. ':h' .. tostring(use.ui.fontsize)
    end
end

--------------------------------------------------------------------------------
-- Extended
--------------------------------------------------------------------------------
local M = {}

--- Goto floating window
function M.extwin_goto_floating()
    local wins = {}
    for _, wid in ipairs(api.nvim_tabpage_list_wins(0)) do
        if fn.win_gettype(wid) == 'popup' then
            wins[#wins + 1] = wid
        end
    end
    if #wins > 0 then
        local idx = fn.index(wins, api.nvim_get_current_win())
        if idx == -1 or (idx + 1 == #wins) then
            idx = 0
        else
            idx = idx + 1
        end
        vim.api.nvim_set_current_win(wins[idx + 1])
    end
end

--- Resize window by moving spliter
--- @param dir boolean Move bottom(true) or right(false) spliter
--- @param inc integer The size to move
function M.extwin_move_spliter(dir, inc)
    local pos = api.nvim_win_get_position(0)
    local offset = inc * vim.v.count1
    if dir then
        local cur = pos[1] + 1 + api.nvim_win_get_height(0) + vim.o.cmdheight
        local max = vim.o.lines
        if cur >= max then
            if pos[1] >= 2 then
                vim.cmd.resize({ args = { ('%+d'):format(-offset) } })
            end
        else
            fn.win_move_statusline(fn.winnr(), offset)
        end
    else
        local cur = pos[2] + api.nvim_win_get_width(0)
        local max = vim.o.columns
        if cur >= max then
            vim.cmd.resize({ args = { ('%+d'):format(-offset) }, mods = { vertical = true } })
        else
            fn.win_move_separator(fn.winnr(), offset)
        end
    end
end

function M.setup()
    set_default_opts()
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
    m.nnore({ '<leader>ih', options.syntax, desc = 'Invert syntax' })

    api.nvim_create_augroup('v.Sets', { clear = true })
    set_default_autocmds()

    --vim.o.guioptions = 'M' -- 完全禁用Gui界面元素
    vim.g.did_install_default_menus = 1 -- 禁止加载缺省菜单
    vim.g.did_install_syntax_menu = 1 -- 禁止加载Syntax菜单
    api.nvim_create_autocmd('UIEnter', { group = 'v.Sets', callback = on_UIEnter })

    vim.cmd.source(vim.env.DotVimInit .. '/lua/v/maps.vim')
end

return M
