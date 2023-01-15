local utils = require("utils")
local keymaps = require("keymaps")
vim.cmd "exe 'source '..fnamemodify(expand('$MYVIMRC'), ':p:h')..'/coc.vim'"
-- utils.rerequire("plugins.lsp")
-- utils.rerequire("plugins.cmp")
--local plugings_path = utils.vimrc_dir() .. "plugin_config.vim"
local lua_plugings_path = utils.vimrc_lua_dir() .. "plugins"
vim.g['rainbow#pairs'] = { { '(', ')' }, { '[', ']' }, { '{', '}' } }
vim.g['rainbow#blacklist'] = { '#cc241d' }
-- vim.cmd("source " .. plugings_path)
keymaps.n({
	--	["<c-w><c-p>"] = ":tabnew " .. plugings_path .. "<cr>",
	["<c-b>"]      = ":CtrlPBuffer<cr>",
	-- ["<leader>s"]  = ":Telescope live_grep<cr>",
	["<C-p>"]      = ":CtrlP<cr>",
	["<Leader>b"]  = ':exec "Tabularize/".input("enter regex: ")."/"<cr>',
	["<Leader>nc"] = ":NERDTreeClose<cr>",
	["<Leader>nt"] = ":NERDTreeToggle<cr>",
	["<Leader>nf"] = ":NERDTreeFind<cr>",
	["<Leader>gg"] = ":wa|:Git<cr>",
	["\\wt"]       = ":WakaTimeToday<cr>",
	["\\wo"]       = ":WakatimeOpen<cr>",
	["<leader>pr"] = ":lua require'utils'.rerequire'plugins';print'plugins reloaded'<cr>",
	["<leader>pd"] = ":NERDTree " .. lua_plugings_path .. "<cr>",
	["<C-w><C-p>"] = ":tabnew " .. lua_plugings_path .. "/init.lua<cr>",
})
keymaps.i {
	["\\cc"] = "<c-o>:Copilot panel<cr>",
}
vim.g.ctrlp_user_command= "git ls-files . --cached --exclude-standard --others"
vim.cmd "command! -nargs=0 CP Copilot panel"
-- packer config
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
end

vim.cmd([[ 
	
	let g:scratch_insert_autohide = 0
	let g:airline_powerline_fonts = 1
	let g:airline#extensions#whitespace#enabled = 0
	let g:airline_theme='one'
	let NERDTreeWinSize = 30
	let g:user_emmet_leader_key = "<m-e>"
	colorscheme one
	autocmd BufReadPost *.tsx set ft=typescript.tsx
	command! WakatimeOpen :silent !open https://wakatime.com
	command! Gpull :Git pull
	command! UpdatePlugins :PackerSync
	command! LspUpdates :LspInstallInfo
	if (has("nvim"))
		let $NVIM_TUI_ENABLE_TRUE_COLOR=1
		endif
		if (has("termguicolors"))
			set termguicolors
			endif
			autocmd VimEnter * RainbowParentheses
			]])
require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
	use 'wakatime/vim-wakatime'
	use 'vim-airline/vim-airline-themes'
	use 'tpope/vim-surround'
	use 'tpope/vim-fugitive'
	use 'tomtom/tcomment_vim'
	use 'sheerun/vim-polyglot'
	use 'scrooloose/nerdtree'
	use 'rakr/vim-one'
	use {'neoclide/coc.nvim',branch = 'release'}
	use 'mmahnic/vim-flipwords'
	use 'mattn/emmet-vim'
	use 'junegunn/rainbow_parentheses.vim'
	use 'jacoborus/tender.vim'
	use 'gregsexton/MatchTag'
	use 'godlygeek/tabular'
	use 'github/copilot.vim'
	use 'dag/vim-fish'
	use 'ctrlpvim/ctrlp.vim'
	use 'bling/vim-airline'
	use 'airblade/vim-gitgutter'
	use {
		'nvim-treesitter/nvim-treesitter',
		run = function()
			local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
			ts_update()
		end,
	}
	if packer_bootstrap then
		require('packer').sync()
	end
end)
require "nvim-treesitter.configs".setup {
	ensure_installed = {"help","lua","vim","rust","toml","typescript","javascript","svelte","yaml"},
	additional_vim_regex_highlighting = false,
	incremental_selection = {
		enable = false,
	},
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},

}
vim.cmd "set foldexpr=nvim_treesitter#foldexpr()"
