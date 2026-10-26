return {
  'danymat/neogen',
  config = true,
  dependencies = 'nvim-treesitter/nvim-treesitter',
  ---@module 'neogen'
  ---@type NeogenConfig
  keys = {
    {
      '<leader>nf',
      function()
        require('neogen').generate()
      end,
      desc = 'Generate Doc Comment',
    },
  },
}
