return {
	'kristijanhusak/vim-dadbod-ui',
	lazy = true,
	dependencies = {
		{ 'tpope/vim-dadbod',                     lazy = true },
		{ 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
	},
	cmd = {
		'DBUI',
		'DBUIToggle',
		'DBUIAddConnection',
		'TabDbui',
	},
	config = function()
		-- Your DBUI configuration
		vim.cmd('command! TabDbui tab DBUI')
		vim.g.db_ui_use_nerd_fonts = 1
		vim.g.db_ui_use_nvim_notify = 0
		vim.cmd.cnoreabbrev('dbtab', 'tab DBUI')
	end,
}
