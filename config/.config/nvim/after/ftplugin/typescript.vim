nnoremap \rr :call <sid>runts()<cr>

function! s:runts()
	vsp
	term ts-node %
	normal! i
endfunction
nnoremap \c :vsp\|exe "term npx tsc ".expand("%")\|normal! i<cr>

nnoremap \s :exe "vim /".input("search: ")."/ ./src/**"<cr>

setl wildignore=*/node_modules/*
let b:ale_fixers=['xo']
