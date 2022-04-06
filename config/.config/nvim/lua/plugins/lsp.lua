local keymaps = require("keymaps")

-- Register a handler that will be called for each installed server when it's ready (i.e. when installation is finished
-- or if the server is already installed).
keymaps.n({
    ["<c-k>"] = ":lua vim.diagnostic.goto_prev()<cr>",
    ["<c-j>"] = ":lua vim.diagnostic.goto_next()<cr>",
  })
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  keymaps.n{
    ["<c-]>"] = ":Telescope lsp_definitions<cr>",
    ["K"] = {":lua vim.lsp.buf.hover()<cr>"},
    ["<leader>lr"] = ":Telescope lsp_references<cr>",
    ["<leader>q"] = ":Telescope lsp_range_code_actions<cr>",
    ["<m-s>"] = ":Telescope lsp_workspace_symbols<cr>",
    ["<m-d>"] = ":Telescope diagnostics<cr>",
    ["<m-.>"] = ":Telescope lsp_code_actions<cr>",
    ["<leader>r"] = ":lua vim.lsp.buf.rename()<cr>",
    ["<m-c-l>"] = ":lua vim.lsp.buf.formatting()<cr>",
  }
end
local servers = {'rust_analyzer'}
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    },
    settings={
      ['rust-analyzer'] = {
        enable=true,
        rustfmt = {
          extraArgs = { "+nightly" }
        },
        cargo ={
          allFeatures = false,
          features = {}
        },
        checkOnSave={
          command = "clippy",
          enable = true,
          allFeatures = false,
        },
        diagnostics = {
          disabled = {
            "unresolved-proc-macro",
            "unresolved-macro-call",
            "macro-error",
            "inactive-code"
          }
        },
        inlayHints = {
          enable=true
        },
        completion = {
          postfix = {enable=true}
        }
      }
    }
  }
end
