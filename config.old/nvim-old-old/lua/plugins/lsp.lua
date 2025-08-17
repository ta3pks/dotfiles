vim.cmd [[
augroup __AutoFormatters
	au! __AutoFormatters
	au BufWritePre *.html,*.toml,*.svelte,*.dart,*.js,*.json,*.ts*,*.rs,*.lua lua vim.lsp.buf.format()
augroup END
]]
local keymaps = require("keymaps")


-- Register a handler that will be called for each installed server when it's ready (i.e. when installation is finished
-- or if the server is already installed).
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  keymaps.n {
    ["<leader>lr"] = ":Telescope lsp_references<cr>",
    ["<leader>q"] = ":Telescope lsp_range_code_actions<cr>",
    ["<m-s>"] = ":Telescope lsp_workspace_symbols<cr>",
    ["<m-d>"] = ":Telescope diagnostics<cr>",
    ["<m-.>"] = ":lua vim.lsp.buf.code_action()<cr>",
    ["<m-,>"] = ":lua vim.lsp.buf.code_action({only={'quickfix'}})<cr>",
    ["<leader>r"] = ":lua vim.lsp.buf.rename()<cr>",
    ["<m-c-l>"] = ":lua vim.lsp.buf.format{async=true}<cr>",
    ["<m-o>"] = ":lua vim.lsp.buf.document_symbol()<cr>",
  }
end
local servers = { 'rust_analyzer' }
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local ra_config = { --{{{
  enable = true,
  -- rustfmt = {
  --   extraArgs = { "+nightly" }
  -- },
  cargo = {
    allFeatures = true,
    features = {}
  },
  checkOnSave = {
    command = "clippy",
    enable = true,
    allFeatures = false,
  },
  diagnostics = {
    disabled = {
      "unresolved-proc-macro",
      "unresolved-macro-call",
      "macro-error",
      "inactive-code",
      "unlinked-file",
    }
  },
  inlayHints = {
    enable = true
  },
  completion = {
    postfix = { enable = true }
  }
} --}}}
require("nvim-lsp-installer").on_server_ready(function(server)
  local cfg = {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    },
  }
  if server.name == "rust_analyzer" then
    cfg.settings = { ['rust-analyzer'] = ra_config }
  elseif server.name == "denols" then
    cfg.init_options = {
      lint = true,
    }
  elseif server.name == "emmet_ls" then
    cfg.filetypes = { "html", "css", "typescriptreact", "javascriptreact", "svelte" }
  end
  server:setup(cfg)
end)
