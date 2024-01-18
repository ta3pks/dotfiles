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
	dependencies = { "nvim-lua/plenary.nvim", "nvim-neorg/neorg-telescope" },
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
				["core.integrations.telescope"] = {},
			},
		}


		require("neorg.core.callbacks").on_event("core.keybinds.events.enable_keybinds", function(_, keybinds)
			-- Map all the below keybinds only when the "norg" mode is active
			keybinds.map_event_to_mode("norg", {
				n = { -- Bind keys in normal mode
					{ "<C-s>", "core.integrations.telescope.find_linkable" },
				},

				i = { -- Bind in insert mode
					{ "<C-space>n", "core.integrations.telescope.insert_link" },
				},
			}, {
				silent = true,
				noremap = true,
			})
		end)
	end,
}
