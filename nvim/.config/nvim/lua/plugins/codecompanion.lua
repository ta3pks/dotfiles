return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    keys = {
        { "<leader><space>a", "<cmd>CodeCompanionChat toggle<cr>", mode = "n" },
        { "<leader><space>i", "<cmd>CodeCompanion<cr>",            mode = "n" },
        { "<leader><space>i", ":'<,'>CodeCompanion<cr>",           mode = "v" },
    },
    config = function()
        require "codecompanion".setup {
            adapters = {
                opts = {
                    -- allow_insecure = true,
                    -- proxy = "socks5://192.168.1.64:6080",
                },
                anthropic = function()
                    return require("codecompanion.adapters").extend("anthropic", {
                        proxy = "socks5://localhost:6080",
                        env = {
                        },
                    })
                end,
            },
            strategies = {
                chat = {
                    adapter = "ollama",
                    -- adapter = "anthropic",
                },
                inline = {
                    adapter = "ollama",
                    -- adapter = "anthropic",
                },
            },
            adapter = function()
                require "codecompanion.adapters".extend("anthropic", {
                    env = {
                    },
                    schema = {
                        model = {
                            default = "claude-3.7-sonnet",
                        }
                    },
                }
                )
                require "codecompanion.adapters".extend("ollama", {
                    schema = {
                        model = {
                            -- default = 'victornitu/rust-coder'
                            -- default = "qwen2.5-coder:32b"
                            -- default = "deepseek-coder-v2"
                            default = 'codeastral'
                        }
                    }
                })
            end
        }
    end

}
