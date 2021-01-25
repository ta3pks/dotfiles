nnoremap \e :exe "vsp \| term deno run % "\| normal! i<cr>

nnoremap \c :vsp\|exe "term npx tsc --jsx react ".expand("%")\|normal! i<cr>

nnoremap \s :exe "vim /".input("search: ")."/ ./src/**"<cr>

setl wildignore=*/node_modules/*
function! Rust_to_ts()
	silent! global/#\[/d
	silent! %substitute/Vec<\([^>]\+\)>/\1[]/g
	silent! %substitute/\(\w\+\)\s*:\s*Option<\([^>]\+\)>/\1?:\2/g
	silent! %substitute/\(f\(64\|32\)\|i32\|i64\|isize\)/number/g
	silent! %substitute/String/string/g
	silent! %substitute/bool\>/boolean/g
	silent! %substitute/\<pub\> //g
	silent! %substitute/\<struct\> /export interface /g
endfunction
command! RustToTs :call Rust_to_ts()
