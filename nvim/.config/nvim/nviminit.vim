lua require"openterm"
command! -nargs=? -complete=shellcmd -bar Term lua require('openterm').open_full_term(<q-args>, false)
command! -nargs=? -complete=shellcmd -bar TermInPlace lua require('openterm').open_full_term(<q-args>, false,nil,true)
command! -nargs=? -complete=shellcmd -bar VTerm lua require('openterm').open_term(<q-args>, false, false)
command! -nargs=? -complete=shellcmd -bar HTerm lua require('openterm').open_term(<q-args>, true,false)
command! -nargs=? -complete=shellcmd -bar TermHere lua require('openterm').open_full_term(<q-args>, true)
command! -nargs=? -complete=shellcmd -bar VTermHere lua require('openterm').open_term(<q-args>, false, true)
command! -nargs=? -complete=shellcmd -bar HTermHere lua require('openterm').open_term(<q-args>, true, true)
command! Lgit :TermHere lazygit
nnoremap <leader>gg :Lgit<CR>
nnoremap <m-CR> :Term<CR>
nnoremap <c-CR> :VTerm<CR>
tnoremap <c-:><c-:><c-:> <C-\><C-n><c-w>h
tnoremap <c-"><c-"><c-"> <C-\><C-n>g<Tab>
"init lazy.nvim for plugins
let s:lazypath = stdpath("data").."/lazy/lazy.nvim"
if !s:lazypath->isdirectory()
	echo "lazyvim not found shall i load it using git?"
	let s:should_install_lazy = input("[Y/n]:","y")
	if s:should_install_lazy == "y" 
		echo "installing lazy.nvim"
		call system( "git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable ".. s:lazypath )
		let &runtimepath.=","..s:lazypath
		runtime lazy.lua
	endif
else
	let &runtimepath.=","..s:lazypath
	if !exists("g:lazy_sourced")
		let g:lazy_sourced=1
	runtime lazy.lua
endif
endif
