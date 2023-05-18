local task = require('v.task')
local m = require('v.maps')
local fn = vim.fn

-- Single file tasks to build & execute
-- @garg Generate arguments
-- @barg Build arguments
-- @earg Execution arguments
-- @src Source file
-- @out Output file
local singles = {
    cmd = {
        c = 'gcc -g {barg} {src} -o "{out}" && "./{out}" {earg}',
        cpp = 'g++ -g -std=c++20 {barg} {src} -o "{out}" && "./{out}" {earg}',
        python = 'python {src} {earg}',
        lua = 'lua {src} {earg}',
    },
    emf = {},
}

local function task_file(config)
    local ft = config.type or vim.o.filetype
    if (not singles.cmd[ft]) or ('dosbatch' == ft and IsWin()) then
        error('Code task doesn\'t support "' .. ft .. '"', task.Err.Code)
    end
    config.type = ft

    local rep = {}
    rep.barg = config.barg or ''
    rep.earg = config.earg or ''
    rep.src = '"' .. fn.fnamemodify(config.file, ':t') .. '"'
    rep.out = fn.fnamemodify(config.file, ':t:r')
    local cmd = singles.cmd[ft]:gsub('{(%w+)}', rep)

    return {
        cmd = cmd,
    }
end

-- local function task_make(config) end
-- local function task_cmake(config) end
-- local function task_cargo(config) end
-- local function task_sphinx(config) end

local function code(keys)
    local config = {
        file = fn.Expand('%', ':p'),
    }
    config.cwd = fn.fnamemodify(config.file, ':h')

    local tfn = task_file
    local ok, opts = pcall(tfn, config)
    if ok then
        opts.cwd = fn.fnameescape(config.cwd)
        opts.components = {
            {
                'on_output_quickfix',
                open = true,
                -- errorformat = '',
            },
            'display_duration',
            'on_output_summarize',
            'on_exit_set_status',
            'on_complete_dispose',
            -- 'unique',
        }
        task.run(opts)
    else
        vim.notify(tostring(opts))
    end
end

local function setup()
    local mappings = {
        'ri',
    }
    for _, k in ipairs(mappings) do
        m.nnore({
            '<leader>' .. k,
            function()
                code(k)
            end,
        })
    end
end

return {
    setup = setup,
}
