return {
	{
		"mmahnic/vim-flipwords",
		lazy = true,
		cmd = { "Flip" },
	},
	{
		"tpope/vim-surround",
		event = "VeryLazy",
		depedencies = { "tpope/vim-repeat" },
	},
	{
		"glts/vim-radical",
		event = "VeryLazy",
		depedencies = { "tpope/vim-repeat" },
	},
	{
		"tpope/vim-repeat",
	},
	{
		"rakr/vim-one",
		init = function()
			vim.o.background = "dark"
			vim.cmd "colorscheme one"
		end
	},
	{
		'stevearc/dressing.nvim',
	},
	{
		"tomtom/tcomment_vim",
		event = "VeryLazy",
		init = function()
			vim.keymap.set('n', '<c-\\>', ':TComment<cr>', { noremap = true, silent = true })
			vim.keymap.set('v', '<c-\\>', function()
				vim.fn.feedkeys('gcgv')
			end, { noremap = true, silent = true })
		end
	},
	{ 'wakatime/vim-wakatime',            event = "VeryLazy" },
	{ 'junegunn/rainbow_parentheses.vim', event = "VeryLazy" },
	{ 'airblade/vim-gitgutter',           event = "BufReadPost" },

}
