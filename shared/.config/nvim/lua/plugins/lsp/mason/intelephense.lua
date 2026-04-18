---@module 'lazy'
---@type LazySpec
---@module "vim.lsp.client"
---@class vim.lsp.ClientConfig
---@type LspServersConfig.mason
return {
  disabled = true,
  settings = {
    environment = {
      phpVersion = '5.6.0',
      phpExecutable = '/sbin/php74',
    },
  },
  filetypes = { 'php', 'inc' },
}
