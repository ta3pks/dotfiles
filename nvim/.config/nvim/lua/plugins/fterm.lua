return {
	"numToStr/FTerm.nvim",
	keys = {
		{ mode = { "n", "t" }, "<a-cr>", function() require("FTerm").toggle() end },
		"<M-BS>",
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
		SecondTerm = require("FTerm"):new({ cmd = "zsh" });
		vim.keymap.set({ 'n', 't' }, '<M-BS>', function()
			SecondTerm:toggle()
		end, { noremap = true, silent = true })
	end,
}
