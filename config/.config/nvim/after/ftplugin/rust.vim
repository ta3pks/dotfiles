if !exists('g:rust_params')
	let g:rust_params = ''
endif
nnoremap <buffer> \e : call <SID>RUST_RUN("run ". g:rust_params )<cr>
nnoremap <buffer> \b : call <SID>RUST_RUN("build --workspace")<cr>
nnoremap <buffer> \t : call <SID>RUST_RUN("test -- --nocapture")<cr>
nnoremap <buffer> \tc : call <SID>RUST_RUN("test ".expand("<cword>")." -- --nocapture")<cr>
nnoremap <buffer> \c : call <SID>RUST_RUN("check --workspace ".g:rust_params)<cr>

func! s:RUST_RUN(cmd)
	vsp
	exe "term bash -c 'cargo " . a:cmd . "'"
	normal! i
endfunction

command! ToRawStr :norm! da"ir##<esc>P
inoreabbr <buffer> pln println!(":%%:{}",:%%:);
inoreabbr <buffer> dbg_ dbg!(":%%:");
inoreabbr <buffer> fmt_ format!(":%%:{}",:%%:);
inoreabbr <buffer> _async Box::pin(async move{:% here %:});
inoreabbr <buffer> _str &'static str
inoreabbr <buffer> drv! #[derive(Clone,Debug:%%:)]
inoreabbr <buffer> epln eprintln!(":%%:{}",:%%:);
inoreabbr <buffer> test_ #[test]<cr> fn :% <name> %: () {:% < > %:}
inoreabbr <buffer> tests_ #[cfg(test)]<cr> mod tests <cr> {<cr> use super::*;<cr> :% %:<cr>}

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
command! -nargs=1 F vim /<args>/  src/**
nnoremap <buffer> \s :exe 'grep '.input('key: ').' -iR . --exclude-dir target --exclude-dir .git'<cr>
nnoremap <buffer> \f :RustFmt<cr>
let b:ale_fixers=[]
" let g:ale_rust_rls_executable='/usr/local/bin/rust-analyzer'
setlocal wildignore=*/target/*,Cargo.lock
let b:ale_linters=['analyzer']
let b:ale_fixers=['rustfmt']
let g:rustfmt_fail_silently = 0
let g:ale_rust_rustfmt_options="--edition 2018"
setl makeprg="make"
