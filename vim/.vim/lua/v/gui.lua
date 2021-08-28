local fn = vim.fn
local use = require('v.use').get()
local noremap = require('v.libs').keymap.noremap
local nnoremap = require('v.libs').keymap.nnoremap
local inoremap = require('v.libs').keymap.inoremap


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
        noremap{'<RightMouse>' , [[<Cmd>call GuiShowContextMenu()<CR>]]                       }
        inoremap{'<RightMouse>', [[<Cmd>call GuiShowContextMenu()<CR>]]                       }
        nnoremap{'<leader>tf'  , [[<Cmd>call GuiWindowFullScreen(!g:GuiWindowFullScreen)<CR>]]}
        nnoremap{'<leader>tm'  , [[<Cmd>call GuiWindowMaximized(!g:GuiWindowMaximized)<CR>]]  }
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

    nnoremap{'<k0>'    , [[:lua require('v.gui').setfonts(0)<CR>]] }
    nnoremap{'<kPlus>' , [[:lua require('v.gui').setfonts(1)<CR>]] }
    nnoremap{'<kMinus>', [[:lua require('v.gui').setfonts(-1)<CR>]]}
end

return {
    setup = gui_setup,
    setfonts = gui_setfonts,
    neovimqt = gui_neovimqt,
}
