let g:polyglot_disabled = ['go']
call plug#begin('~/plugged') "{{{
"Plug 'chr4/nginx.vim'
Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-airline' | Plug 'vim-airline/vim-airline-themes'
Plug 'nvim-lua/plenary.nvim'|Plug 'nvim-telescope/telescope.nvim'|Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'hsanson/vim-openapi'
Plug 'dNitro/vim-pug-complete', { 'for': ['jade', 'pug','vue'] }
Plug 'tomtom/tcomment_vim'
Plug 'dag/vim-fish'
Plug 'github/copilot.vim'
Plug 'godlygeek/tabular'
Plug 'gregsexton/MatchTag'
Plug 'jacoborus/tender.vim'
Plug 'mattn/emmet-vim'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'mmahnic/vim-flipwords'
Plug 'neoclide/coc.nvim', {'branch': 'release' }
Plug 'rafcamlet/coc-nvim-lua'
Plug 'rakr/vim-one'
Plug 'rust-lang/rust.vim', {'for': ['rust']}
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'wakatime/vim-wakatime'
call plug#end() "}}}
command -nargs=* Swap Flip <args>
colorscheme one
command -nargs=0 SwapArgs Swap , )
let g:rainbow#pairs = [['(', ')'], ['[', ']'] , ['{', '}']]
let g:rainbow#blacklist = ['#cc241d']
autocmd FileType * RainbowParentheses
nmap <silent> <c-k> <Plug>(coc-diagnostic-prev)
nmap <silent> <c-j> <Plug>(coc-diagnostic-next)
nmap <silent> <c-]> <Plug>(coc-definition)
nmap <silent> \lr <Plug>(coc-references)
nmap <leader>r <Plug>(coc-rename)
xmap <M-C-l>  <Plug>(coc-format-selected)
nnoremap <silent> <M-C-l>  :call CocAction('format')<cr>
xmap <silent><leader>q	<Plug>(coc-codeaction-selected)
nmap <silent><leader>a	<Plug>(coc-codeaction)
nmap <silent><m-.>	<plug>(coc-codeaction-cursor)
nmap <silent><m-,>	<Plug>(coc-fix-current)
nnoremap <m-s> :CocList symbols<cr>
nnoremap <m-d> :CocList diagnostics<cr>
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
			\ pumvisible() ? coc#_select_confirm():
			\ coc#expandableOrJumpable() ? "\<C-Space>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : "\<C-Space>"
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
			\: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" Use <c-space> to trigger completion.
if has('nvim')
	inoremap <silent><expr> <c-space> coc#refresh()
else
	inoremap <silent><expr> <c-@> coc#refresh()
endif
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


let g:ctrlp_custom_ignore='node_modules/\|dist/\|target'
let g:scratch_insert_autohide = 0
let g:airline_powerline_fonts = 0
let g:airline#extensions#whitespace#enabled = 0
let g:airline_theme='one'
let NERDTreeWinSize = 30
" nnoremap <silent><Leader>gg :wa\|tabnew\|exe "term lazygit"\|vert resize \|norm! i<CR>
nnoremap <silent><Leader>gg :wa\| :Git<cr>
" nnoremap <Leader>p :Git push<cr>
nnoremap <silent><Leader>nc :NERDTreeClose<cr>
nnoremap <silent><Leader>nt :NERDTreeToggle<cr>
nnoremap <silent><Leader>nf :NERDTreeFind<cr>
nnoremap <silent> <Leader>b :exec "Tabularize/".input("enter regex: ")."/"<cr>
nnoremap <C-b> :Telescope buffers<cr>
nnoremap <leader>s :Telescope live_grep<cr>
nnoremap <c-\> :Telescope resume<cr>
nnoremap <C-p> :Telescope find_files<cr>
nnoremap <C-f> :Telescope grep_string<cr>
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
if (empty($TMUX))
	if (has("nvim"))
		"For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
		let $NVIM_TUI_ENABLE_TRUE_COLOR=1
	endif
	"For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
	"Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
	" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
	if (has("termguicolors"))
		set termguicolors
	endif
endif
nnoremap \wt :WakaTimeToday<cr>
command! WakatimeOpen :silent !open https://wakatime.com<cr>
nnoremap  \wo :WakatimeOpen<cr>
command! Gpull :Git pull<cr>
let g:airline#extensions#tabline#enabled = 0
