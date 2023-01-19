local utils = require("utils")

local keymaps = {
	["Q"] = ":lua require'keymaps'.close_buffer()<cr>",
	["<space>"] = "za",
	["<c-w>r"] = ":source $MYVIMRC<bar>echo 'reloaded'<cr>",
	["<c-w><c-s>"] = ":tabnew $MYVIMRC<cr>",
	["<c-w><c-u>"] = ":lua require'keymaps'.open_utils_file()<cr>",
	["<leader>kr"] = ":lua require'keymaps'.reload_keymaps()<cr>",
	["<leader>ko"] = ":lua require'keymaps'.open_keymap_file()<cr>",
	["<leader><cr>"] = ":lua require('plugins.openterm').open_term()<cr>",
	["<d-e>"] = ":lua require('plugins.openterm').open_term()<cr>",
	["<leader>]"] = ":lua require('plugins.openterm').open_term(1)<cr>",
	["<d-d>"] = ":lua require('plugins.openterm').open_term(1)<cr>",
	["<d-t>"] = ":lua require('plugins.openterm').open_full_term()<cr>",
	["<c-s-t>"] = ":tabnew<cr>",
	["<d-w>"] = ":tabclose<cr>",
	["<d-n>"] = ":!neovide<cr>",
	["<d-1>"] = ":1tabn<cr>",
	["<d-2>"] = ":2tabn<cr>",
	["<d-3>"] = ":3tabn<cr>",
	["<d-4>"] = ":4tabn<cr>",
	["<d-5>"] = ":5tabn<cr>",
	["<d-6>"] = ":6tabn<cr>",
	["<d-7>"] = ":7tabn<cr>",
	["<d-8>"] = ":8tabn<cr>",
	["<d-9>"] = ":9tabn<cr>",
	["<d-0>"] = ":tablast<cr>",
	["<c-w><c-l>"] = ":lua require'plugins.openftplugin'.open_ft_plugin()<cr>",
	["<c-s>"] = ":set spell!<cr>",
	["<C-k>"] = ":lprevious<cr>",
	["<C-j>"] = ":lnext<cr>",
	["<C-h>"] = ":cprevious<cr>",
	["<C-l>"] = ":cnext<cr>",
	["#"] = ":b#<cr>",
	["<Up>"] = "<NOP>",
	["<Down>"] = "<NOP>",
	["<Left>"] = "<NOP>",
	["<Right>"] = "<NOP>",
	["<c-m-o>"] = ":%bd <bar> e # <bar> bd #<cr>",
	["<c-right>"] = ":call feedkeys('2zl')<cr>",
	["<c-left>"] = ":call feedkeys('2zh')<cr>",
	["<leader>d"] = { ":!date<cr>", silent = true },
}

vim.cmd("command! W :w")
local function map(mode, maps)
	local mapfn
	if mode == "n" then
		mapfn = utils.nmap
	elseif mode == "i" then
		mapfn = utils.imap
	else
		print("unknown map mode", mode)
	end
	for k, v in pairs(maps) do
		if type(v) == "string" then
			mapfn(k, v)
		elseif type(v) == "table" then
			local cmd = v[1]
			v[1] = nil
			mapfn(k, cmd, v)
		end
	end
end

map("n", keymaps) --init default global keymaps
local m = {}
function m.reload_keymaps()
	utils.rerequire("keymaps")
	print("keymaps reloaded")
end

function m.n(kmaps)
	map("n", kmaps)
end

function m.i(kmaps)
	map("i", kmaps)
end

function m.open_keymap_file()
	vim.cmd("tabnew " .. string.match(vim.env.MYVIMRC, ".*/") .. "/lua/keymaps.lua")
end

function m.open_utils_file()
	vim.cmd("tabnew " .. string.match(vim.env.MYVIMRC, ".*/") .. "/lua/utils.lua")
end

function m.close_buffer()
	if utils.num_active_bufs() == 1 then
		vim.cmd("q")
	else
		vim.cmd("bd")
	end
end

return m
