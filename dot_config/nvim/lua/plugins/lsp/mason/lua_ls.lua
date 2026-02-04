-- Disabled: lua_ls is now configured inline in lsp.lua (kickstart commit 0c17d32)
-- This file is kept for reference but not loaded
return {
  disabled = true,
  settings = {
    Lua = {
      completion = {
        callSnippet = 'Replace',
      },
    },
  },
}
