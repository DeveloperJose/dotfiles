-- https://www.dmsussman.org/resources/neovimsetup/
return {
  'lervag/vimtex',
  lazy = false, -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    vim.g.vimtex_imaps_enabled = 0
    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_syntax_enabled = 0
    vim.g.vimtex_compiler_latexmk = {
      out_dir = 'build',
    }
    vim.g.vimtex_quickfix_open_on_warning = 0
    vim.g.vimtex_quickfix_ignore_filters =
      { 'Underfull', 'Overfull', 'LaTeX Warning: .\\+ float specifier changed to', 'Package hyperref Warning: Token not allowed in a PDF string' }
  end,
}
