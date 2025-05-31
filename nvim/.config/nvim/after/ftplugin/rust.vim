nnoremap <buffer> <leader>re :vsp term://cargo run<bar>normal! G<CR>
nnoremap <buffer> <leader>rc :e term://cargo clippy<bar>normal! G<CR>
nnoremap <buffer> <leader>cu :vsp term://cargo update<bar>normal! G<CR>
nnoremap <buffer> <leader>cU :vsp term://cargo upgrade<bar>normal! G<CR>
command -buffer -bar -nargs=* Cadd :vsp term://cargo add <args><bar>normal! i<CR>
command -buffer -bar -nargs=* Crm :vsp term://cargo remove <args><bar>normal! i<CR>
