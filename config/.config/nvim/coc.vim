command! -nargs=0 CocMarket CocList marketplace
let coc_vim_settings_root = fnamemodify(expand('$MYVIMRC'), ':p:h')..'/coc.vim'
nnoremap <silent> <leader>wp :exe 'tabnew '.. coc_vim_settings_root<CR>
" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

augroup __coc_group
  autocmd!
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nnoremap <silent><nowait> <c-j>  <Plug>(coc-diagnostic-next)
nnoremap <silent><nowait> <c-k>  <Plug>(coc-diagnostic-prev)
" GoTo code navigation.
nmap <silent> <c-]> <Plug>(coc-definition)
nmap <silent> gd <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gi <Plug>(coc-implementation)
" Symbol renaming.
nmap <leader>lr <Plug>(coc-rename)

" Formatting selected code.
xmap <m-c-l>  <Plug>(coc-format-selected)
nmap <silent><m-c-l>  :call CocActionAsync('format')<cr>
nmap <a-.>  <Plug>(coc-codeaction-cursor)
nmap <a-,>  <Plug>(coc-fix-current)
nmap <silent> <leader>r <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nnoremap <silent><nowait> <m-d>  :<C-u>CocList diagnostics<cr>
command! -nargs=0 Fmt :call CocAction('format')
" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>
nnoremap <leader>s :exe "CocSearch -S -e "..input("search: ")<cr>
nnoremap <a-s> :CocList symbols<cr>
nnoremap <c-\><c-\> :TComment<cr>
vnoremap <c-\><c-\> :TComment<cr>
nnoremap <leader>o :CocOutline<cr>
