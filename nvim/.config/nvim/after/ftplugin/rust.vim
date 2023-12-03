command! -bar -buffer -nargs=+ Cargo :exe "vsp | terminal cargo " . <q-args> | normal! G
command! -buffer -nargs=+ Cadd :Cargo add <args>
command! -buffer -nargs=+ Crm :Cargo rm <args>
command! -buffer -nargs=* Cupgrade :Cargo upgrade <args>
command! -buffer -nargs=* Cupdate :Cargo update <args>
command! -buffer -nargs=* Ctest :Cargo test <args>

function! s:RustAddUse(...)
	if  a:0 == 0
		echoerr 'RustAddUse: params must not be empty'
		return
	endif

	let l:res =  a:000->copy()->map({_, v -> 'use '.v.';'})->append(0)
endfunction
command! -bar -buffer -nargs=+ Cuse :call <sid>RustAddUse(<f-args>)

if !exists('g:rustrun_params')
	let g:rustrun_params = ''
endif
if !exists('g:rusttest_params')
	let g:rusttest_params = ''
endif
function! s:SetRusttestParams()
	let g:rusttest_params = input('Test params: ')
endfunction
function! s:SetRustrunParams()
	let g:rustrun_params = input('Run params: ')
endfunction
nnoremap <silent> <buffer> <leader>cc :Cargo clippy --all-targets --all-features <CR>
nnoremap <silent> <buffer> <leader>cu :Cargo update<CR>
nnoremap <silent> <buffer> <leader>cU :Cargo upgrade<CR>
nnoremap <silent> <buffer> <leader>ee :exe 'Cargo run '.g:rustrun_params<CR>
nnoremap <silent> <buffer> <leader>es :call <sid>SetRustrunParams()<CR>
nnoremap <silent> <buffer> <leader>tt :exe 'Cargo test '.g:rusttest_params.' -- --test-threads=1 --nocapture'<CR>
nnoremap <silent> <buffer> <leader>tc :exe "Cargo test ".expand("<cword>") . " -- --nocapture"<CR>
nnoremap <silent> <buffer> <leader>ts :call <sid>SetRusttestParams()<CR>
autocmd BufWritePost *.rs silent! :silent! !ctags -R src/
