nnoremap \e :vsp <bar> exe "term npm run build&&node lib/js/src/".expand("%:t:r").".bs.js" <bar> normal! i<cr>
