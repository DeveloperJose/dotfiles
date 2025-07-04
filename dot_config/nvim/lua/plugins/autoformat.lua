-- https://github.com/stevearc/conform.nvim/issues/92
-- Format modified lines capability
local default_format_options = {
  lsp_fallback = true,
  async = false,
  timeout = 500,
  ignore_filetypes = { php = true, javascript = true },
}

-- function format_hunks(format_options)
--   local ignore_filetypes = { 'lua', 'php' }
--   if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
--     vim.notify('range formatting for ' .. vim.bo.filetype .. ' not working properly.')
--     return
--   end
--
--   local hunks = require('gitsigns').get_hunks()
--   if hunks == nil then
--     return
--   end
--
--   local format = require('conform').format
--
--   local function format_range()
--     if next(hunks) == nil then
--       vim.notify('done formatting git hunks', 'info', { title = 'formatting' })
--       return
--     end
--     local hunk = nil
--     while next(hunks) ~= nil and (hunk == nil or hunk.type == 'delete') do
--       hunk = table.remove(hunks)
--     end
--
--     if hunk ~= nil and hunk.type ~= 'delete' then
--       local start = hunk.added.start
--       local last = start + hunk.added.count
--       -- nvim_buf_get_lines uses zero-based indexing -> subtract from last
--       local last_hunk_line = vim.api.nvim_buf_get_lines(0, last - 2, last - 1, true)[1]
--       local range = { start = { start, 0 }, ['end'] = { last - 1, last_hunk_line:len() } }
--       format({ range = range, async = true, lsp_fallback = true }, function()
--         vim.defer_fn(function()
--           format_range()
--         end, 1)
--       end)
--     end
--   end
--
--   format_range()
-- end

return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>ff',
        function()
          -- local before = vim.g.format_modifications_only
          -- vim.g.format_modifications_only = false
          require('conform').format { async = true, lsp_format = 'fallback' }
          -- vim.g.format_modifications_only = before
        end,
        mode = '',
        desc = '[F]ormat [F]ile',
      },
      -- {
      --   '<leader>fm',
      --   format_hunks,
      --   desc = '[F]ormat [M]odified Lines',
      -- },
    },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        -- if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        --   return
        -- end
        -- if vim.g.format_modifications_only then
        --   -- Prefer to format Git hunks over entire file
        --   format_hunks()
        if default_format_options.ignore_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          -- Format entire file
          return default_format_options
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        php = { 'php_cs_fixer' },
        python = { 'ruff' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        yaml = { 'prettierd' },
        json = { 'prettierd' },
        bash = { 'shfmt' },
        sh = { 'shfmt' },
        zsh = { 'beautysh' },
        tex = { 'latexindent' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
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
