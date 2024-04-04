return {
	"coffebar/neovim-project",
	opts = {
		projects = { -- define project roots
			"~/.projects/dedecta/*",
			"~/.projects/*",
			"~/.projects/tbls/*",
			"~/.learn/*",
			"~/contributing/*",
			"~/dotfiles/",
		},
	},
	init = function()
		-- enable saving the state of plugins in the session
		vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
	end,
	keys = {
		{ "<c-space>p",     "<cmd>Telescope neovim-project<cr>",          noremap = true },
		{ "<c-space><c-p>", "<cmd>Telescope neovim-project discover<cr>", noremap = true },
		{ "<c-space>3",     "<cmd>NeovimProjectLoadRecent<cr>",           noremap = true },
	},
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-telescope/telescope.nvim", tag = "0.1.4" },
		{ "Shatur/neovim-session-manager" },
	},
	lazy = false,
	priority = 5,
}
