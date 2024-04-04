if !exists("s:loaded") && filereadable(expand("<sfile>:p:h")."/rust.vim") 
	exe "source ".expand("<sfile>:p:h")."/rust.vim"
	let s:loaded = 1
endif
