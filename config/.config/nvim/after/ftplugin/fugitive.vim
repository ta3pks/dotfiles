nnoremap <buffer> \sw :call <SID>SkipWorktree()<cr>
nnoremap <buffer> \sl :exe ':e .skipped_items \| set readonly' <cr>

function! s:SkipWorktree()
	let l:fname=split(getline('.'))[1]
	call system("git update-index --skip-worktree ".l:fname)
	call system("echo ".l:fname." >> .skipped_items")
	silent! e
endfunction

function! s:UnskipWorktree()
	set noreadonly
	let l:fname=getline('.')
	call system("git update-index --no-skip-worktree ".l:fname)
	normal! dd
	exe 'w'
	set readonly
endfunction

augroup __fugitive
	au!
	au BufLeave .skipped_items exe 'bd '.bufnr('.skipped_items')
	au BufWinEnter .skipped_items nnoremap <buffer> \su :call <SID>UnskipWorktree()<cr>
augroup END
