local use = vim.fn.SvarUse()
local m = require('v.maps')
local heirline = require('heirline')
local conds = require('heirline.conditions')
local utils = require('heirline.utils')


-- Symbols
local sep = { '(', ')' }
local vos = ''
if use.ui.patch then
    sep = { '', '' }
    if vim.fn.IsLinux() == 1 then
        vos = ''
    elseif vim.fn.IsMac() == 1 then
        vos = ''
    else
        vos = ''
    end
end

-- Contexts
local ctxs = {}

ctxs.attr = '%{&ft!=#""?&ft."│":""}%{&fenc!=#""?&fenc:&enc}│%{&ff}'
if use.ui.patch then
    ctxs.lite = '%l/%L %v %{winnr()}.%n%{&mod?"+":""}'
else
    ctxs.lite = '%l/%L $%v %{winnr()}.%n%{&mod?"+":""}'
end
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
        res = vim.fn.QuickfixType() == 'c' and 'QF' or 'QL'
    elseif ft == 'help' then
        res = 'Help'
    end
    return vos .. ' ' .. res
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
    end
    if layout.tab then
        res.tab = buftab[2]
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
        -- gruvbox dark
        areaA = '#ff8019',
        areaB = '#beaa82',
        areaC = '#504b4b',
        textA = '#dc6919',
        textB = '#ebdcb4',
        textC = '#c8b9a5',
    }
end

-- Components
local function pad(color, component, fileds)
    local res = utils.surround(sep, color, component)
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

local stl_default = {
    ComHint, ComPath,
    ComAlign,
    ComCheck, ComAttr, ComInfo,
}
local stl_inactive = {
    condition = conds.is_not_active,
    ComFile, ComAlign, ComLite,
}
local stl_terminal = {
    condition = function()
        return conds.buffer_matches({
            buftype = { 'terminal' }
        })
    end,
    {
        condition = conds.is_active,
        ComHint, ComFile,
    },
    {
        condition = conds.is_not_active,
        ComFile,
    },
    ComAlign,
}
local stl_special = {
    condition = function()
        return conds.buffer_matches({
            filetype = { 'vista', 'NvimTree', 'nerdtree' }
        })
    end,
    ComType, ComAlign,
}
local stls = wrap({
    fallthrough = false,
    stl_special, stl_terminal, stl_inactive, stl_default
})

-- Tablines
local ComB = utils.surround({'', sep[2]}, 'areaA', {
    provider = 'B',
    hl = { fg = 'blank' },
})
local ComT = utils.surround({sep[1], ''}, 'areaA', {
    provider = 'T',
    hl = { fg = 'blank' }
})

local function ele(e)
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
    return pad(bg, {
        provider = txt,
        hl = { fg = fg },
    })
end

local tabs = wrap({
    init = function(self)
        local res = ctxs.tabs_bufs(vim.g.tabline_layout)
        local children = {}
        -- buffers
        if res.buf then
            table.insert(children, ComB)
            for _, e in ipairs(res.buf) do
                table.insert(children, ele(e))
            end
        end
        table.insert(children, ComAlign)
        -- tabpages
        if res.tab then
            for _, e in ipairs(res.tab) do
                table.insert(children, ele(e))
            end
            table.insert(children, ComT)
        end
        -- instantiate new child with overwriting the previous one
        self.child = self:new(children, 1)
    end,
    provider = function(self)
        return self.child:eval()
    end,
})

-- Setup
local function toggle_check()
    if vim.b.statusline_check_enabled == nil then
        vim.b.statusline_check_enabled = true
    end
    vim.b.statusline_check_enabled = not vim.b.statusline_check_enabled
    vim.fn.Notify('b:statusline_check_enabled = ' .. tostring(vim.b.statusline_check_enabled))
end

vim.g.tabline_layout = { tab = true, buf = true }
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
    vim.o.showtabline = 2
    heirline.setup(stls, nil, tabs)
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
