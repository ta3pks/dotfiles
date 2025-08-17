inoreabbr td: - [ ] :%<item>%:
setlocal spell
setlocal wrap
setlocal foldmethod=indent
nmap <buffer><C-j> <Plug>(grammarous-move-to-next-error)
nmap <buffer><C-k> <Plug>(grammarous-move-to-previous-error)
nmap <buffer><C-f> <Plug>(grammarous-fixit)
nmap <buffer><C-d> <Plug>(grammarous-disable-rule)
nnoremap <buffer><C-c> :GrammarousCheck<cr>
let b:ale_fixers=['remark-lint']
let b:ale_linters=[]
setlocal foldenable
let b:copilot_enabled = 1
