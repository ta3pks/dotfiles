return {
    {
        'MarcHamamji/runner.nvim',
        dependencies = {
            'nvim-telescope/telescope.nvim',
            dependencies = { 'nvim-lua/plenary.nvim' }
        },
        config = function()
            require('runner').setup {}
        end
    },
    {
        "folke/neodev.nvim",
    },
    {
        "kana/vim-textobj-indent",
        event = "VeryLazy",
        dependencies = {
            "kana/vim-textobj-user",
        }
    },
    { 'rafcamlet/nvim-luapad',  cmd = { "Luapad" } },
    {
        'wellle/targets.vim',
        config = function()
            vim.keymap.set("n", "<leader>", "<Plug>(easymotion-prefix)", { silent = true })
        end,
        keys = {
            "<leader>w",
        },
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim",
            'nvim-telescope/telescope.nvim',
        },
        cmd =
        {
            "TodoTelescope",
            "Todos",
        },
        keys = {
            { "<c-space>d", ":TodoTelescope <cr>", noremap = true, silent = true },
        },
        config = function(cfg)
            require "todo-comments".setup(cfg)
            vim.cmd [[command! Todos TodoTelescope]]
        end
    },
    {
        "mmahnic/vim-flipwords",
        lazy = true,
        cmd = { "Flip" },
    },
    {
        "tpope/vim-surround",
        event = "VeryLazy",
        dependencies = { "tpope/vim-repeat" },
    },
    {
        "tpope/vim-repeat",
    },
    {
        'stevearc/dressing.nvim',
        event = "VeryLazy",
    },
    {
        "tomtom/tcomment_vim",
        keys = {
            {
                "<c-/>", ":TComment<cr>", noremap = true, silent = true, mode = "n"
            },
            {
                --insert mode
                "<c-/>",
                "<c-o>:TComment<cr>",
                noremap = true,
                silent = true,
                mode = "i"
            },
            {
                "<c-/>",
                function()
                    vim.fn.feedkeys('gcgv')
                end,
                noremap = true,
                silent = true,
                mode = "v"
            },
        },
    },
    { 'wakatime/vim-wakatime',  event = "VeryLazy" },
    { 'airblade/vim-gitgutter', event = "BufReadPost" },

}
