local M = {}

--------------------------------------------------------------------------------
--[[
local map      = require('v.maps').map
local nmap     = require('v.maps').nmap
local vmap     = require('v.maps').vmap
local xmap     = require('v.maps').xmap
local smap     = require('v.maps').smap
local omap     = require('v.maps').omap
local imap     = require('v.maps').imap
local lmap     = require('v.maps').lmap
local cmap     = require('v.maps').cmap
local tmap     = require('v.maps').tmap
local noremap  = require('v.maps').noremap
local nnoremap = require('v.maps').nnoremap
local vnoremap = require('v.maps').vnoremap
local xnoremap = require('v.maps').xnoremap
local snoremap = require('v.maps').snoremap
local onoremap = require('v.maps').onoremap
local inoremap = require('v.maps').inoremap
local lnoremap = require('v.maps').lnoremap
local cnoremap = require('v.maps').cnoremap
local tnoremap = require('v.maps').tnoremap
--]]
--------------------------------------------------------------------------------
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

-- map works at normal and visual mode by default here
function M.map(opts)      setmap({'n', 'v'},  opts[1], opts[2], setopts(opts, { remap = true })) end
function M.nmap(opts)     setmap('n', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.vmap(opts)     setmap('v', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.xmap(opts)     setmap('x', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.smap(opts)     setmap('s', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.omap(opts)     setmap('o', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.imap(opts)     setmap('i', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.lmap(opts)     setmap('l', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.cmap(opts)     setmap('c', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.tmap(opts)     setmap('t', opts[1], opts[2], setopts(opts, { remap = true })) end
function M.noremap(opts)  setmap({'n', 'v'},  opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.nnoremap(opts) setmap('n', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.vnoremap(opts) setmap('v', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.xnoremap(opts) setmap('x', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.snoremap(opts) setmap('s', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.onoremap(opts) setmap('o', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.inoremap(opts) setmap('i', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.lnoremap(opts) setmap('l', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.cnoremap(opts) setmap('c', opts[1], opts[2], setopts(opts, { noremap = true })) end
function M.tnoremap(opts) setmap('t', opts[1], opts[2], setopts(opts, { noremap = true })) end

return M
