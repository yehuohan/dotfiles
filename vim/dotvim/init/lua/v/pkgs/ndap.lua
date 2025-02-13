--- @diagnostic disable: inject-field
--- @diagnostic disable: undefined-field

local use = require('v.use')
local m = require('v.nlib').m

local function setup_adapters()
    local dap = require('dap')
    -- Python: pip install debugpy
    dap.adapters.debugpy = function(cb, config)
        if config.request == 'attach' then
            --- @type dap.ServerAdapter
            local adapter = {
                type = 'server',
                port = (config.connect or config).port,
                host = (config.connect or config).host or '127.0.0.1',
            }
            cb(adapter)
        else
            --- @type dap.ExecutableAdapter
            local adapter = {
                type = 'executable',
                command = config.python or 'python',
                args = { '-m', 'debugpy.adapter' },
                options = { source_filetype = 'python' },
            }
            cb(adapter)
        end
    end
    dap.configurations.python = {
        {
            name = 'Launch Python File',
            type = 'debugpy',
            request = 'launch',
            program = '${file}',
            console = 'integratedTerminal',
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
    m.nnore({ '<F4>', dap.terminate })
    m.nnore({ '<S-F5>', dap.terminate })
    m.nnore({ '<F5>', dap.continue })
    m.nnore({ '<F6>', dap.restart })
    m.nnore({
        '<F9>',
        function()
            dap.toggle_breakpoint()
            dapui.update_render({})
        end,
        desc = 'Toggle breakpoint',
    })
    m.nnore({ '<F10>', dap.step_over })
    m.nnore({ '<F11>', dap.step_into })
    m.nnore({ '<S-F11>', dap.step_out })
    m.nnore({ '<F12>', dap.step_out })
    m.nnore({
        '<leader>db',
        function()
            vim.ui.input({ prompt = 'Condition:' }, function(cond)
                dap.set_breakpoint(cond)
                dapui.update_render({})
            end)
        end,
        desc = 'Set condition breakpoint',
    })
    m.nnore({
        '<leader>dh',
        function()
            vim.ui.input({ prompt = 'Hit condition:' }, function(cond)
                dap.set_breakpoint(nil, cond)
                dapui.update_render({})
            end)
        end,
        desc = 'Set hit condition breakpoint',
    })
    m.nnore({
        '<leader>dl',
        function()
            vim.ui.input({ prompt = 'Log message:' }, function(cond)
                dap.set_breakpoint(nil, nil, cond)
                dapui.update_render({})
            end)
        end,
        desc = 'Set log point',
    })
    m.nnore({
        '<leader>de',
        function() dapui.eval(vim.fn.expand('<cword>'), { enter = true }) end,
        'Eval expression',
    })
    m.nnore({
        '<leader>td',
        function()
            dapui.toggle()
            dapui.update_render({})
        end,
        'Toggle DAP UI',
    })
end

local function pkg_ndap()
    require('dap.ext.vscode').json_decode = require('json5').parse
    setup_adapters()
    if use.ui.icon then
        vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DiagnosticError' })
        vim.fn.sign_define('DapBreakpointCondition', { text = '󱍸', texthl = 'DiagnosticError' })
        vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DiagnosticError' })
        vim.fn.sign_define('DapLogPoint', { text = '♦', texthl = 'DiagnosticInfo' })
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
    },
}
