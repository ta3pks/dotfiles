return {
    "dpayne/CodeGPT.nvim",
    lazy = true,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
    },
    cmd = { "Chat" },
    config = function()
        -- vim.g["codegpt_global_commands_defaults"] = {
        -- model = "gpt-4o",
        --     -- max_tokens = 4096,
        --     -- temperature = 0.4,
        --     -- extra_parms = { -- optional list of extra parameters to send to the API
        --     --     presence_penalty = 1,
        --     --     frequency_penalty= 1
        --     -- }
        -- }
        require("codegpt.config")
    end
}
