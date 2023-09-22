local function is_tmux()
	return vim.fn.exists('$TMUX') == 1
end
local function tmux_open_term_full(prg)
	prg = prg or ""
	vim.cmd('silent !tmux new-window ' .. prg)
end
local function tmux_open_term_split(down, prg)
	local cmd = "split -h"
	prg = prg or ""
	if down then
		cmd = "split -v"
	end
	vim.cmd('silent !tmux ' .. cmd .. ' ' .. prg)
end

local function open_nvim_term(prg)
	prg = prg or ""
	vim.cmd('term' .. prg)
	vim.cmd('normal! i')
end

local m = {}
function m.open_full_term(prg)
	if is_tmux() then
		tmux_open_term_full(prg)
	else
		vim.cmd('tabnew')
		open_nvim_term(prg)
	end
end

function m.open_term(down, prg)
	if is_tmux() then
		tmux_open_term_split(down, prg)
	else
		local cmd = "vsp"
		if down then
			cmd = "sp"
		end
		vim.cmd(cmd)
		open_nvim_term(prg)
	end
end

return m
