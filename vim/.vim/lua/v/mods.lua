local fn = vim.fn
local M = { }

--------------------------------------------------------------------------------
-- Libs
--------------------------------------------------------------------------------
-- 获取选区内容
function M.GetSelected(sep)
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
function M.GetEval(str, ty)
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

-- 解析字符串参数到列表中
-- @param str: 参数字符串，如 '"Test", 10, g:a'
-- @return 返回参数列表，如 ["Test", 10, g:a]
function M.GetArgs(str)
    return fn.luaeval('{' ..  str .. '}')
end

-- 输入字符串: Input2Str(prompt, [text, completion, workdir])
-- @param workdir: 设置工作目录，用于文件和目录补全
function M.Input2Str(prompt, ...)
    local a = {...}
    if #a == 0 then
        return fn.input(prompt)
    elseif #a == 1 then
        return fn.input(prompt, a[1])
    elseif #a == 2 then
        return fn.input(prompt, a[1], a[2])
    elseif #a == 3 then
        vim.cmd('lcd ' .. a[3])
        return fn.input(prompt, a[1], a[2])
    end
end

-- 输入字符串作为函数参数: Input2Fn(iargs, fn, [fargs...])
-- @param iargs: 用于Input2Str的参数列表
-- @param fn: 要运行的函数，第一个参数必须为Input2Str的输入
-- @param fargs: fn的附加参数
function M.Input2Fn(iargs, ifn, ...)
    local a = {...}
    local inpt = M.Input2Str(unpack(iargs))
    if fn.empty(inpt) == 1 then
        return
    end
    local fargs = { inpt }
    if #a > 0 then
        fargs = fn.extend(fargs, a)
    end
    local Fn = fn.funcref(ifn, fargs)
    -- TODO support range
    --local range = (a:firstline == a:lastline) ? '' : (string(a:firstline) . ',' . string(a:lastline))
    Fn(unpack(fargs))
end


--------------------------------------------------------------------------------
-- Keymap
-- local map      = require('v.mods').keymap.map
-- local nmap     = require('v.mods').keymap.nmap
-- local vmap     = require('v.mods').keymap.vmap
-- local xmap     = require('v.mods').keymap.xmap
-- local smap     = require('v.mods').keymap.smap
-- local omap     = require('v.mods').keymap.omap
-- local imap     = require('v.mods').keymap.imap
-- local lmap     = require('v.mods').keymap.lmap
-- local cmap     = require('v.mods').keymap.cmap
-- local tmap     = require('v.mods').keymap.tmap
-- local noremap  = require('v.mods').keymap.noremap
-- local nnoremap = require('v.mods').keymap.nnoremap
-- local vnoremap = require('v.mods').keymap.vnoremap
-- local xnoremap = require('v.mods').keymap.xnoremap
-- local snoremap = require('v.mods').keymap.snoremap
-- local onoremap = require('v.mods').keymap.onoremap
-- local inoremap = require('v.mods').keymap.inoremap
-- local lnoremap = require('v.mods').keymap.lnoremap
-- local cnoremap = require('v.mods').keymap.cnoremap
-- local tnoremap = require('v.mods').keymap.tnoremap
--------------------------------------------------------------------------------
M.keymap = {}
local setmap = vim.keymap.set
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

function M.keymap.map(opts)      setmap('',  opts[1], opts[2], setopts(opts, { remap = true })) end
function M.keymap.nmap(opts)     setmap('n', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.keymap.vmap(opts)     setmap('v', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.keymap.xmap(opts)     setmap('x', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.keymap.smap(opts)     setmap('s', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.keymap.omap(opts)     setmap('o', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.keymap.imap(opts)     setmap('i', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.keymap.lmap(opts)     setmap('l', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.keymap.cmap(opts)     setmap('c', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.keymap.tmap(opts)     setmap('t', opts[1], opts[2], setopts(opts, { remap = true })) end
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


--------------------------------------------------------------------------------
-- Workspace
--------------------------------------------------------------------------------
--local ws = { root = '', rp = {}, fw = {} }


function M.setup()
end

return M
