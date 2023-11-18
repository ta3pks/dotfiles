command! -buffer -bar -nargs=+ Go :exe "vsp | term go ".<q-args> | normal! G
nnoremap <buffer> <leader>e :Go run main.go<CR>
