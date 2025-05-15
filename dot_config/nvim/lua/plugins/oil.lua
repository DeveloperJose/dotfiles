return {
  'stevearc/oil.nvim',
  opts = {}, -- use default options, customize if needed
  keys = {
    { "<leader>e", function() require("oil").open() end, desc = "Open Oil file explorer" },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
}

