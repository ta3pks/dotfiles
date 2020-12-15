let g:polyglot_disabled = ['go']
let g:lsp_highlight_references_enabled = 0
call plug#begin('~/plugged')
" Plug 'fatih/vim-go'
" Plug 'neovimhaskell/haskell-vim'
Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-airline' | Plug 'vim-airline/vim-airline-themes'
Plug 'chr4/nginx.vim'
" Plug 'cstrahan/vim-capnp'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'dag/vim-fish'
Plug 'dart-lang/dart-vim-plugin'
Plug 'godlygeek/tabular'
Plug 'gregsexton/MatchTag'
Plug 'jiangmiao/auto-pairs'
Plug 'lifepillar/pgsql.vim'
Plug 'mattn/emmet-vim'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prettier/vim-prettier', { 'do': 'npm install' }
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdtree'| Plug 'Xuyuanp/nerdtree-git-plugin'| Plug 'ryanoasis/vim-devicons'
Plug 'sheerun/vim-polyglot'
Plug 'thosakwe/vim-flutter'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-dadbod'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/netrw.vim'
Plug 'wakatime/vim-wakatime'
call plug#end()
"plugin settings
let g:ctrlp_custom_ignore='node_modules/\|dist/\|target'
let g:go_fmt_autosave = 0
let g:go_mod_fmt_autosave = 0
let g:scratch_insert_autohide = 0
let g:airline_powerline_fonts = 0
let g:airline_theme='raven'
let NERDTreeWinSize = 30
nnoremap <silent><Leader>gg :Gstatus<CR>
nnoremap <Leader>p :Gpush<cr>
nnoremap <silent><Leader>nc :NERDTreeClose<cr>
nnoremap <silent><Leader>nt :NERDTreeToggle<cr>
nnoremap <silent><Leader>nf :NERDTreeFind<cr>
nnoremap <silent> <Leader>b :exec "Tabularize/".input("enter regex: ")."/"<cr>
nnoremap <C-b> :CtrlPBuffer<cr>
let g:user_emmet_settings = {
			\  'reason' : {
			\	   'extends' : 'jsx',
			\  },
			\  'typescriptreact' : {
			\	   'extends' : 'jsx',
			\  },
			\  'typescript' : {
			\	   'extends' : 'jsx',
			\  },
			\}
let g:user_emmet_leader_key = '<C-e>'
set signcolumn=auto
highlight LspErrorText ctermfg=green ctermbg=none
highlight LspErrorHighlight cterm=none
highlight LspWarningText ctermfg=yellow ctermbg=none
highlight LspWarningHighlight cterm=none
let g:lsp_diagnostics_enabled=1
let g:lsp_signs_enabled=1
let g:lsp_preview_float=0
let g:lsp_documentation_float=0
let g:lsp_signature_help_enabled=0
let g:lsp_highlight_references_enables=0
let g:lsp_highlight_references_delay = 100
function! s:on_lsp_buffer_enabled() abort
	setlocal omnifunc=lsp#complete
	nnoremap <buffer> <c-]> :LspDefinition<cr>
	nnoremap <buffer> \r :LspRename<cr>
	nnoremap  <buffer>K :LspHover<cr>
	nnoremap <buffer> \lr :LspReferences<cr>
	nnoremap  <buffer>\q :LspCodeAction<cr>
	nnoremap  <buffer><c-j> :LspNextDiagnostic<cr>
	nnoremap <buffer> <c-k> :LspPreviousDiagnostic<cr>
	nnoremap <buffer> \lf :LspDocumentFormat<cr>
	nnoremap <buffer> <M-C-L> :LspDocumentFormat<cr>
	nnoremap <buffer> \ld :LspDocumentDiagnostics<cr>
	nnoremap <buffer> \w :LspWorkspaceSymbol <cr>
endfunction
augroup lsp_install
	au!
	autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
let g:firenvim_config = {
			\ 'localSettings':{
			\ 'https://(www)?.facebook.com/':{'takeover':'never','priority':999}
			\ }
			\}
command! -nargs=1 PSQL DB postgresql://postgres:postgres@localhost <args>
