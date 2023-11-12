command! -bar -buffer -nargs=+ Cargo :exe "vsp | terminal cargo " . <q-args> | normal! G
command! -buffer -nargs=+ Cadd :Cargo add <args>
command! -buffer -nargs=+ Crm :Cargo rm <args>
command! -buffer -nargs=* Cupgrade :Cargo upgrade <args>
command! -buffer -nargs=* Cupdate :Cargo update <args>
command! -buffer -nargs=* Ctest :Cargo test <args>
if !exists('g:rustrun_params')
	let g:rustrun_params = ''
endif
if !exists('g:rusttest_params')
	let g:rusttest_params = ''
endif
function! s:SetRusttestParams()
	let g:rusttest_params = input('Test params: ')
endfunction
nnoremap <silent> <buffer> <leader>c :Cargo clippy --all-targets --all-features <CR>
nnoremap <silent> <buffer> <leader>e :exe 'Cargo run '.g:rustrun_params<CR>
nnoremap <silent> <buffer> <leader>tt :exe 'Cargo test '.g:rusttest_params.' -- --test-threads=1 --nocapture'<CR>
nnoremap <silent> <buffer> <leader>tc :exe "Cargo test ".expand("<cword>") . " -- --nocapture"<CR>
nnoremap <silent> <buffer> <leader>ts :call <sid>SetRusttestParams()<CR>
autocmd BufWritePost *.rs silent! :silent! !ctags -R src/
