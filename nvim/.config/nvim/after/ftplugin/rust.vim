lua <<ENDLUA
function CargoFloatTerm(args)
		require"openterm".open_full_term("cargo ".. args ,true,function() 
			vim.fn.setqflist({})
			vim.o.modifiable = true
			vim.cmd[[
			%s/--> //g
			cgetbuffer
			cfirst
			]]
			if #vim.fn.getqflist()>0 then
				vim.notify('errors loaded into quickfix list', vim.log.levels.WARN)
			end
		end)
end
function CargoDeps()
	local deps = vim.fn.systemlist('cargo tree --depth=1 --prefix=none')
	vim.ui.select(deps,{},function(selected) end)
end
ENDLUA
command! -bar -buffer CargoDeps :lua CargoDeps()
command! -bar -buffer -nargs=+ Cargo :exe "vsp | terminal cargo " . <q-args> | normal! G
command! -bar -buffer -nargs=+ CargoFloat :lua CargoFloatTerm(<q-args>)<CR>
command! -buffer -nargs=+ Cadd :CargoFloat add <args>
command! -buffer -nargs=+ Crm :CargoFloat rm <args>
command! -buffer -nargs=* Cupgrade :CargoFloat upgrade <args>
command! -bar -buffer -nargs=* Cupdate :CargoFloat update <args>
command! -buffer -nargs=* Ctest :CargoFloat testf <args> -- --nocapture

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
	let g:rusttest_params = input('Test params: ')
endfunction
function! s:SetRustrunParams()
	let g:rustrun_params = input('Run params: ')
endfunction
nnoremap <silent> <buffer> <leader>cc :CargoFloat clippy --all-targets --all-features <CR>
nnoremap <silent> <buffer> <leader>cu :CargoFloat update<CR>
nnoremap <silent> <buffer> <leader>cU :CargoFloat upgrade<CR>
nnoremap <silent> <buffer> <leader>ee :exe 'Cargo run '.g:rustrun_params<CR>
nnoremap <silent> <buffer> <leader>ef :exe 'CargoFloat run '.g:rustrun_params<CR>
nnoremap <silent> <buffer> <leader>es :call <sid>SetRustrunParams()<CR>
nnoremap <silent> <buffer> <leader>tt :exe 'Ctest '.g:rusttest_params<CR>
nnoremap <silent> <buffer> <leader>tc :let g:rusttest_params=expand("<cword>")<bar>exe 'Ctest '.g:rusttest_params<CR>
nnoremap <silent> <buffer> <leader>ts :call <sid>SetRusttestParams()<CR>
command! -bar -nargs=? -complete=customlist,RustcWrapperComplete  RustcWrapper :let $RUSTC_WRAPPER = <q-args>
function! RustcWrapperComplete(...)
	return ['sccache']
endfunction
cnoreabbrev <silent> <buffer> rw RustcWrapper
cnoreabbrev <silent> <buffer> scc RustcWrapper sccache
if !"g:rustc_wrapper_sccache_set"->exists()
	let g:rustc_wrapper_sccache_set = 1
	let $RUSTC_WRAPPER = 'sccache'
endif
autocmd BufWritePost *.rs silent! :silent! !ctags -R src/

function! MakeTokioTests(prefix="") range
	let l:fn_names = getline(a:firstline,a:lastline)->filter({_,v -> v->match("async fn") > -1})->map({_,v -> v->matchstr("async fn \\zs\\w\\+")})
	let l:fn_names = l:fn_names->map({_,v -> "#[tokio::test]" . "\n async fn " .a:prefix. v . "(){\nunimplemented!()\n}"})->join("\n")->setreg('')
endfunction
function! s:WrapType(ty)
	call feedkeys('b"pdw')
	call feedkeys("i".a:ty."<".@p.">")
	return ""
endfunction
inoreabbrev <silent> <buffer><expr> _opt <SID>WrapType("Option")
inoreabbrev <silent> <buffer><expr> _vec <SID>WrapType("Vec")
