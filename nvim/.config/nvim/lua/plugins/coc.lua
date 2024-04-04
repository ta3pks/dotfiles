return {
	'neoclide/coc.nvim',
	branch = 'release',
	init = function()
		vim.keymap.set("n", "<leader>o", "<cmd>CocOutline<CR>", { noremap = true, silent = true })
		vim.o.tagfunc = "CocTagFunc"
		-- vim.keymap.set("n", "<leader><leader>r", "<cmd>CocRestart<CR>", { noremap = true, silent = true })
		vim.keymap.set("n", "<leader>r", "<Plug>(coc-rename)", { noremap = true, silent = true })
		vim.keymap.set("n", "<a-,>", "<Plug>(coc-fix-current)", { noremap = true, silent = true })
		vim.keymap.set("n", "<a-.>", "<Plug>(coc-codeaction-cursor)", { noremap = true, silent = true })
		vim.keymap.set("i", "<a-.>", function() vim.fn.CocAction('showSignatureHelp') end,
			{ noremap = true, silent = true, })
		vim.keymap.set("v", "<a-.>", "<Plug>(coc-codeaction-selected)", { noremap = true, silent = true })
		vim.keymap.set("n", "<a-r>", "<Plug>(coc-codeaction-refactor)", { noremap = true, silent = true })
		vim.keymap.set("n", "<m-s>", "<Plug>(coc-codeaction-source)", { noremap = true, silent = true })
		vim.keymap.set("n", "<a-d>", ":CocList diagnostics<CR>", { noremap = true, silent = true })
		vim.keymap.set("i", "<cr>", function()
			if vim.fn["coc#pum#visible"]() == 1 then
				return vim.fn["coc#_select_confirm"]()
			else
				return "<cr>"
			end
		end, { noremap = true, expr = true })

		vim.keymap.set("n", "<c-j>", "<plug>(coc-diagnostic-next)", { noremap = true, silent = true })
		vim.keymap.set("n", "<c-k>", "<plug>(coc-diagnostic-prev)", { noremap = true, silent = true })
		vim.keymap.set("n", "gt", "<plug>(coc-type-definition)", { noremap = true, silent = true })
		vim.keymap.set("n", "gd", "<plug>(coc-definition)", { noremap = true, silent = true })
		vim.keymap.set("i", "<c-space>", "coc#refresh()", { noremap = true, silent = true, expr = true })
		vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", { noremap = true, silent = true })
		vim.keymap.set("n", "gr", "<Plug>(coc-references)", { noremap = true, silent = true })
		vim.keymap.set({ "i", "n" }, "<c-c>", function()
			if vim.fn["coc#pum#visible"]() == 1 then
				return vim.fn["coc#pum#cancel"]()
			elseif vim.fn["coc#float#has_float"]() == 1 then
				return vim.fn["coc#float#close_all"]()
			else
				return "<c-c>"
			end
		end, { noremap = true, silent = true, expr = true })
		local function ShowDocumentation()
			if vim.fn.CocAction("hasProvider", "hover") then
				vim.fn.CocActionAsync("doHover")
			else
				vim.fn.feedkeys("K", "in")
			end
		end
		vim.keymap.set("n", "K", ShowDocumentation, { noremap = true, silent = true })
		if vim.fn.has("nvim-0.4.0") or vim.fn.has("patch-8.2.0750") then
			vim.keymap.set("n", "<a-j>", "coc#float#has_scroll() ? coc#float#scroll(1) : '<a-j>'",
				{ noremap = true, silent = true, expr = true, nowait = true })
			vim.keymap.set("n", "<a-k>", "coc#float#has_scroll() ? coc#float#scroll(0) : '<a-k>'",
				{ noremap = true, silent = true, expr = true, nowait = true })
		end
		-- set statusline+=%=%{coc#status()}%{get(b:,'coc_current_function','')}
		vim.o.statusline = "%f" .. vim.o.statusline .. "%=%{coc#status()}%{get(b:,'coc_current_function','')}"

		vim.cmd [[
			inoremap <silent><expr> <TAB>
			\ coc#pum#visible() ? coc#pum#next(1) :
			\ CheckBackspace() ? "\<Tab>" :
			\ coc#refresh()
			function! CheckBackspace() abort
			let col = col('.') - 1
			return !col || getline('.')[col - 1]  =~# '\s'
			endfunction
			command! -bar -nargs=0 Snippets :CocCommand snippets.openSnippetFiles

			]]
	end

}
