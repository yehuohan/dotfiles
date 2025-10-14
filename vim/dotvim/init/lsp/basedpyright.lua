return {
	-- Treesitter is better than lsp's semantic
	on_init = function(client)
		client.server_capabilities.semanticTokensProvider = nil
	end,
}
