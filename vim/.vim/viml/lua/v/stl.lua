local use = vim.fn.SvarUse()
local m = require('v.maps')
local heirline = require('heirline')
local conds = require('heirline.conditions')
local utils = require('heirline.utils')


-- Symbols
local sep = { '', '' }
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

-- Statuslines
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

local function toggle_check()
    if vim.b.statusline_check_enabled == nil then
        vim.b.statusline_check_enabled = true
    end
    vim.b.statusline_check_enabled = not vim.b.statusline_check_enabled
    vim.fn.Notify('b:statusline_check_enabled = ' .. tostring(vim.b.statusline_check_enabled))
end

local function setup()
    heirline.setup(stls)
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
end

return {
    setup = setup
}
