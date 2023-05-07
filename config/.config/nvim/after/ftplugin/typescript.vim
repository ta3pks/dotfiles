let g:deno_app_flags = ""
nnoremap \e :exe "vsp \| term make run FLAGS='".g:deno_app_flags."'"\| normal! i<cr>
nnoremap \c :vsp\|exe "term make check " \|normal! i<cr>
setl wildignore=*/node_modules/*
function! Rust_to_ts()
	silent! global/#\[/d
	silent! %substitute/Vec<\([^>]\+\)>/\1[]/g
	silent! %substitute/\(\w\+\)\s*:\s*Option<\([^>]\+\)>/\1?:\2/g
	silent! %substitute/\(f\(64\|32\)\|i32\|i64\|usize\|u64\|u32\|isize\|u8\|i8\)/number/g
	silent! %substitute/String/string/g
	silent! %substitute/HashMap/Record/g
	silent! %substitute/bool\>/boolean/g
	silent! %substitute/pub enum \(\w\+\)/export type \1 = /g
	silent! %substitute/\<pub\> //g
	silent! %substitute/\<struct\> /export interface /g
endfunction
command! RustToTs :call Rust_to_ts()
setl makeprg=make
nnoremap \\e :make build<cr>
setl foldexpr=nvim_treesitter#foldexpr()
setl foldmethod=expr
