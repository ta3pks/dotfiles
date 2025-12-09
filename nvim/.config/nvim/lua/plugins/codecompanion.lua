return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "ravitemer/mcphub.nvim",
    },
    opts = {
      adapters = {
        http = {
          openrouter = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = {
                url = "https://openrouter.ai/api",
                api_key = "OPENROUTER_API_KEY",
                chat_url = "/v1/chat/completions",
              },
              schema = {
                model = {
                  default = "google/gemini-2.5-flash",
                },
              },
            })
          end,
        },
      },
      strategies = {
        chat = {
          adapter = {
            name = "opencode",
            model = "openrouter/kwaipilot/kat-coder-pro:free",
          },
        },
        -- chat = {
        --   adapter = "openrouter",
        -- },
        inline = {
          adapter = {
            name = "opencode",
            model = "openrouter/kwaipilot/kat-coder-pro:free",
          },
        },
        cmd = {
          adapter = {
            name = "opencode",
            model = "openrouter/kwaipilot/kat-coder-pro:free",
          },
        },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
  },
}
