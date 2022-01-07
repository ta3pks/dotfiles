require("events")
require("keymaps")
require("plugins")
require("neorgcfg")
local utils = require("utils")
local api = vim.api
vim.cmd([[
	syntax on
	command! FixTrailing :%s/\s\+$//g
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
vim.o.mouse='a'
