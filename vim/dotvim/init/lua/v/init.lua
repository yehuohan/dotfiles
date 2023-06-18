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
    -- Append {'path':[], 'vars':{}} from .env.json
    local sep = IsWin() and ';' or ':'
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
