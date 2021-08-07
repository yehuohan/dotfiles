local fn = vim.fn
local map = vim.api.nvim_set_keymap
local use = require('v.use').use


-- Init font and font size
local gui_fontsize = 12
local gui_font = ''
local gui_fontwide = ''
if IsWin() then
    if use.powerfont
    then gui_font = 'Consolas For Powerline'
    else gui_font = 'Consolas'
    end
    gui_fontwide = 'Microsoft YaHei UI'
else
    if use.powerfont
    then gui_font = 'DejaVu Sans Mono for Powerline'
    else gui_font = 'DejaVu Sans'
    end
    gui_fontwide = 'WenQuanYi Micro Hei Mono'
end

local function adjust_fontsize(inc)
    gui_fontsize = gui_fontsize + inc
    vim.o.guifont = gui_font .. ':h' .. tostring(gui_fontsize)
    vim.o.guifontwide = gui_fontwide .. ':h' .. tostring(gui_fontsize - 1)
end

-- Set gui of Neovim-qt
vim.cmd[[
augroup UserSettingsGui
    autocmd!
    autocmd UIEnter * :lua require('v.gui').set_gui_neovimqt()
augroup END
]]

local function set_gui_neovimqt()
    -- 在UIEnter之后才起作用
    if fn.exists('g:GuiLoaded') == 1 then
        adjust_fontsize(0)
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

return {
    set_gui_neovimqt = set_gui_neovimqt,
}
