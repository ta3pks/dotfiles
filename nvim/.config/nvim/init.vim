set splitbelow splitright number relativenumber smartcase smartindent ignorecase incsearch smartindent foldenable exrc
set inccommand=split foldmethod=indent foldcolumn=0 foldlevelstart=99 conceallevel=0 concealcursor= ts=4 expandtab shiftwidth=4
if has("termguicolors")
	set termguicolors
endif
nnoremap <space>q :bd<cr>
command! Ssrc source %
command! Time :echo strftime("%c")
if has("nvim") 
	runtime nviminit.vim
else
	echo "no nvim skipping loading packages and stuff"
endif
function! Open_runtime_file(name)
	let fname = findfile(a:name, &runtimepath)
	if !empty(fname)
		exe 'edit' fname
		lcd %:p:h
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
nnoremap <silent> <c-q><c-l> :tabnext #<cr>
inoremap <silent> <c-q><c-l> <c-o>:tabnext #<cr>
tnoremap <silent> <c-q><c-l> <c-\><c-n>:tabnext #<cr>

command! -complete=custom,ConfigPathCompltetion -nargs=1  RuntimeFile call Open_runtime_file(<f-args>)
nnoremap <silent> <C-w><c-l> :exe "tabnew ".$MYVIMRC->fnamemodify(':p:h'). "/after/ftplugin/".&ft.".vim"<bar>lcd %:p:h<CR>
nnoremap <silent> <C-w><c-c> :exe "tabnew ".$MYVIMRC->fnamemodify(':p:h'). "/chords/".&ft.".vim"<bar>lcd %:p:h<CR>
nnoremap <silent> <C-w><c-s> :tabnew $MYVIMRC<bar>lcd %:p:h<CR>
nnoremap <silent> <C-w><c-p> :exe "tabnew ".$MYVIMRC->fnamemodify(':p:h'). "/lua/plugins/"<bar>lcd %:p:h<bar>call search("init.lua")<CR>
nnoremap <silent> <C-w><c-n> :tabnew<bar>call Open_runtime_file("nviminit.vim")<CR>
nnoremap <silent> # <C-^>
" nnoremap <silent> <space> za
nnoremap <silent> zj :<c-u>call RepeatCmd('call NextClosedFold("J")')<cr>
nnoremap <silent> zk :<c-u>call RepeatCmd('call NextClosedFold("K")')<cr>
nnoremap <silent> z0 :set foldlevel=0<cr>
nnoremap <silent> z1 :set foldlevel=1<cr>
nnoremap <silent> z2 :set foldlevel=2<cr>
nnoremap <silent> z3 :set foldlevel=3<cr>
nnoremap <silent> z4 :set foldlevel=4<cr>
nnoremap <silent> <a-l> :if getqflist()->len() == 1 <bar> cfirst <bar> else <bar> cnext <bar> endif<cr>
nnoremap <silent> <a-h> :if getqflist()->len() == 1 <bar> cfirst <bar> else <bar> cprev <bar> endif<cr> 
function! ToSnakeCase()
	let l:cword = expand("<cword>")
	let l:snake_case = substitute(l:cword, '\(\u\)', '_\l\1', 'gI')->substitute("^_", "", "")
	echo l:snake_case
	let @v = l:snake_case
	normal! viw"vp
endfunction
vnoremap <c-c> "+ygv
inoreabbrev todo: <c-r>=printf(&commentstring, "TODO:")<cr>
if exists("g:neovide")
	let g:neovide_cursor_vfx_mode = ""
	let g:neovide_transparency = 0.96
	let g:neovide_scroll_animation_length = 0.1
	let g:neovide_refresh_rate = 15
	let g:neovide_refresh_rate_idle = 1
	let g:neovide_fullscreen = v:true
	let g:neovide_input_macos_alt_is_meta = v:true
	let g:neovide_cursor_animation_length = 0.02
	let g:neovide_cursor_trail_size = 0.1

endif
function! ConfigPathCompltetion(ArgLead, CmdLine, CursorPos)
	return globpath($MYVIMRC->fnamemodify(':p:h'), "**/*")
endfunction
" custom text objects
vnoremap iS i'
vnoremap aS a'
vnoremap is i"
vnoremap as a"
vnoremap ia i<
vnoremap aa a<
onoremap iS i'
onoremap aS a'
onoremap is i"
onoremap as a"
onoremap ia i<
onoremap aa a<
nnoremap <leader>gp :VTerm tgpt -i<cr>
command Wsudo w !SUDO_ASKPASS=`which ssh-askpass` sudo tee % > /dev/null
cnoreabbrev wsudo Wsudo
