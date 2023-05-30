local use = vim.fn.SvarUse()
local m = require('v.maps')

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
    if IsLinux() then
        sym.vos = ''
    elseif IsMac() == 1 then
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

local ctx_check_last = vim.fn.reltimefloat(vim.fn.reltime())
function ctxs.check_lines()
    if vim.b.statusline_check_enabled == false then
        return nil
    end
    local check_this = vim.fn.reltimefloat(vim.fn.reltime())
    if check_this - ctx_check_last < 1.0 then
        return vim.b.statusline_check_res
    end
    ctx_check_last = check_this

    local lst = {}
    local pos
    -- mixed indent
    pos = vim.fn.search([[\m\(\t \| \t\)]], 'nw')
    if pos ~= 0 then
        lst[#lst + 1] = 'M:' .. tostring(pos)
    end
    -- trailing whitespaces
    pos = vim.fn.search([[\m\s\+$]], 'nw')
    if pos ~= 0 then
        lst[#lst + 1] = 'T:' .. tostring(pos)
    end

    local res = nil
    if #lst > 0 then
        res = table.concat(lst, '│')
    end
    vim.b.statusline_check_res = res
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
        blank = require('heirline.utils').get_highlight('Normal').bg,
        red = '#fa461e',
        green = '#b8bb26',
        blue = '#83a598',
        gray = '#665c54',
        -- gruvbox dark
        areaA = '#ff8019',
        areaB = '#beaa82',
        areaC = '#504b4b',
        textA = '#dc6919',
        textB = '#ebdcb4',
        textC = '#b4aa96',
    }
end

-- Helpers
local function pad(color, component, fileds)
    local utils = require('heirline.utils')
    local res = utils.surround(sym.sep, color, component)
    if fileds then
        res = utils.clone(res, fileds)
    end
    return res
end

local function wrap(component)
    return require('heirline.utils').surround({ '', '' }, 'blank', component)
end

-- Statuslines
local function stls()
    local conds = require('heirline.conditions')

    local ComTrunc = {
        provider = '%=%<',
        hl = { fg = 'gray', strikethrough = true },
    }
    local ComHint = pad(function()
        local mch = ctxs.mode()
        if mch == 'V' or mch == 'S' or mch == '^V' or mch == '^S' then
            return 'red'
        elseif mch == 'I' or mch == 'T' then
            return 'green'
        elseif mch == 'R' then
            return 'blue'
        end
        return 'areaB'
    end, {
        provider = ctxs.hint,
        hl = { fg = 'blank', bold = true },
    }, {
        condition = conds.is_active,
    })
    local ComPath = pad('areaC', {
        {
            provider = ctxs.root_path,
            hl = { fg = 'textA', bold = true },
        },
        {
            provider = ctxs.relative_path,
            hl = { fg = 'textB' },
        },
    })
    local ComFile = pad('areaC', {
        provider = '%F',
        hl = function()
            return { fg = conds.is_active() and 'textB' or 'textC' }
        end,
    })
    local ComType = pad('areaC', {
        provider = '%y',
        hl = function()
            return { fg = conds.is_active() and 'textB' or 'textC' }
        end,
    })
    local ComAttr = pad('areaC', {
        provider = ctxs.attr,
        hl = { fg = 'textB' },
    })
    local ComInfo = pad('areaB', {
        provider = ctxs.info,
        hl = { fg = 'blank' },
    })
    local ComLite = pad('areaC', {
        provider = ctxs.lite,
        hl = { fg = 'textC' },
    })
    local ComCheck = pad('areaA', {
        provider = function(self)
            return self:nonlocal('check')
        end,
        hl = { fg = 'blank', italic = true },
    }, {
        condition = function(self)
            self.check = ctxs.check_lines()
            return self.check ~= nil
        end,
    })

    local SecLeft = {
        fallthrough = false,
        {
            condition = function()
                return conds.buffer_matches({
                    filetype = { 'vim%-plug', 'vista', 'NvimTree', 'nerdtree' },
                })
            end,
            ComType,
        },
        {
            condition = function()
                return conds.is_not_active()
                    or conds.buffer_matches({
                        buftype = { 'help', 'terminal' },
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
            ComCheck,
            ComAttr,
            ComInfo,
        },
        ComLite,
    }

    return wrap({ ComHint, SecLeft, ComTrunc, SecRight })
end

-- Tablines
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
    return pad(bg, {
        provider = txt,
        hl = { fg = fg },
    }, {
        on_click = {
            callback = fn,
            minwid = e.index,
        },
    })
end

local function tabs()
    local utils = require('heirline.utils')

    local ComAlign = { provider = '%=' }
    local ComBuf = utils.surround({ '', sym.sep[2] }, 'areaA', {
        provider = sym.buf,
        hl = { fg = 'blank' },
    })
    local ComTab = utils.surround({ sym.sep[1], '' }, 'areaA', {
        provider = sym.tab,
        hl = { fg = 'blank' },
    })

    return wrap({
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
end

-- Winbars
local function disabled_bars(args)
    local bar_excluded_filetypes = { 'alpha', 'vim%-plug', 'vista', 'NvimTree', 'nerdtree' }
    local bar_excluded_buftypes = { 'nofile', 'terminal', 'quickfix' }
    local filetype = vim.tbl_contains(bar_excluded_filetypes, vim.bo[args.buf].filetype)
    local buftype = vim.tbl_contains(bar_excluded_buftypes, vim.bo[args.buf].buftype)
    return filetype
        or buftype
        or vim.o.laststatus ~= 3
        or vim.api.nvim_win_get_config(0).relative ~= ''
end

local function bars()
    return wrap({
        {
            provider = function(self)
                return self:nonlocal('fdir')
            end,
            hl = { fg = 'blue' },
        },
        {
            provider = use.ui.patch and '  ' or ' > ',
            hl = { fg = 'red' },
        },
        {
            provider = function(self)
                return self:nonlocal('fname')
            end,
            hl = { fg = 'green' },
        },
        init = function(self)
            local curfile = vim.fn.Expand('%')
            self.fdir = vim.fn.fnamemodify(curfile, ':h')
            self.fname = vim.fn.fnamemodify(curfile, ':t')
        end,
    })
end

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
    local heirline = require('heirline')

    vim.g.Popc_useTabline = 0
    vim.g.tabline_layout = { tab = true, buf = true }
    vim.o.termguicolors = 1
    vim.o.showtabline = 2
    heirline.setup({
        statusline = stls(),
        tabline = tabs(),
        winbar = bars(),
        opts = {
            disable_winbar_cb = disabled_bars,
            colors = load_colors(),
        },
    })
    vim.api.nvim_create_augroup('PkgHeirline', { clear = true })
    vim.api.nvim_create_autocmd('ColorScheme', {
        callback = function()
            local colors = load_colors()
            require('heirline.utils').on_colorscheme(colors)
        end,
        group = 'PkgHeirline',
    })
    m.nnore({ '<leader>tl', toggle_check })
    m.nnore({ '<leader>ty', toggle_layout })
end

return {
    setup = setup,
}
