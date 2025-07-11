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
  -- {
  --   "ta3pks/LuaSnip-snippets.nvim",
  --   dependencies = {
  --     "L3MON4D3/LuaSnip",
  --   },
  --   config = function()
  --     require("luasnip").add_snippets(nil,   require("luasnip_snippets").load_snippets())
  --   end,
  -- },
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
  -- {
  --   "folke/flash.nvim",
  --   enabled = false,
  -- },
  {
    --neotest nocapture for rust
    "nvim-neotest/neotest",
    dependencies = {
      "rouge8/neotest-rust",
    },
    opts = {
      adapters = {
        ["neotest-rust"] = {
          args = { "--no-capture" },
        },
      },
    },
  },
  --disable mini surround
  {
    "echasnovski/mini.surround",
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
      { "tpope/vim-dadbod", lazy = true },
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
