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

return {
    setup = function()
        require('v.env').setup()
        require('v.use').setup()
        vim.cmd.source(vim.env.DotVimVimL .. '/pkgs.vim')
        require('v.pkgs').setup()
        require('v.task').setup()
    end,
}
