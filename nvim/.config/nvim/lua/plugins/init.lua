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
		"tpope/vim-fugitive",
		lazy = true,
		cmd = { "Git", "Gdiffsplit", "Gdiff", "Gvdiffsplit", "Gvdiff", "Gwrite", "Gw" },
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
	{
		'metakirby5/codi.vim'
		,
		lazy = true
		,
		cmd = { "Codi", "CodiNew" }
	},
	{ 'wakatime/vim-wakatime',            event = "VeryLazy" },
	{ 'junegunn/rainbow_parentheses.vim', event = "VeryLazy" },
	{ 'airblade/vim-gitgutter',           event = "BufReadPost" },

}
