nnoremap <buffer><Leader>e :call <sid>RUN()<cr>
nnoremap <buffer><Leader>c :exe "vsp \| term cabal test" \| normal i<cr>
func! s:RUN()
	vsp
	term runghc %
	normal! i
endfunction
setlocal expandtab
