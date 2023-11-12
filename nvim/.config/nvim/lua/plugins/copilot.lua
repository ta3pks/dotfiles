return {
	{
		"github/copilot.vim",event="VeryLazy",
		init=function()
			vim.cmd[[
			inoremap <c-j> <Plug>(copilot-next)
			inoremap <c-k> <Plug>(copilot-previous)
			inoremap <c-\> <Plug>(copilot-suggest)
			inoremap <silent><script><expr> <C-l> copilot#Accept("\<CR>")
			let g:copilot_no_tab_map = v:true
			]]

		end

	},
}
