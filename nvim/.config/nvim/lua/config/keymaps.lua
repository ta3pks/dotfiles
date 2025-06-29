-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.del("n", "<m-j>")
vim.keymap.del("n", "<m-k>")
vim.cmd([[
  map <c-j> ]d
  map <c-k> [d
  nnoremap <silent> <C-w><c-l> :exe "tabnew ".$MYVIMRC->fnamemodify(':p:h'). "/after/ftplugin/".&ft.".vim"<bar>lcd %:p:h<CR>
  nnoremap <silent> <C-w><c-c> :exe "tabnew ".$MYVIMRC->fnamemodify(':p:h'). "/chords/".&ft.".vim"<bar>lcd %:p:h<CR>
  nnoremap <silent> <C-w><c-s> :tabnew $MYVIMRC<bar>lcd %:p:h<CR>
  vmap <C-c> "+y
  command Wsudo w !SUDO_ASKPASS=`which ssh-askpass` sudo tee % > /dev/null
  cnoreabbrev wsudo Wsudo
  command W w
  command Wq wq
]])
