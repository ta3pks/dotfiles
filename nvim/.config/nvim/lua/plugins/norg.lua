return {
	"nvim-neorg/neorg",
	build = ":Neorg sync-parsers",
	lazy = true,
	keys = {
		{ "<leader>nn", ":Neorg index<CR>",              silent = true },
		{ "<leader>nr", ":Neorg return<CR>",             silent = true },
		{ "<leader>nd", ":Neorg workspace dedecta<CR>",  silent = true },
		{ "<leader>np", ":Neorg workspace personal<CR>", silent = true },
		{ "<leader>ng", ":Neorg workspace game_sys<CR>", silent = true },
	},
	cmd = {
		"Neorg",
	},
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		vim.cmd [[
			cnoreabbrev wsp Neorg workspace
			cnoreabbrev norg Neorg index
		]]
		require("neorg").setup {
			load = {
				["core.defaults"] = {}, -- Loads default behaviour
				["core.concealer"] = {},
				["core.qol.todo_items"] = {
					config = {
						create_todo_parents = true,
						order = {
							{
								"pending",
								"-"
							},
							{
								"done",
								"x"
							},
							{
								"undone",
								" "
							},
						}
					},
				},
				["core.ui.calendar"] = {},
				["core.dirman"] = { -- Manages Neorg workspaces
					config = {
						workspaces = {
							dedecta = "~/Documents/notes/dedecta",
							personal = "~/Documents/notes/personal",
							game_sys = "~/Documents/notes/game_sys",
						},
					},
				},
			},
		}
	end,
}
