return {
	"https://github.com/joshdick/onedark.vim",
	lazy = false,
	-- "sainnhe/everforest",
	-- lazy = false,
	-- config = function()
	-- 	vim.cmd [[
	-- 	let g:everforest_enable_italic = 1
	-- 	"let g:everforest_background = 'soft'
	-- 	let g:everforest_background = 'hard'
	-- 	let g:everforest_sign_column_background = 'grey'
	-- 	let g:everforest_ui_contrast = 'high'
	-- 	colorscheme everforest
	-- 	]]
	-- end
	--
	config = function()
		vim.cmd("colorscheme onedark")
	end,

}
