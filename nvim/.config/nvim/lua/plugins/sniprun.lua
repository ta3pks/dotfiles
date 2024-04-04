return {
	"michaelb/sniprun",
	branch = "master",

	build = "sh install.sh",
	-- do 'sh install.sh 1' if you want to force compile locally
	-- (instead of fetching a binary from the github release). Requires Rust >= 1.65
	cmd = "SnipRun",
	config = function(self)
		local binpath = vim.env.CARGO_TARGET_DIR .. "/release/sniprun"
		local opts = {
			display = {
				"VirtualText",
				"Terminal",
			},
			display_options = {
				terminal_position = "vertical",
			},
			interpreter_options = {
				awk = self.awk,
			}
		}
		if vim.fn.filereadable(binpath) == 1 then
			opts.binary_path = binpath
		end
		require("sniprun").setup(opts)
	end,
	awk = {
		use_on_filetypes = {
			"awk",
		},
		interpreter = "gawk",
	}
}
