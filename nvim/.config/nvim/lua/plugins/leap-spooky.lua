return {
	'ggandor/leap-spooky.nvim',
	dependencies = {
		{ "ggandor/leap.nvim" },
		{ "tpope/vim-repeat" }
	},
	config = function()
		require('leap').create_default_mappings()
		require('leap-spooky').setup()
	end,
}
