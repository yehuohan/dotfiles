-- vim:fdm=marker
local map = vim.api.nvim_set_keymap


-- Search {{{
map('n', '<leader><Esc>'    , [[:nohlsearch<CR>]] , { noremap = true })
map('n', 'i'                , [[:nohlsearch<CR>i]], { noremap = true })
map('n', '<leader>8'        , [[*]]               , { noremap = true })
map('n', '<leader>3'        , [[#]]               , { noremap = true })
map('v', '<leader>8'        , [[/\V\c\<<C-r>=escape(v:lua.require'user.libs'.get_selected(''), '\/')<CR>\><CR>]], { noremap = true })
map('v', '<leader>3'        , [[?\V\c\<<C-r>=escape(v:lua.require'user.libs'.get_selected(''), '\/')<CR>\><CR>]], { noremap = true })
map('n', '<leader>/'        , [[/\V\c<C-r><C-w><CR>]], { noremap = true })
map('v', '<leader>/'        , [[/\V\c<C-r>=escape(v:lua.require'user.libs'.get_selected(''), '\/')<CR><CR>]], { noremap = true })
map('n', '<leader><leader>/', [[/<C-r><C-w>]], { noremap = true })
map('v', '<leader><leader>/', [[/<C-r>=v:lua.require'user.libs'.get_selected('')<CR>]], { noremap = true })
-- }}}
