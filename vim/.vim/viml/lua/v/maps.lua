local M = {}

local setmap = vim.keymap.set
local function setopts(opts, defaults)
    local map_opts = {}
    for k, v in pairs(opts) do
        if type(k) == 'string' then
            map_opts[k] = v
        end
    end
    if defaults then
        map_opts = vim.tbl_extend('keep', map_opts, defaults)
    end
    return map_opts
end

-- map functions
-- * 'map' and 'mnore' works at normal and visual mode by default here
-- * example:
--      local m = require('v.maps')
--      m.nore{'<leader>', ':echo b:<CR>', silent = true, buffer = 9}
--      m.add({'n', 'v'}, {'<leader>', ':echo b:<CR>', buffer = true})
-- @mods Mapping mode
-- @opts Mapping option with {lhs, rhs, **kwargs}
function M.map(opts)   setmap({'n', 'v'}, opts[1], opts[2], setopts(opts, { remap = true })) end
function M.nmap(opts)  setmap('n', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.vmap(opts)  setmap('v', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.xmap(opts)  setmap('x', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.smap(opts)  setmap('s', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.omap(opts)  setmap('o', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.imap(opts)  setmap('i', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.lmap(opts)  setmap('l', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.cmap(opts)  setmap('c', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.tmap(opts)  setmap('t', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.nore(opts)  setmap({'n', 'v'}, opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.nnore(opts) setmap('n', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.vnore(opts) setmap('v', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.xnore(opts) setmap('x', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.snore(opts) setmap('s', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.onore(opts) setmap('o', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.inore(opts) setmap('i', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.lnore(opts) setmap('l', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.cnore(opts) setmap('c', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.tnore(opts) setmap('t', opts[1], opts[2], setopts(opts, { noremap = true })) end

function M.add(mods, opts)     setmap(mods, opts[1], opts[2], setopts(opts, { remap = true })) end
function M.addnore(mods, opts) setmap(mods, opts[1], opts[2], setopts(opts, { noremap = true })) end

return M
