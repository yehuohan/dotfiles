local fn = vim.fn

local use_file = vim.env.DotVimLocal .. '/.use.json'
local use = {
    xgit = vim.v.null,
    coc = false,
    nlsp = false,
    nts = false,
    ndap = false,
    has_py = false,
    ui = {
        patch = false,
        font = 'Consolas',
        fontsize = 12,
        wide = 'Microsoft YaHei UI',
        widesize = 11,
    },
}

local function use_save(name)
    if name == 'onCR' then
        fn.writefile({ vim.json.encode(use) }, use_file)
        vim.notify('v.use save successful!')
    end
end

local function use_load()
    if fn.filereadable(use_file) == 1 then
        use = vim.tbl_deep_extend('force', use, vim.json.decode(fn.join(fn.readfile(use_file))))
    else
        use_save('onCR')
    end
end

local function use_init()
    -- Init with empty dict '{}' to indicate sub-selection
    local udic = vim.tbl_map(function()
        return vim.empty_dict()
    end, use)
    -- Set xgit
    udic.xgit = { lst = { vim.v.null, 'https://kgithub.com' } }
    -- Set ui
    local fontlst = {
        'Consolas',
        'Consolas,CaskaydiaCove Nerd Font Mono',
        'Consolas Nerd Font Mono',
        'CaskaydiaCove Nerd Font Mono',
        'agave Nerd Font Mono',
        'FantasqueSansMono Nerd Font Mono',
        'UbuntuMono Nerd Font Mono',
        'Microsoft YaHei UI',
        'Microsoft YaHei Mono',
        'WenQuanYi Micro Hei Mono',
    }
    local fontsizelst = { 9, 10, 11, 12, 13, 14, 15 }
    udic.ui = {
        dsr = 'set ui',
        lst = fn.sort(vim.tbl_keys(use.ui)),
        dic = {
            patch = { lst = { true, false } },
            font = { dsr = 'set guifont', lst = fontlst },
            wide = { dsr = 'set guifontwide', lst = fontlst },
            fontsize = { lst = fontsizelst },
            widesize = { lst = fontsizelst },
        },
        sub = {
            cmd = function(sopt, sel)
                use.ui[sopt] = sel
            end,
            get = function(sopt)
                return use.ui[sopt]
            end,
        },
    }

    fn.PopSelection({
        opt = 'use',
        lst = fn.sort(vim.tbl_keys(use)),
        dic = udic,
        evt = use_save,
        sub = {
            lst = { true, false },
            cmd = function(sopt, sel)
                use[sopt] = sel
            end,
            get = function(sopt)
                return use[sopt]
            end,
        },
    })
end

return {
    setup = function()
        vim.api.nvim_create_user_command('Use', 'lua require("v.use").cfg()', { nargs = 0 })
        use_load()
    end,
    get = function()
        return use
    end,
    cfg = use_init,
}
