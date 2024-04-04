return {
	'ggandor/leap-spooky.nvim',
	dependencies = {
		{ "ggandor/leap.nvim" },
		{ "tpope/vim-repeat" }
	},
	config = function()
		local leap = require('leap')
		leap.setup {}
		vim.keymap.set("n", "<c-s>", "<Plug>(leap-forward)", { noremap = true })
		vim.keymap.set("n", "<c-s><c-s>", "<Plug>(leap-backward)", { noremap = true })
		vim.keymap.set("n", "<c-s><c-s><c-s>", "<Plug>(leap-from-window)", { noremap = true })
		leap.add_repeat_mappings("<c-;>", "<c-,>", {
			relative_directions = true,
		})
		require('leap-spooky').setup()
	end,
}
