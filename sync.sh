#!/usr/bin/env bash
set -euo pipefail

if (($#)); then
    echo "Run ./sync.sh without arguments." >&2
    exit 2
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
machine="${HOSTNAME:-$(hostnamectl hostname 2>/dev/null || hostname)}"

case "$machine" in
    LAPTOP-0U1CQTBJ|arch-laptop|laptop)
        profile=laptop
        ;;
    arch-desktop|vps)
        profile="$machine"
        ;;
    *) echo "No profile configured for machine: $machine" >&2; exit 1 ;;
esac

if [[ -n "$(git -C "$repo_dir" status --porcelain)" ]]; then
    echo "Using local changes; skipping git pull."
elif [[ "${DOTFILES_SYNC_UPDATED:-0}" != 1 ]]; then
    git -C "$repo_dir" pull --ff-only
    exec env DOTFILES_SYNC_UPDATED=1 bash "$repo_dir/sync.sh"
fi
unset DOTFILES_SYNC_UPDATED

if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
    source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

prefer_nix_tools() {
    for nix_bin in /nix/var/nix/profiles/default/bin "$HOME/.nix-profile/bin" "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/bin"; do
        if [[ -d "$nix_bin" ]]; then
            export PATH="$nix_bin:$PATH"
        fi
    done
}
prefer_nix_tools

if ! command -v nix >/dev/null 2>&1; then
    echo "Install Nix first using the one-time setup in README.md." >&2
    exit 1
fi
if [[ ! -f "$repo_dir/flake.lock" ]]; then
    echo "flake.lock is missing. Generate and review it before syncing." >&2
    exit 1
fi

echo "Applying packages for $profile..."
activation="$(nix --extra-experimental-features 'nix-command flakes' build \
    --no-update-lock-file --no-link --print-out-paths \
    "$repo_dir#homeConfigurations.$profile.activationPackage")"
/usr/bin/python3 "$repo_dir/scripts/activate-home.py" "$activation" "$repo_dir"
prefer_nix_tools

if [[ "$profile" != laptop ]]; then
    echo "Preparing system files for $profile..."
    nix --extra-experimental-features 'nix-command flakes' build \
        --no-update-lock-file --out-link "$repo_dir/result-system" \
        "$repo_dir#$profile-system"
    echo "Apply system files separately with: sudo ./system.sh"
fi

nvim_dir="$HOME/.config/nvim"
if [[ ! -f "$nvim_dir/init.lua" || ! -f "$nvim_dir/lazy-lock.json" ]]; then
    echo "Neovim config or lockfile missing in $nvim_dir." >&2
    exit 1
fi
echo "Restoring Neovim plugins..."
nvim --headless -u "$nvim_dir/init.lua" '+Lazy! restore' +qa

echo "Sync complete."
