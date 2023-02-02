local use = vim.fn.SvarUse()
local m = require('v.maps')
local heirline = require('heirline')
local conds = require('heirline.conditions')
local utils = require('heirline.utils')


-- Symbols
local sym = {
    sep = { '(', ')' },
    row = '',
    col = '$',
    vos = '',
    buf = 'B',
    tab = 'T',
}
if use.ui.patch then
    sym.sep = { '', '' }
    sym.row = ''
    sym.col = ''
    sym.buf = ''
    sym.tab = ''
    if vim.fn.IsLinux() == 1 then
        sym.vos = ''
    elseif vim.fn.IsMac() == 1 then
        sym.vos = ''
    else
        sym.vos = ''
    end
end

-- Contexts
local ctxs = {}

ctxs.attr = '%{&ft!=#""?&ft."│":""}%{&fenc!=#""?&fenc:&enc}│%{&ff}'
ctxs.lite = sym.row .. '%l/%L ' .. sym.col .. '%v %{winnr()}.%n%{&mod?"+":""}'
ctxs.info = 'U%-2B %p%% ' .. ctxs.lite

function ctxs.mode()
    local mch = vim.fn.mode()
    if mch == '\22' or mch == '\22s' then
        mch = '^V'
    elseif mch == '\19' then
        mch = '^S'
    end
    return mch:upper()
end

function ctxs.hint()
    local res = ctxs.mode()
    local ft = vim.bo.filetype
    if ft == 'Popc' then
        res = 'Popc'
    elseif ft == 'alpha' then
        res = 'Alpha'
    elseif ft == 'qf' then
        local wi = vim.fn.getwininfo(vim.fn.win_getid())[1]
        res = wi.loclist == 0 and 'QF' or 'QL'
    elseif ft == 'help' then
        res = 'Help'
    end
    return sym.vos .. ' ' .. res
end

function ctxs.root_path()
    return vim.fn.Expand(vim.fn.SvarWs().fw.path)
end

function ctxs.relative_path()
    local filepath = vim.fn.Expand('%', ':p')
    local rootpath = vim.fn.Expand(vim.fn.SvarWs().fw.path)
    local pat = '^' .. vim.fn.escape(rootpath, '\\')
    return vim.fn.substitute(filepath, pat, '', '')
end

function ctxs.check_lines()
    if vim.b.statusline_check_enabled == false then
        return ''
    end
    local res = ''
    local pos
    -- mixed indent
    pos = vim.fn.search([[\m\(\t \| \t\)]], 'nw')
    if pos ~= 0 then
        res = 'M:' .. tostring(pos)
    end
    -- trailing whitespaces
    pos = vim.fn.search([[\m\s\+$]], 'nw')
    if pos ~= 0 then
        if res ~= '' then
            res = res .. '│'
        end
        res = res .. 'T:' .. tostring(pos)
    end
    return res
end

function ctxs.tabs_bufs(layout)
    local buflst = layout.buf and vim.fn['popc#layer#buf#GetBufs'](vim.fn.tabpagenr()) or {}
    local tablst = layout.tab and vim.fn['popc#layer#buf#GetTabs']() or {}
    local buftab = vim.fn['popc#stl#ShortenTabsBufs'](buflst, tablst, 2)
    local res = {}
    if layout.buf then
        res.buf = buftab[1]
        res.buf_click = 'popc#stl#SwitchBuffer'
    end
    if layout.tab then
        res.tab = buftab[2]
        res.tab_click = 'popc#stl#SwitchTab'
    end
    return res
end

-- Colors
local function load_colors()
    return {
        blank  = utils.get_highlight('Normal').bg,
        red    = '#fa461e',
        green  = '#b8bb26',
        blue   = '#83a598',
        gray   = '#665c54',
        -- gruvbox dark
        areaA = '#ff8019',
        areaB = '#beaa82',
        areaC = '#504b4b',
        textA = '#dc6919',
        textB = '#ebdcb4',
        textC = '#b4aa96',
    }
end

-- Components
local function pad(color, component, fileds)
    local res = utils.surround(sym.sep, color, component)
    if fileds then
        res = utils.clone(res, fileds)
    end
    return res
end

local function wrap(component)
    return utils.surround({'', ''}, 'blank', component)
end

-- Statuslines
local ComAlign = { provider = '%=' }
local ComTrunc = {
    provider = '%=%<',
    hl = { fg = 'gray', strikethrough = true },
}
local ComHint = pad(
    function()
        local mch = ctxs.mode()
        if mch == 'V' or mch == 'S' or mch == '^V' or mch == '^S' then
            return 'red'
        elseif mch == 'I' or mch == 'T' then
            return 'green'
        elseif mch == 'R' then
            return 'blue'
        end
        return 'areaB'
    end,
    {
        provider = ctxs.hint,
        hl = { fg = 'blank', bold = true },
    }, {
        condition = conds.is_active,
    }
)
local ComPath = pad('areaC', {
    {
        provider = ctxs.root_path,
        hl = { fg = 'textA', bold = true },
    }, {
        provider = ctxs.relative_path,
        hl = { fg = 'textB' },
    },
})
local ComFile = pad('areaC', {
    provider = '%F',
    hl = function()
        return { fg = conds.is_active() and 'textB' or 'textC'}
    end,
})
local ComType = pad('areaC', {
    provider = '%y',
    hl = function()
        return { fg = conds.is_active() and 'textB' or 'textC'}
    end,
})
local ComAttr = pad('areaC', {
    provider = ctxs.attr,
    hl = { fg = 'textB' }
})
local ComInfo = pad('areaB', {
    provider = ctxs.info,
    hl = { fg = 'blank' },
})
local ComLite = pad('areaC', {
    provider = ctxs.lite,
    hl = { fg = 'textC' },
})
local ComCheck = pad('areaA',
    {
        provider = function(self)
            return self:nonlocal('check')
        end,
        hl = { fg = 'blank', italic = true },
    }, {
        condition = function(self)
            self.check = ctxs.check_lines()
            return self.check ~= ''
        end,
    }
)

local SecLeft = {
    fallthrough = false,
    {
        condition = function()
            return conds.buffer_matches({
                filetype = { 'vim%-plug', 'vista', 'NvimTree', 'nerdtree' }
            })
        end,
        ComType,
    }, {
        condition = function()
            return conds.is_not_active() or conds.buffer_matches({
                buftype = { 'help', 'terminal' }
            })
        end,
        ComFile,
    },
    ComPath,
}
local SecRight = {
    fallthrough = false,
    {
        condition = conds.is_active,
        ComCheck, ComAttr, ComInfo,
    },
    ComLite,
}

local stls = wrap({ ComHint, SecLeft, ComTrunc, SecRight })

-- Tablines
local ComBuf = utils.surround({'', sym.sep[2]}, 'areaA', {
    provider = sym.buf,
    hl = { fg = 'blank' },
})
local ComTab = utils.surround({sym.sep[1], ''}, 'areaA', {
    provider = sym.tab,
    hl = { fg = 'blank' }
})

local function ele(e, fn)
    local fg = 'textB'
    local bg = 'areaC'
    local txt = e.title
    if e.modified == 0 and e.selected == 1 then
        fg = 'blank'
        bg = 'blue'
    elseif e.modified == 1 and e.selected == 1 then
        txt = txt .. '+'
        fg = 'blank'
        bg = 'green'
    elseif e.modified == 1 and e.selected == 0 then
        txt = txt .. '+'
        fg = 'green'
    end
    return pad(bg,
        {
            provider = txt,
            hl = { fg = fg },
        }, {
            on_click = {
                callback = fn,
                minwid = e.index,
            }
        }
    )
end

local tabs = wrap({
    init = function(self)
        local res = ctxs.tabs_bufs(vim.g.tabline_layout)
        local children = {}
        -- buffers
        if res.buf then
            table.insert(children, ComBuf)
            for _, e in ipairs(res.buf) do
                table.insert(children, ele(e, res.buf_click))
            end
        end
        table.insert(children, ComAlign)
        -- tabpages
        if res.tab then
            for _, e in ipairs(res.tab) do
                table.insert(children, ele(e, res.tab_click))
            end
            table.insert(children, ComTab)
        end
        -- instantiate new child with overwriting the previous one
        self.child = self:new(children, 1)
    end,
    provider = function(self)
        return self.child:eval()
    end,
})

-- Winbars
local bars = wrap({
    fallthrough = false,
    {
        condition = function()
            return vim.o.laststatus ~= 3 or conds.buffer_matches({
                filetype = { 'alpha', 'vim%-plug', 'vista', 'NvimTree', 'nerdtree' },
                buftype = { 'terminal',  'quickfix' },
            })
        end,
        init = function()
            vim.opt_local.winbar = nil
        end
    },
    ComFile,
})

-- Setup
local function toggle_check()
    if vim.b.statusline_check_enabled == nil then
        vim.b.statusline_check_enabled = true
    end
    vim.b.statusline_check_enabled = not vim.b.statusline_check_enabled
    vim.fn.Notify('b:statusline_check_enabled = ' .. tostring(vim.b.statusline_check_enabled))
end

local function toggle_layout()
    local layout = vim.g.tabline_layout
    if layout.tab and layout.buf then
        layout.tab = false
    elseif not layout.tab and layout.buf then
        layout.buf = false
    elseif not layout.tab and not layout.buf then
        layout.tab = true
        layout.buf = true
    end
    vim.g.tabline_layout = layout
end

local function setup()
    vim.g.Popc_useTabline = 0
    vim.g.tabline_layout = { tab = true, buf = true }
    vim.o.termguicolors = 1
    vim.o.showtabline = 2
    heirline.setup({
        statusline = stls,
        tabline = tabs,
        winbar = bars,
    })
    heirline.load_colors(load_colors())
    vim.api.nvim_create_augroup('PkgHeirline', { clear = true })
    vim.api.nvim_create_autocmd('ColorScheme', {
        callback = function()
            local colors = load_colors()
            utils.on_colorscheme(colors)
        end,
        group = 'PkgHeirline',
    })
    m.nnore{'<leader>tk', toggle_check}
    m.nnore{'<leader>ty', toggle_layout}
end

return {
    setup = setup
}
