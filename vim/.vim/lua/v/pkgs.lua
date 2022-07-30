local fn = vim.fn
local g = vim.g
local use = require('v.use').get()
local map      = require('v.mods').keymap.map
local nmap     = require('v.mods').keymap.nmap
local vmap     = require('v.mods').keymap.vmap
local xmap     = require('v.mods').keymap.xmap
local omap     = require('v.mods').keymap.omap
local noremap  = require('v.mods').keymap.noremap
local nnoremap = require('v.mods').keymap.nnoremap
local vnoremap = require('v.mods').keymap.vnoremap
local xnoremap = require('v.mods').keymap.xnoremap


local function pkgs_standard()
    g.loaded_gzip = 1
    g.loaded_tarPlugin = 1
    g.loaded_tar = 1
    g.loaded_zipPlugin = 1
    g.loaded_zip = 1
    g.loaded_netrw = 1
    g.loaded_netrwPlugin = 1
end

local function pkgs_packer()
    local packer_config = {
        package_root = vim.env.DotVimDir .. '/pack',
        compile_path = vim.env.DotVimDir .. '/pack/packer_compiled.lua',
        plugin_package = 'packer',
        git = {
            default_url_format = 'https://github.com/%s',
        },
    }
    if use.fastgit then
        packer_config.git.default_url_format = 'https://hub.fastgit.org/%s'
    end

    require('packer').startup({
    function()
        local add = require('packer').use
        add 'wbthomason/packer.nvim'

        -- editing
        add 'yehuohan/hop.nvim'
        add 'haya14busa/incsearch.vim'
        add 'haya14busa/incsearch-fuzzy.vim'
        add 'rhysd/clever-f.vim'
        add 'mg979/vim-visual-multi'
        add 't9md/vim-textmanip'
        add 'markonm/traces.vim'
        add 'junegunn/vim-easy-align'
        add 'psliwka/vim-smoothie'
        add 'terryma/vim-expand-region'
        add 'kana/vim-textobj-user'
        add 'kana/vim-textobj-indent'
        add 'kana/vim-textobj-function'
        add 'glts/vim-textobj-comment'
        add 'adriaanzon/vim-textobj-matchit'
        add 'lucapette/vim-textobj-underscore'
        add 'tpope/vim-repeat'
        add 'kshenoy/vim-signature'
        add 'Konfekt/FastFold'
        add 'mbbill/undotree'

        -- managers
        add 'morhetz/gruvbox'
        add 'yehuohan/popc'
        add 'yehuohan/popset'
    end, config = packer_config})
end

--------------------------------------------------------------------------------
-- Editing
--------------------------------------------------------------------------------
-- 快速跳转
local function pkgs_hop()
    require'hop'.setup({ match_mappings = { 'zh', 'zh_sc' }, create_hl_autocmd = true })
    noremap{'s'                , [[<Cmd>HopChar1MW<CR>]]    }
    noremap{'<leader>ms'       , [[<Cmd>HopChar2MW<CR>]]    }
    noremap{'<leader><leader>s', [[<Cmd>HopPatternMW<CR>]]  }
    noremap{'<leader>j'        , [[<Cmd>HopLineStartMW<CR>]]}
    noremap{'<leader><leader>j', [[<Cmd>HopLineMW<CR>]]     }
    noremap{'<leader>mw'       , [[<Cmd>HopWord<CR>]]       }
    nnoremap{'z/',
        [[incsearch#go(incsearch#config#fuzzy#make({'prompt': 'z/'}))]],
        silent = true, expr = true }
    nnoremap{'zg/',
        [[incsearch#go(incsearch#config#fuzzy#make({'prompt': 'z/', 'is_stay': 1}))]],
        silent = true, expr = true }
end

-- 行跳转
local function pkgs_clever_f()
    g.clever_f_across_no_line = 1
    g.clever_f_show_prompt = 1
    g.clever_f_smart_case = 1
end

-- 多光标编辑
local function pkgs_visual_multi()
    -- Usage: https://github.com/mg979/vim-visual-multi/wiki
    -- Tab: 切换cursor/extend模式
    -- C-n: 添加word或selected region作为cursor
    -- C-Up/Down: 移动当前position并添加cursor
    -- <VM_leader>a: 查找当前word作为cursor
    -- <VM_leader>/: 查找regex作为cursor（n/N用于查找下/上一个）
    -- <VM_leader>\: 添加当前position作为cursor（使用/或arrows或Hop跳转位置）
    -- <VM_leader>a <VM_leader>c: 添加visual区域作为cursor
    -- v: 文本对象（类似于viw等）
    g.VM_mouse_mappings = 0         -- 禁用鼠标
    g.VM_leader = ','
    g.VM_maps = {
        ['Find Under']         = '<C-n>',
        ['Find Subword Under'] = '<C-n>',
        ['Select All']         = ',a',
        ['Add Cursor At Pos']  = ',,',
        ['Select Operator']    = 'v',
    }
    g.VM_custom_remaps = {
        ['<C-p>'] = '[',
        ['<C-s>'] = 'q',
        ['<C-c>'] = 'Q',
        ['s']     = '<Cmd>HopChar1<CR>',
    }
end

-- 块编辑
local function pkgs_textmanip()
    g.textmanip_enable_mappings = 0
    -- 切换Insert/Replace Mode
    xnoremap{'<M-o>',
        [[<Cmd>]] ..
        [[let g:textmanip_current_mode = (g:textmanip_current_mode == 'replace') ? 'insert' : 'replace'<Bar>]] ..
        [[echo 'textmanip mode: ' . g:textmanip_current_mode<CR>]]}
    xmap{'<C-o>', '<M-o>'}
    -- 更据Mode使用Move-Insert或Move-Replace
    xmap{'<C-j>', [[<Plug>(textmanip-move-down)]] }
    xmap{'<C-k>', [[<Plug>(textmanip-move-up)]]   }
    xmap{'<C-h>', [[<Plug>(textmanip-move-left)]] }
    xmap{'<C-l>', [[<Plug>(textmanip-move-right)]]}
    -- 更据Mode使用Duplicate-Insert或Duplicate-Replace
    xmap{'<M-j>', [[<Plug>(textmanip-duplicate-down)]] }
    xmap{'<M-k>', [[<Plug>(textmanip-duplicate-up)]]   }
    xmap{'<M-h>', [[<Plug>(textmanip-duplicate-left)]] }
    xmap{'<M-l>', [[<Plug>(textmanip-duplicate-right)]]}
end

-- 预览增强
local function pkgs_traces()
    -- 支持:s, :g, :v, :sort, :range预览
    g.traces_num_range_preview = 1          -- 支持:N,M预览
end

-- 字符对齐
local function pkgs_easy_align()
    g.easy_align_bypass_fold = 1
    g.easy_align_ignore_groups = {}         -- 默认任何group都进行对齐
    -- 默认对齐内含段落（Text Object: vip）
    nmap{'<leader>al', [[<Plug>(LiveEasyAlign)ip]]}
    xmap{'<leader>al', [[<Plug>(LiveEasyAlign)]]  }
    -- :EasyAlign[!] [N-th] DELIMITER_KEY [OPTIONS]
    -- :EasyAlign[!] [N-th]/REGEXP/[OPTIONS]
    nnoremap{'<leader><leader>a', [[vip:EasyAlign<Space>*//l0><Left><Left><Left><Left>]]}
    vnoremap{'<leader><leader>a', [[:EasyAlign<Space>*//l0><Left><Left><Left><Left>]]   }
    nnoremap{'<leader><leader>A', [[vip:EasyAlign<Space>]]                              }
    vnoremap{'<leader><leader>A', [[:EasyAlign<Space>]]                                 }
end

-- 平滑滚动
local function pkgs_smoothie()
    g.smoothie_no_default_mappings = true
    g.smoothie_update_interval = 30
    g.smoothie_base_speed = 20
    nmap{'<M-n>', [[<Plug>(SmoothieDownwards)]]}
    nmap{'<M-m>', [[<Plug>(SmoothieUpwards)]]  }
    nmap{'<M-j>', [[<Plug>(SmoothieForwards)]] }
    nmap{'<M-k>', [[<Plug>(SmoothieBackwards)]]}
end

--  快速块选择
local function pkgs_expand_region()
    map{'<M-r>', [[<Plug>(expand_region_expand)]]}
    map{'<M-w>', [[<Plug>(expand_region_shrink)]]}
end

-- 文本对象
local function pkgs_textobj_user()
    -- vdc-ia-wWsp(b[<t{B"'`
    -- vdc-ia-ifcmu
    g.textobj_indent_no_default_key_mappings = 1
    omap{'aI', [[<Plug>(textobj-indent-a)]]     }
    omap{'iI', [[<Plug>(textobj-indent-i)]]     }
    omap{'ai', [[<Plug>(textobj-indent-same-a)]]}
    omap{'ii', [[<Plug>(textobj-indent-same-i)]]}
    vmap{'aI', [[<Plug>(textobj-indent-a)]]     }
    vmap{'iI', [[<Plug>(textobj-indent-i)]]     }
    vmap{'ai', [[<Plug>(textobj-indent-same-a)]]}
    vmap{'ii', [[<Plug>(textobj-indent-same-i)]]}
    omap{'au', [[<Plug>(textobj-underscore-a)]] }
    omap{'iu', [[<Plug>(textobj-underscore-i)]] }
    vmap{'au', [[<Plug>(textobj-underscore-a)]] }
    vmap{'iu', [[<Plug>(textobj-underscore-i)]] }
    nnoremap{'<leader>to', [[:lua Plug_to_motion('v')<CR>]]}
    nnoremap{'<leader>tO', [[:lua Plug_to_motion('V')<CR>]]}
end

local textobj_motion = vim.regex('/l')
function Plug_to_motion(motion)
    fn.PopSelection({
        opt = 'select text object motion',
        lst = vim.split([[w W s p ( b [ < t { B " ' ` i f c m u]], ' '),
        cmd = function(_, sel)
            local c = ''
            if textobj_motion:match_str(motion)
            then c = 'i'
            else c = 'a' end
            vim.cmd(string.format('normal! %s%s%s', string.lower(motion), c, sel))
        end
    })
end

-- 书签管理
local function pkgs_signature()
    g.SignatureMap = {
        Leader            = 'm',
        PlaceNextMark     = 'm,',
        ToggleMarkAtLine  = 'm.',
        PurgeMarksAtLine  = 'm-',
        DeleteMark        = '', PurgeMarks        = '', PurgeMarkers      = '',
        GotoNextLineAlpha = '', GotoPrevLineAlpha = '', GotoNextLineByPos = '', GotoPrevLineByPos = '',
        GotoNextSpotAlpha = '', GotoPrevSpotAlpha = '', GotoNextSpotByPos = '', GotoPrevSpotByPos = '',
        GotoNextMarker    = '', GotoPrevMarker    = '', GotoNextMarkerAny = '', GotoPrevMarkerAny = '',
        ListBufferMarks   = '', ListBufferMarkers = '',
    }
    nnoremap{'<leader>ts', [[:SignatureToggleSigns<CR>]]                           }
    nnoremap{'<leader>ma', [[:SignatureListBufferMarks<CR>]]                       }
    nnoremap{'<leader>mc', [[:call signature#mark#Purge('all')<CR>]]               }
    nnoremap{'<leader>ml', [[:call signature#mark#Purge('line')<CR>]]              }
    nnoremap{'<M-,>'     , [[:call signature#mark#Goto('prev', 'line', 'pos')<CR>]]}
    nnoremap{'<M-.>'     , [[:call signature#mark#Goto('next', 'line', 'pos')<CR>]]}
end

-- 更新折叠
local function pkgs_fastfold()
    g.fastfold_savehook = 0                 -- 只允许手动更新folds
    g.fastfold_fold_command_suffixes = {'x','X','a','A','o','O','c','C'}
    g.fastfold_fold_movement_commands = {'z[', 'z]', 'zj', 'zk'}
                                            -- 允许指定的命令更新folds
    nmap{'<leader>zu', [[<Plug>(FastFoldUpdate)]]}
end

-- 撤消历史
local function pkgs_undotree()
    nnoremap{'<leader>tu', [[:UndotreeToggle<CR>]]}
end

--------------------------------------------------------------------------------
-- Manager
--------------------------------------------------------------------------------
-- Vim主题(ColorScheme, StatusLine, TabLine)
local function pkgs_theme()
    g.gruvbox_contrast_dark = 'soft'        -- 背景选项：dark, medium, soft
    g.gruvbox_italic = 1
    vim.o.background = 'dark'
    if not pcall(vim.cmd, [[colorscheme gruvbox]]) then
        vim.cmd[[colorscheme default]]
    end
end

-- 弹出选项
local function pkgs_popset()
    g.Popset_SelectionData = {{
            opt = {'colorscheme', 'colo'},
            lst = {'gruvbox', 'one'},
        }}
    nnoremap{'<leader><leader>p', ':PopSet<Space>'    }
    nnoremap{'<leader>sp'       , ':PopSet popset<CR>'}
end

-- buffer管理
local function pkgs_popc()
    g.Popc_jsonPath = vim.env.DotVimCache
    g.Popc_useFloatingWin = 1
    g.Popc_highlight = {
        text     = 'Pmenu',
        selected = 'CursorLineNr',
    }
    g.Popc_useTabline = 1
    g.Popc_useStatusline = 1
    g.Popc_usePowerFont = use.ui.patch
    if use.ui.patch then
        g.Popc_selectPointer = ''
        g.Popc_separator = {left = '', right = ''}
        g.Popc_subSeparator = {left = '', right = ''}
    end
    g.Popc_useLayerPath = 0
    g.Popc_useLayerRoots = {'.popc', '.git', '.svn', '.hg', 'tags', '.LfGtags'}
    g.Popc_enableLog = 1
    nnoremap{'<leader><leader>h', [[:PopcBuffer<CR>]]               }
    nnoremap{'<M-u>'            , [[:PopcBufferSwitchTabLeft!<CR>]] }
    nnoremap{'<M-p>'            , [[:PopcBufferSwitchTabRight!<CR>]]}
    nnoremap{'<M-i>'            , [[:PopcBufferSwitchLeft!<CR>]]    }
    nnoremap{'<M-o>'            , [[:PopcBufferSwitchRight!<CR>]]   }
    nnoremap{'<C-i>'            , [[:PopcBufferJumpPrev<CR>]]       }
    nnoremap{'<C-o>'            , [[:PopcBufferJumpNext<CR>]]       }
    nnoremap{'<C-u>'            , [[<C-o>]]                         }
    nnoremap{'<C-p>'            , [[<C-i>]]                         }
    nnoremap{'<leader>wq'       , [[:PopcBufferClose!<CR>]]         }
    nnoremap{'<leader><leader>b', [[:PopcBookmark<CR>]]             }
    nnoremap{'<leader><leader>w', [[:PopcWorkspace<CR>]]            }
    nnoremap{'<leader>ty',
        [=[<Cmd>]=] ..
        [=[let g:Popc_tabline_layout = (get(g:, 'Popc_tabline_layout', 0) + 1) % 3<Bar>]=] ..
        [=[call call('popc#stl#TabLineSetLayout', [['buffer', 'tab'], ['buffer', ''], ['', 'tab']][g:Popc_tabline_layout])<CR>]=]}
end


local function pkgs_setup()
    pkgs_standard()
    pkgs_packer()
    -- editing
    pkgs_hop()
    pkgs_clever_f()
    pkgs_visual_multi()
    pkgs_textmanip()
    pkgs_traces()
    pkgs_easy_align()
    pkgs_smoothie()
    pkgs_expand_region()
    pkgs_textobj_user()
    pkgs_signature()
    pkgs_fastfold()
    pkgs_undotree()
    -- managers
    pkgs_theme()
    pkgs_popset()
    pkgs_popc()
end

return {
    setup = pkgs_setup,
}
