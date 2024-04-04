return {
	{
		"github/copilot.vim",
		event = "VeryLazy",
		init = function()
			vim.cmd [[
			inoremap <c-j> <Plug>(copilot-next)
			inoremap <c-k> <Plug>(copilot-previous)
			inoremap <c-:> <cmd>Copilot panel<cr>
			inoremap <silent><script><expr> <C-l> copilot#Accept("\<CR>")
			let g:copilot_no_tab_map = v:true
			]]
		end

	},
}
