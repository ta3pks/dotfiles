augroup golangCustom
	au! golangCustom
augroup END
let g:go_app_params = ""
nnoremap <buffer> <Leader>e :call <SID>RUNGO('run . ' . g:go_app_params) <cr>
nnoremap <buffer> <Leader>c :call <SID>RUNGO('vet .') <cr>
nnoremap <buffer> <Leader>gi :GoImports <cr>
function!  s:RUNGO(cmd)
	vsp
	execute 'term go ' . a:cmd 
	normal! i
endfunction
command! -buffer GoImports :CocCommand go.gopls.tidy
command! -buffer -nargs=+ Gta :CocCommand go.tags.add <args>
command! -buffer -nargs=+ Gtr :CocCommand go.tags.remove <args>
