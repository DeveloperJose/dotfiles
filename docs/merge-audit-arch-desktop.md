# Merge Audit: Arch Desktop

This audit covers the current uncommitted merge from live config into the Stow repo.

## Verified

- `fish -n shared/.config/fish/config.fish` passes.
- `nvim --headless -u shared/.config/nvim/init.lua '+quitall'` exits cleanly.
- With `XDG_CONFIG_HOME` pointed at `shared/.config`, `:checkhealth vim.deprecated` reports no deprecated functions.
- `diff -qr` against live config is clean for imported desktop directories after excluding intentionally ignored generated/backup files.
- No generated `node_modules`, `.git`, `bun.lock`, compiled spell files, Niri backups, or Kitty backups were imported.

## Manually Merged

- `shared/.config/fish/config.fish`
  - Kept live LM Studio path.
  - Kept live removal of `/sbin` and `/usr/sbin` from `PATH`.
  - Restored repo Bun, Cargo, and global Node binary paths.
  - Restored `DOCKER_BUILDKIT`.
  - Restored `set --erase DISPLAY`.
  - Restored ssh-agent and key-loading block per user request.

- `shared/.ssh/config`
  - Kept live `frodo` and `bilbo` hosts.
  - Restored `ForwardAgent yes` for `nas` per user request.
  - Restored `User git` for `github.com` per user request.
  - Kept live `IdentitiesOnly yes` and `ForwardAgent yes` for `github.com`.

- `shared/.config/opencode/opencode.jsonc`
  - Kept live `serena_mcp` enabled.
  - Kept live `edit` and `read` disabled.
  - Restored repo deny rules for dev-server commands and `git push`/`git pull`.

- `shared/.config/opencode/.gitignore`
  - Kept generated dependency ignores for `node_modules` and `bun.lock`.
  - Removed `package.json` from the ignore list so imported plugin manifests are trackable.
  - Removed self-ignore for `.gitignore`.

- `shared/.config/nvim/lua/options.lua`
  - Kept live direct clipboard and OSC52 handling.
  - Restored repo dotenv filetype mappings.
  - Kept moved insert-mode `<Tab>` mapping.

- `shared/.config/nvim/lua/keymaps.lua`
  - Kept live diagnostic underline severity change.
  - Fixed imported typo in `virtual_lines` comment.
  - Replaced deprecated `jump.float` with `jump.on_jump` for Neovim 0.12, matching Kickstart PR #1982.
  - Kept moved insert-mode `<Tab>` mapping in `options.lua`.

- `shared/.config/nvim/lua/plugins/autocompletion.lua`
  - Restored Kickstart-style `blink.cmp` and `LuaSnip` instead of the live disabled `return {}`.
  - Kept Kickstart's Lua fuzzy matcher default instead of forcing the optional Rust matcher.

- `shared/.config/nvim/lua/plugins/lsp.lua`
  - Kept the live move to Neovim's `vim.lsp.config` / `vim.lsp.enable` API.
  - Kept `mason-tool-installer` because it installs formatters, linters, and DAP adapters, not just LSP servers.
  - Added explicit Mason package names for enabled LSP servers so installation does not depend on `mason-lspconfig` handlers.
  - Kept the user's per-LSP-file structure; Lua server config lives in `lsp/mason/lua_ls.lua`.

- `shared/.config/nvim/lua/plugins/lsp/mason/lua_ls.lua`
  - Re-enabled this file and moved the Lua server config back out of `lsp.lua`.
  - Preserved Kickstart's Neovim-runtime setup and restored repo completion/diagnostic settings.

- `shared/.config/nvim/lua/plugins/lsp/mason/ts_ls.lua`
  - Removed the disabled reference file so `vtsls` is the single JS/TS/Vue language server.

- `shared/.config/nvim/lua/plugins/autoformat.lua`
  - Kept live `<leader>ff`, `/usr/bin/php7.4`, explicit formatter list, and `notify_on_error = true`.
  - Updated manual format options to current Conform names: `timeout_ms` and `lsp_format`.

- `shared/.config/nvim/lua/plugins/treesitter.lua`
  - Kept live expanded parser list and `nvim-treesitter-context`.
  - Restored old repo `tsx` parser as part of the expanded parser set.
  - Kept Treesitter indent enabled, disabling only Ruby and PHP.

- `shared/.config/fish/fish_variables`
  - Removed from the repo and added to `.gitignore` because it is generated Fish universal variable state.

- `shared/.config/nvim/lua/plugins/telescope.lua`
  - Restored repo `<leader>s/` and `<leader>sn` mappings.

- `shared/.config/nvim/lua/plugins/lsp/mason/tailwindcss.lua`
  - Restored repo custom Tailwind filetypes and `userLanguages`.

- `shared/.config/nvim/lua/plugins/lsp/mason/psalm.lua`
  - Restored `disabled = true` so Psalm is not accidentally enabled.
  - Kept live `php7.4` spelling in the commented example.

## Repo-Only Files Preserved

These were accidentally removed by the first import pass and have been restored:

- `shared/.config/nvim/lua/plugins/lsp/mason/dotls.lua`
- `shared/.config/opencode/package-lock.json`

## Live-Only Files Imported

- `shared/.config/fish/functions/opencode.fish`
- `shared/.config/nvim/.gitignore`
- `shared/.config/nvim/bun-dap-bridge.js`
- `shared/.config/nvim/interactive-test.ts`
- `shared/.config/nvim/lua/plugins/indent_line.lua`
- `shared/.config/nvim/lua/plugins/llama-vim.lua`
- `shared/.config/nvim/lua/plugins/snippets.lua`
- `shared/.config/nvim/lua/plugins/tailwind-tools.lua`
- `shared/.config/nvim/lua/snippets/php.lua`
- `shared/.config/nvim/test.ts`
- `shared/.config/opencode/agent/*.md`
- `shared/.config/opencode/plugins/.opencode/context.md`
- `shared/.config/opencode/plugins/opencode-context/*`
- `shared/.config/opencode/skill/context.ts`
- all files under `arch-desktop/.config` listed in `docs/config-inventory-arch-desktop.md`

Generated OpenCode plugin build output was copied during the first import pass but removed from the dotfiles tree:

- `shared/.config/opencode/plugins/opencode-context/dist/*`

## Remaining Behavioral Decisions

These files were checked and still represent real behavior changes from the old repo version. They are not silent misses; they need an explicit choice if you do not want the live behavior.

- `shared/.config/fish/fish_variables`
  - Resolved: no longer tracked. `config.fish` owns the portable PATH setup.

- `shared/.config/nvim/lua/plugins/autocompletion.lua`
  - Resolved: keep Kickstart-style completion with `blink.cmp` and `LuaSnip`.

- `shared/.config/nvim/lua/plugins/lsp.lua`
  - Resolved: keep `vim.lsp.config` / `vim.lsp.enable`, keep `mason-tool-installer`, and install enabled LSP servers by explicit Mason package name.

- `shared/.config/nvim/lua/plugins/lsp/mason/lua_ls.lua`
  - Resolved: Lua server config is active in its own file.

- `shared/.config/nvim/lua/plugins/lsp/mason/ts_ls.lua`
  - Resolved: removed disabled reference file; `vtsls` owns JS/TS/Vue.

- `shared/.config/nvim/lua/plugins/lsp/mason/vtsls.lua`
  - Resolved: kept `vtsls` enabled.

- `shared/.config/nvim/lua/plugins/autoformat.lua`
  - Resolved: kept live behavior and updated Conform option names.

- `shared/.config/nvim/lua/plugins/treesitter.lua`
  - Resolved: kept expanded parser/context behavior and enabled indent except Ruby/PHP.

- `shared/.config/nvim/lazy-lock.json`
  - Resolved: restored `blink.cmp` and `LuaSnip` lock entries because completion is enabled.
  - Intentionally did not restore `mason-lspconfig` because LSP setup no longer uses it.
  - Live lockfile adds `llama.vim` and `nvim-treesitter-context`.

## Cosmetic Or Annotation-Only Changes

These were checked; changes are comments, annotations, formatting, or equivalent Lua call syntax:

- `shared/.config/nvim/lua/kickstart/health.lua`
- `shared/.config/nvim/lua/plugins/autopairs.lua`
- `shared/.config/nvim/lua/plugins/debug.lua`
- `shared/.config/nvim/lua/plugins/gitsigns.lua`
  - Restored useful plugin option annotations.
- `shared/.config/nvim/lua/plugins/harpoon.lua`
- `shared/.config/nvim/lua/plugins/indent.lua`
  - Restored useful plugin option annotations.
- `shared/.config/nvim/lua/plugins/lint.lua`
- `shared/.config/nvim/lua/plugins/lsp/mason/bashls.lua`
- `shared/.config/nvim/lua/plugins/lsp/mason/intelephense.lua`
  - Kept live removal of hardcoded `/sbin/php74`.
- `shared/.config/nvim/lua/plugins/lsp/mason/ltex-ls-plus.lua`
- `shared/.config/nvim/lua/plugins/lsp/mason/phpactor.lua`
  - Kept live removal of hardcoded `/sbin/php74`.
- `shared/.config/nvim/lua/plugins/lsp/mason/pyright.lua`
- `shared/.config/nvim/lua/plugins/lsp/mason/rust_analyzer.lua`
- `shared/.config/nvim/lua/plugins/lsp/mason/vue_ls.lua`
- `shared/.config/nvim/lua/plugins/mini.lua`
- `shared/.config/nvim/lua/plugins/neogen.lua`
  - Restored useful plugin option annotations.
- `shared/.config/nvim/lua/plugins/nvim-colorizer.lua`
- `shared/.config/nvim/lua/plugins/nvim-ts-autotag.lua`
  - Normalized indentation and restored useful plugin option annotations.
- `shared/.config/nvim/lua/plugins/oil.lua`
  - Restored useful plugin option annotations.
- `shared/.config/nvim/lua/plugins/theme.lua`
  - Restored useful plugin option annotations.
- `shared/.config/nvim/lua/plugins/todo-comments.lua`
  - Expanded one-line spec and restored useful plugin option annotations.
- `shared/.config/nvim/lua/plugins/typescript-tools.lua`
- `shared/.config/nvim/lua/plugins/vimtex.lua`
  - Restored useful plugin option annotations.
- `shared/.config/nvim/lua/plugins/whichkey.lua`
  - Restored useful plugin option annotations.

## Non-Merge Repo Work

- `sync.sh`
  - Changed Stow workflow script; not part of live config merge.
