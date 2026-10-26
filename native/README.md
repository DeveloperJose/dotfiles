# Native packages

Nix manages the shared user tools in `home/common.nix`. The operating system,
login shell, system services, drivers, desktop session, and build toolchains
continue to use pacman or apt.

The two desktop lists preserve the old `sync.sh` recovery package selections,
with `jq` and `zoxide` moved to Nix. They are reference lists, not a complete
inventory of the desktop and not automatically installed by `sync.sh`.

Native cleanup follows a working Nix installation on each machine. Review
duplicates and dependency effects before choosing packages to remove. Git
should remain available natively for cloning and recovering this repository;
Fish and OpenSSH also remain native. A package absent from these lists is not
automatically unnecessary.

Do not run unattended orphan removal or `apt autoremove` as part of dotfile
sync. Package removals and other root operations are performed separately by
the machine owner.

`reference/grub.d/` preserves old copies of distribution GRUB scripts. The
desktop has newer live versions, so pacman owns those scripts; the Nix system
bundle manages the custom GRUB settings and `40_custom` only.
