return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    -- format_on_save = function(bufnr)
    --   local disable_filetypes = { c = true, cpp = true }
    --   if disable_filetypes[vim.bo[bufnr].filetype] then
    --     return nil
    --   else
    --     return {
    --       timeout_ms = 500,
    --       lsp_format = 'fallback',
    --     }
    --   end
    -- end,
    formatters_by_ft = {
      lua = { 'stylua' },
      php = { 'php_cs_fixer' },
      python = { 'ruff' },
      javascript = { 'prettierd' },
      typescript = { 'prettierd' },
      vue = { 'prettierd' },
      yaml = { 'prettierd' },
      json = { 'prettierd' },
      bash = { 'shfmt' },
      sh = { 'shfmt' },
      zsh = { 'beautysh' },
      tex = { 'latexindent' },
    },
    formatters = {
      php_cs_fixer = {
        command = 'php74',
        args = {
          vim.fn.expand '~/.local/share/nvim/mason/packages/php-cs-fixer/php-cs-fixer.phar',
          'fix',
          [[--rules={"@PSR12": true, "visibility_required": false}]],
          '--path-mode=override',
          '--quiet',
          '--using-cache=no',
          '--no-interaction',
          '$FILENAME',
        },
        stdin = false,
      },
    },
  },
}
