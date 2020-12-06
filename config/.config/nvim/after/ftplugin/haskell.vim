nnoremap <buffer><Leader>e :call <sid>GHCI()<cr>
nnoremap <buffer><Leader>t :call <sid>GHCI_TEST()<cr>
func! s:GHCI_TEST()
	vsp
	term stack test
	normal! i
endfunction
func! s:GHCI()
	vsp
	term stack ghci
	normal! i
endfunction
setlocal expandtab

let b:ale_linters = ["stack_build","stack_ghc","hie"]
