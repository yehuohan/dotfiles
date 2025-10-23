--- @class NLib.libutils
local M = {}
local api = vim.api

--- Try to find root directory upward that contains marker
--- @param marker string[]|string|nil
--- @return string|nil
function M.try_root(marker)
    return vim.fs.root(
        api.nvim_buf_get_name(0),
        marker or { '.git', 'Justfile', 'justfile', '.justfile', 'Makefile', 'makefile' }
    )
end

--- Split string arguments with blanks
--- Attention: currently each arg can't contain any blanks.
--- @return string[] List of arguments
function M.str2arg(str) return vim.split(str, '%s+', { trimempty = true }) end

--- Parse string to table of environment variables
--- @param str string Input with format 'VAR0=var0 VAR1=var1'
--- @return table Environment table with { VAR0 = 'var0', VAR1 = 'var1' }
function M.str2env(str)
    local env = {}
    for _, seg in ipairs(M.str2arg(str)) do
        local var = vim.split(seg, '=', { trimempty = true })
        env[var[1]] = var[2]
    end
    return env
end

--- Repleace command's placeholders
--- @param cmd string String command with format 'cmd {arg}'
--- @param rep table Replacement with { arg = 'val' }
function M.replace(cmd, rep) return vim.trim(string.gsub(cmd, '{(%w+)}', rep)) end

--- Sequence commands
--- @param cmdlist string[] Command list to join with ' && '
function M.sequence(cmdlist) return table.concat(cmdlist, ' && ') end

--- Deep copy variable
--- @param mt boolean|nil Copy metatable or not
function M.deepcopy(orig, mt)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in pairs(orig) do
            copy[M.deepcopy(k, mt)] = M.deepcopy(v, mt)
        end
        if mt then
            setmetatable(copy, M.deepcopy(getmetatable(orig), mt))
        end
    else
        copy = orig
    end
    return copy
end

--- Deep merge table
--- @param dst table The table to merge into, and metatable will be keeped
--- @param src table The table to merge from, and value will be keeped for same key
--- @param raw boolean|nil Use `rawget/rawset` to avoid `dst.metatable` works
function M.deepmerge(dst, src, raw)
    if raw then
        for k, v in pairs(src) do
            if type(v) == 'table' then
                if type(rawget(dst, k)) ~= 'table' then
                    rawset(dst, k, {})
                end
                M.deepmerge(rawget(dst, k), v, raw)
            else
                rawset(dst, k, v)
            end
        end
    else
        for k, v in pairs(src) do
            if type(v) == 'table' then
                if type(dst[k]) ~= 'table' then
                    dst[k] = {}
                end
                M.deepmerge(dst[k], v, raw)
            else
                dst[k] = v
            end
        end
    end
end

return M
