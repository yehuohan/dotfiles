local M = {}

--  跳转到下一个floating窗口
function M.win_goto_next_floating()
end

-- 移动窗口的分界，改变窗口大小
-- 只有最bottom-right的窗口是移动其top-left的分界，其余窗口移动其bottom-right分界
function M.win_move_spliter(dir, inc)
end

function M.setup()
    vim.api.nvim_command[[source $DotVimPath/lua/v/maps.vim]]
end

return M
