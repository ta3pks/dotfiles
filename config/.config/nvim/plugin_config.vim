let g:polyglot_disabled = ['go']

call plug#begin('~/plugged') "{{{
Plug 'nathanaelkane/vim-indent-guides'
Plug 'subnut/nvim-ghost.nvim', {'do': ':call nvim_ghost#installer#install()'}
Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-airline' | Plug 'vim-airline/vim-airline-themes'
Plug 'chr4/nginx.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ctrlpvim/ctrlp.vim'
Plug 'dag/vim-fish'
Plug 'dart-lang/dart-vim-plugin'
Plug 'dNitro/vim-pug-complete', { 'for': ['jade', 'pug','vue'] }
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
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/netrw.vim'
Plug 'junegunn/vim-peekaboo'
Plug 'wakatime/vim-wakatime'
call plug#end() "}}}
" let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size=1
let g:indent_guides_start_level=2
let g:peekaboo_window="vert bo 100new"
let g:peekaboo_prefix="\\"
nmap <silent> <c-k> <Plug>(coc-diagnostic-prev)
nmap <silent> <c-j> <Plug>(coc-diagnostic-next)
nmap <silent> <c-]> <Plug>(coc-definition)
nmap <silent> \lr <Plug>(coc-references)
nmap <leader>r <Plug>(coc-rename)
xmap <M-C-l>  <Plug>(coc-format-selected)
nnoremap <silent> <M-C-l>  :call CocAction('format')<cr>
xmap <leader>q	<Plug>(coc-codeaction-selected)
nmap <leader>a	<Plug>(coc-codeaction-selected)
nmap <leader>q	<Plug>(coc-codeaction)
nmap <leader>f  <Plug>(coc-fix-current)
nnoremap <m-C-i> :CocList commands<cr>
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-e> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-e>"
  nnoremap <silent><nowait><expr> <C-y> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-y>"
  inoremap <silent><nowait><expr> <C-e> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-y> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-e> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-e>"
  vnoremap <silent><nowait><expr> <C-y> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-y>"
endif
command! -nargs=0 OR   :call	 CocAction('runCommand', 'editor.action.organizeImport')
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
inoremap <silent><expr> <C-Space>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-Space>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : "\<C-Space>"
nnoremap \\, :Flip , )<cr>


let g:coc_snippet_next = '<c-j>'
let g:coc_snippet_prev = '<c-k>'


nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
	execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
	call CocActionAsync('doHover')
  else
	execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction



let g:LanguageClient_rootMarkers = ['.git']
colorscheme gruvbox8_hard

let g:ctrlp_custom_ignore='node_modules/\|dist/\|target'
let g:go_fmt_autosave = 0
let g:go_mod_fmt_autosave = 0
let g:scratch_insert_autohide = 0
let g:airline_powerline_fonts = 0
let g:airline_theme='raven'
let NERDTreeWinSize = 30
nnoremap <silent><Leader>gg :wa\|tabnew\|exe "term lazygit"\|vert resize \|norm! i<CR>
" nnoremap <silent><Leader>gg :wa\| :Git<cr>
" nnoremap <Leader>p :Git push<cr>
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
let g:user_emmet_leader_key = "<m-e>"
set signcolumn=auto
autocmd BufReadPost *.tsx set ft=typescript.tsx
let g:firenvim_config = {
			\ 'localSettings':{
			\ 'https://(www)?.facebook.com/':{'takeover':'never','priority':999}
			\ }
			\}
command! -nargs=1 PSQL DB postgresql://postgres:postgres@localhost <args>
