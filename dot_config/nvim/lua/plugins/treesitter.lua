return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  opts = {
    ensure_installed = { 'bash', 'c', 'css', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'tsx', 'typescript', 'vim', 'vimdoc' },
    auto_install = true,
    highlight = {
      enable = true,
      use_languagetree = true,
    },
    indent = { enable = true, disable = { 'python' } },
  },
}
