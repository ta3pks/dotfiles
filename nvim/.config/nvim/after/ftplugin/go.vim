" comman! -buffer -bar -nargs=+ Go :exe "vsp | term go ".<q-args> | normal! G
comman! -buffer -bar -nargs=+ Go :wa<bar>lua require"openterm".open_term("go <args>|pbcopy")
nnoremap <buffer> <leader>e :Go run .<CR>
