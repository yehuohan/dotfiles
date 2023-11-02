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
--- @yield last(boolean) Indicate the last valid match
--- @yield line(string) The matched line ends with a CSI code
--- @yield args(string) CSI args
--- @yield byte(string) CSI final byte
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
    local hl = {}
    if args == '1' then
        hl.bold = true
    elseif args == '3' then
        hl.italic = true
    end
    return 'Special'
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

    ansi.feed = function(linestr, is_pending, verbose)
        local verb_t = verbose:match('[at]')
        local verb_h = verbose:match('[ah]')
        local verb_n = verbose:match('[an]')
        local has_csi = false
        for last, line, args, byte in next_csi(linestr, CSI_PAT) do
            -- The rest pending line shouldn't append into buffer lines
            if is_pending and last then
                return line
            end

            -- Process line with highlight
            if line ~= '' then
                local trimed = verb_t and line or trim(line)
                if trimed ~= '' then
                    local s_line = bufs[srow] or (verb_n and ('#%d>'):format(srow) or '')
                    local s_hl = hlts[srow] or {}
                    local cs = string.len(s_line) -- col_start
                    local ce = cs + string.len(trimed) -- col_end
                    if hlgrp then
                        s_hl[#s_hl + 1] = { hlgrp, srow, cs, ce }
                    end
                    if verb_h then
                        trimed = trimed .. ('<%d,%d,%d>'):format(srow, cs, ce)
                    end
                    bufs[srow] = s_line .. trimed
                    hlts[srow] = s_hl
                end
            end

            if byte then
                has_csi = true
            end

            -- Process CSI code
            if byte == 'K' then
                -- n = 0: clear from cursor to end of line
                -- n = 1: clear from cursor to begin of line
                -- n = 2: clear entire line
                -- local n = string.match(args, '(%d)K')
                -- n = (n ~= '') and tonumber(n) or 0
                erased_lines = erased_lines + 1
                if bufs[srow] then
                    srow = srow + 1
                    bufs[srow] = verb_n and ('K%d>'):format(srow)
                end
            elseif byte == 'H' then
                local cur_row, cur_col = string.match(args, '(%d*);?(%d*)')
                cur_row = (cur_row ~= '') and tonumber(cur_row) or 1
                cur_col = (cur_col ~= '') and tonumber(cur_col) or 1
                cur_col = cur_col - 1 -- The cursor cell will also be filled with the inputs
                cur_row = cur_row + erased_lines
                -- Sync cursor row
                while srow < cur_row do
                    bufs[srow] = bufs[srow] or (verb_n and ('H%d>'):format(srow) or '')
                    srow = srow + 1
                end
                while srow > cur_row do
                    bufs[srow] = verb_n and ((bufs[srow] or '') .. ('H%d<'):format(srow))
                    srow = srow - 1
                end
                -- Sync cursor col
                if bufs[srow] then
                    if verb_n then
                        bufs[srow] = bufs[srow] .. '&' .. string.rep('%', cur_col)
                    else
                        local dlen = string.len(bufs[srow]) -- Displayed length
                        bufs[srow] = bufs[srow]:sub(1, cur_col) .. string.rep(' ', cur_col - dlen)
                    end
                else
                    bufs[srow] = string.rep(verb_n and '%' or ' ', cur_col)
                end
            elseif byte == 'm' then
                hlgrp = sgr2hl(args)
            end
        end

        -- For next new line
        if bufs[srow] then
            srow = srow + 1
            bufs[srow] = verb_n and ('$%d>'):format(srow)
        elseif linestr ~= '' and not has_csi then
            bufs[srow] = verb_n and ('$%d>'):format(srow) or ''
            srow = srow + 1
        end
    end

    return ansi
end

return { new = new }
