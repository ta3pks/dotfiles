map <plug>(set_done) :normal! _a DONE<CR>
map <plug>(set_todo) :normal! _a TODO<CR>
nnoremap <buffer> <leader>d <plug>(set_done)
inoremap <buffer> <leader>d <C-o><plug>(set_done)
nnoremap <buffer> <leader>t <plug>(set_todo)
inoremap <buffer> <leader>t <C-o><plug>(set_todo)
setlocal foldmethod=indent
