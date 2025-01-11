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
    return str
        :gsub('\r', '') -- Remove ^M
        :gsub('\x1b%].*[\x07\x9c]', '') -- Remove all OSC code
        :gsub('\x1b%[[\x30-\x3f]*[\x20-\x2f]*[\x40-\x7e]', '') -- Remove all CSI code
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

--- Generate next line that ends with '\r'
--- @param str(string)
--- @yield line(string) The matched line ends with '\r'
local function next_cr(str)
    local ci = 1

    return function()
        if ci < 0 then
            return nil
        end
        local si, ei = string.find(str, '[^\r]*\r', ci)
        if si then
            local line = string.sub(str, ci, ei)
            ci = ei + 1
            return line
        else
            local line = string.sub(str, ci)
            ci = -1
            return line
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
        elseif args == '21' or args == '22' then
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
    local bufc = { '', {} } -- Processed buffer cache lines
    local cnt = 1 -- Buffer line counter
    local bot = 1 -- The bottom buffer line in terminal window
    local wid = vim.o.columns
    local hei = vim.o.lines
    local sgr = new_sgr()

    -- ANSI object
    local ansi = {}

    --- Create next buffer line
    --- @param buf(string|nil) The processed buffer line
    --- @param hlt(table|nil) The highlight of a processed buffer line
    --- @param opts(table|nil)
    --- @return integer row The row of buffer line to process
    --- @return string buf The buffer line to process
    --- @return table hlt The highlight of buffer line to process
    local function nextline(buf, hlt, opts)
        local completed = opts and opts.completed
        if buf and hlt then
            if completed then
                bufs[#bufs + 1] = { buf, hlt }
                if bot < hei then
                    -- There should always `bot <= hei` as terminal window lines = `hei`
                    bot = bot + 1
                    local cell_len = vim.fn.strdisplaywidth(buf)
                    if cell_len > wid then
                        bot = bot + math.floor(cell_len / wid)
                    end
                    bot = math.min(bot, hei)
                end
                -- Override `bufc` directly as `buf` and `hlt` contain previous `bufc`
                bufc = { '', {} }
            else
                bufc = { buf, hlt }
            end
        end
        return #bufs + 1, bufc[1], bufc[2]
    end

    --- Backtrace previous buffer line
    --- @param buf(string) The processed buffer line
    --- @param hlt(table) The highlight of a processed buffer line
    --- @return integer row The row of buffer line to process
    --- @return string buf The buffer line to process
    --- @return table hlt The highlight of buffer line to process
    local function prevline(buf, hlt)
        local _buf, _hlt = unpack(bufs[#bufs])
        bufs[#bufs] = nil
        return #bufs + 1, _buf .. buf, vim.list_extend(_hlt, hlt)
    end

    ansi.bufs = function() return bufs end

    ansi.feed = function(linestr, verbose)
        local verb_h = verbose:match('[ah]')
        local verb_r = verbose:match('[ar]')

        if verb_r then
            bufs[#bufs + 1] = { ('> line=%d'):format(cnt), {} }
            bufs[#bufs + 1] = { linestr, {} } -- May populate `bufs` used by `prevline()`
            cnt = cnt + 1
        end

        local row, buf, hlt = nextline()
        for _, line, args, byte in next_csi(linestr, CSI_PAT) do
            -- Process CSI SGR
            for separated in next_cr(line) do
                local trimed = trim(separated)
                if trimed ~= '' then
                    local cs = string.len(buf) -- col_start
                    local ce = cs + string.len(trimed) -- col_end
                    if sgr.hl then
                        hlt[#hlt + 1] = { sgr.hl, row, cs, ce }
                        if verb_h then
                            trimed = trimed .. ('<%d,%d,%d>'):format(row, cs, ce)
                        end
                    end
                    buf = buf .. trimed
                end
                row, buf, hlt = nextline(buf, hlt, { completed = separated:match('.*\r$') })
            end
            if byte == 'm' then
                sgr.tohl(args)
            end

            -- Process CSI
            if byte == 'C' then
                local n = (args ~= '') and tonumber(args) or 1
                buf = buf .. string.rep(' ', n)
            elseif byte == 'K' then
                -- n = 0: clear from cursor to end of line
                -- n = 1: clear from cursor to begin of line
                -- n = 2: clear entire line
                -- local n = (args ~= '') and tonumber(args) or 0
            elseif byte == 'H' then
                local nr, nc = args:match('(%d*);?(%d*)')
                nr = (nr ~= '') and tonumber(nr) or 1
                nc = (nc ~= '') and tonumber(nc) or 1
                while bot < nr do
                    row, buf, hlt = nextline(buf, hlt, { completed = true })
                end
                if bot == nr + 1 then
                    bot = bot - 1 -- Support backtrace one buffer line had been processed
                    row, buf, hlt = prevline(buf, hlt)
                end
                local cell_len = vim.fn.strdisplaywidth(buf)
                if cell_len < (nc - 1) then
                    buf = buf .. string.rep(' ', nc - 1 - cell_len)
                else
                    buf = string.sub(buf, 1, nc - 1) -- Don't support multi-bytes char
                end
            end
        end
    end

    return ansi
end

return { new = new }
