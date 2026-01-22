return {
	-- Treesitter is better than lsp's semantic
	on_init = function(client)
		client.server_capabilities.semanticTokensProvider = nil
		client.offset_encoding = "utf-8"
	end,
	cmd = { "clangd", "--header-insertion=never" },
}
