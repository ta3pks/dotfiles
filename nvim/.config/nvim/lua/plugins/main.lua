return {
  -- add gruvbox
  {
    "https://github.com/joshdick/onedark.vim",
  },
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
  {
    "kassio/neoterm",
    keys = {
      { "<c-t><c-t>", "<cmd>vert Ttoggle<cr>", desc = "Toggle Neoterm" },
      { "<m-s>", "<cmd>TREPLSendFile<cr>", desc = "Send file" },
      { "<m-l>", "<cmd>TREPLSendLine<cr>", desc = "send current line" },
      { "<m-s>", "<cmd>TREPLSendSelection<cr>", mode = "v", desc = "send selection" },
    },
  },
  {
    "L3MON4D3/LuaSnip",
    --   lazy = false,
    config = function()
      require("luasnip.loaders.from_lua").load({ paths = { "~/.config/nvim/luasnip" } })
      require("luasnip").config.setup({
        update_events = "TextChanged,TextChangedI",
        enable_autosnippets = true,
      })
      vim.api.nvim_create_user_command("Snippets", function()
        require("luasnip.loaders").edit_snippet_files()
      end, { desc = "Edit LuaSnip snippets" })
      vim.api.nvim_create_user_command("LsLog", function()
        require("luasnip").log.open()()
      end, { desc = "open luasnip logs" })
    end,
  },
  {
    "rafcamlet/nvim-luapad",
  },
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
  {
    "mmahnic/vim-flipwords",
    cmd = { "Flip" },
  },
  {
    "wakatime/vim-wakatime",
    event = "VeryLazy",
  },
  --disable mini surround
  {
    "mini_surround/mini.surround",
    enabled = false,
  },
  --install usual surround vim plugin
  {
    "tpope/vim-surround",
    lazy = false,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {
          opts = {
            settings = {
              ["rust-analyzer"] = {
                checkOnSave = {
                  command = "clippy",
                },
                diagnostics = {
                  disabled = { "inactive-code" },
                },
                cargo = {
                  allFeatures = true,
                  features = "all",
                  allTargets = true,
                  buildScripts = true,
                },
              },
            },
          },
        },
      },
    },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true, commit = "d3082402655dfd634d744db6d040e2d636afcb41" },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
}
