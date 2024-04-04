local fname = "./.Session.vim"
_G.LoadSession = function()
	if vim.fn.argc() == 0 and vim.fn.filereadable(fname) == 1 then
		vim.cmd("source " .. fname)
	end
end
_G.LoadProjectConfig = function()
	for _,file in pairs({".project.vim",".project.lua"}) do
		if vim.fn.filereadable(file)==1 then
			vim.cmd("source "..file)
			print(file,"sourced")
		end
	end
end
vim.cmd([[
augroup __mysettings
	au!
	
	autocmd VimEnter * :call v:lua.LoadSession()
	autocmd vimenter * :call v:lua.LoadProjectConfig()
	autocmd BufEnter * :checktime
	autocmd BufWritePost /tmp/copy.md :silent 1,$yank +
	autocmd BufEnter /tmp/copy.md :execute "normal! ggdG" | :put! +
	autocmd BufEnter todo.txt set filetype=TODO
augroup END
]])
