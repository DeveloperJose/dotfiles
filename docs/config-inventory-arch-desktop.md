# Arch Desktop Config Inventory

Generated from `/home/devj/.config` on the Arch desktop.

## Stow State

- Dotfiles repo: `/home/devj/dotfiles`
- Current Stow baseline package: `shared`
- New host package placeholder: `arch-desktop`
- `stow` is installed: GNU Stow 2.4.1 at `/usr/bin/stow`.
- `./sync.sh --dry-run shared arch-desktop` currently reports conflicts because the live files still exist as normal files. This is expected until the live copies are removed, moved, or adopted.
- Live shared configs have been merged into `shared`.
- Live Arch desktop configs have been imported into `arch-desktop`.

## Existing Repo Overlap

These live config roots overlap `shared`:

- `.config/fish`
- `.config/nvim`
- `.config/opencode`
- `.config/starship.toml`
- `.gitconfig`
- `.ssh/config`
- `.tmux.conf`

Exact matches that are safe to let Stow own after conflicts are cleared:

- `.config/starship.toml`
- `.gitconfig`
- `.config/nvim/init.lua`
- `.config/nvim/.stylua.toml`
- `.config/nvim/README.md`
- `.config/nvim/lua/lazy-bootstrap.lua`
- `.config/nvim/spell/en.utf-8.add`
- `.config/fish/functions/chadd.fish`
- `.config/fish/functions/fish_functions.fish`
- `.config/fish/functions/fish_prompt.fish`
- `.config/fish/functions/gc.fish`
- `.config/fish/functions/gco.fish`
- `.config/fish/functions/gd.fish`
- `.config/fish/functions/gdd.fish`
- `.config/fish/functions/gs.fish`
- `.config/fish/functions/gst.fish`
- `.config/fish/functions/ldir.fish`
- `.config/fish/functions/lg.fish`
- `.config/fish/functions/ll.fish`
- `.config/fish/functions/reload.fish`
- `.config/fish/functions/update.fish`
- `.config/opencode/dcp.jsonc`

Merged into repo from the live Arch desktop:

- `.config/fish`
- `.config/nvim`, excluding `.git/` and compiled spell files
- `.config/opencode`, excluding `node_modules/` and `bun.lock`
- `.config/starship.toml`
- `.gitconfig`
- `.ssh/config`
- `.tmux.conf`

Repo-only files not present live:

- `.config/nvim/lua/plugins/lsp/mason/dotls.lua`
- `.config/opencode/package-lock.json`

Live-only files worth deciding on:

- `.config/fish/functions/opencode.fish`: likely useful shell integration.
- `.config/nvim/lua/plugins/indent_line.lua`
- `.config/nvim/lua/plugins/llama-vim.lua`
- `.config/nvim/lua/plugins/snippets.lua`
- `.config/nvim/lua/plugins/tailwind-tools.lua`
- `.config/nvim/lua/snippets/php.lua`
- `.config/nvim/bun-dap-bridge.js`
- `.config/nvim/interactive-test.ts`
- `.config/nvim/test.ts`
- `.config/opencode/agent/*.md`
- `.config/opencode/plugins/**`
- `.config/opencode/skill/context.ts`

Live-only files that should not be tracked:

- `.config/nvim/.git/**`
- `.config/nvim/spell/*.spl`
- `.config/opencode/node_modules/**`
- `.config/opencode/bun.lock`

## Arch Desktop Candidates

Imported into `arch-desktop`:

- `.config/niri`, excluding timestamped backups
- `.config/foot`
- `.config/fuzzel`
- `.config/environment.d`
- `.config/DankMaterialShell`, excluding generated changelog/firstlaunch files
- `.config/kitty`, excluding timestamped backups

Still good candidates to import later:

- `.config/qt5ct`, `.config/qt6ct`, `.config/gtk-3.0`, `.config/gtk-4.0`: theming, useful if you want desktop appearance synced.
- `.config/cava`, `.config/lazygit`: small user configs, good shared or arch-desktop candidates depending on host usage.

## Safe Delete Or Archive

Already removed from live config:

- `.config/hypr`
- `.config/waybar`

These look safe to remove or move to a dated backup now:

- `.config/niri/config.kdl.backup.*` and `.config/niri/config.kdl.dmsbackup*`: old Niri backups. Keep only if you want manual rollback history.
- `.config/kitty/kitty.conf.backup.*`: old Kitty backups.

## Leave Unmanaged

These are app state, browser profiles, generated caches, or tool state. Do not Stow them unless there is a specific reason:

- `.config/BraveSoftware`
- `.config/mozilla`
- `.config/discord`
- `.config/Bitwarden CLI`
- `.config/LM Studio`
- `.config/StardewValley`
- `.config/unity3d`
- `.config/chezmoi`
- `.config/dconf`
- `.config/pulse`
- `.config/go`
- `.config/composer`
- `.config/yay`
- `.config/turborepo`
- `.config/matplotlib`
- `.config/procps`
- `.config/Ultralytics`

## Unknown Or Low Priority

Review before deleting; many are small app configs or remnants from apps that may still be installed:

- `.config/BetterDiscord`
- `.config/Electron`
- `.config/Equicord`
- `.config/GIMP`
- `.config/Kvantum`
- `.config/QtProject.conf`
- `.config/Thunar`
- `.config/Vencord`
- `.config/alacritty`
- `.config/astro`
- `.config/btop`
- `.config/bws`
- `.config/cosmic`
- `.config/danksearch`
- `.config/dgop`
- `.config/dunst`
- `.config/equibop`
- `.config/flameshot`
- `.config/guvcview2`
- `.config/htop`
- `.config/inkscape`
- `.config/ksnip`
- `.config/legcord`
- `.config/mcp`
- `.config/nautilus`
- `.config/nvtop`
- `.config/nwg-look`
- `.config/quickshell`
- `.config/simple-scan`
- `.config/spicetify`
- `.config/systemd`
- `.config/user-dirs.dirs`
- `.config/user-dirs.locale`
- `.config/vesktop`
- `.config/xfce4`
- `.config/xsettingsd`
