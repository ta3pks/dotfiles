local utils = require("utils")
local keymaps = require("keymaps")
local plugings_path = utils.vimrc_dir() .. "plugin_config.vim"
local lua_plugings_path = utils.vimrc_lua_dir() .. "plugins"
vim.cmd("source " .. plugings_path)
keymaps.n({
	["<c-w><c-p>"] = ":tabnew " .. plugings_path .. "<cr>",
	["<leader>pr"] = ":lua require'utils'.rerequire'plugins';print'plugins reloaded'<cr>",
	["<leader>pd"] = ":NERDTree " .. lua_plugings_path .. "<cr>",
})
