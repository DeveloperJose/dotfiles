return {
  disabled = true,
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = vim.fn.expand '$MASON/packages/vue-language-server/node_modules/@vue/language-server',
        languages = { 'typescript', 'vue' },
      },
    },
  },
}
