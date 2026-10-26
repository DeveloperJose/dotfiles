#!/usr/bin/env python3
"""Install a built system-file bundle, preserving existing file contents."""

from datetime import datetime, timezone
import os
from pathlib import Path
import shutil
import socket
import stat
import subprocess
import sys
import tempfile


def install_files(source, destination, backup):
    files = sorted(source.rglob("*"))
    plan = []
    for path in files:
        if path.is_symlink():
            raise ValueError(f"Unexpected symlink in system bundle: {path}")
        if not path.is_file():
            continue
        relative = path.relative_to(source)
        target = destination / relative
        for parent in target.parents:
            if parent == destination:
                break
            if parent.is_symlink():
                raise ValueError(f"Refusing to write through directory symlink: {parent}")
        if target.is_dir():
            raise ValueError(f"Expected a file, found a directory: {target}")
        mode = 0o755 if path.stat().st_mode & 0o111 else 0o644
        if (not target.is_symlink() and target.is_file()
                and target.read_bytes() == path.read_bytes()
                and stat.S_IMODE(target.stat().st_mode) == mode):
            continue
        plan.append((path, relative, target, mode))

    for path, relative, target, mode in plan:
        if target.exists():
            saved = backup / "files" / relative
            saved.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(target, saved)
        if target.is_symlink():
            saved_link = backup / "links" / relative
            saved_link.parent.mkdir(parents=True, exist_ok=True)
            os.symlink(os.readlink(target), saved_link)
        target.parent.mkdir(parents=True, exist_ok=True)
        descriptor, temporary = tempfile.mkstemp(prefix=".dotfiles-", dir=target.parent)
        with os.fdopen(descriptor, "wb") as output:
            output.write(path.read_bytes())
            output.flush()
            os.fsync(output.fileno())
        os.chmod(temporary, mode)
        os.replace(temporary, target)
        print("Installed", target)
    return len(plan)


def main():
    if os.geteuid() != 0:
        raise SystemExit("Run sudo ./system.sh to apply the prepared system files.")
    bundle = Path(sys.argv[1]).resolve()
    expected = (bundle / "host").read_text().strip()
    if socket.gethostname() != expected:
        raise SystemExit(f"This bundle is for {expected}, not {socket.gethostname()}.")
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    backup = Path("/var/backups/dotfiles") / stamp
    count = install_files(bundle / "files", Path("/"), backup)
    if count:
        if backup.exists():
            print("Previous files saved in", backup)
        if expected == "vps":
            subprocess.run(["systemctl", "daemon-reload"], check=True)
        else:
            print("Regenerate GRUB with: sudo grub-mkconfig -o /boot/grub/grub.cfg")
    else:
        print("System files are already current.")


if __name__ == "__main__":
    main()
