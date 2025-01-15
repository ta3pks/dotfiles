return {
    "ahmedkhalf/project.nvim",
    lazy = false,
    keys={
        {
            "<leader>p", ":Telescope projects<CR>", desc = "Projects"
        }
    },
    config = function()
        require("project_nvim").setup({
            -- detection_methods = { "pattern" },
        })
        require'telescope'.load_extension'projects'
    end,
}
