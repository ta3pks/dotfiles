set splitbelow splitright number relativenumber smartcase smartindent ignorecase nohlsearch incsearch smartindent foldenable exrc
set inccommand=split foldmethod=indent foldcolumn=0 foldlevelstart=99
if has("termguicolors")
	set termguicolors
endif
command! Ssrc source %
if has("nvim") 
	runtime nviminit.vim
else
	echo "no nvim skipping loading packages and stuff"
endif
function! Open_runtime_file(name)
	let fname = findfile(a:name, &runtimepath)
	if !empty(fname)
		exe 'edit' fname
	else
		echoerr "file not found in runtimepath: " . a:name
	endif
endfunction
function! NextClosedFold(dir)
    let cmd = 'norm!z'..a:dir
    let view = winsaveview()
    let [l0, l, open] = [0, view.lnum, 1]
    while l != l0 && open
        exe cmd
        let [l0, l] = [l, line('.')]
        let open = foldclosed(l) < 0
    endwhile
    if open
        call winrestview(view)
    endif
endfunction
function! RepeatCmd(cmd) range abort
    let n = v:count < 1 ? 1 : v:count
    while n > 0
        exe a:cmd
        let n -= 1
    endwhile
endfunction
command! -complete=file_in_path -nargs=1  RuntimeFile call Open_runtime_file(<f-args>)
nnoremap <silent> <C-w><c-l> :exe "tabnew ".$MYVIMRC->fnamemodify(':p:h'). "/after/ftplugin/".&ft.".vim"<bar>lcd %:p:h<CR>
nnoremap <silent> <C-w><c-s> :tabnew $MYVIMRC<bar>lcd %:p:h<CR>
nnoremap <silent> <C-w><c-p> :exe "tabnew ".$MYVIMRC->fnamemodify(':p:h'). "/lua/plugins/"<bar>lcd %:p:h<bar>call search("init.lua")<CR>
nnoremap <silent> <C-w><c-n> :tabnew<bar>call Open_runtime_file("nviminit.vim")<CR>
nnoremap <silent> # <C-^>
nnoremap <silent> <space> za
nnoremap <silent> zj :<c-u>call RepeatCmd('call NextClosedFold("j")')<cr>
nnoremap <silent> zk :<c-u>call RepeatCmd('call NextClosedFold("k")')<cr>
nnoremap <silent> z0 :set foldlevel=0<cr>
nnoremap <silent> z1 :set foldlevel=1<cr>
nnoremap <silent> z2 :set foldlevel=2<cr>
nnoremap <silent> z3 :set foldlevel=3<cr>
nnoremap <silent> z4 :set foldlevel=4<cr>
nnoremap <silent> <a-l> :if getqflist()->len() == 1 <bar> cfirst <bar> else <bar> cnext <bar> endif<cr>
nnoremap <silent> <a-h> :if getqflist()->len() == 1 <bar> cfirst <bar> else <bar> cprev <bar> endif<cr> 
