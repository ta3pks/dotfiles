if !exists('g:rust_params')
	let g:rust_params = ''
endif
if !exists('g:rust_run_params')
	let g:rust_run_params = ''
endif
nnoremap <buffer> \e :wa \| call <SID>RUST_RUN("run ".g:rust_run_params )<cr>
nnoremap <buffer> \b : call <SID>RUST_RUN("build")<cr>
nnoremap <buffer> \t : call <SID>RUST_RUN("test --workspace -- --nocapture --test-threads=1")<cr>
nnoremap <buffer> \tc :call <SID>RUST_RUN("test ".expand("<cword>")." -- --nocapture")<cr>
nnoremap <buffer> \ti :call <SID>RUST_RUN("test ".input("name of the test fn: ")." -- --nocapture")<cr>
nnoremap <buffer> \mc :make check<cr>
nnoremap <buffer> \c :call <SID>RUST_RUN("clippy --all-features  --workspace ".g:rust_params)<cr>
"nnoremap <buffer> <c-m-l> :RustFmt<cr>



func! s:RUST_RUN(cmd)
	vsp
	exe "term bash -c 'time cargo " . a:cmd . "'"
	normal! i
endfunction

command! ToRawStr :norm! da"ir##<esc>P
command! -nargs=+ CgAdd :!cargo add <args>

let g:rustfmt_autosave = 0
let g:rustfmt_command = 'rustfmt +nightly --edition=2018'
command! -nargs=1 F vim /<args>/  ./**
" nnoremap <buffer> \s :exe 'Ggrep -i "'.input('key: ').'"'<cr>
" nnoremap <buffer> \s :exe 'vim /'.input('search: ').'/  ./src/**'<cr>
" let g:ale_rust_rls_executable='/usr/local/bin/rust-analyzer'
setlocal wildignore+=*/target/*,Cargo.lock,*/*test
let g:rustfmt_fail_silently = 1
setl makeprg="make"
setl foldmethod=marker
setl nowrap
