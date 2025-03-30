local use_file = vim.env.DotVimLocal .. '/.use.json'
local use = {
    has_py = false, -- Enable python features
    has_git = false, -- Enable git features
    has_build = false, -- Enable self-built libraries
    nlsp = false,
    ndap = false,
    nts = false,
    pkgs = {
        blink = true,
        coc = false,
        which_key = false,
        im_select = false,
    },
    ui = {
        icon = false,
        font = { name = '', size = 12 },
        font_nvy = { name = '', size = 12 },
        font_neovide = { name = '', size = 12 },
        font_wide = { name = '', size = 12 },
    },
    xgit = vim.v.null,
}

local lst = {
    fontnames = {
        'Consolas',
        'Consolas,Cousine Nerd Font Mono',
        'Consolas Nerd Font Mono',
        'FantasqueSansM Nerd Font Mono',
        'Maple Mono NF CN',
        'Microsoft YaHei UI',
        'Microsoft YaHei Mono',
        'WenQuanYi Micro Hei Mono',
    },
    fontsizes = { 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 },
    git = {
        vim.v.null,
        'https://kkgithub.com',
        'https://bgithub.xyz',
    },
}

local function set_fonts(inc)
    if inc ~= 0 then
        use.ui.font.size = use.ui.font.size + inc
        use.ui.font_nvy.size = use.ui.font_nvy.size + inc
        use.ui.font_neovide.size = use.ui.font_neovide.size + inc
        use.ui.font_wide.size = use.ui.font_wide.size + inc
    end
    local fontname = use.ui.font.name
    local fontsize = use.ui.font.size
    if vim.g.nvy then
        fontname = use.ui.font_nvy.name
        fontsize = use.ui.font_nvy.size
    elseif vim.g.neovide then
        fontname = use.ui.font_neovide.name
        fontsize = use.ui.font_neovide.size
    end
    vim.o.guifont = fontname .. ':h' .. tostring(fontsize)
    vim.o.guifontwide = use.ui.font_wide.name .. ':h' .. tostring(use.ui.font_wide.size)
end

--- @type PopSelectionEvent
local function use_save(name)
    if name == 'onCR' then
        vim.fn.mkdir(vim.env.DotVimLocal, 'p')
        vim.fn.writefile({ vim.json.encode(use) }, use_file)
        vim.notify('v.use save successful!')
    end
end

local function use_load()
    if vim.fn.filereadable(use_file) == 1 then
        use = vim.tbl_deep_extend('force', use, vim.json.decode(vim.fn.join(vim.fn.readfile(use_file))))
    else
        use_save('onCR')
    end
end

local function use_init()
    -- Init with empty dict '{}' to indicate sub-selection
    local udic = vim.tbl_map(function() return vim.empty_dict() end, use)
    local fdic = function(name)
        return {
            dsr = 'set ' .. name,
            lst = { 'name', 'size' },
            dic = {
                name = { lst = lst.fontnames },
                size = { lst = lst.fontsizes },
            },
            sub = {
                cmd = function(sopt, sel)
                    use.ui[name][sopt] = sel
                    set_fonts(0)
                end,
                get = function(sopt) return use.ui[name][sopt] end,
            },
        }
    end
    udic.pkgs = {
        dsr = 'set pkgs',
        lst = vim.fn.sort(vim.tbl_keys(use.pkgs)),
        dic = vim.tbl_map(function() return vim.empty_dict() end, use.pkgs),
        sub = {
            lst = { true, false },
            cmd = function(sopt, sel) use.pkgs[sopt] = sel end,
            get = function(sopt) return use.pkgs[sopt] end,
        },
    }
    udic.ui = {
        dsr = 'set ui',
        lst = vim.fn.sort(vim.tbl_keys(use.ui)),
        dic = {
            icon = { lst = { true, false } },
            font = fdic('font'),
            font_nvy = fdic('font_nvy'),
            font_neovide = fdic('font_neovide'),
            font_wide = fdic('font_wide'),
        },
        sub = {
            cmd = function(sopt, sel) use.ui[sopt] = sel end,
            get = function(sopt) return use.ui[sopt] end,
        },
    }
    udic.xgit = { lst = lst.git }
    vim.fn.PopSelection({
        opt = 'use',
        lst = vim.fn.sort(vim.tbl_keys(use)),
        dic = udic,
        evt = use_save,
        sub = {
            lst = { true, false },
            cmd = function(sopt, sel) use[sopt] = sel end,
            get = function(sopt) return use[sopt] end,
        },
    })
end

local M = setmetatable({
    setup = function()
        vim.api.nvim_create_user_command('Use', use_init, { nargs = 0 })
        use_load()
    end,
    set_fonts = set_fonts,
}, { __index = function(_, k) return use[k] end })

return M
