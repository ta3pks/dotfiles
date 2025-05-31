return {
  "kelly-lin/ranger.nvim",
  config = function()
    require("ranger-nvim").setup({  })
    vim.cmd[[
        command! Ranger lua require("ranger-nvim").open(true)
    ]]
  end,
}
