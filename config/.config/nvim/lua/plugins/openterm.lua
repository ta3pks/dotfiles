local m = {}
function m.open_term(down)
	local cmd
	if down then
		cmd = "sp"
	else
		cmd = "vsp"
	end
	vim.cmd(cmd)
	vim.cmd[[term
	normal! i
	]]
end
return m