local fn = vim.fn

local env = {
    ['local'] = {
        vim.env.DotVimLocal,
        vim.env.DotVimLocal .. '/bin',
    },
    ['unix'] = {
        '~/ubin',
        '~/uapps',
    }
}

local function env_init()
    local sep = ''
    if IsWin() then
        sep = ';'
        -- For .ycm_extra_conf.py
        vim.env.VPathPython = vim.env.APPS_HOME .. '/Python'
        vim.env.VPathMingw64 = vim.env.APPS_HOME .. '/msys64/mingw64'
    else
        sep = ':'
        vim.env.PATH = vim.env.PATH .. sep .. fn.join(env['unix'], sep)
        vim.env.VPathPython = '/usr/bin'
    end

    -- Local path has first priority to vim
    vim.env.PATH = fn.join(env['local'], sep) .. sep .. vim.env.PATH

    -- Append {'path':[], 'vars':{}} from .env.json
    local ex_file = vim.env.DotVimCache .. '/.env.json'
    if fn.filereadable(ex_file) == 1 then
        local ex = vim.json.decode(fn.join(fn.readfile(ex_file)))
        vim.env.PATH = vim.env.PATH .. sep .. fn.join(ex.path, sep)
        for name, val in pairs(ex.vars) do
            vim.env[name] = val
        end
    end
end

return {
    setup = env_init,
}
