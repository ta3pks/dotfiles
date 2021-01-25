nnoremap \rr :call <sid>runts()<cr>

function! s:runts()
	vsp
	term ts-node %
	normal! i
endfunction
nnoremap \c :vsp\|exe "term npx tsc --jsx react ".expand("%")\|normal! i<cr>

nnoremap \s :exe "vim /".input("search: ")."/ ./src/**"<cr>

setl wildignore=*/node_modules/*
function! Rust_to_ts()
	silent! %substitute/Vec<\([^>]\+\)>/\1[]/g
	silent! %substitute/Option<\([^>]\+\)>/\1/g
	silent! %substitute/\(f\(64\|32\)\|i32\|i64\)/number/g
	silent! %substitute/String/string/g
	silent! %substitute/bool/boolean/g
endfunction
command! RustToTs :call Rust_to_ts()
