	augroup golangCustom
		au! golangCustom
	augroup END
	let path=&path . ','.$GOPATH.'/src/'
	let &path=path
	nnoremap <buffer> <Leader>t <esc> :GoTest<cr>
	nnoremap <buffer> <Leader>gb :GoBuild<cr>
	nnoremap <buffer> <Leader>gi <esc> :execute 'GoImport' input('name:')<cr>
	nnoremap <buffer> <Leader>gk :GoKeyify<cr>
	nnoremap <buffer> <Leader>gm :GoMetaLinter<cr>
	nnoremap <buffer> <Leader>ga :execute 'GoAddTags' input('type: ')<cr>
	nnoremap <buffer> <Leader>gc :GoCallers<cr>
	nnoremap <buffer> <Leader>e :call <SID>RUNGO() <cr>
	nnoremap <buffer> <leader>[ :tabnew /tmp/main.go<CR>
	nnoremap <buffer> <C-d> :GoDecls<cr>
	nnoremap <buffer><silent> \\ :GoImports<cr>
	"SNIPPETS
	inoreabbr <buffer> {{{}}} //{{{//}}}<Up>
	inoreabbr <buffer> noimp fmt.Errorf("not implemented yet")
	inoreabbr <buffer> ferrf fmt.Errorf(":% <error message> %:")
	inoreabbr <buffer> td: //TODO:
	inoreabbr <buffer> meth func(:% struct %: :% <Type> %:) :% <funcName> %: (:% <params> %:):% <returnValues> %:{:% <funcBody> %:}
	inoreabbr <buffer> fnc func :% <funcName> %: (:% <params> %:):% <returnType> %:{:% <funcBody> %:}
	inoreabbr <buffer> tp type :%<name>%: :%<data>%:
	inoreabbr <buffer> hndl func :% <name> %:(w http.ResponseWriter,r *http.Request){:% <body> %:}
	inoreabbr <buffer> hndlp func :% <name> %:(w http.ResponseWriter,r *http.Request,p httprouter.Params){:% <body> %:}
	inoreabbr <buffer> hndlf http.HandlerFunc(func :% <name> %:(w http.ResponseWriter,r *http.Request){:% <body> %:})
	inoreabbr <buffer> mdlw func :% <name> %:(next http.Handler)http.Handler{<cr>:% <body> %:<cr>}
	inoreabbr <buffer> _tst func Test:%<Name>%:(t *testing.T){<cr>:%<Body>%:<cr>}
	inoreabbr <buffer> finit func init(){<cr>:%<Body>%:<cr>}
	inoreabbr <buffer> map map[:%<key>%:]:%<value>%:
	inoreabbr <buffer> mapi map[string]interface{}{:% <Body> %:}
	inoreabbr <buffer> _maps map[string]string{:% <Body> %:}
	inoremap <buffer> pln fmt.Println(":%str%:")
	function!  s:RUNGO()
			vsp
			execute 'term go run '.expand("%:p")
			normal! i
		endfunction
let b:ale_fixers = ['goimports','trim_whitespace' ]
let b:ale_linters = ['gobuild']
let b:fzf_command ="find . -type f -not -path './vendor/*' -not -path './.git/*'"
let g:go_code_completion_enabled = 1
let g:go_auto_sameids = 0
let g:go_jump_to_error = 0
let g:go_fmt_autosave = 0
let g:go_mod_fmt_autosave = 0
let g:go_term_enabled = 0
let g:go_term_close_on_exit = 0
let g:go_gopls_enabled = 1
let g:go_gopls_complete_unimported = 1
" let g:go_info_mode = 'gocode'
" let g:go_def_mode = 'gocode'
