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
	runtime lazy.lua
endif
function! s:termbindings()
	nnoremap <buffer> <c-j> :call search("--> \\zs\\w","s")<cr>:<esc>
	nnoremap <buffer> <c-k> :call search("--> \\zs\\w","sb")<cr>:<esc>
	nnoremap <buffer> q i<c-c>
	nnoremap <buffer> <cr> <C-w>gF
endfunction
autocmd TermOpen * call s:termbindings()
nnoremap \gg :lua require"openterm".open_full_term("lazygit",true)<CR>
