---@module 'lazy'
---@type LazySpec
---@module "vim.lsp.client"
---@class vim.lsp.ClientConfig
---@type LspServersConfig.mason
return {
  filetypes = { 'tex' },
  settings = {
    ltex = {
      language = 'en-US',
      diagnosticSeverity = 'information',
      additionalRules = { enablePickyRules = true },
    },
  },
}
