local cmp = require"cmp"

cmp.setup{
	snippet = {
		expand = function (args)
			vim.fn["UltiSnips#Anon"](args.body)
		end,
	},
	mapping={
		['<C-e>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
		['<C-y>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	},
	sources =	{
			{ name = 'nvim_lsp' },
			{ name = 'ultisnips' }, 
			{ name = 'nvim_lsp_signature_help' },
		},
}
