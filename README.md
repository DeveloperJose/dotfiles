# DevJ's Dotfiles

GNU Stow-managed dotfiles for shared machines and `arch-desktop`.

## Bootstrap

Fresh machine:

```bash
git clone git@github.com:DeveloperJose/dotfiles.git ~/dotfiles && cd ~/dotfiles && chmod +x sync.sh && ./sync.sh
```

The bootstrap is safe to re-run. It installs the recovery package set, makes
Fish the login shell, and restows the matching package folders.

Before making changes, `sync.sh` stops and lists any uncommitted changes
(including untracked files). With a clean checkout, it runs `git pull --ff-only`
and reloads the updated script before proceeding. A failed pull stops the sync.
`--dry-run` checks for local changes but skips the pull.

After stowing `shared`, home syncs run `Lazy! restore` in headless Neovim to
apply the versions in `lazy-lock.json`. Restore failures stop the sync and
remain visible. System syncs skip this step; dry runs only print it.
To upgrade plugins deliberately, run `:Lazy update`, test, and commit the
updated lockfile.

Useful modes:

```bash
./sync.sh --dry-run
./sync.sh --no-bootstrap
./sync.sh shared
```

## System Files

`arch-desktop-system` manages root-targeted files for GRUB and greetd/DMS.

```bash
sudo ./sync.sh --system
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## Codex

Shared agent skills live under `shared/.agents/skills` and are stowed into
`~/.agents/skills`. Prefer this generic location for user-installed skills and
tool instructions so they can be shared across agents where possible.

Codex-specific configuration lives under `shared/.codex` and is stowed into
`~/.codex` only where Codex expects that path:

- `config.toml`
- `rules/default.rules`

Machine-local Codex state is intentionally not tracked: auth tokens, sessions,
logs, caches, model cache, shell snapshots, and temporary plugin checkouts.
