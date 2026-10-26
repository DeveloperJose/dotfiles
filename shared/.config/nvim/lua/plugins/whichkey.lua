return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VimEnter',
  ---@module 'which-key'
  ---@type wk.Opts
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    -- delay between pressing a key and opening which-key (milliseconds)
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },

    -- Avoid corrupting vim.v.count in Visual mode on Neovim 0.12 (Kickstart PR #2046)
    triggers = {
      { '<auto>', mode = 'nisotc' },
    },

    -- Document existing key chains
    spec = {
      { '<leader>d', group = '[D]ebug' },
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = '[H]arpoon' },
      { '<leader>q', group = '[Q]uickfix' },
      { '<leader>f', group = '[F]ormat' },
      { '<leader>n', group = '[N]ew Code' },
      { '<leader>l', group = '[L]aTeX' },
      { 'gr', group = 'LSP' },
    },
  },
}
