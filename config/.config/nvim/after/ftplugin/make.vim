nnoremap <buffer> mm :call <sid>run_make()<cr>
function! s:run_make()
	normal! _"pyt:
	vsp
	exe 'terminal make ' . @p
	normal! i
endfunction

