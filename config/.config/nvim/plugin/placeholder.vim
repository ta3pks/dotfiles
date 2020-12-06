func! s:NextPlaceHolder()
	let [l:sline,l:scol]=searchpos(":%[^%]*%:")
	if l:sline==0
		return
	endif
	let [l:eline,l:ecol]=searchpos("%:")
	call cursor([l:sline,l:scol])
	let l:line=getline(".")
	if l:scol==1
		let l:line=l:line[l:ecol+1:]
	else
		let l:line=l:line[:l:scol-2].l:line[l:ecol+1:]
	endif
	call setline(l:sline,l:line)
	call feedkeys("i")
endfunc
inoremap <silent>;; :call <SID>NextPlaceHolder()
inoreabbr plhd :%%:<left><left>
