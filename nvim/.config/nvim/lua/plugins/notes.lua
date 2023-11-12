return {
	{
		'xolox/vim-notes',
		cmd = { "Note", "ShowTaggedNotes" },
		dependencies = { 'xolox/vim-misc' },
		init = function()
			vim.g.notes_directories = { "~/Documents/notes_nvim" }
			vim.g.notes_suffix = ".md"
			vim.cmd [[
			command! -nargs=0 Todos :ShowTaggedNotes
			nnoremap <leader><leader>t :Todos<cr>
			]]
		end

	}
}
