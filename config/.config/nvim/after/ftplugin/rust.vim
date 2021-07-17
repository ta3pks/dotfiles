if !exists('g:rust_params')
	let g:rust_params = ''
endif
if !exists('g:rust_run_params')
	let g:rust_run_params = ''
endif
nnoremap <buffer> \e :wa \| call <SID>RUST_RUN("run ".g:rust_run_params )<cr>
nnoremap <buffer> \b : call <SID>RUST_RUN("build --workspace")<cr>
nnoremap <buffer> \t : call <SID>RUST_RUN("test -- --nocapture")<cr>
nnoremap <buffer> \tc : call <SID>RUST_RUN("test ".expand("<cword>")." -- --nocapture")<cr>
nnoremap <buffer> \c : call <SID>RUST_RUN("check --workspace ".g:rust_params)<cr>
nnoremap <buffer> \mc :make check<cr>
nnoremap <buffer> <c-m-l> :RustFmt<cr>



func! s:RUST_RUN(cmd)
	vsp
	exe "term bash -c 'cargo " . a:cmd . "'"
	normal! i
endfunction

command! ToRawStr :norm! da"ir##<esc>P
command! -nargs=+ CgAdd :!cargo add <args>

let b:ale_linters = ['cargo']
let g:rustfmt_autosave = 0
let g:rustfmt_command = 'rustfmt +nightly --edition=2018'
function! Tag()
	let file = findfile("Cargo.toml")
	if empty(trim(file)) == 1
		echo "no file"
		return
	endif
	let bufn = bufadd(file)
	exe "buf ".bufn
	call cursor(1,1)
	let line = search("version")
	let line_str = getline(line)
	let vers= substitute(line_str,'.*"\([^"]\+\)"',"\\1","")
	echo system("git tag v".vers)
endfunctio
nnoremap <buffer>\tt :call Tag()<cr>
command! -nargs=1 F vim /<args>/  ./**
nnoremap <buffer> \s :exe 'vim /'.input('key: ').'/ ./**'<cr>
let b:ale_fixers=[]
" let g:ale_rust_rls_executable='/usr/local/bin/rust-analyzer'
setlocal wildignore+=*/target/*,Cargo.lock,*/*test
let b:ale_linters=['analyzer']
let b:ale_fixers=['rustfmt']
let g:rustfmt_fail_silently = 1
let g:ale_rust_rustfmt_options="--edition 2018"
setl makeprg="make"
