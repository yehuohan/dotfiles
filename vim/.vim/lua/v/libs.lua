local fn = vim.fn
local M = {
    keymap = {}
}


-- 获取选区内容
function M.get_selected(sep)
    local reg_var = fn.getreg('9', 1)
    local reg_mode = fn.getregtype('9')
    if fn.mode() ==# 'n' then
        vim.cmd[[silent normal! gv"9y]]
    else
        vim.cmd[[silent normal! "9y]]
    end
    local selected = fn.getreg('9')
    fn.setreg('9', reg_var, reg_mode)

    if sep then
        return fn.join(fn.split(selected, "\n"), sep)
    else
        return selected
    end
end

-- 获取计算结果
function M.get_eval(str, ty)
    local result = ''
    if ty == 'command'       then result = fn.execute(str)
    elseif ty == 'function'  then result = fn.eval(str)
    elseif ty == 'registers' then result = fn.eval('@' .. str)
    end
    if fn.type(result) ~= vim.v.t_string then
        result = fn.string(result)
    end
    return fn.split(result, "\n")
end

--------------------------------------------------------------------------------
-- keymap
-- local map      = require('v.libs').keymap.map
-- local nmap     = require('v.libs').keymap.nmap
-- local vmap     = require('v.libs').keymap.vmap
-- local xmap     = require('v.libs').keymap.xmap
-- local smap     = require('v.libs').keymap.smap
-- local omap     = require('v.libs').keymap.omap
-- local imap     = require('v.libs').keymap.imap
-- local lmap     = require('v.libs').keymap.lmap
-- local cmap     = require('v.libs').keymap.cmap
-- local tmap     = require('v.libs').keymap.tmap
-- local noremap  = require('v.libs').keymap.noremap
-- local nnoremap = require('v.libs').keymap.nnoremap
-- local vnoremap = require('v.libs').keymap.vnoremap
-- local xnoremap = require('v.libs').keymap.xnoremap
-- local snoremap = require('v.libs').keymap.snoremap
-- local onoremap = require('v.libs').keymap.onoremap
-- local inoremap = require('v.libs').keymap.inoremap
-- local lnoremap = require('v.libs').keymap.lnoremap
-- local cnoremap = require('v.libs').keymap.cnoremap
-- local tnoremap = require('v.libs').keymap.tnoremap
--------------------------------------------------------------------------------
local setmap = vim.api.nvim_set_keymap
local function setopts(opts, defaults)
    local map_opts = {}
    for k, v in pairs(opts) do
        if type(k) == 'string' then
            map_opts[k] = v
        end
    end
    if defaults then
        map_opts = vim.tbl_extend('keep', map_opts, defaults)
    end
    return map_opts
end

function M.keymap.map(opts)      setmap('',  opts[1], opts[2], setopts(opts)) end
function M.keymap.nmap(opts)     setmap('n', opts[1], opts[2], setopts(opts)) end
function M.keymap.vmap(opts)     setmap('v', opts[1], opts[2], setopts(opts)) end
function M.keymap.xmap(opts)     setmap('x', opts[1], opts[2], setopts(opts)) end
function M.keymap.smap(opts)     setmap('s', opts[1], opts[2], setopts(opts)) end
function M.keymap.omap(opts)     setmap('o', opts[1], opts[2], setopts(opts)) end
function M.keymap.imap(opts)     setmap('i', opts[1], opts[2], setopts(opts)) end
function M.keymap.lmap(opts)     setmap('l', opts[1], opts[2], setopts(opts)) end
function M.keymap.cmap(opts)     setmap('c', opts[1], opts[2], setopts(opts)) end
function M.keymap.tmap(opts)     setmap('t', opts[1], opts[2], setopts(opts)) end
function M.keymap.noremap(opts)  setmap('',  opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.keymap.nnoremap(opts) setmap('n', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.keymap.vnoremap(opts) setmap('v', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.keymap.xnoremap(opts) setmap('x', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.keymap.snoremap(opts) setmap('s', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.keymap.onoremap(opts) setmap('o', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.keymap.inoremap(opts) setmap('i', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.keymap.lnoremap(opts) setmap('l', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.keymap.cnoremap(opts) setmap('c', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.keymap.tnoremap(opts) setmap('t', opts[1], opts[2], setopts(opts, { noremap = true })) end


return M
