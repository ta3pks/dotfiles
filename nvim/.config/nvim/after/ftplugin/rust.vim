lua <<ENDLUA
require"openterm"
function CargoDeps()
	local deps = vim.fn.systemlist('cargo tree --depth=1 --prefix=none')
	vim.ui.select(deps,{},function(selected) end)
end
ENDLUA
command! -bar -buffer CargoDeps :lua CargoDeps()
command! -bar -buffer -nargs=+ Cargo :VTerm cargo <args>
command! -bar -buffer -nargs=+ CargoRun :Cargo <args>
command! -buffer -nargs=+ Cadd :CargoRun add <args>
command! -buffer -nargs=+ Crm :CargoRun rm <args>
command! -buffer -nargs=* Cupgrade :CargoRun upgrade <args>
command! -bar -buffer -nargs=* Cupdate :CargoRun update <args>
command! -buffer -nargs=* Ctest :exe "CargoRun nextest run --success-output=immediate --config-file=$HOME/.cargo/nextest.toml <args> -F ssr ".g:rusttest_params
"-- --nocapture

function! s:RustAddUse(...)
	if  a:0 == 0
		echoerr 'RustAddUse: params must not be empty'
		return
	endif

	let l:res =  a:000->copy()->map({_, v -> 'use '.v.';'})->append(0)
endfunction
command! -bar -buffer -nargs=+ Cuse :call <sid>RustAddUse(<f-args>)

if !exists('g:rustrun_params')
	let g:rustrun_params = ''
endif
if !exists('g:rusttest_params')
	let g:rusttest_params = ''
endif
function! s:SetRusttestParams()
	let g:rusttest_params = input('Test params: ',expand('<cword>'))
endfunction
function! s:SetRustrunParams()
	let g:rustrun_params = input('Run params: ')
endfunction
function! s:CurrentFuncName() abort
	let l:view = winsaveview()
	call search("fn \\zs\\w\\+\\ze(","b")
	let l:func_name = expand("<cword>")
	call winrestview(l:view)
	call luaeval("vim.notify('current: ".l:func_name."')")
	return l:func_name
endfunction
command! -bar -buffer FnName :echo <SID>CurrentFuncName()
nnoremap <silent> <buffer> <leader>cc :CargoRun clippy --all-targets --all-features <CR>
nnoremap <silent> <buffer> <leader>cu :CargoRun update<CR>
nnoremap <silent> <buffer> <leader>cU :CargoRun upgrade<CR>
nnoremap <silent> <buffer> <leader>er :exe 'Cargo run '.g:rustrun_params<CR>
nnoremap <silent> <buffer> <leader>ee :exe 'CargoRun run '.g:rustrun_params<CR>
nnoremap <silent> <buffer> <leader>es :call <sid>SetRustrunParams()<CR>
nnoremap <silent> <buffer> <leader>tt :Ctest<CR>
nnoremap <silent> <buffer> <leader>tc :let g:rusttest_params=<SID>CurrentFuncName()<bar>Ctest<CR>
nnoremap <silent> <buffer> <leader>ts :call <sid>SetRusttestParams()<CR>
command! -bar -nargs=? -complete=customlist,RustcWrapperComplete  RustcWrapper :let $RUSTC_WRAPPER = <q-args>
function! RustcWrapperComplete(...)
	return ['sccache']
endfunction
cnoreabbrev <silent> <buffer> rw RustcWrapper
cnoreabbrev <silent> <buffer> scc RustcWrapper sccache
autocmd BufWritePost *.rs silent! :silent! !ctags -R src/

function! MakeTokioTests(prefix="test_") range
	let l:fn_names = getline(a:firstline,a:lastline)->filter({_,v -> v->match("async fn") > -1})->map({_,v -> v->matchstr("async fn \\zs\\w\\+")})
	let l:fn_names = l:fn_names->map({_,v -> "#[tokio::test]" . "\n async fn " .a:prefix. v . "(){\nunimplemented!()\n}"})->join("\n")->setreg('')
endfunction
function! s:WrapType(ty)
	call feedkeys('"pdb')
	call feedkeys("i".a:ty."<\<c-o>\"pp>")
	return ""
endfunction
inoreabbrev <silent> <buffer><expr> _opt> <SID>WrapType("Option")
inoreabbrev <silent> <buffer><expr> _vec> <SID>WrapType("Vec")
cnoreabbrev <silent> <buffer> reload CocCommand rust-analyzer.reloadWorkspace
command! -bar -buffer LeptosFmt :silent !leptosfmt %
command! -bar CargoFmt :silent exe "!cargo fmt -- %"<bar>edit
