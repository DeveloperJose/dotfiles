# DevJ's Dotfiles

GNU Stow-managed dotfiles for shared machines and `arch-desktop`.

## Bootstrap

Fresh machine:

```bash
git clone git@github.com:DeveloperJose/dotfiles.git ~/dotfiles && cd ~/dotfiles && chmod +x sync.sh && ./sync.sh
```

The bootstrap is safe to re-run. It installs the recovery package set, makes
Fish the login shell, and restows the matching package folders.

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
