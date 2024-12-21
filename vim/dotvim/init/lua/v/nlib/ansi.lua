--- CSI(Control Sequence Introducer) pattern
--- A: move cursor up
--- B: move cursor down
--- C: move cursor forward
--- D: move cursor back
--- H: set cursor position
--- K: erase in line
--- m: set SGR(Select Graphic Rendition)
local CSI_PAT = '\x1b%[([%d:;<=>%?]*)([CHKm])'

--- Basic SGR color codes
--- * fg = 30~37, 38, 90~97
--- * bg = 40~47, 48, 100~107
local CSI_SGR = {
    hls = {},
    fgcolors = {
        ['30'] = '#1e1e1e', --'#000000',
        ['31'] = '#cc241d', --'#800000',
        ['32'] = '#98971a', --'#008000',
        ['33'] = '#d79921', --'#808000',
        ['34'] = '#458588', --'#000080',
        ['35'] = '#b16286', --'#800080',
        ['36'] = '#689d6a', --'#008080',
        ['37'] = '#ebdbb2', --'#c0c0c0',
        ['90'] = '#928374', --'#808080',
        ['91'] = '#fb4934', --'#ff0000',
        ['92'] = '#b8bb26', --'#00ff00',
        ['93'] = '#fabd2f', --'#ffff00',
        ['94'] = '#83a598', --'#0000ff',
        ['95'] = '#d3869b', --'#ff00ff',
        ['96'] = '#8ec07c', --'#00ffff',
        ['97'] = '#ebdbb2', --'#ffffff',
    },
    bgcolors = {
        ['40'] = '#1e1e1e', --'#000000',
        ['41'] = '#cc241d', --'#800000',
        ['42'] = '#98971a', --'#008000',
        ['43'] = '#d79921', --'#808000',
        ['44'] = '#458588', --'#000080',
        ['45'] = '#b16286', --'#800080',
        ['46'] = '#689d6a', --'#008080',
        ['47'] = '#ebdbb2', --'#c0c0c0',
        ['100'] = '#928374', --'#808080',
        ['101'] = '#fb4934', --'#ff0000',
        ['102'] = '#b8bb26', --'#00ff00',
        ['103'] = '#fabd2f', --'#ffff00',
        ['104'] = '#83a598', --'#0000ff',
        ['105'] = '#d3869b', --'#ff00ff',
        ['106'] = '#8ec07c', --'#00ffff',
        ['107'] = '#ebdbb2', --'#ffffff',
    },
}

local function trim(str)
    -- Complete CSI: '\x1b%[[\x30-\x3f]*[\x20-\x2f]*[\x40-\x7e]'
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

local function new_sgr()
    local opts = {
        fg = nil,
        bg = nil,
        bold = false,
        italic = false,
        underline = false,
        strikethrough = false,
        reverse = false,
    }
    local sgr = { hl = nil }

    sgr.tohl = function(args)
        if args == '' or args == '0' then
            sgr.hl = nil
            opts.fg = nil
            opts.bg = nil
            opts.bold = false
            opts.italic = false
            opts.underline = false
            opts.strikethrough = false
            opts.reverse = false
            return
        end
        if args == '1' then
            opts.bold = true
        elseif args == '21' then
            opts.bold = false
        elseif args == '3' then
            opts.italic = true
        elseif args == '23' then
            opts.italic = false
        elseif args == '4' then
            opts.underline = true
        elseif args == '24' then
            opts.underline = false
        elseif args == '9' then
            opts.strikethrough = true
        elseif args == '29' then
            opts.strikethrough = false
        elseif args == '7' then
            opts.reverse = true
        elseif args == '27' then
            opts.reverse = false
        end

        -- Get foreground color code
        local fc = args:match('38;5;(%d*)')
        if fc then
            local n = tonumber(fc)
            fc = n <= 7 and tostring(30 + n) or tostring(90 + n - 8)
        else
            fc = args
        end
        if CSI_SGR.fgcolors[fc] then
            opts.fg = CSI_SGR.fgcolors[fc]
        end

        -- Get background color code
        local bc = args:match('48;5;(%d*)')
        if bc then
            local n = tonumber(bc)
            bc = n <= 7 and tostring(30 + n) or tostring(90 + n - 8)
        else
            bc = args
        end
        if CSI_SGR.bgcolors[bc] then
            opts.bg = CSI_SGR.bgcolors[bc]
        end

        -- Create highlights
        local key = '.'
            .. (opts.fg and string.sub(opts.fg, 2) or 'n')
            .. '.'
            .. (opts.bg and string.sub(opts.bg, 2) or 'n')
            .. '.'
            .. (opts.bold and '1' or '0')
            .. (opts.italic and '1' or '0')
            .. (opts.underline and '1' or '0')
            .. (opts.strikethrough and '1' or '0')
            .. (opts.reverse and '1' or '0')
        if CSI_SGR.hls[key] then
            sgr.hl = CSI_SGR.hls[key]
        else
            sgr.hl = 'v.nlib.ansi' .. key
            vim.api.nvim_set_hl(0, sgr.hl, opts)
            CSI_SGR.hls[key] = sgr.hl
        end
    end

    return sgr
end

local function new()
    local bufs = {} -- Processed buffer lines
    local hlts = {} -- Processed highlights
    local srow = 1 -- Cursor position row
    -- local scol = 1 -- Cursor position col
    local erased_lines = 0 -- Erased lines should be displayed too
    local sgr = new_sgr()

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
        sgr = new_sgr()
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
                    if sgr.hl then
                        s_hl[#s_hl + 1] = { sgr.hl, srow, cs, ce }
                        if verb_h then
                            trimed = trimed .. ('<%d,%d,%d>'):format(srow, cs, ce)
                        end
                    end
                    bufs[srow] = s_line .. trimed
                    hlts[srow] = s_hl
                end
            end

            if byte then
                has_csi = true
            end

            -- Process CSI code
            if byte == 'C' then
                local n = (args ~= '') and tonumber(args) or 1
                bufs[srow] = (bufs[srow] or '') .. string.rep(' ', n)
            elseif byte == 'K' then
                -- n = 0: clear from cursor to end of line
                -- n = 1: clear from cursor to begin of line
                -- n = 2: clear entire line
                -- local n = (args ~= '') and tonumber(args) or 0
                erased_lines = erased_lines + 1
                if bufs[srow] then
                    srow = srow + 1
                    bufs[srow] = verb_n and ('K%d>'):format(srow)
                end
            elseif byte == 'H' then
                local cur_row, cur_col = args:match('(%d*);?(%d*)')
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
                sgr.tohl(args)
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
