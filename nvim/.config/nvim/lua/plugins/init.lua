return {
	{
		"folke/zen-mode.nvim",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		}
	},
	{
		"sainnhe/everforest",
		lazy = false,
		config = function()
			vim.cmd [[
			let g:everforest_enable_italic = 1
			let g:everforest_background = 'soft'
			let g:everforest_sign_column_background = 'grey'
			let g:everforest_ui_contrast = 'high'
			colorscheme everforest
			]]
		end

	},


	-- {
	-- 	"https://github.com/mkarmona/materialbox",
	-- 	lazy = false,
	-- 	config = function()
	-- 		vim.cmd [[
	-- 		colorscheme materialbox
	-- 		]]
	-- 	end
	-- },
	-- {
	-- 	"https://github.com/rakr/vim-one",
	-- 	lazy = false,
	-- 	config = function()
	-- 		vim.cmd [[
	-- 		colorscheme one
	-- 		highlight Folded guifg=#4A4948 guibg=bg
	-- 		]]
	-- 	end
	-- },
	-- {
	-- 	"rebelot/kanagawa.nvim",
	-- 	lazy = false,
	-- 	config = function()
	-- 		vim.cmd [[
	-- 		colorscheme kanagawa
	-- 		]]
	-- 	end
	--
	-- },
	-- {
	-- 	"joshdick/onedark.vim",
	-- 	lazy = false,
	-- 	init = function()
	-- 		vim.o.background = "dark"
	-- 		vim.cmd "colorscheme onedark"
	-- 	end
	-- },
	-- {
	-- 	"olimorris/onedarkpro.nvim",
	-- 	lazy = false,
	-- 	init = function()
	-- 		vim.o.background = "dark"
	-- 		vim.cmd "colorscheme onedark_vivid"
	-- 	end
	-- },
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
				"<c-\\>", ":TComment<cr>", noremap = true, silent = true, mode = "n"
			},
			{
				"<c-\\>",
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
