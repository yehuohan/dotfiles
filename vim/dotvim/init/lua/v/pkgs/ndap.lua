local use = require('v.use')
local nlib = require('v.nlib')
local m = nlib.m

--- Expand configuration ${variable} with repls
--- @param repls table<string, string|function> Replacements for ${variable}
--- @return fun(option:any):any
local function expand_config(repls)
    local function expand_variables(option)
        if type(option) == 'table' then
            local mt = getmetatable(option)
            local res = {}
            for k, v in pairs(option) do
                res[k] = expand_variables(v)
            end
            return setmetatable(res, mt)
        end
        if type(option) ~= 'string' then
            return option
        end
        local res = option
        for key, repl in pairs(repls) do
            res = res:gsub(key, repl)
        end
        return res
    end
    return expand_variables
end

local function setup_adapters()
    local dap = require('dap')

    -- launch.json
    dap.providers.configs['dap.launch.json'] = function()
        local root = nlib.u.try_root('.vscode')
        local path = root and root .. '/.vscode/launch.json'
        local ok, cfgs = pcall(require('dap.ext.vscode').getconfigs, path)
        if ok then
            if root then
                local repls = {
                    ['${workspaceFolder}'] = root,
                    ['${workspaceFolderBasename}'] = vim.fn.fnamemodify(root, ':t'),
                }
                for k, cfg in ipairs(cfgs) do
                    cfgs[k] = vim.tbl_map(expand_config(repls), cfg)
                end
            end
            return cfgs
        end
        return {}
    end

    -- C/C++/Rust: gdb or lldb
    dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = vim.env.DotVimLocal .. '/.mason/bin/OpenDebugAD7',
    }
    if IsWin() then
        dap.adapters.cppdbg.command = dap.adapters.cppdbg.command .. '.cmd'
        dap.adapters.cppdbg.options = { detached = false }
    end
    dap.configurations.c = {
        {
            name = 'Launch C/C++/Rust file',
            type = 'cppdbg',
            request = 'launch',
            program = function() return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':t:r') end,
            cwd = '${workspaceFolder}',
            stopAtEntry = true,
        },
    }
    dap.configurations.cpp = dap.configurations.c
    dap.configurations.rust = dap.configurations.c

    -- Python: pip install debugpy
    dap.adapters.debugpy = function(cb, cfg)
        if cfg.request == 'attach' then
            --- @type dap.ServerAdapter
            local adapter = {
                type = 'server',
                host = (cfg.connect or cfg).host or '127.0.0.1',
                port = (cfg.connect or cfg).port,
            }
            cb(adapter)
        else
            --- @type dap.ExecutableAdapter
            local adapter = {
                type = 'executable',
                command = cfg.python or 'python',
                args = { '-m', 'debugpy.adapter' },
                options = { source_filetype = 'python' },
            }
            cb(adapter)
        end
    end
    dap.configurations.python = {
        {
            name = 'Launch Python file',
            type = 'debugpy',
            request = 'launch',
            program = '${file}',
            console = 'integratedTerminal',
        },
    }

    -- Neovim Lua
    dap.adapters.nlua = function(cb, cfg)
        cb({
            type = 'server',
            host = cfg.host or '127.0.0.1',
            port = cfg.port or 9876,
        })
    end
    dap.configurations.lua = {
        {
            name = 'Attach to nvim instance',
            type = 'nlua',
            request = 'attach',
            port = 9876,
        },
    }
end

local function setup_ui()
    local dap = require('dap')
    local dapui = require('dapui')
    dapui.setup({
        layouts = {
            {
                elements = {
                    { id = 'breakpoints', size = 0.2 },
                    { id = 'stacks', size = 0.2 },
                    { id = 'watches', size = 0.2 },
                    { id = 'scopes', size = 0.4 },
                },
                position = 'left',
                size = 40,
            },
            {
                elements = {
                    { id = 'repl', size = 0.5 },
                    { id = 'console', size = 0.5 },
                },
                position = 'bottom',
                size = 10,
            },
        },
        mappings = {
            edit = 'e',
            expand = { 'o', '<CR>', '<2-LeftMouse>' },
            open = 'O',
            remove = 'd',
            repl = 'r',
            toggle = 't',
        },
    })
    dap.listeners.before.attach.dapui = dapui.open
    dap.listeners.before.launch.dapui = dapui.open
    dap.listeners.before.event_terminated.dapui = dapui.close
    dap.listeners.before.event_exited.dapui = dapui.close
end

local function setup_mappings()
    local dap = require('dap')
    local dapui = require('dapui')

    local breakpoint = function()
        dap.toggle_breakpoint()
        dapui.update_render({})
    end
    local breakpoint_condition = function()
        vim.ui.input({ prompt = 'Condition:' }, function(cond)
            if cond then
                dap.set_breakpoint(cond)
                dapui.update_render({})
            end
        end)
    end
    local breakpoint_hit_condition = function()
        vim.ui.input({ prompt = 'Hit condition:' }, function(cond)
            if cond then
                dap.set_breakpoint(nil, cond)
                dapui.update_render({})
            end
        end)
    end
    local log_point_message = function()
        vim.ui.input({ prompt = 'Log message:' }, function(msg)
            if msg then
                dap.set_breakpoint(nil, nil, msg)
                dapui.update_render({})
            end
        end)
    end

    m.nnore({ '<F4>', dap.terminate })
    m.nnore({ '<S-F5>', dap.terminate })
    m.nnore({ '<F5>', dap.continue })
    m.nnore({ '<F6>', dap.restart })
    m.nnore({ '<F7>', breakpoint_hit_condition })
    m.nnore({ '<F8>', breakpoint_condition })
    m.nnore({ '<F9>', breakpoint })
    m.nnore({ '<F10>', dap.step_over })
    m.nnore({ '<F11>', dap.step_into })
    m.nnore({ '<S-F11>', dap.step_out })
    m.nnore({ '<F12>', dap.step_out })
    m.nnore({ '<leader>dq', dap.terminate, desc = 'Terminate DAP debug' })
    m.nnore({ '<leader>dd', dap.continue, desc = 'Start/continue DAP debug' })
    m.nnore({ '<leader>dr', dap.run_to_cursor, desc = 'Run to cursor' })
    m.nnore({ '<leader>db', breakpoint, desc = 'Toggle breakpoint' })
    m.nnore({ '<leader>dc', breakpoint_condition, desc = 'Set condition breakpoint' })
    m.nnore({ '<leader>dh', breakpoint_hit_condition, desc = 'Set hit condition breakpoint' })
    m.nnore({ '<leader>dl', log_point_message, desc = 'Set log point message' })
    m.nnore({
        '<leader>de',
        function() dapui.eval(vim.fn.expand('<cword>'), { enter = true }) end,
        desc = 'Eval expression',
    })
    m.vnore({
        '<leader>de',
        function() dapui.eval(nlib.e.selected(''), { enter = true }) end,
        desc = 'Eval expression',
    })
    m.nnore({
        '<leader>dn',
        function() require('osv').run_this() end,
        desc = 'Debug current lua file with nvim',
    })
    m.nnore({
        '<leader>td',
        function()
            dapui.toggle()
            dapui.update_render({})
        end,
        desc = 'Toggle DAP UI',
    })
end

local function pkg_ndap()
    require('dap.ext.vscode').json_decode = require('json5').parse
    setup_adapters()
    if use.ui.icon then
        vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DiagnosticError' })
        vim.fn.sign_define('DapBreakpointCondition', { text = '󱍸', texthl = 'DiagnosticError' })
        vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DiagnosticError' })
        vim.fn.sign_define('DapLogPoint', { text = '󰣏', texthl = 'DiagnosticInfo' })
        vim.fn.sign_define('DapStopped', { text = '󰜴', texthl = 'DiagnosticWarn' })
    end
    setup_ui()
    setup_mappings()
end

return {
    'rcarriga/nvim-dap-ui',
    cond = use.ndap,
    config = pkg_ndap,
    keys = { '<leader>td' },
    dependencies = {
        'mfussenegger/nvim-dap',
        {
            'Joakker/lua-json5',
            build = IsWin() and 'powershell ./install.ps1' or './install.sh',
        },
        'jbyuki/one-small-step-for-vimkind',
    },
}
