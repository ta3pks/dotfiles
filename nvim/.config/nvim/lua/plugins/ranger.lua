return {
	{
		'francoiscabrol/ranger.vim',
		dependencies = { 'rbgrouleff/bclose.vim' },
		lazy = true,
		cmd = { 'Ranger' },
		keys = {},
		init = function()
			vim.g.ranger_replace_netrw = 0
			vim.g.ranger_map_keys = 0
			vim.keymap.set('n', '<M-f>', ':Ranger<cr>', { noremap = true, silent = true })
		end,
	}
}
