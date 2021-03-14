let g:polyglot_disabled = ['go']
let g:LanguageClient_serverCommands = {
			\'c': ['clangd'],
			\ 'haskell':['haskell-language-server-wrapper' ,'--lsp'],
			\ 'rust': {
				\"name":"rust-analyzer",
				\"command":['rust-analyzer'],
				\"initializationOptions":{
					\"cargo":{ "loadOutDirsFromCheck": v:true },
					\"procMacro":{"enable": v:true},
					\ "lens":{"methodReferences": v:true },
					\ "diagnostics":{"disabled":["macro-error"]}
					\}
				\},
			\ 'vim':['vim-language-server','--stdio'],
			\ 'typescript.tsx':['typescript-language-server','--stdio'],
			\ 'typescript':['typescript-language-server','--stdio'],
			\ 'javascript':['typescript-language-server','--stdio'],
			\ 'javascript.jsx':['typescript-language-server','--stdio'],
			\ 'svelte':['svelteserver','--stdio'],
			\ }

call plug#begin('~/plugged')
" Plug 'cstrahan/vim-capnp'
" Plug 'dense-analysis/ale'
" Plug 'fatih/vim-go'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'neovimhaskell/haskell-vim'
" Plug 'thosakwe/vim-flutter'
Plug 'airblade/vim-gitgutter'
Plug 'autozimu/LanguageClient-neovim', {  'branch': 'next',  'do': 'bash install.sh' }
Plug 'bling/vim-airline' | Plug 'vim-airline/vim-airline-themes'
Plug 'chr4/nginx.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'dag/vim-fish'
Plug 'dart-lang/dart-vim-plugin'
Plug 'freitass/todo.txt-vim'
Plug 'godlygeek/tabular'
Plug 'gregsexton/MatchTag'
Plug 'jiangmiao/auto-pairs'
Plug 'lifepillar/pgsql.vim'
Plug 'lifepillar/vim-gruvbox8'
Plug 'luochen1990/rainbow'
Plug 'mattn/emmet-vim'
Plug 'mmahnic/vim-flipwords'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdtree'| Plug 'Xuyuanp/nerdtree-git-plugin'| Plug 'ryanoasis/vim-devicons'
Plug 'sheerun/vim-polyglot'
Plug 'sirver/ultisnips'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-dadbod'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/netrw.vim'
Plug 'wakatime/vim-wakatime'
call plug#end()
let g:lsp_highlight_references_enabled = 0
let g:LanguageClient_useFloatingHover=0
let g:LanguageClient_loggingFile =  expand('~/LanguageClient.log')
let g:LanguageClient_showCompletionDocs = 0
let g:LanguageClient_diagnosticsList = "Location"
let g:rainbow_active = 1
function LC_maps()
	if has_key(g:LanguageClient_serverCommands, &filetype)
		nmap <silent> <c-]> <Plug>(lcn-definition)
		nmap <silent> \r <Plug>(lcn-rename)
		nmap <silent> K <Plug>(lcn-hover)
		nmap <silent> \lr <Plug>(lcn-references)
		nmap <silent> \q <Plug>(lcn-code-action)
		nmap <silent> <M-C-l> <Plug>(lcn-format)
		nmap <silent> <M-C-i> <Plug>(lcn-menu)
		nmap <silent> \ll <Plug>(lcn-code-lens-action)
		nmap <silent> \le <Plug>(lcn-explain-error)
		nmap <silent> <c-j> <Plug>(lcn-diagnostics-next)
		nmap <silent> <c-k> <Plug>(lcn-diagnostics-prev)
	endif
endfunction

let g:LanguageClient_rootMarkers = ['.git']
colorscheme gruvbox8
"plugin settings
nnoremap \lst :LanguageClientStart<cr>
nnoremap \lss :LanguageClientStop<cr>
set completefunc=LanguageClient#complete
autocmd FileType * call LC_maps()

let g:ctrlp_custom_ignore='node_modules/\|dist/\|target'
let g:go_fmt_autosave = 0
let g:go_mod_fmt_autosave = 0
let g:scratch_insert_autohide = 0
let g:airline_powerline_fonts = 0
let g:airline_theme='raven'
let NERDTreeWinSize = 30
nnoremap <silent><Leader>gg :Gstatus<CR>
nnoremap <Leader>p :Git push<cr>
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
let g:lsp_diagnostics_enabled=1
let g:lsp_signs_enabled=1
let g:lsp_preview_float=0
let g:lsp_documentation_float=0
let g:lsp_signature_help_enabled=0
let g:lsp_highlight_references_enables=0
let g:lsp_highlight_references_delay = 100
let g:ale_set_loclist=1
" function! s:on_lsp_buffer_enabled() abort
" set omnifunc=ale#completion#OmniFunc
let g:ale_completion_autoimport = 1
" endfunction
autocmd BufReadPost *.tsx set ft=typescript.tsx
let g:firenvim_config = {
			\ 'localSettings':{
			\ 'https://(www)?.facebook.com/':{'takeover':'never','priority':999}
			\ }
			\}
command! -nargs=1 PSQL DB postgresql://postgres:postgres@localhost <args>
