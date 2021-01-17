inoreabbr td: - [ ] :%<item>%:
setlocal spell
setlocal wrap
set foldenable
set foldmethod=indent
nmap <buffer><C-j> <Plug>(grammarous-move-to-next-error)
nmap <buffer><C-k> <Plug>(grammarous-move-to-previous-error)
nmap <buffer><C-f> <Plug>(grammarous-fixit)
nmap <buffer><C-d> <Plug>(grammarous-disable-rule)
nnoremap <buffer><C-c> :GrammarousCheck<cr>
let b:ale_fixers=['remark-lint']
let b:ale_linters=[]
setlocal nofoldenable
