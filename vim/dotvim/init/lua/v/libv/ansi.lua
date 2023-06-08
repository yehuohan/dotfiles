--- CSI(Control Sequence Introducer) pattern
--- K: erase in line
--- H: set cursor position
--- m: set SGR(Select Graphic Rendition)
local CSI_PAT = '\x1b%[([%d:;<=>%?]*)([KHm])'

local function trim(str)
    return str
        :gsub('\x1b%].*[\x07\x9c]', '') -- Remove all OSC code
        :gsub('\x1b%[[%d:;<=>%?]*[a-zA-Z]', '') -- Remove all CSI code
end

--- Generate next line that ends with a CSI code
--- @param pat(string) One of the CSI pattern
--- @retval last(boolean) Indicate the last valid match
--- @retval line(string) The matched line ends with a CSI code
--- @retval args(string) CSI args
--- @retval byte(string) CSI final byte
local function next_csi(str, pat)
    local len = string.len(str)
    local ci = 1

    return function()
        if ci < 0 then
            return nil
        end
        local si, ei, args, byte = string.find(str, pat, ci)
        local last = nil
        if si then
            local line = string.sub(str, ci, ei)
            ci = ei + 1
            last = (ci > len)
            return last, line, args, byte
        else
            local line = string.sub(str, ci)
            ci = -1
            last = true
            return last, line
        end
    end
end

local function sgr2hl(args)
    if args == '' or args == '0' then
        return nil
    end

    -- TODO: vim.api.nvim_set_hl
    local hl = { }
    if args == '1' then
        hl.bold = true
    elseif args == '3' then
        hl.italic = true
    end
    return 'Identifier'
end

local function new()
    local bufs = {} -- Processed buffer lines
    local hlts = {} -- Processed highlights
    local srow = 1 -- Cursor position row
    -- local scol = 1 -- Cursor position col
    local erased_lines = 0 -- Erased lines should be displayed too
    local hlgrp = nil -- Cursor highlight group from SGR

    -- ANSI object
    local ansi = {}

    ansi.bufs = function() return bufs end

    ansi.hlts = function() return hlts end

    ansi.reset = function()
        bufs = {}
        hlts = {}
        srow = 1
        -- scol = 1
        erased_lines = 0
        hlgrp = nil
    end

    ansi.feed = function(str, is_pending)
        for last, line, args, byte in next_csi(str, CSI_PAT) do
            -- The rest pending line shouldn't append into buffer lines
            if is_pending and last then
                return line
            end

            -- Process line with highlight
            if line ~= '' then
                local s_line = bufs[srow] or ''
                local s_hl = hlts[srow] or {}
                local trimed = trim(line)
                local cs = string.len(s_line) -- col_start
                local ce = cs + string.len(trimed) -- col_end
                if hlgrp then
                    s_hl[#s_hl + 1] = { hlgrp, srow, cs, ce }
                end
                -- trimed = trimed .. ('(%d,%d,%d)'):format(srow, cs, ce)
                bufs[srow] = s_line .. trimed
                hlts[srow] = s_hl
            end

            -- Process CSI code
            if byte == 'K' then
                -- TODO: local n = string.match(args, '(%d)K')
                erased_lines = erased_lines + 1
                srow = srow + 1
            elseif byte == 'H' then
                local cur_row, cur_col = string.match(args, '(%d*);?(%d*)')
                cur_row = (cur_row ~= '') and tonumber(cur_row) or 1
                cur_col = (cur_col ~= '') and tonumber(cur_col) or 1
                cur_row = cur_row + erased_lines
                while srow < cur_row do
                    srow = srow + 1
                    bufs[srow] = ''
                end
                while srow > cur_row do
                    bufs[srow] = nil
                    srow = srow - 1
                end
                bufs[srow] = string.rep(' ', cur_col - 1)
            elseif byte == 'm' then
                hlgrp = sgr2hl(args)
            end
        end

        -- For next new line
        srow = srow + 1
    end

    return ansi
end

return {
    new = new,
}
