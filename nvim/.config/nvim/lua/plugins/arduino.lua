return {
	'stevearc/vim-arduino',
	ft = "arduino",
	config = function()
		vim.keymap.set("n", "<leader>au", "<cmd>ArduinoUpload<cr>");
		vim.keymap.set("n", "<leader>as", "<cmd>ArduinoSerial<cr>");
		vim.keymap.set("n", "<leader>av", "<cmd>ArduinoVerify<cr>");
	end,
}
