return {
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' },
        lazy = true,
        keys = { "<C-space>" },
        cmd = { 'Telescope' },
        config = function()
            local telescope = require('telescope')
            vim.cmd "cnoreabbrev copen Telescope quickfix"
            telescope.setup {
                defaults = {
                    mappings = {
                        i = {
                            ["<C-j>"] = "move_selection_next",
                            ["<C-k>"] = "move_selection_previous",
                            ["<c-d>"] = "delete_buffer",
                            ["<C-\\>"] = "which_key",
                            ["<c-a>"] = "toggle_all",
                            ["<c-]>"] = "send_selected_to_qflist",
                        },
                    },
                },
                pickers = {
                    find_files = {
                        -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
                        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                    },
                },
            }
            local builtins = require('telescope.builtin')
            vim.keymap.set('n', '<space>f', builtins.find_files)
            vim.keymap.set('n', '<space>b', builtins.buffers)
            vim.keymap.set('n', '<space>t', "<cmd>TodoTelescope<cr>")
            vim.keymap.set('n', '<space>r', builtins.registers)
            vim.keymap.set('n', '<space>h', builtins.grep_string)
            vim.keymap.set('n', '<space>s', builtins.live_grep)
            -- vim.keymap.set('i', '<C-space>s', builtins.grep_string)
            --vim.keymap.set('n', '<a-d>', builtins.diagnostics)
            --vim.keymap.set('n', '<c-space>s', builtins.lsp_workspace_symbols)
            --vim.keymap.set('n', '<c-space>r', builtins.lsp_references)
        end,
    }
}
