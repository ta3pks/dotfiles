let b:ale_linters=['jsonlint']
let b:ale_fixers=['jq']
setl foldmethod=indent
nnoremap <buffer><silent> \e :lua require('plugins.openterm').open_full_term("ijq "..vim.fn.fnameescape(vim.fn.expand("%:p")),false)<cr>
