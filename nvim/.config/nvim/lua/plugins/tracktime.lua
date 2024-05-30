return {
    'gaborvecsei/usage-tracker.nvim',
    event = "VeryLazy",
    config = function()
        require("usage-tracker").setup {}
    end
}
