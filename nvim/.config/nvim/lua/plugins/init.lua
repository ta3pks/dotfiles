return {
	{
		'MarcHamamji/runner.nvim',
		dependencies = {
			'nvim-telescope/telescope.nvim',
			dependencies = { 'nvim-lua/plenary.nvim' }
		},
		config = function()
			require('runner').setup()
		end
	},
	{
		"folke/neodev.nvim",
		opts = {
			library = { plugins = { "neotest" }, types = true }
		}
	},
	{
		"sainnhe/everforest",
		lazy = false,
		config = function()
			vim.cmd [[
			let g:everforest_enable_italic = 1
			"let g:everforest_background = 'soft'
			let g:everforest_background = 'hard'
			let g:everforest_sign_column_background = 'grey'
			let g:everforest_ui_contrast = 'high'
			colorscheme everforest
			]]
		end

	},
	{
		"kana/vim-textobj-indent",
		event = "VeryLazy",
		dependencies = {
			"kana/vim-textobj-user",
		}
	},
	{ 'rafcamlet/nvim-luapad',  cmd = { "Luapad" } },
	{
		'wellle/targets.vim',
		config = function()
			vim.keymap.set("n", "<leader>", "<Plug>(easymotion-prefix)", { silent = true })
		end,
		keys = {
			"<leader>w",
		},
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim",
			'nvim-telescope/telescope.nvim',
		},
		cmd =
		{
			"TodoTelescope",
			"Todos",
		},
		keys = {
			{ "<c-space>d", ":TodoTelescope <cr>", noremap = true, silent = true },
		},
		config = function(cfg)
			require "todo-comments".setup(cfg)
			vim.cmd [[command! Todos TodoTelescope]]
		end
	},
	{
		"mmahnic/vim-flipwords",
		lazy = true,
		cmd = { "Flip" },
	},
	{
		"tpope/vim-surround",
		event = "VeryLazy",
		dependencies = { "tpope/vim-repeat" },
	},
	{
		"tpope/vim-repeat",
	},
	{
		'stevearc/dressing.nvim',
		event = "VeryLazy",
	},
	{
		"tomtom/tcomment_vim",
		keys = {
			{
				"<a-:>", ":TComment<cr>", noremap = true, silent = true, mode = "n"
			},
			{
				"<a-:>",
				function()
					vim.fn.feedkeys('gcgv')
				end,
				noremap = true,
				silent = true,
				mode = "v"
			},
		},
	},
	{ 'wakatime/vim-wakatime',  event = "VeryLazy" },
	{ 'airblade/vim-gitgutter', event = "BufReadPost" },

}
