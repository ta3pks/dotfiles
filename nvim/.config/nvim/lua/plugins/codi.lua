return {
	'metakirby5/codi.vim'
	,
	lazy = true
	,
	cmd = { "Codi", "CodiNew" },
	init = function()
		vim.g['codi#interpreters'] = {
			rust = {
				bin = "evcxr",
				prompt = ">>",
			}
		}
	end
}
