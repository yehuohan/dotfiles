-- Neovim lua library

local M = {}

function M.new_config(opt)
    if type(opt) ~= 'table' then
        error('Initial config shoule be a table')
    end

    -- Create initial values
    local initialization = vim.deepcopy(opt)

    -- Config's non-savable options
    local non_savable_config = function()
        local nsc = {}
        nsc.__index = nsc
        return nsc
    end

    -- Config's methods
    local C = {}
    setmetatable(C, non_savable_config())
    C.__index = C
    C.__newindex = function(t, k, v)
        if rawget(t, k) then
            -- New savable option
            rawset(t, k, v)
        elseif rawget(C, k) then
            error(string.format('The key "%s" is a config method that should not be modified', k))
        else
            -- New non-savable option
            -- C == getmetatable(t)
            -- nsc == getmetatable(C)
            getmetatable(getmetatable(t))[k] = v
        end
    end

    -- Add an option to config
    function C:add(k, v)
        rawset(self, k, v)
        initialization[k] = v
    end

    -- Delete an option from config
    function C:del(k)
        rawset(self, k, nil)
        initialization[k] = nil
    end

    -- Setup config's current options
    -- All savable options will be extend with new_opt;
    -- All non-savable options will be keeped.
    function C:set(new_opt)
        for k, v in pairs(new_opt) do
            if type(v) == 'table' then
                rawset(self, k, vim.deepcopy(new_opt[k]))
            else
                rawset(self, k, v)
            end
        end
    end

    -- Reinit config's options
    -- The initial options will be repleaced with init_opt;
    -- All savable options will be cleared first, then reinited with init_opt;
    -- All non-savable options will be cleared.
    function C:reinit(init_opt)
        if init_opt then
            initialization = vim.deepcopy(init_opt)
        end
        for k, _ in pairs(self) do
            rawset(self, k, nil)
        end
        self:set(initialization)
        -- C == getmetatable(self)
        setmetatable(C, non_savable_config())
    end

    return setmetatable(opt, C)
end

return M
