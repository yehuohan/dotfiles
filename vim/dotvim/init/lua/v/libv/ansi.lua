local M = {}

M.CSI = {
    -- K: erase in line
    -- H: set cursor position
    Line = '\x1b%[([%d:;<=>%?]*)([KH])',
    -- m: set SGR(Select Graphic Rendition)
    Color = '\x1b%[([%d:;<=>%?]*)(m)',
}

function M.trim(str)
    return str
        :gsub('\x1b%].*[\x07\x9c]', '') -- Remove all OSC code
        :gsub('\x1b%[[%d:;<=>%?]*[a-zA-Z]', '') -- Remove all CSI code
end

--- Generate next line that ends with a CSI(Control Sequence Introducer) code
--- @param pat(string) One of the CSI pattern
--- @retval last(boolean) Indicate the last valid match
--- @retval line(string) The matched line ends with a CSI code
--- @retval args(string) CSI args
--- @retval byte(string) CSI final byte
function M.next_csi(str, pat)
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

return M
