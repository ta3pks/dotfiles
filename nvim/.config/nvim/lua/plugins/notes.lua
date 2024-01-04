return {
	{
		'xolox/vim-notes',
		cmd = { "Note", "ShowTaggedNotes", "SearchNotes" },
		dependencies = { 'xolox/vim-misc' },
		keys = {
			-- vim.keymap.set("n", "<leader><leader>tn", Notes, { noremap = true, silent = true });
			-- vim.keymap.set("n", "<leader><leader>tt", function()
			-- 	vim.cmd("Note " .. GetLastNote())
			-- 	vim.fn.search("TODO")
			-- end, { noremap = true, silent = true });
			{
				"<leader><leader>tn",
				function()
					Notes()
				end,
				noremap = true,
				silent = true
			},
			{
				"<leader><leader>tt",
				function()
					vim.cmd("Note " .. GetLastNote())
					vim.fn.search("TODO")
				end,
				noremap = true,
				silent = true
			}

		},
		config = function()
			vim.g.notes_directories = { "~/Documents/notes_nvim" }
			vim.g.notes_suffix = ".md"

			function GetNoteList()
				local notes = {}
				for _, dir in ipairs(vim.g.notes_directories) do
					dir = vim.fn.expand(dir)
					local files = vim.fn.readdir(dir, function(fname)
						if vim.fn.match(fname, ".md$") > -1 then
							table.insert(notes, vim.fn.fnamemodify(fname, ":t:r"))
							return 1
						else
							return 0
						end
					end)
				end
				return notes
			end

			function GetLastNote()
				local notes = GetNoteList()
				local last = {
					name = "",
					time = 0
				}
				for _, note in ipairs(notes) do
					local mtime = vim.fn.getftime(vim.fn.expand("~/Documents/notes_nvim/" ..
						note .. ".md"))
					if mtime > last.time then
						last.name = note
						last.time = mtime
					end
				end
				return last.name
			end

			function Notes()
				vim.ui.select(GetNoteList(), {}, function(selected)
					if selected == nil then
						return
					end
					vim.cmd("Note " .. selected)
				end)
			end

			vim.cmd [[
			command! Notes :lua Notes()
			]]
		end

	}
}
