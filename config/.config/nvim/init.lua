require("events")
require("keymaps")
require("plugins")
-- local api = vim.api
vim.cmd([[
	syntax on
	command! FixTrailing :%s/\s\+$//g
	"osx specific settings
	inoremap <d-v> <c-r>+
	vnoremap <d-c> "+ygv
	autocmd VimEnter * NERDTree
]])
vim.o.inccommand = "split"
vim.o.ignorecase = true
vim.o.hlsearch = false
vim.o.smartcase = true
vim.o.wildignorecase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 1 -- width of line numbers column on left
vim.o.foldmethod = "marker"
vim.o.termguicolors = true
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
vim.o.mouse = 'a'
if vim.fn.exists("g:neovide") then
	vim.o.guifont = "FiraCode Nerd Font:h14"
	vim.g.neovide_hide_mouse_when_typing = false
	vim.g.neovide_full_screen = false
	vim.g.neovide_remember_window_size = true
	vim.g.neovide_macos_option_as_alt = true
	vim.g.neovide_input_macos_alt_is_meta = true
	vim.g.neovide_cursor_animation_length = 0.05
	vim.g.neovide_cursor_trail_size = 0.1
	vim.g.neovide_cursor_vfx_mode = ""
	vim.g.neovide_no_idle = false
	vim.g.neovide_refresh_rate_idle = 1
	vim.g.neovide_transparency = 0.9
	vim.g.NERDTreeShowBookmarks = 1
end
