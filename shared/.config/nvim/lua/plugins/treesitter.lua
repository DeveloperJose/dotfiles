-- Highlight, edit, and navigate code
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    commit = 'cf12346a3414fa1b06af75c79faebe7f76df080a',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'lua',
        'luadoc',
        'query',
        'vim',
        'vimdoc',
        'python',
        'php',
        'rust',
        'html',
        'css',
        'javascript',
        'typescript',
        'tsx',
        'vue',
        'latex',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby', 'php' },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<CR>',
          scope_incremental = '<S-CR>',
          node_decremental = '<M-CR>',
        },
      },
      indent = { enable = true, disable = { 'ruby', 'php' } },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    enabled = false,
    opts = function(_, opts)
      opts = opts or {}
      opts.enable = true
      opts.max_lines = 1
      opts.multiline_threshold = 20
      opts.trim_scope = 'outer'
      opts.mode = 'cursor'
      opts.patterns = {
        default = {
          'function',
          'method',
          'for',
          'while',
          'if',
          'switch',
          'case',
        },
        rust = {
          'function_item',
          'impl_item',
          'struct_item',
          'enum_item',
          'mod_item',
        },
      }
      return opts
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
