-- Highlight, edit, and navigate code
local parsers = {
  'bash', 'c', 'cpp', 'css', 'html', 'javascript', 'json', 'lua',
  'luadoc', 'markdown', 'markdown_inline', 'python', 'query',
  'rust', 'tsx', 'typescript', 'vim', 'vimdoc', 'yaml', 'php',
  'vue', 'latex', 'diff',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ts = require 'nvim-treesitter'
      -- Custom install dir for clean separation
      ts.setup {
        install_dir = vim.fn.stdpath('data') .. '/treesitter',
      }
      -- Install parsers (no-op if already installed)
      ts.install(parsers)

      -- Native highlighting via FileType autocmd
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft)
          if not lang then
            return
          end
          if vim.treesitter.language.add(lang) then
            vim.treesitter.start(args.buf, lang)
            -- Optional indentation (experimental)
            local has_indent = vim.treesitter.query.get(lang, 'indents') ~= nil
            if has_indent then
              vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          enable = true,
          lookahead = true,
          selection_modes = {
            ['@function.outer'] = 'V',
            ['@function.inner'] = 'v',
            ['@class.outer'] = 'V',
            ['@class.inner'] = 'v',
          },
        },
      }
      -- Keymaps mapped manually to match previous behavior
      vim.keymap.set({ 'x', 'o' }, 'af', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
      end)
      vim.keymap.set({ 'x', 'o' }, 'if', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
      end)
      vim.keymap.set({ 'x', 'o' }, 'ac', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
      end)
      vim.keymap.set({ 'x', 'o' }, 'ic', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
      end)
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    enabled = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = function(_, opts)
      opts = opts or {}
      opts.enable = true
      opts.max_lines = 1
      opts.multiline_threshold = 20
      opts.trim_scope = 'outer'
      opts.mode = 'cursor'
      opts.patterns = {
        default = {
          'function', 'method', 'for', 'while', 'if', 'switch', 'case',
        },
        rust = {
          'function_item', 'impl_item', 'struct_item', 'enum_item', 'mod_item',
        },
      }
      return opts
    end,
  },
}
