#!/bin/bash

# --- Configuration ---
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backups/$(date +%Y%m%d_%H%M%S)"
HOST=$(hostname)

# --- Setup ---
mkdir -p "$BACKUP_DIR"
cd "$DOTFILES_DIR" || exit

echo "🚀 Starting dotfiles sync for host: $HOST"

# 1. Define which packages to stow based on hostname
PACKAGES=("shared") # Always stow shared

case "$HOST" in
# "arch-desktop")
#     PACKAGES+=("arch-desktop")
#     echo "🖥️  Desktop detected. Including UI and GPU configs."
#     ;;
# "arch-laptop")
#     PACKAGES+=("arch-laptop")
#     echo "💻 Laptop detected. Using portable profile."
#     ;;
*)
    echo "❓ Unknown host. Stowing 'shared' only."
    ;;
esac

# 2. The Sync Logic
for pkg in "${PACKAGES[@]}"; do
    echo "📦 Processing: $pkg"

    # Simulate stow to find conflicts (files that aren't links yet)
    # We grab the paths of existing files that would be overwritten
    CONFLICTS=$(stow -nv -t ~ "$pkg" 2>&1 | grep "existing target" | awk '{print $NF}')

    if [ -n "$CONFLICTS" ]; then
        for file in $CONFLICTS; do
            FULL_PATH="$HOME/$file"
            # Only backup if it's a real file/folder, not a symlink
            if [ -e "$FULL_PATH" ] && [ ! -L "$FULL_PATH" ]; then
                echo "⚠️  Conflict: $file. Moving to $BACKUP_DIR"
                mkdir -p "$(dirname "$BACKUP_DIR/$file")"
                mv "$FULL_PATH" "$BACKUP_DIR/$file"
            fi
        done
    fi

    # 3. Final Execution
    stow -t ~ "$pkg"
done

echo "✅ Sync complete! Your $HOST is now using the latest dotfiles."
