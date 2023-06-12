--------------------------------------------------------------------------------
-- init.lua: configuration for neovim.
-- Github: https://github.com/yehuohan/dotconfigs
-- Author: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
--------------------------------------------------------------------------------

function IsLinux()
    return (vim.fn.has('unix') == 1)
        and (vim.fn.has('macunix') == 0)
        and (vim.fn.has('win32unix') == 0)
end

function IsWin() return (vim.fn.has('win32') == 1) or (vim.fn.has('win64') == 1) end

function IsGw() return vim.fn.has('win32unix') == 1 end

function IsMac() return vim.fn.has('mac') == 1 end

local function init_env()
    local env = {
        ['local'] = { vim.env.DotVimLocal .. '/bin' },
        ['unix'] = { '~/ubin', '~/uapps' },
    }
    local sep = ''
    if IsWin() then
        sep = ';'
        -- For .ycm_extra_conf.py
        vim.env.VPathPython = vim.env.APPS_HOME .. '/Python'
        vim.env.VPathMingw64 = vim.env.APPS_HOME .. '/msys64/mingw64'
    else
        sep = ':'
        vim.env.PATH = vim.env.PATH .. sep .. vim.fn.join(env['unix'], sep)
        vim.env.VPathPython = '/usr/bin'
    end

    -- Local path has first priority to vim
    vim.env.PATH = vim.fn.join(env['local'], sep) .. sep .. vim.env.PATH

    -- Append {'path':[], 'vars':{}} from .env.json
    local env_file = vim.env.DotVimLocal .. '/.env.json'
    if vim.fn.filereadable(env_file) == 1 then
        local ex = vim.json.decode(vim.fn.join(vim.fn.readfile(env_file)))
        vim.env.PATH = vim.env.PATH .. sep .. vim.fn.join(ex.path, sep)
        for name, val in pairs(ex.vars) do
            vim.env[name] = val
        end
    end
end

return {
    setup = function()
        init_env()
        require('v.use').setup()
        vim.cmd.source(vim.env.DotVimVimL .. '/pkgs.vim')
        require('v.pkgs').setup()
        require('v.task').setup()
    end,
}
