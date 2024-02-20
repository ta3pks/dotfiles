return {
	"CRAG666/code_runner.nvim",
	config = function()
		require('code_runner').setup({
			mode = "term",
			term = {
				position = "vertical",
				size = vim.fn.winwidth(0) / 3
			},
			filetype = {
				awk = {
					"awk -f $fileName"
				}
			},
		})
	end
}
