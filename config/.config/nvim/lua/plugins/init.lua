local utils = require("utils")
local keymaps = require("keymaps")
utils.rerequire("plugins.lsp")
utils.rerequire("plugins.cmp")
--local plugings_path = utils.vimrc_dir() .. "plugin_config.vim"
local lua_plugings_path = utils.vimrc_lua_dir() .. "plugins"
vim.g.polyglot_disabled = { 'go' }
vim.g['rainbow#pairs'] = { { '(', ')' }, { '[', ']' }, { '{', '}' } }
vim.g['rainbow#blacklist'] = { '#cc241d' }
-- vim.cmd("source " .. plugings_path)
keymaps.n({
	--	["<c-w><c-p>"] = ":tabnew " .. plugings_path .. "<cr>",
	["<c-b>"]      = ":Telescope buffers<cr>",
	["<leader>s"]  = ":Telescope live_grep<cr>",
	["<c-\\>"]     = ":Telescope resume<cr>",
	["<C-p>"]      = ":Telescope find_files<cr>",
	["<Leader>b"]  = ':exec "Tabularize/".input("enter regex: ")."/"<cr>',
	["<Leader>nc"] = ":NERDTreeClose<cr>",
	["<Leader>nt"] = ":NERDTreeToggle<cr>",
	["<Leader>nf"] = ":NERDTreeFind<cr>",
	["<Leader>gg"] = ":wa|:Git<cr>",
	["<Leader>gs"] = ":Telescope git_commits<cr>",
	["\\wt"]       = ":WakaTimeToday<cr>",
	["\\wo"]       = ":WakatimeOpen<cr>",
	["<leader>pr"] = ":lua require'utils'.rerequire'plugins';print'plugins reloaded'<cr>",
	["<leader>pd"] = ":NERDTree " .. lua_plugings_path .. "<cr>",
	["<C-w><C-p>"] = ":tabnew " .. lua_plugings_path .. "/init.lua<cr>",
	["\\wp"]       = ":tabnew " .. lua_plugings_path .. "/lsp.lua<cr>",
})
keymaps.i {
	["\\cc"] = "<c-o>:Copilot panel<cr>",
}
vim.cmd "command! -nargs=0 CP Copilot panel"
-- packer config
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
end

require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
	use 'thosakwe/vim-flutter'
	use 'airblade/vim-gitgutter'
	use 'bling/vim-airline'
	use 'vim-airline/vim-airline-themes'
	use 'nvim-lua/plenary.nvim'
	use 'evanleck/vim-svelte'
	use { 'nvim-telescope/telescope.nvim',
		'nvim-telescope/telescope-ui-select.nvim'
	}
	use 'nvim-treesitter/nvim-treesitter'
	use 'tpope/vim-dadbod'
	use 'kristijanhusak/vim-dadbod-ui'
	use 'hsanson/vim-openapi'
	use 'dNitro/vim-pug-complete'
	use 'tomtom/tcomment_vim'
	use 'dag/vim-fish'
	use 'github/copilot.vim'
	use 'godlygeek/tabular'
	use 'gregsexton/MatchTag'
	use 'jacoborus/tender.vim'
	use 'mattn/emmet-vim'
	use 'junegunn/rainbow_parentheses.vim'
	use 'mmahnic/vim-flipwords'
	use 'rakr/vim-one'
	use {
		'rust-lang/rust.vim',
	}
	use 'scrooloose/nerdtree'
	use 'sheerun/vim-polyglot'
	use 'tpope/vim-fugitive'
	use 'tpope/vim-surround'
	use 'wakatime/vim-wakatime'
	use {
		'neovim/nvim-lspconfig',
		'williamboman/nvim-lsp-installer',
	}
	use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
	use {
		'hrsh7th/nvim-cmp',
		'hrsh7th/cmp-nvim-lsp',
		'SirVer/ultisnips',
		'quangnguyen30192/cmp-nvim-ultisnips',
		"hrsh7th/cmp-nvim-lsp-signature-help",
	}

	if packer_bootstrap then
		require('packer').sync()
	end
end)
require("telescope").load_extension("ui-select")
require "telescope".setup {
	defaults = {
		preview = {
			hide_on_startup = true,
		},
		layout_config = {
			horizontal = {
				width = 0.9,
				preview_width = 0.6
			}
		},
		mappings = {
			n = {
				["<a-x>"] = require('telescope.actions').delete_buffer,
				["<a-p>"] = require('telescope.actions.layout').toggle_preview
			},
			i = {
				["<C-j>"] = "move_selection_next",
				["<C-k>"] = "move_selection_previous",
				["<a-x>"] = require('telescope.actions').delete_buffer,
				["<a-p>"] = require('telescope.actions.layout').toggle_preview
			}
		}
	},
}
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
