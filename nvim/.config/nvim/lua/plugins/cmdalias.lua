return {
	'vim-scripts/cmdalias.vim',
	config = function()
		local alias = vim.fn.CmdAlias
		alias('wq', 'w\\|bd')
		alias("alias", "Alias")
	end
}
