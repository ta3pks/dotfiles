if !exists('g:rust_params')
	let g:rust_params = ''
endif
if !exists('g:rust_run_params')
	let g:rust_run_params = ''
endif
if !exists('g:rust_test_params')
	let g:rust_test_params = ''
endif
nnoremap <buffer> \e :wa \| call <SID>RUST_RUN("run ".g:rust_run_params )<cr>
nnoremap <buffer> \b : call <SID>RUST_RUN("build")<cr>
nnoremap <buffer> \t : call <SID>RUST_RUN("test --all-features --workspace ".g:rust_test_params." -- --nocapture --test-threads=1")<cr>
nnoremap <buffer> \tc :call <SID>RUST_RUN("test --all-features --workspace ".expand("<cword>")." -- --nocapture  --test-threads=1")<cr>
nnoremap <buffer> \ti :call <SID>RUST_RUN("test --all-features --workspace ".input("name of the test fn: ")." -- --nocapture --test-threads=1")<cr>
nnoremap <buffer> \mc :make check<cr>
nnoremap <buffer> \c :call <SID>RUST_RUN("clippy --release --all-features  --workspace ".g:rust_params)<cr>
"nnoremap <buffer> <c-m-l> :RustFmt<cr>



func! s:RUST_RUN(cmd)
	vsp
	exe "term bash -c 'time cargo " . a:cmd . "'"
	normal! i
endfunction

command! ToRawStr :norm! da"ir##<esc>P
let g:rustfmt_autosave = 0
let g:rustfmt_command = 'rustfmt +nightly --edition=2018'
command! -nargs=1 F vim /<args>/  ./**
" nnoremap <buffer> \s :exe 'Ggrep -i "'.input('key: ').'"'<cr>
" nnoremap <buffer> \s :exe 'vim /'.input('search: ').'/  ./src/**'<cr>
" let g:ale_rust_rls_executable='/usr/local/bin/rust-analyzer'
setlocal wildignore+=*/target/*,Cargo.lock,*/*test
let g:rustfmt_fail_silently = 1
setl makeprg="make"
setl nowrap
setl foldmethod=indent

command! -buffer -nargs=*  Cfeat :call <SID>RUST_RUN('feature '.'<args>')
command! -buffer -nargs=+  Cadd :call <SID>RUST_RUN('add '.'<args>')
command! -buffer -nargs=+  Crm :call <SID>RUST_RUN('rm ' . '<args>')
command! -buffer -nargs=*  Cupdate :call <SID>RUST_RUN('update '.'<args>')
command! -buffer -nargs=*  Cupgrade :call <SID>RUST_RUN('upgrade '.'<args>')
command! -buffer -nargs=*	 Bump :!cargo bump <args>
command! -buffer  MBump :!cargo bump minor
command! -buffer  PBump :!cargo bump patch
command! -buffer  VBump :!cargo bump major
command! -buffer -nargs=1 RustUse :normal! mcggOuse <args>;<esc>`c
