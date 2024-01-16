return {
	"nvim-neorg/neorg",
	build = ":Neorg sync-parsers",
	lazy = true,
	keys = {
		{ "<leader>no", ":Neorg<CR>" },
		{ "<leader>ni", ":Neorg index<CR>" },
		{ "<leader>nr", ":Neorg return<CR>" },
	},
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		vim.cmd [[
			cnoreabbrev workspace Neorg workspace
			cnoreabbrev norg Neorg index
		]]
		require("neorg").setup {
			load = {
				["core.defaults"] = {}, -- Loads default behaviour
				["core.concealer"] = {}, -- Adds pretty icons to your documents
				["core.ui.calendar"] = {},
				["core.dirman"] = { -- Manages Neorg workspaces
					config = {
						workspaces = {
							dedecta = "~/Documents/notes/dedecta",
							default = "~/Documents/notes/personal",
							game_sys = "~/Documents/notes/game_sys",
						},
					},
				},
			},
		}
	end,
}
