nnoremap <silent> \tn i--TODO: 
inoremap <silent> \tn --TODO: 
nnoremap <buffer> <Leader>e :call <sid>ElmRun(expand("%:p"))<cr>
setlocal expandtab
function! s:ElmRun(file)
	vsp
	exec 'term elm make "'.a:file.'" --output=/dev/null'
	normal! i
endfunction

setlocal foldenable
set foldmethod=indent
nnoremap <buffer> \t :vsp\|exe 'term elm-test'\|normal! i<cr>
let b:ale_linters = ['make']
let b:ale_fixers = ['elm-format']
" nnoremap <buffer> <c-]> :ALEGoToDefinition<cr>
" nnoremap <buffer> K :ALEHover<cr>
" nnoremap <buffer> <c-\> :ALEFindReferences<cr>
" nnoremap <buffer> \r :ALERename<cr>
setlocal wildignore=*.d,*.elmi,*.elmo,*/node_modules/*,*.dat,*/elm-stuff/*,*/lib/bs/*
