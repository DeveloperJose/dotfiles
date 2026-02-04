-- tailwind-tools.lua
return {
  'luckasRanarison/tailwind-tools.nvim',
  name = 'tailwind-tools',
  build = ':UpdateRemotePlugins',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim',
    'neovim/nvim-lspconfig',
  },
  opts = function(_, opts)
    opts = opts or {}
    opts.tailwind_css_filetypes = { 'html', 'css', 'javascript', 'typescript', 'vue', 'svelte', 'astro' }
    opts.server = opts.server or {}
    opts.server.override = false
    return opts
  end,
}
