return {
	"numToStr/FTerm.nvim",
	keys = {
		{ "<leader>gg", function()
			require("FTerm").scratch({
				auto_close = true,
				border = "single",
				cmd = "lazygit",
				on_exit = function()
					vim.fn.feedkeys("i")
				end
			})
		end },
	},
}
