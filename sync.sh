#!/bin/bash

# --- Configuration ---
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backups/$(date +%Y%m%d_%H%M%S)"

# Fix for missing 'hostname' command
HOST=${HOSTNAME:-$(hostnamectl hostname 2>/dev/null || echo "unknown")}

# --- Setup ---
mkdir -p "$BACKUP_DIR"
cd "$DOTFILES_DIR" || exit

echo "🚀 Starting dotfiles sync for host: $HOST"

# 1. Start with the baseline
PACKAGES=("shared")

# 2. Layered Fallthrough
# If it's any Arch machine, you could add an 'arch-shared' layer here
if [[ "$HOST" == *"arch"* ]]; then
    # PACKAGES+=("arch-shared") # Optional: for stuff common to all Arch
    if [[ "$HOST" == *"desktop"* ]]; then
        PACKAGES+=("arch-desktop")
        echo "🖥️  Applying Desktop-specific layers."
    elif [[ "$HOST" == *"laptop"* ]]; then
        PACKAGES+=("arch-laptop")
        echo "💻 Applying Laptop-specific layers."
    fi
fi

# 3. Handle Debian/Server environments
if [[ -f /etc/debian_version ]]; then
    PACKAGES+=("debian")
    echo "🐧 Applying Debian-specific layers."
fi

# 4. Final Sync Execution
for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "📦 Stowing: $pkg"

        # Conflict detection
        CONFLICTS=$(stow -nv -t ~ "$pkg" 2>&1 | grep "existing target" | awk '{print $NF}')
        for file in $CONFLICTS; do
            FULL_PATH="$HOME/$file"
            if [ -e "$FULL_PATH" ] && [ ! -L "$FULL_PATH" ]; then
                echo "⚠️  Backing up: $file"
                mkdir -p "$(dirname "$BACKUP_DIR/$file")"
                mv "$FULL_PATH" "$BACKUP_DIR/$file"
            fi
        done

        stow -t ~ "$pkg"
    fi
done

echo "✅ Sync complete for $HOST."
