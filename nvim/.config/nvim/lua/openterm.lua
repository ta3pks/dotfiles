-- local function _is_tmux()
-- 	return vim.fn.exists('$TMUX') == 1
-- end
-- local function tmux_open_term_full(prg, open_current_path)
-- 	prg = prg or ""
-- 	if open_current_path then
-- 		local filepath = current_filepath_dir()
-- 		prg = '-c ' .. filepath .. ' ' .. prg
-- 	end
-- 	vim.cmd('silent !tmux new-window ' .. prg)
-- end
-- local function tmux_open_term_split(down, prg, open_current_path)
-- 	local cmd = "split -h"
-- 	prg = prg or ""
-- 	if open_current_path then
-- 		local filepath = current_filepath_dir()
-- 		prg = '-c' .. filepath .. ' ' .. prg
-- 	end
-- 	if down then
-- 		cmd = "split -v"
-- 	end
-- 	vim.cmd('silent !tmux ' .. cmd .. ' ' .. prg)
-- end
local function current_filepath_dir()
	return vim.fn.fnamemodify(vim.fn.resolve(vim.fn.expand('%')), ':p:h')
end

local function open_nvim_term(prg, open_current_filepath)
	prg = prg or ""
	if open_current_filepath then
		vim.cmd("lcd " .. current_filepath_dir())
	end
	vim.cmd('term ' .. prg)
	vim.cmd('normal! i')
end

local m = {}
function m.open_full_term(prg, open_current_path, on_exit)
	-- if is_tmux() then
	-- 	tmux_open_term_full(prg, open_current_path)
	-- else
	local is_ok, term = pcall(require, "FTerm")
	if is_ok then
		term.scratch({
			cmd = prg,
			border = "rounded",
			on_exit = on_exit,
		})
		return
	else
		vim.cmd('tabnew')
		open_nvim_term(prg, open_current_path)
	end
	-- end
end

function m.open_term(prg, down, open_current_path)
	-- if is_tmux() then
	-- 	tmux_open_term_split(down, prg, open_current_path)
	-- else
	local cmd = "vsp"
	if down then
		cmd = "sp"
	end
	vim.cmd(cmd)
	open_nvim_term(prg, open_current_path)
end

-- end
vim.cmd([[
command! -nargs=? -complete=shellcmd -bar Term lua require('openterm').open_full_term(<q-args>, false)
command! -nargs=? -complete=shellcmd -bar VTerm lua require('openterm').open_term(<q-args>, false, false)
command! -nargs=? -complete=shellcmd -bar HTerm lua require('openterm').open_term(<q-args>, true,false)
command! -nargs=? -complete=shellcmd -bar TermHere lua require('openterm').open_full_term(<q-args>, true)
command! -nargs=? -complete=shellcmd -bar VTermHere lua require('openterm').open_term(<q-args>, false, true)
command! -nargs=? -complete=shellcmd -bar HTermHere lua require('openterm').open_term(<q-args>, true, true)
]])

return m
