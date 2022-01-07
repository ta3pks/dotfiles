local cmp = require("cmp")
cmp.setup({
	sources = {
		{ name = "neorg" },
	},
})
require("neorg").setup({
	-- Tell Neorg what modules to load
	load = {
		["core.defaults"] = {}, -- Load all the default modules
		["core.norg.concealer"] = {}, -- Allows for use of icons
		["core.norg.dirman"] = { -- Manage your directories with Neorg
			config = {
				workspaces = {
					my_workspace = "~/dotfiles/norg",
				},
			},
		},
		["core.norg.completion"] = {
			config = {
				engine = "nvim-cmp", -- We current support nvim-compe and nvim-cmp only
			},
		},
	},
})
-- treesitter setup
local parser_configs = require('nvim-treesitter.parsers').get_parser_configs()

parser_configs.norg = {
    install_info = {
        url = "https://github.com/nvim-neorg/tree-sitter-norg",
        files = { "src/parser.c", "src/scanner.cc" },
        branch = "main"
    },
}

parser_configs.norg_meta = {
    install_info = {
        url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
        files = { "src/parser.c" },
        branch = "main"
    },
}

parser_configs.norg_table = {
    install_info = {
        url = "https://github.com/nvim-neorg/tree-sitter-norg-table",
        files = { "src/parser.c" },
        branch = "main"
    },
}
-- if installation of norg fails install gcc11 through brew and link gcc to /usr/local/bin/cc 
require('nvim-treesitter.configs').setup {
    ensure_installed = { "norg", "norg_meta", "norg_table", "rust", "cpp", "c", "javascript", "markdown","typescript" },
    highlight = { -- Be sure to enable highlights if you haven't!
        enable = true,
    }
}
