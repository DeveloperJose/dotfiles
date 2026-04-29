#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
TARGET_DIR="${TARGET_DIR:-$HOME}"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.dotfiles_backups}"
HOST="${HOSTNAME:-$(hostnamectl hostname 2>/dev/null || hostname 2>/dev/null || echo unknown)}"

DRY_RUN=0
RESTOW=1
BACKUP=1
REQUESTED_PACKAGES=()

usage() {
    cat <<'USAGE'
Usage: ./sync.sh [options] [package ...]

Options:
  -n, --dry-run      Show what would happen without changing files.
  --no-backup        Do not move conflicting files out of the way.
  --no-restow        Run stow normally instead of restow.
  -h, --help         Show this help.

With no package arguments, packages are selected from the host:
  shared, plus arch-desktop on arch desktop hosts, arch-laptop on arch laptop
  hosts, and debian on Debian hosts.
USAGE
}

while (($#)); do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=1
            ;;
        --no-backup)
            BACKUP=0
            ;;
        --no-restow)
            RESTOW=0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            REQUESTED_PACKAGES+=("$@")
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
        *)
            REQUESTED_PACKAGES+=("$1")
            ;;
    esac
    shift
done

if ! command -v stow >/dev/null 2>&1; then
    echo "GNU Stow is not installed. On Arch: sudo pacman -S --needed stow" >&2
    exit 127
fi

cd "$DOTFILES_DIR"

PACKAGES=()
if ((${#REQUESTED_PACKAGES[@]})); then
    PACKAGES=("${REQUESTED_PACKAGES[@]}")
else
    PACKAGES=("shared")

    if [[ -f /etc/arch-release ]]; then
        [[ -d arch-shared ]] && PACKAGES+=("arch-shared")
        if [[ "$HOST" == *desktop* && -d arch-desktop ]]; then
            PACKAGES+=("arch-desktop")
        elif [[ "$HOST" == *laptop* && -d arch-laptop ]]; then
            PACKAGES+=("arch-laptop")
        fi
    fi

    if [[ -f /etc/debian_version && -d debian ]]; then
        PACKAGES+=("debian")
    fi
fi

STOW_ARGS=(--dir "$DOTFILES_DIR" --target "$TARGET_DIR")
if ((RESTOW)); then
    STOW_ARGS+=(--restow)
fi
if ((DRY_RUN)); then
    STOW_ARGS+=(--no --verbose)
fi

BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d_%H%M%S)"

echo "Host: $HOST"
echo "Target: $TARGET_DIR"
echo "Packages: ${PACKAGES[*]}"

for pkg in "${PACKAGES[@]}"; do
    if [[ ! -d "$pkg" ]]; then
        echo "Skip missing package: $pkg"
        continue
    fi

    echo
    echo "Checking package: $pkg"
    if ! stow --no --verbose --dir "$DOTFILES_DIR" --target "$TARGET_DIR" "$pkg"; then
        if ((DRY_RUN)); then
            echo "Conflicts found for $pkg. Merge or back up these files before applying."
            continue
        fi

        if ((!BACKUP || DRY_RUN)); then
            echo "Conflicts found for $pkg. Re-run without --dry-run to back them up, or merge first." >&2
            exit 1
        fi

        mapfile -t conflicts < <(
            stow --no --verbose --dir "$DOTFILES_DIR" --target "$TARGET_DIR" "$pkg" 2>&1 |
                sed -n \
                    -e 's/.*existing target is neither a link nor a directory: //p' \
                    -e 's/.* over existing target \(.*\) since neither a link nor a directory.*/\1/p'
        )

        if ((${#conflicts[@]} == 0)); then
            echo "Stow reported a conflict, but it could not be parsed. Re-run with --dry-run and inspect manually." >&2
            exit 1
        fi

        for relpath in "${conflicts[@]}"; do
            src="$TARGET_DIR/$relpath"
            dst="$BACKUP_DIR/$relpath"
            if [[ -e "$src" && ! -L "$src" ]]; then
                echo "Backing up: $relpath"
                mkdir -p "$(dirname "$dst")"
                mv "$src" "$dst"
            fi
        done
    fi

    if ((DRY_RUN)); then
        stow "${STOW_ARGS[@]}" "$pkg"
    else
        stow "${STOW_ARGS[@]}" "$pkg"
    fi
done

echo
echo "Sync complete."
if [[ -d "$BACKUP_DIR" ]]; then
    echo "Backups: $BACKUP_DIR"
fi
