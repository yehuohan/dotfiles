-- vim:fdm=marker
local map = vim.api.nvim_set_keymap


-- Search {{{
map('n', '<leader><Esc>', [[:nohlsearch<CR>]] , { noremap = true })
map('n', 'i'            , [[:nohlsearch<CR>i]], { noremap = true })
map('n', '<leader>8'    , [[*]]               , { noremap = true })
map('n', '<leader>3'    , [[#]]               , { noremap = true })
map('v', '<leader>8',
    [["9y<Bar>:execute '/\V\c\<' . escape(@9, '\/') . '\>'<CR>]],
    { noremap = true, silent = true })
map('v', '<leader>3',
    [["9y<Bar>:execute '?\V\c\<' . escape(@9, '\/') . '\>'<CR>]],
    { noremap = true, silent = true })
map('v', '<leader>/',
    [["9y<Bar>:execute '/\V\c' . escape(@9, '\/')<CR>]],
    { noremap = true, silent = true })
map('n', '<leader>/',
    [[:execute '/\V\c' . escape(expand('<cword>'), '\/')<CR>]],
    { noremap = true, silent = true })
map('v', '<leader><leader>/',
    [[:call feedkeys('/' . v:lua.require'user.libs'.get_selected(), 'n')<CR>]],
    { noremap = true, silent = true })
-- }}}
