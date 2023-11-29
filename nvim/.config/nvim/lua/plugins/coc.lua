return {
	'neoclide/coc.nvim',
	branch = 'release',
	init = function()
		--		nnoremap <buffer> <silent> K :lua vim.lsp.buf.hover()<CR>
		--		nnoremap <buffer> <silent> <c-a-f> :lua vim.lsp.buf.format()<CR>
		--		nnoremap <buffer> <silent> <a-,> :lua vim.lsp.buf.code_action({apply=true})<CR>
		--		nnoremap <buffer> <silent> <a-.> :lua vim.lsp.buf.code_action({only={'quickfix',"source",'source'}})<CR>
		--		inoremap <buffer> <silent> <a-.> <cmd>lua vim.lsp.buf.signature_help()<CR>
		--		nnoremap <buffer> <silent> \r :lua vim.lsp.buf.rename()<CR>
		--		nnoremap <buffer> <silent> gt :lua vim.lsp.buf.type_definition({reuse_win=true})<CR>
		--		nnoremap <buffer> <silent> <c-j> :lua vim.diagnostic.goto_next()<CR>
		--		nnoremap <buffer> <silent> <c-k> :lua vim.diagnostic.goto_prev()<CR>
		--		nnoremap <buffer> <silent> <a-o> :lua vim.diagnostic.open_float()<CR>
		--		autocmd __lsp BufWritePre <buffer> lua vim.lsp.buf.format()

		vim.keymap.set("n", "<leader>o", "<cmd>CocOutline<CR>", { noremap = true, silent = true })
		vim.o.tagfunc = "CocTagFunc"
		-- nnoremap <silent> <leader><leader>r <cmd>CocRestart<CR>
		-- nmap <silent> <leader>r <Plug>(coc-rename)
		-- nmap <silent> <a-,> <Plug>(coc-fix-current)
		-- nmap <silent> <a-.> <Plug>(coc-codeaction-cursor)
		-- vmap <silent> <a-.> <Plug>(coc-codeaction-selected)
		-- nmap <silent> <a-r> <Plug>(coc-codeaction-refactor)
		-- nmap <silent> <leader>s <Plug>(coc-codeaction-source)
		-- vmap <silent> <leader>f <Plug>(coc-format-selected)
		-- nmap <silent> <leader>f :call CocActionAsync('format')<CR>
		-- nmap <silent> <a-d> :CocList diagnostics<CR>
		-- nmap <silent> <c-j> <plug>(coc-diagnostic-next)
		-- nmap <silent> <c-k> <plug>(coc-diagnostic-prev)
		-- nmap <silent> gt <plug>(coc-type-definition)
		-- nmap <silent> gd <plug>(coc-definition)
		vim.keymap.set("n", "<leader><leader>r", "<cmd>CocRestart<CR>", { noremap = true, silent = true })
		vim.keymap.set("n", "<leader>r", "<Plug>(coc-rename)", { noremap = true, silent = true })
		vim.keymap.set("n", "<a-,>", "<Plug>(coc-fix-current)", { noremap = true, silent = true })
		vim.keymap.set("n", "<a-.>", "<Plug>(coc-codeaction-cursor)", { noremap = true, silent = true })
		vim.keymap.set("i", "<a-.>", function() vim.fn.CocAction('showSignatureHelp') end,
			{ noremap = true, silent = true, })
		vim.keymap.set("v", "<a-.>", "<Plug>(coc-codeaction-selected)", { noremap = true, silent = true })
		vim.keymap.set("n", "<a-r>", "<Plug>(coc-codeaction-refactor)", { noremap = true, silent = true })
		vim.keymap.set("n", "<leader>s", "<Plug>(coc-codeaction-source)", { noremap = true, silent = true })
		vim.keymap.set("v", "<leader>f", "<Plug>(coc-format-selected)", { noremap = true, silent = true })
		vim.keymap.set("n", "<leader>f", ":call CocActionAsync('format')<CR>", { noremap = true, silent = true })
		vim.keymap.set("n", "<a-d>", ":CocList diagnostics<CR>", { noremap = true, silent = true })
		vim.keymap.set("n", "<c-j>", "<plug>(coc-diagnostic-next)", { noremap = true, silent = true })
		vim.keymap.set("n", "<c-k>", "<plug>(coc-diagnostic-prev)", { noremap = true, silent = true })
		vim.keymap.set("n", "gt", "<plug>(coc-type-definition)", { noremap = true, silent = true })
		vim.keymap.set("n", "gd", "<plug>(coc-definition)", { noremap = true, silent = true })
		if vim.fn.has("nvim") then
			-- inoremap <silent><expr> <c-space> coc#refresh()
			vim.keymap.set("i", "<c-space>", "coc#refresh()", { noremap = true, silent = true, expr = true })
		else
			-- else
			-- 	inoremap <silent><expr> <c-@> coc#refresh()
			-- 	endif
			vim.keymap.set("i", "<c-@>", "coc#refresh()", { noremap = true, silent = true, expr = true })
		end
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
		vim.keymap.set("i", "<a-j>", function()
			--"coc#pum#visible() ? coc#pum#prev(0) : '<C-h>'"
			if vim.fn["coc#pum#visible"]() == 1 then
				return vim.fn["coc#pum#next"](0)
			elseif vim.fn["coc#float#has_scroll"]() == 1 then
				return vim.fn["coc#float#scroll"](1)
			else
				return "<a-j>"
			end
		end
		, { noremap = true, silent = true, expr = true })
		vim.keymap.set("i", "<a-k>", function()
			--"coc#pum#visible() ? coc#pum#prev(0) : '<C-h>'"
			if vim.fn["coc#pum#visible"]() == 1 then
				return vim.fn["coc#pum#prev"](0)
			elseif vim.fn["coc#float#has_scroll"]() == 1 then
				return vim.fn["coc#float#scroll"](0)
			else
				return "<a-k>"
			end
		end, { noremap = true, silent = true, expr = true })
		vim.keymap.set("i", "<CR>",
			"coc#pum#visible() ? coc#pum#confirm() : '<C-g>u<CR><c-r>=coc#on_enter()<CR>'",
			{ noremap = true, silent = true, expr = true })
		-- function! ShowDocumentation()
		-- if CocAction('hasProvider', 'hover')
		-- 	call CocActionAsync('doHover')
		-- else
		-- 	call feedkeys('K', 'in')
		-- 	endif
		-- endfunction
		-- nnoremap <silent> K :call ShowDocumentation()<CR>
		local function ShowDocumentation()
			if vim.fn.CocAction("hasProvider", "hover") then
				vim.fn.CocActionAsync("doHover")
			else
				vim.fn.feedkeys("K", "in")
			end
		end
		vim.keymap.set("n", "K", ShowDocumentation, { noremap = true, silent = true })
		-- if has('nvim-0.4.0') || has('patch-8.2.0750')
		-- 	nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-f>"
		-- 	nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
		-- 	inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Right>"
		-- 	inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
		-- 	vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-f>"
		-- 	vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
		-- endif
		if vim.fn.has("nvim-0.4.0") or vim.fn.has("patch-8.2.0750") then
			vim.keymap.set("n", "<a-j>", "coc#float#has_scroll() ? coc#float#scroll(1) : '<a-j>'",
				{ noremap = true, silent = true, expr = true, nowait = true })
			vim.keymap.set("n", "<a-k>", "coc#float#has_scroll() ? coc#float#scroll(0) : '<a-k>'",
				{ noremap = true, silent = true, expr = true, nowait = true })
		end
		-- set statusline+=%=%{coc#status()}%{get(b:,'coc_current_function','')}
		vim.o.statusline = vim.o.statusline .. "%=%{coc#status()}%{get(b:,'coc_current_function','')}"
		vim.cmd [[
			inoremap <silent><expr> <TAB>
			\ coc#pum#visible() ? coc#pum#next(0) :
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
