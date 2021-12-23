local utils = require("utils")

local keymaps = {
	["Q"] = ":q<cr>",
	["<space>"] = "za",
	["<c-w>r"] = ":source $MYVIMRC<bar>echo 'reloaded'<cr>",
	["<c-w><c-s>"] = ":tabnew $MYVIMRC<cr>",
	["<leader>kr"] = ":lua require'keymaps'.reload_keymaps()<cr>",
	["<leader>ko"] = ":lua require'keymaps'.open_keymap_file()<cr>",
	["<leader><cr>"] = ":lua require('plugins.openterm').open_term()<cr>",
	["<leader>]"] = ":lua require('plugins.openterm').open_term(1)<cr>",
	["<c-w><c-l>"] = ":lua require'plugins.openftplugin'.open_ft_plugin()<cr>",
	["<c-s>"] = ":set spell!<cr>",
	["<C-k>"] = ":lprevious<cr>",
	["<C-j>"] = ":lnext<cr>",
	["<C-f>"] = ":lfirst<cr>",
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
	["<leader>d"] = ":!date<cr>",
}

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
			utils.nmap(k, v)
		elseif type(v) == "table" then
			local cmd = v[1]
			v[1] = nil
			utils.nmap(k, cmd, v)
		end
	end
end
map("n", keymaps) --init default global keymaps
local m = {}
function m.reload_keymaps()
	package.loaded.keymaps = nil
	vim.cmd("source $MYVIMRC")
	print("keymaps reloaded")
end
function m.n(keymaps)
	map("n", keymaps)
end
function m.i(keymaps)
	map("i", keymaps)
end
function m.open_keymap_file()
	vim.cmd("tabnew " .. string.match(vim.env.MYVIMRC, ".*/") .. "/lua/keymaps.lua")
end
return m
