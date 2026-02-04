local function get_mason_lsp_configs()
  local configs = {}
  local files = vim.fn.globpath(vim.fn.stdpath 'config' .. '/lua/plugins/lsp/mason', '*.lua', false, true)

  for _, file in ipairs(files) do
    local name = vim.fn.fnamemodify(file, ':t:r')
    local ok, config_or_err = pcall(require, 'plugins.lsp.mason.' .. name)
    if ok and type(config_or_err) == 'table' then
      if not config_or_err.disabled then
        configs[name] = config_or_err
      end
    else
      vim.notify(('Could not load LSP config "%s"\nReason: %s'):format(name, config_or_err), vim.log.levels.WARN)
    end
  end

  return configs
end

local ensure_installed = {
  'stylua',            -- Used to format Lua code
  'phpstan',           -- PHP Linter
  'phpcs',             -- PHP Linter (2)
  'php-cs-fixer',      -- PHP Formatter
  'php-debug-adapter', -- PHP DAP
  'eslint_d',          -- JS/TS Linter
  'prettierd',         -- JS/TS Formatter
  'ruff',              -- Python Formatter and Linter
  'shfmt',             -- Formatter (bash, sh)
  'shellcheck',        -- Linter (bash, sh)
  'beautysh',          -- Formatter (zsh)
  'latexindent',       -- Formatter (tex)
}

return {
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim',    opts = {} },

      -- 'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Toggle to show/hide diagnostic messages
          map('<leader>td', function()
            vim.diagnostic.enable(not vim.diagnostic.is_enabled())
          end, '[T]oggle [D]iagnostics')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Language servers can broadly be installed in the following ways:
      --  1) via the mason package manager; or
      --  2) via your system's package manager; or
      --  3) via a release binary from a language server's repo that's accessible somewhere on your system.

      -- The servers table comprises of the following sub-tables:
      -- 1. mason
      -- 2. others
      -- Both these tables have an identical structure of language server names as keys and
      -- a table of language server configuration as values.
      ---@class LspServersConfig
      ---@field mason table<string, vim.lsp.Config>
      ---@field others table<string, vim.lsp.Config>

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --  See `:help lsp-config` for information about keys and how to configure
      local servers = {
        mason = {},
        others = {},
      }

      -- Get Mason LSP configs from ./lsp/mason folder
      for name, config in pairs(get_mason_lsp_configs()) do
        if not config.disabled then
          servers.mason[name] = config
        end
      end

      -- NOTE: mason-tool-installer expects Mason package names (e.g., 'rust-analyzer')
      -- not LSP server names (e.g., 'rust_analyzer'). LSP servers should be installed
      -- manually via :Mason or added here with correct Mason package names.
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- Either merge all additional server configs from the `servers.mason` and `servers.others` tables
      -- to the default language server configs as provided by nvim-lspconfig or
      -- define a custom server config that's unavailable on nvim-lspconfig.
      for server, config in pairs(vim.tbl_extend('keep', servers.mason, servers.others)) do
        vim.lsp.config(server, config)
      end

      -- Manually enable all LSPs installed via Mason, this way we can ignore the explicitly disabled ones
      if not vim.tbl_isempty(servers.mason) then
        for _, server in ipairs(vim.tbl_keys(servers.mason)) do
          vim.lsp.enable(server)
        end
      end

      -- Manually run vim.lsp.enable for all language servers that are *not* installed via Mason
      if not vim.tbl_isempty(servers.others) then
        for _, server in ipairs(vim.tbl_keys(servers.others)) do
          vim.lsp.enable(server)
        end
      end

      -- Special Lua Config, as recommended by neovim help docs
      vim.lsp.config('lua_ls', {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = { version = 'LuaJIT', path = { 'lua/?.lua', 'lua/?/init.lua' } },
            workspace = {
              checkThirdParty = false,
              -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
              --  See https://github.com/neovim/nvim-lspconfig/issues/3189
              library = vim.tbl_filter(function(path)
                local config_path = vim.fn.stdpath 'config'
                return path ~= config_path and path ~= (config_path .. '/after')
              end, vim.api.nvim_get_runtime_file('', true)),
            },
          })
        end,
        settings = { Lua = {} },
      })

      -- Enable lua_ls
      vim.lsp.enable 'lua_ls'
    end,
  },
}
