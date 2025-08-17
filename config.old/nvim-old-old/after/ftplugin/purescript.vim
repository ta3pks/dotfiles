set expandtab
let b:ale_fixers = ['purty']
nnoremap <buffer> \t :vsp \| exe 'term pulp test' \| normal! i <cr>
