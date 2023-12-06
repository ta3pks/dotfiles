return {
	"numToStr/FTerm.nvim",
	keys = {
		{ "<leader>gg", function()
			require("FTerm").scratch({
				auto_close = true,
				cmd = "zsh -c lazygit",
				on_exit = function()
					vim.fn.feedkeys("i")
				end
			})
		end },
	},
}
