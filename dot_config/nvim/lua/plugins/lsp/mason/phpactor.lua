return {
  -- cmd = { '/home/developerjose/.local/share/nvim/phpactor/bin/phpactor', 'language-server' },
  init_options = {
    ['language_server_phpstan.enabled'] = true,
    ['language_server_php_cs_fixer.enabled'] = false,
    ['language_server.diagnostic_ignore_codes'] = {
      'worse.docblock_missing_param',
      'worse.docblock_missing_return_type',
      'worse.missing_return_type',
    },
  },
}
