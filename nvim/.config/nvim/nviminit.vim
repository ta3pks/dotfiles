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


function! s:SetQfListFromTermOnQuit()
	" :call setqflist([])<bar>caddexpr getline(0,"$")->filter({_,l -> match(l,"-->")>-1})->map({_,v -> v->substitute("\\s*-->\\s*","","")->trim()})<cr><bar>i<c-c><bar>:cnext<cr>
	call setqflist([])
	caddexpr getline(0,"$")->filter({_,l -> match(l,"-->")>-1})->map({_,v -> v->substitute("\\s*-->\\s*","","")->trim()})
	call feedkeys("i\<c-c>")
	let l:term_buf = bufnr("%")
	function! s:check_qf(term_buf)
		if bufnr("%") == a:term_buf
			call timer_start(100,{-> s:check_qf(a:term_buf)})
			return
		endif
		if getqflist()->len()>0
			copen
		endif
	endfunction
	call s:check_qf(l:term_buf)
endfunction
function! s:termbindings()
	nnoremap <buffer> <c-j> :call search("--> \\zs\\w","s")<cr>:<esc>
	nnoremap <buffer> <c-k> :call search("--> \\zs\\w","sb")<cr>:<esc>
	nnoremap <buffer> q :call <sid>SetQfListFromTermOnQuit()<cr>:<esc>
	nnoremap <buffer> <cr> <C-w>gF
endfunction
autocmd TermOpen * call s:termbindings()
nnoremap \gg :lua require"openterm".open_full_term("lazygit",true)<CR>
