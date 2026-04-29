-- Collection of various small independent plugins/modules
return {
  'nvim-mini/mini.nvim',
  config = function()
    -- Icons
    require('mini.icons').setup()
    -- Better Around/Inside textobjects
    require('mini.ai').setup { n_lines = 500 }
    -- Surround actions
    require('mini.surround').setup()
    -- Autopairs
    require('mini.pairs').setup()
    -- Move selection
    require('mini.move').setup {
      mappings = {
        line_left = '',
        line_right = '',
        line_down = '',
        line_up = '',
      },
    }
    -- Visualize indent scope
    require('mini.indentscope').setup()
    -- Comments
    require('mini.comment').setup()

    -- Autocompletion and signature help
    local function in_string_or_comment()
      local ts_utils = require 'nvim-treesitter.ts_utils'
      local ok, node = pcall(ts_utils.get_node_at_cursor)
      if not ok or not node then
        return false
      end

      while node do
        local t = node:type()
        if t == 'string' or t == 'string_fragment' or t == 'comment' then
          return true
        end
        node = node:parent()
      end
      return false
    end

    local function unique_items(items)
      local seen = {}
      local result = {}
      for _, item in ipairs(items) do
        if not seen[item.label] then
          seen[item.label] = true
          table.insert(result, item)
        end
      end
      return result
    end

    local function process_items(items, base)
      local filtered = unique_items(items)
      -- You can also call default processing if you want sorting/fuzzy matching
      return require('mini.completion').default_process_items(filtered, base)
    end

    require('mini.completion').setup {
      delay = { completion = 100, info = 2000, signature = 500 },
      lsp_completion = {
        process_items = process_items,
      },
      disable = function()
        return in_string_or_comment()
      end,
    }

    -- Tab and Shift-Tab to navigate completion popup menu
    local imap_expr = function(lhs, rhs)
      vim.keymap.set('i', lhs, rhs, { expr = true, silent = true })
    end

    imap_expr('<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
    imap_expr('<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])

    -- Custom Enter key: confirm completion with <C-y> if selected, else insert newline
    _G.cr_action = function()
      if vim.fn.complete_info()['selected'] ~= -1 then
        return '\25' -- Ctrl-Y
      end
      return '\r'
    end

    vim.keymap.set('i', '<CR>', 'v:lua.cr_action()', { expr = true, silent = true })

    -- Simple and easy statusline. We'll remove some sections I don't want to see from it
    local statusline = require 'mini.statusline'

    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return ''
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_diff = function()
      return ''
    end
    statusline.setup { use_icons = vim.g.have_nerd_font }
  end,
}
