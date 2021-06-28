local fn = vim.fn

local use_file = vim.env.DotVimCachePath .. '/.use.json'
local use = {
    powerfont = 0,
    lightline = 0,
    startify  = 0,
    ycm       = 0,
    snip      = 0,
    coc       = 0,
    spector   = 0,
    leaderf   = 0,
    utils     = 0,
}

local function use_save(...)
    fn.writefile({ fn.json_encode(use) }, use_file)
    print('s:use save successful!')
end

local function use_load()
    if fn.filereadable(use_file) == 1 then
        use = vim.tbl_extend(
            'force',
            use,
            fn.json_decode(fn.join(fn.readfile(use_file)))
        )
    else
        use_save()
    end
end

local function use_init()
    fn.PopSelection({
        opt = 'select use settings',
        lst = fn.sort(vim.tbl_keys(use)),
        dic = vim.tbl_map(function() return vim.empty_dict() end, use),
        sub = {
            lst = {'0', '1'},
            cmd = function(sopt, sel) use = vim.tbl_extend('force', use, {[sopt] = sel}) end,
            get = function(sopt) return use[sopt] end,
            },
        onCR = use_save,
    })
end


vim.cmd[[command! -nargs=0 Use :lua require('use').init()]]

use_load()

return {
    use = use,
    init = use_init,
}
