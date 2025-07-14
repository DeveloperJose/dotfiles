-- Highlight, edit, and navigate code
return {
  {
    'nvim-treesitter/nvim-treesitter',
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
        'markdown',
        'markdown_inline',
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
        'vue',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby', 'php' },
      },
      indent = { enable = false, disable = { 'ruby', 'php' } },
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
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesitter-context').setup {
        enable = true,
        max_lines = 1, -- Show only the current function
        multiline_threshold = 20, -- Fold long functions
        trim_scope = 'outer', -- Only show the outermost context
        mode = 'cursor', -- Show context based on cursor (not top line)
        patterns = {
          -- Default pattern list used for all filetypes if no override is set
          default = {
            'function',
            'method',
            'for',
            'while',
            'if',
            'switch',
            'case',
          },
          -- Override Rust to prioritize functions
          rust = {
            'function_item', -- Rust-specific Treesitter node for functions
            'impl_item',
            'struct_item',
            'enum_item',
            'mod_item',
          },
        },
      }
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
