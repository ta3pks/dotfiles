let g:polyglot_disabled = ['go']
let g:lsp_highlight_references_enabled = 0
let g:LanguageClient_useFloatingHover=0
let g:LanguageClient_loggingFile =  expand('~/LanguageClient.log')
let g:LanguageClient_serverCommands = {
			\ 'rust': {
				\"name":"rust-analyzer",
				\"command":['rust-analyzer'],
				\"initializationOptions":{
					\"cargo":{ "loadOutDirsFromCheck": v:true },
					\"procMacro":{"enable": v:true},
					\ "lens":{"methodReferences": v:true }
					\}
				\},
			\ 'vim':['vim-language-server','--stdio']
			\ }

let g:LanguageClient_rootMarkers = ['.git']
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
Plug 'lifepillar/vim-gruvbox8'
Plug 'mattn/emmet-vim'
Plug 'mmahnic/vim-flipwords'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'dense-analysis/ale'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
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
colorscheme gruvbox8
"plugin settings
nnoremap \lst :LanguageClientStart<cr>
nnoremap \lss :LanguageClientStop<cr>
set completefunc=LanguageClient#complete
function LC_maps()
	if has_key(g:LanguageClient_serverCommands, &filetype)
		nmap <silent> <c-]> <Plug>(lcn-definition)
		nmap <silent> \r <Plug>(lcn-rename)
		nmap <silent> K <Plug>(lcn-hover)
		nmap <silent> \lr <Plug>(lcn-references)
		nmap <silent> \q <Plug>(lcn-code-action)
		nmap <silent> <M-C-l> <Plug>(lcn-format)
		nmap <silent> <M-C-i> :call LanguageClient#executeCodeAction('source.organizeImports')<cr>
		nmap <silent> <c-j> <Plug>(lcn-diagnostics-next) 
		nmap <silent> <c-k> <Plug>(lcn-diagnostics-prev) 
	endif
endfunction

autocmd FileType * call LC_maps()

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
