local use_file = vim.env.DotVimLocal .. '/.use.json'
local use = {
    has_py = false,
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
        font = 'Consolas',
        fontback = 'Consolas',
        fontsize = 12,
        wide = 'Microsoft YaHei UI',
        widesize = 11,
    },
    xgit = vim.v.null,
}

local lst = {
    fonts = {
        'Consolas',
        'Consolas,CodeNewRoman Nerd Font Mono',
        'Consolas,Cousine Nerd Font Mono',
        'Consolas Nerd Font Mono',
        'FantasqueSansM Nerd Font Mono',
        'Microsoft YaHei UI',
        'Microsoft YaHei Mono',
        'WenQuanYi Micro Hei Mono',
    },
    fontsize = { 9, 10, 11, 12, 13, 14, 15, 16 },
    git = {
        vim.v.null,
        'https://kkgithub.com',
    },
}

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
            font = { dsr = 'as guifont', lst = lst.fonts },
            fontback = { dsr = 'as guifont fallback', lst = lst.fonts },
            wide = { dsr = 'as guifontwide', lst = lst.fonts },
            fontsize = { lst = lst.fontsize },
            widesize = { lst = lst.fontsize },
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
}, { __index = function(t, k) return use[k] end })

return M
