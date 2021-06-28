local fn = vim.fn
local M = {}

function M.is_linux()
    return  (fn.has('unix') == 1)
        and (fn.has('macunix') == 0)
        and (fn.has('win32unix') == 0)
end

function M.is_win()
    return (fn.has('win32') == 1) or (fn.has('win64') == 1)
end

function M.is_gw()
    return fn.has('win32unix') == 1
end

function M.is_mac()
    return fn.has('mac') == 1
end

function M.is_vim()
    return fn.has('nvim') == 0
end

function M.is_nvim()
    return fn.has('nvim') == 1
end

return M
