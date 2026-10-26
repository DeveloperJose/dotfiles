return {
  'ggml-org/llama.vim',
  init = function()
    -- Only activate if a server endpoint is configured; suppress FIM/startup errors otherwise.
    -- The plugin uses g:llama_config; disable FIM and startup attempts by default.
    vim.g.llama_config = {
      auto_fim = false,
      enable_at_startup = false,
      show_info = 0,
    }
  end,
  config = function()
    -- No-op: plugin configured via init; only activates when server is explicitly configured.
  end,
}
