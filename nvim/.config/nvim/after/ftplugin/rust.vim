nnoremap <buffer> <leader>re :vsp term://cargo run<bar>normal! G<CR>
nnoremap <buffer> <leader>rc :e term://cargo clippy<bar>normal! G<CR>
nnoremap <buffer> <leader>cu :vsp term://cargo update<bar>normal! G<CR>
nnoremap <buffer> <leader>cU :vsp term://cargo upgrade<bar>normal! G<CR>
command -buffer -bar -nargs=* Cadd :vsp term://cargo add <args><bar>normal! i<CR>
command -buffer -bar -nargs=* Crm :vsp term://cargo remove <args><bar>normal! i<CR>
" command -buffer -bar -nargs=* Ctst :vsp term://cargo t <args><bar>normal! i<CR>

" Global variable to store the test name
if !exists('g:rust_test_name')
  let g:rust_test_name = ''
endif

" Function to run a specific test with a variable name
" Parameter no_ask: if true, skips the input prompt and uses the existing test name
function! RunRustTest(no_ask) abort
  if !a:no_ask
    " Get test name from input, using existing value as default
    let g:rust_test_name = input('Test name: ', g:rust_test_name)
  endif
  
  execute 'vsp term://cargo t ' . g:rust_test_name
endfunction
function! RunRustRemoteTest(no_ask) abort
  if !a:no_ask
    " Get test name from input, using existing value as default
    let g:rust_test_name = input('Test name: ', g:rust_test_name)
  endif
  
  execute 'vsp term://~/.local/bin/remote_test.sh ' . g:rust_test_name
endfunction

" Map leader+rt to run the test function which asks for the name
nnoremap <buffer> <leader>tn :call RunRustTest(0)<CR>
" Map leader+rrt to rerun the last test without asking for input
nnoremap <buffer> <leader>tt :call RunRustTest(1)<CR>
nnoremap <buffer> <leader>trr :call RunRustRemoteTest(1)<CR>
nnoremap <buffer> <leader>tc :let g:rust_test_name=expand("<cword>")<bar>call RunRustTest(1)<CR>
nnoremap <buffer> <leader>trc :let g:rust_test_name=expand("<cword>")<bar>call RunRustRemoteTest(1)<CR>
