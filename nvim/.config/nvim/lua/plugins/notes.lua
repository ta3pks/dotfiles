return {
	{
		'xolox/vim-notes',
		cmd = { "Note", "ShowTaggedNotes", "SearchNotes" },
		dependencies = { 'xolox/vim-misc' },
		init = function()
			vim.g.notes_directories = { "~/Documents/notes_nvim" }
			vim.g.notes_suffix = ".md"
			vim.cmd [[
			command! -bar -nargs=0 Todos :ShowTaggedNotes
			nnoremap <leader><leader>tt :Todos<bar>setlocal nofoldenable<cr>
			nnoremap <leader><leader>ts :SearchNotes<space>
			nnoremap <leader><leader>tn :Note<space>
			]]
		end

	}
}
