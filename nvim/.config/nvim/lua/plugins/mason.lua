return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/nvim-cmp',
		'SirVer/ultisnips',
		'quangnguyen30192/cmp-nvim-ultisnips',
		"ervandew/supertab",
	},
	lsp_settings = {
		emmet_language_server = {
			filetypes = { "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss", "pug", "typescriptreact", "rust" },
			-- Read more about this options in the [vscode docs](https://code.visualstudio.com/docs/editor/emmet#_emmet-configuration).
			-- **Note:** only the options listed in the table are supported.
			-- init_options = {
			-- 	-- --- @type string[]
			-- 	-- excludeLanguages = {},
			-- 	-- --- @type string[]
			-- 	-- extensionsPath = {},
			-- 	-- --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/preferences/)
			-- 	-- preferences = {},
			-- 	-- --- @type boolean Defaults to `true`
			-- 	-- showAbbreviationSuggestions = true,
			-- 	-- --- @type "always" | "never" Defaults to `"always"`
			-- 	-- showExpandedAbbreviation = "always",
			-- 	-- --- @type boolean Defaults to `false`
			-- 	-- showSuggestionsAsSnippets = false,
			-- 	-- --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/syntax-profiles/)
			-- 	-- syntaxProfiles = {},
			-- 	-- --- @type table<string, string> [Emmet Docs](https://docs.emmet.io/customization/snippets/#variables)
			-- 	-- variables = {},
			-- },
		},
		rust_analyzer = {
			settings = {
				['rust-analyzer'] = {
					inlayHints = {
						chainingHints = {
							enable = true,
						},
						typeHints = {
							hideTypeConstructors = true,
							enable = true,
						},
					},
					imports = {
						granularity = {
							enforce = true,
							group = "crate",
						},
						group = {
							enable = true,
						},
						merge = {
							glob = true,
						},
						prefix = "crate",
					},
					check = {
						allTargets = true,
						command = "clippy",
					},
					checkOnSave = true,
					workspace = {
						symbol = {
							search = {
								kind = "all_symbols",
								limit = 128,
								scope =
								"workspace_and_dependencies",
							},
						},
					},
					cargo = {
						buildScripts = {
							enable = true,
						},
						features = "all",
					},
					procMacro = {
						enable = true,
						ignored = {
							leptos_macro = {
								-- optional: --
								"component",
								-- "server",
							},
						},
					},
					diagnostics = {
						disabled = {
							"inactive-code"
						},
					}
				}
			}
		}
	},
	init_cmp = function()
		vim.g.UltiSnipsSnippetDirectories = { '~/.config/nvim/snips' }
		local cmp = require 'cmp'
		cmp.setup({
			completion = {
				autocomplete = false,
			},
			snippet = {
				-- REQUIRED - you must specify a snippet engine
				expand = function(args)
					vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
				end,
			},
			window = {
				-- completion = cmp.config.window.bordered(),
				-- documentation = cmp.config.window.bordered(),
			},
			mapping = cmp.mapping.preset.insert({
				['<a-j>'] = cmp.mapping.scroll_docs(-4),
				['<a-k>'] = cmp.mapping.scroll_docs(4),
				-- ['<c-Space><c-Space>'] = cmp.mapping.complete(),
				['<C-c>'] = cmp.mapping.abort(),
				['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
			}),
			sources = cmp.config.sources({
				{ name = 'nvim_lsp' },
				{ name = 'ultisnips' }, -- For ultisnips users.
			})
		})
	end,
	lsp_on_attach = function(self)
		vim.api.nvim_create_autocmd('LspAttach', {
			group = vim.api.nvim_create_augroup('UserLspConfig', {}),
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				-- Enable completion triggered by <c-x><c-o>
				vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
				-- vim.keymap.set('n', '<m-d>', vim.diagnostic.open_float)
				vim.keymap.set('n', '<c-k>', vim.diagnostic.goto_prev)
				vim.keymap.set('n', '<c-j>', vim.diagnostic.goto_next)
				vim.keymap.set('n', '<c-q>', vim.diagnostic.setqflist)

				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = ev.buf,
					callback = function()
						-- if client.server_capabilities.documentFormattingProvider then
						-- 	vim.lsp.buf.format { async = true }
						-- end
						if client and client.server_capabilities.inlayHintProvider then
							vim.lsp.codelens.refresh()
						end
					end
				})

				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf }
				vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
				vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
				vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
				vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
				vim.keymap.set('i', '<m-.>', vim.lsp.buf.signature_help, opts)
				vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
				vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)
				vim.keymap.set({ 'n', 'v' }, '<m-.>', vim.lsp.buf.code_action, opts)
				vim.keymap.set({ 'n', 'v' }, '<m-,>', self.quickfix, opts)
				vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
				vim.keymap.set('n', '<m-c-f>', function()
					vim.cmd('write')
					vim.lsp.buf.format {}
					vim.cmd('write')
				end, opts)
				if client and client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(ev.buf, true)
					vim.lsp.codelens.refresh()
				end
			end,
		})
	end,

	quickfix = function()
		vim.lsp.buf.code_action({
			filter = function(a) return a.isPreferred end,
			apply = true
		})
	end,
	config = function(self)
		self.init_cmp()
		self.lsp_on_attach(self)
		vim.cmd"command! Snippets UltiSnipsEdit"
		require("mason").setup()
		require("mason-lspconfig").setup {
			automatic_installation = true,
		}
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		for k, v in pairs(require('cmp_nvim_lsp').default_capabilities()) do
			capabilities[k] = v
		end
		require("mason-lspconfig").setup_handlers {
			-- The first entry (without a key) will be the default handler
			-- and will be called for each installed server that doesn't have
			-- a dedicated handler.
			function(server_name) -- default handler (optional)
				local config = {
					capabilities = capabilities,
				}
				if self.lsp_settings[server_name] then
					for k, v in pairs(self.lsp_settings[server_name]) do
						config[k] = v
					end
				end
				require("lspconfig")[server_name].setup(config)
			end,
		}
	end,
}
