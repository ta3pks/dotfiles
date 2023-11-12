local utils = {}
function utils.map(mode, key, cmd, opts)
	local ops = opts or {}
	for _, val in pairs({ "noremap", "silent" }) do
		if ops[val] == nil then
			ops[val] = true
		end
	end
	if ops.buf then
		ops.buf = nil
		vim.api.nvim_buf_set_keymap(0, mode, key, cmd, ops)
	else
		vim.api.nvim_set_keymap(mode, key, cmd, ops)
	end
end

function utils.nmap(key, cmd, opts)
	utils.map("n", key, cmd, opts)
end

function utils.imap(key, cmd, opts)
	utils.map("i", key, cmd, opts)
end

function utils.rerequire(name)
	package.loaded[name] = nil
	return require(name)
end

_G.rerequire = utils.rerequire
function utils.vimrc_dir()
	return string.match(vim.env.MYVIMRC or "", ".*/") or os.getenv("HOME") .. "/.config/nvim/"
end

function utils.vimrc_lua_dir()
	return utils.vimrc_dir() .. "lua/"
end

function utils.vimrc_lua_plugin_dir()
	return utils.vimrc_lua_dir() .. "plugins/"
end

function utils.num_active_bufs()
	local bufs = vim.api.nvim_list_bufs()
	local num_loaded_bufs = 0
	for i, bufid in pairs(bufs) do
		local valid = vim.fn.buflisted(bufid) == 1
		if valid then
			num_loaded_bufs = num_loaded_bufs + 1
		end
	end
	return num_loaded_bufs
end

function Rerequire(name)
	package.loaded[name] = nil
	return require(name)
end

vim.g.utils = utils
return utils
