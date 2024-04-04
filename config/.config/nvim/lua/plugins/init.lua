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
function OpenFilesPanel()
	-- if current file is in git directory use :GFiles otherwise use :Files
	local git_dir = vim.fn.fnamemodify(vim.fn.finddir(".git", ".;"), ":h");
	vim.cmd("Files " .. git_dir)
end

keymaps.n({
	--	["<c-w><c-p>"] = ":tabnew " .. plugings_path .. "<cr>",
	["<c-b>"]      = ":Buffers<cr>",
	-- ["<leader>s"]  = ":Telescope live_grep<cr>",
	["<C-p><C-p>"] = ":lua OpenFilesPanel()<cr>",
	["<C-p><c-f>"] = ":Files<cr>",
	["<C-p><c-g>"] = ":GFiles?<cr>",
	["<C-p>g"]     = ":GFiles<cr>",
	["<C-p><c-c>"] = ":Commits<cr>",
	["<C-p><c-m>"] = ":Marks<cr>",
	["<C-p><c-t>"] = ":Tags<cr>",
	["<C-p><c-l>"] = ":Lines<cr>",
	["<C-p><c-k>"] = ":Maps<cr>",
	["<Leader>b"]  = ':exec "Tabularize/".input("enter regex: ")."/"<cr>',
	["<Leader>gg"] = ":wa|:lua require('plugins.openterm').open_full_term('lazygit',true)<cr>",
	["\\wt"]       = ":WakaTimeToday<cr>",
	["\\wo"]       = ":WakatimeOpen<cr>",
	["<leader>pr"] = ":lua require'utils'.rerequire'plugins';print'plugins reloaded'<cr>",
	["<C-w><C-p>"] = ":tabnew " .. lua_plugings_path .. "/init.lua<cr>",
})
vim.cmd "command! FlipArgs Flip , )"


keymaps.i {
	["\\cc"] = "<c-o>:Copilot panel<cr>",
}
-- vim.g.ctrlp_user_command = "git ls-files . --cached --exclude-standard --others"
-- vim.g.ctrlp_use_caching = 0
vim.cmd "command! -nargs=0 CP Copilot panel"
-- packer config
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
		install_path })
end

vim.cmd([[
	
	let g:scratch_insert_autohide = 0
	let g:airline_powerline_fonts = 1
	let g:airline#extensions#whitespace#enabled = 0
	let g:airline_theme='one'
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
	use 'metakirby5/codi.vim'
	use 'rafcamlet/nvim-luapad'
	use 'wakatime/vim-wakatime'
	use 'vim-airline/vim-airline-themes'
	use 'tpope/vim-surround'
	use 'tomtom/tcomment_vim'
	-- use 'sheerun/vim-polyglot'
	use 'rakr/vim-one'
	use { 'neoclide/coc.nvim', branch = 'release' }
	use 'mmahnic/vim-flipwords'
	use 'junegunn/rainbow_parentheses.vim'
	use 'gregsexton/MatchTag'
	use 'godlygeek/tabular'
	use 'github/copilot.vim'
	-- use 'ctrlpvim/ctrlp.vim'
	use 'bling/vim-airline'
	use { 'airblade/vim-gitgutter', branch = 'main' }
	use {
		'nvim-treesitter/nvim-treesitter',
		run = function()
			local ts_update = require('nvim-treesitter.install').update({ with_sync = false })
			ts_update()
		end,
	}
	use "nvim-treesitter/nvim-treesitter-textobjects"

	use 'junegunn/fzf'
	use 'junegunn/fzf.vim'
	use {
		'xolox/vim-notes',
		requires = { 'xolox/vim-misc' }

	}
	if packer_bootstrap then
		require('packer').sync()
	end
end)

require "nvim-treesitter.configs".setup {
	ensure_installed = { "lua", "vim", "toml", "typescript", "javascript", "svelte", "yaml" },
	additional_vim_regex_highlighting = false,
	incremental_selection = {
		enable = true,
	},
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
	textobjects = {
		select = {
			enable = true,

			-- Automatically jump forward to textobj, similar to targets.vim
			lookahead = true,

			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				-- You can optionally set descriptions to the mappings (used in the desc parameter of
				-- nvim_buf_set_keymap) which plugins like which-key display
				["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
				-- You can also use captures from other query groups like `locals.scm`
				["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
			},
			-- You can choose the select mode (default is charwise 'v')
			--
			-- Can also be a function which gets passed a table with the keys
			-- * query_string: eg '@function.inner'
			-- * method: eg 'v' or 'o'
			-- and should return the mode ('v', 'V', or '<c-v>') or a table
			-- mapping query_strings to modes.
			selection_modes = {
				['@parameter.outer'] = 'v', -- charwise
				['@function.outer'] = 'V', -- linewise
				['@class.outer'] = '<c-v>', -- blockwise
			},
			-- If you set this to `true` (default is `false`) then any textobject is
			-- extended to include preceding or succeeding whitespace. Succeeding
			-- whitespace has priority in order to act similarly to eg the built-in
			-- `ap`.
			--
			-- Can also be a function which gets passed a table with the keys
			-- * query_string: eg '@function.inner'
			-- * selection_mode: eg 'v'
			-- and should return true of false
			include_surrounding_whitespace = true,
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["<a-j>"] = "@function.outer",
				["]]"] = { query = "@class.outer", desc = "Next class start" },
				--
				-- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
				["]o"] = "@loop.*",
				-- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
				--
				-- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
				-- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
				["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
				["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
			},
			goto_next_end = {
				["<a-s-j>"] = "@function.outer",
				["]["] = "@class.outer",
				["<a-]>"] = "@scope.outer",
			},
			goto_previous_start = {
				["<a-k>"] = "@function.outer",
				["[["] = "@class.outer",
				["<a-[>"] = "@scope.outer",
				["[s"] = { query = "@scope", query_group = "locals", desc = "Prev scope" },
			},
			goto_previous_end = {
				["<a-s-k>"] = "@function.outer",
				["[]"] = "@class.outer",
			},
			-- Below will go to either the start or the end, whichever is closer.
			-- Use if you want more granular movements
			-- Make it even more gradual by adding multiple queries and regex.
			goto_next = {
				["]d"] = "@conditional.outer",
			},
			goto_previous = {
				["[d"] = "@conditional.outer",
			}
		},
	},

}
vim.cmd "set foldexpr=nvim_treesitter#foldexpr()"
-- require 'marks'.setup {
-- 	-- whether to map keybinds or not. default true
-- 	default_mappings = true,
-- 	-- which builtin marks to show. default {}
-- 	-- builtin_marks = { ".", "<", ">", "^" },
-- 	-- whether movements cycle back to the beginning/end of buffer. default true
-- 	cyclic = true,
-- 	-- whether the shada file is updated after modifying uppercase marks. default false
-- 	force_write_shada = false,
-- 	-- how often (in ms) to redraw signs/recompute mark positions.
-- 	-- higher values will have better performance but may cause visual lag,
-- 	-- while lower values may cause performance penalties. default 150.
-- 	refresh_interval = 250,
-- 	-- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
-- 	-- marks, and bookmarks.
-- 	-- can be either a table with all/none of the keys, or a single number, in which case
-- 	-- the priority applies to all marks.
-- 	-- default 10.
-- 	sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
-- 	-- disables mark tracking for specific filetypes. default {}
-- 	excluded_filetypes = {},
-- 	-- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
-- 	-- sign/virttext. Bookmarks can be used to group together positions and quickly move
-- 	-- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
-- 	-- default virt_text is "".
-- 	bookmark_0 = {
-- 		sign = "⚑",
-- 		virt_text = "hello world",
-- 		-- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
-- 		-- defaults to false.
-- 		annotate = false,
-- 	},
-- 	mappings = {}
-- }
vim.cmd [[
inoremap <c-j> <Plug>(copilot-next)
inoremap <c-k> <Plug>(copilot-previous)
inoremap <c-\> <Plug>(copilot-suggest)
inoremap <silent><script><expr> <C-l> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
command! -nargs=0 Todos :ShowTaggedNotes
nnoremap <leader><leader>t :Todos<cr>
let g:fzf_preview_window = ['', 'alt-/']
]]
