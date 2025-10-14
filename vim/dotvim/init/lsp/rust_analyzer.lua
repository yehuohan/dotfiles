local opts = {
	---@module 'codesettings'
	---@type lsp.rust_analyzer
	settings = {
		["rust-analyzer"] = {
			updates = { checkOnStartup = false, channel = "nightly" },
			cargo = { features = "all" },
			notifications = { cargoTomlNotFound = false },
		},
	},
}
-- return opts
return require("codesettings").with_local_settings("rust-analyzer", opts)
