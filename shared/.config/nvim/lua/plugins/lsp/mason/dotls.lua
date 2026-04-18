---@module 'lazy'
---@type LazySpec
---@module "vim.lsp.client"
---@class vim.lsp.ClientConfig
---@type LspServersConfig.mason
return {
  filetypes = { 'dotenv' },
  settings = {
    dotls = {
      documentFormatting = false,
    },
  },
}