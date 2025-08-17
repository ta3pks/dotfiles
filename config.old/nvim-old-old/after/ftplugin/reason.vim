nnoremap \e :vsp <bar> exe "term npm run start" <bar> normal! i<cr>
nnoremap \c :vsp <bar> exe "term bsb -make-world"<bar>normal! i<cr>
nnoremap \t :vsp <bar> exe "term npm run test"<bar>normal! i<cr>
nnoremap \j :exe 'vsp '.expand('%:p:r').".bs.js"<cr>
set foldenable
set foldmethod=indent
let b:ale_fixers=['refmt']
" let b:ale_linters=['reason-language-server']
let b:ale_fixers=[]
let g:fzf_command = 'find src/ -type f &&find . -maxdepth 1 -type f'
" nnoremap <buffer> <c-]> :ALEGoToDefinition<cr>
" nnoremap <buffer> K :ALEHover<cr>
" nnoremap <buffer> <c-\> :ALEFindReferences<cr>
" nnoremap <buffer> \r :ALERename<cr>
let g:ale_reasonml_refmt_executable = "bsrefmt"
" let b:ale_reason_ls_executable = "reason-language-server"
