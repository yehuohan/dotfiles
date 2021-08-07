local fn = vim.fn

local use_file = vim.env.DotVimCachePath .. '/.use.json'
local use = {
    fastgit   = false,
    powerfont = false,
    lightline = false,
    startify  = false,
    ycm       = false,
    coc       = false,
    coc_exts  = {
        ['coc-snippets']      = false,
        ['coc-yank']          = false,
        ['coc-explorer']      = false,
        ['coc-json']          = false,
        ['coc-clangd']        = false,
        ['coc-rust-analyzer'] = false,
        ['coc-pyright']       = false,
        ['coc-java']          = false,
        ['coc-tsserver']      = false,
        ['coc-vimlsp']        = false,
        ['coc-lua']           = false,
        ['coc-toml']          = false,
        ['coc-vimtex']        = false,
        ['coc-cmake']         = false,
        ['coc-calc']          = false,
    },
    nlsp      = false,
    snip      = false,
    spector   = false,
    leaderf   = false,
    utils     = false,
}

local function use_save(_)
    fn.writefile({ fn.json_encode(use) }, use_file)
    print('s:use save successful!')
end

local function use_load()
    if fn.filereadable(use_file) == 1 then
        use = vim.tbl_deep_extend(
            'force',
            use,
            fn.json_decode(fn.join(fn.readfile(use_file)))
        )
    else
        use_save()
    end
end

local function use_init()
    -- Set coc-extension selections
    local cocdic = vim.tbl_map(function() return vim.empty_dict() end, use)
    cocdic.coc_exts = {
        dsr = 'coc extensions',
        lst = fn.sort(vim.tbl_keys(use.coc_exts)),
        dic = vim.tbl_map(function() return vim.empty_dict() end, use.coc_exts),
        sub = {
            lst = {true, false},
            cmd = function(sopt, sel) use.coc_exts[sopt] = sel end,
            get = function(sopt) return use.coc_exts[sopt] end,
        },
        onCR = use_save,
    }

    fn.PopSelection({
        opt = 'select use settings',
        lst = fn.sort(vim.tbl_keys(use)),
        dic = cocdic,
        sub = {
            lst = {true, false},
            cmd = function(sopt, sel) use[sopt] = sel end,
            get = function(sopt) return use[sopt] end,
        },
        onCR = use_save,
    })
end


vim.cmd[[command! -nargs=0 Use :lua require('v.use').init()]]

use_load()

return {
    use = use,
    init = use_init,
}
