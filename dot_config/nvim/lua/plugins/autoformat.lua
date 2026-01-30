-- Format modified lines capability
local ignore_filetypes = { php = true, typescript = true, javascript = true, tsx = true }
local default_format_options = {
  async = true,
  timeout = 500,
  lsp_fallback = 'always',
}

-- Autoformat
return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>ff',
        function()
          require('conform').format(default_format_options)
        end,
        mode = '',
        desc = '[F]ormat [F]ile',
      },
    },
    opts = {
      notify_on_error = true,
      -- format_on_save = function(bufnr)
      --   if ignore_filetypes[vim.bo[bufnr].filetype] then
      --     return nil
      --   else
      --     -- Async isn't supported on saving so force it to be false
      --     return vim.tbl_deep_extend('force', {}, default_format_options, {
      --       async = false,
      --     })
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
          command = '/usr/bin/php7.4',
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
  },
}
