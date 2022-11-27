local fn = vim.fn

local use_file = vim.env.DotVimCache .. '/.use.json'
local use = {
    fastgit    = false,
    coc        = false,
    nlsp       = false,
    treesitter = false,
    spector    = false,
    has_py     = false,
    ui         = {
        patch    = false,
        font     = 'Consolas',
        fontsize = 12,
        wide     = 'Microsoft YaHei UI',
        widesize = 11,
    }
}

local function use_save(_)
    fn.writefile({ vim.json.encode(use) }, use_file)
    print('s:use save successful!')
end

local function use_load()
    if fn.filereadable(use_file) == 1 then
        use = vim.tbl_deep_extend(
            'force',
            use,
            vim.json.decode(fn.join(fn.readfile(use_file)))
        )
    else
        use_save()
    end
end

local function use_init()
    local udic = vim.tbl_map(function() return vim.empty_dict() end, use)

    -- Set ui selections
    local fontlst = {
        'Consolas',
        'Consolas Nerd Font Mono',
        'agave Nerd Font Mono',
        'UbuntuMono Nerd Font Mono',
        'Microsoft YaHei UI',
        'WenQuanYi Micro Hei Mono',
        }
    local fontsizelst = {9, 10, 11, 12, 13, 14, 15}
    udic.ui = {
        dsr = 'set ui',
        lst = fn.sort(vim.tbl_keys(use.ui)),
        dic = {
            patch    = {lst = {true, false}},
            font     = {dsr = 'set guifont', lst = fontlst},
            wide     = {dsr = 'set guifontwide', lst = fontlst},
            fontsize = {lst = fontsizelst},
            widesize = {lst = fontsizelst},
            },
        sub = {
            cmd = function(sopt, sel) use.ui[sopt] = sel end,
            get = function(sopt) return use.ui[sopt] end,
            },
        onCR = use_save,
        }

    fn.PopSelection({
        opt = 'select use settings',
        lst = fn.sort(vim.tbl_keys(use)),
        dic = udic,
        sub = {
            lst = {true, false},
            cmd = function(sopt, sel) use[sopt] = sel end,
            get = function(sopt) return use[sopt] end,
        },
        onCR = use_save,
    })
end


return {
    setup = function()
        vim.api.nvim_add_user_command('Use', 'lua require("v.use").cfg()', {nargs = 0})
        use_load()
    end,
    get = function() return use end,
    cfg = use_init,
}
