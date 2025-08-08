-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local function ts_to_date(param)
  if param == nil then
    return print(os.date())
  end
  local date = os.date("*t", param)
  return string.format("%04d-%02d-%02d %02d:%02d:%02d", date.year, date.month, date.day, date.hour, date.min, date.sec)
end
vim.keymap.set("n", "<leader>ts", function()
  local word = vim.fn.expand("<cword>")
  local ts = tonumber(word)
  if ts then
    print(ts_to_date(ts))
  else
    print(ts_to_date())
  end
end, { desc = "Convert timestamp to date" })

-- paste on c-v on terminal
vim.keymap.set("t", "<c-v>", "<c-\\><c-o>p ", { desc = "paste from clipboard" })
vim.keymap.del("n", "<m-j>")
vim.keymap.del("n", "<m-k>")
vim.keymap.set("n", "<leader>a<space>", function()
  local current_file = vim.fn.expand("%:p")
  vim.cmd("vertical term tgpt -m")
  vim.cmd("normal! i")
end, { desc = "open tgpt on a split" })
vim.keymap.set("n", "<m-;>", function()
  -- check if theres a terminal buffer active
  local term_buf = vim.fn.bufnr("term://*")
  if term_buf ~= -1 and vim.api.nvim_buf_is_valid(term_buf) then
    -- if it is, open it in split
    vim.cmd("vsp")
    vim.cmd("buffer " .. term_buf)
  else
    -- otherwise, open a new terminal in a split
    vim.cmd("vertical terminal")
  end
  vim.cmd("normal! i")
end, { desc = "open terminal in split and focus" })
vim.keymap.set("t", "<m-;>", function()
  vim.cmd("close")
end, { desc = "close terminal buffer" })
vim.cmd([[
  map <c-j> ]d
  map <c-k> [d
  map <m-/> gcc
  vmap <m-/> gcgv
  nnoremap <silent> <C-w><c-l> :exe "tabnew ".$MYVIMRC->fnamemodify(':p:h'). "/after/ftplugin/".&ft.".vim"<bar>lcd %:p:h<CR>
  nnoremap <silent> <C-w><c-c> :exe "tabnew ".$MYVIMRC->fnamemodify(':p:h'). "/chords/".&ft.".vim"<bar>lcd %:p:h<CR>
  nnoremap <silent> <C-w><c-s> :tabnew $MYVIMRC<bar>lcd %:p:h<CR>
  tnoremap <c-h> <bs>
  vmap <C-c> "+y
  command Wsudo w !SUDO_ASKPASS=`which ssh-askpass` sudo tee % > /dev/null
  cnoreabbrev wsudo Wsudo
  command W w
  command Wq wq
]])
