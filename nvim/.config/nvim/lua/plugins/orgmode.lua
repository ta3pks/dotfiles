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

		-- Setup treesitter
		require('nvim-treesitter.configs').setup({
            mappings = {
                prefix = '<space>',
            },
			highlight = {
				enable = true,
			},
			ensure_installed = { 'org' },
		})

		-- Setup orgmode
		require('orgmode').setup({
			org_agenda_files = {
				-- '~/Documents/notes/**/*.org',
				"~/.todos/*.org","~/.todos/**/*.org", "./*.org","../*.org",
			},
			org_default_notes_file = '~/.todos/notes.org',
			org_todo_keywords = { 'TODO(t)', 'WIP(w)', "NEXT(n)", '|', 'DONE(d)' },
		})
		-- vim.cmd([[
                -- function! OrgStatus()
                --     lua orgmode.statusline()
                -- endfunction
                --  set statusline+='%{OrgStatus()}'
             -- ]])
	end,
}
