nnoremap <silent><buffer> <c-n> :call search('TODO ')<CR>
nnoremap <silent><buffer> <c-p> :call search('TODO ', 'b')<CR>
nnoremap <silent><buffer> ZZ :w<bar>bd<cr>
function! s:SetState(init,latter)
	let l:line = getline('.')
	let l:line = substitute(l:line, a:init, a:latter, '')
	call setline('.', l:line)
endfunction
function! s:AddTag(tag)
	let l:line = getline('.')
	if l:line =~ '@'.a:tag
		let l:line = substitute(l:line, '@'.a:tag, '', '')
	else
		let l:line = l:line->trim(). ' @'.a:tag
	endif
	call setline('.', l:line->trim())
endfunction
nnoremap <silent><buffer> <leader>d :call <sid>SetState('TODO', 'DONE')<cr>
nnoremap <silent><buffer> <leader>w :call <sid>AddTag('WIP')<cr>
cnoreabbrev <buffer> wq w<bar>bd
