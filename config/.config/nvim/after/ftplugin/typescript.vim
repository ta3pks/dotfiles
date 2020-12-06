nnoremap \rr :call <sid>runts()<cr>

function! s:runts()
	vsp
	term ts-node %
	normal! i
endfunction
nnoremap \c :vsp\|exe "term npx tsc --noEmit --pretty ".expand("%")\|normal! i<cr>

setl wildignore=*/node_modules/*
