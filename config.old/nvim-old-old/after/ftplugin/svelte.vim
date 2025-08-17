setl foldmethod=indent
command! -buffer -nargs=+ Npmi :vsp \| exe 'term sh -c "npm i <args>"' \| normal! i
