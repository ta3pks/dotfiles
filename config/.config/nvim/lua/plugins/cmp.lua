local cmp = require "cmp"

cmp.setup {
	snippet = {
		expand = function(args)
			vim.fn["UltiSnips#Anon"](args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert {
		['<C-e>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
		['<C-y>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
		['<C-c>'] = cmp.mapping.abort(),
		['<C-j>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end),

		['<C-k>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end)
		,




	},
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'ultisnips' },
		{ name = 'nvim_lsp_signature_help' },
	},
}
