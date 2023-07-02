local fn = vim.fn
local api = vim.api
local use = require('v.use')
local m = require('v.libv').m

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
    o.colorcolumn = 80                               -- 设置宽度参考线
    o.hlsearch = true                                -- 设置高亮显示查找到的文本
    o.incsearch = true                               -- 预览当前的搜索内容
    o.termguicolors = true                           -- 在终端中使用24位彩色
    o.expandtab = true                               -- 将Tab用Space代替，方便显示缩进标识indentLine
    o.tabstop = 4                                    -- 设置Tab键宽4个空格
    o.softtabstop = 4                                -- 设置按<Tab>或<BS>移动的空格数
    o.shiftwidth = 4                                 -- 设置>和<命令移动宽度为4
    o.wrap = false                                   -- 默认关闭折行
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
    o.conceallevel = 0                               -- 显示高样样式中的隐藏字符
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
    vim.opt.nrformats = {
        'bin', 'octal', 'hex', 'alpha'
    }                                                -- CTRL-A-X支持数字和字母
    o.mouse = 'a'                                    -- 使能鼠标
    o.imdisable = false                              -- 不禁用输入法
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

local opts = {
    conceallevel = { 2, 0 },
    virtualedit = { 'all', '' },
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
        if fn.exists('g:syntax_on') then
            vim.cmd.syntax({ args = 'off' })
            vim.notify('syntax off')
        else
            vim.cmd.syntax({ args = 'on' })
            vim.notify('syntax on')
        end
    end,
}

local function opt_inv(opt)
    vim.bo[opt] = not vim.bo[opt]
    vim.notify(('%s = %s'):format(opt, vim.bo[opt]))
end

local function opt_lst(opt)
    local values = opts[opt]
    local idx = fn.index(values, vim.bo[opt])
    vim.bo[opt] = values[(idx + 1) % #values]
    vim.notify(('%s = %s'):format(opt, vim.bo[opt]))
end

--------------------------------------------------------------------------------
-- Autocmds
--------------------------------------------------------------------------------
local function on_large_file()
    local fsize = fn.getfsize(fn.expand('<afile>'))
    if fsize >= 5 * 1024 * 1024 or fsize == -2 then
        vim.b.statusline_check_enabled = false
        vim.opt.eventignore:append('FileType')
        vim.bo.undolevels = -1
        vim.bo.swapfile = false
    else
        vim.opt.eventignore:remove('FileType')
    end
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
    vim.o.guicursor = [[n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50]]
        .. [[,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor]]
        .. [[,sm:block-blinkwait175-blinkoff150-blinkon175]]

    -- g:GuiLoaded work after UIEnter
    if fn.exists('g:GuiLoaded') == 1 then
        vim.cmd.GuiLinespace(0)
        vim.cmd.GuiTabline(0)
        vim.cmd.GuiPopupmenu(0)
        m.nore({ '<RightMouse>', vim.fn.GuiShowContextMenu })
        m.inore({ '<RightMouse>', vim.fn.GuiShowContextMenu })
        m.nnore({ '<leader>tf', [[<Cmd>call GuiWindowFullScreen(!g:GuiWindowFullScreen)<CR>]] })
        m.nnore({ '<leader>tm', [[<Cmd>call GuiWindowMaximized(!g:GuiWindowMaximized)<CR>]] })
    end

    if fn.exists('g:neovide') then
        vim.g.neovide_remember_window_size = true
        vim.g.neovide_cursor_antialiasing = false
        vim.g.neovide_cursor_vfx_mode = 'railgun'
        m.nnore({
            '<leader>tf',
            function() vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen end,
        })
    end
end

local function setup()
    set_default_opts()

    vim.o.guioptions = 'M' -- 完全禁用Gui界面元素
    vim.g.did_install_default_menus = 1 -- 禁止加载缺省菜单
    vim.g.did_install_syntax_menu = 1 -- 禁止加载Syntax菜单
    set_fonts(0)
    m.nnore({ '<k0>', function() set_fonts(0) end })
    m.nnore({ '<kPlus>', function() set_fonts(1) end })
    m.nnore({ '<kMinus>', function() set_fonts(-1) end })
    vim.api.nvim_create_augroup('Sets', { clear = true })
    vim.api.nvim_create_autocmd('UIEnter', { group = 'Sets', callback = on_UIEnter })
end

return { setup = setup }
