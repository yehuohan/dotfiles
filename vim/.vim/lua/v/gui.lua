local fn = vim.fn
local map = vim.api.nvim_set_keymap
local use = require('v.use').get()


local function gui_setfonts(inc)
    use.ui.fontsize = use.ui.fontsize + inc
    use.ui.widesize = use.ui.widesize + inc
    vim.o.guifont = use.ui.font .. ':h' .. tostring(use.ui.fontsize)
    vim.o.guifontwide = use.ui.wide .. ':h' .. tostring(use.ui.widesize)
end

local function gui_neovimqt()
    -- 在UIEnter之后才起作用
    if fn.exists('g:GuiLoaded') == 1 then
        gui_setfonts(0)
        vim.cmd[[
            GuiLinespace 0
            GuiTabline 0
            GuiPopupmenu 0
        ]]
        map('' , '<RightMouse>', [[<Cmd>call GuiShowContextMenu()<CR>]]                       , { noremap = true })
        map('i', '<RightMouse>', [[<Cmd>call GuiShowContextMenu()<CR>]]                       , { noremap = true })
        map('n', '<leader>tf'  , [[<Cmd>call GuiWindowFullScreen(!g:GuiWindowFullScreen)<CR>]], { noremap = true })
        map('n', '<leader>tm'  , [[<Cmd>call GuiWindowMaximized(!g:GuiWindowMaximized)<CR>]]  , { noremap = true })
    end
end

local function gui_setup()
    -- Set gui of Neovim-qt
    vim.cmd[[
    augroup UserSettingsGui
        autocmd!
        autocmd UIEnter * :lua require('v.gui').neovimqt()
    augroup END
    ]]

    vim.o.guicursor =
        [[n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50]] ..
        [[,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor]] ..
        [[,sm:block-blinkwait175-blinkoff150-blinkon175]]

    map('n', '<k0>'    , [[:lua require('v.gui').setfonts(0)<CR>]] , { noremap = true })
    map('n', '<kPlus>' , [[:lua require('v.gui').setfonts(1)<CR>]] , { noremap = true })
    map('n', '<kMinus>', [[:lua require('v.gui').setfonts(-1)<CR>]], { noremap = true })
end

return {
    setup = gui_setup,
    setfonts = gui_setfonts,
    neovimqt = gui_neovimqt,
}
