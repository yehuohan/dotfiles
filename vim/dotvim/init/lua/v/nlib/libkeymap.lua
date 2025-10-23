--- @class NLib.libkeymap
local M = {}

local delmap = vim.keymap.del
local setmap = vim.keymap.set

--- Setup options for setmap and delmap
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

--- @class keymap.Opts Mapping options with {lhs, rhs, **kwargs}
--- @field [1] string The mapping lhs
--- @field [2] string|function The mapping rhs
--- @field remap boolean|nil
--- @field noremap boolean|nil
--- @field buffer integer|nil

--- Keymap functions
---
--- * 'map' and 'nore' works at 'n', 'v' and 'o'
--- * 'v' includes both 'x' and 's'
--- * avoid mapping a-z in 's' mode, which breaks editing placeholder selection of snippet/completion
---
--- ```lua
---      local m = require('v.nlib').m
---      m.add({'n', 'v'}, {'<leader>', ':echo b:<CR>', buffer = true})
---      m.del({'n', 'v'}, {'<leader>', buffer = true})
---      m.nnore{'<leader>', ':echo b:<CR>', silent = true, buffer = 9}
---      m.ndel{'<leader>', buffer = 9}
--- ```
--- @param mods string|string[] Mapping modes
--- @param opts keymap.Opts
-- stylua: ignore start
function M.del(mods, opts)     delmap(mods, opts[1], setopts(opts)) end
function M.add(mods, opts)     setmap(mods, opts[1], opts[2], setopts(opts, { remap = true })) end
function M.addnore(mods, opts) setmap(mods, opts[1], opts[2], setopts(opts, { noremap = true })) end

function M.ndel(opts)   delmap('n', opts[1], setopts(opts)) end
function M.vdel(opts)   delmap('v', opts[1], setopts(opts)) end
function M.xdel(opts)   delmap('x', opts[1], setopts(opts)) end
function M.sdel(opts)   delmap('s', opts[1], setopts(opts)) end
function M.odel(opts)   delmap('o', opts[1], setopts(opts)) end
function M.idel(opts)   delmap('i', opts[1], setopts(opts)) end
function M.ldel(opts)   delmap('l', opts[1], setopts(opts)) end
function M.cdel(opts)   delmap('c', opts[1], setopts(opts)) end
function M.tdel(opts)   delmap('t', opts[1], setopts(opts)) end
function M.map(opts)    setmap({'n', 'v', 'o'}, opts[1], opts[2], setopts(opts, { remap = true })) end
function M.nvmap(opts)  setmap({'n', 'v'}, opts[1], opts[2], setopts(opts, { remap = true })) end
function M.nxmap(opts)  setmap({'n', 'x'}, opts[1], opts[2], setopts(opts, { remap = true })) end
function M.nmap(opts)   setmap('n', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.vmap(opts)   setmap('v', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.xmap(opts)   setmap('x', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.smap(opts)   setmap('s', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.omap(opts)   setmap('o', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.imap(opts)   setmap('i', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.lmap(opts)   setmap('l', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.cmap(opts)   setmap('c', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.tmap(opts)   setmap('t', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.nore(opts)   setmap({'n', 'v', 'o'}, opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.nvnore(opts) setmap({'n', 'v'}, opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.nxnore(opts) setmap({'n', 'x'}, opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.nnore(opts)  setmap('n', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.vnore(opts)  setmap('v', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.xnore(opts)  setmap('x', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.snore(opts)  setmap('s', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.onore(opts)  setmap('o', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.inore(opts)  setmap('i', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.lnore(opts)  setmap('l', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.cnore(opts)  setmap('c', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.tnore(opts)  setmap('t', opts[1], opts[2], setopts(opts, { noremap = true })) end
-- stylua: ignore end

return M
