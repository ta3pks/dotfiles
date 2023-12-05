return {
	{
		'nvimdev/dashboard-nvim',
		event = 'VimEnter',
		config = function()
			require('dashboard').setup {
				-- config
			}
		end,
		dependencies = { 'nvim-tree/nvim-web-devicons' }
	},
	{ "glts/vim-magnum" },
	{
		'ggandor/leap.nvim',
		event = "VeryLazy",
		config = function()
			require('leap').add_default_mappings()
			-- vim.keymap.set({ 'n', 'x', 'o' }, 'f', '<Plug>(leap-forward-to)', { noremap = false })
			-- vim.keymap.set({ 'n', 'x', 'o' }, 'F', '<Plug>(leap-backward-to)', { noremap = false })
			-- vim.keymap.set({ 'n', 'x', 'o' }, 't', '<Plug>(leap-forward-till)', { noremap = false })
			-- vim.keymap.set({ 'n', 'x', 'o' }, 'T', '<Plug>(leap-backward-till)', { noremap = false })
			-- vim.keymap.set({ 'n', 'x', 'o' }, 'gs', '<Plug>(leap-from-window)', { noremap = false })
			-- require('leap').add_repeat_mappings(';', ',', {
			-- 	relative_directions = true,
			-- 	modes = { 'n', 'x', 'o' },
			-- })
		end
	},
	{ 'wellle/targets.vim' },
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		}
	},
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
