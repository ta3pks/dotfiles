set encoding=utf8
scriptencoding utf-8
au!
"settings
syntax on
set t_Co=256
au colorscheme * hi spellrare ctermbg=none cterm=underline|hi spellbad cterm=underline ctermbg=none|hi SignColumn ctermbg=black|hi folded ctermbg=none ctermfg=1
set completeopt=noinsert,menuone,noselect
set nofoldenable
set backupcopy=yes
set hidden
"sets
set inccommand=split
set modeline
set ignorecase
set numberwidth=1
set smartcase
set background=dark
set linebreak
set nowrap
set tabstop=4
set noexpandtab
set shiftwidth=4
set list
set listchars=tab:\|\ ,eol:\ ,space:┆
set nohlsearch
set wildignorecase
set nospell
set splitbelow
set splitright
set number
set mouse=
set relativenumber
set autoindent
set noautochdir
set backspace=2
"registers


"""""""""""
if has('nvim')
	func! OpenTerm(down)
		if a:down==1
			sp
		else
			vsp
		endif
		term
		normal! i
	endfunction
	noremap <silent> <Leader><cr> :call OpenTerm(0) <cr>
	noremap <silent> <Leader>] :call OpenTerm(1) <cr>
else
	noremap <Leader><cr> <ESC>:!tmux a -t vim<cr>
endif
augroup __mysettings
	au!
	autocmd bufenter * :checktime
	" autocmd VimLeavePre * :mksession! ./Session.vim
	autocmd VimEnter * :call LoadSession()
	autocmd vimenter * :let g:b=system('pwd')
	autocmd vimenter * :call Load_project_config()
	autocmd BufWritePost /tmp/copy.md :silent 1,$yank +
	autocmd BufEnter /tmp/copy.md :execute "normal! ggdG" | :put! +
augroup END
function! OpenFtPlugin()
	let ft = &ft
	if empty(ft)
		echo "unknown filetype"
		exe "tabnew ~/.config/nvim/after/ftplugin/"
		return
	endif
	exe "tabnew ~/.config/nvim/after/ftplugin/".ft.".vim"
endfunction
"maps
nnoremap <Space> za
nnoremap <silent><C-w>r <esc>:so $MYVIMRC<cr>
nnoremap <silent><C-w><C-s> <esc>:tabnew $MYVIMRC<cr>
nnoremap <silent><C-w><C-p> <esc>:tabnew ~/.config/nvim/plugin_config.vim<cr>
nnoremap <silent><C-w><C-l> <esc>:call OpenFtPlugin()<cr>
nnoremap <silent><Leader>l :set list!<cr>
nnoremap <silent> Q :q<cr>
nnoremap <silent> <C-s> :set spell!<cr>
nnoremap <C-k> :lprevious<cr>
nnoremap <C-j> :lnext<cr>
nnoremap <C-f> :lfirst<cr>
nnoremap <C-h> :cprevious<cr>
nnoremap <C-l> :cnext<cr>
nnoremap # :b #<cr>
nnoremap <Up> <NOP>
nnoremap <Down> <NOP>
nnoremap <Left> <NOP>
nnoremap <Right> <NOP>
"functions
function! LoadSession()
	if argc()==0 && filereadable("Session.vim")
		silent! source ./Session.vim
	endif
endfunction
function! Load_project_config()
if filereadable('project.vim')
	source project.vim
	echo 'sourced project file'
endif
endfunction
let g:keybase_username=""
function! Keybase_read()
	if exists('g:keybase_username')
		let l:uname = g:keybase_username
	else
		let l:uname = input('username: ')
	endif
	let l:messages=system("keybase chat read --at-least='15' ".l:uname)
	echo l:messages
endfunction
function! Keybase_send()
	if exists('g:keybase_username')
		let l:uname = g:keybase_username
	else
		let l:uname = input('username: ')
	endif
	let l:_msg=input('message: ')
	let l:msg='keybase chat send '.l:uname.' "'.l:_msg . '"'
	call system(l:msg)
endfunction
function! Keybase_upload()
	if exists('g:keybase_username')
		let l:uname = g:keybase_username
	else
		let l:uname = input('username: ')
	endif
	call system('xclip -selection clipboard -o > /tmp/clipboard.png')
	call system('keybase chat upload '.l:uname.' /tmp/clipboard.png')
endfunction
function! Keybase_download()
	if exists('g:keybase_username')
		let l:uname = g:keybase_username
	else
		let l:uname = input('username: ')
	endif
	let l:fileno=input('img id: ')
	call system('keybase chat download '.l:uname.' '.l:fileno.' > /tmp/attachment.png && mirage /tmp/attachment.png')
endfunction
nnoremap <silent> \kr :call Keybase_read()<cr>
nnoremap <silent> \ks :call Keybase_send()<cr>
nnoremap <silent> \kl :echo system("keybase chat list")<cr>
nnoremap <silent> \ku :call Keybase_upload()<cr>
nnoremap <silent> \kd :call Keybase_download()<cr>
" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" inoremap <expr> <CR> (pumvisible() ? "\<c-y>" : "\<CR>")
inoremap <a-v> <C-r>=system('xclip -o -selection clipboard')<cr>
if has('nvim')
"plugin config
source ~/.config/nvim/plugin_config.vim
endif
command! FixTrailing :%s/\s\+$//g
" nnoremap \sr :call writefile(["/tmp/updated"],"/tmp/updated")<cr>
set foldmethod=marker
