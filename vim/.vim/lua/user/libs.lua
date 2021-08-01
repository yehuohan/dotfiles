local fn = vim.fn
local M = {}


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

-- 获取特定的内容的范围
-- @param pats: 起始行匹配模式，rstart为pats所在行
-- @param pate: 结束行匹配模式，rend为pate所在行
-- @return 返回列表[rstart, rend]
function M.get_range(pats, pate)
    local rstart = fn.search(pats, 'bcnW')
    local rend = fn.search(pate, 'cnW')
    if rstart == 0 then
        rstart = 1
    end
    if rend == 0 then
        rend = fn.line('$')
    end
    return {rstart, rend}
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

return M
