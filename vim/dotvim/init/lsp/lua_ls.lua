return {
	---@module 'codesettings'
	---@type lsp.lua_ls
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = {
				library = { vim.env.DotVimInit .. "/lua" },
				checkThirdParty = false,
			},
			telemetry = { enable = false },
			format = { enable = false },
		},
	},
}
