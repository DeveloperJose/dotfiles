---@module 'lazy'
---@type LazySpec
return {
    'windwp/nvim-ts-autotag',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ---@module 'nvim-ts-autotag'
    ---@type AutotagConfig
    config = function()
        require('nvim-ts-autotag').setup {
            opts = {
                enable_close = true,
                enable_rename = true,
                enable_close_on_slash = false,
            },
            per_filetype = {
                -- example override:
                -- html = { enable_close = false },
            },
        }
    end,
}
