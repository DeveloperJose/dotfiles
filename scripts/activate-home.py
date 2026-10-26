#!/usr/bin/env python3
"""Transfer legacy repository links to Home Manager without deleting files."""

from datetime import datetime, timezone
import os
from pathlib import Path
import subprocess
import sys


def home_links(generation):
    root = generation / "home-files"
    for directory, folders, files in os.walk(root, followlinks=False):
        for name in folders[:]:
            path = Path(directory) / name
            if path.is_symlink():
                folders.remove(name)
                yield path.relative_to(root)
        for name in files:
            yield (Path(directory) / name).relative_to(root)


def activate(generation, repository, home):
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    backup = home / ".dotfiles_backups" / ("home-manager-" + stamp)
    moved = []
    try:
        for relative in home_links(generation):
            target = home / relative
            if not target.is_symlink():
                continue
            # Inspect the immediate link, not its resolved destination: an
            # existing Home Manager link also ultimately resolves to the repo.
            old_source = Path(os.path.abspath(target.parent / os.readlink(target)))
            if not old_source.is_relative_to(repository):
                continue
            saved = backup / relative
            saved.parent.mkdir(parents=True, exist_ok=True)
            os.replace(target, saved)
            moved.append((target, saved))

        environment = os.environ.copy()
        environment["HOME_MANAGER_BACKUP_EXT"] = "before-nix-" + stamp
        subprocess.run([str(generation / "activate")], env=environment, check=True)
    except BaseException:
        for target, saved in reversed(moved):
            if target.is_symlink():
                failed = backup / ".failed" / target.relative_to(home)
                failed.parent.mkdir(parents=True, exist_ok=True)
                os.replace(target, failed)
            if not target.exists():
                os.replace(saved, target)
        raise
    if moved:
        print("Previous repository links saved in", backup)


if __name__ == "__main__":
    activate(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve(), Path.home())
