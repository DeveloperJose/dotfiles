return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'mxsdev/nvim-dap-vscode-js',
  },
  keys = {
    {
      '<leader>dl',
      function() require('dap').run_last() end,
      desc = 'Debug (Run Last Config)',
    },
    {
      '<leader>dt',
      function() require('dap').toggle_breakpoint() end,
      desc = 'Debug (Toggle Breakpoint)',
    },
    {
      '<leader>dr',
      function() require('dap').repl.open() end,
      desc = 'Debug (REPL)',
    },
    {
      '<leader>do',
      function() require('dap').step_over() end,
      desc = 'Debug (Step Over)',
    },
    {
      '<leader>di',
      function() require('dap').step_into() end,
      desc = 'Debug (Step Into)',
    },
    {
      '<leader>du',
      function() require('dapui').toggle() end,
      desc = 'Debug (See last session result)',
    },
    {
      '<leader>dc',
      function() require('dap').continue() end,
      desc = 'Debug (Continue)',
    },
  },
  config = function()
    local dap = require 'dap'
    dap.set_log_level('TRACE')

    -- local js_debug_path = vim.fn.expand '$MASON/packages/js-debug-adapter/js-debug'
    local bun_dap_path = os.getenv('DATA') or (os.getenv('HOME') .. '/.local/share/nvim')
    bun_dap_path = bun_dap_path .. '/bun-dap/adapter.js'

    if vim.fn.filereadable(bun_dap_path) == 1 then
      dap.adapters.bun = {
        type = 'executable',
        command = 'sh',
        args = { '-c', 'node ' .. bun_dap_path .. ' 2> /tmp/bun-dap.log' },
      }

      local js_filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }
      for _, language in ipairs(js_filetypes) do
        dap.configurations[language] = dap.configurations[language] or {}
        table.insert(dap.configurations[language], {
          type = 'bun',
          request = 'attach',
          name = 'Bun: Attach (Manual)',
          url = function()
            return vim.fn.input('Bun inspector WebSocket URL: ')
          end,
        })
      end
    end

    -- PHP Debugger
    dap.configurations.php = {
      {
        name = 'awbw',
        hostname = '0.0.0.0',
        type = 'php',
        request = 'launch',
        port = 9003,
        pathMappings = {
          ['/var/www/'] = '${workspaceFolder}/public_html',
        },
      },
    }

    local path = vim.fn.expand '$MASON/packages/php-debug-adapter/extension/out/phpDebug.js'
    dap.adapters.php = {
      type = 'executable',
      command = 'node',
      args = { path },
    }
  end,
}
