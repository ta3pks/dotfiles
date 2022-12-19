local m = {}
function m.open_full_term()
	vim.cmd('tabnew')
	vim.cmd[[term
	normal! i
	]]
end
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
vim.cmd [[
	command! -nargs=0 TermTab :lua require('plugins.openterm').open_full_term()<cr>
	nnoremap <silent> <d-t> :TermTab<cr>
]]

return m
