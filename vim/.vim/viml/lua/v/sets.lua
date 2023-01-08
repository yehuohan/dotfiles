local M = {}
local api = vim.api
local fn = vim.fn
local o = vim.o
local opt = vim.opt
local use = require('v.use').get()
local m = require('v.maps')


--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------
local function opts_default()
    o.synmaxcol = 512                       -- 最大高亮列数
    o.number = true                         -- 显示行号
    o.relativenumber = true                 -- 显示相对行号
    o.cursorline = true                     -- 高亮当前行
    o.cursorcolumn = true                   -- 高亮当前列
    o.hlsearch = true                       -- 设置高亮显示查找到的文本
    o.incsearch = true                      -- 预览当前的搜索内容
    o.termguicolors = true                  -- 在终端中使用24位彩色
    o.expandtab = true                      -- 将Tab用Space代替，方便显示缩进标识indentLine
    o.tabstop = 4                           -- 设置Tab键宽4个空格
    o.softtabstop = 4                       -- 设置按<Tab>或<BS>移动的空格数
    o.shiftwidth = 4                        -- 设置>和<命令移动宽度为4
    o.wrap = false                          -- 默认关闭折行
    o.textwidth = 0                         -- 关闭自动换行
    opt.listchars = {
        tab = '⤜⤚→',
        eol = '↲',
        space = '·',
        nbsp = '␣',
        precedes = '<',
        extends = '>',
        trail = '~',
    }                                       -- 不可见字符显示

    o.autoindent = true                     -- 使用autoindent缩进
    o.breakindent = false                   -- 折行时不缩进
    o.conceallevel = 0                      -- 显示高样样式中的隐藏字符
    o.foldenable = true                     -- 充许折叠
    opt.foldopen:remove('search')           -- 查找时不自动展开折叠
    o.foldcolumn = '0'                      -- 0~12,折叠标识列，分别用“-”和“+”而表示打开和关闭的折叠
    o.foldmethod = 'indent'                 -- 设置折叠，默认为缩进折叠
    o.scrolloff = 3                         -- 光标上下保留的行数
    o.startofline = false                   -- 执行滚屏等命令时，不改变光标列位置
    o.laststatus = 2                        -- 一直显示状态栏
    o.showmode = false                      -- 命令行栏不显示VISUAL等字样
    opt.completeopt = {
        'menuone', 'preview'
    }                                       -- 补全显示设置
    o.wildmenu = true                       -- 使能命令补全
    opt.backspace = {
        'indent', 'eol', 'start'
    }                                       -- Insert模式下使用BackSpace删除
    o.title = true                          -- 允许设置titlestring
    o.hidden = true                         -- 允许在未保存文件时切换buffer
    o.bufhidden = ''                        -- 跟随hidden设置
    o.backup = false                        -- 不生成备份文件
    o.writebackup = false                   -- 覆盖文件前，不生成备份文件
    o.autochdir = true                      -- 自动切换当前目录为当前文件所在的目录
    o.autowrite = false                     -- 禁止自动保存文件
    o.autowriteall = false                  -- 禁止自动保存文件
    opt.fileencodings = {
        'ucs-bom', 'utf-8', 'cp936', 'gb18030', 'big5', 'euc-jp', 'euc-kr', 'latin1'
    }                                       -- 解码尝试序列
    o.fileformat = 'unix'                   -- 以unix格式保存文本文件，即CR作为换行符
    o.magic = true                          -- 默认使用magic匹配
    o.ignorecase = true                     -- 不区别大小写搜索
    o.smartcase = true                      -- 有大写字母时才区别大小写搜索
    o.tildeop = false                       -- 使切换大小写的~，类似于c,y,d等操作符
    opt.nrformats = {
        'bin', 'octal', 'hex', 'alpha'
    }                                       -- CTRL-A-X支持数字和字母
    o.mouse = 'a'                           -- 使能鼠标
    --o.imdisable = false                     -- 不禁用输入法
    o.visualbell = true                     -- 使用可视响铃代替鸣声
    o.errorbells = false                    -- 关闭错误信息响铃
    o.belloff = 'all'                       -- 关闭所有事件的响铃
    opt.helplang = {'en', 'cn'}             -- help-doc顺序
    o.timeout = true                        -- 打开映射超时检测
    o.ttimeout = true                       -- 打开键码超时检测
    o.timeoutlen = 1000                     -- 映射超时时间为1000ms
    o.ttimeoutlen = 70                      -- 键码超时时间为70ms
end

--------------------------------------------------------------------------------
-- Autocmds
--------------------------------------------------------------------------------
function M.onLargeFile()
    local fsize = fn.getfsize(fn.expand('<afile>'))
    if fsize >= 5 * 1024 * 1024 or fsize == -2 then
        vim.b.statusline_check_enabled = false
        opt.eventignore:append('FileType')
        vim.bo.undolevels = -1
        vim.bo.swapfile = true
    else
        opt.eventignore:remove('FileType')
    end
end

--------------------------------------------------------------------------------
-- Gui
--------------------------------------------------------------------------------
function M.setfonts(inc)
    use.ui.fontsize = use.ui.fontsize + inc
    use.ui.widesize = use.ui.widesize + inc
    vim.o.guifont = use.ui.font .. ':h' .. tostring(use.ui.fontsize)
    vim.o.guifontwide = use.ui.wide .. ':h' .. tostring(use.ui.widesize)
end

function M.onUIEnter()
    -- 在UIEnter之后才起作用
    if fn.exists('g:GuiLoaded') == 1 then
        vim.o.guicursor =
            [[n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50]] ..
            [[,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor]] ..
            [[,sm:block-blinkwait175-blinkoff150-blinkon175]]
        M.setfonts(0)
        vim.cmd[[
            GuiLinespace 0
            GuiTabline 0
            GuiPopupmenu 0
        ]]
        m.nore{'<RightMouse>' , [[<Cmd>call GuiShowContextMenu()<CR>]]                       }
        m.inore{'<RightMouse>', [[<Cmd>call GuiShowContextMenu()<CR>]]                       }
        m.nnore{'<leader>tf'  , [[<Cmd>call GuiWindowFullScreen(!g:GuiWindowFullScreen)<CR>]]}
        m.nnore{'<leader>tm'  , [[<Cmd>call GuiWindowMaximized(!g:GuiWindowMaximized)<CR>]]  }
    end

    m.nnore{'<k0>'    , [[:lua require('v.sets').setfonts(0)<CR>]] }
    m.nnore{'<kPlus>' , [[:lua require('v.sets').setfonts(1)<CR>]] }
    m.nnore{'<kMinus>', [[:lua require('v.sets').setfonts(-1)<CR>]]}
end

--------------------------------------------------------------------------------
-- Mappings
--------------------------------------------------------------------------------
-- 跳转到下一个floating窗口
function M.WinGotoNextFloating()
    for _, wid in ipairs(api.nvim_list_wins()) do
        if wid ~= api.nvim_get_current_win() then
            local cfg = api.nvim_win_get_config(wid)
            if fn.get(cfg, 'relative', '') ~= '' and fn.get(cfg, 'focusable', true) == true then
                fn.win_gotoid(wid)
            end
        end
    end
end

-- 移动窗口的分界，改变窗口大小
-- 只有最bottom-right的窗口是移动其top-left的分界，其余窗口移动其bottom-right分界
function M.WinMoveSpliter(dir, inc)
    local wnr = fn.winnr()
    local pos = fn.win_screenpos(wnr)
    local hei = fn.winheight(wnr) + pos[1] + o.cmdheight
    local wid = fn.winwidth(wnr) - 1 + pos[2]
    local all_hei = o.lines
    local all_wid = o.columns

    inc = inc * vim.v.count1
    local cmd
    local sig
    if dir == 'e' then
        if (hei >= all_hei and pos[1] >= 3)
        then sig = '+'
        else sig = '-'
        end
        cmd = string.format('resize%s%d', sig, inc)
    elseif dir == 'd' then
        if (hei >= all_hei and pos[1] >= 3)
        then sig = '-'
        else sig = '+'
        end
        cmd = string.format('resize%s%d', sig, inc)
    elseif dir == 's' then
        if (wid >= all_wid)
        then sig = '+'
        else sig = '-'
        end
        cmd = string.format('vertical resize%s%d', sig, inc)
    elseif dir == 'f' then
        if (wid >= all_wid)
        then sig = '-'
        else sig = '+'
        end
        cmd = string.format('vertical resize%s%d', sig, inc)
    end
    api.nvim_command(cmd)
end


function M.setup()
    opts_default()
    vim.cmd[[
    augroup SetupGui
        autocmd!
        autocmd UIEnter * :lua require('v.sets').onUIEnter()
    augroup END
    ]]
end

return M
