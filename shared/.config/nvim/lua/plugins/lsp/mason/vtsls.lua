-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.semanticTokens = nil -- disables semantic tokens safely

---@module "vim.lsp.client"
---@class vim.lsp.ClientConfig
return {
  disabled = false,
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
  },
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = '@vue/typescript-plugin',
            location = vim.fn.expand '$MASON/packages/vue-language-server/node_modules/@vue/language-server',
            languages = { 'vue' },
            configNamespace = 'typescript',
          },
        },
      },
    },
  },

}
