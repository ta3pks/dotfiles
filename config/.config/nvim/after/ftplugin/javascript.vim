" nnoremap <buffer> \e :!node %<cr>
let b:ale_linters=['eslint']
let b:ale_fixers=['eslint']
nnoremap <leader>e :vsp\|exe 'term zsh -c "frida -U Telegram -l telegram.js"'\|normal! i<cr>
