return {
	'nvim-orgmode/orgmode',
	dependencies = {
		{ 'nvim-treesitter/nvim-treesitter', lazy = true },
	},
	ft = { 'org' },
	keys = {
		{ '<space>oa', function()
			require('orgmode').action("agenda.prompt")
		end
		},
		{ '<space>oc', function()
			require('orgmode').action("capture.prompt")
		end
		},
	},
	config = function()
		-- Load treesitter grammar for org
		require('orgmode').setup_ts_grammar()

		-- Setup treesitter
		require('nvim-treesitter.configs').setup({
			highlight = {
				enable = true,
			},
			ensure_installed = { 'org' },
		})

		-- Setup orgmode
		require('orgmode').setup({
			org_agenda_files = {
				-- '~/Documents/notes/**/*.org',
				"~/Documents/notes/*.org", "./*.org","../*.org",
			},
			org_default_notes_file = '~/Documents/notes/index.org',
			org_todo_keywords = { 'TODO(t)', 'WIP(w)', "NEXT(n)", '|', 'DONE(d)' },
		})
		vim.cmd([[
                 set statusline+=%#v:lua.orgmode.statusline()#
             ]])
	end,
}
