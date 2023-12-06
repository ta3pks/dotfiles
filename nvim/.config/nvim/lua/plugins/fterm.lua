return {
	"numToStr/FTerm.nvim",
	keys = {
		{ mode = { "n", "t" }, "<a-cr>", function() require("FTerm").toggle() end },
		{ "<leader>gg", function()
			require("FTerm").scratch({
				auto_close = true,
				border = "rounded",
				cmd = "lazygit",
				on_exit = function()
					vim.fn.feedkeys("i")
				end
			})
		end },
	},
	config = function()
		vim.cmd("highlight FloatBorder guifg=gray")
		require("FTerm").setup {
			border = "rounded",
		}
	end,
}
