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
