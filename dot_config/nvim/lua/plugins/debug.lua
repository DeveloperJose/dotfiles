return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
  },
  keys = {
    {
      '<leader>dl',
      function()
        require('dap').run_last()
      end,
      desc = 'Debug (Run Last Config)',
    },
    {
      '<leader>dt',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug (Toggle Breakpoint)',
    },
    {
      '<leader>dr',
      function()
        require('dap').repl.open()
      end,
      desc = 'Debug (REPL)',
    },
    {
      '<leader>do',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug (Step Over)',
    },
    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug (Step Into)',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<leader>du',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug (See last session result)',
    },
    {
      '<leader>dc',
      function()
        require('dap').continue()
      end,
      desc = 'Debug (Continue)',
    },
  },
  config = function()
    local dap = require 'dap'

    require('mason-nvim-dap').setup {
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      ensure_installed = {
        'php-debug-adapter',
      },
    }

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
