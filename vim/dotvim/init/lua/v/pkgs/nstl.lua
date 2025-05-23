local use = require('v.use')
local m = require('v.nlib').m

--- Symbols
local sym = {
    sep = { ' ', '' },
    row = '',
    col = '$',
    buf = 'B',
    tab = 'T',
    lck = '*',
    mod = '+',
    lck_mod = '#',
    lsp = '@',
    vos = '',
}
if use.ui.icon then
    sym.sep = { '', '' }
    sym.row = ''
    sym.col = ''
    sym.buf = ''
    sym.tab = ''
    sym.lck = '󰌾'
    sym.mod = '󱇬'
    sym.lck_mod = '󰗻'
    sym.lsp = ''
    if IsLinux() then
        sym.vos = ''
    elseif IsMac() == 1 then
        sym.vos = ''
    else
        sym.vos = ''
    end
end

--- Contexts for statusline
local ctxs = {}

ctxs.attr = '%{&ft!=#""?&ft."│":""}%{&fenc!=#""?&fenc:&enc}│%{&ff}'
ctxs.lite = sym.row .. '%l/%L ' .. sym.col .. '%v %{win_getid()}.%n'
ctxs.info = 'U%-2B ' .. ctxs.lite

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
        res = (vim.fn.win_gettype() == 'quickfix') and 'QF' or 'QL'
    elseif ft == 'help' then
        res = 'Help'
    end
    local icon = sym.vos
    if vim.bo.readonly and vim.bo.modified then
        icon = sym.lck_mod
    elseif vim.bo.readonly then
        icon = sym.lck
    elseif vim.bo.modified then
        icon = sym.mod
    end
    return icon .. ' ' .. res
end

function ctxs.root_path()
    if not vim.t.nstl_root_path_disabled then
        local fzer = require('v.task').wsc.fzer
        return vim.fs.normalize(fzer.patht[tostring(vim.api.nvim_get_current_tabpage())] or fzer.path)
    end
    return ''
end

function ctxs.relative_path()
    local filepath = vim.fs.normalize(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p'))
    if vim.t.nstl_root_path_disabled then
        return filepath
    else
        local fzer = require('v.task').wsc.fzer
        local root = vim.fs.normalize(fzer.patht[tostring(vim.api.nvim_get_current_tabpage())] or fzer.path)
        local pat = '^' .. vim.fn.escape(root, '\\')
        return vim.fn.substitute(filepath, pat, '', '')
    end
end

function ctxs.check_lines()
    if not vim.bo.modifiable then
        return nil
    end
    if vim.b.nstl_check_lines_enabled == false or vim.b.sets_large_file then
        return nil
    end
    local check_last = vim.b.nstl_check_last or 0
    local check_this = vim.fn.reltimefloat(vim.fn.reltime())
    if check_this - check_last < 1.0 then
        return vim.b.nstl_check_res
    end
    vim.b.nstl_check_last = check_this

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
    vim.b.nstl_check_res = res
    return res
end

function ctxs.tabs_bufs(layout)
    local popc_tabuf = require('popc.panel.tabuf')
    local buflst = layout.buf and popc_tabuf.get_bufstatus(vim.api.nvim_get_current_tabpage()) or {}
    local tablst = layout.tab and popc_tabuf.get_tabstatus() or {}
    buflst, tablst = require('popc.panel.tabuf.tabline').adjust(buflst, tablst, 2, vim.o.columns - 4)
    local res = {}
    if layout.buf then
        res.buf = buflst
        res.buf_click = require('popc.panel.tabuf.tabline').switch_buffer
    end
    if layout.tab then
        res.tab = tablst
        res.tab_click = require('popc.panel.tabuf.tabline').switch_tabpage
    end
    return res
end

--- Alias colors
local function load_colors()
    local normal_bg = require('heirline.utils').get_highlight('Normal').bg or '#000000'
    local colors = {
        blank = normal_bg,
        red = '#fa461e',
        green = '#b8bb26',
        blue = '#83a598',
        gray = '#665c54',
        -- gruvbox dark as default
        base = '#ff8019', -- Base highlight color
        area = '#504b4b', -- Base block bg
        atxt = '#ebdcb4', -- Base block fg
        astr = '#b4aa96', -- Base inactive block fg
        fill = '#beaa82', -- Fill block bg
        ftxt = normal_bg, -- Fill block fg
    }
    local colorscheme = vim.g.colors_name or ''
    if colorscheme == 'monokai-nightasty' then
        colors.base = '#ff9700'
        colors.area = '#4d5154'
        colors.atxt = '#e3e3e1'
        colors.astr = '#b1b1b1'
        colors.fill = '#a1b5b1'
        colors.ftxt = normal_bg
    end
    return colors
end

--- Pad component as a block
--- @param color string|function Block background color
--- @param component table Component contained within block
--- @param fileds table|nil Extra fileds for the whole block
local function pad(color, component, fileds)
    local utils = require('heirline.utils')
    local res = utils.surround(sym.sep, color, component)
    if fileds then
        res = utils.clone(res, fileds)
    end
    return res
end

--- Wrap component as a block with blank background
local function wrap(component) return require('heirline.utils').surround({ '', '' }, 'blank', component) end

--- Statuslines
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
        return 'fill'
    end, { provider = ctxs.hint, hl = { fg = 'ftxt', bold = true } }, { condition = conds.is_active })
    local ComPath = pad('area', {
        { provider = ctxs.root_path, hl = { fg = 'base', bold = true } },
        { provider = ctxs.relative_path, hl = { fg = 'atxt' } },
    })
    local ComFile = pad('area', {
        provider = '%F',
        hl = function() return { fg = conds.is_active() and 'atxt' or 'astr' } end,
    })
    local ComType = pad('area', {
        provider = '%y',
        hl = function() return { fg = conds.is_active() and 'atxt' or 'astr' } end,
    })
    local ComAttr = pad('area', { provider = ctxs.attr, hl = { fg = 'atxt' } })
    local ComInfo = pad('fill', { provider = ctxs.info, hl = { fg = 'ftxt' } })
    local ComLite = pad('area', { provider = ctxs.lite, hl = { fg = 'astr' } })
    local ComCheck = pad('base', {
        provider = function(self) return self:nonlocal('check') end,
        hl = { fg = 'ftxt', italic = true },
    }, {
        condition = function(self)
            self.check = ctxs.check_lines()
            return self.check ~= nil
        end,
    })
    local ComLsp = pad('area', {
        provider = function(self) return self:nonlocal('lsp') end,
        hl = { fg = 'blue', bold = true, italic = true },
        update = {
            'User',
            pattern = 'LspProgressStatusUpdated',
            callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
        },
    }, {
        condition = function(self)
            self.lsp = require('lsp-progress').progress(self)
            return use.nlsp and self.lsp ~= ''
        end,
    })

    local SecLeft = {
        fallthrough = false,
        {
            condition = function()
                return conds.buffer_matches({ filetype = { 'OverseerList', 'neo%-tree' } })
            end,
            ComType,
        },
        {
            condition = function()
                return conds.is_not_active() or conds.buffer_matches({ buftype = { 'terminal' } })
            end,
            ComFile,
        },
        ComPath,
    }
    local SecRight = {
        fallthrough = false,
        {
            condition = conds.is_active,
            ComLsp,
            ComCheck,
            ComAttr,
            ComInfo,
        },
        ComLite,
    }

    return wrap({ ComHint, SecLeft, ComTrunc, SecRight })
end

--- Tablines
local function ele(e, fn)
    local fg = 'atxt'
    local bg = 'area'
    local txt = e.name
    if e.current and not e.modified then
        fg = 'ftxt'
        bg = 'blue'
    elseif e.current and e.modified then
        txt = txt .. '+'
        fg = 'ftxt'
        bg = 'green'
    elseif (not e.current) and e.modified then
        txt = txt .. '+'
        fg = 'green'
    end
    return pad(bg, { provider = txt, hl = { fg = fg } }, { on_click = { callback = fn, minwid = e.id } })
end

local function tabs()
    local utils = require('heirline.utils')

    local ComAlign = { provider = '%=' }
    local ComBuf = utils.surround({ '', sym.sep[2] }, 'base', {
        provider = sym.buf,
        hl = { fg = 'ftxt' },
    })
    local ComTab = utils.surround({ sym.sep[1], '' }, 'base', {
        provider = sym.tab,
        hl = { fg = 'ftxt' },
    })

    return wrap({
        init = function(self)
            local res = ctxs.tabs_bufs(vim.g.nstl_tabline_layout)
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
        provider = function(self) return self.child:eval() end,
    })
end

--- Winbars
local function disabled_bars(args)
    local bar_excluded_filetypes = { 'alpha', 'OverseerList', 'neo%-tree' }
    local bar_excluded_buftypes = { 'nofile', 'terminal', 'quickfix' }
    local filetype = vim.tbl_contains(bar_excluded_filetypes, vim.bo[args.buf].filetype)
    local buftype = vim.tbl_contains(bar_excluded_buftypes, vim.bo[args.buf].buftype)
    return filetype or buftype or vim.o.laststatus ~= 3 or vim.api.nvim_win_get_config(0).relative ~= ''
end

local function bars()
    return wrap({
        {
            provider = function(self) return self:nonlocal('fdir') end,
            hl = { fg = 'blue' },
        },
        {
            provider = use.ui.icon and '  ' or ' > ',
            hl = { fg = 'red' },
        },
        {
            provider = function(self) return self:nonlocal('fname') end,
            hl = { fg = 'green' },
        },
        init = function(self)
            local curfile = vim.api.nvim_buf_get_name(0)
            self.fdir = vim.fn.fnamemodify(curfile, ':h')
            self.fname = vim.fn.fnamemodify(curfile, ':t')
        end,
    })
end

--- Setup functions
local function toggle_root_path()
    if vim.t.nstl_root_path_disabled == nil then
        vim.t.nstl_root_path_disabled = false
    end
    vim.t.nstl_root_path_disabled = not vim.t.nstl_root_path_disabled
    vim.notify('t:nstl_root_path_disabled = ' .. tostring(vim.t.nstl_root_path_disabled))
end

local function toggle_check_lines()
    if vim.b.nstl_check_lines_enabled == nil then
        vim.b.nstl_check_lines_enabled = true
    end
    vim.b.nstl_check_lines_enabled = not vim.b.nstl_check_lines_enabled
    vim.notify('b:nstl_check_lines_enabled = ' .. tostring(vim.b.nstl_check_lines_enabled))
end

local function toggle_tabline_layout()
    local layout = vim.g.nstl_tabline_layout
    if layout.tab and layout.buf then
        layout.tab = false
    elseif not layout.tab and layout.buf then
        layout.tab = true
        layout.buf = false
    elseif layout.tab and not layout.buf then
        layout.buf = true
    end
    vim.g.nstl_tabline_layout = layout
end

local function pkg_nstl()
    vim.g.nstl_tabline_layout = { tab = true, buf = true }
    vim.o.termguicolors = true
    vim.o.showtabline = 2

    -- Lsp status
    require('lsp-progress').setup({
        format = function(client_messages)
            local sign = sym.lsp .. ' Lsp'
            if #client_messages > 0 then
                return sign .. ' ' .. table.concat(client_messages, ' ')
            end
            if #vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() }) > 0 then
                return sign
            end
            return ''
        end,
    })

    local reset = function()
        local heirline = require('heirline')
        heirline.setup({
            statusline = stls(),
            -- tabline = tabs(),
            winbar = bars(),
            opts = {
                disable_winbar_cb = disabled_bars,
                colors = load_colors(),
            },
        })
    end
    reset()
    vim.api.nvim_create_user_command('NStlReset', reset, { nargs = 0 })

    vim.api.nvim_create_autocmd('ColorScheme', {
        group = 'v.Pkgs',
        callback = function()
            local colors = load_colors()
            require('heirline.utils').on_colorscheme(colors)
        end,
    })
    m.nnore({ '<leader>ta', toggle_root_path, desc = 'Toggle root path' })
    m.nnore({ '<leader>tl', toggle_check_lines, desc = 'Toggle check lines' })
    m.nnore({ '<leader>ty', toggle_tabline_layout, desc = 'Toggle table layout' })
end

return {
    'rebelot/heirline.nvim',
    config = pkg_nstl,
    event = 'VeryLazy',
    dependencies = {
        -- 'yehuohan/popc',
        'linrongbin16/lsp-progress.nvim',
    },
}
