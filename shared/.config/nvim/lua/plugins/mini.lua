-- Collection of various small independent plugins/modules
return {
  'nvim-mini/mini.nvim',
  config = function()
    -- Icons
    require('mini.icons').setup()
    -- Better Around/Inside textobjects
    require('mini.ai').setup {
      n_lines = 500,
      mappings = {
        around_next = '',
        inside_next = '',
        around_last = '',
        inside_last = '',
      },
    }
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

    -- Autocompletion is handled by blink.cmp; mini.completion disabled to avoid conflicts.
    -- (Previously mini.completion setup removed.)

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
