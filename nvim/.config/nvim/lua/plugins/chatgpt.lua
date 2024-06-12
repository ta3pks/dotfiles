return {
    "jackMort/ChatGPT.nvim",
    lazy = true,
    config = function()
        require("chatgpt").setup {
            chat = {
                keymaps = {
                    toggle_help = "<a-h>"
                },
                openai_params = {
                    model = "gpt-4o"
                },
            },
            popup_input = {
                submit = "<Enter>",
                submit_n = "<C-Enter>",
            }
        }
    end,
    keys = {
        { "<space>g", ":ChatGPT<cr>" }
    },
    dependencies = {
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "folke/trouble.nvim",
        "nvim-telescope/telescope.nvim"
    }
}
