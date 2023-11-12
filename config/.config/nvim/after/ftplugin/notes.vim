map <plug>(set_done) :normal! _a DONE<CR>
map <plug>(set_todo) :normal! _a TODO<CR>
map <plug>(set_wip) :normal! A @WIP<CR>
nnoremap <buffer> <leader>d <plug>(set_done)
inoremap <buffer> <leader>d <C-o><plug>(set_done)<c-o>A
nnoremap <buffer> <leader>t <plug>(set_todo)
inoremap <buffer> <leader>t <C-o><plug>(set_todo)<c-o>A
nnoremap <buffer> <leader>w <plug>(set_wip)
inoremap <buffer> <leader>w <C-o><plug>(set_wip)
setlocal foldmethod=indent
