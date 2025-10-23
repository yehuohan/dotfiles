--- @class NLib.libasync Async functions
local M = {}

M._await = coroutine.yield

function M._async(func)
    return function(...) coroutine.wrap(func)(...) end
end

function M._wrap(afunc)
    return function(...)
        local caller = coroutine.running()
        local args = { ... }
        -- Place async function's callback at the last by default
        table.insert(args, function(...)
            -- Callback args will passed to `res = await()` from resume
            coroutine.resume(caller, ...)
        end)
        coroutine.wrap(afunc)(unpack(args))
    end
end

return M
