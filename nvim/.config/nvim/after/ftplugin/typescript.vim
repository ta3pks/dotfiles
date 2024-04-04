setlocal tabstop=2
" lua << EOF
" local client_id = vim.lsp.start({
" 	name="deno lsp",
" 	cmd={"deno", "lsp"},
" 	init_options = { enable = true, lint = true, unstable = true },
" 	root_dir=vim.fs.dirname(vim.fs.find({"package.json",".git"},{upward = true})[1]),
" })
" vim.lsp.buf_attach_client(0, client_id)
" EOF
command -nargs=* -buffer -bar Deno exe "lua require'openterm'.open_term('sh -c \"deno " . <q-args> . "\"')"
nnoremap <silent> <buffer> <leader>c :exe "Deno run -A  ".expand("%")<CR>
nnoremap <silent> <buffer> <leader>e :exe "Deno run -A  main.ts"<CR>
let s:codi_interpreter = {
	\ 'bin': 'deno',
	\ 'prompt': "> ",
	\}
let g:codi#interpreters = {
			\'typescript': s:codi_interpreter,
			\}
setlocal shiftwidth=2 smartindent
