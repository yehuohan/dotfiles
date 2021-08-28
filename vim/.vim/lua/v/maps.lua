local nnoremap = require('v.libs').keymap.nnoremap
local vnoremap = require('v.libs').keymap.vnoremap


local function maps_search()
    nnoremap{'<leader><Esc>'    , [[:nohlsearch<CR>]] }
    nnoremap{'i'                , [[:nohlsearch<CR>i]]}
    nnoremap{'<leader>8'        , [[*]]               }
    nnoremap{'<leader>3'        , [[#]]               }
    vnoremap{'<leader>8'        , [[/\V\c\<<C-r>=escape(v:lua.require'v.libs'.get_selected(''), '\/')<CR>\><CR>]]}
    vnoremap{'<leader>3'        , [[?\V\c\<<C-r>=escape(v:lua.require'v.libs'.get_selected(''), '\/')<CR>\><CR>]]}
    nnoremap{'<leader>/'        , [[/\V\c<C-r><C-w><CR>]]                                                        }
    vnoremap{'<leader>/'        , [[/\V\c<C-r>=escape(v:lua.require'v.libs'.get_selected(''), '\/')<CR><CR>]]    }
    nnoremap{'<leader><leader>/', [[/<C-r><C-w>]]                                                                }
    vnoremap{'<leader><leader>/', [[/<C-r>=v:lua.require'v.libs'.get_selected('')<CR>]]                          }
end

return {
    setup = function()
        maps_search()
    end
}
