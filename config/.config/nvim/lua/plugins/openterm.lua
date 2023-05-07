local m = {}
local function do_open_term(prg)
	if prg then
		vim.cmd('term ' .. prg)
		vim.cmd('normal! i')
	else
		vim.cmd [[term
		normal! i
		]]
	end
end
function m.open_full_term(prg)
	vim.cmd('tabnew')
	do_open_term(prg)
end

function m.open_term(down, prg)
	local cmd
	if down then
		cmd = "sp"
	else
		cmd = "vsp"
	end
	vim.cmd(cmd)
	do_open_term(prg)
end

return m
