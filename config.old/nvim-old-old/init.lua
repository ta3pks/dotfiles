require("events")
require("keymaps")
require("plugins")
-- local api = vim.api
-- remove auto commenting on next line
function Exe_current_viml_line()
	local line = vim.fn.getline(".")
	print("executing " .. line)
	vim.cmd(line)
end

function Exe_current_lua_selection()
	local line1 = vim.fn.getpos("'<")[2]
	local line2 = vim.fn.getpos("'>")[2]
	local lines = vim.fn.getline(line1, line2)
	local lua_code = table.concat(lines, "\n")
	print("executing " .. lua_code)
	local fn = load(lua_code)
	if fn then
		fn()
	end
end

function Search_in_project_dir()
	local search_term = vim.fn.input("search: ")
	if search_term == "" then
		search_term = vim.fn.expand("<cword>")
	end
	vim.cmd("Rg " .. search_term)
	-- if search_term == "" then
	-- 	print("no search term")
	-- 	return
	-- end
	-- local search_cmd = "vim " .. search_term .. " " .. string.gsub(vim.fn.system("git ls-files"), "\n", " ")
	-- vim.cmd(search_cmd)
end

function Cd_git_root_dir()
	vim.cmd("cd " .. vim.fn.expand("%:p:h"))
	local curr_dir = vim.fn.system("git rev-parse --show-toplevel")
	vim.cmd("cd " .. curr_dir)
	print("cd " .. curr_dir)
end

function Movement_keys(key)
	if vim.v.count == 0 then
		-- run normal j key in 1 second with delay
		vim.defer_fn(function() vim.cmd("normal! " .. key) end, 1000)
	else
		vim.cmd("normal! " .. vim.v.count .. key)
	end
end

vim.o.inccommand = "split"
vim.o.ignorecase = true
vim.o.hlsearch = false
vim.o.smartcase = true
vim.o.wildignorecase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 1 -- width of line numbers column on left
vim.o.termguicolors = true
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
vim.o.mouse = 'a'
if vim.fn.exists("g:neovide") then
	vim.o.guifont = "FiraCode Nerd Font:h14"
	vim.g.neovide_hide_mouse_when_typing = false
	vim.g.neovide_full_screen = false
	vim.g.neovide_remember_window_size = true
	vim.g.neovide_macos_option_as_alt = true
	vim.g.neovide_input_macos_alt_is_meta = true
	vim.g.neovide_cursor_animation_length = 0.05
	vim.g.neovide_cursor_trail_size = 0.1
	vim.g.neovide_cursor_vfx_mode = ""
	vim.g.neovide_no_idle = false
	vim.g.neovide_refresh_rate_idle = 1
	vim.g.neovide_transparency = 0.95
end
function Remove_old_manual_indents()
	vim.cmd [[
		set foldmethod=marker
		normal! zE
		set foldmethod=indent
	]]
end

vim.g.notes_directories = { "~/Documents/notes_nvim" }
vim.g.notes_suffix = ".md"
function MakeTags(src_path)
	if src_path == nil then
		src_path = "src"
	end
	vim.cmd("!ctags -R -f tags " .. src_path)
end

vim.cmd([[
	syntax on
	highlight Folded guifg=#686363
	nnoremap \mt :silent! MakeTags src/<CR>
	command! FixTrailing :%s/\s\+$//g
	tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'
	command! -bar -nargs=0 Ssrc source %
	command! -nargs=? MakeTags :lua MakeTags(<q-args>)
	set foldlevel=2
	setglobal foldmethod=indent
	nnoremap z1 :set foldlevel=1<CR>
	nnoremap z0 :set foldlevel=0<CR>
	autocmd BufEnter * set formatoptions-=cro
	command! Bufonly :%bd|e#|bd#
	nnoremap <silent><leader><leader>c :lua Cd_git_root_dir()<CR>
	nnoremap <leader>s :lua Search_in_project_dir()<CR>
	nnoremap <leader>tt O// TODO:<space>
	nnoremap <c-t> :Tags<CR>
	nnoremap <leader>to :tabonly<CR>
]])
vim.g["codi#interpreters"] = {
	sh = {
		bin = "sh",
		prompt = "sh-3.2$",
	},
}
vim.o.exrc = true
