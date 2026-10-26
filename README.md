# DevJ's Dotfiles

One Nix + Home Manager repository for the Arch laptop, Arch desktop, and Ubuntu
Oracle VPS. Packages and home-file links are declared in Nix. Existing config
files keep their original formats. Stow is no longer needed.

## Sync

```bash
cd ~/dotfiles
./sync.sh
```

The script selects the machine, builds its pinned Home Manager environment,
activates packages and dotfile links, and restores Neovim plugins. It has no
options and runs as your normal user. A clean checkout pulls updates first;
local edits skip the pull.

The initial activation moves old repository links into `~/.dotfiles_backups/`
before Home Manager takes ownership. If activation fails, the migration helper
restores those links. Other conflicting files get a dated backup beside the
original. Unrelated symlinks are preserved and reported as conflicts.

Application directories use Home Manager's live-repository links. This keeps
Fish state, editor files, generated desktop themes, and local credentials
writable. Ignored files are not copied into the Nix store. Editing an existing
config still takes effect directly; changing packages or link declarations
requires another sync. Configuration history is in Git; Home Manager generations
alone do not restore earlier contents of live files.

## Setup

Install Git, curl, Python 3, and Fish using the native package manager. Fish
remains the native login shell. Install Nix yourself with the official
[multi-user installer](https://nix.dev/install-nix.html), which requests sudo:

```bash
curl -fsSL https://nixos.org/nix/install -o /tmp/install-nix.sh
sh /tmp/install-nix.sh --daemon --no-modify-profile --no-channel-add
```

The laptop runs Arch under WSL2 with systemd, so it uses the same installation.
Clone this repository into `~/dotfiles`, then run `./sync.sh`. The flags above
leave shell setup to the dotfiles and package-source pinning to `flake.lock`.

## Updates and recovery

Update package pins deliberately from the repository:

```bash
nix flake update
./sync.sh
```

Review and commit `flake.lock` after checking the result. Ordinary syncs never
change it. New Nix files must be added to Git before building; Git flakes only
include files known to Git.

Home Manager retains package generations. Run `home-manager generations` to
find an earlier generation, then execute its `activate` script to restore its
packages and link declarations. Restore earlier config contents through Git.
Native packages and application data are managed separately.

## System files

On the desktop and VPS, sync also builds a `result-system` bundle. Applying
that bundle is a separate step you run yourself:

```bash
sudo ./system.sh
```

The installer checks the hostname, backs up replaced files under
`/var/backups/dotfiles/`, and installs regular root-owned files atomically. It
also preserves old link targets and refuses to write through directory
symlinks. Running it again skips files that are already current. The VPS
reloads systemd after unit changes; timers are not automatically enabled.

The desktop bundle contains custom GRUB and greetd/DMS files. After applying
GRUB changes, run:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

The laptop has no system-file bundle. Keep `result-system`: its symlink protects
the prepared bundle from Nix garbage collection. Sync never runs sudo.

## Repository layout

- `home/common.nix`: shared user packages.
- `home/files.nix`: shared home-file links.
- `home/laptop.nix`, `home/arch-desktop.nix`, `home/vps.nix`: host settings.
- `shared/`, `arch-desktop/`, `vps/`: original home configuration files.
- `arch-desktop-system/`, `vps-system/`: system-file sources.
- `native/`: native package recovery lists and archived GRUB references.
- `flake.nix` and `flake.lock`: machine definitions and pinned package sources.

OS essentials, services, build toolchains, the login shell, and the desktop
stack stay with pacman or apt. Native cleanup follows a working Nix environment
on each host; sync does not remove packages or run unattended orphan cleanup.
Keep native Git available for bootstrapping and recovery.

Neovim plugins still use Lazy's `lazy-lock.json`; update them deliberately with
`:Lazy update`, check the result, and commit the lockfile. Credentials, sessions,
caches, generated dependency manifests, and generated Codex user services stay
local and ignored. Shared agent skills live in `shared/.agents/skills`.
