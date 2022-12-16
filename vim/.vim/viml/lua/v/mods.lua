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
-- Workspace
--------------------------------------------------------------------------------
--local ws = { root = '', rp = {}, fw = {} }


function M.setup()
end

return M
